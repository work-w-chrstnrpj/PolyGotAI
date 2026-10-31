import Foundation
import Testing
@testable import SpeechCoachAI

/// Phase 8: rank filter, hidden packs, Practice questions, Anki-style interval labels, saved-word origin.
struct LexiconTrainingTests {
    private let bank = LexiconBankLoader.bundled
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private struct Seeded: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }
    }

    // MARK: Ranks and hidden packs

    @Test func c2OnlyTrainsEveryC2PackWhenNoC2PackWasChosen() {
        var state = LexiconState()
        state.setRanks(["C2"])
        let groups = state.trainingGroups(in: bank, startLevel: "A1")
        #expect(!groups.isEmpty)
        #expect(groups.allSatisfy { $0.level == "C2" && !$0.isField })
        #expect(Set(groups.map(\.id)) == Set(bank.groups.filter { !$0.isField && $0.level == "C2" }.map(\.id)))
    }

    @Test func chosenPacksInsideTheRanksAreKeptAndFieldPacksIgnoreRanks() throws {
        let c2 = try #require(bank.groups.first { $0.level == "C2" && !$0.isField })
        let field = try #require(bank.groups.first { $0.isField })
        var state = LexiconState()
        state.setActive(c2, true, in: bank); state.setActive(field, true, in: bank)
        state.setRanks(["C2"])
        #expect(Set(state.trainingGroups(in: bank).map(\.id)) == [c2.id, field.id])
    }

    @Test func allRanksOrNoneMeansEveryRank() {
        var state = LexiconState()
        state.setRanks(Set(LevelGate.levels))
        #expect(state.ranks == nil)
        state.setRanks([])
        #expect(state.ranks == nil)
        state.setRanks(["B2", "A2"])
        #expect(state.ranks == ["A2", "B2"])
    }

    @Test func hidingAPackStopsTrainingItAndShowingDoesNotRestartIt() throws {
        let group = try #require(bank.groups.first { !$0.isField })
        var state = LexiconState()
        state.setActive(group, true, in: bank)
        state.setHidden(group, true, in: bank)
        #expect(state.hidden.contains(group.id))
        #expect(!state.trainingGroups(in: bank).contains { $0.id == group.id })
        state.setHidden(group, false, in: bank)
        #expect(!state.hidden.contains(group.id))
        #expect(!state.isActive(group, in: bank))
    }

    @Test func newWordsComeOnlyFromTheChosenRanks() {
        var state = LexiconState()
        state.setRanks(["C1"])
        let words = LexiconTrainingPlan.newWords(bank: bank, state: state, enrollments: [], now: now)
        #expect(!words.isEmpty)
        #expect(words.allSatisfy { bank.group(id: $0.groupId)?.level == "C1" })
    }

    @Test func olderSavedStateWithoutRanksStillDecodes() throws {
        let old = #"{"newPerDay":5,"shownDailyWordIDs":[],"action":{}}"#
        let state = try JSONDecoder().decode(LexiconState.self, from: Data(old.utf8))
        #expect(state.ranks == nil && state.hiddenGroupIDs == nil && state.newPerDay == 5)
    }

    // MARK: Practice

    @Test func theBundledBankHasSynonymsForMostWords() {
        let withSynonyms = bank.words.filter { !$0.synonyms.isEmpty }
        #expect(withSynonyms.count >= 1_700)
        #expect(withSynonyms.allSatisfy { word in !word.synonyms.contains { LexiconKey.normalize($0) == LexiconKey.normalize(word.lemma) } })
    }

    @Test func everySynonymQuestionHasOneSynonymAndThreeNonSynonyms() {
        var generator = Seeded(state: 7)
        for word in bank.words where !word.synonyms.isEmpty {
            guard let question = LexiconPracticeBuilder.synonymQuestion(word, bank: bank, using: &generator) else {
                Issue.record("no synonym question for \(word.lemma)"); continue
            }
            let options = question.activity.exercise?.options ?? []
            #expect(options.count == 4, "\(word.lemma)")
            #expect(Set(options.map(LexiconKey.normalize)).count == 4, "\(word.lemma)")
            let correct = options.filter { option in word.synonyms.contains { LexiconKey.normalize($0) == LexiconKey.normalize(option) } }
            #expect(correct.count == 1, "\(word.lemma): \(options)")
            #expect(!options.contains { LexiconKey.normalize($0) == LexiconKey.normalize(word.lemma) })
        }
    }

    @Test func sentenceQuestionsBlankTheWordAndOfferFourChoices() throws {
        var generator = Seeded(state: 3)
        let word = try #require(bank.words.first { $0.lemma == "happy" })
        let question = try #require(LexiconPracticeBuilder.sentenceQuestion(word, bank: bank, using: &generator))
        let options = question.activity.exercise?.options ?? []
        #expect(options.count == 4)
        #expect(options.contains(question.activity.answer ?? ""))
        #expect(question.activity.prompt?.contains("___") == true)
    }

    @Test func aRoundMixesBothKindsAndHasTenQuestions() {
        var generator = Seeded(state: 11)
        let words = Array(bank.words.prefix(40))
        let round = LexiconPracticeBuilder.questions(words: words, bank: bank, using: &generator)
        #expect(round.count == LexiconPracticeBuilder.sessionSize)
        #expect(round.contains { $0.activity.id.hasSuffix("#practice-synonym") })
        #expect(round.contains { $0.activity.id.hasSuffix("#practice-sentence") })
    }

    @Test func thePoolUsesStartedWordsOrElseThePacksInTraining() {
        let state = LexiconState()
        let fallback = LexiconPracticeBuilder.pool(bank: bank, stages: [:], state: state, startLevel: "A1")
        #expect(fallback.count == state.trainingGroups(in: bank).flatMap(\.words).count)
        let started = Dictionary(uniqueKeysWithValues: bank.words.prefix(5).map { ($0.id, LexiconStage.learning) })
        #expect(LexiconPracticeBuilder.pool(bank: bank, stages: started, state: state, startLevel: "A1").count == 5)
    }

    // MARK: Interval labels

    @Test func aNewCardShowsIncreasingWaitsLikeAnki() throws {
        let preview = ReviewSchedule.preview(existing: nil, now: now, itemId: "lex.x", senseId: "1")
        let again = try #require(preview[.again]), hard = try #require(preview[.hard])
        let good = try #require(preview[.good]), easy = try #require(preview[.easy])
        #expect(again <= hard && hard <= good && good < easy)
        #expect(easy.timeIntervalSince(now) >= 86_400)
    }

    @Test func shortIntervalsReadLikeAnki() {
        func label(_ seconds: Double) -> String { ReviewSchedule.shortInterval(from: now, to: now.addingTimeInterval(seconds)) }
        #expect(label(30) == "<1m")
        #expect(label(600) == "10m")
        #expect(label(3 * 3600) == "3h")
        #expect(label(4 * 86_400) == "4d")
        #expect(label(60 * 86_400) == "2mo")
        #expect(label(45 * 86_400) == "1.5mo")
        #expect(label(730 * 86_400) == "2y")
    }

    // MARK: Saved words

    @Test func savedWordsAreSeparateFromLexiconAndOwnPacks() {
        func enrollment(_ objective: String) -> VocabularyEnrollment {
            VocabularyEnrollment(itemId: "i", senseId: "s", lemma: "w", lessonID: "l", objectiveID: objective,
                                 contentVersion: "1", enrolledAt: now)
        }
        #expect(enrollment("lexicon").origin == .lexicon)
        #expect(enrollment("personal-vocabulary").origin == .personal)
        #expect(enrollment("A1-GREET-01").origin == .saved)
    }
}
