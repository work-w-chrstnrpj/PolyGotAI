import Foundation

enum SpeechLabArea: String, Codable, CaseIterable, Identifiable {
    case dictation, phonetics, articulation, voice
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

/// Only result numbers and content identities are retained here; recognized text stays in the session.
/// Audio is an optional reference to the existing recording lifecycle, never a file path.
struct SpeechLabAttempt: Codable, Equatable, Identifiable {
    var id = UUID()
    var area: SpeechLabArea
    var itemID: String
    var date = Date()
    var correct: Int? = nil
    var total: Int? = nil
    var wordsPerMinute: Double? = nil
    var pauses: Int? = nil
    var fillers: Int? = nil
    var recordingID: UUID? = nil
    var errors: Int? = nil

    var summary: String {
        if let wordsPerMinute { return "\(Int(wordsPerMinute.rounded())) wpm · \(pauses ?? 0) pauses · \(fillers ?? 0) fillers" }
        if let correct, let total { return "\(correct) of \(total) \(area == .dictation ? "words" : "answers")" }
        return "Practice complete"
    }
    var accuracy: Double? {
        guard let correct, let total, total > 0 else { return nil }
        return Double(correct) / Double(total)
    }
    var isValid: Bool {
        guard !itemID.isEmpty, itemID.count <= 120, date.timeIntervalSince1970.isFinite else { return false }
        if let total { guard total > 0, let correct, (0...total).contains(correct) else { return false } }
        if let wordsPerMinute { guard wordsPerMinute.isFinite, wordsPerMinute >= 0 else { return false } }
        return (pauses ?? 0) >= 0 && (fillers ?? 0) >= 0 && (errors ?? 0) >= 0 && (correct == nil) == (total == nil)
    }
}

struct SpeechLabState: Codable, Equatable {
    var attempts: [SpeechLabAttempt] = []
    var strictDictation = false
    var missedDictation: [String] = []

    mutating func record(_ attempt: SpeechLabAttempt) {
        guard !attempts.contains(where: { $0.id == attempt.id }) else { return }
        attempts.append(attempt)
        if attempt.area == .dictation, let accuracy = attempt.accuracy {
            missedDictation.removeAll { $0 == attempt.itemID }
            if accuracy < 1 || (attempt.errors ?? 0) > 0 { missedDictation.append(attempt.itemID) }
        }
    }
    mutating func remove(_ id: UUID) {
        guard let removed = attempts.first(where: { $0.id == id }) else { return }
        attempts.removeAll { $0.id == id }
        if removed.area == .dictation {
            missedDictation.removeAll { $0 == removed.itemID }
            if let last = attempts.last(where: { $0.area == .dictation && $0.itemID == removed.itemID }),
               (last.accuracy ?? 0) < 1 || (last.errors ?? 0) > 0 { missedDictation.append(removed.itemID) }
        }
    }
    func results(for area: SpeechLabArea) -> [SpeechLabAttempt] { attempts.filter { $0.area == area } }
    func trend(for area: SpeechLabArea) -> String? {
        let values = results(for: area).filter { area == .voice ? $0.wordsPerMinute != nil : $0.accuracy != nil }
        guard values.count >= 2, let first = values.dropLast().last, let last = values.last else { return nil }
        if let current = last.wordsPerMinute, let previous = first.wordsPerMinute {
            let delta = Int((current - previous).rounded())
            return "Pace: \(delta >= 0 ? "+" : "")\(delta) wpm from last time"
        }
        if let current = last.accuracy, let previous = first.accuracy {
            let delta = Int(((current - previous) * 100).rounded())
            return "Accuracy: \(delta >= 0 ? "+" : "")\(delta) points from last time"
        }
        return nil
    }
}

struct SpeechLabDictationItem: Codable, Equatable, Identifiable {
    var id: String
    var level: String
    var category: String
    var title: String
    var text: String
    var spoken: String
}

struct SpeechLabDictationResult: Equatable {
    var diff: [WordDiffEntry]
    var total: Int
    var correct: Int { AnswerChecker.correctCount(diff) }
    var summary: String { "\(correct) of \(total) words" }
}

/// Literal word alignment. Unlike course answers, dictation does not expand contractions.
/// Strict mode keeps case and punctuation attached to each word.
enum SpeechLabDictationChecker {
    static func tokens(_ text: String, strict: Bool) -> [String] {
        let text = String(text.prefix(2000)).replacingOccurrences(of: "’", with: "'")
        if strict { return text.split(whereSeparator: \.isWhitespace).map(String.init) }
        // Ignore apostrophes without splitting contractions; other punctuation separates words.
        let folded = text.lowercased().replacingOccurrences(of: "'", with: "")
        let clean = String(String.UnicodeScalarView(folded.unicodeScalars.map {
            CharacterSet.punctuationCharacters.union(.symbols).contains($0) ? UnicodeScalar(32)! : $0
        }))
        return clean.split(whereSeparator: \.isWhitespace).map(String.init)
    }
    static func check(_ response: String, expected: String, strict: Bool = false) -> SpeechLabDictationResult {
        let a = tokens(response, strict: strict), b = tokens(expected, strict: strict)
        var cost = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in 0...a.count { cost[i][0] = i }
        for j in 0...b.count { cost[0][j] = j }
        if !a.isEmpty && !b.isEmpty {
            for i in 1...a.count { for j in 1...b.count {
                cost[i][j] = min(cost[i - 1][j] + 1, cost[i][j - 1] + 1, cost[i - 1][j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1))
            } }
        }
        var i = a.count, j = b.count, result: [WordDiffEntry] = []
        while i > 0 || j > 0 {
            if i > 0, j > 0, cost[i][j] == cost[i - 1][j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1) {
                let same = a[i - 1] == b[j - 1]
                if same { result.append(.init(mark: .correct, word: a[i - 1])) }
                else if a[i - 1].lowercased() == b[j - 1].lowercased() || AnswerChecker.isSpellingSlip(a[i - 1], b[j - 1]) {
                    result.append(.init(mark: .misspelled, word: a[i - 1], expected: b[j - 1]))
                } else {
                    result.append(.init(mark: .missing, word: b[j - 1]))
                    result.append(.init(mark: .extra, word: a[i - 1]))
                }
                i -= 1; j -= 1
            } else if i > 0, cost[i][j] == cost[i - 1][j] + 1 {
                result.append(.init(mark: .extra, word: a[i - 1])); i -= 1
            } else { result.append(.init(mark: .missing, word: b[j - 1])); j -= 1 }
        }
        return SpeechLabDictationResult(diff: result.reversed(), total: b.count)
    }
}
