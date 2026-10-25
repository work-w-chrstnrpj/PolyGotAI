import Foundation

/// One next action. Only installed personal-use INTRO practice is connected to a
/// difficulty; other trainer packs stay unavailable. A preference is a destination,
/// not a level or a score.
enum SuggestionAction: String, Codable, Equatable, CaseIterable {
    case reviewWords, openLesson, speechLab

    var preferenceTitle: String {
        switch self {
        case .reviewWords: "Review due words"
        case .openLesson: "Open a lesson"
        case .speechLab: "Speech Lab"
        }
    }

    static let noPreferenceTitle = "No preference"
}

enum ObservedDifficulty: String, Codable, Equatable, CaseIterable {
    case retrieval, grammar, followUp, clarity

    var title: String {
        switch self {
        case .retrieval: "Remember a phrase"
        case .grammar: "Match subjects and verbs"
        case .followUp: "Answer follow-up questions"
        case .clarity: "Listen and replay for clarity"
        }
    }
}

struct LessonOffer: Equatable {
    var id: String
    var title: String
}

struct DifficultyObservation: Equatable {
    var difficulty: ObservedDifficulty
    var at: Date?
    var source: Source = .reported
    enum Source: Equatable { case reported, recall, vocabularyFeedback, grammarAssistance, grammarFeedback }
}

/// A learner's choice for one local day. It does not erase the grounded reason.
struct DailyPracticeChoice: Codable, Equatable {
    var day: String
    var action: SuggestionAction
    var difficulty: ObservedDifficulty? = nil
}

/// Unsaved preference stays in memory through a failed save. A new learner epoch drops it.
struct PracticeGoalDraft: Equatable {
    var epoch: UUID
    var selection: SuggestionAction?
    var saved: SuggestionAction?
    var hasSaveFailure = false

    var isDirty: Bool { selection != saved }

    func refreshed(saved: SuggestionAction?, epoch: UUID) -> PracticeGoalDraft {
        guard self.epoch == epoch else {
            return PracticeGoalDraft(epoch: epoch, selection: saved, saved: saved)
        }
        if isDirty || hasSaveFailure {
            return PracticeGoalDraft(epoch: epoch, selection: selection, saved: saved, hasSaveFailure: hasSaveFailure)
        }
        return PracticeGoalDraft(epoch: epoch, selection: saved, saved: saved)
    }

    mutating func recordSaveSuccess() {
        saved = selection
        hasSaveFailure = false
    }

    mutating func recordSaveFailure() {
        hasSaveFailure = true
    }
}

struct PracticeAlternative: Equatable, Identifiable {
    var id: SuggestionAction { action }
    var action: SuggestionAction
    var title: String
    var detail: String
}

struct PracticeSuggestion: Equatable {
    var action: SuggestionAction
    var title: String
    var reason: String
    var groundedAction: SuggestionAction
    var groundedTitle: String
    var groundedReason: String
    var lessonID: String?
    var chosenByLearner: Bool
    var evidenceIsInsufficient: Bool
    var alternatives: [PracticeAlternative]
    var focus: ObservedDifficulty? = nil
}

struct PracticeFacts: Equatable {
    var now: Date
    var dueReviewCount: Int
    var lesson: LessonOffer?
    var resuming = false
    var recallMissedAt: Date?
    var vocabularyFeedbackAt: Date?
    var assistedGrammarAt: Date?
    var hasUndatedAssistedGrammar = false
    var grammarFeedbackAt: Date?
    var savedChoice: DailyPracticeChoice?
    /// Durable destination preference. Nil keeps the original no-goal ranking.
    var goal: SuggestionAction? = nil
    var focusLesson: LessonOffer? = nil
}

/// Precedence, recorded for SC-T051: an available choice for this local day wins.
/// Otherwise the newest supported difficulty wins. The same time keeps grammar,
/// then retrieval, then follow-up, then clarity. With no difficulty, due reviews
/// come first, then an available practice preference, then a ready lesson, then
/// Speech Lab. One primary action; the others stay choices.
enum PracticeRecommendation {
    static let preferenceExplanation = "No preference, review due words, open a lesson, or Speech Lab. This is used when nothing is due and no difficulty is named. It is not a daily target, a level, or a score. A choice for today still comes first."

    static func localDay(_ date: Date, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    static func selectLesson(journeys: [LessonJourney], lessons: [ResolvedLesson], archivedLessons: [ResolvedLesson] = []) -> (lesson: LessonOffer?, resuming: Bool) {
        let install = CurriculumInstall(lessons: lessons, problem: nil, archivedLessons: archivedLessons)
        let courses = journeys.filter { $0.practiceOrigin == nil && $0.personalCheck == nil }
        let ready = lessons.filter(\.isReady)
        for journey in courses.reversed() where journey.completedAt == nil {
            guard let offered = ready.first(where: { $0.id == journey.lessonID && $0.objectiveId == journey.objectiveID }),
                  let opening = try? install.opening(offered, saved: courses), opening.journey?.completedAt == nil else { continue }
            return (LessonOffer(id: offered.id, title: opening.lesson.title), true)
        }
        // Do not recommend an already completed course or one whose saved version cannot open.
        for offered in ready {
            guard let opening = try? install.opening(offered, saved: courses), opening.journey == nil else { continue }
            return (LessonOffer(id: offered.id, title: offered.title), false)
        }
        return (nil, false)
    }

    /// Only the installed personal-use INTRO routes are offered. Other trainer packs stay unavailable.
    static func focusLesson(journeys: [LessonJourney], install: CurriculumInstall) -> LessonOffer? {
        let courses = journeys.filter { $0.practiceOrigin == nil && $0.personalCheck == nil }
        guard let offered = install.lessons.first(where: { $0.id == "intro-01" && $0.objectiveId == "INTRO-01" && $0.isReady }),
              let opening = try? install.opening(offered, saved: courses),
              opening.lesson.sessionActivities.contains(where: { $0.kind == "recall" || $0.kind == "vocabularyRecall" }),
              opening.lesson.sessionActivities.contains(where: { $0.kind == "listening" && $0.playbackPath != nil }) else { return nil }
        return LessonOffer(id: offered.id, title: opening.lesson.title)
    }

    static func grammarSignals(_ journeys: [LessonJourney]) -> (dated: Date?, undated: Bool) {
        var dated: Date?
        var undated = false
        for journey in journeys {
            let assisted = journey.responses.contains { $0.kind == "grammar" && ($0.assistedText != nil || $0.answerRevealed) }
            guard assisted else { continue }
            if let completed = journey.completedAt { dated = later(dated, completed) }
            else { undated = true }
        }
        return (dated, undated)
    }

    static func latestMiss(_ recalls: [VocabularyRecallAttempt]) -> Date? {
        recalls.filter { $0.rating == .again && $0.revealed }.map(\.createdAt).max()
    }

    /// Organization feedback is not a follow-up, and no category is a clarity score.
    static func feedbackDates(_ attempts: [AttemptSnapshot]) -> (grammar: Date?, vocabulary: Date?) {
        var grammar: Date?
        var vocabulary: Date?
        for attempt in attempts where attempt.text.isVisible {
            for feedback in attempt.feedback {
                for item in feedback.improvements {
                    switch item.category {
                    case .grammar: grammar = later(grammar, feedback.createdAt)
                    case .vocabulary: vocabulary = later(vocabulary, feedback.createdAt)
                    case .organization: continue
                    }
                }
            }
        }
        return (grammar, vocabulary)
    }

    static func suggest(_ facts: PracticeFacts, reported: [DifficultyObservation] = [], calendar: Calendar = .current) -> PracticeSuggestion {
        let grounded = groundedSuggestion(facts, observations: derived(facts) + reported)
        let today = localDay(facts.now, calendar: calendar)
        if let choice = facts.savedChoice, choice.day == today, let difficulty = choice.difficulty,
           choice.action == .openLesson {
            guard facts.focusLesson != nil else {
                var fallback = grounded
                let explanation = " Your chosen focus is unavailable in the saved content version; its saved work is preserved."
                fallback.reason += explanation
                fallback.groundedReason += explanation
                return fallback
            }
            var chosen = focusedSuggestion(difficulty, facts: facts, reason: "You chose \(difficulty.title.lowercased()) for today.")
            chosen.chosenByLearner = true
            chosen.groundedAction = grounded.action
            chosen.groundedTitle = grounded.title
            chosen.groundedReason = grounded.reason
            chosen.alternatives = alternatives(primary: .openLesson, facts: facts, grounded: grounded)
            return chosen
        }
        if let choice = facts.savedChoice, choice.day == today, choice.action != grounded.action, available(choice.action, facts) {
            return override(choice.action, grounded: grounded, facts: facts)
        }
        return grounded
    }

    private static func derived(_ facts: PracticeFacts) -> [DifficultyObservation] {
        var items: [DifficultyObservation] = []
        if let at = facts.recallMissedAt { items.append(DifficultyObservation(difficulty: .retrieval, at: at, source: .recall)) }
        if let at = facts.vocabularyFeedbackAt { items.append(DifficultyObservation(difficulty: .retrieval, at: at, source: .vocabularyFeedback)) }
        if let at = facts.assistedGrammarAt { items.append(DifficultyObservation(difficulty: .grammar, at: at, source: .grammarAssistance)) }
        if facts.hasUndatedAssistedGrammar { items.append(DifficultyObservation(difficulty: .grammar, at: nil, source: .grammarAssistance)) }
        if let at = facts.grammarFeedbackAt { items.append(DifficultyObservation(difficulty: .grammar, at: at, source: .grammarFeedback)) }
        return items
    }

    private static func groundedSuggestion(_ facts: PracticeFacts, observations: [DifficultyObservation]) -> PracticeSuggestion {
        if let difficulty = winner(observations) {
            return suggestion(for: difficulty, facts: facts, insufficient: false)
        }
        if facts.dueReviewCount > 0 { return reviewSuggestion(facts, insufficient: true, lead: "These words are due. There is not enough other evidence to name a difficulty.") }
        if let goal = facts.goal {
            if available(goal, facts) { return preferredGoal(goal, facts: facts) }
            return unavailableGoal(goal, facts: facts)
        }
        if facts.lesson != nil { return lessonSuggestion(facts, insufficient: true, title: nil, reason: "There is not enough evidence to name a difficulty. \(facts.resuming ? "Continue the lesson in progress." : "\(facts.lesson?.title ?? "A lesson") is ready.") This is not an English-level placement.") }
        return make(.speechLab, title: "Record an introduction", reason: "There is not enough evidence to name a difficulty, and no lesson is ready. This is not an English-level placement.", facts: facts, insufficient: true, lessonID: nil)
    }

    /// Due reviews return before this is reached, so a review preference is used here
    /// only if that order changes. An unavailable review preference is explained below.
    private static func preferredGoal(_ goal: SuggestionAction, facts: PracticeFacts) -> PracticeSuggestion {
        switch goal {
        case .reviewWords:
            return reviewSuggestion(facts, insufficient: true, lead: "There is not enough evidence to name a difficulty. You prefer reviewing words, and some are due. This is not an English-level placement.")
        case .openLesson:
            return lessonSuggestion(facts, insufficient: true, title: nil, reason: "There is not enough evidence to name a difficulty. You prefer the lesson, so that is the suggestion. This is not an English-level placement.")
        case .speechLab:
            let ready = facts.lesson == nil ? " No lesson is ready." : " The ready lesson stays available as another choice."
            return make(.speechLab, title: "Record in Speech Lab", reason: "There is not enough evidence to name a difficulty. You prefer Speech Lab, so that is the suggestion.\(ready) This is not an English-level placement.", facts: facts, insufficient: true, lessonID: nil)
        }
    }

    private static func unavailableGoal(_ goal: SuggestionAction, facts: PracticeFacts) -> PracticeSuggestion {
        let because: String
        switch goal {
        case .reviewWords:
            because = "You prefer reviewing words, but nothing is due, so that preference cannot be used."
        case .openLesson:
            because = "You prefer a lesson, but no lesson is ready, so that preference cannot be used."
        case .speechLab:
            because = "You prefer Speech Lab, but that destination cannot be used."
        }
        let reason = "\(because) There is not enough evidence to name a difficulty."
        if facts.lesson != nil {
            let next = facts.resuming ? "Continue the lesson in progress." : "\(facts.lesson?.title ?? "A lesson") is ready."
            return lessonSuggestion(facts, insufficient: true, title: nil, reason: "\(reason) \(next) This is not an English-level placement.")
        }
        return make(.speechLab, title: "Record an introduction", reason: "\(reason) No lesson is ready. This is not an English-level placement.", facts: facts, insufficient: true, lessonID: nil)
    }

    private static func suggestion(for observation: DifficultyObservation, facts: PracticeFacts, insufficient: Bool) -> PracticeSuggestion {
        let difficulty = observation.difficulty
        let reason: String
        switch observation.source {
        case .recall: reason = "A recent recall was marked Again."
        case .vocabularyFeedback: reason = "Saved coaching feedback identified vocabulary to practise."
        case .grammarAssistance: reason = "A grammar answer used an example or a correction."
        case .grammarFeedback: reason = "Saved coaching feedback identified grammar to practise."
        case .reported: reason = "You reported \(difficulty == .followUp ? "a difficult follow-up" : difficulty.rawValue + " difficulty")."
        }
        if facts.focusLesson != nil && (difficulty != .retrieval || facts.dueReviewCount == 0) {
            return focusedSuggestion(difficulty, facts: facts, reason: reason)
        }
        switch difficulty {
        case .retrieval:
            if facts.dueReviewCount > 0 {
                return reviewSuggestion(facts, insufficient: insufficient, lead: "\(reason) Review the due meanings. This is not an English-level placement.")
            }
            return lessonSuggestion(facts, insufficient: insufficient, title: "Practice that meaning in the lesson", reason: "\(reason) Nothing is due right now. This is not an English-level placement.")
        case .grammar:
            return lessonSuggestion(facts, insufficient: insufficient, title: "Practice that grammar again", reason: "\(reason) Return to the available lesson. This is not an English-level placement.")
        case .followUp:
            return make(.speechLab, title: "Answer another question", reason: "A follow-up was difficult. Record a short answer in your own words. Compatible follow-up practice is unavailable for this saved content, and this is not an English-level placement.", facts: facts, insufficient: insufficient, lessonID: nil)
        case .clarity:
            return lessonSuggestion(facts, insufficient: insufficient, title: "Listen, then try again", reason: "Clarity was marked as difficult. Replay the lesson listening clip. Speech has not been scored, and compatible focused practice is unavailable for this saved content.")
        }
    }

    private static func focusedSuggestion(_ difficulty: ObservedDifficulty, facts: PracticeFacts, reason: String) -> PracticeSuggestion {
        var suggestion = make(.openLesson, title: difficulty.title,
            reason: reason + " Optional Introductions personal-use practice is available. Content has not had qualified educator review; speech is not scored and this is not an English-level placement.",
            facts: facts, insufficient: false, lessonID: facts.focusLesson?.id)
        suggestion.focus = difficulty
        return suggestion
    }

    private static func reviewSuggestion(_ facts: PracticeFacts, insufficient: Bool, lead: String) -> PracticeSuggestion {
        let count = facts.dueReviewCount
        let title = "Revisit \(count) \(count == 1 ? "word" : "words")"
        return make(.reviewWords, title: title, reason: lead, facts: facts, insufficient: insufficient, lessonID: nil)
    }

    private static func lessonSuggestion(_ facts: PracticeFacts, insufficient: Bool, title: String?, reason: String) -> PracticeSuggestion {
        guard let lesson = facts.lesson else {
            return make(.speechLab, title: "Record an introduction", reason: reason + " No lesson is ready.", facts: facts, insufficient: true, lessonID: nil)
        }
        let resolvedTitle = title ?? (facts.resuming ? "Continue \(lesson.title)" : "Start \(lesson.title)")
        return make(.openLesson, title: resolvedTitle, reason: reason, facts: facts, insufficient: insufficient, lessonID: lesson.id)
    }

    private static func override(_ action: SuggestionAction, grounded: PracticeSuggestion, facts: PracticeFacts) -> PracticeSuggestion {
        let title: String
        let lessonID: String?
        switch action {
        case .reviewWords:
            title = "Revisit \(facts.dueReviewCount) \(facts.dueReviewCount == 1 ? "word" : "words")"
            lessonID = nil
        case .openLesson:
            title = facts.resuming ? "Continue \(facts.lesson?.title ?? "the lesson")" : "Start \(facts.lesson?.title ?? "the lesson")"
            lessonID = facts.lesson?.id
        case .speechLab:
            title = "Record in Speech Lab"
            lessonID = nil
        }
        return PracticeSuggestion(
            action: action, title: title, reason: "You chose this for today.",
            groundedAction: grounded.action, groundedTitle: grounded.title, groundedReason: grounded.reason,
            lessonID: lessonID, chosenByLearner: true, evidenceIsInsufficient: grounded.evidenceIsInsufficient,
            alternatives: alternatives(primary: action, facts: facts, grounded: grounded))
    }

    private static func make(_ action: SuggestionAction, title: String, reason: String, facts: PracticeFacts, insufficient: Bool, lessonID: String?) -> PracticeSuggestion {
        let suggestion = PracticeSuggestion(
            action: action, title: title, reason: reason,
            groundedAction: action, groundedTitle: title, groundedReason: reason,
            lessonID: lessonID, chosenByLearner: false, evidenceIsInsufficient: insufficient, alternatives: [])
        return PracticeSuggestion(
            action: suggestion.action, title: suggestion.title, reason: suggestion.reason,
            groundedAction: suggestion.groundedAction, groundedTitle: suggestion.groundedTitle, groundedReason: suggestion.groundedReason,
            lessonID: suggestion.lessonID, chosenByLearner: false, evidenceIsInsufficient: insufficient,
            alternatives: alternatives(primary: action, facts: facts, grounded: suggestion))
    }

    private static func alternatives(primary: SuggestionAction, facts: PracticeFacts, grounded: PracticeSuggestion) -> [PracticeAlternative] {
        var items: [PracticeAlternative] = []
        if primary != grounded.action {
            items.append(PracticeAlternative(action: grounded.action, title: grounded.title, detail: "Suggested from your practice"))
        }
        if primary != .reviewWords, grounded.action != .reviewWords, facts.dueReviewCount > 0 {
            let detail = facts.goal == .reviewWords ? "Your practice preference · \(facts.dueReviewCount) ready" : "\(facts.dueReviewCount) ready"
            items.append(PracticeAlternative(action: .reviewWords, title: "Revisit due words", detail: detail))
        }
        if primary != .openLesson, grounded.action != .openLesson, facts.lesson != nil {
            let detail = facts.goal == .openLesson ? "Your practice preference" : "Read, listen, and practice"
            items.append(PracticeAlternative(action: .openLesson, title: facts.resuming ? "Continue the lesson" : "Open the lesson", detail: detail))
        }
        if primary != .speechLab, grounded.action != .speechLab {
            let detail = facts.goal == .speechLab ? "Your practice preference" : "Replay and self-review"
            items.append(PracticeAlternative(action: .speechLab, title: "Record in Speech Lab", detail: detail))
        }
        return items
    }

    private static func available(_ action: SuggestionAction, _ facts: PracticeFacts) -> Bool {
        switch action {
        case .reviewWords: facts.dueReviewCount > 0
        case .openLesson: facts.lesson != nil
        case .speechLab: true
        }
    }

    private static func winner(_ items: [DifficultyObservation]) -> DifficultyObservation? {
        items.reduce(nil) { current, next in
            guard let current else { return next }
            switch (current.at, next.at) {
            case let (lhs?, rhs?) where rhs != lhs:
                return rhs > lhs ? next : current
            case (nil, .some):
                return next
            case (.some, nil):
                return current
            default:
                return tieRank(next.difficulty) < tieRank(current.difficulty) ? next : current
            }
        }
    }

    private static func tieRank(_ difficulty: ObservedDifficulty) -> Int {
        switch difficulty {
        case .grammar: 0
        case .retrieval: 1
        case .followUp: 2
        case .clarity: 3
        }
    }

    private static func later(_ current: Date?, _ next: Date) -> Date {
        guard let current else { return next }
        return max(current, next)
    }
}
