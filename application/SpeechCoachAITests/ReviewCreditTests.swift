import Foundation
import Testing
import SwiftData
@testable import SpeechCoachAI

struct ReviewCreditTests {
    @Test func onlyAnExplicitRevealedRatingSchedules() {
        let event = UUID()
        #expect(ReviewCreditPolicy.decide(task: .explicitRating, revealed: true, kind: .recognition, sourceEventID: event, alreadyRecorded: [], enrolled: true) == .schedule)
        #expect(ReviewCreditPolicy.decide(task: .explicitRating, revealed: false, kind: .recognition, sourceEventID: event, alreadyRecorded: [], enrolled: true) == .unchanged(.answerHidden))
        #expect(ReviewCreditPolicy.decide(task: .lessonExposure, revealed: true, kind: .recognition, sourceEventID: event, alreadyRecorded: [], enrolled: true) == .unchanged(.lessonExposure))
        #expect(ReviewCreditPolicy.decide(task: .grammarCorrection, revealed: true, kind: .recognition, sourceEventID: event, alreadyRecorded: [], enrolled: true) == .unchanged(.grammarCorrection))
        #expect(ReviewCreditPolicy.decide(task: .productiveUse, revealed: true, kind: .productiveUse, sourceEventID: event, alreadyRecorded: [], enrolled: true) == .unchanged(.productiveUseKeptSeparate))
        #expect(ReviewCreditPolicy.decide(task: .explicitRating, revealed: true, kind: .recognition, sourceEventID: event, alreadyRecorded: [event], enrolled: true) == .unchanged(.duplicateEvent))
        #expect(ReviewCreditPolicy.decide(task: .explicitRating, revealed: true, kind: .recognition, sourceEventID: event, alreadyRecorded: [], enrolled: false) == .unchanged(.missingSense))
    }

    @Test func anEditedWordingKeepsTheCardAndANewSenseDoesNotInheritIt() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-T047-\(UUID().uuidString)")
        var clock = date(10)
        let repo = try LearnerRepository(root: root, now: { clock }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        defer { repo.close() }
        let topic = try repo.createCustomTopic(title: "Kitchen", subtopic: "")
        let sense = try repo.addCustomSense(topicID: topic.id, lemma: "menu", note: "a list of dishes")
        let saved = try repo.enrollCustomSense(topicID: topic.id, senseID: sense.sense.id)
        let again = try repo.enrollCustomSense(topicID: topic.id, senseID: sense.sense.id)
        #expect(again.id == saved.id)
        #expect(try repo.vocabularyEnrollments().count == 1)

        var draft = RecallDraft()
        draft.hint()
        draft.reveal()
        let event = UUID()
        let rated = try repo.recordVocabularyRecall(card: saved, rating: .good, draft: draft, sourceEventID: event)
        #expect(rated.assistance == "hint")
        #expect(rated.unaided == false)
        let due = try #require(try repo.recognitionSchedule(itemId: saved.itemId, senseId: saved.senseId)).due
        let repeated = try repo.recordVocabularyRecall(card: saved, rating: .easy, draft: draft, sourceEventID: event)
        #expect(repeated.id == rated.id)
        #expect(try repo.vocabularyRecalls().count == 1)
        #expect(try repo.recognitionSchedule(itemId: saved.itemId, senseId: saved.senseId)?.due == due)

        let edited = try repo.editCustomSense(topicID: topic.id, senseID: sense.sense.id, lemma: "menu board", note: "posted list")
        #expect(ReviewCreditPolicy.sameSense(itemId: saved.itemId, senseId: saved.senseId, otherItemId: edited.itemId, otherSenseId: edited.senseId))
        #expect(try repo.recognitionSchedule(itemId: edited.itemId, senseId: edited.senseId)?.due == due)

        let other = try repo.addCustomSense(topicID: topic.id, lemma: "water", note: "a drink")
        let otherCard = try repo.enrollCustomSense(topicID: topic.id, senseID: other.sense.id)
        #expect(ReviewCreditPolicy.sameSense(itemId: saved.itemId, senseId: saved.senseId, otherItemId: otherCard.itemId, otherSenseId: otherCard.senseId) == false)
        #expect(try repo.recognitionSchedule(itemId: otherCard.itemId, senseId: otherCard.senseId) == nil)

        try repo.noteGrammarCorrection(itemId: saved.itemId, senseId: saved.senseId, sourceEventID: UUID())
        try repo.noteGrammarCorrection(itemId: saved.itemId, senseId: saved.senseId, sourceEventID: try #require(try repo.senseCredits().first?.id))
        #expect(try repo.senseCredits().count == 1)
        #expect(try repo.recognitionSchedule(itemId: saved.itemId, senseId: saved.senseId)?.due == due)

        let use = UUID()
        try repo.recordProductiveUse(card: saved, rating: .good, sourceEventID: use)
        try repo.recordProductiveUse(card: saved, rating: .easy, sourceEventID: use)
        #expect(try repo.senseCredits().filter { $0.task == "productiveUse" }.count == 1)
        #expect(try repo.recognitionSchedule(itemId: saved.itemId, senseId: saved.senseId)?.due == due)
        #expect(try repo.reviewQueue().waiting == 1)
        #expect(try repo.reviewQueue().due.map(\.id) == [otherCard.id])

        clock = due.addingTimeInterval(86_400)
        let later = UUID()
        _ = try repo.recordVocabularyRecall(card: saved, rating: .good, draft: draft, sourceEventID: later)
        #expect(try repo.recognitionSchedule(itemId: saved.itemId, senseId: saved.senseId)?.due != due)

        let orphan = ReviewQueue.plan(enrollments: [], cards: [try #require(try repo.recognitionSchedule(itemId: saved.itemId, senseId: saved.senseId))], now: clock)
        #expect(orphan.due.isEmpty)
        #expect(orphan.waiting == 0)
    }

    @Test func aCollectionSaveIsNotDueAndAnInterruptedRevealIsNotRated() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-T048-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, now: { date(3) }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        let topic = try repo.createCustomTopic(title: "Kitchen", subtopic: "")
        let sense = try repo.addCustomSense(topicID: topic.id, lemma: "menu", note: "a list of dishes")
        let kept = try repo.saveCustomSenseToCollection(topicID: topic.id, senseID: sense.sense.id)
        #expect(kept.inReview == false)
        #expect(try repo.reviewQueue().due.isEmpty)
        #expect(try repo.recognitionSchedule(itemId: kept.itemId, senseId: kept.senseId) == nil)
        let added = try repo.enrollCustomSense(topicID: topic.id, senseID: sense.sense.id)
        let again = try repo.saveCustomSenseToCollection(topicID: topic.id, senseID: sense.sense.id)
        #expect(added.id == kept.id)
        #expect(again.inReview)
        #expect(try repo.vocabularyEnrollments().count == 1)
        #expect(try repo.reviewQueue().due.map(\.id) == [added.id])

        let legacyJSON = try JSONSerialization.jsonObject(with: JSONEncoder().encode(added)) as? [String: Any]
        var legacyObject = try #require(legacyJSON)
        legacyObject.removeValue(forKey: "inReview")
        let legacy = try JSONDecoder().decode(VocabularyEnrollment.self, from: JSONSerialization.data(withJSONObject: legacyObject))
        #expect(legacy.inReview)

        var draft = RecallDraft()
        draft.typed = "a list of dishes"
        #expect(throws: VocabularyRecallError.unknownCard) {
            try repo.stageOpenRecall(card: VocabularyEnrollment(
                itemId: "missing", senseId: "missing", lemma: "missing", lessonID: "topic",
                objectiveID: "personal-vocabulary", contentVersion: "personal", enrolledAt: date(3), inReview: false), draft: draft)
        }
        draft.reveal()
        try repo.stageOpenRecall(card: added, draft: draft)
        #expect(try repo.vocabularyRecalls().isEmpty)
        #expect(try repo.recognitionSchedule(itemId: added.itemId, senseId: added.senseId) == nil)
        repo.close()

        let reopened = try LearnerRepository(root: root, now: { date(4) }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        defer { reopened.close() }
        let open = try #require(try reopened.openRecall())
        #expect(open.revealed)
        #expect(open.firstResponse == "a list of dishes")
        #expect(try reopened.vocabularyRecalls().isEmpty)
        reopened.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) {
            try reopened.recordVocabularyRecall(card: added, rating: .good, draft: draft)
        }
        reopened.beforeCommit = nil
        #expect(try reopened.openRecall() != nil)
        #expect(try reopened.vocabularyRecalls().isEmpty)
        _ = try reopened.recordVocabularyRecall(card: added, rating: .good, draft: draft)
        #expect(try reopened.openRecall() == nil)
        #expect(try reopened.vocabularyRecalls().count == 1)
    }

    @Test func hiddenDraftAndRevealSurviveRestartWithOneStableRating() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("recall-recovery-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        var clock = date(10)
        var repo = try LearnerRepository(root: root, now: { clock }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        defer { repo.close() }
        let topic = try repo.createCustomTopic(title: "Kitchen", subtopic: "")
        let sense = try repo.addCustomSense(topicID: topic.id, lemma: "menu", note: "a list of dishes")
        let card = try repo.enrollCustomSense(topicID: topic.id, senseID: sense.sense.id)
        var draft = RecallDraft(typed: "my unfinished answer")
        try repo.stageOpenRecall(card: card, draft: draft)
        let event = draft.sourceEventID
        repo.close()
        repo = try LearnerRepository(root: root, now: { clock }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        draft = RecallDraft(try #require(try repo.openRecall()))
        #expect(draft.sourceEventID == event)
        #expect(draft.typed == "my unfinished answer")
        #expect(!draft.revealed)
        #expect(try repo.vocabularyRecalls().isEmpty)
        #expect(throws: VocabularyRecallError.stillHidden) {
            try repo.recordVocabularyRecall(card: card, rating: .good, draft: draft)
        }
        draft.typed = "a list of dishes"
        draft.reveal()
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) { try repo.stageOpenRecall(card: card, draft: draft) }
        repo.beforeCommit = nil
        #expect(try repo.openRecall()?.revealed == false)
        try repo.stageOpenRecall(card: card, draft: draft)
        repo.close()
        clock = date(8) // The repository's persisted clock prevents a backward review instant.
        repo = try LearnerRepository(root: root, now: { clock }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        draft = RecallDraft(try #require(try repo.openRecall()))
        #expect(draft.sourceEventID == event)
        #expect(draft.revealed)
        #expect(draft.firstResponse == "a list of dishes")
        var edited = RecallDraft(typed: "answer after reveal", mode: .say, sourceEventID: event)
        edited.reveal()
        try repo.stageOpenRecall(card: card, draft: edited)
        #expect(try repo.openRecall()?.firstResponse == "a list of dishes")
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) { try repo.recordVocabularyRecall(card: card, rating: .good, draft: draft) }
        repo.beforeCommit = nil
        #expect(try repo.vocabularyRecalls().isEmpty)
        #expect(try repo.openRecall()?.sourceEventID == event)
        let rated = try repo.recordVocabularyRecall(card: card, rating: .good, draft: edited)
        #expect(rated.typedAttempt == "a list of dishes")
        #expect(rated.modality == "text")
        #expect(rated.createdAt >= date(10))
        let schedule = try repo.recognitionSchedule(itemId: card.itemId, senseId: card.senseId)
        repo.close()
        repo = try LearnerRepository(root: root, now: { date(12) }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        let duplicate = try repo.recordVocabularyRecall(card: card, rating: .easy, draft: draft)
        #expect(duplicate == rated)
        #expect(try repo.recognitionSchedule(itemId: card.itemId, senseId: card.senseId) == schedule)
        #expect(try repo.vocabularyRecalls().count == 1)
        #expect(try repo.openRecall() == nil)
        #expect(throws: VocabularyRecallError.staleEvent) { try repo.stageOpenRecall(card: card, draft: draft) }
        let other = try repo.addCustomSense(topicID: topic.id, lemma: "water", note: "a drink")
        let otherCard = try repo.enrollCustomSense(topicID: topic.id, senseID: other.sense.id)
        #expect(throws: VocabularyRecallError.staleEvent) { try repo.recordVocabularyRecall(card: otherCard, rating: .good, draft: draft) }
    }

    @Test func clearingAnOlderDraftCannotClearTheCurrentOne() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("recall-clear-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, now: { date(3) }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        defer { repo.close() }
        let topic = try repo.createCustomTopic(title: "Kitchen", subtopic: "")
        let sense = try repo.addCustomSense(topicID: topic.id, lemma: "menu", note: "a list of dishes")
        let card = try repo.enrollCustomSense(topicID: topic.id, senseID: sense.sense.id)
        let current = RecallDraft(mode: .say)
        try repo.stageOpenRecall(card: card, draft: current)
        try repo.clearOpenRecall(sourceEventID: UUID())
        #expect(try repo.openRecall()?.sourceEventID == current.sourceEventID)
        try repo.clearOpenRecall(sourceEventID: current.sourceEventID)
        #expect(try repo.openRecall() == nil)
        #expect(try repo.vocabularyRecalls().isEmpty)
    }

    @Test func legacyRevealedDraftGetsOneDurableIdentityAndCanBeSkipped() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("recall-legacy-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        var repo = try LearnerRepository(root: root, now: { date(3) }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        defer { repo.close() }
        let topic = try repo.createCustomTopic(title: "Kitchen", subtopic: "")
        let sense = try repo.addCustomSense(topicID: topic.id, lemma: "menu", note: "a list of dishes")
        let card = try repo.enrollCustomSense(topicID: topic.id, senseID: sense.sense.id)
        var draft = RecallDraft(typed: "a list")
        draft.reveal()
        try repo.stageOpenRecall(card: card, draft: draft)
        repo.close()
        try makeLegacyOpenRecall(root)
        repo = try LearnerRepository(root: root, now: { date(4) }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) { try repo.openRecall() }
        repo.beforeCommit = nil
        let resumed = try #require(try repo.openRecall())
        let event = try #require(resumed.sourceEventID)
        #expect(resumed.revealed)
        #expect(resumed.firstResponse == "a list")
        #expect(resumed.mode == nil)
        repo.close()
        repo = try LearnerRepository(root: root, now: { date(4) }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        #expect(try repo.openRecall()?.sourceEventID == event)
        try repo.clearOpenRecall(sourceEventID: event)
        #expect(try repo.openRecall() == nil)
        #expect(try repo.vocabularyRecalls().isEmpty)
        #expect(try repo.recognitionSchedule(itemId: card.itemId, senseId: card.senseId) == nil)
    }

    /// Synthetic old-version payload in a temporary test store, never the learner's store.
    private func makeLegacyOpenRecall(_ root: URL) throws {
        let schema = Schema(versionedSchema: LearnerSchemaV1.self)
        let configuration = ModelConfiguration(root.lastPathComponent, schema: schema,
            url: root.appendingPathComponent("learner.store"), allowsSave: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, migrationPlan: LearnerMigrationPlan.self, configurations: [configuration])
        let context = ModelContext(container)
        let row = try #require(try context.fetch(FetchDescriptor<LearnerSchemaV1.StateRow>()).first)
        var object = try #require(try JSONSerialization.jsonObject(with: row.preferences) as? [String: Any])
        var open = try #require(object["openRecall"] as? [String: Any])
        open.removeValue(forKey: "sourceEventID")
        open.removeValue(forKey: "mode")
        object["openRecall"] = open
        row.preferences = try JSONSerialization.data(withJSONObject: object)
        try context.save()
    }

    private func date(_ day: Int) -> Date { Date(timeIntervalSince1970: TimeInterval(day) * 86_400) }
}
