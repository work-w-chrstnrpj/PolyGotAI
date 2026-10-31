import Foundation

/// Which CEFR levels the learner may open (owner rules, 2026-10-25 and 2026-10-30). A level opens when the learner finishes
/// every lesson of the level before it with at least `passingAccuracy` right on the first try, or passes that level's test
/// with a perfect score: any locked level has its own test, even C2 from A1, and a pass opens that level and every level
/// below it. Lessons inside an unlocked level stay open in any order, and coach tracks are never gated.
struct LevelGate: Equatable {
    static let levels = ["A1", "A2", "B1", "B2", "C1", "C2"]
    /// Share of a lesson's checked exercises right on the first try that counts the lesson as done for unlocking.
    static let passingAccuracy = 0.5

    /// Unlocked levels in order; always starts with A1.
    let unlockedLevels: [String]
    /// Locked levels whose test can be taken now (every locked level whose test content exists).
    private let jumpTestTargets: Set<String>
    /// Level → (lessons done at the passing accuracy, ready lessons) for each level.
    private let qualified: [String: Progress]

    struct Progress: Equatable {
        var done: Int
        var total: Int
    }

    init(install: CurriculumInstall, journeys: [LessonJourney], passedTests: Set<String>) {
        let known = install.lessons + install.archivedLessons
        var levelOfLesson: [String: String] = [:]
        for lesson in known where levelOfLesson[lesson.id] == nil { levelOfLesson[lesson.id] = lesson.level.uppercased() }
        let opened = Set(journeys.compactMap { levelOfLesson[$0.lessonID] })
        let finishedJourneys = Dictionary(grouping: journeys.filter { $0.completedAt != nil }, by: \.lessonID)

        /// A finished journey whose first-try accuracy reaches the bar; a lesson without checked exercises counts once finished.
        func qualifies(_ lesson: ResolvedLesson) -> Bool {
            (finishedJourneys[lesson.id] ?? []).contains { journey in
                let exact = install.lesson(id: journey.lessonID, version: journey.contentVersion) ?? lesson
                guard let session = try? LessonSession.begin(lesson: exact, presenter: journey.presenter, now: .now, existing: journey),
                      let accuracy = session.exerciseAccuracy else { return true }
                return accuracy >= Self.passingAccuracy
            }
        }
        var progress: [String: Progress] = [:]
        for level in Self.levels {
            let ready = install.lessons(at: level).filter(\.isReady)
            progress[level] = Progress(done: ready.filter(qualifies).count, total: ready.count)
        }
        qualified = progress
        func finished(_ level: String) -> Bool {
            guard let value = progress[level] else { return false }
            return value.total > 0 && value.done == value.total
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

    /// For a locked level: how many lessons of the level before it are done at the passing accuracy.
    func progressToward(_ level: String) -> Progress? {
        guard let index = Self.levels.firstIndex(of: level.uppercased()), index > 0 else { return nil }
        return qualified[Self.levels[index - 1]]
    }

    /// The first level the learner cannot open yet; nil when all six are open.
    var nextLockedLevel: String? { Self.levels.first { !isUnlocked($0) } }

    /// True for every locked level whose test exists.
    func canTakeJumpTest(to level: String) -> Bool { jumpTestTargets.contains(level.uppercased()) }
}
