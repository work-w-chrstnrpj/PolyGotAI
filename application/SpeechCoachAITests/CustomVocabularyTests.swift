import Foundation
import Testing
@testable import SpeechCoachAI

struct CustomVocabularyTests {
    @Test func savingATopicDoesNotEnrollAndRepeatedWordsStayOneCard() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-T165-\(UUID().uuidString)")
        let repo = try LearnerRepository(root: root, now: { date(1) }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        defer { repo.close() }
        let topic = try repo.createCustomTopic(title: "  Kitchen  ", subtopic: " Food ")
        #expect(topic.title == "Kitchen")
        #expect(topic.subtopic == "Food")
        #expect(try repo.vocabularyEnrollments().isEmpty)

        let first = try repo.addCustomSense(topicID: topic.id, lemma: " menu ", note: "a list of dishes")
        let repeatAdd = try repo.addCustomSense(topicID: topic.id, lemma: "menu", note: "a list of dishes")
        #expect(first.alreadyInTopic == false)
        #expect(repeatAdd.alreadyInTopic)
        #expect(repeatAdd.sense.id == first.sense.id)
        #expect(try repo.customTopics().first?.senses.count == 1)

        let other = try repo.createCustomTopic(title: "Cafe", subtopic: "")
        let shared = try repo.addCustomSense(topicID: other.id, lemma: "menu", note: "a list of dishes")
        #expect(shared.reusedIdentity)
        #expect(shared.sense.id == first.sense.id)

        let saved = try repo.enrollCustomSense(topicID: topic.id, senseID: first.sense.id)
        let savedAgain = try repo.enrollCustomSense(topicID: other.id, senseID: shared.sense.id)
        #expect(saved.objectiveID == "personal-vocabulary")
        #expect(savedAgain.id == saved.id)
        #expect(try repo.vocabularyEnrollments().count == 1)

        let edited = try repo.editCustomSense(topicID: topic.id, senseID: first.sense.id, lemma: "menu board", note: "posted list")
        #expect(edited.id == first.sense.id)
        #expect(try repo.vocabularyEnrollments().map(\.lemma) == ["menu board"])
        #expect(try repo.customTopics().flatMap(\.senses).allSatisfy { $0.lemma == "menu board" })
        let encoded = try JSONEncoder().encode(try repo.vocabularyEnrollments()[0])
        let object = try JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        #expect(object?["rating"] == nil)
        #expect(object?["dueAt"] == nil)

        let kitchen = try #require(try repo.customTopics().first { $0.title == "Kitchen" })
        _ = try repo.addCustomSense(topicID: kitchen.id, lemma: "water", note: "")
        #expect(throws: CustomVocabularyError.duplicateLemma) {
            try repo.editCustomSense(topicID: kitchen.id, senseID: first.sense.id, lemma: "water", note: "")
        }

        try repo.deleteCustomTopic(id: topic.id)
        #expect(try repo.customTopics().map(\.title) == ["Cafe"])
        #expect(try repo.vocabularyEnrollments().count == 1)
        #expect(try repo.meaningNote(itemId: saved.itemId, senseId: saved.senseId) == "posted list")
        var draft = RecallDraft()
        draft.typed = "list"
        draft.reveal()
        let rated = try repo.recordVocabularyRecall(card: saved, rating: .good, draft: draft)
        let ratedObject = try JSONSerialization.jsonObject(with: JSONEncoder().encode(rated)) as? [String: Any]
        #expect(ratedObject?["dueAt"] == nil)
        #expect(rated.succeeded)
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) {
            try repo.recordVocabularyRecall(card: saved, rating: .easy, draft: draft, sourceEventID: UUID())
        }
        repo.beforeCommit = nil
        #expect(try repo.vocabularyRecalls().count == 1)
        try repo.deleteAllLearningData()
        #expect(try repo.customTopics().isEmpty)
        #expect(try repo.vocabularyEnrollments().isEmpty)
        #expect(try repo.vocabularyRecalls().isEmpty)
    }

    @Test func aFailedSaveDoesNotCreateTheTopic() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-T165-fail-\(UUID().uuidString)")
        let repo = try LearnerRepository(root: root, now: { date(1) }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        defer { repo.close() }
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) {
            try repo.createCustomTopic(title: "Travel", subtopic: "")
        }
        repo.beforeCommit = nil
        #expect(try repo.customTopics().isEmpty)
        #expect(throws: CustomVocabularyError.tooLong) {
            try repo.createCustomTopic(title: String(repeating: "a", count: 81), subtopic: "")
        }
        #expect(throws: CustomVocabularyError.blankTitle) {
            try repo.createCustomTopic(title: "   ", subtopic: "Anywhere")
        }
    }

    @Test func identicalSpellingKeepsDifferentMeaningsAndCollectionSurvivesTopicDeletion() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("sense-recovery-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { repo.close() }
        let topic = try repo.createCustomTopic(title: "Everyday", subtopic: "")
        let financial = try repo.addCustomSense(topicID: topic.id, lemma: "bank", note: "A business that keeps money")
        let river = try repo.addCustomSense(topicID: topic.id, lemma: "bank", note: "The ground beside a river")
        #expect(financial.sense.id != river.sense.id)
        let card = try repo.enrollCustomSense(topicID: topic.id, senseID: river.sense.id)
        try repo.deleteCustomTopic(id: topic.id)
        #expect(try repo.meaningNote(itemId: card.itemId, senseId: card.senseId) == "The ground beside a river")
        #expect(try repo.vocabularyEnrollments().count == 1)
        var draft = RecallDraft(); draft.reveal()
        _ = try repo.recordVocabularyRecall(card: card, rating: .good, draft: draft)
        #expect(try repo.recognitionSchedule(itemId: card.itemId, senseId: card.senseId) != nil)
    }

    @Test func missingMeaningCannotCreateAReviewRating() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("meaning-required-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { repo.close() }
        let topic = try repo.createCustomTopic(title: "Unfinished", subtopic: "")
        let word = try repo.addCustomSense(topicID: topic.id, lemma: "bank", note: "")
        let card = try repo.enrollCustomSense(topicID: topic.id, senseID: word.sense.id)
        var draft = RecallDraft(); draft.reveal()
        #expect(throws: VocabularyRecallError.missingMeaning) { try repo.recordVocabularyRecall(card: card, rating: .good, draft: draft) }
        #expect(try repo.vocabularyRecalls().isEmpty)
    }

    @Test func searchFindsUnenrolledMeaningsSubtopicsAndAccentedWords() throws {
        var library = CustomVocabularyLibrary(topics: [], enrollments: [])
        let topic = try library.createTopic(title: "Travel", subtopic: "Ordering food", now: date(1))
        _ = try library.addSense(topicID: topic.id, lemma: "café", note: "a place for coffee", now: date(1))
        let saved = try #require(library.topics.first)
        #expect(VocabularySearch.matches("  CAFE coffee  ", topic: saved))
        #expect(VocabularySearch.matches("food", topic: saved))
        #expect(VocabularySearch.matches(" \n ", topic: saved))
        #expect(!VocabularySearch.matches("coffee airport", topic: saved))
        #expect(library.enrollments.isEmpty)
    }

    @Test func refreshingWordsKeepsUnsavedTopicDetailsUntilExplicitSaveOrDiscard() throws {
        var library = CustomVocabularyLibrary(topics: [], enrollments: [])
        let topic = try library.createTopic(title: "Kitchen", subtopic: "", now: date(1))
        var draft = CustomTopicDetailsDraft()
        draft.refresh(topic)
        draft.title = "Cafe"
        draft.subtopic = "Breakfast"
        _ = try library.addSense(topicID: topic.id, lemma: "menu", note: "a list of dishes", now: date(1))
        draft.refresh(try #require(library.topics.first))
        #expect(draft.title == "Cafe")
        #expect(draft.subtopic == "Breakfast")
        #expect(draft.isDirty)
        let saved = try library.renameTopic(id: topic.id, title: draft.title, subtopic: draft.subtopic, now: date(2))
        draft.accept(saved)
        #expect(!draft.isDirty)
        draft.title = "Discard me"
        draft.accept(saved)
        #expect(draft.title == "Cafe")
        #expect(!draft.isDirty)
    }

    @Test func invalidRenameLeavesBothFieldsAndTimestampUnchanged() throws {
        var library = CustomVocabularyLibrary(topics: [], enrollments: [])
        let topic = try library.createTopic(title: "Kitchen", subtopic: "Food", now: date(1))
        #expect(throws: CustomVocabularyError.tooLong) {
            try library.renameTopic(id: topic.id, title: "Changed", subtopic: String(repeating: "x", count: 81), now: date(2))
        }
        #expect(library.topics == [topic])
    }

    private func date(_ day: Int) -> Date { Date(timeIntervalSince1970: TimeInterval(day) * 86_400) }
}
