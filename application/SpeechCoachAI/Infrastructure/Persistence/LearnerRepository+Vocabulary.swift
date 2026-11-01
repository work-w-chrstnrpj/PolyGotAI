import Foundation
import SwiftData

/// Vocabulary enrollments, recall, custom topics and exposures.
extension LearnerRepository {
    func vocabularyEnrollments() throws -> [VocabularyEnrollment] { try document().vocabularyEnrollments }

    func vocabularyExposures() throws -> [VocabularyExposure] { try document().vocabularyExposures }

    @discardableResult
    func enrollVocabulary(_ sense: CurriculumSense, lesson: ResolvedLesson, inReview: Bool = true) throws -> VocabularyEnrollment {
        var stored = try document()
        var collection = VocabularyCollection(enrollments: stored.vocabularyEnrollments, exposures: stored.vocabularyExposures)
        let enrollment = try collection.enroll(sense, lesson: lesson, now: try effectiveNow(), inReview: inReview)
        if stored.vocabularyEnrollments == collection.enrollments { return enrollment }
        stored.vocabularyEnrollments = collection.enrollments
        try write(stored)
        return enrollment
    }

    @discardableResult
    func saveVocabularyToCollection(_ sense: CurriculumSense, lesson: ResolvedLesson) throws -> VocabularyEnrollment {
        try enrollVocabulary(sense, lesson: lesson, inReview: false)
    }

    func addCollectedVocabularyToReview(_ card: VocabularyEnrollment) throws {
        var stored = try document()
        let indices = stored.vocabularyEnrollments.indices.filter { stored.vocabularyEnrollments[$0].id == card.id }
        guard indices.count == 1, let index = indices.first else { throw VocabularyRecallError.unknownCard }
        guard !stored.vocabularyEnrollments[index].inReview else { return }
        stored.vocabularyEnrollments[index].inReview = true
        try write(stored)
    }

    func customTopics() throws -> [CustomVocabularyTopic] { try document().customTopics }

    func vocabularyRecalls() throws -> [VocabularyRecallAttempt] { try document().vocabularyRecalls }

    func senseCredits() throws -> [SenseCreditEvent] { try document().senseCredits }

    /// Assign identity once to a legacy draft before returning it for resume or skip.
    func openRecall() throws -> OpenRecall? {
        var stored = try document()
        guard var open = stored.openRecall else { return nil }
        guard open.sourceEventID == nil else { return open }
        open.sourceEventID = UUID()
        stored.openRecall = open
        try write(stored)
        return open
    }

    /// Saves a hidden draft or reveal without rating. Revealed first responses cannot be replaced.
    func stageOpenRecall(card: VocabularyEnrollment, draft: RecallDraft, expectedEpoch: UUID? = nil) throws {
        if let expectedEpoch, expectedEpoch != (try state().epoch) { throw LearnerStorageError.invalidState }
        var stored = try document()
        guard stored.vocabularyEnrollments.contains(where: { $0.itemId == card.itemId && $0.senseId == card.senseId && $0.inReview }) else {
            throw VocabularyRecallError.unknownCard
        }
        guard !stored.vocabularyRecalls.contains(where: { $0.sourceEventID == draft.sourceEventID }) else {
            throw VocabularyRecallError.staleEvent
        }
        if let open = stored.openRecall, open.itemId == card.itemId, open.senseId == card.senseId {
            if let event = open.sourceEventID, event != draft.sourceEventID { throw VocabularyRecallError.staleEvent }
            if open.revealed { return }
        }
        let staged = OpenRecall(
            itemId: card.itemId, senseId: card.senseId, typed: draft.typed, revealed: draft.revealed,
            firstResponse: draft.firstResponse, hinted: draft.hinted, mode: draft.mode, sourceEventID: draft.sourceEventID)
        guard stored.openRecall != staged else { return }
        stored.openRecall = staged
        try write(stored)
    }

    func clearOpenRecall(sourceEventID: UUID, expectedEpoch: UUID? = nil) throws {
        if let expectedEpoch, expectedEpoch != (try state().epoch) { throw LearnerStorageError.invalidState }
        var stored = try document()
        guard stored.openRecall?.sourceEventID == sourceEventID else { return }
        stored.openRecall = nil
        try write(stored)
    }

    func recognitionSchedule(itemId: String, senseId: String) throws -> ReviewCardState? {
        try document().reviewCards.first { $0.itemId == itemId && $0.senseId == senseId && $0.kind == ReviewSchedule.kind }
    }

    func reviewQueue() throws -> ReviewQueuePlan {
        let stored = try document()
        return ReviewQueue.plan(enrollments: stored.vocabularyEnrollments, cards: stored.reviewCards, now: try effectiveNow())
    }

    func reviewSettings() throws -> ReviewSettings {
        let settings = try document().reviewSettings ?? ReviewSettings()
        try settings.validate()
        return settings
    }

    func saveReviewSettings(_ settings: ReviewSettings, expectedEpoch: UUID? = nil) throws {
        if let expectedEpoch, expectedEpoch != (try state().epoch) { throw LearnerStorageError.invalidState }
        try settings.validate()
        var stored = try document()
        guard stored.reviewSettings != settings else { return }
        stored.reviewSettings = settings
        try write(stored)
    }

    // Practice-goal preference used by the Today suggestion.
    func meaningNote(itemId: String, senseId: String) throws -> String? {
        let stored = try document()
        let note = stored.customTopics.lazy.flatMap(\.senses).first { $0.itemId == itemId && $0.senseId == senseId }?.note
            ?? stored.vocabularyEnrollments.first { $0.itemId == itemId && $0.senseId == senseId }?.meaning
            ?? CurriculumCatalogLoader.bundled.lessons.lazy.filter(\.isReady).flatMap(\.senses)
                .first { $0.itemId == itemId && $0.senseId == senseId }?.meaning
        let trimmed = note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    @discardableResult
    func recordVocabularyRecall(card: VocabularyEnrollment, rating: RecallRating, draft: RecallDraft, sourceEventID: UUID? = nil, expectedEpoch: UUID? = nil) throws -> VocabularyRecallAttempt {
        if let expectedEpoch, expectedEpoch != (try state().epoch) { throw LearnerStorageError.invalidState }
        var stored = try document()
        let sourceEventID = sourceEventID ?? draft.sourceEventID
        let enrolled = stored.vocabularyEnrollments.contains { $0.itemId == card.itemId && $0.senseId == card.senseId && $0.inReview }
        let recorded = Set(stored.vocabularyRecalls.compactMap(\.sourceEventID))
        let decision = ReviewCreditPolicy.decide(
            task: .explicitRating, revealed: draft.revealed, kind: .recognition,
            sourceEventID: sourceEventID, alreadyRecorded: recorded, enrolled: enrolled)
        if case .unchanged(.duplicateEvent) = decision {
            guard let existing = stored.vocabularyRecalls.first(where: { $0.sourceEventID == sourceEventID }),
                  existing.itemId == card.itemId, existing.senseId == card.senseId else {
                throw VocabularyRecallError.staleEvent
            }
            return existing
        }
        var acceptedDraft = draft
        if let open = stored.openRecall, open.itemId == card.itemId, open.senseId == card.senseId {
            if let event = open.sourceEventID, event != sourceEventID { throw VocabularyRecallError.staleEvent }
            acceptedDraft = RecallDraft(open)
        }
        guard enrolled else { throw VocabularyRecallError.unknownCard }
        guard acceptedDraft.revealed else { throw VocabularyRecallError.stillHidden }
        guard try meaningNote(itemId: card.itemId, senseId: card.senseId) != nil else { throw VocabularyRecallError.missingMeaning }
        let now = try effectiveNow()
        var log = VocabularyRecallLog(attempts: stored.vocabularyRecalls)
        var attempt = try log.record(card: card, rating: rating, draft: acceptedDraft, now: now, sourceEventID: sourceEventID)
        // Do not bypass queue integrity through a stale screen or a direct repository call.
        guard stored.vocabularyEnrollments.filter({ $0.id == card.id && $0.inReview }).count == 1 else {
            throw ReviewScheduleError.schedulingFailed
        }
        let histories = stored.reviewCards.filter { $0.itemId == card.itemId && $0.senseId == card.senseId }
        guard histories.count <= 1 else { throw ReviewScheduleError.schedulingFailed }
        let existing = histories.first
        let scheduled = try ReviewSchedule.schedule(existing: existing, rating: rating, now: now, itemId: card.itemId, senseId: card.senseId, settings: stored.reviewSettings ?? ReviewSettings())
        attempt.schedulerVersion = scheduled.schedulerVersion
        attempt.desiredRetention = scheduled.desiredRetention
        log.attempts[log.attempts.count - 1] = attempt
        stored.vocabularyRecalls = log.attempts
        if stored.openRecall?.itemId == card.itemId && stored.openRecall?.senseId == card.senseId {
            stored.openRecall = nil
        }
        if let index = stored.reviewCards.firstIndex(where: { $0.id == scheduled.id }) {
            stored.reviewCards[index] = scheduled
        } else {
            stored.reviewCards.append(scheduled)
        }
        try write(stored)
        return attempt
    }

    /// A grammar correction is not a recall rating and does not move the recognition card.
    func noteGrammarCorrection(itemId: String, senseId: String, sourceEventID: UUID) throws {
        try noteUnscheduled(itemId: itemId, senseId: senseId, task: .grammarCorrection, rating: nil, sourceEventID: sourceEventID)
    }

    /// Productive use is kept beside recognition. It does not schedule the meaning card.
    func recordProductiveUse(card: VocabularyEnrollment, rating: RecallRating, sourceEventID: UUID) throws {
        try noteUnscheduled(itemId: card.itemId, senseId: card.senseId, task: .productiveUse, rating: rating.rawValue, sourceEventID: sourceEventID)
    }

    func noteUnscheduled(itemId: String, senseId: String, task: ReviewTask, rating: String?, sourceEventID: UUID) throws {
        var stored = try document()
        let enrolled = stored.vocabularyEnrollments.contains { $0.itemId == itemId && $0.senseId == senseId }
        let recorded = Set(stored.senseCredits.map(\.id))
        let decision = ReviewCreditPolicy.decide(
            task: task, revealed: false, kind: task == .productiveUse ? .productiveUse : .recognition,
            sourceEventID: sourceEventID, alreadyRecorded: recorded, enrolled: enrolled)
        switch decision {
        case .unchanged(.duplicateEvent), .unchanged(.grammarCorrection), .unchanged(.productiveUseKeptSeparate):
            if case .unchanged(.duplicateEvent) = decision { return }
        default:
            throw VocabularyRecallError.unknownCard
        }
        guard enrolled else { throw VocabularyRecallError.unknownCard }
        let dueBefore = stored.reviewCards
        stored.senseCredits.append(SenseCreditEvent(
            id: sourceEventID, itemId: itemId, senseId: senseId, task: task.rawValue,
            cardKind: task == .productiveUse ? ReviewCardKind.productiveUse.rawValue : ReviewCardKind.recognition.rawValue,
            rating: rating, createdAt: try effectiveNow()))
        stored.reviewCards = dueBefore
        try write(stored)
    }

    @discardableResult
    func createCustomTopic(title: String, subtopic: String) throws -> CustomVocabularyTopic {
        var stored = try document()
        var library = stored.customLibrary()
        let topic = try library.createTopic(title: title, subtopic: subtopic, now: try effectiveNow())
        stored.customTopics = library.topics
        try write(stored)
        return topic
    }

    @discardableResult
    func renameCustomTopic(id: UUID, title: String, subtopic: String) throws -> CustomVocabularyTopic {
        var stored = try document()
        var library = stored.customLibrary()
        let topic = try library.renameTopic(id: id, title: title, subtopic: subtopic, now: try effectiveNow())
        stored.customTopics = library.topics
        try write(stored)
        return topic
    }

    @discardableResult
    func addCustomSense(topicID: UUID, lemma: String, note: String) throws -> CustomSenseChange {
        var stored = try document()
        var library = stored.customLibrary()
        let change = try library.addSense(topicID: topicID, lemma: lemma, note: note, now: try effectiveNow())
        guard stored.customTopics != library.topics else { return change }
        stored.customTopics = library.topics
        try write(stored)
        return change
    }

    @discardableResult
    func editCustomSense(topicID: UUID, senseID: UUID, lemma: String, note: String) throws -> CustomVocabularySense {
        var stored = try document()
        var library = stored.customLibrary()
        let sense = try library.editSense(topicID: topicID, senseID: senseID, lemma: lemma, note: note, now: try effectiveNow())
        stored.customTopics = library.topics
        stored.vocabularyEnrollments = library.enrollments
        try write(stored)
        return sense
    }

    @discardableResult
    func enrollCustomSense(topicID: UUID, senseID: UUID, inReview: Bool = true) throws -> VocabularyEnrollment {
        var stored = try document()
        var library = stored.customLibrary()
        let enrollment = try library.enroll(topicID: topicID, senseID: senseID, now: try effectiveNow(), inReview: inReview)
        if stored.vocabularyEnrollments == library.enrollments { return enrollment }
        stored.vocabularyEnrollments = library.enrollments
        try write(stored)
        return enrollment
    }

    @discardableResult
    func saveCustomSenseToCollection(topicID: UUID, senseID: UUID) throws -> VocabularyEnrollment {
        try enrollCustomSense(topicID: topicID, senseID: senseID, inReview: false)
    }

    func deleteCustomTopic(id: UUID) throws {
        var stored = try document()
        var library = stored.customLibrary()
        let before = stored.vocabularyEnrollments
        try library.deleteTopic(id: id)
        stored.customTopics = library.topics
        stored.vocabularyEnrollments = library.enrollments
        guard stored.vocabularyEnrollments.map(\.id) == before.map(\.id) else { throw LearnerStorageError.invalidState }
        try write(stored)
    }

    func recordVocabularyExposure(_ sense: CurriculumSense, lesson: ResolvedLesson) throws {
        var stored = try document()
        var collection = VocabularyCollection(enrollments: stored.vocabularyEnrollments, exposures: stored.vocabularyExposures)
        let before = collection.exposures.count
        try collection.expose(sense, lesson: lesson, now: try effectiveNow())
        guard collection.exposures.count != before else { return }
        stored.vocabularyExposures = collection.exposures
        try write(stored)
    }
}
