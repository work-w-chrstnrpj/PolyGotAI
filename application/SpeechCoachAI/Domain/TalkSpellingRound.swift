import Foundation

struct SpellingRound {
    let words: [LexiconWord]
    private(set) var index = 0
    private(set) var correct = 0
    private(set) var checked: Bool? = nil
    var current: LexiconWord? { words.indices.contains(index) ? words[index] : nil }
    var finished: Bool { index >= words.count }
    init(bank: LexiconBank, rank: String, shuffle: Bool = true) {
        let candidates = bank.words.filter { $0.cefr == rank }
        words = Array((shuffle ? candidates.shuffled() : candidates).prefix(10))
    }
    @discardableResult mutating func check(_ answer: String) -> Bool? {
        guard checked == nil, let word = current, !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let matches = Self.normalized(answer) == Self.normalized(word.lemma)
        checked = matches; if matches { correct += 1 }; return matches
    }
    mutating func next() { guard checked != nil else { return }; index += 1; checked = nil }
    static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().precomposedStringWithCanonicalMapping
    }
    static func prompt(_ word: LexiconWord) -> String {
        "\(word.lemma). \(word.meaning). \(word.parsedExamples.first?.plain ?? "")"
    }
    static func correction(_ word: LexiconWord) -> String {
        "\(word.lemma). " + word.lemma.map { $0 == " " ? "space" : String($0) }.joined(separator: ", ")
    }
}
