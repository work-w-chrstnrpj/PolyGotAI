import Foundation

/// Which CEFR levels the learner may open. Levels unlock in order (owner rule, 2026-10-25): finish the
/// previous level's lessons, or pass the next level's jump test with a perfect score. Lessons inside an
/// unlocked level stay open in any order, and coach tracks are never gated.
struct LevelGate: Equatable {
    static let levels = ["A1", "A2", "B1", "B2", "C1", "C2"]

    /// Unlocked levels in order; always starts with A1.
    let unlockedLevels: [String]
    /// Levels whose jump test can be taken now (the first locked level, when its test content exists).
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
        if highest + 1 < Self.levels.count, JumpTest.isAvailable(target: Self.levels[highest + 1], install: install) {
            jumpTestTargets = [Self.levels[highest + 1]]
        } else {
            jumpTestTargets = []
        }
    }

    func isUnlocked(_ level: String) -> Bool { unlockedLevels.contains(level.uppercased()) }

    /// The first level the learner cannot open yet; nil when all six are open.
    var nextLockedLevel: String? { Self.levels.first { !isUnlocked($0) } }

    /// True only for the level right after the highest unlocked one, and only when its test exists.
    func canTakeJumpTest(to level: String) -> Bool { jumpTestTargets.contains(level.uppercased()) }
}
