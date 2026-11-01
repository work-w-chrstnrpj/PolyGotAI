import Foundation

// MARK: Ranks and hidden packs (Phase 8)

extension LexiconState {
    var hidden: Set<String> { Set(hiddenGroupIDs ?? []) }

    /// The packs Daily Training takes new words from: the chosen packs, minus hidden ones, limited to the chosen ranks.
    /// Field packs are not tied to a rank. When no chosen rank pack is left, every pack of the chosen ranks is used,
    /// so "C2 only" works with one tap.
    func trainingGroups(in bank: LexiconBank, startLevel: String = "A1") -> [LexiconGroup] {
        let chosen = activeGroups(in: bank, startLevel: startLevel).filter { !hidden.contains($0.id) }
        guard let ranks, !ranks.isEmpty else { return chosen }
        let inRank = chosen.filter { $0.isField || ranks.contains($0.level) }
        if inRank.contains(where: { !$0.isField }) { return inRank }
        let rankPacks = bank.groups.filter { !$0.isField && ranks.contains($0.level) && !hidden.contains($0.id) }
        return inRank + rankPacks
    }

    mutating func setHidden(_ group: LexiconGroup, _ isHidden: Bool, in bank: LexiconBank, startLevel: String = "A1") {
        var ids = hidden
        if isHidden {
            ids.insert(group.id)
            if isActive(group, in: bank, startLevel: startLevel) { setActive(group, false, in: bank, startLevel: startLevel) }
        } else {
            ids.remove(group.id)
        }
        hiddenGroupIDs = bank.groups.map(\.id).filter(ids.contains)
    }

    /// Sets the ranks; all six ranks means every rank. An empty set is ignored, so at least one rank stays on.
    mutating func setRanks(_ chosen: Set<String>) {
        guard !chosen.isEmpty else { return }
        let ordered = LevelGate.levels.filter(chosen.contains)
        ranks = ordered.isEmpty || ordered.count == LevelGate.levels.count ? nil : ordered
    }
}

// MARK: Practice (unrated, repeatable)

/// Practice: as many rounds as the learner wants. Choose the word that fits the sentence, or choose the synonym.
/// Answers never change the review schedule.
enum LexiconPracticeBuilder {
    static let sessionSize = 10
    static let minimumWords = 4

    enum Kind: String { case wordInSentence, synonym }

    /// Words to practise: those the learner has started, else the words of the packs in training.
    static func pool(bank: LexiconBank, stages: [String: LexiconStage], state: LexiconState, startLevel: String) -> [LexiconWord] {
        let started = bank.words.filter { (stages[$0.id] ?? .new) != .new }
        if started.count >= minimumWords { return started }
        return state.trainingGroups(in: bank, startLevel: startLevel).flatMap(\.words)
    }

    static func questions<G: RandomNumberGenerator>(words: [LexiconWord], bank: LexiconBank, count: Int = sessionSize,
                                                    using generator: inout G) -> [LexiconQuestion] {
        var result: [LexiconQuestion] = []
        for (index, word) in words.shuffled(using: &generator).enumerated() where result.count < count {
            let preferSynonym = index % 2 == 1
            if preferSynonym, let question = synonymQuestion(word, bank: bank, using: &generator) {
                result.append(question)
            } else if let question = sentenceQuestion(word, bank: bank, using: &generator) {
                result.append(question)
            } else if let question = synonymQuestion(word, bank: bank, using: &generator) {
                result.append(question)
            }
        }
        return result
    }

    static func questions(words: [LexiconWord], bank: LexiconBank, count: Int = sessionSize) -> [LexiconQuestion] {
        var generator = SystemRandomNumberGenerator()
        return questions(words: words, bank: bank, count: count, using: &generator)
    }

    /// "Choose the word that fits": the sentence with a blank and four words of the same part of speech.
    static func sentenceQuestion<G: RandomNumberGenerator>(_ word: LexiconWord, bank: LexiconBank, using generator: inout G) -> LexiconQuestion? {
        guard let example = word.parsedExamples.shuffled(using: &generator).first else { return nil }
        let others = distractors(for: word, bank: bank, exclude: [example.form], using: &generator) { $0.parsedExamples.first?.form }
        guard others.count == 3 else { return nil }
        let options = ([example.form] + others).shuffled(using: &generator)
        let activity = CurriculumActivity(
            id: "\(word.id)#practice-sentence", kind: "grammar", required: true,
            prompt: "Choose the word that fits: \(example.blanked)", answer: example.form,
            exercise: ExerciseSpec(type: "choice", options: options, accepted: [example.form]))
        return LexiconQuestion(wordID: word.id, lemma: word.lemma, kind: .clozeChoice, activity: activity)
    }

    /// "Closest in meaning to …": one synonym and three words of the same part of speech that are not synonyms.
    static func synonymQuestion<G: RandomNumberGenerator>(_ word: LexiconWord, bank: LexiconBank, using generator: inout G) -> LexiconQuestion? {
        guard let synonym = word.synonyms.shuffled(using: &generator).first else { return nil }
        let excluded = [word.lemma] + word.synonyms
        let others = distractors(for: word, bank: bank, exclude: excluded, using: &generator) { $0.lemma }
        guard others.count == 3 else { return nil }
        let options = ([synonym] + others).shuffled(using: &generator)
        let activity = CurriculumActivity(
            id: "\(word.id)#practice-synonym", kind: "grammar", required: true,
            prompt: "Which word is closest in meaning to “\(word.lemma)”?", answer: synonym,
            exercise: ExerciseSpec(type: "choice", options: options, accepted: [synonym]))
        return LexiconQuestion(wordID: word.id, lemma: word.lemma, kind: .chooseSentence, activity: activity)
    }

    // MARK: Vocabulary Enricher

    /// Vocabulary Enricher: any word of the packs in training, learned or not. Each question is one of: the meaning → choose
    /// the word, choose the synonym, choose the opposite, or choose the word that completes the sentence. Never rated.
    static func enricherPool(bank: LexiconBank, state: LexiconState, startLevel: String) -> [LexiconWord] {
        state.trainingGroups(in: bank, startLevel: startLevel).flatMap(\.words)
    }

    static func enricherQuestions<G: RandomNumberGenerator>(words: [LexiconWord], bank: LexiconBank, count: Int = sessionSize,
                                                            using generator: inout G) -> [LexiconQuestion] {
        var result: [LexiconQuestion] = []
        for word in words.shuffled(using: &generator) where result.count < count {
            let makers: [(inout G) -> LexiconQuestion?] = [
                { meaningQuestion(word, bank: bank, using: &$0) },
                { synonymQuestion(word, bank: bank, using: &$0) },
                { antonymQuestion(word, bank: bank, using: &$0) },
                { sentenceQuestion(word, bank: bank, using: &$0) },
            ]
            for make in makers.shuffled(using: &generator) {
                if let question = make(&generator) { result.append(question); break }
            }
        }
        return result
    }

    static func enricherQuestions(words: [LexiconWord], bank: LexiconBank, count: Int = sessionSize) -> [LexiconQuestion] {
        var generator = SystemRandomNumberGenerator()
        return enricherQuestions(words: words, bank: bank, count: count, using: &generator)
    }

    /// "Which word means …?": the meaning and four words of the same part of speech. Skipped when the meaning gives the word away.
    static func meaningQuestion<G: RandomNumberGenerator>(_ word: LexiconWord, bank: LexiconBank, using generator: inout G) -> LexiconQuestion? {
        guard !mentions(word.meaning, word.lemma) else { return nil }
        let others = distractors(for: word, bank: bank, exclude: [word.lemma] + word.synonyms, using: &generator) { $0.lemma }
        guard others.count == 3 else { return nil }
        let options = ([word.lemma] + others).shuffled(using: &generator)
        let activity = CurriculumActivity(
            id: "\(word.id)#enricher-meaning", kind: "grammar", required: true,
            prompt: "Which word means: \(word.meaning)", answer: word.lemma,
            exercise: ExerciseSpec(type: "choice", options: options, accepted: [word.lemma]))
        return LexiconQuestion(wordID: word.id, lemma: word.lemma, kind: .chooseSentence, activity: activity)
    }

    /// Whether `text` contains `lemma` as whole words ("art" is not in "start").
    static func mentions(_ text: String, _ lemma: String) -> Bool {
        let words = AnswerChecker.words(in: text), target = AnswerChecker.words(in: lemma)
        guard !target.isEmpty, words.count >= target.count else { return false }
        return (0...(words.count - target.count)).contains { Array(words[$0..<($0 + target.count)]) == target }
    }

    /// "Which word is opposite in meaning to …?": one antonym and three words that are neither the word, its synonyms nor its antonyms.
    static func antonymQuestion<G: RandomNumberGenerator>(_ word: LexiconWord, bank: LexiconBank, using generator: inout G) -> LexiconQuestion? {
        guard let antonym = word.antonyms.shuffled(using: &generator).first else { return nil }
        let others = distractors(for: word, bank: bank, exclude: [word.lemma] + word.synonyms + word.antonyms, using: &generator) { $0.lemma }
        guard others.count == 3 else { return nil }
        let options = ([antonym] + others).shuffled(using: &generator)
        let activity = CurriculumActivity(
            id: "\(word.id)#enricher-antonym", kind: "grammar", required: true,
            prompt: "Which word is opposite in meaning to “\(word.lemma)”?", answer: antonym,
            exercise: ExerciseSpec(type: "choice", options: options, accepted: [antonym]))
        return LexiconQuestion(wordID: word.id, lemma: word.lemma, kind: .chooseSentence, activity: activity)
    }

    /// Three distinct options from other words, same part of speech first, then same pack, then the bank.
    /// A candidate is skipped when it is the word, one of its synonyms, or lists the word as its own synonym.
    private static func distractors<G: RandomNumberGenerator>(for word: LexiconWord, bank: LexiconBank, exclude: [String],
                                                              using generator: inout G, text: (LexiconWord) -> String?) -> [String] {
        let blocked = Set(exclude.map(LexiconKey.normalize))
        let lemma = LexiconKey.normalize(word.lemma)
        let others = bank.words.filter { other in
            other.id != word.id && !other.synonyms.map(LexiconKey.normalize).contains(lemma)
        }
        let tiers = [others.filter { $0.pos == word.pos && $0.groupId == word.groupId },
                     others.filter { $0.pos == word.pos },
                     others]
        var seen = blocked
        var picked: [String] = []
        for tier in tiers {
            for candidate in tier.shuffled(using: &generator) {
                guard let value = text(candidate), seen.insert(LexiconKey.normalize(value)).inserted else { continue }
                picked.append(value)
                if picked.count == 3 { return picked }
            }
        }
        return picked
    }
}

// MARK: Next-review preview (Anki-style labels on the rating buttons)

extension ReviewSchedule {
    /// When each rating would bring the card back, without saving anything. Ratings that fail to schedule are left out.
    static func preview(existing: ReviewCardState?, now: Date, itemId: String, senseId: String,
                        settings: ReviewSettings = ReviewSettings()) -> [RecallRating: Date] {
        var result: [RecallRating: Date] = [:]
        for rating in RecallRating.allCases {
            if let card = try? schedule(existing: existing, rating: rating, now: now, itemId: itemId, senseId: senseId, settings: settings) {
                result[rating] = card.due
            }
        }
        return result
    }

    /// Short Anki-style interval: "<1m", "10m", "3h", "4d", "2mo", "1.5y".
    static func shortInterval(from now: Date, to due: Date) -> String {
        let seconds = due.timeIntervalSince(now)
        guard seconds.isFinite, seconds >= 60 else { return "<1m" }
        let minutes = seconds / 60, hours = minutes / 60, days = hours / 24
        if minutes < 60 { return "\(Int(minutes.rounded()))m" }
        if hours < 24 { return "\(Int(hours.rounded()))h" }
        if days < 30 { return "\(Int(days.rounded()))d" }
        if days < 365 {
            let months = days / 30
            return months < 10 ? String(format: "%.1fmo", months).replacingOccurrences(of: ".0mo", with: "mo") : "\(Int(months.rounded()))mo"
        }
        return String(format: "%.1fy", days / 365).replacingOccurrences(of: ".0y", with: "y")
    }
}

// MARK: Where a saved word came from

extension VocabularyEnrollment {
    enum Origin { case lexicon, personal, saved }

    /// Lexicon bank words (Daily Training), words in the learner's own packs, or words saved from lessons and the daily word.
    var origin: Origin {
        switch objectiveID {
        case "lexicon": .lexicon
        case "personal-vocabulary": .personal
        default: .saved
        }
    }
}
