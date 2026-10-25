import Foundation
import Testing
@testable import SpeechCoachAI

struct VocabularyLinkTests {
    @Test func omittedSensesDecodeAsNoneAndABlankSenseBlocksOnlyThatLesson() throws {
        let json = #"{"id":"plain","contentVersion":"1","level":"A1","title":"Plain","objectiveId":"INTRO-01","activities":[]}"#
        let decoded = try JSONDecoder().decode(CurriculumLesson.self, from: Data(json.utf8))
        #expect(decoded.senses.isEmpty)

        let resolved = CurriculumAvailability.resolve(manifest: manifest, inspected: [:])
        let ready = try #require(resolved.first { $0.id == "ready" })
        #expect(ready.isReady)
        #expect(ready.senses.map(\.lemma) == ["fixture-word"])
        let blocked = try #require(resolved.first { $0.id == "blank" })
        #expect(blocked.isReady == false)
        #expect(blocked.senses.isEmpty)
    }

    @Test func oneCardPerSenseAndRecognitionDoesNotSchedule() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-T021-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, now: { date(1) }, protectedDataAvailable: { true })
        defer { repo.close() }
        let original = try repo.preferences()
        let first = try repo.enrollVocabulary(sense, lesson: readyLesson())
        let again = try repo.enrollVocabulary(
            CurriculumSense(itemId: "fixture-item", senseId: "fixture-sense", lemma: "different-lemma"),
            lesson: readyLesson(id: "other-lesson"))
        #expect(again.lessonID == "ready")
        #expect(again.lemma == "fixture-word")
        #expect(again.enrolledAt == first.enrolledAt)
        #expect(try repo.vocabularyEnrollments().count == 1)
        try repo.enrollVocabulary(CurriculumSense(itemId: "fixture-item", senseId: "other-sense", lemma: "other-word"), lesson: readyLesson())
        #expect(try repo.vocabularyEnrollments().count == 2)

        try repo.recordVocabularyExposure(sense, lesson: readyLesson())
        try repo.recordVocabularyExposure(sense, lesson: readyLesson())
        let exposures = try repo.vocabularyExposures()
        #expect(exposures.count == 1)
        let object = try JSONSerialization.jsonObject(with: JSONEncoder().encode(exposures[0])) as? [String: Any]
        #expect(object?["kind"] as? String == "recognition")
        #expect(object?["rating"] == nil)
        #expect(object?["dueAt"] == nil)
        #expect(try repo.recognitionSchedule(itemId: sense.itemId, senseId: sense.senseId) == nil)
        #expect(try repo.reviewQueue().waiting == 0)
        #expect(try repo.reviewQueue().due.count == 2)

        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) {
            try repo.enrollVocabulary(CurriculumSense(itemId: "new-item", senseId: "new-sense", lemma: "new-word"), lesson: readyLesson())
        }
        repo.beforeCommit = nil
        repo.close()
        let reopened = try LearnerRepository(root: root, now: { date(2) }, protectedDataAvailable: { true })
        defer { reopened.close() }
        #expect(try reopened.vocabularyEnrollments().count == 2)
        #expect(try reopened.preferences() == original)
        try reopened.deleteAllLearningData()
        #expect(try reopened.vocabularyEnrollments().isEmpty)
        #expect(try reopened.vocabularyExposures().isEmpty)
    }

    @Test func speakingUsesTheLessonObjectiveWithoutFinishingIt() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-T021-speak-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, now: { date(1) }, protectedDataAvailable: { true })
        defer { repo.close() }
        var session = try LessonSession.begin(lesson: readyLesson(), presenter: "elephantTeacher", now: date(1))
        try session.record(activityID: "quiet", text: "I study English.", assisted: false)
        try repo.saveLessonJourney(session.journey)

        let context = try LessonSpeakingLink.context(
            lesson: readyLesson(), defaults: try repo.preferences(), recordingObjectiveID: RecordingController.prompt.objectiveID)
        let attempt = try repo.createAttempt(prompt: RecordingController.prompt, context: context)
        #expect(attempt.sourceLessonID == "ready")
        #expect(attempt.prompt.objectiveID == "INTRO-01")
        #expect(try repo.lessonJourneys(lessonID: "ready").first?.completedAt == nil)

        #expect(throws: VocabularyLinkError.objectiveMismatch) {
            _ = try LessonSpeakingLink.context(lesson: readyLesson(objectiveId: "OTHER"), defaults: try repo.preferences(),
                                               recordingObjectiveID: RecordingController.prompt.objectiveID)
        }
        #expect(throws: VocabularyLinkError.lessonUnavailable) {
            try repo.enrollVocabulary(sense, lesson: readyLesson(ready: false))
        }
    }

    @Test func bundledLessonMeaningIsAvailableToLegacyAndNewCards() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("lesson-meaning-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { repo.close() }
        let lesson = try #require(CurriculumCatalogLoader.bundled.lessons.first { $0.id == "intro-01" })
        let sense = try #require(lesson.senses.first)
        let card = try repo.enrollVocabulary(sense, lesson: lesson)
        #expect(try repo.meaningNote(itemId: card.itemId, senseId: card.senseId) == sense.meaning)
        #expect(card.meaning != nil)
        var draft = RecallDraft(); draft.reveal()
        _ = try repo.recordVocabularyRecall(card: card, rating: .good, draft: draft)
        #expect(try repo.vocabularyRecalls().count == 1)
        #expect(CurriculumCatalogLoader.bundled.lessons.flatMap(\.senses).allSatisfy { $0.meaning?.isEmpty == false })
    }

    private var sense: CurriculumSense { CurriculumSense(itemId: "fixture-item", senseId: "fixture-sense", lemma: "fixture-word") }

    private var manifest: CurriculumManifest {
        CurriculumManifest(
            schemaVersion: 1, packId: "fixture.catalog", contentVersion: "fixture-1", locale: "en-US", minimumSchemaVersion: 1,
            editorialApprovalReference: "fixture-review-not-publication", rightsReference: "fixture-rights", assets: [],
            lessons: [
                CurriculumLesson(id: "blank", contentVersion: "1", level: "A1", title: "Blank", objectiveId: "INTRO-01",
                                 activities: [CurriculumActivity(id: "quiet", kind: "quietText", required: true, prompt: "Write one fact.")],
                                 senses: [CurriculumSense(itemId: " ", senseId: "fixture-sense", lemma: "fixture-word")]),
                CurriculumLesson(id: "ready", contentVersion: "1", level: "A1", title: "Ready", objectiveId: "INTRO-01",
                                 activities: [CurriculumActivity(id: "quiet", kind: "quietText", required: true, prompt: "Write one fact.")],
                                 senses: [sense])
            ])
    }

    private func readyLesson(id: String = "ready", objectiveId: String = "INTRO-01", ready: Bool = true) -> ResolvedLesson {
        ResolvedLesson(id: id, level: "A1", title: "Fixture", objectiveId: objectiveId, contentVersion: "1",
                       availability: ready ? .ready : .unavailable(.missingReview),
                       practiceActivities: [CurriculumActivity(id: "quiet", kind: "quietText", required: true, prompt: "Write one fact.")],
                       senses: ready ? [sense, CurriculumSense(itemId: "fixture-item", senseId: "other-sense", lemma: "other-word"),
                                        CurriculumSense(itemId: "new-item", senseId: "new-sense", lemma: "new-word")] : [])
    }

    private func date(_ day: Int) -> Date { Date(timeIntervalSince1970: TimeInterval(day) * 86_400) }
}
