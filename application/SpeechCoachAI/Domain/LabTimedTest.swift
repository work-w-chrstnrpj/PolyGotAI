import Foundation
import CryptoKit

// Phase 15: timed tests in the Lab. The online model writes each item (`LabTimedTests.swift`); this file holds the
// pure parts: the kinds, the themes that keep tests varied, the clock, the answers, and the fingerprints that stop repeats.

enum TimedTestKind: String, CaseIterable, Identifiable, Codable {
    case writing, reading, analogies
    var id: String { rawValue }

    var title: String {
        switch self {
        case .writing: "Impromptu writing"
        case .reading: "Timed reading"
        case .analogies: "Analogies"
        }
    }
    var symbol: String {
        switch self {
        case .writing: "square.and.pencil"
        case .reading: "text.book.closed"
        case .analogies: "arrow.left.arrow.right"
        }
    }
    /// One line under the title in the list.
    var subtitle: String {
        switch self {
        case .writing: "A new topic, 5 minutes, AI feedback"
        case .reading: "A passage and 5 questions in 6 minutes"
        case .analogies: "10 items in 4 minutes"
        }
    }
    var seconds: Int {
        switch self {
        case .writing: 300
        case .reading: 360
        case .analogies: 240
        }
    }
    var questionCount: Int {
        switch self {
        case .writing: 0
        case .reading: 5
        case .analogies: 10
        }
    }

    /// Everyday themes, picked at random so two tests in a row are about different things.
    static let themes = [
        "food and cooking", "travel", "work and careers", "technology in daily life", "sports and games", "nature and parks",
        "city life", "friendship", "learning and school", "music", "shopping and money", "weather and seasons",
        "healthy habits", "animals", "inventions", "science in everyday life", "art and design", "transportation",
        "family routines", "festivals and holidays", "the ocean", "space", "books and stories", "movies and TV",
        "volunteering", "small businesses", "the internet", "gardening", "houses and homes", "time management",
    ]
}

/// One multiple-choice item: a reading question or an analogy.
struct TimedChoice: Equatable {
    var prompt: String
    var options: [String]
    var answer: Int
}

struct TimedTest: Equatable {
    var kind: TimedTestKind
    var theme: String
    var level: String
    /// Writing: the topic to write about.
    var topic = ""
    /// Reading: the passage.
    var passage = ""
    /// Reading questions or analogy items.
    var items: [TimedChoice] = []

    /// A writing topic or a reading passage counts as one item; analogies count one by one.
    var fingerprints: [String] {
        switch kind {
        case .writing: [Self.fingerprint(topic)]
        case .reading: [Self.fingerprint(String(passage.prefix(400)))]
        case .analogies: items.map { Self.fingerprint($0.prompt + " " + ($0.options[safe: $0.answer] ?? "")) }
        }
    }

    /// Lowercase words only, hashed, so small changes in spacing or punctuation still count as the same item.
    static func fingerprint(_ text: String) -> String {
        let words = SpeechLabDictationChecker.tokens(text, strict: false).joined(separator: " ")
        return SHA256.hash(data: Data(words.utf8)).prefix(12).map { String(format: "%02x", $0) }.joined()
    }

    static func analogyPrompt(first: String, second: String, third: String) -> String {
        "\(first) is to \(second) as \(third) is to …"
    }
}

/// The countdown for a running test. Time is read from dates, so it keeps going while the screen is in the background.
struct TimedTestClock: Equatable {
    var started: Date
    var seconds: Int

    var ends: Date { started.addingTimeInterval(TimeInterval(seconds)) }
    func remaining(at now: Date) -> Int { max(0, Int(ends.timeIntervalSince(now).rounded(.up))) }
    func isOver(at now: Date) -> Bool { now >= ends }

    static func label(_ seconds: Int) -> String { String(format: "%d:%02d", seconds / 60, seconds % 60) }
}

/// The learner's choices in a reading or analogies test. Unanswered items count as wrong.
struct TimedChoiceAnswers: Equatable {
    var picks: [Int?]

    init(count: Int) { picks = Array(repeating: nil, count: count) }

    var answeredCount: Int { picks.compactMap { $0 }.count }
    func correctCount(_ items: [TimedChoice]) -> Int {
        zip(items, picks).filter { item, pick in pick == item.answer }.count
    }
    func summary(_ items: [TimedChoice]) -> String { "\(correctCount(items)) of \(items.count) correct" }
}

fileprivate extension Array {
    subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}
