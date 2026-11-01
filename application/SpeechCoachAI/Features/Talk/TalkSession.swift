import Foundation
import Observation
import OSLog

@MainActor @Observable final class TalkSession {
    enum State: String { case idle, listening, thinking, speaking, error }
    private(set) var state = State.idle
    private(set) var turns: [TalkTurn] = []
    private(set) var caption = ""
    private(set) var message: String?
    private(set) var starting = false
    private(set) var firstTextLatency: TimeInterval?
    private(set) var firstAudioLatency: TimeInterval?
    var silence: TimeInterval = 1.2
    var handsFree = true
    var mode = TalkMode.freeTalk
    var scenario = "Order a meal at a restaurant. You are the server."
    var voice = VoiceSettings()
    private let client: any TalkStreaming
    private let recognition: any TalkRecognizing
    private let speaker: any TalkSpeaking
    private var work: Task<Void, Never>?
    private var generation = UUID()
    private var buffer = SentenceBuffer()
    private var streamEnded = false
    private var speaking = false
    private var endedAt: Date?
    private var lastChange = Date()
    private var listeningSince = Date()
    private var replyID: UUID?
    private static let logger = Logger(subsystem: "com.personal.SpeechCoachAI", category: "TalkLatency")

    init(client: any TalkStreaming, recognition: any TalkRecognizing = TalkRecognition(), speaker: any TalkSpeaking = TalkSpeaker()) {
        self.client = client; self.recognition = recognition; self.speaker = speaker
        speaker.onDrained = { [weak self] in self?.drained() }
        speaker.onFirstAudio = { [weak self] in
            guard let self, self.firstAudioLatency == nil, let endedAt = self.endedAt else { return }
            firstAudioLatency = max(0, Date().timeIntervalSince(endedAt))
            Self.logger.info("First audio: \(self.firstAudioLatency ?? 0, privacy: .public) seconds")
        }
    }
    var feedbackText: String { turns.map { "\($0.role == .user ? "Learner" : "Partner"): \($0.text)" }.joined(separator: "\n") }
    var busy: Bool { starting || state == .listening || state == .thinking || state == .speaking }

    func listen() {
        guard !busy else { return }
        generation = UUID()
        message = nil; starting = true; caption = ""
        let token = generation
        work = Task { [weak self] in
            guard let self else { return }
            do {
                try await recognition.start()
                guard generation == token, !Task.isCancelled else { return }
                starting = false; state = .listening; listeningSince = .now; lastChange = .now; work = nil
            } catch {
                guard generation == token, !Task.isCancelled else { return }
                recognition.cancel(); starting = false; state = .error; message = TalkError.recognition.message; work = nil
            }
        }
    }
    func tick(now: Date = .now) {
        guard state == .listening else { return }
        let text = recognition.transcript
        if text != caption { caption = text; lastChange = now }
        if (handsFree && !caption.isEmpty && now.timeIntervalSince(lastChange) >= min(3, max(0.6, silence))) || now.timeIntervalSince(listeningSince) >= 60 { send() }
    }
    func send() {
        guard state == .listening else { return }
        state = .thinking; endedAt = handsFree && !caption.isEmpty ? lastChange : .now
        let token = generation
        work = Task { [weak self] in
            guard let self else { return }
            do {
                let text = try await recognition.finish()
                guard generation == token, !Task.isCancelled else { return }
                if let speechEndedAt = recognition.speechEndedAt { endedAt = speechEndedAt }
                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { state = .idle; work = nil; return }
                guard text.count <= 6000, feedbackText.unicodeScalars.count + text.unicodeScalars.count < 10_000 else { throw TalkError.invalidResponse }
                caption = ""; turns.append(TalkTurn(role: .user, text: text))
                let request = TalkRequest(mode: mode, scenario: scenario, turns: turns)
                let reply = TalkTurn(role: .assistant, text: ""); replyID = reply.id; turns.append(reply)
                buffer = SentenceBuffer(); streamEnded = false; speaking = false; firstTextLatency = nil; firstAudioLatency = nil
                try await client.stream(request) { [weak self] delta in
                    guard let self, generation == token, !Task.isCancelled else { return }
                    receive(delta)
                }
                guard generation == token, !Task.isCancelled else { return }
                for sentence in buffer.finish() { speaking = true; state = .speaking; speaker.enqueue(sentence, settings: voice) }
                streamEnded = true
                if !speaking { completeReply() }
            } catch {
                guard generation == token, !Task.isCancelled else { return }
                speaker.stop(); speaking = false; recognition.cancel()
                state = .error; message = (error as? TalkError ?? .interrupted).message; work = nil
                removeEmptyReply()
            }
        }
    }
    private func receive(_ delta: String) {
        guard let id = replyID, let index = turns.firstIndex(where: { $0.id == id }) else { return }
        guard turns[index].text.count + delta.count <= 6000,
              feedbackText.unicodeScalars.count + delta.unicodeScalars.count <= LabFeedbackRequest.maximumScalars else { stop(); state = .error; message = TalkError.invalidResponse.message; return }
        if firstTextLatency == nil, let endedAt {
            firstTextLatency = max(0, Date().timeIntervalSince(endedAt))
            Self.logger.info("First text: \(self.firstTextLatency ?? 0, privacy: .public) seconds")
        }
        turns[index].text += delta
        for sentence in buffer.append(delta) { speaking = true; state = .speaking; speaker.enqueue(sentence, settings: voice) }
    }
    private func drained() {
        guard state == .speaking || state == .thinking else { return }
        speaking = false
        if streamEnded { completeReply() } else { state = .thinking }
    }
    private func completeReply() {
        guard let id = replyID, let reply = turns.first(where: { $0.id == id }), !reply.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            work = nil; removeEmptyReply(); state = .error; message = TalkError.invalidResponse.message; return
        }
        generation = UUID(); replyID = nil
        work = nil; state = .idle
        if handsFree { listen() }
    }
    func stop() {
        generation = UUID(); work?.cancel(); work = nil; starting = false
        recognition.cancel(); speaker.stop(); speaking = false; streamEnded = false; replyID = nil
        caption = ""; message = nil; state = .idle; removeEmptyReply()
    }
    func clear() { stop(); turns = []; firstTextLatency = nil; firstAudioLatency = nil }
    private func removeEmptyReply() { turns.removeAll { $0.role == .assistant && $0.text.isEmpty } }
}
