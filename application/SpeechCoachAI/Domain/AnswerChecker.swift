import Foundation

/// Result of checking one learner answer. `almost` is a small spelling slip; the hint names the word.
enum AnswerResult: Equatable {
    case correct
    case almost(hint: String)
    case incorrect

    var isCorrect: Bool { self == .correct }

    /// Accuracy weight of a first try. A spelling slip counts as half.
    var weight: Double {
        switch self {
        case .correct: 1
        case .almost: 0.5
        case .incorrect: 0
        }
    }
}

struct WordDiffEntry: Equatable {
    enum Mark: Equatable { case correct, misspelled, missing, extra }
    var mark: Mark
    /// The learner's word for correct, misspelled and extra; the expected word for missing.
    var word: String
    /// The expected word when the learner's word was misspelled.
    var expected: String? = nil
}

/// Pure answer checking shared by every typed, spoken and dictated exercise.
enum AnswerChecker {
    // MARK: Normalization

    /// Lowercase, straight quotes, no punctuation, contractions expanded, single spaces.
    static func normalize(_ text: String) -> String {
        words(in: text).joined(separator: " ")
    }

    static func words(in text: String) -> [String] {
        var folded = text.lowercased()
        for (curly, plain) in [("\u{2019}", "'"), ("\u{2018}", "'"), ("\u{201C}", "\""), ("\u{201D}", "\""), ("\u{2013}", " "), ("\u{2014}", " "), ("-", " ")] {
            folded = folded.replacingOccurrences(of: curly, with: plain)
        }
        var tokens: [String] = []
        for raw in folded.split(whereSeparator: { $0.isWhitespace }) {
            let word = raw.trimmingCharacters(in: CharacterSet.punctuationCharacters.union(.symbols))
            guard !word.isEmpty else { continue }
            let cleaned = word.filter { $0 != "," && $0 != "." && $0 != "!" && $0 != "?" && $0 != ";" && $0 != ":" && $0 != "\"" }
            tokens.append(contentsOf: expand(cleaned))
        }
        // "can not" and "cannot" are the same answer.
        var merged: [String] = []
        for token in tokens {
            if token == "not", merged.last == "can" { merged[merged.count - 1] = "cannot" } else { merged.append(token) }
        }
        return merged
    }

    private static let irregular: [String: [String]] = [
        "won't": ["will", "not"], "can't": ["cannot"], "cannot": ["cannot"], "shan't": ["shall", "not"],
        "let's": ["let", "us"], "i'm": ["i", "am"], "ain't": ["is", "not"],
    ]
    private static let isContractions: Set<String> = ["he's", "she's", "it's", "that's", "there's", "here's", "what's", "who's", "where's", "how's"]

    private static func expand(_ word: String) -> [String] {
        if let known = irregular[word] { return known }
        if isContractions.contains(word) { return [String(word.dropLast(2)), "is"] }
        if word.hasSuffix("n't"), word.count > 3 { return [String(word.dropLast(3)), "not"] }
        for (suffix, full) in [("'re", "are"), ("'ve", "have"), ("'ll", "will"), ("'d", "would")] where word.hasSuffix(suffix) && word.count > suffix.count {
            return [String(word.dropLast(suffix.count)), full]
        }
        return [word]
    }

    // MARK: Checking

    /// Correct when the normalized answer equals an accepted one. Almost when a single word of the same-length answer
    /// has a small spelling slip. Everything else is incorrect.
    static func check(_ response: String, accepted: [String], allowAlmost: Bool = true) -> AnswerResult {
        let given = words(in: response)
        guard !given.isEmpty else { return .incorrect }
        let targets = accepted.map(words(in:))
        if targets.contains(given) { return .correct }
        guard allowAlmost else { return .incorrect }
        for target in targets where target.count == given.count {
            let differing = zip(given, target).enumerated().filter { $0.element.0 != $0.element.1 }
            guard differing.count == 1, let slip = differing.first else { continue }
            let (heard, expected) = slip.element
            if isSpellingSlip(heard, expected) { return .almost(hint: "Check the spelling of “\(expected)”.") }
        }
        return .incorrect
    }

    /// One edit (swap counts as one) for words of 4+ letters, two edits for 8+ letters. Short words must match exactly.
    static func isSpellingSlip(_ heard: String, _ expected: String) -> Bool {
        guard expected.count >= 4 else { return false }
        let allowed = expected.count >= 8 ? 2 : 1
        return editDistance(heard, expected) <= allowed
    }

    /// Optimal string alignment distance (insert, delete, replace, swap adjacent).
    static func editDistance(_ lhs: String, _ rhs: String) -> Int {
        let a = Array(lhs), b = Array(rhs)
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        var rows = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in 0...a.count { rows[i][0] = i }
        for j in 0...b.count { rows[0][j] = j }
        for i in 1...a.count {
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                rows[i][j] = min(rows[i - 1][j] + 1, rows[i][j - 1] + 1, rows[i - 1][j - 1] + cost)
                if i > 1, j > 1, a[i - 1] == b[j - 2], a[i - 2] == b[j - 1] {
                    rows[i][j] = min(rows[i][j], rows[i - 2][j - 2] + 1)
                }
            }
        }
        return rows[a.count][b.count]
    }

    // MARK: Word diff (dictation and "We heard")

    /// Aligns what the learner wrote or the phone heard with the expected text.
    static func diff(response: String, expected: String) -> [WordDiffEntry] {
        let given = words(in: response), target = words(in: expected)
        // Longest common subsequence anchors.
        var lcs = Array(repeating: Array(repeating: 0, count: target.count + 1), count: given.count + 1)
        for i in stride(from: given.count - 1, through: 0, by: -1) {
            for j in stride(from: target.count - 1, through: 0, by: -1) {
                lcs[i][j] = given[i] == target[j] ? lcs[i + 1][j + 1] + 1 : max(lcs[i + 1][j], lcs[i][j + 1])
            }
        }
        var entries: [WordDiffEntry] = []
        var gapGiven: [String] = [], gapTarget: [String] = []
        func flushGap() {
            let pairs = min(gapGiven.count, gapTarget.count)
            for k in 0..<pairs {
                if isSpellingSlip(gapGiven[k], gapTarget[k]) {
                    entries.append(WordDiffEntry(mark: .misspelled, word: gapGiven[k], expected: gapTarget[k]))
                } else {
                    entries.append(WordDiffEntry(mark: .extra, word: gapGiven[k]))
                    entries.append(WordDiffEntry(mark: .missing, word: gapTarget[k]))
                }
            }
            for word in gapGiven.dropFirst(pairs) { entries.append(WordDiffEntry(mark: .extra, word: word)) }
            for word in gapTarget.dropFirst(pairs) { entries.append(WordDiffEntry(mark: .missing, word: word)) }
            gapGiven = []; gapTarget = []
        }
        var i = 0, j = 0
        while i < given.count && j < target.count {
            if given[i] == target[j] {
                flushGap()
                entries.append(WordDiffEntry(mark: .correct, word: given[i]))
                i += 1; j += 1
            } else if lcs[i + 1][j] >= lcs[i][j + 1] {
                gapGiven.append(given[i]); i += 1
            } else {
                gapTarget.append(target[j]); j += 1
            }
        }
        gapGiven.append(contentsOf: given[i...]); gapTarget.append(contentsOf: target[j...])
        flushGap()
        return entries
    }

    /// The accepted text the response is closest to, for showing a diff.
    static func bestDiff(response: String, accepted: [String]) -> [WordDiffEntry] {
        accepted.map { diff(response: response, expected: $0) }
            .max { correctCount($0) < correctCount($1) } ?? []
    }

    static func correctCount(_ diff: [WordDiffEntry]) -> Int { diff.filter { $0.mark == .correct }.count }

    /// Fraction of expected words written or heard correctly. A misspelled word counts as half.
    static func accuracy(of diff: [WordDiffEntry]) -> Double {
        let expectedCount = diff.filter { $0.mark != .extra }.count
        guard expectedCount > 0 else { return 0 }
        let score = diff.reduce(0.0) { $0 + ($1.mark == .correct ? 1 : $1.mark == .misspelled ? 0.5 : 0) }
        return score / Double(expectedCount)
    }
}
