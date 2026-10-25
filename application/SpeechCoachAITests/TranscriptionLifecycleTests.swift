import Foundation
import Testing
@testable import SpeechCoachAI

struct TranscriptionLifecycleTests {
    private func fixture(text: String = "I am a fictional learner.", model: String = "qwen3-asr-flash", finish: String = "stop") throws -> Data {
        try JSONSerialization.data(withJSONObject: ["model": model,
            "choices": [["index": 0, "finish_reason": finish, "message": ["role": "assistant", "content": text]]]])
    }
    private func root() -> URL { FileManager.default.temporaryDirectory.appendingPathComponent("SC-T013-\(UUID().uuidString)") }
    private func repository(_ root: URL) throws -> LearnerRepository {
        try LearnerRepository(root: root, protectedDataAvailable: { true })
    }
    private func attempt(_ repository: LearnerRepository) throws -> AttemptSnapshot {
        let value = try repository.createAttempt(prompt: RecordingController.prompt)
        return try repository.finalizeRecording(attemptID: value.id, data: Data([1,2,3]),
            durationMilliseconds: 1000, sampleRate: 44_100, channels: 1, bitsPerSample: 16, expectedVersion: value.version)
    }
    private func request(_ repository: LearnerRepository, attempt: AttemptSnapshot) throws -> (UUID, CallbackToken) {
        let token = try repository.prepareTranscription(attempt.id, expectedVersion: attempt.version,
            model: "qwen3-asr-flash", region: "Singapore")
        let id = try #require(repository.attempt(attempt.id).requests.last?.id)
        return (id, token)
    }

    @Test func resultAndConfirmationRemainImmutableAndPersistWithoutAutomaticCoaching() throws {
        let root = root(); defer { try? FileManager.default.removeItem(at: root) }
        let repo = try repository(root); defer { repo.close() }
        let value = try attempt(repo)
        let (id, prepared) = try request(repo, attempt: value)
        let sent = try repo.transitionRequest(id, status: .sent, token: prepared)
        let recognition = try ASRRecognition(response: fixture(), expectedModel: "qwen3-asr-flash")
        #expect(recognition.confidence == nil)
        let completed = try repo.completeTranscription(recognition, requestID: id, token: sent)
        #expect(completed.requests.last?.status == .succeeded)
        let original = try #require(completed.transcripts.first)
        let confirmed = try repo.confirmTranscript(value.id, sourceID: original.id, text: "I am a fictional student.", expectedVersion: completed.version)
        #expect(confirmed.transcripts.first == original)
        #expect(confirmed.transcripts.last?.sourceTranscriptID == original.id)
        #expect(confirmed.transcripts.last?.kind == .learnerConfirmed)
        #expect(confirmed.requests.count == 1)
        let unchanged = try repo.confirmTranscript(value.id, sourceID: original.id, text: original.text, expectedVersion: confirmed.version)
        #expect(unchanged.transcripts.count == 3 && unchanged.transcripts.last?.revision == 3)
        repo.close()
        let reopened = try repository(root); defer { reopened.close() }
        #expect(try reopened.attempt(value.id).transcripts == unchanged.transcripts)
    }

    @Test func duplicateTapCancellationAndLateResultCannotDuplicateOrOverwriteWork() throws {
        let root = root(); defer { try? FileManager.default.removeItem(at: root) }
        let repo = try repository(root); defer { repo.close() }
        let value = try attempt(repo)
        let (id, prepared) = try request(repo, attempt: value)
        let latest = try repo.attempt(value.id)
        #expect(throws: LearnerStorageError.invalidState) {
            try repo.prepareTranscription(value.id, expectedVersion: latest.version, model: "qwen3-asr-flash", region: "Singapore")
        }
        let sent = try repo.transitionRequest(id, status: .sent, token: prepared)
        let cancelled = try repo.transitionRequest(id, status: .cancelled, token: sent)
        let result = try ASRRecognition(response: fixture(), expectedModel: "qwen3-asr-flash")
        #expect(throws: LearnerStorageError.staleVersion) { try repo.completeTranscription(result, requestID: id, token: sent) }
        #expect(throws: LearnerStorageError.invalidContent) { try repo.completeTranscription(result, requestID: id, token: cancelled) }
        let after = try repo.attempt(value.id)
        let (retryID, _) = try request(repo, attempt: after)
        #expect(retryID != id)
        #expect(try repo.attempt(value.id).transcripts.isEmpty)
        #expect(try repo.attempt(value.id).recording == value.recording)
    }

    @Test(arguments: [false, true])
    func restartNeverResubmitsUnsentOrSentRequests(_ sent: Bool) throws {
        let root = root(); defer { try? FileManager.default.removeItem(at: root) }
        let repo = try repository(root)
        let value = try attempt(repo)
        let (id, prepared) = try request(repo, attempt: value)
        if sent { _ = try repo.transitionRequest(id, status: .sent, token: prepared) }
        repo.close()
        let reopened = try repository(root); defer { reopened.close() }
        let recovered = try reopened.attempt(value.id)
        #expect(recovered.requests.count == 1)
        #expect(recovered.requests[0].status == (sent ? .unknownOutcome : .cancelled))
        #expect(recovered.stage == .recorded && recovered.transcripts.isEmpty)
    }

    @Test func responseValidationRejectsEmptyTruncatedOversizedAndWrongModel() throws {
        #expect(throws: ASRResponseError.emptyRecognition) {
            try ASRRecognition(response: fixture(text: " \n "), expectedModel: "qwen3-asr-flash")
        }
        #expect(throws: ASRResponseError.incomplete) {
            try ASRRecognition(response: fixture(finish: "length"), expectedModel: "qwen3-asr-flash")
        }
        #expect(throws: ASRResponseError.unsupportedModel) {
            try ASRRecognition(response: fixture(model: "unapproved-model"), expectedModel: "qwen3-asr-flash")
        }
        #expect(throws: ASRResponseError.malformed) {
            try ASRRecognition(response: Data("{broken".utf8), expectedModel: "qwen3-asr-flash")
        }
        #expect(throws: ASRResponseError.oversized) {
            try ASRRecognition(response: fixture(text: String(repeating: "x", count: 12_001)), expectedModel: "qwen3-asr-flash")
        }
    }

    @Test func failedCompletionCommitCanRetryAtomicallyWithTheSameToken() throws {
        let root = root(); defer { try? FileManager.default.removeItem(at: root) }
        let repo = try repository(root); defer { repo.close() }
        let value = try attempt(repo)
        let (id, prepared) = try request(repo, attempt: value)
        let sent = try repo.transitionRequest(id, status: .sent, token: prepared)
        let recognition = try ASRRecognition(response: fixture(), expectedModel: "qwen3-asr-flash")
        var commits = 0
        repo.beforeCommit = { commits += 1; if commits == 2 { throw LearnerStorageError.storageFailure } }
        #expect(throws: LearnerStorageError.storageFailure) { try repo.completeTranscription(recognition, requestID: id, token: sent) }
        repo.beforeCommit = nil
        let failed = try repo.attempt(value.id)
        #expect(failed.transcripts.isEmpty && failed.requests.last?.status == .sent)
        let completed = try repo.completeTranscription(recognition, requestID: id, token: sent)
        #expect(completed.transcripts.count == 1 && completed.requests.last?.status == .succeeded)
    }
}
