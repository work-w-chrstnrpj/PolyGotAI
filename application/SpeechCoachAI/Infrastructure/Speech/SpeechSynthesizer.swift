import AVFoundation
import Observation

/// On-device American English voice for model audio, dictation and pronunciation examples. Nothing leaves the device.
@MainActor @Observable
final class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechSynthesizer()

    private let synthesizer = AVSpeechSynthesizer()
    private(set) var isSpeaking = false
    /// Called when the current utterance ends or is stopped.
    var onFinish: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// The best installed en-US voice (premium, then enhanced, then default).
    static func preferredVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "en-US" }
        return voices.max { $0.quality.rawValue < $1.quality.rawValue } ?? AVSpeechSynthesisVoice(language: "en-US")
    }

    /// Speaks `text`. Slow speed is about 70% of the default rate, for dictation and articulation models.
    func speak(_ text: String, slow: Bool = false) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        stop()
        prepareAudioSession()
        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.voice = Self.preferredVoice()
        let base = AVSpeechUtteranceDefaultSpeechRate
        utterance.rate = slow ? base * 0.7 : base
        utterance.pitchMultiplier = 1.0
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        isSpeaking = false
    }

    /// Plays through the speaker even with the silent switch on, unless a recording session is already active.
    private func prepareAudioSession() {
        let session = AVAudioSession.sharedInstance()
        if session.category == .playAndRecord { return }
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.finish() }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.finish() }
    }

    private func finish() {
        isSpeaking = false
        onFinish?()
    }
}
