import AVFAudio
import Foundation
import Testing
@testable import SpeechCoachAI

private final class LoopFixtureProvider: SpeakingProvider {
    let scope = try! ProviderScope(workspace: "synthetic-integration")
    var calls: [SpeakingRequestStage] = []
    var requestBodies: [Data] = []
    var error: SpeakingProviderError?
    var delay = false
    var verification: ProviderVerification? {
        ProviderVerification(workspace: scope.workspace, asrModel: "qwen3-asr-flash", coachingModel: "qwen-flash",
            validUntil: .now.addingTimeInterval(3600), directNativePermissionVerified: true, quotaProtectionVerified: true,
            retentionDisclosure: "Synthetic local test", evidenceReference: "fixture")
    }
    func send(body: Data, scope: ProviderScope, stage: SpeakingRequestStage) async throws -> Data {
        calls.append(stage); requestBodies.append(body)
        if delay { try await Task.sleep(for: .seconds(10)) }
        if let error { throw error }
        let content: String
        if stage == .transcription { content = "I am a synthetic learner." }
        else {
            content = String(decoding: try JSONSerialization.data(withJSONObject: ["summary": "A clear introduction.",
                "strengths": [], "improvements": [], "limitations": ["Synthetic fixture only."], "speechAssessmentStatus": "not_assessed"]), as: UTF8.self)
        }
        return try JSONSerialization.data(withJSONObject: ["model": stage == .transcription ? "qwen3-asr-flash" : "qwen-flash",
            "choices": [["index": 0, "finish_reason": "stop", "message": ["role": "assistant", "content": content]]]])
    }
}

struct SpeakingLoopIntegrationTests {
    private func newRoot() -> URL { FileManager.default.temporaryDirectory.appendingPathComponent("SC-group-\(UUID().uuidString)") }
    private func recorded(_ repository: LearnerRepository, root: URL, retryOf: UUID? = nil, context: PracticeSessionContext? = nil) throws -> AttemptSnapshot {
        let fileURL = root.appendingPathComponent("synthetic.wav")
        let format = try #require(AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16_000, channels: 1, interleaved: true))
        let buffer = try #require(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 16_000))
        buffer.frameLength = 16_000; buffer.int16ChannelData?[0].initialize(repeating: 0, count: 16_000)
        do { let file = try AVAudioFile(forWriting: fileURL, settings: format.settings, commonFormat: .pcmFormatInt16, interleaved: true); try file.write(from: buffer) }
        let attempt = try repository.createAttempt(prompt: RecordingController.prompt, retryOf: retryOf, context: context)
        return try repository.finalizeRecording(attemptID: attempt.id, data: Data(contentsOf: fileURL), durationMilliseconds: 1000,
            sampleRate: 16_000, channels: 1, bitsPerSample: 16, expectedVersion: attempt.version)
    }
    private func settle(_ controller: OnlinePracticeController) async throws {
        for _ in 0..<500 {
            if !controller.isBusy { return }
            try await Task.sleep(for: .milliseconds(10))
        }
        Issue.record("Fixture operation did not settle within five seconds.")
    }

    @Test(arguments: [(false, false), (true, false), (false, true), (true, true)])
    func integratedASRConfirmCoachingFinishRestartAndScopedTrash(keep: (Bool, Bool)) async throws {
        let root = newRoot(); defer { try? FileManager.default.removeItem(at: root) }
        let repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let recorded = try recorded(repository, root: root)
        let provider = LoopFixtureProvider()
        let online = OnlinePracticeController(provider: provider, scope: provider.scope)
        online.load(repository, attemptID: recorded.id)
        #expect(provider.calls.isEmpty, "Entering never submits.")
        online.submit(.transcription); online.submit(.transcription)
        try await settle(online)
        #expect(provider.calls.count == 1 && online.original?.text == "I am a synthetic learner.")
        online.editedText = "I am a synthetic student."
        online.confirm()
        #expect(provider.calls.count == 1)
        online.submit(.coaching); try await settle(online)
        #expect(provider.calls.count == 2 && online.currentFeedback?.speechAssessmentStatus == "not_assessed")
        let object = try #require(JSONSerialization.jsonObject(with: provider.requestBodies[1]) as? [String: Any])
        let messages = try #require(object["messages"] as? [[String: Any]])
        let userContent = try #require(messages.last?["content"] as? String)
        let quoted = try #require(JSONSerialization.jsonObject(with: Data(userContent.utf8)) as? [String: String])
        #expect(quoted["learnerText"] == "I am a synthetic student.")
        #expect(!String(decoding: provider.requestBodies[1], as: UTF8.self).contains("data:audio"))
        let fresh = try repository.attempt(recorded.id)
        let saved = try repository.saveSelection(fresh.id, keepAudio: keep.0, keepText: keep.1, expectedVersion: fresh.version)
        #expect(try repository.completedPracticeCount() == 1)
        _ = try repository.saveSelection(saved.id, keepAudio: keep.0, keepText: keep.1, expectedVersion: saved.version)
        #expect(try repository.completedPracticeCount() == 1)
        repository.close()
        let reopened = try LearnerRepository(root: root, protectedDataAvailable: { true }); defer { reopened.close() }
        let restored = try reopened.attempt(saved.id)
        #expect((restored.recording != nil) == keep.0)
        #expect(restored.transcripts.isEmpty == !keep.1)
        #expect(try reopened.history().count == ((keep.0 || keep.1) ? 1 : 0))
        if keep.0 || keep.1 {
            let deletions = try reopened.softDelete(restored.id, scope: .all, expectedVersion: restored.version)
            #expect(try reopened.history().isEmpty)
            #expect(try reopened.history(recentlyDeleted: true).count == 1)
            for deletion in deletions {
                let latest = try reopened.attempt(restored.id)
                try reopened.restore(deletion, expectedVersion: latest.version)
            }
            #expect(try reopened.history().count == 1 && reopened.completedPracticeCount() == 1)
            let latest = try reopened.attempt(restored.id)
            let purgeIDs = try reopened.softDelete(latest.id, scope: .all, expectedVersion: latest.version)
            for deletion in purgeIDs {
                let current = try reopened.attempt(restored.id)
                try reopened.purge(deletion, expectedVersion: current.version)
            }
            #expect(try reopened.history().isEmpty && reopened.history(recentlyDeleted: true).isEmpty)
            #expect(try reopened.completedPracticeCount() == 1)
        }
    }

    @Test func cancellationLateWaitingAndExplicitRetryPreserveLocalWork() async throws {
        let root = newRoot(); defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, protectedDataAvailable: { true }); defer { repo.close() }
        let take = try recorded(repo, root: root)
        let provider = LoopFixtureProvider(); provider.delay = true
        let online = OnlinePracticeController(provider: provider, scope: provider.scope)
        online.load(repo, attemptID: take.id); online.submit(.transcription)
        for _ in 0..<100 where provider.calls.isEmpty { try await Task.sleep(for: .milliseconds(10)) }
        online.cancel(); try await Task.sleep(for: .milliseconds(20))
        let cancelled = try repo.attempt(take.id)
        #expect(cancelled.requests.last?.status == .cancelled && cancelled.transcripts.isEmpty)
        #expect(cancelled.recording == take.recording && !online.isBusy)
        provider.delay = false; provider.error = .unknownOutcome
        online.submit(.transcription); try await settle(online)
        let unknown = try repo.attempt(take.id)
        #expect(unknown.requests.count == 2 && unknown.requests.last?.status == .unknownOutcome)
        #expect(provider.calls.count == 2 && unknown.requests[0].id != unknown.requests[1].id)
    }

    @Test func sameSessionRetriesCountOnceAndUnverifiedClientNeverReadsOrSendsAKey() async throws {
        let root = newRoot(); defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, protectedDataAvailable: { true }); defer { repo.close() }
        let context = PracticeSessionContext(defaults: LearnerPreferences())
        let first = try recorded(repo, root: root, context: context)
        _ = try repo.saveSelection(first.id, keepAudio: false, keepText: false, expectedVersion: first.version)
        let retry = try recorded(repo, root: root, retryOf: first.id, context: context)
        _ = try repo.saveSelection(retry.id, keepAudio: false, keepText: false, expectedVersion: retry.version)
        #expect(try repo.completedPracticeCount() == 1)
        let newSession = PracticeSessionContext(defaults: LearnerPreferences())
        let separate = try recorded(repo, root: root, context: newSession)
        _ = try repo.saveSelection(separate.id, keepAudio: false, keepText: false, expectedVersion: separate.version)
        #expect(try repo.completedPracticeCount() == 2, "A fresh session is a distinct self-review.")
        let isolated = ProviderCredentialStore(service: "SC-gate-fixture-\(UUID().uuidString)")
        let client = SpeakingProviderClient(verification: nil, credentials: isolated)
        do { _ = try await client.send(body: Data(), scope: ProviderScope(workspace: "no-live-fixture"), stage: .transcription); Issue.record("Unverified client permitted a request.") }
        catch SpeakingProviderError.verificationRequired { }
        #expect(try isolated.configuredScope() == nil)
    }
    @Test func transportConfigurationAndReviewEvidenceFailClosed() throws {
        let config = SpeakingProviderClient.configuration(for: .transcription)
        #expect(config.urlCache == nil && config.httpCookieStorage == nil && config.urlCredentialStorage == nil)
        #expect(config.httpShouldSetCookies == false && config.waitsForConnectivity == false)
        #expect(config.timeoutIntervalForResource == 60)
        #expect(SpeakingProviderClient.configuration(for: .coaching).timeoutIntervalForResource == 45)
        let scope = try ProviderScope(workspace: "synthetic-verification")
        let expired = ProviderVerification(workspace: scope.workspace, asrModel: "qwen3-asr-flash", coachingModel: "qwen-flash",
            validUntil: .distantPast, directNativePermissionVerified: true, quotaProtectionVerified: true,
            retentionDisclosure: "Fixture", evidenceReference: "Fixture")
        #expect(!expired.permits(scope))
        let wrongScope = ProviderVerification(workspace: "another-workspace", asrModel: "qwen3-asr-flash", coachingModel: "qwen-flash",
            validUntil: .distantFuture, directNativePermissionVerified: true, quotaProtectionVerified: true,
            retentionDisclosure: "Fixture", evidenceReference: "Fixture")
        #expect(!wrongScope.permits(scope))
        #expect(ProviderVerification.bundled == nil, "No unreviewed live-provider grant may ship in this build.")
    }

}
