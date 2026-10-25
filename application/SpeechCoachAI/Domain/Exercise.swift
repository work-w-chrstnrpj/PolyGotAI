import Foundation

enum ExerciseType: String, CaseIterable {
    case choice, wordBank, fillBlank, match, order, spotError, listenType, speak, open
}

/// What the learner submitted for one exercise.
enum ExerciseResponse: Equatable {
    case text(String)
    /// Tiles in chosen order (wordBank) or items in chosen order (order).
    case sequence([String])
    /// Left/right pairs the learner matched (match).
    case pairs([[String]])
}

/// Typed, auto-checked behavior for one activity. Absent on legacy activities, which map through `legacy(for:)`.
struct ExerciseSpec: Codable, Equatable {
    var type: String
    /// choice: the buttons. wordBank: tiles including distractors.
    var options: [String]? = nil
    /// Every answer that counts as correct. The first is shown as the model answer.
    var accepted: [String]? = nil
    /// match: left/right pairs.
    var pairs: [[String]]? = nil
    /// order: items in the correct order (shown shuffled).
    var items: [String]? = nil
    /// Text spoken by the on-device voice when no recorded clip exists (listenType, speak, audio choices).
    var audioText: String? = nil

    var kind: ExerciseType? { ExerciseType(rawValue: type) }
    var isChecked: Bool { kind != nil && kind != .open }
    var modelAnswer: String? { accepted?.first }

    /// Why this spec cannot run, or nil when it is usable. A lesson containing a broken spec stays closed.
    func problem(hasClip: Bool = false) -> String? {
        guard let kind else { return "unknown exercise type" }
        func blank(_ values: [String]?) -> Bool {
            guard let values else { return true }
            return values.isEmpty || values.contains { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        }
        switch kind {
        case .open:
            return nil
        case .choice:
            guard !blank(options), !blank(accepted), let options, let accepted else { return "choice needs options and accepted" }
            // Choices are buttons, so they match exactly: capitalization and punctuation can be the point of the question.
            if Set(options).count != options.count { return "duplicate options" }
            if options.count < 2 { return "choice needs at least two options" }
            if !accepted.allSatisfy({ options.contains($0) }) { return "accepted answer is not an option" }
        case .wordBank:
            guard !blank(options), !blank(accepted), let options, let model = accepted?.first else { return "wordBank needs options and accepted" }
            var pool = options.map { AnswerChecker.normalize($0) }
            for tile in model.split(separator: " ").map({ AnswerChecker.normalize(String($0)) }) where !tile.isEmpty {
                guard let index = pool.firstIndex(of: tile) else { return "tiles do not cover the answer" }
                pool.remove(at: index)
            }
        case .fillBlank, .spotError, .listenType, .speak:
            if blank(accepted) { return "\(type) needs accepted" }
            let hasText = !(audioText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            if (kind == .listenType || kind == .speak), !hasText, !hasClip { return "\(type) needs audioText or a clip" }
            if kind == .spotError, blank(options) { return "spotError needs the sentence tokens in options" }
        case .match:
            guard let pairs, pairs.count >= 3, pairs.allSatisfy({ $0.count == 2 && !$0[0].isEmpty && !$0[1].isEmpty }) else { return "match needs three or more pairs" }
            if Set(pairs.map { $0[0] }).count != pairs.count || Set(pairs.map { $0[1] }).count != pairs.count { return "duplicate match side" }
        case .order:
            guard let items, items.count >= 3, !blank(items), Set(items).count == items.count else { return "order needs three or more distinct items" }
        }
        return nil
    }

    /// Checks one response. Open exercises are not checked and return nil.
    func evaluate(_ response: ExerciseResponse) -> AnswerResult? {
        guard let kind, kind != .open else { return nil }
        let accepted = accepted ?? []
        switch (kind, response) {
        case (.choice, .text(let text)):
            return accepted.contains(text) ? .correct : .incorrect
        case (.wordBank, .sequence(let tiles)):
            return AnswerChecker.check(tiles.joined(separator: " "), accepted: accepted, allowAlmost: false)
        case (.fillBlank, .text(let text)), (.spotError, .text(let text)), (.listenType, .text(let text)), (.speak, .text(let text)):
            return AnswerChecker.check(text, accepted: accepted)
        case (.match, .pairs(let given)):
            let expected = Set((pairs ?? []).map { "\($0[0])\u{1F}\($0[1])" })
            let chosen = Set(given.filter { $0.count == 2 }.map { "\($0[0])\u{1F}\($0[1])" })
            return expected == chosen ? .correct : .incorrect
        case (.order, .sequence(let given)):
            return given == (items ?? []) ? .correct : .incorrect
        default:
            return .incorrect
        }
    }

    // MARK: Stored form
    // A lesson journey keeps one text per answered activity. These helpers turn any response into that text and back,
    // so accuracy can be recomputed after the app restarts without a new stored field.

    private static let listSeparator = " | "

    func storedText(_ response: ExerciseResponse) -> String {
        switch response {
        case .text(let text): text.trimmingCharacters(in: .whitespacesAndNewlines)
        case .sequence(let items): items.joined(separator: kind == .order ? Self.listSeparator : " ")
        case .pairs(let pairs): pairs.map { $0.joined(separator: "=") }.joined(separator: Self.listSeparator)
        }
    }

    func response(fromStored stored: String) -> ExerciseResponse? {
        switch kind {
        case .wordBank: return .sequence(stored.split(separator: " ").map(String.init))
        case .order: return .sequence(stored.components(separatedBy: Self.listSeparator))
        case .match: return .pairs(stored.components(separatedBy: Self.listSeparator).map { $0.components(separatedBy: "=") })
        case .choice, .fillBlank, .spotError, .listenType, .speak: return .text(stored)
        case .open, .none: return nil
        }
    }

    func result(forStored stored: String) -> AnswerResult? {
        response(fromStored: stored).flatMap(evaluate)
    }

    /// Activities without a spec keep their v1 behavior: answer buttons when a choice set exists, otherwise open.
    static func legacy(for activity: CurriculumActivity) -> ExerciseSpec {
        if let choices = activity.choiceSet, let answer = activity.answer {
            return ExerciseSpec(type: "choice", options: choices, accepted: [answer])
        }
        return ExerciseSpec(type: "open")
    }
}

extension CurriculumActivity {
    var resolvedExercise: ExerciseSpec { exercise ?? ExerciseSpec.legacy(for: self) }
}

/// Runs the exercises of one lesson: one at a time, first-try results, wrong items return once at the end.
struct ExerciseSession: Equatable {
    struct Item: Equatable, Identifiable {
        var id: String
        var spec: ExerciseSpec
    }

    let items: [Item]
    private(set) var queue: [String]
    private(set) var firstResults: [String: AnswerResult]
    private(set) var latest: AnswerResult?
    private(set) var requeued: Set<String> = []
    private(set) var stepsDone = 0

    init(items: [Item]) {
        self.items = items
        self.queue = items.map(\.id)
        self.firstResults = [:]
    }

    init(activities: [CurriculumActivity]) {
        self.init(items: activities.map { Item(id: $0.id, spec: $0.resolvedExercise) })
    }

    var current: Item? {
        guard let id = queue.first else { return nil }
        return items.first { $0.id == id }
    }

    var isFinished: Bool { queue.isEmpty }
    /// True while the learner has submitted the current item and not yet continued.
    var awaitingContinue: Bool { latest != nil }
    var totalSteps: Int { items.count + requeued.count }
    var progress: Double { totalSteps == 0 ? 1 : Double(stepsDone) / Double(totalSteps) }

    var checkedItems: [Item] { items.filter(\.spec.isChecked) }
    var firstTryCorrect: Int { firstResults.values.filter { $0 == .correct }.count }
    /// Weighted first-try accuracy over checked items answered so far; nil before any answer.
    var accuracy: Double? {
        guard !firstResults.isEmpty else { return nil }
        return firstResults.values.reduce(0) { $0 + $1.weight } / Double(firstResults.count)
    }

    /// Checks the current item. Ignored while a result is waiting for Continue.
    @discardableResult
    mutating func submit(_ response: ExerciseResponse) -> AnswerResult? {
        guard latest == nil, let item = current else { return nil }
        guard let result = item.spec.evaluate(response) else {
            // Open exercises are not scored; any response lets the learner continue.
            latest = .correct
            return nil
        }
        if firstResults[item.id] == nil { firstResults[item.id] = result }
        latest = result
        return result
    }

    /// Moves on. A wrong first answer sends the item to the end once.
    mutating func advance() {
        guard latest != nil, let id = queue.first else { return }
        queue.removeFirst()
        stepsDone += 1
        if latest == .incorrect, !requeued.contains(id) {
            requeued.insert(id)
            queue.append(id)
        }
        latest = nil
    }
}

extension LessonSession {
    /// First-try results of the auto-checked activities answered so far, in lesson order.
    var exerciseResults: [(activity: CurriculumActivity, result: AnswerResult)] {
        activities.compactMap { activity in
            guard activity.exercise != nil, activity.resolvedExercise.isChecked,
                  let response = response(for: activity.id),
                  let first = response.firstResponseText ?? response.unaidedText ?? response.assistedText,
                  let result = activity.resolvedExercise.result(forStored: first) else { return nil }
            return (activity, result)
        }
    }

    /// Weighted first-try accuracy (correct 1, almost 0.5) over the checked activities answered; nil before any answer.
    var exerciseAccuracy: Double? {
        let results = exerciseResults
        guard !results.isEmpty else { return nil }
        return results.reduce(0) { $0 + $1.result.weight } / Double(results.count)
    }

    /// Activities answered wrongly on the first try.
    var missedExercises: [CurriculumActivity] {
        exerciseResults.filter { $0.result == .incorrect }.map(\.activity)
    }
}
