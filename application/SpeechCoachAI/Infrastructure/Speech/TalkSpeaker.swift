import AVFoundation

@MainActor protocol TalkSpeaking: AnyObject {
    var onDrained: (() -> Void)? { get set }
    var onFirstAudio: (() -> Void)? { get set }
    func enqueue(_ text: String, settings: VoiceSettings)
    func stop()
}

@MainActor final class TalkSpeaker: NSObject, TalkSpeaking, AVSpeechSynthesizerDelegate {
    var onDrained: (() -> Void)?
    var onFirstAudio: (() -> Void)?
    private let speaker = AVSpeechSynthesizer()
    private var utterances: Set<ObjectIdentifier> = []
    private var started = false
    override init() { super.init(); speaker.delegate = self }
    func enqueue(_ text: String, settings: VoiceSettings) {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = settings.voice; utterance.rate = settings.speechRate
        utterances.insert(ObjectIdentifier(utterance)); speaker.speak(utterance)
    }
    func stop() {
        utterances.removeAll(); started = false; speaker.stopSpeaking(at: .immediate)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor [weak self] in
            guard let self, utterances.contains(id), !started else { return }
            started = true; onFirstAudio?()
        }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor [weak self] in
            guard let self, utterances.remove(id) != nil else { return }
            if utterances.isEmpty { started = false; onDrained?() }
        }
    }
}
