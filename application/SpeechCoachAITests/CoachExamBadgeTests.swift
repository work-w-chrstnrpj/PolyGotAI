import Foundation
import Testing
@testable import SpeechCoachAI

struct CoachExamBadgeTests {
    private let now = Date(timeIntervalSince1970: 1_792_800_000)

    private func lesson(_ id: String, count: Int = 5) -> ResolvedLesson {
        let questions = (0..<count).map { index in
            CurriculumActivity(id: "\(id)-q\(index)", kind: "quietText", required: true,
                prompt: "Choose the synthetic answer.", answer: "yes",
                exercise: ExerciseSpec(type: "choice", options: ["yes", "no"], accepted: ["yes"]))
        }
        let open = CurriculumActivity(id: id + "-open", kind: "quietText", required: true,
            prompt: "Give an example.", answer: "Synthetic reflection.", exercise: ExerciseSpec(type: "open"))
        return ResolvedLesson(id: id, level: "A2", title: id, objectiveId: id, contentVersion: "2",
            availability: .ready, practiceActivities: questions + [open])
    }

    private func track(_ coach: TrackCoach = .grammarian, lessons: [ResolvedLesson]) -> Track {
        Track(id: coach.rawValue, coach: coach,
            stages: [TrackStage(id: "foundation", title: "Foundation",
                units: [TrackUnit(id: "synthetic", title: "Synthetic", lessons: lessons)])])
    }

    private func attempt(_ lesson: ResolvedLesson, correct: Int = 4) -> LessonJourney {
        let responses = lesson.sessionActivities.enumerated().map { index, activity in
            let first = activity.resolvedExercise.isChecked ? (index < correct ? "yes" : "no") : "Synthetic reflection."
            return LessonResponse(activityID: activity.id, kind: activity.kind, modality: "text",
                unaidedText: first, assistedText: activity.resolvedExercise.isChecked ? "yes" : nil,
                answerRevealed: true, firstResponseText: first)
        }
        return LessonJourney(id: UUID(), lessonID: lesson.id, objectiveID: lesson.objectiveId,
            contentVersion: lesson.contentVersion, presenter: "synthetic", currentActivityID: nil,
            responses: responses, completedAt: now)
    }

    private func evaluate(_ tracks: [Track], _ journeys: [LessonJourney], ledger: RewardLedger? = nil) -> RewardLedger {
        var value = ledger ?? RewardLedger(epoch: UUID(), startedAt: now)
        AwardEvaluator.evaluate(&value, AwardInputs(journeys: journeys, course: [], tracks: tracks, watched: [:],
            activities: [], legacyFeedback: [], customTopicCount: 0, wordsInAction: 0), now: now)
        return value
    }

    private func examAwards(_ value: RewardLedger) -> [RewardAward] {
        value.awards.filter { AwardEvaluator.coachExamFamilies.values.contains($0.family) }
    }

    @Test func eightyPercentIsInclusiveButSeventyNinePercentDoesNotPass() throws {
        let exam = lesson("boundary", count: 100), course = track(lessons: [lesson("boundary", count: 100)])
        #expect(examAwards(evaluate([course], [attempt(exam, correct: 79)])).isEmpty)
        let journey = attempt(exam, correct: 80)
        let award = try #require(examAwards(evaluate([course], [journey])).first)
        #expect(award.family == "AW-TK-07")
        #expect(award.evidence == ["boundary@2/" + journey.id.uuidString])
    }

    @Test func everyLessonNeedsEightyRatherThanAveragingScoresAcrossTheTrack() {
        let a = lesson("one"), b = lesson("two"), course = track(lessons: [a, b])
        // 100% + 60% averages 80%, but the second lesson still fails its own requirement.
        #expect(examAwards(evaluate([course], [attempt(a, correct: 5), attempt(b, correct: 3)])).isEmpty)
        #expect(examAwards(evaluate([course], [attempt(a, correct: 5), attempt(b)])).count == 1)
        #expect(examAwards(evaluate([course], [attempt(a)])).isEmpty)
    }

    @Test func bestCompletedRetakeCountsAndLaterFailuresNeverRemoveTheBadge() {
        let exam = lesson("retake"), course = track(lessons: [lesson("retake")])
        let failed = attempt(exam, correct: 3), passed = attempt(exam)
        #expect(examAwards(evaluate([course], [failed])).isEmpty, "correcting the retry does not rewrite its first score")
        let earned = evaluate([course], [failed, passed, failed])
        #expect(examAwards(earned).count == 1)
        #expect(examAwards(evaluate([course], [failed], ledger: earned)).count == 1)
        #expect(examAwards(evaluate([course], [passed], ledger: earned)).count == 1)
    }

    @Test func unfinishedOldVersionOrOptionalPracticeDoesNotQualify() {
        let exam = lesson("identity"), course = track(lessons: [lesson("identity")])
        var unfinished = attempt(exam); unfinished.completedAt = nil
        var archived = attempt(exam); archived.contentVersion = "1"
        var wrongObjective = attempt(exam); wrongObjective.objectiveID = "other"
        var optional = attempt(exam)
        optional.practiceOrigin = LessonPracticeOrigin(journeyID: UUID(), lessonID: exam.id, objectiveID: exam.objectiveId, activityID: nil)
        for journey in [unfinished, archived, wrongObjective, optional] {
            #expect(examAwards(evaluate([course], [journey])).isEmpty)
        }
    }

    @Test func missingScoresPartialResponsesAndIncompleteOpenWorkDoNotQualify() {
        let exam = lesson("complete"), course = track(lessons: [lesson("complete")])
        var empty = attempt(exam); empty.responses = []
        var partial = attempt(exam, correct: 5); partial.responses.removeFirst()
        var missingOpen = attempt(exam); missingOpen.responses.removeLast()
        var invalidKind = attempt(exam); invalidKind.responses[0].kind = "other"
        for journey in [empty, partial, missingOpen, invalidKind] {
            #expect(examAwards(evaluate([course], [journey])).isEmpty)
        }
        var openOnly = exam; openOnly.practiceActivities = Array(exam.practiceActivities.suffix(1))
        #expect(examAwards(evaluate([track(lessons: [openOnly])], [attempt(openOnly)])).isEmpty)
        #expect(examAwards(evaluate([track(lessons: [])], [])).isEmpty)
    }

    @Test func allElevenCoachesHaveDistinctEarnableFaceBadges() throws {
        #expect(AwardEvaluator.coachExamFamilies.count == TrackCoach.allCases.count)
        #expect(Set(AwardEvaluator.coachExamFamilies.values).count == 11)
        var filenames: Set<String> = []
        for coach in TrackCoach.allCases {
            let exam = lesson(coach.rawValue)
            let awards = examAwards(evaluate([track(coach, lessons: [exam])], [attempt(exam)]))
            let familyID = try #require(AwardEvaluator.coachExamFamilies[coach])
            #expect(awards.map(\.family) == [familyID])
            let family = try #require(AwardFamily.catalog.first { $0.id == familyID })
            #expect(family.title.contains("80%") && family.criteria.contains("each lesson"))
            #expect(!family.filename.isEmpty && family.visibility == nil)
            filenames.insert(family.filename)
        }
        #expect(filenames.count == 11)
    }

    @Test func everyBundledCoachLessonProvidesCheckedExamItems() {
        let tracks = CurriculumCatalogLoader.bundled.tracks.tracks
        #expect(tracks.count == 11)
        for course in tracks {
            #expect(!course.lessons.isEmpty)
            for exam in course.lessons { #expect(exam.hasCheckedExercises, "\(exam.id) needs an exam score") }
        }
    }
}
