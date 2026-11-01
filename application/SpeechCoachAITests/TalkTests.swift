import Foundation
import Testing
@testable import SpeechCoachAI

@MainActor struct TalkTests {
    @Test func sentencesRetainChunksAndNeverRepeat() {
        var buffer = SentenceBuffer()
        #expect(buffer.append("Hello").isEmpty)
        #expect(buffer.append(". How are") == ["Hello."])
        #expect(buffer.append(" you? ") == ["How are you?"])
        #expect(buffer.append("It costs 3.14 dollars.").isEmpty)
        #expect(buffer.finish() == ["It costs 3.14 dollars."])
        #expect(buffer.finish().isEmpty)
    }
    @Test func sseCommentsUsageAndTermination() throws {
        var parser = TalkSSEParser()
        #expect(try parser.line(": keepalive") == nil)
        #expect(try parser.line("data: {\"choices\":[{\"index\":0,\"delta\":{\"content\":\"Hi. \"}}]}") == nil)
        #expect(try parser.line("") == "Hi. ")
        _ = try parser.line("data: {\"choices\":[],\"usage\":{}}")
        #expect(try parser.line("") == nil)
        _ = try parser.line("data: [DONE]"); _ = try parser.line("")
        #expect(parser.done)
        #expect(try parser.line("data: bad") == nil)
    }
    @Test func malformedSSEFailsClosed() throws {
        var parser = TalkSSEParser()
        _ = try parser.line("data: {\"error\":{\"message\":\"private provider details\"}}")
        #expect(throws: (any Error).self) { try parser.line("") }
        var oversized = TalkSSEParser()
        #expect(throws: TalkError.invalidResponse) { try oversized.line("data: " + String(repeating: "x", count: 65537)) }
    }
    @Test func requestBoundsHistoryAndUsesStreaming() throws {
        let turns = (0..<20).map { TalkTurn(role: $0.isMultiple(of: 2) ? .user : .assistant, text: "Synthetic \($0)") }
        let data = try TalkRequest(mode: .interview, scenario: "", turns: turns).body()
        let body = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let messages = try #require(body["messages"] as? [[String: String]])
        #expect(body["stream"] as? Bool == true)
        #expect(messages.count == 9)
        #expect(messages[1]["content"] == "Synthetic 12")
        #expect(messages[0]["content"]?.contains("job interviewer") == true)
        #expect(throws: TalkError.invalidResponse) { try TalkRequest(mode: .freeTalk, scenario: "", turns: [], model: "other").body() }
    }
    @Test func statusAndVoiceValidation() {
        #expect(TalkError.status(401) == .unauthorized)
        #expect(TalkError.status(403) == .quota)
        #expect(TalkError.status(429) == .rateLimited)
        #expect(TalkError.status(200) == nil)
        #expect(VoiceSettings(rate: .nan).safeRate == 1)
        #expect(VoiceSettings(rate: 8).safeRate == 1.4)
    }
    @Test func oldPreferencesDecodeAndVoiceRoundTrips() throws {
        let data = Data(#"{"background":"creativeAcademy","appearance":"system","coach":"elephantTeacher","countdownEnabled":false}"#.utf8)
        var preferences = try JSONDecoder().decode(LearnerPreferences.self, from: data)
        #expect(preferences.voiceSettings == nil)
        preferences.voiceSettings = VoiceSettings(voiceIdentifier: "synthetic-voice", rate: 0.8)
        #expect(try JSONDecoder().decode(LearnerPreferences.self, from: JSONEncoder().encode(preferences)) == preferences)
    }
    @Test func spellingChecksOnceAndHasTenRankWords() throws {
        var round = SpellingRound(bank: LexiconBankLoader.bundled, rank: "C2", shuffle: false)
        #expect(round.words.count == 10)
        #expect(round.words.allSatisfy { $0.cefr == "C2" })
        let first = try #require(round.current)
        #expect(round.check(" \(first.lemma.uppercased()) ") == true)
        #expect(round.check(first.lemma) == nil)
        #expect(round.correct == 1)
        round.next()
        #expect(round.index == 1)
        #expect(round.checked == nil)
        #expect(SpellingRound.correction(first).contains(", "))
    }
    @Test func stopRejectsLateResponsesAndNeverRestartsCapture() async throws {
        let client = FakeTalkClient(), mic = FakeTalkMic(), speaker = FakeTalkSpeaker()
        let session = TalkSession(client: client, recognition: mic, speaker: speaker)
        session.handsFree = false; session.listen()
        await settle()
        #expect(session.state == .listening)
        session.send(); await settle()
        #expect(session.state == .thinking)
        client.receive?("Hello. "); #expect(session.state == .speaking)
        session.stop()
        client.receive?("Late private text."); client.finish()
        await settle()
        #expect(session.state == .idle)
        #expect(session.turns.last?.text == "Hello. ")
        #expect(mic.starts == 1)
        #expect(speaker.stopped)
    }
    @Test func streamAndSpeechMustBothFinishBeforeListening() async throws {
        let client = FakeTalkClient(), mic = FakeTalkMic(), speaker = FakeTalkSpeaker()
        let session = TalkSession(client: client, recognition: mic, speaker: speaker)
        session.listen(); await settle(); session.send(); await settle()
        client.receive?("First sentence. ")
        #expect(mic.starts == 1)
        speaker.onDrained?(); #expect(session.state == .thinking)
        client.receive?("Second sentence."); client.finish(); await settle()
        #expect(session.state == .speaking)
        #expect(speaker.sentences == ["First sentence.", "Second sentence."])
        #expect(mic.starts == 1)
        speaker.onDrained?(); await settle()
        #expect(session.state == .listening)
        #expect(mic.starts == 2)
        session.stop()
    }
    @Test func completedReplyRejectsLateTransportEvents() async {
        let client = FakeTalkClient(), mic = FakeTalkMic(), speaker = FakeTalkSpeaker()
        let session = TalkSession(client: client, recognition: mic, speaker: speaker)
        session.handsFree = false; session.listen(); await settle(); session.send(); await settle()
        client.receive?("Finished."); client.finish(); await settle(); speaker.onDrained?()
        let turns = session.turns
        client.receive?("Unexpected late text.")
        #expect(session.turns == turns)
        #expect(session.state == .idle)
        session.stop()
    }
    @Test func cancelledMicrophoneStartupCannotCancelANewerTurn() async throws {
        let mic = DelayedTalkMic()
        let session = TalkSession(client: FakeTalkClient(), recognition: mic, speaker: FakeTalkSpeaker())
        session.listen(); await settle(); session.stop()
        session.listen(); await settle()
        try #require(mic.pending.count == 2)
        mic.pending[1].resume(); await settle()
        #expect(session.state == .listening)
        mic.pending[0].resume(); await settle()
        #expect(session.state == .listening)
        #expect(mic.cancels == 1)
        session.stop()
    }
    @Test func quotaAndNetworkErrorsDoNotRetry() async {
        for failure in [TalkError.quota, .unauthorized, .offline] {
            let client = FakeTalkClient(), mic = FakeTalkMic(), speaker = FakeTalkSpeaker()
            let session = TalkSession(client: client, recognition: mic, speaker: speaker)
            session.listen(); await settle(); session.send(); await settle()
            client.finish(error: failure); await settle()
            #expect(session.state == .error)
            #expect(session.message == failure.message)
            #expect(client.calls == 1)
            #expect(mic.starts == 1)
            session.stop()
        }
    }
    @Test func silenceAndManualSendFinalizeRecognition() async {
        let client = FakeTalkClient(), mic = FakeTalkMic(), speaker = FakeTalkSpeaker()
        let session = TalkSession(client: client, recognition: mic, speaker: speaker)
        session.listen(); await settle()
        let now = Date(); session.tick(now: now); session.tick(now: now.addingTimeInterval(2))
        await settle()
        #expect(mic.finishes == 1)
        #expect(client.calls == 1)
        session.stop(); client.finish()
    }
    private func settle() async { for _ in 0..<20 { await Task.yield() } }
}

@MainActor private final class FakeTalkClient: TalkStreaming {
    var receive: (@MainActor (String) -> Void)?
    var pending: CheckedContinuation<Void, Error>?
    var calls = 0
    func stream(_ request: TalkRequest, receive: @escaping @MainActor (String) -> Void) async throws {
        calls += 1; self.receive = receive
        try await withCheckedThrowingContinuation { pending = $0 }
    }
    func finish(error: TalkError? = nil) {
        let continuation = pending; pending = nil
        if let error { continuation?.resume(throwing: error) } else { continuation?.resume() }
    }
}
@MainActor private final class FakeTalkMic: TalkRecognizing {
    var transcript = "Synthetic learner turn"
    var starts = 0, finishes = 0
    func start() async throws { starts += 1 }
    func finish() async throws -> String { finishes += 1; return transcript }
    func cancel() {}
}
@MainActor private final class FakeTalkSpeaker: TalkSpeaking {
    var onDrained: (() -> Void)?
    var onFirstAudio: (() -> Void)?
    var sentences: [String] = []
    var stopped = false
    func enqueue(_ text: String, settings: VoiceSettings) { sentences.append(text); onFirstAudio?() }
    func stop() { stopped = true }
}

@MainActor private final class DelayedTalkMic: TalkRecognizing {
    var transcript = "Synthetic learner turn"
    var pending: [CheckedContinuation<Void, Never>] = []
    var cancels = 0
    func start() async throws { await withCheckedContinuation { pending.append($0) } }
    func finish() async throws -> String { transcript }
    func cancel() { cancels += 1 }
}
