import Foundation
import Testing
@testable import SpeechCoachAI

struct LessonJourneyTests {
    @Test func unaidedAnswerStaysFixedAndQuietWorkIsTextEvidence() throws {
        var session = try LessonSession.begin(lesson: readyLesson(), presenter: "elephantTeacher", now: date(1))
        try session.record(activityID: "quiet", text: "I am a cook.", assisted: false)
        try session.record(activityID: "quiet", text: "I am a chef.", assisted: false)
        try session.record(activityID: "quiet", text: "I work in a kitchen.", assisted: true)
        let quiet = try #require(session.response(for: "quiet"))
        #expect(quiet.unaidedText == "I am a cook.")
        #expect(quiet.assistedText == "I work in a kitchen.")
        #expect(quiet.modality == "text")
        #expect(throws: LessonProgressError.answerStillHidden) { try session.revealAnswer(activityID: "speak") }
        #expect(try session.revealAnswer(activityID: "quiet") == "am")
        session.journey.presenter = "owlGrammarian"
        #expect(session.response(for: "quiet")?.unaidedText == "I am a cook.")
    }

    @Test func completionRequiresEveryActivityButAllowsHonestAssistedTextPractice() throws {
        var session = try LessonSession.begin(lesson: readyLesson(), presenter: "elephantTeacher", now: date(1))
        try session.record(activityID: "quiet", text: "I study English.", assisted: false)
        #expect(throws: LessonProgressError.unfinished) { try session.finish(now: date(2)) }
        try session.record(activityID: "speak", text: "I like music.", assisted: true)
        try session.finish(now: date(2))
        #expect(session.journey.completedAt == date(2))
        #expect(session.response(for: "speak")?.modality == "text")
        #expect(session.response(for: "speak")?.unaidedText == nil)
    }

    @Test func unavailableLessonAndOtherVersionDoNotMoveCredit() throws {
        let blocked = ResolvedLesson(id: "intro", level: "A1", title: "Intro", objectiveId: "INTRO-01", contentVersion: "1",
                                     availability: .unavailable(.missingReview), practiceActivities: [])
        #expect(throws: LessonProgressError.unfinished) {
            _ = try LessonSession.begin(lesson: blocked, presenter: "elephantTeacher", now: date(1))
        }
        let started = try LessonSession.begin(lesson: readyLesson(), presenter: "elephantTeacher", now: date(1))
        #expect(throws: LessonProgressError.versionMismatch) {
            _ = try LessonSession.begin(lesson: readyLesson(version: "2"), presenter: "foxJournalist", now: date(2), existing: started.journey)
        }
        #expect(started.journey.contentVersion == "1")
        #expect(started.journey.responses.isEmpty)
    }

    @Test func progressResumesAndAFailedSaveDoesNotClaimCompletion() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-T020-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        var repo = try LearnerRepository(root: root, now: { date(1) }, protectedDataAvailable: { true })
        let original = try repo.preferences()
        var session = try LessonSession.begin(lesson: readyLesson(), presenter: original.coach.rawValue, now: date(1))
        try session.record(activityID: "quiet", text: "I live in Manila.", assisted: false)
        try repo.saveLessonJourney(session.journey)
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        try session.record(activityID: "speak", text: "I like reading.", assisted: false)
        try session.finish(now: date(2))
        #expect(throws: LearnerStorageError.storageFailure) { try repo.saveLessonJourney(session.journey) }
        repo.beforeCommit = nil
        repo.close()
        repo = try LearnerRepository(root: root, now: { date(3) }, protectedDataAvailable: { true })
        #expect(try repo.preferences() == original)
        let saved = try #require(repo.lessonJourneys(lessonID: "intro").first)
        #expect(saved.completedAt == nil)
        #expect(saved.responses.first?.unaidedText == "I live in Manila.")
        let resumed = try LessonSession.begin(lesson: readyLesson(), presenter: "creativeWriter", now: date(3), existing: saved)
        #expect(resumed.journey.presenter == "creativeWriter")
        #expect(resumed.response(for: "quiet")?.unaidedText == "I live in Manila.")
        try repo.deleteAllLearningData()
        #expect(try repo.lessonJourneys(lessonID: "intro").isEmpty)
    }

    @Test func draftsNavigationAndRepeatedAttemptsSurviveReopening() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("lesson-recovery-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        var repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        var first = try LessonSession.begin(lesson: readyLesson(), presenter: "elephantTeacher", now: date(1))
        try first.saveDraft("Still thinking", for: "speak")
        try first.move(to: "speak")
        try repo.saveLessonJourney(first.journey)
        repo.close()
        repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { repo.close() }
        let saved = try #require(try repo.lessonJourneys(lessonID: "intro").last)
        #expect(saved.currentActivityID == "speak")
        #expect(saved.drafts?["speak"] == "Still thinking")
        #expect(saved.responses.isEmpty)
        let repeated = try LessonSession.begin(lesson: readyLesson(), presenter: "elephantTeacher", now: date(2))
        try repo.saveLessonJourney(repeated.journey)
        #expect(try repo.lessonJourneys(lessonID: "intro").map(\.id) == [first.journey.id, repeated.journey.id])
        var legacy = try JSONSerialization.jsonObject(with: JSONEncoder().encode(saved)) as! [String: Any]
        legacy.removeValue(forKey: "drafts")
        #expect(try JSONDecoder().decode(LessonJourney.self, from: JSONSerialization.data(withJSONObject: legacy)).drafts == nil)
    }

    @Test func typedSpeakingAndSupportCannotBecomeUnaidedEvidence() throws {
        var session = try LessonSession.begin(lesson: readyLesson(), presenter: "elephantTeacher", now: date(1))
        try session.record(activityID: "speak", text: "I work at a cafe.", assisted: false)
        #expect(session.response(for: "speak")?.modality == "text")
        try session.record(activityID: "quiet", text: "Supported first answer", assisted: true)
        _ = try session.revealAnswer(activityID: "quiet")
        try session.record(activityID: "quiet", text: "After seeing the answer", assisted: false)
        #expect(session.response(for: "quiet")?.unaidedText == nil)
        #expect(session.response(for: "quiet")?.assistedText == "After seeing the answer")
        session.journey.responses[0].modality = "speaking"
        let resumed = try LessonSession.begin(lesson: readyLesson(), presenter: "elephantTeacher", now: date(2), existing: session.journey)
        #expect(resumed.response(for: "speak")?.modality == "text")
    }

    @Test func quietEquivalentIsNotAnExtraTaskAndRealRecordingCanCompleteSpeaking() throws {
        var lesson = readyLesson()
        lesson.practiceActivities.append(CurriculumActivity(id: "quiet-equivalent", kind: "quietText", required: true,
            prompt: "Write instead of recording", alternativeToActivityID: "speak"))
        var session = try LessonSession.begin(lesson: lesson, presenter: "elephantTeacher", now: date(1))
        #expect(session.activities.count == 2)
        #expect(throws: LessonProgressError.unfinished) { try session.finish(now: date(2)) }
        let completion = UUID()
        try session.recordSpeakingPractice(activityID: "speak", completionID: completion)
        try session.recordSpeakingPractice(activityID: "speak", completionID: completion)
        #expect(session.journey.responses.count == 1)
        #expect(session.response(for: "speak")?.unaidedText == nil)
        #expect(session.response(for: "speak")?.recordedPracticeID == completion)
        #expect(session.response(for: "speak")?.modality == "speaking")
        try session.record(activityID: "quiet", text: "I am a cook.", assisted: false)
        try session.finish(now: date(2))
        #expect(session.journey.completedAt != nil)
        let resumed = try LessonSession.begin(lesson: lesson, presenter: "owlGrammarian", now: date(3), existing: session.journey)
        #expect(resumed.response(for: "speak")?.modality == "speaking")
    }

    @Test func optionalPacksKeepCourseAndReservedAssessmentSeparateAcrossRestart() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("intro-packs-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        var repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        var course = try LessonSession.begin(lesson: readyLesson(), presenter: "elephantTeacher", now: date(1))
        try course.saveDraft("My course draft", for: "quiet")
        try repo.saveLessonJourney(course.journey)
        let origin = LessonPracticeOrigin(journeyID: course.journey.id, lessonID: course.journey.lessonID,
            objectiveID: course.journey.objectiveID, activityID: course.journey.currentActivityID)
        for pack in IntroPracticePack.allCases {
            var practice = try LessonSession.begin(lesson: pack.lesson, presenter: pack.rawValue, now: date(1))
            practice.journey.practiceOrigin = origin
            #expect(!practice.activities.contains { $0.id.contains("baseline") || $0.id.contains("transfer") })
            let first = try #require(pack.steps.first)
            #expect(throws: LessonProgressError.answerStillHidden) { try practice.revealAnswer(activityID: first.id) }
            for step in pack.steps {
                try practice.record(activityID: step.id, text: "My first response", assisted: step.supported)
                _ = try practice.revealAnswer(activityID: step.id)
                try practice.record(activityID: step.id, text: "My retry", assisted: true)
                #expect(practice.response(for: step.id)?.firstResponseText == "My first response")
                #expect(practice.response(for: step.id)?.assistedText == "My retry")
                #expect(practice.response(for: step.id)?.modality == "text")
            }
            try pack.finish(&practice, now: date(2))
            try repo.saveLessonJourney(practice.journey)
        }
        repo.close()
        repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { repo.close() }
        #expect(try repo.lessonJourneys(lessonID: "intro") == [course.journey])
        for pack in IntroPracticePack.allCases {
            let saved = try #require(repo.lessonJourneys(lessonID: pack.id).first)
            #expect(saved.practiceOrigin == origin)
            #expect(saved.completedAt != nil)
        }
        try repo.deleteAllLearningData()
        #expect(try repo.allLessonJourneys().isEmpty)
    }

    @Test func foundationCompletionRequiresProductionAndReviewWithoutAccuracyGate() throws {
        let pack = IntroPracticePack.foundations
        #expect(pack.steps.filter(\.concept).count == 5)
        #expect(pack.steps.filter { $0.id.contains("-produce-") }.count == 5)
        var session = try LessonSession.begin(lesson: pack.lesson, presenter: "foundations", now: date(1))
        for step in pack.steps { try session.record(activityID: step.id, text: "A deliberately incorrect attempt", assisted: false) }
        #expect(throws: LessonProgressError.unfinished) { try pack.finish(&session, now: date(2)) }
        for step in pack.steps.dropLast() { _ = try session.revealAnswer(activityID: step.id) }
        try pack.finish(&session, now: date(2))
        #expect(session.journey.completedAt != nil)
    }

    @Test func practiceOriginAndFirstResponseDecodeFromOldDocumentsAsAbsent() throws {
        let journey = try LessonSession.begin(lesson: readyLesson(), presenter: "owlGrammarian", now: date(1)).journey
        let decoded = try JSONDecoder().decode(LessonJourney.self, from: JSONEncoder().encode(journey))
        #expect(decoded.practiceOrigin == nil)
        var session = try LessonSession.begin(lesson: readyLesson(), presenter: "owlGrammarian", now: date(1))
        try session.record(activityID: "quiet", text: "First supported answer", assisted: true)
        try session.record(activityID: "quiet", text: "Second supported answer", assisted: true)
        #expect(session.response(for: "quiet")?.firstResponseText == "First supported answer")
        #expect(session.response(for: "quiet")?.unaidedText == nil)
    }

    @Test func personalCheckRetentionRestartAndCompletionAreIndependentOfCourse() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("checks-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        var repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let course = try LessonSession.begin(lesson: readyLesson(), presenter: "teacher", now: date(1)).journey
        try repository.saveLessonJourney(course)
        for keepText in [false, true] {
            let frozen = IntroCheckSnapshot.begin(kind: .baseline, course: course, previous: [], now: date(1), supported: false, retainedText: keepText, interveningPractice: "Not reported")
            var check = try LessonSession.begin(lesson: frozen.lesson(), presenter: "teacher", now: date(1))
            check.journey.personalCheck = frozen
            #expect(throws: LessonProgressError.unfinished) { try check.finishPersonalCheck(now: date(2)) }
            try check.recordPersonalCheck(text: "My original introduction")
            try repository.saveLessonJourney(check.journey)
            repository.close()
            repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
            let saved = try #require(repository.lessonJourneys(lessonID: frozen.lesson().id).first { $0.id == check.journey.id })
            check = try LessonSession.begin(lesson: frozen.lesson(), presenter: "teacher", now: date(2), existing: saved)
            #expect(check.journey.currentActivityID == "check-1")
            try check.recordPersonalCheck(text: "I enjoy walking")
            try check.finishPersonalCheck(now: date(2))
            try repository.saveLessonJourney(check.journey)
            #expect(check.journey.personalCheck?.completedItems == [0, 1])
            #expect(check.journey.responses.count == (keepText ? 2 : 0))
            #expect(check.journey.personalCheck?.modalities?["check-0"] == "text")
            #expect(try repository.lessonJourneys(lessonID: course.lessonID) == [course])
        }
        try repository.deleteAllLearningData()
        #expect(try repository.allLessonJourneys().isEmpty)
    }

    @Test func personalChecksFreezePurposeTimingAndNeverEnterCoursePractice() throws {
        var course = try LessonSession.begin(lesson: readyLesson(), presenter: "teacher", now: date(1)).journey
        course.teachingBeganAt = date(1)
        let first = IntroCheckSnapshot.begin(kind: .baseline, course: course, previous: [], now: date(1), supported: false, retainedText: false, interveningPractice: "Not reported")
        var recorded = try LessonSession.begin(lesson: first.lesson(), presenter: "teacher", now: date(1)).journey
        recorded.personalCheck = first
        let repeated = IntroCheckSnapshot.begin(kind: .baseline, course: course, previous: [recorded], now: date(2), supported: true, retainedText: true, interveningPractice: "Some practice reported")
        #expect(repeated.purpose == "repeatedBaseline" && repeated.priorExposure && repeated.supported)
        #expect(first.prompts == repeated.prompts)
        for (kind, day) in [(IntroCheckKind.day7, 8), (.day28, 29)] {
            let check = IntroCheckSnapshot.begin(kind: kind, course: course, previous: [], now: date(day), supported: false, retainedText: false, interveningPractice: "No practice reported")
            #expect(check.prompts.count == 5)
            #expect(check.timingDescription.contains("within the planned window"))
            #expect(check.lesson().practiceActivities.allSatisfy { $0.answer == nil })
            let decoded = try JSONDecoder().decode(IntroCheckSnapshot.self, from: JSONEncoder().encode(check))
            #expect(decoded == check)
        }
        var late = IntroCheckSnapshot.begin(kind: .day7, course: course, previous: [], now: date(20), supported: false, retainedText: false, interveningPractice: "Not reported")
        #expect(late.timingDescription.contains("outside"))
        late.teachingBeganAt = nil
        #expect(late.timingDescription.contains("unavailable"))
        #expect(course.responses.isEmpty && course.completedAt == nil)
        #expect(!CurriculumCatalogLoader.bundled.lessons.first { $0.id == "intro-01" }!.practiceActivities.contains { $0.withheldFromPractice == true })
    }

    private func readyLesson(version: String = "1") -> ResolvedLesson {
        ResolvedLesson(id: "intro", level: "A1", title: "Introductions", objectiveId: "INTRO-01", contentVersion: version,
                       availability: .ready, practiceActivities: [
                        CurriculumActivity(id: "quiet", kind: "quietText", required: true, prompt: "Write three facts.", answer: "am"),
                        CurriculumActivity(id: "speak", kind: "guidedSpeaking", required: true, prompt: "Say three facts.")
                       ])
    }

    private func date(_ day: Int) -> Date { Date(timeIntervalSince1970: TimeInterval(day) * 86_400) }
}
