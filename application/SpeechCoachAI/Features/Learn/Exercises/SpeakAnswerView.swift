import SwiftUI

/// Phase 12: a "say it" exercise is answered by voice. The on-device recogniser fills `heard`, which the lesson checks.
/// There is no text field, so the word has to be spoken.
struct SpeakAnswerView: View {
    @Binding var heard: String
    var locked: Bool
    /// Debug fixture runs answer with this text instead of the microphone.
    var fixtureAnswer: String?
    @State private var recognizer = DictationRecognizer()
    @State private var message: String?

    static var available: Bool { DictationRecognizer.isSupported || fixture }

    private static var fixture: Bool {
        #if DEBUG
        SpeakingEnvironment.fixtureID != nil
        #else
        false
        #endif
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: toggle) {
                Label(recognizer.isListening ? "Stop" : (heard.isEmpty ? "Say it" : "Again"),
                      systemImage: recognizer.isListening ? "stop.fill" : "mic.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(KitPrimaryButtonStyle())
            .accessibilityIdentifier("exercise.speak")
            if recognizer.isListening {
                Text("Listening…").font(.callout).foregroundStyle(Kit.secondary)
            }
            if !heard.isEmpty {
                Text("We heard: “\(heard)”").font(.title3).fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("exercise.heard")
            }
            if let message { Text(message).font(.callout).foregroundStyle(Kit.error) }
        }
        .onChange(of: recognizer.transcript) { _, spoken in
            if recognizer.isListening, !spoken.isEmpty { heard = spoken }
        }
        .onChange(of: locked) { _, isLocked in if isLocked { recognizer.stop() } }
        .onDisappear { recognizer.stop() }
    }

    private func toggle() {
        if Self.fixture { heard = fixtureAnswer ?? ""; return }
        if !recognizer.isListening { heard = ""; message = nil }
        Task {
            await recognizer.toggle()
            if recognizer.state == .denied { message = "Allow Speech Recognition and Microphone in Settings." }
            if recognizer.state == .unavailable { message = "Speech recognition isn’t available right now; try again." }
        }
    }
}
