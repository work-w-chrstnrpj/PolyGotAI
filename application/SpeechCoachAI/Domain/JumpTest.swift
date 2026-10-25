import Foundation

/// The test that opens the next CEFR level early. Twenty auto-checked items from the level below, every topic
/// at least once. Wrong items are not asked again, "almost" does not count, and only 20 of 20 passes.
struct JumpTest: Equatable {
    struct Item: Equatable, Identifiable {
        /// "lessonID/activityID"
        var id: String
        var lessonID: String
        var activity: CurriculumActivity
        var spec: ExerciseSpec { activity.resolvedExercise }
    }

    static let questionCount = 20
    private static let minimumTopics = 5

    let target: String
    let items: [Item]
    private(set) var position = 0
    private(set) var results: [String: AnswerResult] = [:]
    /// Result of the current item, kept until the learner continues.
    private(set) var latest: AnswerResult?

    var current: Item? { position < items.count ? items[position] : nil }
    var total: Int { items.count }
    var isFinished: Bool { position >= items.count }
    var awaitingContinue: Bool { latest != nil }
    var progress: Double { total == 0 ? 1 : Double(position) / Double(total) }
    var correctCount: Int { results.values.filter { $0 == .correct }.count }
    var isPerfect: Bool { isFinished && total > 0 && correctCount == total }

    /// One short line for the result screen.
    var resultLine: String {
        isPerfect ? "Perfect. \(target) is open." : "\(correctCount) of \(total). Try again."
    }

    @discardableResult
    mutating func submit(_ response: ExerciseResponse) -> AnswerResult? {
        guard latest == nil, let item = current, let result = item.spec.evaluate(response) else { return nil }
        results[item.id] = result
        latest = result
        return result
    }

    mutating func advance() {
        guard latest != nil else { return }
        position += 1
        latest = nil
    }

    // MARK: Building

    /// The level whose lessons feed the test for `target` (A2 draws from A1).
    static func sourceLevel(for target: String) -> String? {
        guard let index = LevelGate.levels.firstIndex(of: target.uppercased()), index > 0 else { return nil }
        return LevelGate.levels[index - 1]
    }

    /// Auto-checked, non-speaking items from the source level's ready lessons, grouped by lesson.
    static func eligibleItems(target: String, install: CurriculumInstall) -> [[Item]] {
        guard let source = sourceLevel(for: target) else { return [] }
        return install.lessons(at: source).filter(\.isReady).compactMap { lesson in
            let items = lesson.sessionActivities.compactMap { activity -> Item? in
                guard activity.exercise != nil, let kind = activity.resolvedExercise.kind,
                      activity.resolvedExercise.isChecked, kind != .speak else { return nil }
                return Item(id: "\(lesson.id)/\(activity.id)", lessonID: lesson.id, activity: activity)
            }
            return items.isEmpty ? nil : items
        }
    }

    /// A test exists once the source level has typed exercises: enough items across several topics.
    static func isAvailable(target: String, install: CurriculumInstall) -> Bool {
        let groups = eligibleItems(target: target, install: install)
        return groups.count >= minimumTopics && groups.reduce(0) { $0 + $1.count } >= questionCount
    }

    /// A fresh test with a new question order each time; nil when no test exists for `target`.
    static func make<G: RandomNumberGenerator>(target: String, install: CurriculumInstall, using generator: inout G) -> JumpTest? {
        let groups = eligibleItems(target: target, install: install)
        guard isAvailable(target: target, install: install) else { return nil }
        var chosen: [Item] = []
        var pool: [Item] = []
        for group in groups.shuffled(using: &generator) {
            var shuffled = group.shuffled(using: &generator)
            if chosen.count < questionCount { chosen.append(shuffled.removeFirst()) }
            pool.append(contentsOf: shuffled)
        }
        pool.shuffle(using: &generator)
        chosen.append(contentsOf: pool.prefix(max(0, questionCount - chosen.count)))
        return JumpTest(target: target.uppercased(), items: chosen.shuffled(using: &generator))
    }

    static func make(target: String, install: CurriculumInstall) -> JumpTest? {
        var generator = SystemRandomNumberGenerator()
        return make(target: target, install: install, using: &generator)
    }
}
