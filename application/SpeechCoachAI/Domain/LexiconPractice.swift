import Foundation

// MARK: Stored state (optional section of the learner document)

struct LexiconDailyRecord: Codable, Equatable {
    /// Local calendar day, "yyyy-MM-dd".
    var day: String
    var wordID: String
}

/// How long a word waits before it is tested again in Lexicon in Action.
struct LexiconActionProgress: Codable, Equatable {
    var correctStreak: Int
    var nextDue: Date
}

struct LexiconState: Codable, Equatable {
    static let defaultNewPerDay = 10
    /// nil means the default: the first bank group only.
    var activeGroupIDs: [String]? = nil
    var newPerDay = LexiconState.defaultNewPerDay
    var daily: LexiconDailyRecord?
    var shownDailyWordIDs: [String] = []
    var action: [String: LexiconActionProgress] = [:]

    func activeGroups(in bank: LexiconBank) -> [LexiconGroup] {
        if let ids = activeGroupIDs { return bank.groups.filter { ids.contains($0.id) } }
        return Array(bank.groups.prefix(1))
    }

    func isActive(_ group: LexiconGroup, in bank: LexiconBank) -> Bool {
        activeGroups(in: bank).contains { $0.id == group.id }
    }

    mutating func setActive(_ group: LexiconGroup, _ active: Bool, in bank: LexiconBank) {
        var ids = activeGroups(in: bank).map(\.id)
        ids.removeAll { $0 == group.id }
        if active { ids.append(group.id) }
        activeGroupIDs = bank.groups.map(\.id).filter(ids.contains)
    }
}

// MARK: Daily Lexicon (Today)

enum DailyLexicon {
    static func dayString(_ date: Date, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    /// The word of the day. It stays the same all day. A new day takes the next bank word the learner has not rated Easy
    /// and has not been shown yet; when every word has been shown the cycle starts again. Returns nil for an empty bank
    /// or when every word is Easy. Showing a word schedules nothing.
    static func pick(bank: LexiconBank, state: LexiconState, stages: [String: LexiconStage], day: String) -> (word: LexiconWord, state: LexiconState)? {
        if let record = state.daily, record.day == day, let word = bank.word(id: record.wordID) { return (word, state) }
        let candidates = bank.words.filter { stages[$0.id] != .easy }
        guard !candidates.isEmpty else { return nil }
        var next = state
        var pool = candidates.filter { !state.shownDailyWordIDs.contains($0.id) }
        if pool.isEmpty { next.shownDailyWordIDs = []; pool = candidates }
        guard let word = pool.first else { return nil }
        next.daily = LexiconDailyRecord(day: day, wordID: word.id)
        next.shownDailyWordIDs.append(word.id)
        return (word, next)
    }
}

// MARK: Daily Training

enum LexiconTrainingPlan {
    /// Enrollment for a bank word. The meaning is stored so the existing recall and rating code works unchanged.
    static func enrollment(for word: LexiconWord, bankVersion: String, now: Date) -> VocabularyEnrollment {
        VocabularyEnrollment(itemId: word.itemId, senseId: LexiconWord.senseId, lemma: word.lemma,
                             lessonID: "lexicon:\(word.groupId)", objectiveID: "lexicon", contentVersion: bankVersion,
                             enrolledAt: now, inReview: true, meaning: word.meaning)
    }

    /// New words to start today: the next words of the active groups, in bank order, that are not enrolled yet,
    /// up to the daily limit minus the Lexicon words already started today.
    static func newWords(bank: LexiconBank, state: LexiconState, enrollments: [VocabularyEnrollment],
                         now: Date, calendar: Calendar = .current) -> [LexiconWord] {
        let enrolled = Set(enrollments.map(\.itemId))
        let startedToday = enrollments.filter { $0.lessonID.hasPrefix("lexicon:") && calendar.isDate($0.enrolledAt, inSameDayAs: now) }.count
        let room = max(0, state.newPerDay - startedToday)
        guard room > 0 else { return [] }
        let candidates = state.activeGroups(in: bank).flatMap(\.words).filter { !enrolled.contains($0.itemId) }
        return Array(candidates.prefix(room))
    }
}

// MARK: Lexicon in Action

struct LexiconQuestion: Equatable, Identifiable {
    enum Kind: String { case clozeChoice, chooseSentence, clozeTyped }
    var id: String { activity.id }
    var wordID: String
    var lemma: String
    var kind: Kind
    var activity: CurriculumActivity
}

enum LexiconActionBuilder {
    static let sessionSize = 10
    /// Days a word waits after its 1st, 2nd, 3rd... correct Lexicon in Action answer in a row.
    static let intervalsInDays = [1, 3, 7, 14, 30, 60]

    /// Words whose latest rating is Easy and whose wait is over.
    static func eligible(bank: LexiconBank, stages: [String: LexiconStage], state: LexiconState, now: Date) -> [LexiconWord] {
        bank.words.filter { word in
            guard stages[word.id] == .easy, !word.parsedExamples.isEmpty else { return false }
            return (state.action[word.id]?.nextDue ?? .distantPast) <= now
        }
    }

    static func questions<G: RandomNumberGenerator>(words: [LexiconWord], bank: LexiconBank, count: Int = sessionSize,
                                                    using generator: inout G) -> [LexiconQuestion] {
        let chosen = Array(words.shuffled(using: &generator).prefix(count))
        let kinds: [LexiconQuestion.Kind] = [.clozeChoice, .chooseSentence, .clozeTyped]
        var result: [LexiconQuestion] = []
        for (index, word) in chosen.enumerated() {
            guard let example = word.parsedExamples.shuffled(using: &generator).first else { continue }
            var kind = kinds[index % kinds.count]
            if kind == .chooseSentence, word.wrong.isEmpty { kind = .clozeTyped }
            let activity: CurriculumActivity
            switch kind {
            case .clozeTyped:
                activity = CurriculumActivity(
                    id: "\(word.id)#typed", kind: "grammar", required: true,
                    prompt: "Type the missing word: \(example.blanked)", answer: example.form,
                    exercise: ExerciseSpec(type: "fillBlank", accepted: [example.form]))
            case .clozeChoice:
                let options = clozeOptions(for: word, form: example.form, bank: bank, using: &generator)
                guard options.count >= 3 else { continue }
                activity = CurriculumActivity(
                    id: "\(word.id)#cloze", kind: "grammar", required: true,
                    prompt: "Fill in the blank: \(example.blanked)", answer: example.form,
                    exercise: ExerciseSpec(type: "choice", options: options, accepted: [example.form]))
            case .chooseSentence:
                let wrong = Array(word.wrong.shuffled(using: &generator).prefix(2))
                activity = CurriculumActivity(
                    id: "\(word.id)#sentence", kind: "grammar", required: true,
                    prompt: "Which sentence uses “\(word.lemma)” correctly?", answer: example.plain,
                    exercise: ExerciseSpec(type: "choice", options: [example.plain] + wrong, accepted: [example.plain]))
            }
            result.append(LexiconQuestion(wordID: word.id, lemma: word.lemma, kind: kind, activity: activity))
        }
        return result
    }

    static func questions(words: [LexiconWord], bank: LexiconBank, count: Int = sessionSize) -> [LexiconQuestion] {
        var generator = SystemRandomNumberGenerator()
        return questions(words: words, bank: bank, count: count, using: &generator)
    }

    /// Other words' forms from the same group (same part of speech first) as wrong choices.
    private static func clozeOptions<G: RandomNumberGenerator>(for word: LexiconWord, form: String, bank: LexiconBank,
                                                               using generator: inout G) -> [String] {
        let group = bank.group(id: word.groupId)?.words ?? bank.words
        let others = group.filter { $0.id != word.id }
        let samePos = others.filter { $0.pos == word.pos }
        let pool = (samePos.count >= 3 ? samePos : others).compactMap { $0.parsedExamples.first?.form }
            .filter { LexiconKey.normalize($0) != LexiconKey.normalize(form) }
        var seen = Set<String>([LexiconKey.normalize(form)])
        var options = [form]
        for candidate in pool.shuffled(using: &generator) where seen.insert(LexiconKey.normalize(candidate)).inserted {
            options.append(candidate)
            if options.count == 4 { break }
        }
        return options
    }

    /// The word's new wait after an answer. A miss clears it: the word goes back to Daily Training.
    static func updated(_ state: LexiconState, wordID: String, correct: Bool, now: Date) -> LexiconState {
        var next = state
        if correct {
            let streak = (state.action[wordID]?.correctStreak ?? 0) + 1
            let days = intervalsInDays[min(streak - 1, intervalsInDays.count - 1)]
            next.action[wordID] = LexiconActionProgress(
                correctStreak: streak, nextDue: now.addingTimeInterval(Double(days) * 86_400))
        } else {
            next.action.removeValue(forKey: wordID)
        }
        return next
    }
}
