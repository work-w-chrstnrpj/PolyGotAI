import SwiftUI
import Observation

/// Phase 15: the three timed tests. Each test is written by the online model; without a key, Start opens the key setup.
struct LabTimedTestsView: View {
    var storage: LearnerStorageController
    var body: some View {
        List { KitRows {
            Section {
                ForEach(TimedTestKind.allCases) { kind in
                    NavigationLink { TimedTestView(storage: storage, kind: kind) } label: {
                        KitContentRow(symbol: kind.symbol, title: kind.title, detail: kind.subtitle)
                    }.accessibilityIdentifier("timed.\(kind.rawValue)")
                }
            } footer: { Text("Every test is new, written by AI.") }
        }}
        .listStyle(.insetGrouped).scrollContentBackground(.hidden)
        .background(Kit.canvas(storage.preferences.background))
        .navigationTitle("Timed tests").navigationBarTitleDisplayMode(.inline)
    }
}

@MainActor @Observable final class TimedTestController {
    enum Stage: Equatable { case start, loading, running, finished }
    let kind: TimedTestKind
    private let service: LabFeedbackService?
    private let seconds: Int
    private var work: Task<Void, Never>?
    private var generation = UUID()
    private(set) var stage: Stage = .start
    private(set) var test: TimedTest?
    private(set) var clock: TimedTestClock?
    var answers = TimedChoiceAnswers(count: 0)
    var text = ""
    private(set) var feedback: LabFeedback?
    private(set) var sending = false
    private(set) var message: String?
    var isAvailable: Bool { service?.isAvailable == true }

    init(kind: TimedTestKind, service: LabFeedbackService?, seconds: Int? = nil) {
        self.kind = kind; self.service = service; self.seconds = seconds ?? kind.seconds
    }

    /// Called only by Start, beside the cost and privacy line.
    func start(level: String, storage: LearnerStorageController) {
        guard isAvailable, let service, stage == .start || stage == .finished else { return }
        let seen = (try? storage.repository?.labExtras()) ?? LabExtrasState()
        var random = SystemRandomNumberGenerator()
        let request = TimedTestRequest(kind: kind, level: level, theme: seen.nextTheme(for: kind, using: &random))
        let consent = LabFeedbackConsent(shown: .current(mode: .writing, includesAudio: false))
        let token = UUID(); generation = token
        stage = .loading; test = nil; feedback = nil; message = nil; text = ""
        work = Task { [weak self] in
            do {
                let test = try await service.timedTest(request, consent: consent, seen: seen)
                guard let self, generation == token, !Task.isCancelled else { return }
                try? storage.repository?.rememberTimedTest(test)
                self.test = test
                answers = TimedChoiceAnswers(count: test.items.count)
                clock = TimedTestClock(started: .now, seconds: seconds)
                stage = .running; work = nil
            } catch {
                guard let self, generation == token, !Task.isCancelled else { return }
                message = Self.describe(error, fallback: "No usable test came back. Try again.")
                stage = .start; work = nil
            }
        }
    }

    /// Ends the test. Writing goes to AI feedback at once; this also runs when time runs out.
    func finish(storage: LearnerStorageController) {
        guard stage == .running, let test else { return }
        stage = .finished
        try? storage.repository?.recordLabActivity("timed." + kind.rawValue, id: UUID())   // runs once: finish needs a running test
        if kind == .writing { sendWriting(test, storage: storage) }
    }

    func sendWriting(_ test: TimedTest, storage: LearnerStorageController) {
        let request = LabFeedbackRequest.timedWriting(topic: test.topic, text: text, seconds: seconds, level: test.level)
        guard request.isValid, let service, !sending else { return }
        let consent = LabFeedbackConsent(shown: .current(mode: .writing, includesAudio: false))
        let token = UUID(); generation = token
        sending = true; message = nil
        work = Task { [weak self] in
            do {
                let result = try await service.feedback(for: request, consent: consent)
                guard let self, generation == token, !Task.isCancelled else { return }
                feedback = result; sending = false; work = nil
                let record = StoredLabFeedback(id: UUID(), createdAt: .now, mode: .writing, title: "Timed writing",
                                               transcript: request.transcript, feedback: result)
                try? storage.repository?.saveLabFeedback(record)
                NotificationCenter.default.post(name: .labFeedbackChanged, object: nil)
            } catch {
                guard let self, generation == token, !Task.isCancelled else { return }
                message = Self.describe(error, fallback: "The feedback could not be checked, so it was not shown.")
                sending = false; work = nil
            }
        }
    }

    func reset() { cancel(); stage = .start; test = nil; clock = nil; feedback = nil; message = nil; text = "" }

    /// Stops a request in flight. A running test keeps its clock.
    func cancel() {
        generation = UUID(); work?.cancel(); work = nil; sending = false
        if stage == .loading { stage = .start }
    }

    private static func describe(_ error: Error, fallback: String) -> String {
        if let error = error as? LabFeedbackError { return error == .invalidResponse ? fallback : ProviderSettingsModel.firstSentence(error.message) }
        return ProviderSettingsModel.notice(error)
    }
}

struct TimedTestView: View {
    var storage: LearnerStorageController
    let kind: TimedTestKind
    @State private var controller: TimedTestController
    @State private var level = "B1"
    @State private var setup = false
    @State private var privacy = false
    @Environment(\.scenePhase) private var scenePhase

    init(storage: LearnerStorageController, kind: TimedTestKind, service: LabFeedbackService? = nil) {
        self.storage = storage; self.kind = kind
        _controller = State(initialValue: TimedTestController(kind: kind, service: service ?? Self.localService(), seconds: Self.testSeconds))
    }

    private var seconds: Int? { Self.testSeconds }

    /// UI tests can shorten the clock with `SC_TIMED_SECONDS`; release builds always use the kind's time.
    private static var testSeconds: Int? {
        #if DEBUG
        return ProcessInfo.processInfo.environment["SC_TIMED_SECONDS"].flatMap(Int.init)
        #else
        return nil
        #endif
    }

    private static func localService() -> LabFeedbackService? {
        #if DEBUG
        if ProcessInfo.processInfo.environment["SC_TIMED_FIXTURE"] == "1" {
            return LabFeedbackService(provider: TimedTestFixtureProvider(), scope: try! ProviderScope(workspace: "synthetic"))
        }
        #endif
        return AIFeedbackController.localService()
    }

    var body: some View {
        SpeechLabPage(storage: storage, title: kind.title) {
            switch controller.stage {
            case .start, .loading: startSection
            case .running: if let test = controller.test, let clock = controller.clock { runningSection(test, clock) }
            case .finished: if let test = controller.test { finishedSection(test) }
            }
            if let message = controller.message { Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("timed.error") }
        }
        .aiSetupSheet(isPresented: $setup) {
            if controller.stage == .start, !controller.isAvailable {
                controller = TimedTestController(kind: kind, service: Self.localService(), seconds: seconds)
            }
        }
        .sheet(isPresented: $privacy) {
            AIFeedbackPrivacyView(disclosure: .current(mode: .writing, includesAudio: false), retention: ProviderVerification.bundled?.retentionDisclosure)
        }
        .onAppear { if controller.stage == .start { level = storage.feedbackLevel } }
        .onDisappear { controller.cancel() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active, controller.stage == .loading { controller.cancel() }
            if phase == .active, controller.stage == .running, controller.clock?.isOver(at: .now) == true { controller.finish(storage: storage) }
        }
        .task(id: controller.clock) {
            guard let clock = controller.clock, controller.stage == .running else { return }
            try? await Task.sleep(for: .seconds(max(0, clock.ends.timeIntervalSinceNow)))
            if !Task.isCancelled, controller.clock == clock { controller.finish(storage: storage) }
        }
    }

    // MARK: Start

    @ViewBuilder private var startSection: some View {
        Text(kind.subtitle).foregroundStyle(Kit.secondary)
        Picker("Rank", selection: $level) { ForEach(LevelGate.levels, id: \.self) { Text($0).tag($0) } }
            .accessibilityIdentifier("timed.level")
        Text(LabFeedbackDisclosure.current(mode: .writing, includesAudio: false).line)
            .font(.footnote).foregroundStyle(Kit.secondary).accessibilityIdentifier("timed.disclosure")
        Button("Cost and privacy") { privacy = true }.accessibilityIdentifier("timed.privacy")
        if controller.stage == .loading {
            ProgressView("Writing your test").accessibilityIdentifier("timed.loading")
            Button("Cancel") { controller.cancel() }.accessibilityIdentifier("timed.cancel")
        } else {
            Button("Start") {
                if controller.isAvailable { controller.start(level: level, storage: storage) } else { setup = true }
            }.buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("timed.start")
        }
    }

    // MARK: Running

    @ViewBuilder private func runningSection(_ test: TimedTest, _ clock: TimedTestClock) -> some View {
        TimelineView(.periodic(from: clock.started, by: 1)) { context in
            let left = clock.remaining(at: context.date)
            Label(TimedTestClock.label(left), systemImage: "timer").font(.title2.monospacedDigit().bold())
                .foregroundStyle(left <= 30 ? Kit.error : Kit.ink)
                .accessibilityLabel("\(left / 60) minutes \(left % 60) seconds left").accessibilityIdentifier("timed.clock")
        }
        switch test.kind {
        case .writing:
            KitCard { Text(test.topic).font(.headline).fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("timed.topic") }
            TextEditor(text: Binding(get: { controller.text }, set: { controller.text = String($0.prefix(LabFeedbackRequest.maximumScalars / 2)) }))
                .frame(minHeight: 220).padding(8).scrollContentBackground(.hidden)
                .background(Kit.surface, in: RoundedRectangle(cornerRadius: 12))
                .accessibilityLabel("Your writing").accessibilityIdentifier("timed.text")
                .dictation(Binding(get: { controller.text }, set: { controller.text = $0 }))
            Text("\(SpeechLabDictationChecker.tokens(controller.text, strict: false).count) words").font(.footnote).foregroundStyle(Kit.secondary)
            Button("Send now") { controller.finish(storage: storage) }.buttonStyle(KitPrimaryButtonStyle())
                .disabled(controller.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty).accessibilityIdentifier("timed.finish")
        case .reading, .analogies:
            if test.kind == .reading {
                KitCard { Text(test.passage).fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("timed.passage") }
            }
            ForEach(Array(test.items.enumerated()), id: \.offset) { index, item in choiceCard(index, item, review: false) }
            Button("Finish") { controller.finish(storage: storage) }.buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("timed.finish")
        }
    }

    private func choiceCard(_ index: Int, _ item: TimedChoice, review: Bool) -> some View {
        let pick = controller.answers.picks[index]
        return KitCard {
            Text("\(index + 1). \(item.prompt)").font(.headline).fixedSize(horizontal: false, vertical: true)
            ForEach(Array(item.options.enumerated()), id: \.offset) { option, text in
                Button { if !review { controller.answers.picks[index] = option } } label: {
                    HStack {
                        Image(systemName: symbol(option: option, pick: pick, answer: item.answer, review: review)).accessibilityHidden(true)
                        Text(text).multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }.frame(minHeight: 44).contentShape(Rectangle())
                }
                .buttonStyle(.plain).disabled(review)
                .accessibilityAddTraits(pick == option ? .isSelected : [])
                .accessibilityValue(review && option == item.answer ? "Correct answer" : "")
                .accessibilityIdentifier("timed.item.\(index).\(option)")
            }
        }
    }

    private func symbol(option: Int, pick: Int?, answer: Int, review: Bool) -> String {
        if review {
            if option == answer { return "checkmark.circle.fill" }
            if option == pick { return "xmark.circle.fill" }
            return "circle"
        }
        return option == pick ? "largecircle.fill.circle" : "circle"
    }

    // MARK: Finished

    @ViewBuilder private func finishedSection(_ test: TimedTest) -> some View {
        switch test.kind {
        case .writing:
            KitCard { Text(test.topic).font(.headline).fixedSize(horizontal: false, vertical: true) }
            if controller.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Time is up.").font(.title2.bold()).accessibilityIdentifier("timed.timeUp")
            } else {
                Text(controller.text).fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("timed.written")
            }
            if controller.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                EmptyView()
            } else if controller.sending {
                ProgressView("Getting feedback").accessibilityIdentifier("timed.sending")
            } else if let feedback = controller.feedback {
                AIFeedbackCard(feedback: feedback)
            } else {
                Button("Send again") { controller.sendWriting(test, storage: storage) }.buttonStyle(KitSecondaryButtonStyle())
                    .accessibilityIdentifier("timed.resend")
            }
        case .reading, .analogies:
            HeroCard(eyebrow: "Test complete", title: controller.answers.summary(test.items), detail: test.kind.title) { EmptyView() }
                .accessibilityIdentifier("timed.summary")
            ForEach(Array(test.items.enumerated()), id: \.offset) { index, item in choiceCard(index, item, review: true) }
        }
        Button("New test") { controller.reset() }.buttonStyle(KitPrimaryButtonStyle()).disabled(controller.sending)
            .accessibilityIdentifier("timed.new")
    }
}

#if DEBUG
/// Synthetic replies for UI tests (`SC_TIMED_FIXTURE=1`). Never used in release builds.
final class TimedTestFixtureProvider: SpeakingProvider {
    let verification: ProviderVerification? = ProviderVerification(workspace: "synthetic", asrModel: "qwen3-asr-flash", coachingModel: "qwen-flash",
        validUntil: .distantFuture, directNativePermissionVerified: true, quotaProtectionVerified: true,
        retentionDisclosure: "Synthetic test disclosure.", evidenceReference: "isolated-ui-test")

    func send(body: Data, scope: ProviderScope, stage: SpeakingRequestStage) async throws -> Data {
        try await Task.sleep(for: .milliseconds(300))
        let text = String(decoding: body, as: UTF8.self)
        let content: [String: Any]
        if text.contains("impromptu writing topics") {
            content = ["topic": "Describe a small habit that makes your mornings easier, and explain why it helps you."]
        } else if text.contains("timed reading tests") {
            let passage = Array(repeating: "Many people in the town ride bicycles to work because the roads are flat and the weather is mild most of the year.", count: 7).joined(separator: " ")
            let questions = (1...5).map { number -> [String: Any] in
                ["question": "Question \(number): why do many people ride bicycles?", "options": ["The roads are flat", "Cars are banned", "Buses are free", "It always rains"], "answer": 0]
            }
            content = ["passage": passage, "questions": questions]
        } else if text.contains("word analogy items") {
            let pairs = [("hot", "cold", "tall", "short"), ("finger", "hand", "toe", "foot"), ("pen", "writer", "brush", "painter"),
                         ("rain", "flood", "spark", "fire"), ("warm", "hot", "cool", "cold"), ("apple", "fruit", "carrot", "vegetable"),
                         ("bird", "nest", "bee", "hive"), ("read", "book", "drive", "car"), ("happy", "glad", "big", "large"),
                         ("day", "night", "up", "down")]
            content = ["items": pairs.map { ["first": $0.0, "second": $0.1, "third": $0.2, "options": [$0.3, "river", "window", "pencil"], "answer": 0] }]
        } else {
            content = ["summary": "Your answer is clear and on topic.", "strengths": ["You gave a reason."], "improvements": [],
                       "nextStep": "Add one example next time.", "speechAssessmentStatus": "not_assessed"]
        }
        let json = String(decoding: try JSONSerialization.data(withJSONObject: content), as: UTF8.self)
        return try JSONSerialization.data(withJSONObject: ["model": "qwen-flash", "choices": [
            ["index": 0, "finish_reason": "stop", "message": ["role": "assistant", "content": json]]]])
    }
}
#endif
