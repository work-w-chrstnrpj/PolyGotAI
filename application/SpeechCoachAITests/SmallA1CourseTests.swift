import Foundation
import Testing
@testable import SpeechCoachAI

struct SmallA1CourseTests {
    @Test func approvedPersonalUseLessonsStayReadyAndSeparate() throws {
        let install = CurriculumCatalogLoader().loadBundled()
        // Resolve the approved revision, including its archived pack, rather than
        // silently substituting the newest curriculum with the same lesson ID.
        let approved = try PersonalUseA1Course.lessons.map { item in
            try #require(install.lesson(id: item.id, version: item.contentVersion))
        }
        #expect(PersonalUseA1Course.lessons.map(\.id) == ["family-01", "routine-01", "food-01"])
        #expect(approved.map(\.contentVersion) == ["2", "2", "2"])
        #expect(approved.map(\.objectiveId) == ["FAMILY-01", "ROUTINE-01", "FOOD-01"])
        #expect(approved.allSatisfy { $0.isReady && PersonalUseA1Course.contains($0) })
        for lesson in approved {
            var otherRevision = lesson
            otherRevision.contentVersion = "unapproved-revision"
            #expect(!PersonalUseA1Course.contains(otherRevision))
            if let latest = install.lessons.first(where: { $0.id == lesson.id }), latest.contentVersion != lesson.contentVersion {
                #expect(!PersonalUseA1Course.contains(latest))
                #expect(install.archivedLessons.contains(lesson))
            }
        }

        let intro = try #require(install.lessons.first { $0.id == "intro-01" })
        #expect(intro.contentVersion == "4")
        #expect(intro.objectiveId == "INTRO-01")
        #expect(PersonalUseA1Course.contains(intro) == false)
        for excluded in ["a1-greetings", "a1-alphabet", "a1-numbers", "a1-dates", "a1-home", "a1-shopping", "a1-places", "a1-hobbies", "a1-weather"] {
            let lesson = try #require(install.lessons.first { $0.id == excluded })
            #expect(PersonalUseA1Course.contains(lesson) == false)
        }

        var identities: Set<String> = []
        for lesson in [intro] + approved {
            #expect(lesson.senses.count == 5)
            for sense in lesson.senses {
                #expect(identities.insert(sense.id).inserted)
            }
        }
        for lesson in approved {
            let kinds = Set(lesson.practiceActivities.map(\.kind))
            #expect(kinds.isSuperset(of: ["reading", "listening", "grammar", "recall", "guidedSpeaking", "selfReview"]))
            #expect(lesson.practiceActivities.allSatisfy { ($0.childObjectiveIds ?? []).isEmpty && ($0.explanation ?? "").isEmpty })
            #expect(lesson.practiceActivities.contains { $0.id.hasPrefix("transfer-") } == false)
            #expect(lesson.sessionActivities.contains { $0.kind == "quietText" } == false)
            #expect(lesson.sessionActivities.contains { $0.kind == "guidedSpeaking" })
            let listening = try #require(lesson.practiceActivities.first { $0.kind == "listening" })
            #expect(listening.playbackPath?.isEmpty == false)
        }
    }

    @Test func oneLessonCannotResumeOrCompleteAnother() throws {
        let install = CurriculumCatalogLoader().loadBundled()
        let family = try #require(install.lesson(id: "family-01", version: "2"))
        let food = try #require(install.lesson(id: "food-01", version: "2"))
        var familySession = try LessonSession.begin(lesson: family, presenter: "teacher", now: date(1))
        let foodSession = try LessonSession.begin(lesson: food, presenter: "teacher", now: date(1))
        let firstID = try #require(family.sessionActivities.first?.id)
        try familySession.record(activityID: firstID, text: "My sister is a student.", assisted: false)
        let resumed = try LessonSession.begin(lesson: family, presenter: "teacher", now: date(2), existing: familySession.journey)
        #expect(resumed.journey.id == familySession.journey.id)
        #expect(resumed.journey.completedAt == nil)
        #expect(resumed.response(for: firstID)?.unaidedText == "My sister is a student.")

        let savedBeforeRejection = familySession.journey
        #expect(throws: LessonProgressError.unknownActivity) {
            try LessonSession.begin(lesson: food, presenter: "teacher", now: date(2), existing: savedBeforeRejection)
        }
        var wrongObjective = familySession.journey
        wrongObjective.objectiveID = "FOOD-01"
        #expect(throws: LessonProgressError.objectiveMismatch) {
            try LessonSession.begin(lesson: family, presenter: "teacher", now: date(2), existing: wrongObjective)
        }
        var wrongVersion = familySession.journey
        wrongVersion.contentVersion = "3"
        #expect(throws: LessonProgressError.versionMismatch) {
            try LessonSession.begin(lesson: family, presenter: "teacher", now: date(2), existing: wrongVersion)
        }

        #expect(familySession.journey == savedBeforeRejection)
        #expect(wrongObjective.objectiveID == "FOOD-01")
        #expect(wrongVersion.contentVersion == "3")

        for activity in family.sessionActivities where activity.required {
            try familySession.record(activityID: activity.id, text: "My sister is a student.", assisted: false)
        }
        try familySession.finish(now: date(3))
        #expect(familySession.journey.completedAt == date(3))
        #expect(foodSession.journey.completedAt == nil)
        #expect(foodSession.journey.lessonID == "food-01")
    }

    @Test func introPersonalCheckDoesNotCompleteTheApprovedLesson() throws {
        let install = CurriculumCatalogLoader().loadBundled()
        let family = try #require(install.lesson(id: "family-01", version: "2"))
        var course = try LessonSession.begin(lesson: family, presenter: "teacher", now: date(1))
        course.journey.teachingBeganAt = date(1)
        let frozen = IntroCheckSnapshot.begin(
            kind: .baseline, course: course.journey, previous: [], now: date(1),
            supported: false, retainedText: true, interveningPractice: "Not reported")
        let checkLesson = frozen.lesson()
        #expect(checkLesson.objectiveId == "INTRO-01")
        #expect(PersonalUseA1Course.contains(checkLesson) == false)
        var check = try LessonSession.begin(lesson: checkLesson, presenter: "teacher", now: date(1))
        check.journey.personalCheck = frozen
        try check.recordPersonalCheck(text: "My name is Sam.")
        try check.recordPersonalCheck(text: "I like walking.")
        try check.finishPersonalCheck(now: date(2))
        #expect(check.journey.completedAt == date(2))
        #expect(course.journey.completedAt == nil)
        #expect(course.journey.lessonID == "family-01")
        #expect(course.journey.objectiveID == "FAMILY-01")
    }

    @Test func missingListeningKeepsThatLessonClosed() throws {
        let family = CurriculumLesson(
            id: "family-01", contentVersion: "2", level: "A1", title: "Describe your family", objectiveId: "FAMILY-01",
            activities: [CurriculumActivity(id: "listen", kind: "listening", required: true, prompt: "Listen.", answer: "Sam.", assetId: "family-audio")])
        let food = CurriculumLesson(
            id: "food-01", contentVersion: "2", level: "A1", title: "Order a snack", objectiveId: "FOOD-01",
            activities: [CurriculumActivity(id: "read", kind: "reading", required: true, prompt: "Read the order.")])
        let manifest = CurriculumManifest(
            schemaVersion: 1, packId: "speechcoach.curriculum", contentVersion: "2", locale: "en-US",
            minimumSchemaVersion: 1, editorialApprovalReference: "Owner personal-use acceptance.",
            rightsReference: "Original wording.",
            assets: [CurriculumAsset(id: "family-audio", relativePath: "missing-family.wav", byteCount: 4, sha256: String(repeating: "ab", count: 32), mediaType: "audio/wav")],
            lessons: [family, food])
        let resolved = CurriculumAvailability.resolve(manifest: manifest, inspected: [:])
        let closed = try #require(resolved.first { $0.id == "family-01" })
        let open = try #require(resolved.first { $0.id == "food-01" })
        #expect(PersonalUseA1Course.contains(closed))
        #expect(closed.isReady == false)
        if case .unavailable(.missingAsset("missing-family.wav")) = closed.availability {} else {
            Issue.record("Missing listening audio must keep the lesson unavailable")
        }
        #expect(open.isReady)
        #expect(PersonalUseA1Course.contains(open))
    }

    private func date(_ day: Int) -> Date {
        Date(timeIntervalSince1970: TimeInterval(day * 86_400))
    }
}
