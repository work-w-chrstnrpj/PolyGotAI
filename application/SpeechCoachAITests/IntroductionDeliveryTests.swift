import CryptoKit
import Foundation
import Testing
@testable import SpeechCoachAI

struct IntroductionDeliveryTests {
    private func current() throws -> ResolvedLesson {
        try #require(CurriculumCatalogLoader.bundled.lessons.first { $0.id == "intro-01" })
    }

    @Test func minimumCoreAndQuietFollowUpKeepTheSameOutcome() throws {
        let lesson = try current()
        #expect(lesson.contentVersion == "4")
        #expect(lesson.practiceActivities.filter { $0.kind == "reading" }.count == 3)
        #expect(lesson.practiceActivities.filter { $0.kind == "listening" }.count == 3)
        #expect(lesson.practiceActivities.filter { $0.kind == "grammar" }.count == 5)
        #expect(lesson.practiceActivities.filter { $0.kind == "recall" }.count == 5)
        #expect(lesson.sessionActivities.count == 18)
        let quiet = try #require(lesson.practiceActivities.first { $0.id == "quiet-intro" })
        #expect(quiet.alternativeToActivityID == "guided-intro")
        #expect(quiet.prompt?.contains("Then answer:") == true)
        #expect(quiet.prompt?.contains("question back") == false)
        #expect(lesson.senses.count == 5)
    }

    @Test func guideBindsAllPracticeItemsAndNeverLeaksReservedOrUnrevealedAnswers() throws {
        let lesson = try current()
        let guide = try #require(IntroductionReviewGuide.bundled)
        #expect(Set(guide.activities.map(\.id)) == Set(lesson.practiceActivities.map(\.id)))
        #expect(Set(guide.activities.map(\.id)).isDisjoint(with: Set(lesson.reservedActivities.map(\.id))))
        for activity in lesson.practiceActivities {
            #expect(guide.review(activityID: activity.id, lessonID: lesson.id, contentVersion: "4", revealed: false) == nil)
            #expect(guide.review(activityID: activity.id, lessonID: lesson.id, contentVersion: "3", revealed: true) == nil)
            #expect(guide.review(activityID: activity.id, lessonID: "other", contentVersion: "4", revealed: true) == nil)
            #expect(guide.review(activityID: activity.id, lessonID: lesson.id, contentVersion: "4", revealed: true) != nil)
        }
        for reserved in lesson.reservedActivities {
            #expect(guide.review(activityID: reserved.id, lessonID: lesson.id, contentVersion: "4", revealed: true) == nil)
        }
        #expect(guide.reviewState == "personalUseDraft")
        #expect(guide.dimensions.first { $0.id == "intelligibility" }?.notAssessed.contains("Text") == true)
    }

    @Test func reviewAssetMatchesManifestAndOriginalAudioRemainsUnchanged() throws {
        let manifestURL = try #require(Bundle.main.url(forResource: "CurriculumCatalog", withExtension: "json"))
        let manifest = try JSONDecoder().decode(CurriculumManifest.self, from: Data(contentsOf: manifestURL))
        let guideAsset = try #require(manifest.assets.first { $0.id == "intro-01-review-guide" })
        let data = try Data(contentsOf: try #require(Bundle.main.url(forResource: "IntroductionReviewGuide", withExtension: "json")))
        #expect(guideAsset.byteCount == data.count)
        #expect(guideAsset.sha256 == SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined())
        let audio = try #require(manifest.assets.first { $0.id == "intro-01-listen-alex" })
        #expect(audio.sha256 == "e059e4a8a078787000fdc9e2cf050f51cd1e8e92aad940a0894566d16f8ea894")
    }

    @Test func oldIntroJourneyReopensItsExactContentAndCannotCompleteTheNewVersion() throws {
        let catalog = CurriculumCatalogLoader.bundled
        let previous = try #require(catalog.lesson(id: "intro-01", version: "3"))
        #expect(previous.isReady)
        #expect(catalog.lesson(id: "intro-01", version: "2")?.isReady == true)
        var old = try LessonSession.begin(lesson: previous, presenter: "synthetic", now: .now)
        try old.saveDraft("Synthetic original draft", for: "read-mina")
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-D002-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        var repository: LearnerRepository? = try LearnerRepository(root: root, protectedDataAvailable: { true })
        try repository?.saveLessonJourney(old.journey)
        repository?.close(); repository = nil
        let reopened = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { reopened.close() }
        let saved = try reopened.lessonJourneys(lessonID: "intro-01")
        let opening = try catalog.opening(try current(), saved: saved)
        #expect(opening.lesson.contentVersion == "3")
        #expect(opening.journey?.drafts?["read-mina"] == "Synthetic original draft")
        #expect(opening.journey?.id == old.journey.id)
        #expect(throws: LessonProgressError.versionMismatch) {
            try LessonSession.begin(lesson: current(), presenter: "synthetic", now: .now, existing: old.journey)
        }
        #expect(try reopened.lessonJourneys(lessonID: "intro-01").allSatisfy { $0.contentVersion == "3" && $0.completedAt == nil })
    }

    @Test func allPresentersKeepTheSameRequiredCourseAndGuideDoesNotGrade() throws {
        let lesson = try current()
        for coach in LearnerPreferences.Coach.allCases {
            let session = try LessonSession.begin(lesson: lesson, presenter: coach.rawValue, now: .now)
            #expect(session.activities == lesson.sessionActivities)
            #expect(session.journey.objectiveID == "INTRO-01")
            #expect(session.journey.completedAt == nil && session.journey.responses.isEmpty)
        }
        let guide = try #require(IntroductionReviewGuide.bundled)
        for pack in IntroPracticePack.allCases {
            let review = try #require(guide.pack(id: pack.id, version: pack.lesson.contentVersion))
            #expect(review.objectiveID == pack.lesson.objectiveId)
            #expect(!review.method.isEmpty && !review.priorities.isEmpty && !review.criteria.isEmpty)
            #expect(guide.pack(id: pack.id, version: "unknown") == nil)
        }
        #expect(guide.packs.first { $0.id == "journalist" }?.boundary.contains("reading-based") == true)
    }

    @Test func assessmentSourceAndTeachingExposureAreFrozenWithoutRelabelingOlderChecks() throws {
        let course = try LessonSession.begin(lesson: current(), presenter: "synthetic", now: .now)
        let first = IntroCheckSnapshot.begin(kind: .baseline, course: course.journey, previous: [], now: .now,
            supported: false, retainedText: false, interveningPractice: "")
        #expect(first.sourceContentVersion == "4")
        #expect(first.teachingMayHaveBeenSeen == false)
        var taught = course
        taught.journey.teachingBeganAt = .now
        let later = IntroCheckSnapshot.begin(kind: .baseline, course: taught.journey, previous: [], now: .now,
            supported: false, retainedText: false, interveningPractice: "")
        #expect(later.teachingMayHaveBeenSeen == true)
        #expect(later.priorExposure == false) // Prompt repetition and teaching exposure remain different.
        let frozen = try JSONDecoder().decode(IntroCheckSnapshot.self, from: JSONEncoder().encode(first))
        #expect(frozen.teachingMayHaveBeenSeen == false)
        var old = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(first)) as? [String: Any])
        old.removeValue(forKey: "teachingMayHaveBeenSeen"); old.removeValue(forKey: "sourceContentVersion")
        let legacy = try JSONDecoder().decode(IntroCheckSnapshot.self, from: JSONSerialization.data(withJSONObject: old))
        #expect(legacy.sourceContentVersion == nil && legacy.teachingMayHaveBeenSeen == nil)
    }

    @Test func comparisonIsRequiredWithoutAnAccuracyGateAndOldCompletionStaysUnchanged() throws {
        var session = try LessonSession.begin(lesson: current(), presenter: "synthetic", now: .now)
        for activity in session.activities {
            try session.record(activityID: activity.id, text: "Deliberately incorrect synthetic response", assisted: false)
        }
        #expect(throws: LessonProgressError.unfinished) { try session.finish(now: .now) }
        for activity in session.activities where session.needsComparison(activity.id) {
            _ = try session.revealAnswer(activityID: activity.id)
        }
        try session.finish(now: .now)
        #expect(session.journey.completedAt != nil)
        #expect(session.journey.responses.allSatisfy { $0.firstResponseText == "Deliberately incorrect synthetic response" })
        let prior = try #require(CurriculumCatalogLoader.bundled.lesson(id: "intro-01", version: "3"))
        var old = try LessonSession.begin(lesson: prior, presenter: "synthetic", now: .now)
        for activity in old.activities { try old.record(activityID: activity.id, text: "Synthetic legacy attempt", assisted: false) }
        try old.finish(now: .now)
        #expect(old.journey.completedAt != nil)
    }

    @Test func malformedOrApprovalShapedGuideIsRejected() throws {
        let guide = try #require(IntroductionReviewGuide.bundled)
        var invalid = guide
        invalid.reviewState = "approved"
        #expect(throws: LearnerStorageError.invalidContent) { try IntroductionReviewGuide.decode(JSONEncoder().encode(invalid)) }
        invalid = guide
        invalid.activities[1] = invalid.activities[0]
        #expect(throws: LearnerStorageError.invalidContent) { try IntroductionReviewGuide.decode(JSONEncoder().encode(invalid)) }
        invalid = guide
        invalid.sourceContentVersion = "3"
        #expect(throws: LearnerStorageError.invalidContent) { try IntroductionReviewGuide.decode(JSONEncoder().encode(invalid)) }
    }
}
