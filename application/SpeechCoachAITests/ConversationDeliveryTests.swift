import Foundation
import AVFAudio
import Testing
@testable import SpeechCoachAI

struct ConversationDeliveryTests {
    @Test func twoBoundRepliesQualifyAndASelfReviewDoesNot() throws {
        var session = try startedConversation()
        let first = try submit(&session, "I went to the market.", at: 1)
        #expect(session.qualifiesAsConversation == false)
        try reply(to: &session, turn: first, text: "What did you buy?", requestAt: 2, replyAt: 2)
        #expect(session.qualifiesAsConversation == false)
        let second = try submit(&session, "I bought tea.", at: 3)
        #expect(session.saveSelfReview(purposeClear: true, factsNamed: "market and tea", nextStep: "Say the price next time.", now: clock(4)).accepted)
        #expect(session.selfReview.speechAssessed == false)
        #expect(session.qualifiesAsConversation == false)
        #expect(session.affectsCourseProgress == false)
        try reply(to: &session, turn: second, text: "Was the tea for a friend?", requestAt: 5, replyAt: 6)
        #expect(session.qualifiesAsConversation)
        #expect(session.backAndForthCount == 2)
        #expect(session.turns.filter { $0.speaker == .partner }.compactMap(\.respondsTo) == [first, second])
    }

    @Test func aPartnerReplyBindsOnlyToTheCurrentTurn() throws {
        var session = try enabledConversation()
        let first = try submit(&session, "Hello.", at: 1)
        let second = try submit(&session, "I am practicing.", at: 2)
        let stale = TurnRequestAuthorization(requestID: UUID(), consentReference: "this-turn", contractVersion: contract)
        let wrong = session.requestPartner(turnID: first, authorization: stale, now: clock(3))
        #expect(wrong.refusal == .notCurrentTurn)
        let live = session.requestPartner(turnID: second, authorization: TurnRequestAuthorization(requestID: UUID(), consentReference: "this-turn", contractVersion: contract), now: clock(3))
        let request = try #require(live.descriptor)
        #expect(request.sendsAudio == false)
        #expect(request.currentTurnText == "I am practicing.")
        #expect(request.priorTurnIDs.isEmpty)
        #expect(request.priorTurnText.isEmpty)
        let late = session.receivePartner(PartnerReply(requestID: request.requestID, learnerTurnID: first, text: "Too late."), now: clock(4))
        #expect(late.refusal == .lateResult)
        #expect(session.turns.contains { $0.text == "Too late." } == false)
        #expect(session.receivePartner(PartnerReply(requestID: request.requestID, learnerTurnID: second, text: "What are you practicing?"), now: clock(5)).accepted)
    }

    @Test func cancellationLateResultsAndUnknownOutcomesDoNotResend() throws {
        var session = try enabledConversation()
        let turn = try submit(&session, "Can we meet on Friday?", at: 1)
        let first = try #require(session.requestPartner(turnID: turn, authorization: auth(), now: clock(2)).descriptor)
        #expect(session.cancelPartnerRequest(now: clock(3)).accepted)
        #expect(session.receivePartner(PartnerReply(requestID: first.requestID, learnerTurnID: turn, text: "Friday works."), now: clock(4)).refusal == .lateResult)
        #expect(session.turns.contains { $0.text == "Friday works." } == false)
        #expect(session.requestPartner(turnID: turn, authorization: TurnRequestAuthorization(requestID: first.requestID, consentReference: "again", contractVersion: contract), now: clock(5)).refusal == .duplicateRequest)

        let second = try #require(session.requestPartner(turnID: turn, authorization: auth(), now: clock(6)).descriptor)
        #expect(session.markUnknownOutcome(now: clock(7)).accepted)
        #expect(session.receivePartner(PartnerReply(requestID: second.requestID, learnerTurnID: turn, text: "Ignored."), now: clock(8)).refusal == .lateResult)
        let beforeRestart = session.closedRequests.count
        #expect(session.stop(now: clock(9)).accepted)
        #expect(session.restart().accepted)
        #expect(session.closedRequests.count == beforeRestart)
        #expect(session.closedRequests.contains { $0.reason == .unknownOutcome })
        #expect(session.requestPartner(turnID: turn, authorization: auth(), now: clock(10)).accepted)
    }

    @Test func retryKeepsOneCreditAndAFailureDoesNotSendAgain() throws {
        var session = try enabledConversation()
        let first = try submit(&session, "I can start at nine.", at: 1)
        #expect(session.credits.count == 1)
        #expect(session.retryLearnerTurn(previousID: first, now: clock(2)).accepted)
        let retry = try #require(session.currentLearnerTurnID)
        #expect(retry != first)
        #expect(session.turns.first { $0.id == retry }?.retryOf == first)
        #expect(session.submitLearnerTurn(id: retry, text: "I can start at ten.", now: clock(3)).accepted)
        #expect(session.credits.count == 1)
        #expect(session.credits.first?.firstLearnerTurnID == first)

        let request = try #require(session.requestPartner(turnID: retry, authorization: auth(), now: clock(4)).descriptor)
        #expect(session.failPartnerRequest(requestID: request.requestID, now: clock(5)).accepted)
        #expect(session.turns.contains { $0.speaker == .partner } == false)
        #expect(session.receivePartner(PartnerReply(requestID: request.requestID, learnerTurnID: retry, text: "Noted."), now: clock(6)).refusal == .lateResult)
        #expect(session.requestPartner(turnID: retry, authorization: auth(), now: clock(7)).descriptor != nil)
    }

    @Test func onlineRequestsStayOffAndPriorTextIsNotIncludedByDefault() throws {
        var session = try startedConversation()
        let first = try submit(&session, "Private detail.", at: 1)
        let second = try submit(&session, "Current turn.", at: 2)
        var authorization = auth()
        authorization.priorTurnIDs = [first]
        authorization.includePriorTurnText = true
        let blocked = session.requestPartner(turnID: second, authorization: authorization, now: clock(3))
        #expect(blocked.refusal == .onlineDisabled)
        #expect(blocked.descriptor == nil)
        #expect(session.turns.contains { $0.speaker == .partner } == false)
        #expect(session.turns.first { $0.id == second }?.text == "Current turn.")

        session.onlinePolicy = .explicitlyEnabled(contractVersion: contract)
        authorization.includePriorTurnText = false
        let sent = try #require(session.requestPartner(turnID: second, authorization: authorization, now: clock(4)).descriptor)
        #expect(sent.currentTurnText == "Current turn.")
        #expect(sent.priorTurnText.isEmpty)
        #expect(sent.priorTurnIDs.isEmpty)
        #expect(sent.sendsAudio == false)
        #expect(ConversationSession.selectRealtime() == .realtimeUnavailable)
    }

    @Test func aRecordingWithoutTextIsNotUploaded() throws {
        var session = try enabledConversation()
        session.setup.modality = .recordedTurn
        #expect(session.openLearnerTurn(now: clock(1)).accepted)
        let id = try #require(session.currentLearnerTurnID)
        #expect(session.attachRecording(turnID: id, reference: "private/take-1").accepted)
        #expect(session.submitLearnerTurn(id: id, text: "", now: clock(2)).accepted)
        #expect(session.turns.first?.modality == .recordedTurn)
        #expect(session.requestPartner(turnID: id, authorization: auth(), now: clock(3)).refusal == .emptyTurn)
        #expect(session.retention.keepAudio == nil)
        #expect(session.retention.keepText == nil)
        #expect(session.end(now: clock(4)).accepted)
        #expect(session.applyRetention(keepAudio: false, keepText: false).accepted)
        #expect(session.turns.first?.text == nil)
        #expect(session.turns.first?.recordingReference == nil)
    }

    @Test func unpublishedScenariosStayHidden() throws {
        var session = ConversationSession(presenterID: "tigerBusinessProfessional", now: clock(0))
        session.setup.kind = .everydayScenario
        session.setup.scenarioID = "candidate-update"
        let candidate = WorkplaceScenarioReference(
            id: "candidate-update", version: "sc-d013-candidate-1", kind: "update",
            levelLessonID: "a2-work", levelContentVersion: "2", objectiveID: "WORK-02",
            trainerReference: "TR-BIZ", audience: "A fictional teammate", purpose: "Share a made-up schedule",
            nextStep: "Ask one question", fictionalExample: "A fictional character, not the learner, describes a Tuesday.",
            reviewStatus: "unreviewed-candidate", rubricStatus: "awaiting-qualified-review", representsLearnerAccomplishment: false)
        #expect(ScenarioAvailability.published([candidate]).isEmpty)
        #expect(session.begin(publishedScenarios: [candidate], now: clock(1)).refusal == .invalidSetup)
        session.setup.kind = .freeDiscussion
        #expect(session.begin(publishedScenarios: [], now: clock(1)).refusal == .invalidSetup)
        session.setup.situation = "Ordering lunch"
        #expect(session.begin(publishedScenarios: [], now: clock(1)).accepted)
    }

    @Test func anInterviewFollowUpUsesTheSubmittedAnswer() throws {
        var session = try startedInterview()
        #expect(session.submitOpening(text: "I want to talk about a team library.", recordingReference: nil, now: clock(2)).accepted)
        let followUp = try #require(session.activeAttempt?.activeFollowUp)
        #expect(followUp.quotedAnswer == "I want to talk about a team library.")
        #expect(followUp.preservesSuppliedFacts)
        #expect(followUp.composed.contains("20%") == false)
        #expect(followUp.composed.hasPrefix("You said: I want to talk about a team library."))
        #expect(session.qualifiesAsInteractiveInterview == false)
        #expect(session.submitFollowUp(text: "I would document the setup next.", recordingReference: nil, now: clock(3)).accepted)
        #expect(session.saveSelfReview(purposeClear: true, factsNamed: "library and setup", nextStep: "Name the reader.", now: clock(4)).accepted)
        #expect(session.qualifiesAsInteractiveInterview)
        #expect(session.activeAttempt?.review.speechAssessed == false)
        #expect(session.affectsCourseProgress == false)
        #expect(session.trainerReference == "TR-BIZ")
        let before = session.qualifiesAsInteractiveInterview
        #expect(session.saveTechnicalNote("Optional note.") .refusal == .invalidSetup)
        #expect(session.qualifiesAsInteractiveInterview == before)
    }

    @Test func onlineNotesDoNotBecomeLearnerFacts() throws {
        var session = try startedInterview()
        #expect(session.addSuppliedFact("I wrote the notes for the meeting.").accepted)
        #expect(session.submitOpening(text: "I wrote the notes for the meeting.", recordingReference: nil, now: clock(2)).accepted)
        let answer = try #require(session.activeAttempt?.answers.first?.id)
        session.onlinePolicy = .explicitlyEnabled(contractVersion: contract)
        let request = try #require(session.requestOnlineNote(answerID: answer, authorization: auth(), now: clock(3)).descriptor)
        #expect(request.sendsAudio == false)
        #expect(request.priorTurnText.isEmpty)
        let invented = "You increased revenue by 20 percent."
        #expect(session.receiveOnlineNote(PartnerReply(requestID: request.requestID, learnerTurnID: answer, text: invented), now: clock(4)).accepted)
        #expect(session.activeAttempt?.preparation.suppliedFacts == ["I wrote the notes for the meeting."])
        #expect(session.addSuppliedFact(invented).refusal == .invalidReply)
        #expect(session.activeAttempt?.activeFollowUp?.composed.contains("20") == false)
    }

    @Test func aChangedTaskStartsADistinctAttemptAndQuietPreparationRemains() throws {
        var session = try startedInterview()
        #expect(session.updatePreparation(note: "I will talk about a library.").accepted)
        #expect(session.setQuietPractice(true).accepted)
        #expect(session.submitOpening(text: "The library needs a short guide.", recordingReference: nil, now: clock(2)).accepted)
        let original = try #require(session.activeAttemptID)
        var support = try #require(session.activeAttempt?.support)
        support.interviewType = .behavioral
        #expect(session.reviseSupport(support, publishedScenarios: [], now: clock(3)).accepted)
        let next = try #require(session.activeAttemptID)
        #expect(next != original)
        #expect(session.attempts.first { $0.id == original }?.answers.count == 1)
        #expect(session.activeAttempt?.answers.isEmpty == true)
        #expect(session.activeAttempt?.preparation.note == "I will talk about a library.")
        #expect(session.activeAttempt?.preparation.quietPractice == true)
        #expect(session.submitOpening(text: "A teammate asked for the guide.", recordingReference: nil, now: clock(4)).accepted)
        let answer = try #require(session.activeAttempt?.answers.first?.id)
        #expect(session.requestOnlineNote(answerID: answer, authorization: auth(), now: clock(5)).refusal == .quietPractice)
        #expect(session.updatePreparation(note: "Add one example I choose.").accepted)
        #expect(session.activeAttempt?.preparation.note == "Add one example I choose.")
    }

    @Test func retentionClearsDeclinedInterviewTextAndKeepsTheOtherChoice() throws {
        var session = try startedInterview()
        #expect(session.retention.isExplicit == false)
        #expect(session.submitOpening(text: "I keep this only if I choose to.", recordingReference: "private/answer", now: clock(2)).accepted)
        #expect(session.end(now: clock(3)).accepted)
        #expect(session.applyRetention(keepAudio: true, keepText: false).accepted)
        #expect(session.activeAttempt?.answers.first?.text == nil)
        #expect(session.activeAttempt?.answers.first?.recordingReference == "private/answer")
        #expect(session.activeAttempt?.activeFollowUp?.quotedAnswer == "")
    }
    @Test func discardClearsConversationSetupAndReviewAndBlocksRepopulation() throws {
        var session = try startedConversation()
        session.setup.supportNote = "synthetic private support"
        session.setup.feedbackFocus = "synthetic private focus"
        _ = session.saveSelfReview(purposeClear: true, factsNamed: "private facts", nextStep: "private step", now: clock(1))
        _ = session.end(now: clock(2))
        #expect(session.applyRetention(keepAudio: false, keepText: false).accepted)
        #expect(session.setup.situation.isEmpty && session.setup.supportNote.isEmpty && session.setup.feedbackFocus.isEmpty)
        #expect(session.selfReview.factsNamed.isEmpty && session.selfReview.nextStep.isEmpty)
        #expect(session.saveSelfReview(purposeClear: true, factsNamed: "restore", nextStep: "restore", now: clock(3)).refusal == .sessionClosed)
    }

    @Test func discardClearsInterviewDraftAndAllAttemptsAndBlocksRepopulation() throws {
        var session = try startedInterview()
        _ = session.updatePreparation(note: "synthetic private preparation")
        _ = session.submitOpening(text: "synthetic answer", recordingReference: "private-audio", now: clock(1))
        _ = session.saveSelfReview(purposeClear: true, factsNamed: "private facts", nextStep: "private step", now: clock(2))
        _ = session.end(now: clock(3))
        #expect(session.applyRetention(keepAudio: false, keepText: false).accepted)
        #expect(session.draftPreparation.note.isEmpty && session.draftPreparation.suppliedFacts.isEmpty)
        #expect(session.draftSupport.roleTitle.isEmpty)
        #expect(session.attempts.allSatisfy { $0.preparation.note.isEmpty && $0.review.factsNamed.isEmpty && $0.review.nextStep.isEmpty && $0.support.roleTitle.isEmpty })
        #expect(session.updatePreparation(note: "restore").refusal == .sessionClosed)
        #expect(session.addSuppliedFact("restore").refusal == .sessionClosed)
        #expect(session.saveTechnicalNote("restore").refusal == .sessionClosed)
        #expect(session.saveSelfReview(purposeClear: true, factsNamed: "restore", nextStep: "restore", now: clock(4)).refusal == .sessionClosed)
    }

    @Test func revisingTaskCancelsOldRequestBeforeSwitchingAttempt() throws {
        var session = try startedInterview()
        _ = session.submitOpening(text: "synthetic first answer", recordingReference: nil, now: clock(1))
        session.onlinePolicy = .explicitlyEnabled(contractVersion: contract)
        let answer = try #require(session.activeAttempt?.answers.first)
        let request = try #require(session.requestOnlineNote(answerID: answer.id, authorization: auth(), now: clock(2)).descriptor)
        let originalID = session.activeAttemptID
        var changed = session.draftSupport; changed.roleTitle = "Different role"
        #expect(session.reviseSupport(changed, publishedScenarios: [], now: clock(3)).accepted)
        let old = try #require(session.attempts.first { $0.id == originalID })
        #expect(old.inFlightRequestID == nil && old.inFlightAnswerID == nil)
        #expect(old.closedRequests.last?.requestID == request.requestID)
        #expect(old.closedRequests.last?.reason == .cancelled)
        #expect(session.receiveOnlineNote(PartnerReply(requestID: request.requestID, learnerTurnID: answer.id, text: "late"), now: clock(4)).refusal == .lateResult)
        #expect(session.activeAttempt?.onlineNotes.isEmpty == true)
    }

    @Test func recordingSlotRejectsUnrelatedLateAndRepeatedAttachments() {
        let attempt = UUID()
        var slot = InterviewRecordingSlot(attemptID: attempt, promptID: "opening")
        let wrong = slot.receive(PracticeRecordingAttachment(turnID: UUID(), reference: "wrong"), activeAttemptID: attempt)
        #expect(wrong == false)
        let late = slot.receive(PracticeRecordingAttachment(turnID: slot.id, reference: "late"), activeAttemptID: UUID())
        #expect(late == false)
        let right = slot.receive(PracticeRecordingAttachment(turnID: slot.id, reference: "right"), activeAttemptID: attempt)
        #expect(right)
        let repeated = slot.receive(PracticeRecordingAttachment(turnID: slot.id, reference: "replacement"), activeAttemptID: attempt)
        #expect(repeated == false)
        #expect(slot.reference(attemptID: attempt, promptID: "opening") == "right")
        #expect(slot.reference(attemptID: attempt, promptID: "followup") == nil)
        #expect(slot.reference(attemptID: UUID(), promptID: "opening") == nil)
    }

    @Test func keepingTextPreservesChosenReviewAndAudioRemainsIndependent() throws {
        var session = try startedConversation()
        let id = try submit(&session, "keep chosen text", at: 1)
        _ = session.saveSelfReview(purposeClear: true, factsNamed: "chosen facts", nextStep: "chosen plan", now: clock(2))
        _ = session.end(now: clock(3))
        _ = session.applyRetention(keepAudio: false, keepText: true)
        #expect(session.turns.first { $0.id == id }?.text == "keep chosen text")
        #expect(session.selfReview.factsNamed == "chosen facts")
        #expect(session.turns.allSatisfy { $0.recordingReference == nil })
    }

    @Test func explicitDraftSurvivesRepositoryReopenAndRejectsDeletedEpoch() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("D013-recovery-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        var repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let epoch = try repository.learningDataEpoch()
        let session = try startedConversation()
        let archive = SpeakingPracticeArchive(kind: "conversation", conversation: session,
            drafts: ["draft": "synthetic unfinished turn"], expiresAt: Date.now.addingTimeInterval(3600), updatedAt: .now)
        try repository.saveSpeakingPractice(archive, expectedEpoch: epoch)
        repository.close()
        repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let restored = try #require(try repository.speakingPractice("conversation"))
        #expect(restored.drafts["draft"] == "synthetic unfinished turn")
        #expect(restored.conversation?.id == session.id)
        try repository.deleteAllLearningData()
        #expect(try repository.speakingPractice("conversation") == nil)
        #expect(throws: LearnerStorageError.staleVersion) { try repository.saveSpeakingPractice(archive, expectedEpoch: epoch) }
        repository.close()
    }

    @Test func expiredDraftIsUnavailableAndDoesNotReappear() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("D013-expiry-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = try LearnerRepository(root: root, now: { clock(100) }, protectedDataAvailable: { true })
        let archive = SpeakingPracticeArchive(kind: "interview", interview: try startedInterview(),
            drafts: ["opening": "expired synthetic answer"], expiresAt: clock(99), updatedAt: clock(98))
        try repository.saveSpeakingPractice(archive, expectedEpoch: repository.learningDataEpoch())
        #expect(try repository.speakingPractice("interview") == nil)
        #expect(try repository.speakingPractice("interview") == nil)
        repository.close()
    }

    @Test func reopeningPendingRequestMarksUnknownAndDoesNotResend() throws {
        var session = try enabledConversation()
        let turn = try submit(&session, "synthetic request", at: 1)
        let request = try #require(session.requestPartner(turnID: turn, authorization: auth(), now: clock(2)).descriptor)
        var archive = SpeakingPracticeArchive(kind: "conversation", conversation: session, drafts: [:], expiresAt: clock(50), updatedAt: clock(2))
        archive = try JSONDecoder().decode(SpeakingPracticeArchive.self, from: JSONEncoder().encode(archive))
        archive.resolveInterruptedRequest(now: clock(3))
        #expect(archive.conversation?.closedRequests.last?.requestID == request.requestID)
        #expect(archive.conversation?.closedRequests.last?.reason == .unknownOutcome)
        #expect(archive.conversation?.turns.contains { $0.speaker == .partner } == false)
    }

    @Test func independentRecorderFreezesPrivatePromptWithoutCourseCredit() {
        let slot = UUID(), session = UUID()
        let context = practiceRecordingContext(slotID: slot, sessionID: session, prompt: "synthetic chosen situation",
            objective: "CONVERSATION-LOCAL", presenter: "parrotSpeaker", purpose: "conversationTurn", defaults: LearnerPreferences())
        #expect(context.id == slot)
        #expect(context.promptOverride?.text == "synthetic chosen situation")
        #expect(context.promptOverride?.isPrivate == true)
        #expect(context.provenance?.journeyID == session)
        #expect(context.provenance?.activityID == slot.uuidString)
        #expect(context.provenance?.purpose == "conversationTurn")
        #expect(context.sourceLessonID == nil)
    }

    @Test func failedArchiveWritePreservesLastSavedDraft() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("D013-atomic-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let epoch = try repository.learningDataEpoch()
        var archive = SpeakingPracticeArchive(kind: "conversation", conversation: try startedConversation(),
            drafts: ["draft": "saved draft"], expiresAt: Date.now.addingTimeInterval(3600), updatedAt: .now)
        try repository.saveSpeakingPractice(archive, expectedEpoch: epoch)
        repository.beforeCommit = { throw LearnerStorageError.storageFailure }
        archive.drafts["draft"] = "unsaved draft"
        #expect(throws: LearnerStorageError.storageFailure) { try repository.saveSpeakingPractice(archive, expectedEpoch: epoch) }
        repository.beforeCommit = nil
        #expect(try repository.speakingPractice("conversation")?.drafts["draft"] == "saved draft")
        repository.close()
    }

    @Test func finalDiscardPersistsNoAnswerOrDraftText() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("D013-discard-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        var session = try startedInterview()
        _ = session.submitOpening(text: "synthetic-discard-sentinel", recordingReference: nil, now: clock(1))
        _ = session.end(now: clock(2))
        _ = session.applyRetention(keepAudio: false, keepText: false)
        let archive = SpeakingPracticeArchive(kind: "interview", interview: session, drafts: [:], expiresAt: nil, updatedAt: .now)
        try repository.saveSpeakingPractice(archive, expectedEpoch: repository.learningDataEpoch())
        let saved = try #require(try repository.speakingPractice("interview"))
        let data = try JSONEncoder().encode(saved)
        #expect(String(decoding: data, as: UTF8.self).contains("synthetic-discard-sentinel") == false)
        #expect(saved.drafts.isEmpty && saved.expiresAt == nil)
        repository.close()
    }

    @Test func decliningAudioPurgesOnlyTheMatchingIndependentSession() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("D013-audio-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { repository.close() }
        let session = UUID()
        func recorded(_ owner: UUID) throws -> AttemptSnapshot {
            let context = practiceRecordingContext(slotID: UUID(), sessionID: owner, prompt: "Synthetic prompt",
                objective: "INTERVIEW-LOCAL", presenter: "tigerBusinessProfessional", purpose: "interviewTurn", defaults: LearnerPreferences())
            let attempt = try repository.createAttempt(prompt: #require(context.promptOverride), context: context)
            let url = try repository.prepareCapture(attempt.id, expectedVersion: attempt.version)
            let format = try #require(AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 44_100, channels: 1, interleaved: true))
            let buffer = try #require(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44_100))
            buffer.frameLength = 44_100
            buffer.int16ChannelData?[0].initialize(repeating: 0, count: 44_100)
            do {
                let file = try AVAudioFile(forWriting: url, settings: format.settings, commonFormat: .pcmFormatInt16, interleaved: true)
                try file.write(from: buffer)
            }
            let captured = try repository.finalizeCapture(attempt.id)
            return try repository.saveSelection(captured.id, keepAudio: true, keepText: false, expectedVersion: captured.version)
        }
        let own = try recorded(session), other = try recorded(UUID())
        let epoch = try repository.learningDataEpoch()
        #expect(throws: LearnerStorageError.invalidReference) {
            try repository.discardSpeakingPracticeAudio([other.id], sessionID: session, expectedEpoch: epoch)
        }
        #expect(try repository.attempt(other.id).audio.state == .saved)
        try repository.discardSpeakingPracticeAudio([own.id], sessionID: session, expectedEpoch: epoch)
        #expect(try repository.attempt(own.id).audio.isVisible == false)
        #expect(try repository.attempt(other.id).audio.state == .saved)
    }

}

private let contract = "test-contract"

private func clock(_ step: Int) -> Date { Date(timeIntervalSince1970: TimeInterval(step * 60)) }

private func auth() -> TurnRequestAuthorization {
    TurnRequestAuthorization(requestID: UUID(), consentReference: "explicit-turn-consent", contractVersion: contract)
}

private func startedConversation() throws -> ConversationSession {
    var session = ConversationSession(presenterID: "parrotSpeaker", now: clock(0))
    session.setup.situation = "A short everyday exchange"
    #expect(session.begin(publishedScenarios: [], now: clock(0)).accepted)
    return session
}

private func enabledConversation() throws -> ConversationSession {
    var session = try startedConversation()
    session.onlinePolicy = .explicitlyEnabled(contractVersion: contract)
    return session
}

private func submit(_ session: inout ConversationSession, _ text: String, at step: Int) throws -> UUID {
    #expect(session.openLearnerTurn(now: clock(step)).accepted)
    let id = try #require(session.currentLearnerTurnID)
    #expect(session.submitLearnerTurn(id: id, text: text, now: clock(step)).accepted)
    return id
}

private func reply(to session: inout ConversationSession, turn: UUID, text: String, requestAt: Int, replyAt: Int) throws {
    session.onlinePolicy = .explicitlyEnabled(contractVersion: contract)
    let request = try #require(session.requestPartner(turnID: turn, authorization: auth(), now: clock(requestAt)).descriptor)
    #expect(session.receivePartner(PartnerReply(requestID: request.requestID, learnerTurnID: turn, text: text), now: clock(replyAt)).accepted)
}

private func startedInterview() throws -> InterviewSession {
    var session = InterviewSession(presenterID: LearnerPreferences.Coach.tigerBusinessProfessional.rawValue, now: clock(0))
    session.draftSupport.roleTitle = "Software engineering"
    #expect(session.begin(publishedScenarios: [], now: clock(1)).accepted)
    #expect(session.activeAttempt?.support.technicalCoaching == false)
    #expect(session.activeAttempt?.support.fictionalPersona == false)
    return session
}
