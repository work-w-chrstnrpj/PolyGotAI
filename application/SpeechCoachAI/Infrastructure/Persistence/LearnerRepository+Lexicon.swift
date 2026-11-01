import Foundation
import SwiftData

/// Lexicon state, stages and Lexicon in Action.
extension LearnerRepository {
    // MARK: Lexicon (v2)

    func lexiconState() throws -> LexiconState { try document().lexicon ?? LexiconState() }

    /// Counts a finished Practice or Vocabulary Enricher round (for the Enricher Rounds and Perfect Round badges).
    func recordPracticeRound(enricher: Bool, perfect: Bool) throws {
        var state = try lexiconState()
        if enricher { state.enricherRounds = (state.enricherRounds ?? 0) + 1 }
        if perfect { state.perfectRounds = (state.perfectRounds ?? 0) + 1 }
        try saveLexiconState(state)
    }

    func saveLexiconState(_ state: LexiconState) throws {
        var stored = try document()
        guard stored.lexicon != state else { return }
        stored.lexicon = state
        try write(stored)
    }

    /// Stage of every bank word from its card and latest rating.
    func lexiconStages(bank: LexiconBank) throws -> [String: LexiconStage] {
        let stored = try document()
        return LexiconLedger.stages(bank: bank, cards: stored.reviewCards, recalls: stored.vocabularyRecalls)
    }

    /// Enrolls today's new words for Daily Training. Words already enrolled are left alone.
    @discardableResult
    func startLexiconWords(_ words: [LexiconWord], bankVersion: String) throws -> [VocabularyEnrollment] {
        guard !words.isEmpty else { return [] }
        var stored = try document()
        let now = try effectiveNow()
        var started: [VocabularyEnrollment] = []
        for word in words where !stored.vocabularyEnrollments.contains(where: { $0.itemId == word.itemId && $0.senseId == LexiconWord.senseId }) {
            let enrollment = LexiconTrainingPlan.enrollment(for: word, bankVersion: bankVersion, now: now)
            stored.vocabularyEnrollments.append(enrollment)
            started.append(enrollment)
        }
        if !started.isEmpty { try write(stored) }
        return started
    }

    /// Saves one Lexicon in Action answer. A miss sends the word back to Daily Training with a Hard rating.
    func recordLexiconAction(word: LexiconWord, correct: Bool) throws {
        let now = try effectiveNow()
        if !correct, let card = try document().vocabularyEnrollments.first(where: { $0.itemId == word.itemId && $0.senseId == LexiconWord.senseId }) {
            _ = try recordVocabularyRecall(card: card, rating: .hard, draft: RecallDraft(revealed: true))
        }
        try saveLexiconState(LexiconActionBuilder.updated(try lexiconState(), wordID: word.id, correct: correct, now: now))
    }
}
