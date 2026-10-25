import Foundation

/// Which CEFR levels the learner may open (owner rule, 2026-10-25). A level opens when the learner finishes the
/// previous level's lessons, or passes that level's test with a perfect score: any locked level has its own test,
/// even C2 from A1, and a pass opens that level and every level below it. Lessons inside an unlocked level stay open
/// in any order, and coach tracks are never gated.
struct LevelGate: Equatable {
    static let levels = ["A1", "A2", "B1", "B2", "C1", "C2"]

    /// Unlocked levels in order; always starts with A1.
    let unlockedLevels: [String]
    /// Locked levels whose test can be taken now (every locked level whose test content exists).
    private let jumpTestTargets: Set<String>

    init(install: CurriculumInstall, journeys: [LessonJourney], passedTests: Set<String>) {
        let known = install.lessons + install.archivedLessons
        var levelOfLesson: [String: String] = [:]
        for lesson in known where levelOfLesson[lesson.id] == nil { levelOfLesson[lesson.id] = lesson.level.uppercased() }
        let opened = Set(journeys.compactMap { levelOfLesson[$0.lessonID] })
        let finishedIDs = Set(journeys.filter { $0.completedAt != nil }.map(\.lessonID))

        func finished(_ level: String) -> Bool {
            let ready = install.lessons(at: level).filter(\.isReady)
            return !ready.isEmpty && ready.allSatisfy { finishedIDs.contains($0.id) }
        }
        // A level opened in v1 or passed by test also opens every level below it.
        var highest = 0
        for (index, level) in Self.levels.enumerated() where index > 0 {
            let previous = Self.levels[index - 1]
            if passedTests.contains(level) || opened.contains(level) || finished(previous) { highest = index }
        }
        unlockedLevels = Array(Self.levels[0...highest])
        jumpTestTargets = Set(Self.levels.dropFirst(highest + 1).filter { JumpTest.isAvailable(target: $0, install: install) })
    }

    func isUnlocked(_ level: String) -> Bool { unlockedLevels.contains(level.uppercased()) }

    /// The first level the learner cannot open yet; nil when all six are open.
    var nextLockedLevel: String? { Self.levels.first { !isUnlocked($0) } }

    /// True for every locked level whose test exists.
    func canTakeJumpTest(to level: String) -> Bool { jumpTestTargets.contains(level.uppercased()) }
}
