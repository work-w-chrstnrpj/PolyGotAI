import AVFAudio
import SwiftUI

struct JumpTestView: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    var target: String
    @State private var test: JumpTest?
    @State private var savedPass = false
    @State private var message: String?
    @State private var clip: AVAudioPlayer?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    init(storage: LearnerStorageController, install: CurriculumInstall, target: String) {
        self.storage = storage
        self.install = install
        self.target = target
        _test = State(initialValue: JumpTest.make(target: target, install: install))
    }

    var body: some View {
        Group {
            if let test, test.isFinished {
                result(test)
            } else if let test, let item = test.current {
                ExerciseActivityView(activity: item.activity, progress: test.progress,
                    positionText: "\(test.position + 1) of \(test.total)", isLast: test.position == test.total - 1,
                    message: message, onPlayClip: play,
                    onSubmit: { stored in
                        guard let response = item.spec.response(fromStored: stored) else { return false }
                        return self.test?.submit(response) != nil
                    }, onContinue: advance)
                    .id(item.id)
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("jumptest.question")
            }
        }
        .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
        .navigationTitle("\(target) test").navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onDisappear(perform: stopAudio)
        .onChange(of: scenePhase) { _, phase in if phase != .active { stopAudio() } }
    }

    private func result(_ test: JumpTest) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: savedPass ? "checkmark.circle.fill" : "arrow.clockwise.circle")
                    .font(.system(size: 56)).foregroundStyle(Kit.accent).accessibilityHidden(true)
                Text(test.isPerfect && !savedPass ? "\(test.correctCount) of \(test.total)." : test.resultLine)
                    .font(.title2.bold()).multilineTextAlignment(.center).accessibilityIdentifier("jumptest.result")
                if let message { Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("jumptest.error") }
                if test.isPerfect {
                    Button(savedPass ? "Done" : "Save again") { if savedPass { dismiss() } else { savePass() } }
                        .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("jumptest.done")
                } else {
                    Button("Retry") {
                        self.test = JumpTest.make(target: target, install: install)
                        message = nil
                    }.buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("jumptest.retry")
                }
            }.padding(24).frame(maxWidth: 640).frame(maxWidth: .infinity)
        }
    }

    private func advance() {
        stopAudio()
        message = nil
        test?.advance()
        if test?.isPerfect == true { savePass() }
    }

    private func savePass() {
        guard !savedPass, test?.isPerfect == true else { return }
        savedPass = storage.recordJumpTestPass(level: target)
        message = savedPass ? nil : "Couldn’t save your progress."
    }

    private func play(_ path: String) {
        stopAudio()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
            clip = try AVAudioPlayer(contentsOf: Bundle.main.bundleURL.appendingPathComponent(path))
            guard clip?.play() == true else { throw LearnerStorageError.unavailable }
        } catch { message = "Couldn’t play this recording." }
    }

    private func stopAudio() {
        SpeechSynthesizer.shared.stop()
        guard clip != nil else { return }
        clip?.stop(); clip = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
