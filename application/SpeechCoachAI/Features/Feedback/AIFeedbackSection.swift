import SwiftUI
import Observation

@MainActor @Observable final class AIFeedbackController {
    private let service: LabFeedbackService?
    private var work: Task<Void, Never>?
    private var generation = UUID()
    private(set) var busy = false
    private(set) var result: LabFeedback?
    private(set) var message: String?
    var isAvailable: Bool { service?.isAvailable == true }

    init(service: LabFeedbackService?) { self.service = service }

    static func localService() -> LabFeedbackService? {
        guard let verification = ProviderVerification.bundled else { return nil }
        #if DEBUG
        if SpeakingEnvironment.fixtureID != nil { return nil }
        #endif
        let credentials = ProviderCredentialStore()
        guard let scope = try? credentials.configuredScope(), verification.permits(scope),
              (try? credentials.credential(scope: scope)?.isEmpty) == false else { return nil }
        return LabFeedbackService(provider: SpeakingProviderClient(verification: verification, credentials: credentials), scope: scope)
    }

    /// Called only by the explicit Get feedback action beside the current disclosure.
    func submit(_ request: LabFeedbackRequest) {
        guard isAvailable, let service, !busy else { return }
        let disclosure = LabFeedbackDisclosure.current(mode: request.mode, includesAudio: false)
        let consent = LabFeedbackConsent(shown: disclosure)
        let token = UUID(); generation = token
        busy = true; result = nil; message = nil
        work = Task { [weak self] in
            do {
                let feedback = try await service.feedback(for: request, consent: consent)
                guard let self, generation == token, !Task.isCancelled, isAvailable else { return }
                result = feedback; busy = false; work = nil
            } catch {
                guard let self, generation == token, !Task.isCancelled else { return }
                if let error = error as? LabFeedbackError { message = ProviderSettingsModel.firstSentence(error.message) }
                else { message = ProviderSettingsModel.notice(error) }
                busy = false; work = nil
            }
        }
    }
    func cancel(clear: Bool = false) {
        generation = UUID(); work?.cancel(); work = nil; busy = false
        if clear { result = nil; message = nil }
    }
}

struct AIFeedbackSection: View {
    var mode: LabFeedbackMode
    private let request: LabFeedbackRequest
    /// When set, a received result is saved to the learner's history under this title.
    private var storage: LearnerStorageController?
    private var title: String
    @State private var controller: AIFeedbackController
    @State private var privacy = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var setup = false

    init(mode: LabFeedbackMode, transcript: String, task: String? = nil, level: String? = nil, service: LabFeedbackService? = nil) {
        self.init(request: LabFeedbackRequest(mode: mode, transcript: transcript, task: task, level: level), service: service)
    }

    /// A prebuilt request (see `LabFeedbackRequests.swift`), with an optional history title and storage.
    init(request: LabFeedbackRequest, title: String = "", storage: LearnerStorageController? = nil, service: LabFeedbackService? = nil) {
        self.mode = request.mode; self.request = request; self.title = title; self.storage = storage
        _controller = State(initialValue: AIFeedbackController(service: service ?? AIFeedbackController.localService()))
    }
    var body: some View {
        Group {
            if controller.isAvailable {
                VStack(alignment: .leading, spacing: 16) {
                    Text("AI feedback").font(.headline)
                    Text(LabFeedbackDisclosure.current(mode: mode, includesAudio: false).line)
                        .font(.footnote).foregroundStyle(Kit.secondary).accessibilityIdentifier("ai.disclosure")
                    Button("Cost and privacy") { privacy = true }.accessibilityIdentifier("ai.privacy")
                    if controller.busy {
                        ProgressView("Getting feedback").accessibilityIdentifier("ai.loading")
                        Button("Cancel") { controller.cancel() }.accessibilityIdentifier("ai.cancel")
                    } else {
                        Button("Get feedback") { controller.submit(request) }.buttonStyle(KitPrimaryButtonStyle())
                            .disabled(!request.isValid).accessibilityIdentifier("ai.send")
                    }
                    if let result = controller.result { AIFeedbackCard(feedback: result) }
                    if let message = controller.message { Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("ai.error") }
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("AI feedback").font(.headline)
                    Button("Set up AI") { setup = true }.buttonStyle(KitSecondaryButtonStyle()).accessibilityIdentifier("ai.setup")
                }
            }
        }
        .aiSetupSheet(isPresented: $setup) {
            if !controller.isAvailable { controller = AIFeedbackController(service: AIFeedbackController.localService()) }
        }
        .sheet(isPresented: $privacy) {
            AIFeedbackPrivacyView(disclosure: .current(mode: mode, includesAudio: false),
                retention: ProviderVerification.bundled?.retentionDisclosure)
        }
        .onChange(of: request) { _, _ in controller.cancel(clear: true) }
        .onChange(of: controller.result) { _, feedback in save(feedback) }
        .onChange(of: controller.isAvailable) { _, available in if !available { controller.cancel(clear: true) } }
        .onDisappear { controller.cancel(clear: true) }
        .onChange(of: scenePhase) { _, phase in if phase != .active { controller.cancel(clear: true) } }
    }
}

extension AIFeedbackSection {
    private func save(_ feedback: LabFeedback?) {
        guard let feedback, let repository = storage?.repository else { return }
        let record = StoredLabFeedback(id: UUID(), createdAt: .now, mode: request.mode,
                                       title: title.isEmpty ? request.mode.historyTitle : title,
                                       transcript: request.transcript, feedback: feedback)
        try? repository.saveLabFeedback(record)
        NotificationCenter.default.post(name: .labFeedbackChanged, object: nil)
    }
}

extension LearnerStorageController {
    /// The learner's highest unlocked level, sent as context with feedback requests.
    var feedbackLevel: String { levelGate(install: CurriculumCatalogLoader.bundled).unlockedLevels.last ?? "A1" }
}

extension Notification.Name { static let labFeedbackChanged = Notification.Name("SpeechCoachAI.labFeedbackChanged") }

extension LabFeedbackMode {
    var historyTitle: String {
        switch self {
        case .pronunciation: "Pronunciation"
        case .speaking: "Speaking"
        case .interview: "Interview"
        case .conversation: "Conversation"
        case .communication: "Communication"
        case .coachReview: "Coach review"
        case .writing: "Timed writing"
        }
    }
}

struct AIFeedbackCard: View {
    let feedback: LabFeedback
    var body: some View {
        KitCard {
            Text(feedback.summary).font(.headline).fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("ai.summary")
            ForEach(Array(feedback.strengths.enumerated()), id: \.offset) { _, strength in Text(strength) }
            ForEach(Array(feedback.improvements.prefix(3).enumerated()), id: \.offset) { _, item in
                Divider()
                Text(item.quote).italic().fixedSize(horizontal: false, vertical: true)
                Text(item.tip).fixedSize(horizontal: false, vertical: true)
                Text(item.retry).font(.callout.weight(.semibold)).fixedSize(horizontal: false, vertical: true)
            }
            Divider()
            Text(feedback.nextStep).fixedSize(horizontal: false, vertical: true)
            if let line = Self.answeredBy(feedback) {
                Text(line).font(.caption).foregroundStyle(Kit.secondary).accessibilityIdentifier("ai.model")
            }
        }
    }

    /// Which model wrote this feedback (#10). Older saved feedback has no model and shows nothing.
    static func answeredBy(_ feedback: LabFeedback) -> String? { feedback.model.map { "Answered by \($0)" } }
}

struct AIFeedbackPrivacyView: View {
    var disclosure: LabFeedbackDisclosure
    var retention: String?
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(disclosure.line)
                    Text("Your provider account may be charged.")
                    if let retention { Text(retention) }
                }.padding(20).foregroundStyle(Kit.ink)
            }.navigationTitle("Cost and privacy").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}
