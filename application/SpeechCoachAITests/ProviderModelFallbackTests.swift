import AVFAudio
import Foundation
import Testing
@testable import SpeechCoachAI

/// #10: ranked free-quota models. Fake transport only: no network, no key, synthetic text.
@MainActor
struct ProviderModelFallbackTests {
    private static let coaching = ["qwen-flash", "qwen3.5-flash", "qwen-plus"]
    private static let asr = ["qwen3-asr-flash", "qwen-audio-3.0-asr-flash"]

    private final class RankedProvider: SpeakingProvider {
        let scope = try! ProviderScope(workspace: "synthetic-ranked")
        var verification: ProviderVerification?
        /// Models that answer with the free-quota error.
        var exhausted: Set<String> = []
        var error: SpeakingProviderError?
        var answerAs: String?
        var sentModels: [String] = []
        init() {
            verification = ProviderVerification(workspace: scope.workspace, asrModels: ProviderModelFallbackTests.asr,
                coachingModels: ProviderModelFallbackTests.coaching, validUntil: .now.addingTimeInterval(3600),
                directNativePermissionVerified: true, quotaProtectionVerified: true,
                retentionDisclosure: "Synthetic local test", evidenceReference: "fixture")
        }
        func send(body: Data, scope: ProviderScope, stage: SpeakingRequestStage) async throws -> Data {
            let object = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
            let model = try #require(object["model"] as? String)
            sentModels.append(model)
            if exhausted.contains(model) { throw SpeakingProviderError.freeQuotaExhausted }
            if let error { throw error }
            let content: String
            if stage == .transcription { content = "I am a synthetic learner." }
            else if object["messages"].flatMap({ ($0 as? [[String: Any]])?.first?["content"] as? String })?.contains("nextStep") == true {
                content = String(decoding: try JSONSerialization.data(withJSONObject: ["summary": "Clear.", "strengths": [],
                    "improvements": [], "nextStep": "Say it again.", "speechAssessmentStatus": "not_assessed"]), as: UTF8.self)
            } else {
                content = String(decoding: try JSONSerialization.data(withJSONObject: ["summary": "A clear introduction.",
                    "strengths": [], "improvements": [], "limitations": [], "speechAssessmentStatus": "not_assessed"]), as: UTF8.self)
            }
            return try JSONSerialization.data(withJSONObject: ["model": answerAs ?? model,
                "choices": [["index": 0, "finish_reason": "stop", "message": ["role": "assistant", "content": content]]]])
        }
    }

    private final class Clock { var now = Date(timeIntervalSince1970: 1_794_200_000) }

    private func ledger(_ clock: Clock = Clock()) -> FreeQuotaLedger {
        let defaults = UserDefaults(suiteName: "SC-ledger-\(UUID().uuidString)")!
        return FreeQuotaLedger(defaults: defaults, now: { clock.now })
    }

    private func labRequest() -> LabFeedbackRequest {
        LabFeedbackRequest(mode: .speaking, transcript: "I like my city.", task: "Talk about your city.", level: "A2")
    }
    private var consent: LabFeedbackConsent { LabFeedbackConsent(shown: .current(mode: .speaking, includesAudio: false)) }

    // MARK: AC1 — ranked lists from the verification file, and the gate accepts only those models

    @Test func verificationFileCarriesRankedListsAndTheOlderSingleModelForm() throws {
        let ranked = Data("""
        {"workspace":"demo","asrModels":["qwen3-asr-flash","fun-asr"],"coachingModels":["qwen-flash","qwen-plus"],
         "validUntil":"2099-01-01T00:00:00Z","directNativePermissionVerified":true,"quotaProtectionVerified":true,
         "retentionDisclosure":"x","evidenceReference":"y"}
        """.utf8)
        let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
        let verification = try decoder.decode(ProviderVerification.self, from: ranked)
        #expect(verification.models(for: .coaching) == ["qwen-flash", "qwen-plus"])
        #expect(verification.models(for: .transcription) == ["qwen3-asr-flash", "fun-asr"])
        #expect(verification.permits(try ProviderScope(workspace: "demo")))
        let single = Data("""
        {"workspace":"demo","asrModel":"qwen3-asr-flash","coachingModel":"qwen-flash",
         "validUntil":"2099-01-01T00:00:00Z","directNativePermissionVerified":true,"quotaProtectionVerified":true,
         "retentionDisclosure":"x","evidenceReference":"y"}
        """.utf8)
        #expect(try decoder.decode(ProviderVerification.self, from: single).models(for: .coaching) == ["qwen-flash"])
    }

    @Test func emptyOrMalformedListsDoNotPermitAnything() throws {
        let scope = try ProviderScope(workspace: "demo")
        func make(_ coaching: [String], _ asr: [String] = ["qwen3-asr-flash"]) -> ProviderVerification {
            ProviderVerification(workspace: "demo", asrModels: asr, coachingModels: coaching, validUntil: .distantFuture,
                directNativePermissionVerified: true, quotaProtectionVerified: true, retentionDisclosure: "x", evidenceReference: "y")
        }
        #expect(make(["qwen-flash", "qwen-plus"]).permits(scope))
        #expect(!make([]).permits(scope))
        #expect(!make(["qwen-flash"], []).permits(scope))
        #expect(!make(["Qwen Flash"]).permits(scope))
        #expect(!make(["qwen-flash", "qwen-flash"]).permits(scope))
    }

    @Test func clientGateAcceptsListedModelsAndRejectsOthersBeforeReadingAKey() async throws {
        let scope = try ProviderScope(workspace: "synthetic-gate")
        let verification = ProviderVerification(workspace: scope.workspace, asrModels: Self.asr, coachingModels: Self.coaching,
            validUntil: .distantFuture, directNativePermissionVerified: true, quotaProtectionVerified: true,
            retentionDisclosure: "x", evidenceReference: "y")
        let client = SpeakingProviderClient(verification: verification,
            credentials: ProviderCredentialStore(service: "SC-test-\(UUID().uuidString)"))
        func body(_ model: String) -> Data { try! JSONSerialization.data(withJSONObject: ["model": model, "stream": false]) }
        await #expect(throws: SpeakingProviderError.credentialMissing) { _ = try await client.send(body: body("qwen-plus"), scope: scope, stage: .coaching) }
        await #expect(throws: SpeakingProviderError.invalidResponse) { _ = try await client.send(body: body("qwen-max"), scope: scope, stage: .coaching) }
        await #expect(throws: SpeakingProviderError.invalidResponse) { _ = try await client.send(body: body("qwen-flash"), scope: scope, stage: .transcription) }
    }

    // MARK: AC2 — only the free-quota error moves the request to the next model

    @Test func freeTierOnlyReplyIsToldApartFromAKeyProblem() {
        func body(_ object: [String: Any]) -> Data { try! JSONSerialization.data(withJSONObject: object) }
        #expect(SpeakingProviderError.from(status: 403, body: body(["error": ["code": "AllocationQuota.FreeTierOnly", "message": "m"]])) == .freeQuotaExhausted)
        #expect(SpeakingProviderError.from(status: 403, body: body(["code": "AllocationQuota.FreeTierOnly"])) == .freeQuotaExhausted)
        #expect(SpeakingProviderError.from(status: 403, body: body(["error": ["code": "InvalidApiKey"]])) == .unauthorized)
        #expect(SpeakingProviderError.from(status: 403, body: Data("not json".utf8)) == .unauthorized)
        #expect(SpeakingProviderError.from(status: 401, body: body(["code": "AllocationQuota.FreeTierOnly"])) == .unauthorized)
        #expect(SpeakingProviderError.from(status: 402, body: Data()) == .quotaExhausted)
        #expect(SpeakingProviderError.from(status: 429, body: Data()) == .rateLimited)
        #expect(TalkError.from(status: 403, body: body(["error": ["code": "AllocationQuota.FreeTierOnly"]])) == .freeQuota)
        #expect(TalkError.from(status: 403, body: Data()) == .quota)
    }

    @Test func exhaustedModelHandsTheSameRequestToTheNextOne() async throws {
        let provider = RankedProvider(); provider.exhausted = ["qwen-flash"]
        let reply = try await provider.sendRouted(body: LabFeedbackRequest(mode: .speaking, transcript: "Hi there.").body(),
            scope: provider.scope, stage: .coaching, ledger: ledger())
        #expect(provider.sentModels == ["qwen-flash", "qwen3.5-flash"])
        #expect(reply.model == "qwen3.5-flash")
    }

    @Test(arguments: [SpeakingProviderError.unauthorized, .rateLimited, .offline, .quotaExhausted, .unknownOutcome])
    func otherErrorsStopAtTheFirstModel(_ error: SpeakingProviderError) async throws {
        let provider = RankedProvider(); provider.error = error
        await #expect(throws: error) {
            _ = try await provider.sendRouted(body: try self.labRequest().body(), scope: provider.scope, stage: .coaching, ledger: self.ledger())
        }
        #expect(provider.sentModels == ["qwen-flash"])
    }

    @Test func speechToTextUsesItsOwnList() async throws {
        let provider = RankedProvider(); provider.exhausted = ["qwen3-asr-flash"]
        let body = try JSONSerialization.data(withJSONObject: ["model": "qwen3-asr-flash", "stream": false])
        let reply = try await provider.sendRouted(body: body, scope: provider.scope, stage: .transcription, ledger: ledger())
        #expect(provider.sentModels == ["qwen3-asr-flash", "qwen-audio-3.0-asr-flash"])
        #expect(try ASRRecognition(response: reply.data, expectedModel: reply.model).text == "I am a synthetic learner.")
    }

    // MARK: AC3 — the end of the list stops for good

    @Test func whenEveryModelRunsOutTheLearnerGetsTheQuotaMessageAndNothingMoreIsSent() async throws {
        let provider = RankedProvider(); provider.exhausted = Set(Self.coaching)
        let book = ledger()
        await #expect(throws: SpeakingProviderError.quotaExhausted) {
            _ = try await provider.sendRouted(body: try self.labRequest().body(), scope: provider.scope, stage: .coaching, ledger: book)
        }
        #expect(provider.sentModels == Self.coaching)
        await #expect(throws: SpeakingProviderError.quotaExhausted) {
            _ = try await provider.sendRouted(body: try self.labRequest().body(), scope: provider.scope, stage: .coaching, ledger: book)
        }
        #expect(provider.sentModels.count == Self.coaching.count, "A spent list sends nothing more today.")
    }

    @Test func labFeedbackShowsTheQuotaMessageWhenTheListIsSpent() async throws {
        let provider = RankedProvider(); provider.exhausted = Set(Self.coaching)
        let service = LabFeedbackService(provider: provider, scope: provider.scope, ledger: ledger())
        await #expect(throws: SpeakingProviderError.quotaExhausted) { _ = try await service.feedback(for: self.labRequest(), consent: self.consent) }
    }

    // MARK: AC4 — a spent model is skipped for the rest of the day

    @Test func spentModelIsSkippedUntilTheNextLocalDay() async throws {
        let clock = Clock()
        let book = ledger(clock)
        let provider = RankedProvider(); provider.exhausted = ["qwen-flash"]
        _ = try await provider.sendRouted(body: try labRequest().body(), scope: provider.scope, stage: .coaching, ledger: book)
        provider.exhausted = []; provider.sentModels = []
        _ = try await provider.sendRouted(body: try labRequest().body(), scope: provider.scope, stage: .coaching, ledger: book)
        #expect(provider.sentModels == ["qwen3.5-flash"], "Later requests today skip the spent model.")
        clock.now = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: clock.now))!
        provider.sentModels = []
        _ = try await provider.sendRouted(body: try labRequest().body(), scope: provider.scope, stage: .coaching, ledger: book)
        #expect(provider.sentModels == ["qwen-flash"], "A new day tries the first model again.")
    }

    // MARK: AC5 — the answering model is checked and shown

    @Test func replyFromAnotherModelIsRejected() async throws {
        let provider = RankedProvider(); provider.exhausted = ["qwen-flash"]; provider.answerAs = "qwen-flash"
        let service = LabFeedbackService(provider: provider, scope: provider.scope, ledger: ledger())
        await #expect(throws: LabFeedbackError.invalidResponse) { _ = try await service.feedback(for: self.labRequest(), consent: self.consent) }
        #expect(provider.sentModels == ["qwen-flash", "qwen3.5-flash"], "Sent to qwen3.5-flash, so a reply naming another model is refused.")
    }

    @Test func labFeedbackRecordsTheModelThatAnswered() async throws {
        let provider = RankedProvider(); provider.exhausted = ["qwen-flash"]
        let service = LabFeedbackService(provider: provider, scope: provider.scope, ledger: ledger())
        let feedback = try await service.feedback(for: labRequest(), consent: consent)
        #expect(feedback.model == "qwen3.5-flash")
        #expect(AIFeedbackCard.answeredBy(feedback) == "Answered by qwen3.5-flash")
    }

    @Test func recordedCoachingKeepsOneRequestPerModelTriedAndShowsTheAnsweringModel() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-ranked-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = try LearnerRepository(root: root, protectedDataAvailable: { true }); defer { repository.close() }
        let fileURL = root.appendingPathComponent("synthetic.wav")
        let format = try #require(AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16_000, channels: 1, interleaved: true))
        let buffer = try #require(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 16_000))
        buffer.frameLength = 16_000; buffer.int16ChannelData?[0].initialize(repeating: 0, count: 16_000)
        do { let file = try AVAudioFile(forWriting: fileURL, settings: format.settings, commonFormat: .pcmFormatInt16, interleaved: true); try file.write(from: buffer) }
        let created = try repository.createAttempt(prompt: RecordingController.prompt)
        let take = try repository.finalizeRecording(attemptID: created.id, data: Data(contentsOf: fileURL), durationMilliseconds: 1000,
            sampleRate: 16_000, channels: 1, bitsPerSample: 16, expectedVersion: created.version)
        let provider = RankedProvider(); provider.exhausted = ["qwen3-asr-flash", "qwen-flash"]
        let online = OnlinePracticeController(provider: provider, scope: provider.scope, ledger: ledger())
        online.load(repository, attemptID: take.id)
        online.submit(.transcription)
        for _ in 0..<500 where online.isBusy { try await Task.sleep(for: .milliseconds(10)) }
        #expect(online.original?.text == "I am a synthetic learner.")
        online.editedText = "I am a synthetic student."; online.confirm()
        online.submit(.coaching)
        for _ in 0..<500 where online.isBusy { try await Task.sleep(for: .milliseconds(10)) }
        let attempt = try repository.attempt(take.id)
        #expect(attempt.requests.map(\.model) == ["qwen3-asr-flash", "qwen-audio-3.0-asr-flash", "qwen-flash", "qwen3.5-flash"])
        #expect(attempt.requests.map(\.status) == [.failed, .succeeded, .failed, .succeeded])
        #expect(online.currentFeedback?.model == "qwen3.5-flash")
        #expect(FeedbackContent.answeredBy(try #require(online.currentFeedback)) == "Answered by qwen3.5-flash")
    }
}
