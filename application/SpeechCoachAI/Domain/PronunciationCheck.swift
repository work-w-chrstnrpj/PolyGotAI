import Accelerate
import Foundation

// MARK: Minimal pairs (Phase 10)

/// Two words that differ by one sound. The learner says `target`; hearing `contrast` means the sound slipped.
struct MinimalPair: Codable, Equatable, Identifiable {
    var id: String
    /// The `SpeechLabSound` this pair practises.
    var sound: String
    var target: String
    var contrast: String
    /// How to fix it when the contrast was heard.
    var tip: String
}

enum PairVerdict: Equatable {
    /// The recogniser heard the target word.
    case clear
    /// It heard the other word of the pair.
    case soundedLike(String)
    /// It heard something else.
    case heard(String)
    /// Nothing was recognised.
    case nothing
}

enum MinimalPairJudge {
    /// Judges the best transcription. Only whole words count, so "ship" never matches "shipping".
    static func judge(_ pair: MinimalPair, heard: String) -> PairVerdict {
        let words = AnswerChecker.words(in: heard)
        guard !words.isEmpty else { return .nothing }
        let target = AnswerChecker.words(in: pair.target), contrast = AnswerChecker.words(in: pair.contrast)
        if contains(words, target) { return .clear }
        if contains(words, contrast) { return .soundedLike(pair.contrast) }
        return .heard(heard.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private static func contains(_ words: [String], _ phrase: [String]) -> Bool {
        guard !phrase.isEmpty, words.count >= phrase.count else { return false }
        return (0...(words.count - phrase.count)).contains { Array(words[$0..<($0 + phrase.count)]) == phrase }
    }
}
