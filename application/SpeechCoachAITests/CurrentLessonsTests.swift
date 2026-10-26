import Foundation
import Testing
@testable import SpeechCoachAI

/// Today's "continue" lessons: course position and coach tracks (Phase 7, C4).
struct CurrentLessonsTests {
    private let install = CurriculumCatalogLoader.bundled

    private func journey(_ lesson: ResolvedLesson, finished: Bool) -> LessonJourney {
        LessonJourney(id: UUID(), lessonID: lesson.id, objectiveID: lesson.objectiveId, contentVersion: lesson.contentVersion,
                      presenter: "elephantTeacher", currentActivityID: nil, responses: [],
                      completedAt: finished ? Date(timeIntervalSince1970: 100) : nil)
    }
    private func current(_ journeys: [LessonJourney], passed: Set<String> = []) -> CurrentLessons {
        CurrentLessons.make(install: install, journeys: journeys,
                            gate: LevelGate(install: install, journeys: journeys, passedTests: passed), dueWords: 3)
    }
    private var a1: [ResolvedLesson] { install.lessons(at: "A1").filter { $0.isReady && $0.trackId == "course" } }

    @Test func newLearnerStartsTheFirstA1CourseLessonAndHasNoCoachLesson() throws {
        let today = current([])
        let first = try #require(a1.first)
        #expect(today.course?.lesson.id == first.id)
        #expect(today.course?.resuming == false)
        #expect(today.course?.rank == "A1")
        #expect(today.coaches.isEmpty)
        #expect(today.dueWords == 3)
    }

    @Test func theIntroLessonIsNeverOffered() {
        #expect(current([]).course?.lesson.trackId == "course")
    }

    @Test func anUnfinishedCourseLessonIsResumedEvenWhenWordsAreDue() throws {
        let second = try #require(a1.dropFirst().first)
        let today = current([journey(a1[0], finished: true), journey(second, finished: false)])
        #expect(today.course?.lesson.id == second.id)
        #expect(today.course?.resuming == true)
    }

    @Test func afterAFinishedLessonTheNextOneAtTheSameRankIsOffered() throws {
        let today = current([journey(a1[0], finished: true)])
        #expect(today.course?.lesson.id == a1[1].id)
        #expect(today.course?.resuming == false)
    }

    @Test func aPassedTestMovesTheCourseToTheHighestOpenRank() throws {
        let today = current([], passed: ["B1"])
        #expect(today.course?.rank == "B1")
    }

    @Test func coachLessonsInProgressComeFirstAndAreCapped() throws {
        let tracks = install.tracks.tracks
        try #require(tracks.count >= 3)
        let started = tracks.prefix(3).map { journey($0.lessons[0], finished: false) }
        let today = current(started)
        #expect(today.coaches.count == CurrentLessons.maximumCoaches)
        // Most recently started first.
        #expect(today.coaches.first?.lesson.id == tracks[2].lessons[0].id)
        #expect(today.coaches.allSatisfy { $0.resuming && $0.coach != nil })
    }

    @Test func withNothingInProgressTheLastUsedCoachOffersItsNextLesson() throws {
        let track = try #require(install.tracks.tracks.first)
        let today = current([journey(track.lessons[0], finished: true)])
        #expect(today.coaches.map(\.lesson.id) == [track.lessons[1].id])
        #expect(today.coaches.first?.coach == track.coach)
    }
}
