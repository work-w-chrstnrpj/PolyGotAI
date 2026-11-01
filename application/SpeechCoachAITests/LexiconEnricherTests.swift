import Foundation
import Testing
@testable import SpeechCoachAI

/// 2026-10-30: Anki-style repeats in Daily Training, IPA and antonyms in the bank, and Vocabulary Enricher.
struct LexiconEnricherTests {
    private let bank = LexiconBankLoader.bundled
    private let now = Date(timeIntervalSince1970: 1_792_800_000)

    private func card(_ word: LexiconWord) -> VocabularyEnrollment {
        LexiconTrainingPlan.enrollment(for: word, bankVersion: "1", now: now)
    }

    private struct Seeded: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 { state = state &* 6364136223846793005 &+ 1442695040888963407; return state }
    }

    @Test func againBringsTheCardBackInTheSameSitting() {
        let words = Array(bank.words.prefix(3)).map(card)
        var sitting = TrainingSitting(waiting: words)
        #expect(sitting.next(now: now) == words[0])
        sitting.rated(words[0], due: now.addingTimeInterval(60), now: now)           // Again: 1 minute
        #expect(sitting.remaining == 3)
        #expect(sitting.next(now: now) == words[1], "not due yet, so the next new card comes first")
        sitting.rated(words[1], due: now.addingTimeInterval(4 * 86_400), now: now)  // Good: days away, leaves the pile
        #expect(sitting.next(now: now.addingTimeInterval(61)) == words[0], "due again: it comes before the waiting card")
        sitting.rated(words[0], due: now.addingTimeInterval(600), now: now)          // a learning step, 10 minutes
        #expect(sitting.next(now: now.addingTimeInterval(62)) == words[2])
        #expect(sitting.next(now: now.addingTimeInterval(63)) == words[0], "nothing else left: learn ahead")
        #expect(sitting.next(now: now) == nil)
    }

    @Test func everyBankWordHasIPAAndAntonymsAreNeverTheWordOrASynonym() {
        for word in bank.words {
            #expect(word.ipa?.hasPrefix("/") == true && word.ipa?.hasSuffix("/") == true, "\(word.id)")
            let blocked = Set(([word.lemma] + word.synonyms).map(LexiconKey.normalize))
            #expect(word.antonyms.allSatisfy { !blocked.contains(LexiconKey.normalize($0)) }, "\(word.id)")
        }
        #expect(bank.words.filter { !$0.antonyms.isEmpty }.count > 500)
    }

    @Test func enricherUsesAnyPackWordAndAllFourQuestionKinds() throws {
        var generator = Seeded(state: 7)
        var state = LexiconState()
        state.activeGroupIDs = bank.groups.filter { $0.level == "B2" && !$0.isField }.map(\.id)
        let pool = LexiconPracticeBuilder.enricherPool(bank: bank, state: state, startLevel: "A1")
        #expect(pool.count > 100 && pool.allSatisfy { $0.cefr <= "B2" })
        var kinds = Set<String>()
        for _ in 0..<10 {
            for question in LexiconPracticeBuilder.enricherQuestions(words: pool, bank: bank, using: &generator) {
                let options = question.activity.exercise?.options ?? []
                #expect(options.count == 4 && Set(options.map(LexiconKey.normalize)).count == 4, "\(question.id)")
                #expect(options.contains(question.activity.answer ?? ""), "\(question.id)")
                kinds.insert(String(question.id.split(separator: "#").last ?? ""))
            }
        }
        #expect(kinds == ["enricher-meaning", "practice-synonym", "enricher-antonym", "practice-sentence"])
    }

    @Test func theMeaningQuestionNeverShowsTheWordInItsPrompt() {
        var generator = Seeded(state: 3)
        for word in bank.words.prefix(400) {
            guard let question = LexiconPracticeBuilder.meaningQuestion(word, bank: bank, using: &generator) else { continue }
            #expect(!LexiconPracticeBuilder.mentions((question.activity.prompt ?? "").replacingOccurrences(of: "Which word means: ", with: ""), word.lemma), "\(word.id)")
        }
    }
}
