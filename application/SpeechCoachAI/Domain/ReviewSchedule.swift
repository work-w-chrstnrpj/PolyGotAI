import Foundation
import FSRS

enum ReviewScheduleError: Error, Equatable {
    /// The review instant is earlier than this card's last review. The card stays as it was.
    case clockRollback
    /// Stored scheduler identity is not the selected version. History is left unchanged.
    case unsupportedVersion
    /// The scheduler refused the input. The stored card and rating history stay as they were.
    case schedulingFailed
    case invalidSettings
}

/// One recognition card. Productive use is stored separately and is not scheduled here.
struct ReviewCardState: Codable, Equatable, Identifiable {
    var itemId: String
    var senseId: String
    /// Always recognition. A meaning rating must not be stored as productive use.
    var kind: String
    var schedulerVersion: String
    var due: Date
    var stability: Double
    var difficulty: Double
    var elapsedDays: Double
    var scheduledDays: Double
    var learningSteps: Int
    var reps: Int
    var lapses: Int
    /// new, learning, review, or relearning.
    var phase: String
    var lastReview: Date
    /// Retention used for this rating; nil identifies the original 0.90 policy.
    var desiredRetention: Double?
    var id: String { "\(itemId)|\(senseId)|\(kind)" }
}

enum ReviewSchedule {
    /// swift-fsrs commit that implements FSRS-6. Fuzz is off so the same history repeats.
    static let version = "fsrs-6.0@d09cfc96c8f4c135ffc1905ac5627672906bf421"
    static let desiredRetention = 0.9
    static let maximumIntervalDays = 36_500.0
    static let kind = "recognition"

    static func schedule(existing: ReviewCardState?, rating: RecallRating, now: Date, itemId: String, senseId: String, settings: ReviewSettings = ReviewSettings()) throws -> ReviewCardState {
        try settings.validate()
        guard isFiniteInstant(now) else { throw ReviewScheduleError.schedulingFailed }
        if let existing {
            try rejectUnusableStoredCard(existing, itemId: itemId, senseId: senseId)
            guard now >= existing.lastReview else { throw ReviewScheduleError.clockRollback }
        }
        let engine = FSRS(parameters: .init(
            requestRetention: settings.desiredRetention,
            maximumInterval: maximumIntervalDays,
            w: FSRSDefaults.defaultWv6,
            enableFuzz: false,
            enableShortTerm: true,
            learningSteps: FSRSDefaults.defaultLearningSteps,
            relearningSteps: FSRSDefaults.defaultRelearningSteps))
        let current = try existing.map { try fsrsCard($0) } ?? Card(due: now, state: .new)
        let graded: RecordLogItem
        do {
            graded = try engine.next(card: current, now: now, grade: fsrsRating(rating))
        } catch is FSRSError {
            throw ReviewScheduleError.schedulingFailed
        }
        guard let phase = phaseName(graded.card.state) else { throw ReviewScheduleError.unsupportedVersion }
        return ReviewCardState(
            itemId: itemId, senseId: senseId, kind: kind, schedulerVersion: version,
            due: graded.card.due, stability: graded.card.stability, difficulty: graded.card.difficulty,
            elapsedDays: graded.card.elapsedDays, scheduledDays: graded.card.scheduledDays,
            learningSteps: graded.card.learningSteps, reps: graded.card.reps, lapses: graded.card.lapses,
            phase: phase, lastReview: graded.card.lastReview ?? now, desiredRetention: settings.desiredRetention)
    }

    static func returnPhrase(due: Date, now: Date) -> String {
        let seconds = due.timeIntervalSince(now)
        guard seconds.isFinite else { return "now" }
        if seconds <= 90 { return seconds <= 0 ? "now" : "1 minute" }
        if seconds < 3_600 {
            guard let minutes = wholeCount(seconds / 60) else { return "now" }
            return "\(minutes) minutes"
        }
        if seconds < 86_400 {
            guard let hours = wholeCount(seconds / 3_600) else { return "now" }
            return hours == 1 ? "1 hour" : "\(hours) hours"
        }
        guard let days = wholeCount(seconds / 86_400) else { return "now" }
        return days == 1 ? "1 day" : "\(days) days"
    }

    /// `FSRSDefaults.S_MIN_V6` in the pinned library. The symbol is internal to that module.
    private static let minimumStability = 0.001
    /// Literal upper clamp in the pinned stability formulas. It matches `maximumIntervalDays`.
    private static let maximumStability = 36_500.0

    private static func wholeCount(_ value: Double) -> Int? {
        let rounded = value.rounded()
        guard rounded.isFinite, rounded >= 1 else { return nil }
        return Int(exactly: rounded)
    }

    fileprivate static func isFiniteInstant(_ date: Date) -> Bool {
        date.timeIntervalSince1970.isFinite
    }

    /// A persisted card is graded history. The pinned algorithm treats stability 0 and
    /// difficulty 0 as empty memory and would replace it, so that pair is refused here.
    private static func rejectUnusableStoredCard(_ state: ReviewCardState, itemId: String, senseId: String) throws {
        guard state.itemId == itemId, state.senseId == senseId, state.kind == kind, state.schedulerVersion == version else {
            throw ReviewScheduleError.unsupportedVersion
        }
        switch state.phase {
        case "new", "learning", "review", "relearning":
            break
        default:
            throw ReviewScheduleError.unsupportedVersion
        }
        if let retention = state.desiredRetention {
            guard retention.isFinite, retention > 0, retention < 1 else { throw ReviewScheduleError.schedulingFailed }
        }
        guard storedMeasuresAreUsable(state) else { throw ReviewScheduleError.schedulingFailed }
    }

    fileprivate static func storedCardIsUsable(_ state: ReviewCardState, itemId: String, senseId: String) -> Bool {
        (try? rejectUnusableStoredCard(state, itemId: itemId, senseId: senseId)) != nil
    }

    /// Ranges the pinned FSRS-6 source actually writes or rejects:
    /// difficulty is clamped to `[1, 10]`; `nextState` throws below 1;
    /// stability below `S_MIN_V6` throws, and the stability formulas clamp to 36,500;
    /// a negative elapsed interval throws; `scheduledDays` is 0 during learning steps
    /// and otherwise at most `maximumInterval`; `reps` and `lapses` are incremented.
    private static func storedMeasuresAreUsable(_ state: ReviewCardState) -> Bool {
        guard isFiniteInstant(state.due), isFiniteInstant(state.lastReview) else { return false }
        guard state.stability.isFinite, state.difficulty.isFinite,
              state.elapsedDays.isFinite, state.scheduledDays.isFinite else { return false }
        guard state.difficulty >= 1, state.difficulty <= 10 else { return false }
        guard state.stability >= minimumStability, state.stability <= maximumStability else { return false }
        guard state.elapsedDays >= 0 else { return false }
        guard state.scheduledDays >= 0, state.scheduledDays <= maximumIntervalDays else { return false }
        guard state.learningSteps >= 0 else { return false }
        guard state.reps >= 0, state.reps < Int.max else { return false }
        guard state.lapses >= 0, state.lapses < Int.max else { return false }
        return true
    }

    private static func fsrsRating(_ rating: RecallRating) -> Rating {
        switch rating {
        case .again: .again
        case .hard: .hard
        case .good: .good
        case .easy: .easy
        }
    }

    private static func phaseName(_ state: CardState) -> String? {
        switch state {
        case .new: "new"
        case .learning: "learning"
        case .review: "review"
        case .relearning: "relearning"
        }
    }

    private static func fsrsCard(_ state: ReviewCardState) throws -> Card {
        let phase: CardState
        switch state.phase {
        case "new": phase = .new
        case "learning": phase = .learning
        case "review": phase = .review
        case "relearning": phase = .relearning
        default: throw ReviewScheduleError.unsupportedVersion
        }
        return Card(
            due: state.due, stability: state.stability, difficulty: state.difficulty,
            elapsedDays: state.elapsedDays, scheduledDays: state.scheduledDays,
            learningSteps: state.learningSteps, reps: state.reps, lapses: state.lapses,
            state: phase, lastReview: state.lastReview)
    }
}

struct ReviewQueuePlan: Equatable {
    var due: [VocabularyEnrollment]
    var waiting: Int
    var nextDue: Date?
    var blocked: Int
}

enum ReviewQueue {
    /// A saved word with no recognition card is ready for its first rating.
    /// A future due instant waits. An unknown version, a card the selected scheduler
    /// would refuse, or more than one history for the same enrolled sense stays blocked.
    /// Conflicting rows are not reduced to one card and are not offered as a new rating.
    static func plan(enrollments: [VocabularyEnrollment], cards: [ReviewCardState], now: Date) -> ReviewQueuePlan {
        var due: [VocabularyEnrollment] = []
        var waiting = 0
        var nextDue: Date?
        var blocked = 0
        let reviewing = enrollments.filter(\.inReview)
        guard ReviewSchedule.isFiniteInstant(now) else {
            return ReviewQueuePlan(due: [], waiting: 0, nextDue: nil, blocked: Set(reviewing.map(\.id)).count)
        }
        let repeatedEnrollmentIDs = repeatedIDs(reviewing.map(\.id))
        var histories: [String: [ReviewCardState]] = [:]
        for card in cards {
            histories["\(card.itemId)|\(card.senseId)", default: []].append(card)
        }
        for enrollment in reviewing.sorted(by: { ($0.lemma, $0.id) < ($1.lemma, $1.id) }) {
            if repeatedEnrollmentIDs.contains(enrollment.id) { continue }
            let matches = histories[enrollment.id] ?? []
            guard matches.count == 1, let card = matches.first else {
                if matches.isEmpty {
                    due.append(enrollment)
                } else {
                    blocked += 1
                }
                continue
            }
            guard ReviewSchedule.storedCardIsUsable(card, itemId: enrollment.itemId, senseId: enrollment.senseId) else {
                blocked += 1
                continue
            }
            if card.due <= now {
                due.append(enrollment)
            } else {
                waiting += 1
                if let current = nextDue {
                    if card.due < current { nextDue = card.due }
                } else {
                    nextDue = card.due
                }
            }
        }
        blocked += repeatedEnrollmentIDs.count
        return ReviewQueuePlan(due: due, waiting: waiting, nextDue: nextDue, blocked: blocked)
    }

    private static func repeatedIDs(_ ids: [String]) -> Set<String> {
        var seen: Set<String> = []
        var repeated: Set<String> = []
        for id in ids where !seen.insert(id).inserted {
            repeated.insert(id)
        }
        return repeated
    }
}

/// Prospective learner controls. Defaults preserve the original scheduling and queue behavior.
/// No policy change rewrites a due instant or synthesizes a rating.
struct ReviewSettings: Codable, Equatable {
    var desiredRetention: Double = ReviewSchedule.desiredRetention
    /// nil offers the full due queue; a value limits one session, never the backlog.
    var sessionLimit: Int?

    func validate() throws {
        guard desiredRetention.isFinite, desiredRetention > 0, desiredRetention < 1,
              sessionLimit.map({ $0 > 0 }) ?? true else { throw ReviewScheduleError.invalidSettings }
    }
}

struct ReviewSessionPlan: Equatable {
    var cards: [VocabularyEnrollment]
    var deferred: Int

    init(queue: ReviewQueuePlan, settings: ReviewSettings, open: OpenRecall?) throws {
        try settings.validate()
        var ordered = queue.due
        if let open, let index = ordered.firstIndex(where: { $0.itemId == open.itemId && $0.senseId == open.senseId }) {
            ordered.insert(ordered.remove(at: index), at: 0)
        }
        cards = Array(ordered.prefix(settings.sessionLimit ?? ordered.count))
        deferred = ordered.count - cards.count
    }
}
