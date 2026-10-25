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

    // MARK: Synthetic content (every level typed), so the rule is tested independently of the bundle

    /// Lessons with twelve typed choice items each. `counts` maps a level to its number of lessons.
    private func syntheticInstall(_ counts: [String: Int]) -> CurriculumInstall {
        var lessons: [ResolvedLesson] = []
        for (level, count) in counts {
            for number in 1...count {
                let id = "\(level.lowercased())-t\(number)"
                let activities = (1...12).map { index in
                    CurriculumActivity(id: "\(id)-\(index)", kind: "grammar", required: true, prompt: "Question \(index)", answer: "a",
                                       exercise: ExerciseSpec(type: "choice", options: ["a", "b"], accepted: ["a"]))
                }
                lessons.append(ResolvedLesson(id: id, level: level, title: id, objectiveId: id.uppercased(), contentVersion: "1",
                                              availability: .ready, practiceActivities: activities))
            }
        }
        return CurriculumInstall(lessons: lessons, problem: nil)
    }

    private let everyLevel = ["A1": 4, "A2": 4, "B1": 4, "B2": 4, "C1": 4, "C2": 4]

    // MARK: Level gate

    @Test func aFreshLearnerHasOnlyA1AndCanTakeAnyLockedLevelsTest() {
        let gate = LevelGate(install: syntheticInstall(everyLevel), journeys: [], passedTests: [])
        #expect(gate.unlockedLevels == ["A1"])
        #expect(gate.nextLockedLevel == "A2")
        for level in ["A2", "B1", "B2", "C1", "C2"] { #expect(gate.canTakeJumpTest(to: level), "\(level) has a test") }
        #expect(!gate.canTakeJumpTest(to: "A1"))
    }

    @Test func passingC2OpensEveryLevel() {
        let gate = LevelGate(install: syntheticInstall(everyLevel), journeys: [], passedTests: ["C2"])
        #expect(gate.unlockedLevels == LevelGate.levels)
        #expect(gate.nextLockedLevel == nil)
        #expect(!gate.canTakeJumpTest(to: "C2"))
    }

    @Test func passingB2OpensEverythingBelowAndKeepsHigherTestsOpen() {
        let gate = LevelGate(install: syntheticInstall(everyLevel), journeys: [], passedTests: ["B2"])
        #expect(gate.unlockedLevels == ["A1", "A2", "B1", "B2"])
        #expect(!gate.canTakeJumpTest(to: "B1"))
        #expect(gate.canTakeJumpTest(to: "C1") && gate.canTakeJumpTest(to: "C2"))
    }

    @Test func finishingEveryReadyLessonOfALevelOpensTheNext() {
        let content = syntheticInstall(everyLevel)
        let journeys = content.lessons(at: "A1").map { journey($0, finished: true) }
        let gate = LevelGate(install: content, journeys: journeys, passedTests: [])
        #expect(gate.unlockedLevels == ["A1", "A2"])
        #expect(gate.canTakeJumpTest(to: "B1") && gate.canTakeJumpTest(to: "C2"))
    }

    @Test func oneFinishedLessonIsNotEnough() throws {
        let content = syntheticInstall(everyLevel)
        let first = try #require(content.lessons(at: "A1").first)
        let gate = LevelGate(install: content, journeys: [journey(first, finished: true)], passedTests: [])
        #expect(gate.unlockedLevels == ["A1"])
    }

    @Test func levelsOpenedInV1StayOpenAndOpenEverythingBelow() throws {
        let content = syntheticInstall(everyLevel)
        let b1 = try #require(content.lessons(at: "B1").first)
        let gate = LevelGate(install: content, journeys: [journey(b1, finished: false)], passedTests: [])
        #expect(gate.unlockedLevels == ["A1", "A2", "B1"])
    }

    @Test func aLevelWithoutTypedExercisesHasNoTest() {
        let gate = LevelGate(install: syntheticInstall(["A1": 4, "A2": 4]), journeys: [], passedTests: [])
        #expect(gate.canTakeJumpTest(to: "A2"))
        for level in ["B1", "B2", "C1", "C2"] { #expect(!gate.canTakeJumpTest(to: level), "\(level) has no typed exercises yet") }
    }

    @Test func aTooSmallLevelHasNoTest() {
        // One lesson is fewer than the three topics a test needs from its own level.
        let gate = LevelGate(install: syntheticInstall(["A1": 4, "A2": 1]), journeys: [], passedTests: [])
        #expect(!gate.canTakeJumpTest(to: "A2"))
    }

    // MARK: Jump test

    @Test func testSizesAreTwentyForA2AndThirtyAbove() {
        #expect(JumpTest.questionCount(for: "A2") == 20)
        #expect(JumpTest.questionCount(for: "B1") == 30)
        #expect(JumpTest.questionCount(for: "C2") == 30)
        #expect(JumpTest.sourceLevels(for: "C1") == ["C1", "B2", "B1", "A2", "A1"])
        #expect(JumpTest.sourceLevels(for: "A1").isEmpty)
    }

    @Test func aTestDrawsMostlyFromItsOwnLevelAndFromBelow() throws {
        let content = syntheticInstall(everyLevel)
        var generator = SeededGenerator(state: 7)
        let test = try #require(JumpTest.make(target: "C1", install: content, using: &generator))
        #expect(test.total == 30)
        #expect(Set(test.items.map(\.id)).count == test.total)
        let own = test.items.filter { $0.level == "C1" }
        #expect(own.count >= 18)
        #expect(Set(own.map(\.lessonID)) == Set(content.lessons(at: "C1").map(\.id)), "every C1 topic appears")
        #expect(test.items.contains { $0.level != "C1" })
        #expect(test.items.allSatisfy { JumpTest.sourceLevels(for: "C1").contains($0.level) })
        #expect(test.items.allSatisfy { $0.spec.isChecked && $0.spec.kind != .speak })
    }

    @Test func theA2TestHasTwentyItems() throws {
        var generator = SeededGenerator(state: 8)
        let test = try #require(JumpTest.make(target: "A2", install: syntheticInstall(everyLevel), using: &generator))
        #expect(test.total == 20)
        #expect(test.items.filter { $0.level == "A2" }.count >= 12)
    }

    @Test func eachAttemptHasANewQuestionOrder() throws {
        let content = syntheticInstall(everyLevel)
        var first = SeededGenerator(state: 1), second = SeededGenerator(state: 2)
        let a = try #require(JumpTest.make(target: "B2", install: content, using: &first))
        let b = try #require(JumpTest.make(target: "B2", install: content, using: &second))
        #expect(a.items.map(\.id) != b.items.map(\.id))
    }

    @Test func onlyAPerfectScorePasses() throws {
        let content = syntheticInstall(everyLevel)
        var generator = SeededGenerator(state: 3)
        var perfect = try #require(JumpTest.make(target: "A2", install: content, using: &generator))
        while let item = perfect.current {
            #expect(perfect.submit(correctResponse(item.spec)) == .correct)
            perfect.advance()
        }
        #expect(perfect.isFinished && perfect.isPerfect)
        #expect(perfect.resultLine == "Perfect. A2 is open.")

        var missed = try #require(JumpTest.make(target: "C2", install: content, using: &generator))
        var index = 0
        while let item = missed.current {
            missed.submit(index == 4 ? .text("b") : correctResponse(item.spec))
            missed.advance()
            index += 1
        }
        #expect(missed.isFinished && !missed.isPerfect)
        #expect(missed.correctCount == 29)
        #expect(missed.resultLine == "29 of 30. Try again.")
    }

    @Test func noTestExistsForA1OrForAnUntypedLevel() {
        let content = syntheticInstall(["A1": 4, "A2": 4])
        #expect(JumpTest.make(target: "A1", install: content) == nil)
        #expect(JumpTest.make(target: "B1", install: content) == nil)
        #expect(!JumpTest.isAvailable(target: "C2", install: content))
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
