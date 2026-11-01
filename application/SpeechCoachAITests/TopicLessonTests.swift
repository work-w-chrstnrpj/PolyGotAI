import Foundation
import Testing
@testable import SpeechCoachAI

struct TopicLessonTests {
    private let install = CurriculumCatalogLoader.bundled

    @Test func everyCoachHasTopicReadingExamplesAndPractice() throws {
        #expect(install.tracks.tracks.count == 11)
        #expect(install.tracks.lessons.count == 170)
        for lesson in install.tracks.lessons {
            let pages = try #require(lesson.reading, "\(lesson.id) has reading")
            #expect(pages.count >= 2)
            #expect(pages.allSatisfy { $0.isValid })
            #expect(Set(pages.map(\.id)).count == pages.count)
            #expect((15...20).contains(lesson.sessionActivities.count))
            #expect(lesson.sessionActivities.filter { $0.resolvedExercise.isChecked }.count >= 15)
            #expect(lesson.sessionActivities.filter { $0.resolvedExercise.isChecked }.allSatisfy { !($0.explanation ?? "").isEmpty })
        }
        #expect(install.lessons.allSatisfy { $0.reading == nil }, "Course remains unchanged")
    }

    @Test func oldTrackLessonsResolveExactlyAndNeverBecomeCurrentCredit() throws {
        #expect(install.tracks.archivedLessons.count == 296)
        let archived = try #require(install.lesson(id: "gram-s-nouns", version: "1"))
        #expect(archived.title == "Nouns: common and proper")
        #expect(archived.reading == nil)
        let current = try #require(install.tracks.lessons.first { $0.title == "Nouns" })
        var old = try LessonSession.begin(lesson: archived, presenter: "synthetic", now: .now).journey
        let opening = try install.opening(archived, saved: [old])
        #expect(opening.lesson == archived)
        #expect(opening.journey?.id == old.id)
        #expect(install.tracks.continueLesson(journeys: [old])?.lesson == archived)
        old.completedAt = .now
        let track = try #require(install.tracks.track(id: "grammarian"))
        #expect(track.completedFraction(journeys: [old]) == 0)
        #expect(LessonProgress.of(current, journeys: [old]).state == .new)
        #expect(install.lesson(id: archived.id, version: "missing") == nil)
        #expect(Set(install.tracks.lessons.map(\.id)).isDisjoint(with: Set(install.tracks.archivedLessons.map(\.id))))
    }

    @Test func readingCheckpointAndAnswersSurviveRepositoryReopen() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("topic-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let lesson = try #require(install.tracks.lessons.first { $0.title == "Nouns" })
        var session = try LessonSession.begin(lesson: lesson, presenter: "synthetic", now: .now)
        session.journey.readingPageIndex = 2
        try repository.saveLessonJourney(session.journey)
        repository.close()
        let reopened = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { reopened.close() }
        let saved = try #require(try reopened.lessonJourneys(lessonID: lesson.id).first)
        #expect(saved.readingPageIndex == 2)
        #expect(saved.responses.isEmpty)
        #expect(saved.completedAt == nil)
        var resumed = try LessonSession.begin(lesson: lesson, presenter: "synthetic", now: .now, existing: saved)
        resumed.journey.readingPageIndex = lesson.reading?.count
        resumed.journey.readingCompletedAt = .now
        let activity = try #require(resumed.activities.first)
        let response = try #require(activity.resolvedExercise.accepted?.first)
        try resumed.record(activityID: activity.id, text: response, assisted: false)
        let answers = resumed.journey.responses
        resumed.journey.readingPageIndex = 0 // rereading does not erase responses
        try reopened.saveLessonJourney(resumed.journey)
        let stored = try #require(try reopened.lessonJourneys(lessonID: lesson.id).first)
        #expect(stored.responses == answers)
        #expect(stored.readingCompletedAt != nil)
    }

    @Test func malformedReadingFailsClosed() throws {
        let packURL = try #require(Bundle.main.url(forResource: "track-business", withExtension: "json"))
        let data = try Data(contentsOf: packURL)
        var manifest = try JSONDecoder().decode(CurriculumManifest.self, from: data)
        #expect(manifest.lessons.first?.reading != nil)
        manifest.lessons[0].reading?[0].explanation = " "
        let resolved = CurriculumAvailability.resolve(manifest: manifest, inspected: [:])
        #expect(resolved.first?.isReady == false)
        #expect(resolved.first?.reading == nil)
    }

    @Test func oldJourneyDecodingAndInvalidCheckpointAreSafe() throws {
        let old = try #require(install.tracks.archivedLessons.first)
        let session = try LessonSession.begin(lesson: old, presenter: "synthetic", now: .now)
        let data = try JSONEncoder().encode(session.journey)
        let decoded = try JSONDecoder().decode(LessonJourney.self, from: data)
        #expect(decoded.readingPageIndex == nil)
        #expect(decoded.readingCompletedAt == nil)
        #expect(LessonReading.resumeIndex(nil, count: 3) == 0)
        #expect(LessonReading.resumeIndex(-1, count: 3) == 0)
        #expect(LessonReading.resumeIndex(100, count: 3) == 0)
        #expect(LessonReading.resumeIndex(3, count: 3) == 3)
    }

    /// Phase 12: the Pronunciation coach is second, and every lesson mixes voice, listening and sound questions.
    @Test func pronunciationCoachHasSpeakListenAndQuestionItems() throws {
        let track = try #require(install.tracks.track(id: "pronunciation"))
        #expect(install.tracks.tracks.map(\.id).prefix(2) == ["grammarian", "pronunciation"])
        #expect(track.lessons.count == 12)
        for lesson in track.lessons {
            let checked = lesson.sessionActivities.map(\.resolvedExercise).filter(\.isChecked)
            #expect((15...18).contains(checked.count), "\(lesson.id)")
            #expect(checked.allSatisfy { $0.problem() == nil }, "\(lesson.id)")
            #expect(checked.contains { $0.kind == .choice }, "\(lesson.id)")
        }
        let speak = track.lessons.flatMap(\.sessionActivities).map(\.resolvedExercise).filter { $0.kind == .speak }
        #expect(speak.count >= 70)
        #expect(speak.allSatisfy { $0.audioText == $0.modelAnswer })
    }

    /// A say-it answer counts when the phone hears the word or phrase as whole words, and not the other word of the pair.
    @Test func speakAnswersMatchWholeWords() {
        let spec = ExerciseSpec(type: "speak", accepted: ["sheep"], audioText: "sheep")
        #expect(spec.evaluate(.text("Sheep")) == .correct)
        #expect(spec.evaluate(.text("a sheep.")) == .correct)
        #expect(spec.evaluate(.text("ship")) == .incorrect)
        #expect(spec.evaluate(.text("sheepdog")) == .incorrect)
        #expect(spec.evaluate(.text("")) == .incorrect)
        let phrase = ExerciseSpec(type: "speak", accepted: ["a cup of tea"], audioText: "a cup of tea")
        #expect(phrase.evaluate(.text("A cup of tea, please")) == .correct)
        #expect(phrase.evaluate(.text("a cup of coffee")) == .incorrect)
    }
}
