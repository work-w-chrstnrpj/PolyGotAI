import Foundation
import Testing
@testable import SpeechCoachAI

struct CommunicationDeliveryTests {
    @Test func unreviewedItemsStayUnavailable() throws {
        let reviewed = sampleItem(status: "reviewed")
        let candidate = sampleItem(id: "comm-draft", status: "unreviewed-candidate")
        #expect(CommunicationItem.published([reviewed, candidate]).map(\.id) == ["comm-clear-1"])
        var hidden = practice()
        hidden.draftTask.itemID = candidate.id
        hidden.draftTask.itemVersion = candidate.version
        #expect(hidden.begin(published: [reviewed, candidate], now: clock(1)).accepted == false)
        var shown = practice()
        shown.draftTask.itemID = reviewed.id
        shown.draftTask.itemVersion = reviewed.version
        #expect(shown.begin(published: [reviewed, candidate], now: clock(1)).accepted)
        #expect(shown.activeAttempt?.task.source?.objectiveID == "GREET-01")
        #expect(shown.activeAttempt?.task.source?.contentVersion == "3")
        #expect(shown.affectsCourseProgress == false)
    }

    @Test func transcriptSoundStaysUnassessed() throws {
        var session = try started()
        #expect(CommunicationPractice.preciseSoundFeedbackAvailable() == false)
        #expect(session.requestSoundFeedback().refusal == .capabilityUnavailable)
        if case .notAssessed = SoundAssessment.fromTranscript("I moved the meeting.") {
            #expect(Bool(true))
        } else {
            Issue.record("A transcript was treated as sound evidence")
        }
        #expect(try submit(&session, "I moved the meeting to Thursday.", at: 2))
        session.feedbackPolicy = .textOnlyEnabled(contractVersion: "recorded-feedback-v1")
        let request = try #require(session.requestTextFeedback(now: clock(3)).value)
        #expect(request.sendsAudio == false)
        let response = try #require(session.activeAttempt?.currentResponse?.id)
        let bad = textFeedback(request: request.requestID, response: response, summary: "Your confidence score is high.")
        #expect(session.receiveTextFeedback(bad, now: clock(4)).accepted == false)
        #expect(session.activeAttempt?.feedback == nil)
        #expect(session.saveSelfReview(
            purposeClear: true, organization: "Point then day.", wordUse: "Thursday is specific.",
            delivery: "I paused.", eyeContact: "I looked up.", now: clock(5)).accepted)
        #expect(session.activeAttempt?.review.soundAssessed == false)
    }

    @Test func zeroCorrectionsAreValidAndAThirdIsNot() throws {
        var session = try enabled()
        #expect(try submit(&session, "The meeting moved to Thursday.", at: 2))
        let request = try #require(session.requestTextFeedback(now: clock(3)).value)
        let response = try #require(session.activeAttempt?.currentResponse?.id)
        let none = textFeedback(
            request: request.requestID, response: response,
            summary: "The purpose and the day are both clear.", strengths: [])
        #expect(session.receiveTextFeedback(none, now: clock(4)).accepted)
        #expect(session.activeAttempt?.feedback?.improvements.isEmpty == true)
        var extra = none
        extra.requestID = UUID()
        extra.improvements = [
            improvement("The meeting"), improvement("moved"), improvement("Thursday")
        ]
        #expect(CommunicationPractice.validate(extra, learnerText: "The meeting moved to Thursday.", source: nil) == nil)
        let ungrounded = textFeedback(
            request: UUID(), response: response, summary: "A detail is missing.",
            improvements: [improvement("Friday")])
        #expect(CommunicationPractice.validate(ungrounded, learnerText: "The meeting moved to Thursday.", source: nil) == nil)
    }

    @Test func bothEntriesShareOneCreditAndOptionalWorkDoesNotFinishTheCourse() throws {
        var session = try started()
        let key = session.participationKey
        #expect(try submit(&session, "I moved the meeting.", at: 2))
        let credit = session.activeAttempt?.creditID
        let attempt = session.activeAttemptID
        #expect(session.setEntry(.speechLab).accepted)
        #expect(session.entry == .speechLab)
        #expect(session.activeAttemptID == attempt)
        #expect(session.activeAttempt?.creditID == credit)
        #expect(session.participationKey == key)
        #expect(session.activeAttempt?.courseCompletionID == nil)
        #expect(session.completeRoutine([.paraphrase], now: clock(3)).accepted)
        let routine = session.activeAttempt?.routineParticipationID
        #expect(session.completeRoutine([.paraphrase, .pausePractice], now: clock(4)).accepted)
        #expect(session.activeAttempt?.routineParticipationID == routine)
        #expect(session.activeAttempt?.masteryAwarded == false)
        #expect(session.completeRoutine([], now: clock(5)).accepted == false)
    }

    @Test func retryKeepsOneCreditAndAFrameworkIsOptional() throws {
        var session = try started()
        #expect(try submit(&session, "The meeting moved.", at: 2))
        let first = try #require(session.activeAttempt?.currentResponse?.id)
        let credit = session.activeAttempt?.creditID
        #expect(session.submit(questionID: "response", text: "Again.", now: clock(3)).accepted == false)
        #expect(session.retry(previousID: first, questionID: "response", text: "The meeting moved to Thursday.", now: clock(4)).accepted)
        #expect(session.activeAttempt?.creditID == credit)
        #expect(session.activeAttempt?.responses.count == 2)
        #expect(session.activeAttempt?.currentResponse?.retryOf == first)
        #expect(session.activeAttempt?.currentResponse?.assisted == false)
        #expect(session.saveSelfReview(
            purposeClear: true, organization: "Point then detail.", wordUse: "Thursday.",
            delivery: "", eyeContact: "", now: clock(5)).accepted)
        #expect(session.activeAttempt?.qualifies() == true)
    }

    @Test func recordingResultsAreOneUseAndAReferenceIsNotSoundEvidence() throws {
        var session = try started()
        #expect(session.openRecordingSlot(questionID: "response").accepted)
        let slot = try #require(session.activeRecordingSlot?.id)
        #expect(session.receiveRecording(turnID: UUID(), reference: "late").accepted == false)
        #expect(session.receiveRecording(turnID: slot, reference: "  ").accepted == false)
        #expect(session.receiveRecording(turnID: slot, reference: "private/take-1").accepted)
        #expect(session.receiveRecording(turnID: slot, reference: "private/take-2").accepted == false)
        #expect(try submit(&session, "I moved the meeting.", at: 2))
        #expect(session.activeAttempt?.currentResponse?.recordingReference == "private/take-1")
        #expect(session.activeAttempt?.currentResponse?.modality == .recorded)
        #expect(session.requestSoundFeedback().refusal == .capabilityUnavailable)
        session.feedbackPolicy = .textOnlyEnabled(contractVersion: "recorded-feedback-v1")
        #expect(try #require(session.requestTextFeedback(now: clock(3)).value).sendsAudio == false)
    }

    @Test func discardClearsTextWithoutRestoringItFromAudio() throws {
        var session = try started()
        #expect(session.openRecordingSlot(questionID: "response").accepted)
        let slot = try #require(session.activeRecordingSlot?.id)
        #expect(session.receiveRecording(turnID: slot, reference: "private/take-1").accepted)
        #expect(try submit(&session, "I moved the meeting.", at: 2))
        #expect(session.saveSelfReview(
            purposeClear: true, organization: "Point first.", wordUse: "Meeting.",
            delivery: "I paused.", eyeContact: "I looked up.", now: clock(3)).accepted)
        #expect(session.stop(now: clock(4)).accepted)
        #expect(session.applyRetention(keepAudio: true, keepText: false).accepted)
        #expect(session.activeAttempt?.currentResponse?.text == nil)
        #expect(session.activeAttempt?.currentResponse?.recordingReference == "private/take-1")
        #expect(session.activeAttempt?.review.organizationNote.isEmpty == true)
        #expect(session.activeAttempt?.review.eyeContactNote.isEmpty == true)
        #expect(session.saveSelfReview(
            purposeClear: true, organization: "Restored.", wordUse: "Restored.",
            delivery: "", eyeContact: "", now: clock(5)).accepted == false)
        #expect(session.activeAttempt?.currentResponse?.text == nil)
    }

    @Test func keepingTextDoesNotRestoreADeclinedRecording() throws {
        var session = try started()
        #expect(session.openRecordingSlot(questionID: "response").accepted)
        let slot = try #require(session.activeRecordingSlot?.id)
        #expect(session.receiveRecording(turnID: slot, reference: "private/take-1").accepted)
        #expect(try submit(&session, "I moved the meeting.", at: 2))
        #expect(session.stop(now: clock(3)).accepted)
        #expect(session.applyRetention(keepAudio: false, keepText: true).accepted)
        #expect(session.activeAttempt?.currentResponse?.text == "I moved the meeting.")
        #expect(session.activeAttempt?.currentResponse?.recordingReference == nil)
        #expect(session.receiveRecording(turnID: slot, reference: "private/take-1").accepted == false)
    }

    @Test func aTaskChangeClosesTheRequestAndAFailedChangeKeepsTheWork() throws {
        var session = try enabled()
        #expect(try submit(&session, "I moved the meeting.", at: 2))
        let request = try #require(session.requestTextFeedback(now: clock(3)).value)
        var same = try #require(session.activeAttempt?.task)
        #expect(session.reviseTask(same, published: [], now: clock(4)).accepted)
        #expect(session.activeAttempt?.inFlightRequestID == request.requestID)
        var blank = same
        blank.purpose = " "
        #expect(session.reviseTask(blank, published: [], now: clock(5)).accepted == false)
        #expect(session.activeAttempt?.currentResponse?.text == "I moved the meeting.")
        #expect(session.activeAttempt?.inFlightRequestID == request.requestID)
        same.purpose = "Explain the new day and the reason."
        let previous = session.activeAttemptID
        #expect(session.reviseTask(same, published: [], now: clock(6)).accepted)
        #expect(session.activeAttemptID != previous)
        #expect(session.activeAttempt?.inFlightRequestID == nil)
        #expect(session.attempts.first?.closedRequests.map(\.reason) == [.cancelled])
        let stale = textFeedback(request: request.requestID, response: request.responseID, summary: "Clear.")
        #expect(session.receiveTextFeedback(stale, now: clock(7)).accepted == false)
        #expect(session.activeAttempt?.feedback == nil)
        #expect(session.attempts.first?.responses.first?.text == "I moved the meeting.")
    }

    @Test func restartDoesNotResend() throws {
        var session = try enabled()
        #expect(try submit(&session, "I moved the meeting.", at: 2))
        _ = try #require(session.requestTextFeedback(now: clock(3)).value)
        #expect(session.stop(now: clock(4)).accepted)
        #expect(session.activeAttempt?.inFlightRequestID == nil)
        #expect(session.activeAttempt?.closedRequests.map(\.reason) == [.cancelled])
        #expect(session.restart().accepted)
        #expect(session.activeAttempt?.inFlightRequestID == nil)
        #expect(session.activeAttempt?.currentResponse?.text == "I moved the meeting.")
    }

    @Test func listeningNeedsASourceAndAScaffoldStaysAssisted() throws {
        var listening = practice(focus: .listenAndRespond, purpose: "Restate the update.")
        #expect(listening.begin(published: [], now: clock(1)).accepted)
        #expect(listening.submit(questionID: "response", text: "The meeting moved.", now: clock(2)).accepted == false)
        var sourced = try #require(listening.activeAttempt?.task)
        sourced.sourceExchange = "The Thursday meeting is now at ten."
        #expect(listening.reviseTask(sourced, published: [], now: clock(3)).accepted)
        #expect(listening.activeAttemptID != nil)
        #expect(try submit(&listening, "The meeting moved to ten.", at: 4))
        #expect(listening.saveSelfReview(
            purposeClear: true, organization: "I kept the time.", wordUse: "Ten.",
            delivery: "", eyeContact: "", now: clock(5)).accepted)
        #expect(listening.activeAttempt?.qualifies() == true)

        var helped = practice()
        helped.draftTask.scaffold = "Start with the point."
        #expect(helped.begin(published: [], now: clock(1)).accepted)
        #expect(try submit(&helped, "The point is the new day.", at: 2))
        #expect(helped.activeAttempt?.currentResponse?.assisted == true)
        #expect(helped.saveSelfReview(
            purposeClear: true, organization: "Point first.", wordUse: "Day.",
            delivery: "", eyeContact: "", now: clock(3)).accepted)
        #expect(helped.activeAttempt?.qualifies() == false)
        #expect(helped.activeAttempt?.courseCompletionID == nil)
    }

    @Test func aLateRecordingCannotAttachToAnotherQuestion() throws {
        var session = try started()
        #expect(session.openRecordingSlot(questionID: "response").accepted)
        let first = try #require(session.activeRecordingSlot?.id)
        #expect(session.openRecordingSlot(questionID: "follow-up").accepted)
        #expect(session.receiveRecording(turnID: first, reference: "private/opening").accepted == false)
        let second = try #require(session.activeRecordingSlot?.id)
        #expect(session.receiveRecording(turnID: second, reference: "private/follow-up").accepted)
        #expect(session.submit(questionID: "response", text: "", now: clock(2)).accepted == false)
        #expect(session.activeRecordingSlot?.reference == "private/follow-up")
    }
    @Test func changedTaskInvalidatesAnUnsubmittedRecordingAndRoutineCredit() throws {
        var session = try started()
        _ = session.completeRoutine([.paraphrase], now: clock(2))
        _ = session.openRecordingSlot(questionID: "response")
        let old = try #require(session.activeRecordingSlot?.id)
        _ = session.receiveRecording(turnID: old, reference: "old prompt take")
        var task = try #require(session.activeAttempt?.task)
        task.purpose = "A materially different task"
        let before = session.activeAttemptID
        #expect(session.reviseTask(task, published: [], now: clock(3)).accepted)
        #expect(session.activeAttemptID != before)
        #expect(session.activeRecordingSlot == nil)
        #expect(session.activeAttempt?.routineParticipationID == nil)
        #expect(!session.receiveRecording(turnID: old, reference: "late").accepted)
    }

    @Test func retryWaitsForUnresolvedFeedbackAndPreservesFirstResponse() throws {
        var session = try enabled()
        _ = try submit(&session, "First response", at: 2)
        let first = try #require(session.activeAttempt?.currentResponse?.id)
        let request = try #require(session.requestTextFeedback(now: clock(3)).value)
        #expect(session.retry(previousID: first, questionID: "response", text: "New answer", now: clock(4)) == .refused(.requestInFlight))
        #expect(session.activeAttempt?.currentResponse?.id == first)
        #expect(session.activeAttempt?.inFlightRequestID == request.requestID)
        _ = session.cancelFeedback(now: clock(5))
        #expect(session.retry(previousID: first, questionID: "response", text: "New answer", now: clock(6)).accepted)
        #expect(session.activeAttempt?.responses.first?.text == "First response")
    }

    @Test func discardClearsEnteredFrameworkAcrossDraftAndAttempt() throws {
        var session = practice()
        session.draftTask.frameworkID = "Private framework sentinel"
        _ = session.begin(published: [], now: clock(1))
        _ = session.end()
        #expect(session.applyRetention(keepAudio: true, keepText: false).accepted)
        #expect(session.draftTask.frameworkID == nil)
        #expect(session.attempts.allSatisfy { $0.task.frameworkID == nil })
        let data = try JSONEncoder().encode(session)
        #expect(!String(decoding: data, as: UTF8.self).contains("Private framework sentinel"))
    }

    @Test func feedbackHintsAndRetryPromptsCannotIntroduceUnsupportedScores() {
        var feedback = textFeedback(request: UUID(), response: UUID(), summary: "Clear purpose", improvements: [improvement("Meeting")])
        feedback.improvements[0].hint = "Raise your confidence score"
        #expect(CommunicationPractice.validate(feedback, learnerText: "Meeting", source: nil) == nil)
        feedback.improvements[0].hint = nil
        feedback.improvements[0].retryPrompt = "Improve your pronunciation score"
        #expect(CommunicationPractice.validate(feedback, learnerText: "Meeting", source: nil) == nil)
    }

    @Test func structuredTaskIdentityCannotCollideThroughDelimiterText() {
        var first = practice().draftTask, second = first
        first.purpose = "a|b"; first.frameworkID = "c"
        second.purpose = "a"; second.frameworkID = "b|c"
        #expect(first.fingerprint != second.fingerprint)
    }

    @Test func sourceLinkedArchiveRestoresAcrossEntriesAndKeepsVersionsSeparate() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        var repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        var session = try started()
        _ = try submit(&session, "Synthetic source-linked first response", at: 2)
        let credit = session.activeAttempt?.creditID
        let archive = SpeakingPracticeArchive(kind: session.archiveKind, drafts: ["answer": "Synthetic draft"],
            expiresAt: Date.now.addingTimeInterval(3600), communication: session, updatedAt: .now)
        try repository.saveSpeakingPractice(archive, expectedEpoch: repository.learningDataEpoch())
        repository.close()
        repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { repository.close() }
        let saved = try #require(try repository.speakingPractice(session.archiveKind))
        var restored = try #require(saved.communication)
        #expect(restored.setEntry(.speechLab).accepted)
        #expect(restored.id == session.id && restored.activeAttempt?.creditID == credit)
        #expect(saved.drafts["answer"] == "Synthetic draft")
        var older = try #require(session.draftTask.source); older.contentVersion = "2"
        #expect(CommunicationPractice.archiveKind(source: older) != session.archiveKind)
        #expect(try repository.speakingPractice(CommunicationPractice.archiveKind(source: older)) == nil)
        #expect(try repository.lessonJourneys(lessonID: "a1-greetings").isEmpty)
        try repository.deleteAllLearningData()
        #expect(throws: LearnerStorageError.staleVersion) { try repository.saveSpeakingPractice(archive, expectedEpoch: UUID()) }
    }

    @Test func recoveringCommunicationNeverResendsAnUnresolvedRequest() throws {
        var session = try enabled()
        _ = try submit(&session, "Synthetic pending response", at: 2)
        let request = try #require(session.requestTextFeedback(now: clock(3)).value)
        var archive = SpeakingPracticeArchive(kind: session.archiveKind, drafts: [:], expiresAt: nil, communication: session, updatedAt: .now)
        archive = try JSONDecoder().decode(SpeakingPracticeArchive.self, from: JSONEncoder().encode(archive))
        archive.resolveInterruptedRequest(now: clock(4))
        #expect(archive.communication?.activeAttempt?.inFlightRequestID == nil)
        #expect(archive.communication?.activeAttempt?.closedRequests.last?.requestID == request.requestID)
        #expect(archive.communication?.activeAttempt?.closedRequests.last?.reason == .unknownOutcome)
        #expect(archive.communication?.activeAttempt?.feedback == nil)
    }

    @Test func failedCommunicationSaveKeepsLastRecordAndExpiryRemovesIt() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = try LearnerRepository(root: root, now: { clock(100) }, protectedDataAvailable: { true })
        defer { repository.close() }
        let session = try started()
        let epoch = try repository.learningDataEpoch()
        var archive = SpeakingPracticeArchive(kind: session.archiveKind, drafts: ["answer": "Saved"], expiresAt: clock(200), communication: session, updatedAt: clock(1))
        try repository.saveSpeakingPractice(archive, expectedEpoch: epoch)
        repository.beforeCommit = { throw LearnerStorageError.storageFailure }
        archive.drafts["answer"] = "Unsaved"
        #expect(throws: LearnerStorageError.storageFailure) { try repository.saveSpeakingPractice(archive, expectedEpoch: epoch) }
        repository.beforeCommit = nil
        #expect(try repository.speakingPractice(session.archiveKind)?.drafts["answer"] == "Saved")
        archive.expiresAt = clock(99)
        try repository.saveSpeakingPractice(archive, expectedEpoch: epoch)
        #expect(try repository.speakingPractice(session.archiveKind) == nil)
    }

    @Test func audioDeclineAlsoPurgesAbandonedSlotsAndPrivatePromptCanBeClearedIndependently() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { repository.close() }
        let session = UUID()
        func saved(_ owner: UUID) throws -> AttemptSnapshot {
            let context = practiceRecordingContext(slotID: UUID(), sessionID: owner, prompt: "Private task sentinel",
                objective: "COMMUNICATION-LOCAL", presenter: "parrotSpeaker", purpose: "communicationTurn", defaults: LearnerPreferences())
            let attempt = try repository.createAttempt(prompt: #require(context.promptOverride), context: context)
            // Synthetic storage bytes test file ownership/retention, not capture or audio quality.
            let captured = try repository.finalizeRecording(attemptID: attempt.id, data: Data([0, 0]), durationMilliseconds: 1000,
                sampleRate: 44_100, channels: 1, bitsPerSample: 16, expectedVersion: attempt.version)
            return try repository.saveSelection(captured.id, keepAudio: true, keepText: false, expectedVersion: captured.version)
        }
        let attached = try saved(session), abandoned = try saved(session), unrelated = try saved(UUID())
        let epoch = try repository.learningDataEpoch()
        try repository.clearSpeakingPracticePrivatePrompts(sessionID: session, expectedEpoch: epoch)
        #expect(try repository.attempt(attached.id).prompt.text == nil)
        #expect(try repository.attempt(abandoned.id).audio.state == .saved)
        #expect(try repository.attempt(unrelated.id).prompt.text == "Private task sentinel")
        try repository.discardSpeakingPracticeAudio([attached.id], sessionID: session, expectedEpoch: epoch)
        #expect(try repository.attempt(attached.id).audio.isVisible == false)
        #expect(try repository.attempt(abandoned.id).audio.isVisible == false)
        #expect(try repository.attempt(unrelated.id).audio.state == .saved)
    }

    @Test func communicationRecordingFreezesExactSourceWithoutCourseCompletion() throws {
        var task = practice().draftTask
        task.source?.contentVersion = "2"
        let owner = UUID(), slot = UUID()
        let context = communicationRecordingContext(slotID: slot, sessionID: owner, task: task, defaults: LearnerPreferences())
        #expect(context.provenance?.communicationSource == task.source)
        #expect(context.provenance?.purpose == "communicationTurn")
        #expect(context.provenance?.journeyID == owner && context.provenance?.activityID == slot.uuidString)
        #expect(context.sourceLessonID == nil && context.sourceLessonJourneyID == nil)
        #expect(context.provenance?.supported == false)
        #expect(context.promptOverride?.selectedLevel == "A1")
        task.source = nil
        let standalone = communicationRecordingContext(slotID: UUID(), sessionID: owner, task: task, defaults: LearnerPreferences())
        #expect(standalone.promptOverride?.selectedLevel == "Unassessed")
    }

}

private extension Result where Failure == CommunicationRefusal {
    var value: Success? { if case .success(let value) = self { return value }; return nil }
    var refusal: CommunicationRefusal? { if case .failure(let error) = self { return error }; return nil }
}

private func started() throws -> CommunicationPractice {
    var session = practice()
    #expect(session.begin(published: [], now: clock(1)).accepted)
    return session
}

private func enabled() throws -> CommunicationPractice {
    var session = try started()
    session.feedbackPolicy = .textOnlyEnabled(contractVersion: "recorded-feedback-v1")
    return session
}

@discardableResult
private func submit(_ session: inout CommunicationPractice, _ text: String, at minute: Int) throws -> Bool {
    let action = session.submit(questionID: "response", text: text, now: clock(minute))
    #expect(action.accepted)
    return action.accepted
}

private func practice(
    focus: CommunicationFocus = .explainClearly, purpose: String = "Explain a delay to a teammate."
) -> CommunicationPractice {
    CommunicationPractice(entry: .learn, task: CommunicationTask(
        itemID: nil, itemVersion: nil,
        source: CommunicationSource(lessonID: "a1-greetings", contentVersion: "3", objectiveID: "GREET-01", senseID: nil),
        purpose: purpose, focus: focus, frameworkID: nil, scaffold: nil, fictional: true,
        sourceExchange: nil, referenceAudioID: nil))
}

private func sampleItem(id: String = "comm-clear-1", status: String) -> CommunicationItem {
    CommunicationItem(
        id: id, version: "1", focus: .explainClearly, lessonID: "a1-greetings", contentVersion: "3",
        objectiveID: "GREET-01", senseID: nil, audience: "a teammate", purpose: "Explain why a meeting moved.",
        sourceExchange: nil, referenceAudioID: nil, prompt: "Tell a teammate the meeting day changed.",
        fictionalExample: "The meeting moved to Thursday.", reviewStatus: status, rubricStatus: status,
        representsLearnerAccomplishment: false, frameworkRequired: false)
}

private func textFeedback(
    request: UUID, response: UUID, summary: String, strengths: [String] = ["The day is explicit."],
    improvements: [CommunicationImprovement] = []
) -> CommunicationTextFeedback {
    CommunicationTextFeedback(
        requestID: request, responseID: response, summary: summary, strengths: strengths,
        improvements: improvements, limitations: ["Pronunciation was not assessed from this transcript."],
        speechAssessmentStatus: "not_assessed")
}

private func improvement(_ quote: String) -> CommunicationImprovement {
    CommunicationImprovement(
        category: .organization, evidenceQuote: quote, explanation: "Name the day before the reason.",
        suggestedRevision: nil, hint: nil, retryPrompt: "Give the day first.")
}

private func clock(_ minute: Int) -> Date { Date(timeIntervalSince1970: TimeInterval(minute)) }
