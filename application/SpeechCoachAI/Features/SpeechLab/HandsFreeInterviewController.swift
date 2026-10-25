import AVFAudio
import Observation

/// Owns the screen's audio lifetime. Captions and finished turns stay in memory only.
@MainActor @Observable
final class HandsFreeInterviewController: NSObject, AVSpeechSynthesizerDelegate {
    enum Phase { case setup, speaking, starting, listening, waiting, paused, thinking, summary }
    private(set) var phase = Phase.setup
    private(set) var interview: HandsFreeInterview?
    private(set) var caption = ""
    private(set) var message: String?
    private var recognition = DictationRecognizer()
    private let speaker = AVSpeechSynthesizer()
    private var utteranceID: ObjectIdentifier?
    private var generation = UUID()
    private var starting: Task<Void, Never>?
    private var detector: TurnDetector?
    private var fixturePromptEnd: Date?
    /// Online follow-ups (Phase 6c). Off unless the learner turns them on beside the disclosure line; any failure falls back to the scripted follow-up.
    private let aiService: LabFeedbackService?
    var aiFollowUps = false
    var aiAvailable: Bool { aiService?.isAvailable == true }
    private var thinking: Task<Void, Never>?
    private let fixture: Bool
    private let silentFixture: Bool
    var canResume: Bool { starting == nil }

    init(fixture: Bool = SpeechLabRecognizer.fixture, silentFixture: Bool = false, aiService: LabFeedbackService? = nil) {
        self.fixture = fixture
        self.silentFixture = silentFixture
        self.aiService = aiService
        super.init()
        speaker.delegate = self
    }

    func start(set: String, level: String, bank: [InterviewQuestionItem], now: Date = .now) {
        stopAudio()
        let questions = HandsFreeInterview.plan(set: set, level: level, bank: bank)
        guard !questions.isEmpty else { message = "Choose another question set."; return }
        interview = HandsFreeInterview(setID: set, questions: questions, now: now)
        message = nil
        presentPrompt(now: now)
    }

    func repeatQuestion(now: Date = .now) {
        guard phase != .setup, phase != .summary, let prompt = interview?.repeatPrompt() else { return }
        stopAudio(); caption = ""; detector = nil; message = nil
        speak(prompt, now: now)
    }

    func skip(now: Date = .now) {
        guard phase != .setup, phase != .summary else { return }
        stopAudio(); interview?.skip(now: now); presentPrompt(now: now)
    }

    func finish(now: Date = .now) {
        guard interview != nil, phase != .summary else { return }
        let text = caption
        let duration = detector.map { now.timeIntervalSince($0.startedAt) } ?? 0
        stopAudio()
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            interview?.record(transcript: text, duration: duration, end: .manual, now: now)
        }
        interview?.finish(now: now)
        caption = ""; detector = nil; message = nil; phase = .summary
    }

    func pause() {
        guard phase != .setup, phase != .summary else { return }
        stopAudio(); caption = ""; detector = nil; phase = .paused
    }

    func resume(now: Date = .now) {
        guard phase == .paused, canResume else { return }
        message = nil; presentPrompt(now: now)
    }

    func reset() {
        stopAudio(); interview = nil; caption = ""; detector = nil; message = nil; phase = .setup
    }

    func tick(now: Date = .now) {
        if fixture, phase == .speaking, let end = fixturePromptEnd, now >= end {
            fixturePromptEnd = nil; beginListening(now: now)
        }
        guard phase == .listening, var detector else { return }
        if fixture {
            if !silentFixture, now.timeIntervalSince(detector.startedAt) >= 1 {
                caption = "I enjoy learning English and meeting new people."
            }
        } else {
            caption = recognition.transcript
            if !recognition.isListening, caption.isEmpty {
                pause(); message = "Try the microphone again."; return
            }
        }
        detector.heard(words: SpeechLabDictationChecker.tokens(caption, strict: false).count, at: now)
        let signal = detector.tick(at: now)
        self.detector = detector
        switch signal {
        case .keepListening: break
        case .promptToSpeak:
            stopAudio(); speak("Take your time.", now: now)
        case .offerSkip:
            stopAudio(); phase = .waiting
        case .endTurn(let reason):
            let text = caption
            let duration = now.timeIntervalSince(detector.startedAt)
            stopAudio()
            interview?.record(transcript: text, duration: duration, end: reason, now: now)
            if !askOnline(level: level, now: now) { presentPrompt(now: now) }
        }
    }

    private var level = "A1"

    func start(set: String, level: String, bank: [InterviewQuestionItem], learnerLevel: String, now: Date = .now) {
        self.level = learnerLevel
        start(set: set, level: level, bank: bank, now: now)
    }

    /// After an answer to a core question, ask the online model for one follow-up. Returns false when nothing was started,
    /// so the caller speaks the scripted follow-up (or the next question) at once.
    private func askOnline(level: String, now: Date) -> Bool {
        guard aiFollowUps, let service = aiService, service.isAvailable, let interview, interview.inFollowUp,
              let latest = interview.latestAnswer else { return false }
        let request = InterviewFollowUpRequest(question: latest.question, answer: latest.answer, level: self.level)
        let consent = LabFeedbackConsent(shown: .current(mode: .interview, includesAudio: false))
        let token = generation
        phase = .thinking; caption = ""; detector = nil
        thinking = Task { [weak self] in
            let text = try? await service.followUp(for: request, consent: consent).text
            guard let self, generation == token, phase == .thinking, !Task.isCancelled else { return }
            if let text { self.interview?.setAIFollowUp(text) }
            thinking = nil
            presentPrompt(now: .now)
        }
        return true
    }

    private func presentPrompt(now: Date) {
        caption = ""; detector = nil; message = nil
        guard let prompt = interview?.prompt else { phase = .summary; return }
        speak(prompt, now: now)
    }

    private func speak(_ text: String, now: Date) {
        phase = .speaking
        if fixture { fixturePromptEnd = now.addingTimeInterval(0.3); return }
        let audio = AVAudioSession.sharedInstance()
        do {
            try audio.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try audio.setActive(true)
        } catch { phase = .paused; message = "Try the speaker again."; return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = SpeechSynthesizer.preferredVoice()
        utteranceID = ObjectIdentifier(utterance)
        speaker.speak(utterance)
    }

    private func beginListening(now: Date) {
        if detector == nil { detector = TurnDetector(startedAt: now) }
        if fixture { phase = .listening; return }
        guard starting == nil else { phase = .paused; return }
        let token = generation
        // Each turn owns its recognizer so a late result cannot overwrite the next caption.
        let recognizer = DictationRecognizer()
        recognition = recognizer
        phase = .starting
        starting = Task { [weak self] in
            guard let self else { return }
            await recognizer.start()
            starting = nil
            guard generation == token, recognition === recognizer, !Task.isCancelled else { recognizer.stop(); return }
            guard recognizer.isListening else {
                phase = .paused
                message = recognizer.state == .denied ? "Allow microphone and speech access in Settings." : "Try the microphone again."
                return
            }
            // Permission time is not part of an answer's duration.
            if detector?.wordCount == 0, detector?.prompts == 0 { detector = TurnDetector(startedAt: .now) }
            phase = .listening
        }
    }

    private func stopAudio() {
        generation = UUID(); utteranceID = nil; fixturePromptEnd = nil
        thinking?.cancel(); thinking = nil
        starting?.cancel()
        speaker.stopSpeaking(at: .immediate)
        if !fixture {
            recognition.stop()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor [weak self] in
            guard let self, utteranceID == id, phase == .speaking else { return }
            utteranceID = nil; beginListening(now: .now)
        }
    }
}
