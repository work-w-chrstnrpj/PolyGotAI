import SwiftUI
import UIKit

/// Microphone button that dictates into a text field. Hidden when the device can't recognize speech on-device.
struct DictationButton: View {
    @Binding var text: String
    @State private var recognizer = DictationRecognizer()
    @State private var base = ""
    @State private var problem: Problem?
    private enum Problem: String, Identifiable { case denied, unavailable; var id: String { rawValue } }

    var body: some View {
        if DictationRecognizer.isSupported {
            Button {
                if !recognizer.isListening { base = text }
                Task {
                    await recognizer.toggle()
                    if recognizer.state == .denied { problem = .denied }
                    if recognizer.state == .unavailable { problem = .unavailable }
                }
            } label: {
                Image(systemName: recognizer.isListening ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.title)
                    .foregroundStyle(recognizer.isListening ? Kit.error : Kit.accent)
                    .symbolEffect(.pulse, isActive: recognizer.isListening)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(recognizer.isListening ? "Stop dictation" : "Dictate")
            .accessibilityIdentifier("dictation.button")
            .onChange(of: recognizer.transcript) { _, spoken in
                guard recognizer.isListening, !spoken.isEmpty else { return }
                text = Self.joined(base, spoken)
            }
            .onDisappear { recognizer.stop() }
            .alert(item: $problem) { problem in
                switch problem {
                case .denied:
                    Alert(title: Text("Dictation is off"),
                          message: Text("Allow Speech Recognition and Microphone in Settings."),
                          primaryButton: .default(Text("Open Settings")) {
                              if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                          }, secondaryButton: .cancel())
                case .unavailable:
                    Alert(title: Text("Dictation isn’t available right now"), message: Text("Try again, or type your answer."),
                          dismissButton: .cancel(Text("OK")))
                }
            }
        }
    }

    /// Existing text, one space, then what was spoken.
    static func joined(_ existing: String, _ spoken: String) -> String {
        let trimmed = existing.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? spoken : trimmed + " " + spoken
    }
}

extension View {
    /// Puts a dictation button beside a text field. Apply it last, after the field's own styling.
    func dictation(_ text: Binding<String>) -> some View {
        HStack(alignment: .center, spacing: 8) {
            self
            DictationButton(text: text)
        }
    }
}
