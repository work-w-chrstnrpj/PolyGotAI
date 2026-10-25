import Foundation
import Testing
@testable import SpeechCoachAI

struct CoachingValidationTests {
    private func transcript() -> TranscriptSnapshot {
        TranscriptSnapshot(id: UUID(), revision: 2, kind: .learnerConfirmed, sourceTranscriptID: UUID(),
            text: "I lives in Manila. I am a developer.", createdAt: Date())
    }
    private func item() -> [String: Any] {
        ["category": "grammar", "evidenceQuote": "I lives in Manila.", "explanation": "With I, use live.",
         "suggestedRevision": "I live in Manila.", "hint": "Check the verb after I.", "retryPrompt": "Introduce yourself again."]
    }
    private func body(items: [[String: Any]] = []) -> [String: Any] {
        ["summary": "You shared a location and occupation.", "strengths": [], "improvements": items,
         "limitations": ["Pronunciation was not assessed."], "speechAssessmentStatus": "not_assessed"]
    }
    private func data(_ object: [String: Any]) throws -> Data { try JSONSerialization.data(withJSONObject: object) }

    @Test func zeroImprovementsAndGroundedFeedbackAreValid() throws {
        let confirmed = transcript()
        let clean = try ValidatedCoachingContent(response: data(body()), confirmed: confirmed)
        #expect(clean.improvements.isEmpty && clean.transcriptID == confirmed.id && clean.transcriptRevision == 2)
        let grounded = try ValidatedCoachingContent(response: data(body(items: [item()])), confirmed: confirmed)
        #expect(grounded.improvements.count == 1)
        #expect(grounded.transcriptChecksum == PrivateFileStore.checksum(Data(confirmed.text.utf8)))
    }

    @Test func missingExtraWrongTypeInvalidEnumAndMarkdownAreRejected() throws {
        var extra = body(); extra["score"] = 95
        #expect(throws: CoachingValidationError.self) { try ValidatedCoachingContent(response: data(extra), confirmed: transcript()) }
        var missing = body(); missing.removeValue(forKey: "strengths")
        #expect(throws: CoachingValidationError.self) { try ValidatedCoachingContent(response: data(missing), confirmed: transcript()) }
        var wrong = body(); wrong["summary"] = 123
        #expect(throws: CoachingValidationError.self) { try ValidatedCoachingContent(response: data(wrong), confirmed: transcript()) }
        var invalid = item(); invalid["category"] = "pronunciation"
        #expect(throws: CoachingValidationError.self) { try ValidatedCoachingContent(response: data(body(items: [invalid])), confirmed: transcript()) }
        #expect(throws: CoachingValidationError.self) { try ValidatedCoachingContent(response: Data("```json\n{}\n```".utf8), confirmed: transcript()) }
        var nestedExtra = item(); nestedExtra["confidence"] = 0.9
        #expect(throws: CoachingValidationError.self) { try ValidatedCoachingContent(response: data(body(items: [nestedExtra])), confirmed: transcript()) }
    }

    @Test func inventedEvidenceAndAssessedSpeechAreRejected() throws {
        var invented = item(); invented["evidenceQuote"] = "I am from London."
        #expect(throws: CoachingValidationError.ungroundedEvidence) { try ValidatedCoachingContent(response: data(body(items: [invented])), confirmed: transcript()) }
        var scored = body(); scored["speechAssessmentStatus"] = "assessed"
        #expect(throws: CoachingValidationError.self) { try ValidatedCoachingContent(response: data(scored), confirmed: transcript()) }
        var original = transcript(); original.kind = .asrOriginal
        #expect(throws: CoachingValidationError.unconfirmedTranscript) { try ValidatedCoachingContent(response: data(body()), confirmed: original) }
    }

    @Test func defaultCountAndHintsOnlyPreferenceAreEnforced() throws {
        let three = body(items: [item(), item(), item()])
        #expect(throws: CoachingValidationError.self) { try ValidatedCoachingContent(response: data(three), confirmed: transcript()) }
        #expect(try ValidatedCoachingContent(response: data(three), confirmed: transcript(), expanded: true).improvements.count == 3)
        #expect(throws: CoachingValidationError.invalidPreference) { try ValidatedCoachingContent(response: data(body(items: [item()])), confirmed: transcript(), hintsOnly: true) }
        var hint = item(); hint["suggestedRevision"] = NSNull()
        #expect(try ValidatedCoachingContent(response: data(body(items: [hint])), confirmed: transcript(), hintsOnly: true).improvements.count == 1)
        hint["hint"] = NSNull()
        #expect(throws: CoachingValidationError.invalidPreference) { try ValidatedCoachingContent(response: data(body(items: [hint])), confirmed: transcript(), hintsOnly: true) }
    }

    @Test func lengthLimitsRejectRatherThanTruncate() throws {
        var oversized = body(); oversized["summary"] = String(repeating: "x", count: 601)
        #expect(throws: CoachingValidationError.self) { try ValidatedCoachingContent(response: data(oversized), confirmed: transcript()) }
        var empty = body(); empty["summary"] = " \n "
        #expect(throws: CoachingValidationError.self) { try ValidatedCoachingContent(response: data(empty), confirmed: transcript()) }
    }
    @Test func repositoryCommitsOnlyMatchingConfirmedRevisionAndNeverDuplicatesResult() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, protectedDataAvailable: { true }); defer { repo.close() }
        let attempt = try repo.createAttempt(prompt: RecordingController.prompt)
        let original = TranscriptSnapshot(id: UUID(), revision: 1, kind: .asrOriginal,
            text: "I lives in Manila. I am a developer.", createdAt: Date())
        try repo.appendTranscript(original, token: repo.token(for: attempt.id))
        let before = try repo.attempt(attempt.id)
        let confirmed = try repo.confirmTranscript(attempt.id, sourceID: original.id, text: original.text, expectedVersion: before.version)
        let transcript = try #require(confirmed.transcripts.last)
        let prepared = try repo.prepareCoaching(attempt.id, transcriptID: transcript.id, expectedVersion: confirmed.version, model: "qwen-flash", region: "Singapore")
        let requestID = try #require(repo.attempt(attempt.id).requests.last?.id)
        let sent = try repo.transitionRequest(requestID, status: .sent, token: prepared)
        let validated = try ValidatedCoachingContent(response: data(body(items: [item()])), confirmed: transcript)
        let completed = try repo.completeCoaching(validated, requestID: requestID, rubricVersion: "synthetic-v1", token: sent)
        #expect(completed.feedback.count == 1 && completed.requests.last?.status == .succeeded)
        #expect(completed.feedback[0].speechAssessmentStatus == "not_assessed")
        #expect(throws: LearnerStorageError.staleVersion) { try repo.completeCoaching(validated, requestID: requestID, rubricVersion: "synthetic-v1", token: sent) }
        let edited = try repo.confirmTranscript(attempt.id, sourceID: transcript.id, text: "I live in Manila.", expectedVersion: completed.version)
        #expect(edited.feedback.first?.transcriptID == transcript.id)
        #expect(edited.transcripts.last?.id != transcript.id && edited.stage == .transcriptReview)
        #expect(edited.requests.count == 1, "Editing never automatically sends coaching.")
    }

}
