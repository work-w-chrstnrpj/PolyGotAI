import Foundation
import Testing
@testable import SpeechCoachAI

/// Level lock, jump test and coach tracks (Phase 2).
struct LevelGateTests {
    private let install = CurriculumCatalogLoader.bundled

    private func journey(_ lesson: ResolvedLesson, finished: Bool) -> LessonJourney {
        LessonJourney(id: UUID(), lessonID: lesson.id, objectiveID: lesson.objectiveId, contentVersion: lesson.contentVersion,
                      presenter: "elephantTeacher", currentActivityID: nil, responses: [],
                      completedAt: finished ? Date(timeIntervalSince1970: 100) : nil)
    }

    private struct SeededGenerator: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }
    }

    private func correctResponse(_ spec: ExerciseSpec) -> ExerciseResponse {
        switch spec.kind {
        case .wordBank: .sequence((spec.accepted?.first ?? "").split(separator: " ").map(String.init))
        case .order: .sequence(spec.items ?? [])
        case .match: .pairs(spec.pairs ?? [])
        default: .text(spec.accepted?.first ?? "")
        }
    }

    // MARK: Level gate

    @Test func aFreshLearnerHasOnlyA1AndCanTakeTheA2Test() {
        let gate = LevelGate(install: install, journeys: [], passedTests: [])
        #expect(gate.unlockedLevels == ["A1"])
        #expect(gate.isUnlocked("A1"))
        #expect(!gate.isUnlocked("C2"))
        #expect(gate.nextLockedLevel == "A2")
        #expect(gate.canTakeJumpTest(to: "A2"))
        #expect(!gate.canTakeJumpTest(to: "B1"))
        #expect(!gate.canTakeJumpTest(to: "C2"))
    }

    @Test func finishingEveryReadyA1LessonOpensA2() {
        let journeys = install.lessons(at: "A1").filter(\.isReady).map { journey($0, finished: true) }
        let gate = LevelGate(install: install, journeys: journeys, passedTests: [])
        #expect(gate.unlockedLevels == ["A1", "A2"])
        #expect(gate.nextLockedLevel == "B1")
        // The B1 test needs typed A2 exercises (Phase 4), so none can be taken yet.
        #expect(!gate.canTakeJumpTest(to: "B1"))
    }

    @Test func oneFinishedLessonIsNotEnough() throws {
        let first = try #require(install.lessons(at: "A1").first { $0.isReady })
        let gate = LevelGate(install: install, journeys: [journey(first, finished: true)], passedTests: [])
        #expect(gate.unlockedLevels == ["A1"])
    }

    @Test func aPassedTestOpensOnlyThatLevel() {
        let gate = LevelGate(install: install, journeys: [], passedTests: ["A2"])
        #expect(gate.unlockedLevels == ["A1", "A2"])
        #expect(!gate.isUnlocked("B1"))
    }

    @Test func levelsOpenedInV1StayOpenAndOpenEverythingBelow() throws {
        let b1 = try #require(install.lessons(at: "B1").first { $0.isReady })
        let gate = LevelGate(install: install, journeys: [journey(b1, finished: false)], passedTests: [])
        #expect(gate.unlockedLevels == ["A1", "A2", "B1"])
    }

    // MARK: Jump test

    @Test func theA2TestHasTwentyItemsAndEveryA1TopicOnce() throws {
        var generator = SeededGenerator(state: 7)
        let test = try #require(JumpTest.make(target: "A2", install: install, using: &generator))
        #expect(test.total == JumpTest.questionCount)
        #expect(Set(test.items.map(\.id)).count == test.total)
        let topics = Set(test.items.map(\.lessonID))
        let eligibleTopics = Set(JumpTest.eligibleItems(target: "A2", install: install).compactMap { $0.first?.lessonID })
        #expect(topics == eligibleTopics)
        #expect(test.items.allSatisfy { $0.spec.isChecked && $0.spec.kind != .speak })
    }

    @Test func eachAttemptHasANewQuestionOrder() throws {
        var first = SeededGenerator(state: 1), second = SeededGenerator(state: 2)
        let a = try #require(JumpTest.make(target: "A2", install: install, using: &first))
        let b = try #require(JumpTest.make(target: "A2", install: install, using: &second))
        #expect(a.items.map(\.id) != b.items.map(\.id))
    }

    @Test func onlyTwentyOfTwentyPasses() throws {
        var generator = SeededGenerator(state: 3)
        var perfect = try #require(JumpTest.make(target: "A2", install: install, using: &generator))
        while let item = perfect.current {
            #expect(perfect.submit(correctResponse(item.spec)) == .correct)
            perfect.advance()
        }
        #expect(perfect.isFinished && perfect.isPerfect)
        #expect(perfect.resultLine == "Perfect. A2 is open.")

        var missed = try #require(JumpTest.make(target: "A2", install: install, using: &generator))
        var index = 0
        while let item = missed.current {
            missed.submit(index == 4 ? .text("zzz") : correctResponse(item.spec))
            missed.advance()
            index += 1
        }
        #expect(missed.isFinished && !missed.isPerfect)
        #expect(missed.correctCount == 19)
        #expect(missed.resultLine == "19 of 20. Try again.")
    }

    @Test func aSpellingSlipIsNotCorrectOnATest() throws {
        var generator = SeededGenerator(state: 5)
        var test = try #require(JumpTest.make(target: "A2", install: install, using: &generator))
        // Find a typed-word item and answer it with a near miss.
        while let item = test.current, item.spec.kind != .fillBlank {
            test.submit(correctResponse(item.spec)); test.advance()
        }
        guard let item = test.current, let answer = item.spec.accepted?.first, answer.count > 3 else { return }
        let slip = String(answer.dropLast())
        let result = test.submit(.text(slip))
        #expect(result != .correct)
        test.advance()
        while let rest = test.current { test.submit(correctResponse(rest.spec)); test.advance() }
        #expect(!test.isPerfect)
    }

    @Test func noTestExistsForLevelsWithoutTypedExercises() {
        #expect(JumpTest.make(target: "B1", install: install) == nil)
        #expect(JumpTest.make(target: "A1", install: install) == nil)
        #expect(!JumpTest.isAvailable(target: "C2", install: install))
    }

    // MARK: Storage

    @Test func aPassedTestSurvivesRestartAndA1CannotBeRecorded() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("P2-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        var repo = try LearnerRepository(root: root, now: { Date(timeIntervalSince1970: 1) }, protectedDataAvailable: { true })
        #expect(try repo.passedJumpTests().isEmpty)
        try repo.recordJumpTestPass(level: "a2")
        try repo.recordJumpTestPass(level: "A2")
        #expect(throws: LearnerStorageError.invalidContent) { try repo.recordJumpTestPass(level: "A1") }
        #expect(throws: LearnerStorageError.invalidContent) { try repo.recordJumpTestPass(level: "Z9") }
        repo.close()
        repo = try LearnerRepository(root: root, now: { Date(timeIntervalSince1970: 2) }, protectedDataAvailable: { true })
        #expect(try repo.passedJumpTests() == ["A2"])
    }

    @Test func theControllerRefreshesTheGateAfterAPass() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("P2c-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, now: { Date(timeIntervalSince1970: 1) }, protectedDataAvailable: { true })
        let controller = LearnerStorageController(repository: repo)
        #expect(controller.levelGate(install: install).unlockedLevels == ["A1"])
        #expect(controller.recordJumpTestPass(level: "A2"))
        #expect(controller.levelGate(install: install).unlockedLevels == ["A1", "A2"])
    }

    // MARK: Coach tracks

    @Test func theGrammarianTrackLoadsWithTwoUnitsOfFourLessons() throws {
        let track = try #require(install.tracks.track(id: "grammarian"))
        #expect(track.coach == .grammarian)
        #expect(track.stages.map(\.id) == ["starter"])
        let units = try #require(track.stages.first?.units)
        #expect(units.map(\.id) == ["sentences", "be-have-do"])
        #expect(units.allSatisfy { $0.lessons.count == 4 })
        #expect(track.lessons.allSatisfy { $0.isReady && $0.tip?.isEmpty == false && $0.hasCheckedExercises })
        #expect(install.tracks.tracks.first?.coach == .grammarian)
    }

    @Test func trackLessonsStayOutOfTheCourseButResolveForJourneys() throws {
        #expect(install.lessons.allSatisfy { $0.trackId == nil || $0.trackId == "course" })
        #expect(install.lesson(id: "gram-sent-subject", version: "1")?.title == "Subject and verb")
        #expect(install.lesson(id: "gram-sent-subject", version: "9") == nil)
    }

    @Test func lessonProgressAndTheContinueCard() throws {
        let track = try #require(install.tracks.track(id: "grammarian"))
        let lesson = try #require(track.lessons.first)
        #expect(LessonProgress.of(lesson, journeys: []).state == .new)
        #expect(track.completedFraction(journeys: []) == 0)
        #expect(install.tracks.continueLesson(journeys: []) == nil)

        let started = journey(lesson, finished: false)
        #expect(LessonProgress.of(lesson, journeys: [started]).state == .inProgress)
        #expect(install.tracks.continueLesson(journeys: [started])?.lesson.id == lesson.id)

        let done = journey(lesson, finished: true)
        #expect(LessonProgress.of(lesson, journeys: [done]).state == .done)
        #expect(track.completedFraction(journeys: [done]) == 1.0 / Double(track.lessons.count))
        #expect(install.tracks.continueLesson(journeys: [done]) == nil)
    }

    @Test func everyCoachHasOneLineTaglineAndAnIcon() {
        #expect(TrackCoach.allCases.count == 10)
        for coach in TrackCoach.allCases {
            #expect(!coach.title.isEmpty && !coach.symbol.isEmpty)
            #expect(coach.tagline.count <= 28)
        }
    }
}
