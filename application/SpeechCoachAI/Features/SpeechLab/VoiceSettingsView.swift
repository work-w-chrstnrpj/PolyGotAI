import SwiftUI

struct VoiceSettingsView: View {
    var storage: LearnerStorageController
    @State private var settings = VoiceSettings()
    @State private var message: String?
    @Environment(\.scenePhase) private var scene
    var body: some View {
        Form {
            Section {
                Picker("Voice", selection: $settings.voiceIdentifier) {
                    Text("Best installed").tag(nil as String?)
                    ForEach(VoiceSettings.installed, id: \.identifier) { voice in
                        Text("\(voice.name) · \(voice.language) · \(VoiceSettings.quality(voice))").tag(Optional(voice.identifier))
                    }
                }.accessibilityIdentifier("voice.choice")
                Button("Preview") { SpeechSynthesizer.shared.speak("Hello! Let's practice English together.") }.accessibilityIdentifier("voice.preview")
            } header: { Text("English voice") } footer: {
                Text("Download a Premium voice in Settings › Accessibility › Spoken Content › Voices.")
            }
            Section("Speaking rate") {
                Slider(value: $settings.rate, in: 0.6...1.4, step: 0.05) { Text("Rate") }
                    .accessibilityValue("\(Int(settings.safeRate * 100)) percent").accessibilityIdentifier("voice.rate")
                Text("\(Int(settings.safeRate * 100))%").monospacedDigit().accessibilityIdentifier("voice.rateValue")
            }
            if let message { Text(message).foregroundStyle(Kit.error) }
        }.scrollContentBackground(.hidden).background(Kit.canvas(storage.preferences.background))
            .navigationTitle("Voice").navigationBarTitleDisplayMode(.inline)
            .onAppear { settings = storage.preferences.voiceSettings ?? VoiceSettings(); SpeechSynthesizer.shared.settings = settings }
            .onChange(of: settings) { _, value in
                SpeechSynthesizer.shared.settings = value
                var preferences = storage.preferences; preferences.voiceSettings = value
                storage.savePreferences(preferences)
                message = storage.preferences.voiceSettings == value ? nil : "Couldn’t save your voice."
            }
            .onDisappear { SpeechSynthesizer.shared.stop() }
            .onChange(of: scene) { _, phase in if phase != .active { SpeechSynthesizer.shared.stop() } }
    }
}
