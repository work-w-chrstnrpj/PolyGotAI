import Foundation

// MARK: Bank

/// One predefined word. Meaning and sentences are original wording. `examples` mark the word form with braces,
/// for example "She felt {happy} today."; `wrong` sentences use the word incorrectly (for Lexicon in Action).
struct LexiconWord: Codable, Equatable, Identifiable {
    static let partsOfSpeech: Set<String> = ["noun", "verb", "adjective", "adverb", "preposition", "conjunction", "pronoun", "phrase"]
    /// How a word is used: everyday speech, formal writing, a field term, jargon, slang, informal talk or literary writing.
    static let registers: Set<String> = ["everyday", "formal", "term", "jargon", "slang", "informal", "literary"]
    static let senseId = "1"

    var lemma: String
    var pos: String
    var meaning: String
    var examples: [String]
    var wrong: [String]
    /// CEFR level of the word (A1 to C2). Filled from the group's level when the file does not give one.
    var cefr: String = ""
    var register: String = "everyday"
    /// "<groupId>.<slug>", or the explicit id a word kept when it moved between groups.
    var id: String = ""
    /// The group the word sits in now; set by the loader.
    var groupId: String = ""
    /// Words with a close meaning, for the synonym question in Practice. Empty when none fits (idioms, function words).
    var synonyms: [String] = []
    /// General American pronunciation in IPA, between slashes ("/ɪˈfɛmərəl/"). Nil for words without one yet.
    var ipa: String?
    /// True opposites in this meaning, for the antonym question in Vocabulary Enricher. Often empty.
    var antonyms: [String] = []

    init(lemma: String, pos: String, meaning: String, examples: [String], wrong: [String],
         cefr: String = "", register: String = "everyday", id: String = "", groupId: String = "") {
        self.lemma = lemma; self.pos = pos; self.meaning = meaning; self.examples = examples; self.wrong = wrong
        self.cefr = cefr; self.register = register; self.id = id; self.groupId = groupId
    }

    private enum CodingKeys: String, CodingKey { case lemma, pos, meaning, examples, wrong, cefr, register, id, synonyms, ipa, antonyms }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lemma = try container.decode(String.self, forKey: .lemma)
        pos = try container.decode(String.self, forKey: .pos)
        meaning = try container.decode(String.self, forKey: .meaning)
        examples = try container.decode([String].self, forKey: .examples)
        wrong = try container.decode([String].self, forKey: .wrong)
        cefr = try container.decodeIfPresent(String.self, forKey: .cefr) ?? ""
        register = try container.decodeIfPresent(String.self, forKey: .register) ?? "everyday"
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        synonyms = try container.decodeIfPresent([String].self, forKey: .synonyms) ?? []
        ipa = try container.decodeIfPresent(String.self, forKey: .ipa)
        antonyms = try container.decodeIfPresent([String].self, forKey: .antonyms) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lemma, forKey: .lemma); try container.encode(pos, forKey: .pos)
        try container.encode(meaning, forKey: .meaning); try container.encode(examples, forKey: .examples)
        try container.encode(wrong, forKey: .wrong); try container.encode(cefr, forKey: .cefr)
        try container.encode(register, forKey: .register); try container.encode(id, forKey: .id)
        if !synonyms.isEmpty { try container.encode(synonyms, forKey: .synonyms) }
        try container.encodeIfPresent(ipa, forKey: .ipa)
        if !antonyms.isEmpty { try container.encode(antonyms, forKey: .antonyms) }
    }

    var itemId: String { "lex.\(id)" }

    /// A marked example split into the plain sentence, the blanked sentence and the marked form.
    struct Example: Equatable {
        var plain: String
        var blanked: String
        var form: String
    }

    static func parse(_ marked: String) -> Example? {
        guard let open = marked.firstIndex(of: "{"), let close = marked.firstIndex(of: "}"), open < close else { return nil }
        let form = String(marked[marked.index(after: open)..<close]).trimmingCharacters(in: .whitespaces)
        guard !form.isEmpty, marked.filter({ $0 == "{" }).count == 1, marked.filter({ $0 == "}" }).count == 1 else { return nil }
        let before = String(marked[..<open]), after = String(marked[marked.index(after: close)...])
        return Example(plain: before + form + after, blanked: before + "___" + after, form: form)
    }

    var parsedExamples: [Example] { examples.compactMap(Self.parse) }

    /// Why this word cannot be used, or nil. A word with a problem is dropped by the loader.
    func problem() -> String? {
        func blank(_ text: String) -> Bool { text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if blank(lemma) { return "missing lemma" }
        if !Self.partsOfSpeech.contains(pos) { return "unknown part of speech \(pos)" }
        if blank(meaning) || meaning.count > 140 { return "meaning missing or too long" }
        if examples.isEmpty || parsedExamples.count != examples.count { return "each example needs exactly one {marked} form" }
        if wrong.isEmpty || wrong.contains(where: { blank($0) || $0.contains("{") || $0.contains("}") }) { return "needs wrong-usage sentences without braces" }
        if !cefr.isEmpty, !LevelGate.levels.contains(cefr) { return "unknown CEFR level \(cefr)" }
        if !Self.registers.contains(register) { return "unknown register \(register)" }
        if synonyms.contains(where: { blank($0) || LexiconKey.normalize($0) == LexiconKey.normalize(lemma) }) { return "synonym blank or same as the word" }
        return nil
    }
}

struct LexiconGroup: Equatable, Identifiable {
    var id: String
    var title: String
    var level: String
    var tagline: String
    var sources: [String]
    var words: [LexiconWord]
    /// A field pack (business, technology, health, travel, law): opt-in, never the default group or the "Next" suggestion.
    var isField = false
}

struct LexiconBank: Equatable {
    var groups: [LexiconGroup] = []
    /// Words skipped because they were malformed or repeated.
    var skipped = 0

    var words: [LexiconWord] { groups.flatMap(\.words) }
    func word(id: String) -> LexiconWord? { words.first { $0.id == id } }
    func word(itemId: String, senseId: String) -> LexiconWord? {
        senseId == LexiconWord.senseId ? words.first { $0.itemId == itemId } : nil
    }
    func group(id: String) -> LexiconGroup? { groups.first { $0.id == id } }
}

// MARK: Duplicate check

enum LexiconKey {
    /// Lowercased, accent-free, single-spaced.
    static func normalize(_ text: String) -> String {
        let folded = text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: Locale(identifier: "en_US"))
        return folded.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    static func slug(_ text: String) -> String {
        normalize(text).map { $0.isLetter || $0.isNumber ? String($0) : "-" }.joined()
            .split(separator: "-", omittingEmptySubsequences: true).joined(separator: "-")
    }
}

struct LexiconDuplicate: Equatable {
    enum Source: Equatable { case bank(group: String), personal(topic: String), saved }
    var lemma: String
    var source: Source
    /// Bank word id when the match is in the bank.
    var wordId: String?
}

enum LexiconDuplicateCheck {
    /// A word is already in the Lexicon when its normalized lemma matches and the parts of speech match,
    /// or when either part of speech is not given (it cannot be told apart).
    static func find(lemma: String, partOfSpeech: String?, bank: LexiconBank,
                     topics: [CustomVocabularyTopic], enrollments: [VocabularyEnrollment]) -> LexiconDuplicate? {
        let target = LexiconKey.normalize(lemma)
        guard !target.isEmpty else { return nil }
        let pos = partOfSpeech.map(LexiconKey.normalize).flatMap { $0.isEmpty ? nil : $0 }
        for group in bank.groups {
            for word in group.words where LexiconKey.normalize(word.lemma) == target {
                if pos == nil || pos == word.pos { return LexiconDuplicate(lemma: word.lemma, source: .bank(group: group.title), wordId: word.id) }
            }
        }
        for topic in topics {
            for sense in topic.senses where LexiconKey.normalize(sense.lemma) == target {
                return LexiconDuplicate(lemma: sense.lemma, source: .personal(topic: topic.title), wordId: nil)
            }
        }
        let personalIDs = Set(topics.flatMap(\.senses).map(\.itemId))
        for enrollment in enrollments where LexiconKey.normalize(enrollment.lemma) == target && !personalIDs.contains(enrollment.itemId) {
            if bank.words.contains(where: { $0.itemId == enrollment.itemId }) { continue }
            return LexiconDuplicate(lemma: enrollment.lemma, source: .saved, wordId: nil)
        }
        return nil
    }
}

// MARK: Stages

enum LexiconStage: String, Equatable, CaseIterable {
    case new, learning, review, easy

    var title: String {
        switch self {
        case .new: "New"
        case .learning: "Learning"
        case .review: "Review"
        case .easy: "Easy"
        }
    }

    /// From the word's review card and its latest rating. Easy only while the latest rating is Easy.
    static func of(card: ReviewCardState?, lastRating: RecallRating?) -> LexiconStage {
        guard let card else { return .new }
        if lastRating == .easy { return .easy }
        switch card.phase {
        case "learning", "relearning": return .learning
        case "review": return .review
        default: return .new
        }
    }
}

enum LexiconLedger {
    /// Stage of every bank word, keyed by word id.
    static func stages(bank: LexiconBank, cards: [ReviewCardState], recalls: [VocabularyRecallAttempt]) -> [String: LexiconStage] {
        var cardByID: [String: ReviewCardState] = [:]
        for card in cards where card.kind == ReviewSchedule.kind { cardByID["\(card.itemId)|\(card.senseId)"] = card }
        var latest: [String: VocabularyRecallAttempt] = [:]
        for attempt in recalls {
            let key = "\(attempt.itemId)|\(attempt.senseId)"
            if let current = latest[key], current.createdAt >= attempt.createdAt { continue }
            latest[key] = attempt
        }
        var result: [String: LexiconStage] = [:]
        for word in bank.words {
            let key = "\(word.itemId)|\(LexiconWord.senseId)"
            result[word.id] = LexiconStage.of(card: cardByID[key], lastRating: latest[key]?.rating)
        }
        return result
    }
}
