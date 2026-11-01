import Foundation

// MARK: Question bank

/// One scripted interview question with its two fixed follow-ups (Phase 5b). Chosen by rule, never by AI.
struct InterviewQuestionItem: Codable, Equatable, Identifiable {
    enum Stage: String, Codable { case opening, core, closing }
    var id: String
    var set: String
    var setTitle: String
    var stage: Stage
    var level: String
    var title: String
    var text: String
    var followUpShort: String
    var followUpLong: String
}

enum InterviewFollowUpRule {
    /// Answers shorter than this get the "tell me more" follow-up; longer ones get the deeper one.
    static let shortAnswerWords = 12

    static func text(for question: InterviewQuestionItem, wordCount: Int) -> String {
        wordCount < shortAnswerWords ? question.followUpShort : question.followUpLong
    }
}

// MARK: Turn taking

/// How long silence lasts before a spoken answer counts as finished, and how patient the interviewer is.
struct TurnTakingRules: Equatable {
    var silenceToEnd: TimeInterval = 2.0
    var noSpeechPrompt: TimeInterval = 8.0
    var maxNoSpeechPrompts = 2
    var maxTurn: TimeInterval = 90
}

enum TurnEnd: String, Codable, Equatable { case silence, maxLength, manual }

enum TurnSignal: Equatable {
    case keepListening
    /// The learner has said nothing for a while: say a gentle prompt (1 = first, 2 = second).
    case promptToSpeak(Int)
    /// Nothing was said after the prompts: offer Skip.
    case offerSkip
    case endTurn(TurnEnd)
}

/// A pure state machine for one answer. The caller passes the clock and the live caption's word count.
struct TurnDetector: Equatable {
    let rules: TurnTakingRules
    let startedAt: Date
    private(set) var wordCount = 0
    private(set) var lastSpeechAt: Date?
    private(set) var prompts = 0
    private var promptAnchor: Date

    init(rules: TurnTakingRules = TurnTakingRules(), startedAt: Date) {
        self.rules = rules
        self.startedAt = startedAt
        promptAnchor = startedAt
    }

    /// The live caption now has `words` words. Only growth counts as speech, so a recognizer repeating itself does not.
    mutating func heard(words: Int, at time: Date) {
        guard words > wordCount else { return }
        wordCount = words
        lastSpeechAt = time
    }

    mutating func tick(at time: Date) -> TurnSignal {
        if time.timeIntervalSince(startedAt) >= rules.maxTurn { return wordCount > 0 ? .endTurn(.maxLength) : .offerSkip }
        if wordCount > 0, let last = lastSpeechAt {
            return time.timeIntervalSince(last) >= rules.silenceToEnd ? .endTurn(.silence) : .keepListening
        }
        guard time.timeIntervalSince(promptAnchor) >= rules.noSpeechPrompt else { return .keepListening }
        prompts += 1
        promptAnchor = time
        return prompts > rules.maxNoSpeechPrompts ? .offerSkip : .promptToSpeak(prompts)
    }
}

// MARK: Session

struct InterviewTurn: Codable, Equatable {
    enum Kind: String, Codable { case question, followUp }
    var questionID: String
    var kind: Kind
    var prompt: String
    var transcript: String
    var duration: TimeInterval
    var wordCount: Int
    var skipped: Bool
    var repeats: Int
    var end: TurnEnd?
}

struct InterviewSummary: Equatable {
    var answered: Int
    var skipped: Int
    var followUps: Int
    var totalWords: Int
    var speakingSeconds: TimeInterval
    var wordsPerMinute: Int?
    var longestAnswerWords: Int
    var fillers: Int
    var lines: [String]
}

/// A scripted, hands-free interview: an opening question, core questions that may each get one follow-up, a closing question.
/// Offline and rule-based. Nothing here scores pronunciation or grammar; the summary only counts what was said.
struct HandsFreeInterview: Codable, Equatable, Identifiable {
    let id: UUID
    let setID: String
    let startedAt: Date
    private(set) var questions: [InterviewQuestionItem]
    private(set) var turns: [InterviewTurn] = []
    private(set) var index = 0
    private(set) var inFollowUp = false
    private(set) var finishedAt: Date?
    /// A follow-up written by the online model for the current answer (Phase 6c). Replaces the scripted one while it is asked.
    private(set) var aiFollowUp: String?
    private var pendingRepeats = 0

    init(id: UUID = UUID(), setID: String, questions: [InterviewQuestionItem], now: Date) {
        self.id = id
        self.setID = setID
        self.questions = questions
        startedAt = now
        if questions.isEmpty { finishedAt = now }
    }

    // MARK: Planning

    /// Pick one opening, up to `count - 2` core questions at or below `level` (easiest first), and one closing.
    /// `seed` rotates the choice so a repeat session asks different questions. Deterministic.
    static func plan(set: String, level: String, bank: [InterviewQuestionItem], count: Int = 6, seed: Int = 0) -> [InterviewQuestionItem] {
        let ceiling = LevelGate.levels.firstIndex(of: level.uppercased()) ?? 0
        func rank(_ item: InterviewQuestionItem) -> Int { LevelGate.levels.firstIndex(of: item.level) ?? 99 }
        let pool = bank.filter { $0.set == set && rank($0) <= ceiling }
        func rotated(_ items: [InterviewQuestionItem]) -> [InterviewQuestionItem] {
            guard !items.isEmpty else { return [] }
            let shift = ((seed % items.count) + items.count) % items.count
            return Array(items[shift...] + items[..<shift])
        }
        let opening = rotated(pool.filter { $0.stage == .opening }).first
        let closing = rotated(pool.filter { $0.stage == .closing }).first
        let coreCount = max(0, count - 2)
        let core = Array(rotated(pool.filter { $0.stage == .core }).prefix(coreCount)).enumerated()
            .sorted { (rank($0.element), $0.offset) < (rank($1.element), $1.offset) }.map(\.element)
        return [opening].compactMap { $0 } + core + [closing].compactMap { $0 }
    }

    // MARK: Reading the state

    var isFinished: Bool { finishedAt != nil }
    var current: InterviewQuestionItem? { isFinished || index >= questions.count ? nil : questions[index] }

    /// The words the interviewer says now: the question, or its follow-up.
    var prompt: String? {
        guard let question = current else { return nil }
        if inFollowUp {
            if let aiFollowUp { return aiFollowUp }
            return turns.last(where: { $0.questionID == question.id && $0.kind == .question }).map { InterviewFollowUpRule.text(for: question, wordCount: $0.wordCount) }
        }
        return question.text
    }

    /// "Question 2 of 6"; follow-ups do not change the count.
    var progress: String? { current.map { _ in "Question \(index + 1) of \(questions.count)" } }

    // MARK: Actions

    /// The learner pressed Repeat: the interviewer says the same words again.
    mutating func repeatPrompt() -> String? {
        guard let prompt else { return nil }
        pendingRepeats += 1
        return prompt
    }

    /// The learner's answer ended (by silence, the time limit or a tap). Moves on, possibly to one follow-up.
    mutating func record(transcript: String, duration: TimeInterval, end: TurnEnd, now: Date) {
        guard let question = current, let prompt else { return }
        let words = SpeechLabDictationChecker.tokens(transcript, strict: false).count
        turns.append(InterviewTurn(questionID: question.id, kind: inFollowUp ? .followUp : .question, prompt: prompt,
                                   transcript: transcript.trimmingCharacters(in: .whitespacesAndNewlines),
                                   duration: max(0, duration), wordCount: words, skipped: false, repeats: pendingRepeats, end: end))
        pendingRepeats = 0
        if !inFollowUp, question.stage == .core, words > 0 {
            inFollowUp = true
        } else {
            advance(now: now)
        }
    }

    /// The learner pressed Skip. A skipped follow-up just moves on; a skipped question is noted and gets no follow-up.
    mutating func skip(now: Date) {
        guard let question = current, let prompt else { return }
        turns.append(InterviewTurn(questionID: question.id, kind: inFollowUp ? .followUp : .question, prompt: prompt,
                                   transcript: "", duration: 0, wordCount: 0, skipped: true, repeats: pendingRepeats, end: nil))
        pendingRepeats = 0
        advance(now: now)
    }

    /// End early (Done). Keeps the turns recorded so far.
    mutating func finish(now: Date) {
        if finishedAt == nil { finishedAt = now }
    }

    /// Swap in an online follow-up while the scripted one is pending. Returns false when no follow-up is pending.
    @discardableResult
    mutating func setAIFollowUp(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard inFollowUp, !isFinished, !trimmed.isEmpty else { return false }
        aiFollowUp = trimmed
        return true
    }

    /// The last answered turn of the current question: the text a follow-up should respond to.
    var latestAnswer: (question: String, answer: String)? {
        guard let question = current, let turn = turns.last(where: { $0.questionID == question.id && $0.kind == .question && !$0.skipped }) else { return nil }
        return (turn.prompt, turn.transcript)
    }

    private mutating func advance(now: Date) {
        inFollowUp = false
        aiFollowUp = nil
        index += 1
        if index >= questions.count { finishedAt = now }
    }

    // MARK: Summary

    var summary: InterviewSummary {
        let answers = turns.filter { !$0.skipped && $0.wordCount > 0 }
        let words = answers.reduce(0) { $0 + $1.wordCount }
        let seconds = answers.reduce(0) { $0 + $1.duration }
        let fillers = answers.flatMap { SpeechLabDictationChecker.tokens($0.transcript, strict: false) }.filter { ["um", "uh", "er", "erm"].contains($0) }.count
        let pace = seconds >= 5 ? Int((Double(words) * 60 / seconds).rounded()) : nil
        let skipped = turns.filter(\.skipped).count
        let followUps = answers.filter { $0.kind == .followUp }.count
        let longest = answers.map(\.wordCount).max() ?? 0
        var lines: [String] = []
        lines.append("\(answers.count) \(answers.count == 1 ? "answer" : "answers")" + (skipped > 0 ? ", \(skipped) skipped" : ""))
        if let pace { lines.append("About \(pace) words a minute") }
        if longest > 0 { lines.append("Longest answer: \(longest) words") }
        if fillers > 0 { lines.append("Fillers: \(fillers)") }
        return InterviewSummary(answered: answers.count, skipped: skipped, followUps: followUps, totalWords: words, speakingSeconds: seconds,
                                wordsPerMinute: pace, longestAnswerWords: longest, fillers: fillers, lines: lines)
    }
}
