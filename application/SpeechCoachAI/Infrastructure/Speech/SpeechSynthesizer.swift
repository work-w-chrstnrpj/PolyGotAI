import AVFoundation
import Observation

/// On-device American English voice for model audio, dictation and pronunciation examples. Nothing leaves the device.
@MainActor @Observable
final class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechSynthesizer()

    private let synthesizer = AVSpeechSynthesizer()
    private(set) var isSpeaking = false
    var settings = VoiceSettings()
    private var utteranceID: ObjectIdentifier?
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
        utterance.voice = settings.voice
        let base = settings.speechRate
        utterance.rate = slow ? base * 0.7 : base
        utterance.pitchMultiplier = 1.0
        utteranceID = ObjectIdentifier(utterance)
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    /// IPA notation gives sound-chart cues a specified American English pronunciation.
    func speakPronunciation(_ text: String, ipa: String, slow: Bool = false) {
        guard !text.isEmpty, !ipa.isEmpty else { speak(text, slow: slow); return }
        stop(); prepareAudioSession()
        let attributed = NSAttributedString(string: text, attributes: [NSAttributedString.Key(AVSpeechSynthesisIPANotationAttribute): ipa])
        let utterance = AVSpeechUtterance(attributedString: attributed)
        utterance.voice = settings.voice
        utterance.rate = slow ? settings.speechRate * 0.7 : settings.speechRate
        utteranceID = ObjectIdentifier(utterance)
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        utteranceID = nil
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        isSpeaking = false
        SoundCenter.shared.release("speech")
    }

    /// Plays through the speaker even with the silent switch on, unless a recording session is already active.
    private func prepareAudioSession() {
        SoundCenter.shared.hold("speech")
        let session = AVAudioSession.sharedInstance()
        if session.category == .playAndRecord { return }
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in self.finish(id) }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in self.finish(id) }
    }

    private func finish(_ id: ObjectIdentifier) {
        guard utteranceID == id else { return }; utteranceID = nil
        isSpeaking = false
        SoundCenter.shared.release("speech")
        onFinish?()
    }
}
