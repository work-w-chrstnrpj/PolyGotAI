import AVFAudio
import SwiftUI

struct HandsFreeInterviewView: View {
    var storage: LearnerStorageController
    @State private var controller: HandsFreeInterviewController
    @State private var set = "general"
    @State private var level = "A1"
    @Environment(\.scenePhase) private var scenePhase
    private let bank = SpeechLabCatalog.bundled.interview

    init(storage: LearnerStorageController) {
        self.storage = storage
        #if DEBUG
        let silent = SpeakingEnvironment.fixtureID != nil && ProcessInfo.processInfo.environment["SC_INTERVIEW_SILENT_FIXTURE"] == "1"
        #else
        let silent = false
        #endif
        _controller = State(initialValue: HandsFreeInterviewController(silentFixture: silent))
    }

    var body: some View {
        SpeechLabPage(storage: storage, title: "Interview") {
            if controller.phase == .setup { setup }
            else if controller.phase == .summary { summary }
            else { conversation }
            if let message = controller.message {
                Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("interview.notice")
            }
        }
        .task {
            while !Task.isCancelled {
                do { try await Task.sleep(for: .milliseconds(250)) } catch { return }
                controller.tick()
            }
        }
        .onAppear {
            if controller.phase == .setup { level = storage.levelGate(install: CurriculumCatalogLoader.bundled).unlockedLevels.last ?? "A1" }
        }
        .onDisappear { controller.pause() }
        .onChange(of: scenePhase) { _, phase in if phase != .active { controller.pause() } }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { _ in controller.pause() }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)) { notification in
            if let raw = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
               AVAudioSession.RouteChangeReason(rawValue: raw) == .oldDeviceUnavailable { controller.pause() }
        }
    }

    private var setup: some View {
        Group {
            Text(SpeechLabRecognizer.supported ? "Answer aloud." : "Prepare an answer.").foregroundStyle(Kit.secondary)
            if SpeechLabRecognizer.supported {
                Picker("Question set", selection: $set) {
                    ForEach(["general", "job", "study"], id: \.self) { id in
                        Text(bank.first { $0.set == id }?.setTitle ?? id.capitalized).tag(id)
                    }
                }.pickerStyle(.menu).accessibilityIdentifier("interview.set")
                Picker("Level", selection: $level) {
                    ForEach(LevelGate.levels, id: \.self) { Text($0).tag($0) }
                }.pickerStyle(.menu).accessibilityIdentifier("interview.level")
                Button("Start") { controller.start(set: set, level: level, bank: bank) }
                    .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("interview.start")
            }
            NavigationLink("Written practice") {
                InterviewPracticeView(storage: storage, presenterID: storage.preferences.coach.rawValue)
            }.accessibilityIdentifier("interview.written")
        }
    }

    private var conversation: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(controller.interview?.progress ?? "").font(.headline).accessibilityIdentifier("interview.progress")
            Text(controller.interview?.prompt ?? "").font(.title2.bold())
                .fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("interview.prompt")
            Button {
                if controller.phase == .paused { controller.resume() } else { controller.pause() }
            } label: {
                ZStack {
                    Circle().fill(Kit.soft)
                    Image(systemName: controller.phase == .listening ? "mic.fill" : controller.phase == .speaking ? "waveform" : "pause.fill")
                        .font(.largeTitle).foregroundStyle(Kit.accent)
                }.frame(width: 120, height: 120).frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .disabled(controller.phase == .paused && !controller.canResume)
            .accessibilityLabel(controller.phase == .paused ? "Resume" : "Pause")
            .accessibilityValue(status)
            .accessibilityIdentifier("interview.orb")
            Text(status).font(.headline).accessibilityIdentifier("interview.status")
            if !controller.caption.isEmpty {
                KitCard {
                    Text("We heard").font(.headline)
                    Text(controller.caption).fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("interview.caption")
                }
            }
            ViewThatFits(in: .horizontal) {
                HStack { controls }
                VStack(alignment: .leading) { controls }
            }
        }
    }

    private var status: String {
        switch controller.phase {
        case .speaking: "Listen"
        case .starting: "Opening microphone"
        case .listening: "Your turn"
        case .waiting: "Repeat or skip"
        case .paused: "Paused"
        case .setup, .summary: ""
        }
    }

    @ViewBuilder private var controls: some View {
        Button("Repeat") { controller.repeatQuestion() }.buttonStyle(.bordered)
            .accessibilityIdentifier("interview.repeat")
        Button("Skip") { controller.skip() }.buttonStyle(.bordered)
            .accessibilityIdentifier("interview.skip")
        Button("Done") { controller.finish() }.buttonStyle(.bordered)
            .accessibilityIdentifier("interview.done")
    }

    private var summary: some View {
        Group {
            Text("Your interview").font(.title2.bold()).accessibilityIdentifier("interview.summary")
            if let summary = controller.interview?.summary {
                KitCard {
                    ForEach(Array(summary.lines.enumerated()), id: \.offset) { _, line in Text(line) }
                }.accessibilityIdentifier("interview.summary.lines")
            }
            Button("New interview") { controller.reset() }
                .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("interview.new")
        }
    }
}
