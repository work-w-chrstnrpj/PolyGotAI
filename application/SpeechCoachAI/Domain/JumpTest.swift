import Foundation

/// The test that opens a locked CEFR level (owner rule, 2026-10-25: any locked level, even C2 from A1). Auto-checked
/// items from the target level and the levels below it, every topic of the target level at least once. Wrong items are
/// not asked again, "almost" does not count, and only a perfect score passes. A pass opens that level and all below.
struct JumpTest: Equatable {
    struct Item: Equatable, Identifiable {
        /// "lessonID/activityID"
        var id: String
        var lessonID: String
        /// The CEFR level of the lesson the item comes from.
        var level: String
        var activity: CurriculumActivity
        var spec: ExerciseSpec { activity.resolvedExercise }
    }

    /// 20 items for A2, 30 for B1 and above.
    static func questionCount(for target: String) -> Int { target.uppercased() == "A2" ? 20 : 30 }
    /// The target level must supply at least this many topics and items of its own.
    private static let minimumTargetTopics = 3
    private static let minimumTargetItems = 10

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

    /// The target level and every level below it, highest first (C1 draws from C1, B2, B1, A2 and A1).
    static func sourceLevels(for target: String) -> [String] {
        guard let index = LevelGate.levels.firstIndex(of: target.uppercased()), index > 0 else { return [] }
        return Array(LevelGate.levels[0...index].reversed())
    }

    /// Auto-checked, non-speaking items grouped by lesson, for one level's ready lessons.
    static func eligibleItems(level: String, install: CurriculumInstall) -> [[Item]] {
        install.lessons(at: level).filter(\.isReady).compactMap { lesson in
            let items = lesson.sessionActivities.compactMap { activity -> Item? in
                guard activity.exercise != nil, let kind = activity.resolvedExercise.kind,
                      activity.resolvedExercise.isChecked, kind != .speak else { return nil }
                return Item(id: "\(lesson.id)/\(activity.id)", lessonID: lesson.id, level: level.uppercased(), activity: activity)
            }
            return items.isEmpty ? nil : items
        }
    }

    /// A test exists once the target level has typed exercises of its own and the pool is large enough.
    static func isAvailable(target: String, install: CurriculumInstall) -> Bool {
        let own = eligibleItems(level: target, install: install)
        guard own.count >= minimumTargetTopics, own.reduce(0, { $0 + $1.count }) >= minimumTargetItems else { return false }
        let pool = sourceLevels(for: target).reduce(0) { $0 + eligibleItems(level: $1, install: install).reduce(0) { $0 + $1.count } }
        return pool >= questionCount(for: target)
    }

    /// A fresh test with a new question order each time; nil when no test exists for `target`. At least 60 percent of the
    /// items come from the target level (every one of its topics once, first); the rest come from the levels below.
    static func make<G: RandomNumberGenerator>(target: String, install: CurriculumInstall, using generator: inout G) -> JumpTest? {
        guard isAvailable(target: target, install: install) else { return nil }
        let count = questionCount(for: target)
        let ownTarget = Int((Double(count) * 0.6).rounded(.up))
        var chosen: [Item] = []
        var ownPool: [Item] = []
        for group in eligibleItems(level: target, install: install).shuffled(using: &generator) {
            var shuffled = group.shuffled(using: &generator)
            if chosen.count < ownTarget { chosen.append(shuffled.removeFirst()) }
            ownPool.append(contentsOf: shuffled)
        }
        ownPool.shuffle(using: &generator)
        chosen.append(contentsOf: ownPool.prefix(max(0, ownTarget - chosen.count)))
        var lowerPool: [Item] = []
        for level in sourceLevels(for: target).dropFirst() {
            lowerPool.append(contentsOf: eligibleItems(level: level, install: install).flatMap { $0 })
        }
        lowerPool.shuffle(using: &generator)
        chosen.append(contentsOf: lowerPool.prefix(max(0, count - chosen.count)))
        // Short of lower-level items: top up from the unused target-level items.
        let used = Set(chosen.map(\.id))
        chosen.append(contentsOf: ownPool.filter { !used.contains($0.id) }.prefix(max(0, count - chosen.count)))
        guard chosen.count == count else { return nil }
        return JumpTest(target: target.uppercased(), items: chosen.shuffled(using: &generator))
    }

    static func make(target: String, install: CurriculumInstall) -> JumpTest? {
        var generator = SystemRandomNumberGenerator()
        return make(target: target, install: install, using: &generator)
    }
}
