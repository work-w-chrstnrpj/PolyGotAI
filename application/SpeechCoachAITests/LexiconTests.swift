import Foundation
import Testing
@testable import SpeechCoachAI

/// Lexicon bank, duplicate check, stages, daily word, training plan and Lexicon in Action (Phase 3).
struct LexiconTests {
    private let bank = LexiconBankLoader.bundled
    private let day1 = Date(timeIntervalSince1970: 1_800_000_000)

    private struct SeededGenerator: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }
    }

    private func repository() throws -> (LearnerRepository, URL) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("LX-\(UUID().uuidString)")
        let repo = try LearnerRepository(root: root, now: { Date() }, protectedDataAvailable: { true })
        return (repo, root)
    }

    private func attempt(_ word: LexiconWord, _ rating: RecallRating, at date: Date) -> VocabularyRecallAttempt {
        VocabularyRecallAttempt(id: UUID(), itemId: word.itemId, senseId: LexiconWord.senseId, lemma: word.lemma,
                                rating: rating, revealed: true, typedAttempt: nil, modality: "selfCheck", createdAt: date)
    }

    private func card(_ word: LexiconWord, rating: RecallRating, at date: Date) throws -> ReviewCardState {
        try ReviewSchedule.schedule(existing: nil, rating: rating, now: date, itemId: word.itemId, senseId: LexiconWord.senseId)
    }

    // MARK: Bank

    @Test func theBankHasThreeGroupsOfFortyValidWords() throws {
        #expect(bank.groups.map(\.id) == ["everyday-a1", "work-office", "academic-basics"])
        #expect(bank.groups.allSatisfy { $0.words.count == 40 })
        #expect(bank.skipped == 0)
        #expect(Set(bank.words.map(\.id)).count == 120)
        #expect(bank.words.allSatisfy { $0.problem() == nil && !$0.parsedExamples.isEmpty && !$0.wrong.isEmpty })
        #expect(bank.words.allSatisfy { !$0.groupId.isEmpty && $0.id.hasPrefix($0.groupId + ".") })
    }

    @Test func exampleMarkersSplitIntoPlainBlankAndForm() throws {
        let example = try #require(LexiconWord.parse("She felt {happy} today."))
        #expect(example.plain == "She felt happy today.")
        #expect(example.blanked == "She felt ___ today.")
        #expect(example.form == "happy")
        #expect(LexiconWord.parse("No marker here.") == nil)
        #expect(LexiconWord.parse("Two {marked} {forms}.") == nil)
    }

    @Test func aMalformedWordIsRejected() {
        var word = LexiconWord(lemma: "test", pos: "noun", meaning: "A check.", examples: ["A {test}."], wrong: ["Wrong."])
        #expect(word.problem() == nil)
        word.pos = "thing"
        #expect(word.problem() != nil)
        word.pos = "noun"; word.examples = ["No marker."]
        #expect(word.problem() != nil)
        word.examples = ["A {test}."]; word.wrong = []
        #expect(word.problem() != nil)
    }

    // MARK: Duplicates

    @Test func duplicatesIgnoreCaseAccentsAndSpaces() {
        let found = LexiconDuplicateCheck.find(lemma: "  HAPPY ", partOfSpeech: "adjective", bank: bank, topics: [], enrollments: [])
        #expect(found?.wordId == "everyday-a1.happy")
        #expect(LexiconDuplicateCheck.find(lemma: "Nai\u{308}ve", partOfSpeech: nil, bank: bank, topics: [], enrollments: []) == nil)
        // A different part of speech is a different word; no part of speech means it cannot be told apart.
        #expect(LexiconDuplicateCheck.find(lemma: "happy", partOfSpeech: "noun", bank: bank, topics: [], enrollments: []) == nil)
        #expect(LexiconDuplicateCheck.find(lemma: "happy", partOfSpeech: nil, bank: bank, topics: [], enrollments: []) != nil)
        #expect(LexiconDuplicateCheck.find(lemma: "zebra", partOfSpeech: "noun", bank: bank, topics: [], enrollments: []) == nil)
    }

    @Test func personalAndSavedWordsCountAsDuplicates() {
        let sense = CustomVocabularySense(id: UUID(), itemId: "personal-1", lemma: "Zebra", note: "An animal with stripes.")
        let topic = CustomVocabularyTopic(id: UUID(), title: "Animals", subtopic: "", senses: [sense], createdAt: day1, updatedAt: day1)
        let personal = LexiconDuplicateCheck.find(lemma: "zebra", partOfSpeech: "noun", bank: bank, topics: [topic], enrollments: [])
        #expect(personal?.source == .personal(topic: "Animals"))
        let saved = VocabularyEnrollment(itemId: "intro-name", senseId: "called", lemma: "Quokka", lessonID: "intro-01",
                                         objectiveID: "INTRO-01", contentVersion: "4", enrolledAt: day1)
        #expect(LexiconDuplicateCheck.find(lemma: "quokka", partOfSpeech: nil, bank: bank, topics: [], enrollments: [saved])?.source == .saved)
    }

    // MARK: Stages

    @Test func stagesFollowTheCardAndTheLatestRating() throws {
        let word = try #require(bank.words.first)
        #expect(LexiconStage.of(card: nil, lastRating: nil) == .new)
        let learning = try card(word, rating: .good, at: day1)
        #expect(LexiconStage.of(card: learning, lastRating: .good) == .learning)
        var review = learning; review.phase = "review"
        #expect(LexiconStage.of(card: review, lastRating: .good) == .review)
        #expect(LexiconStage.of(card: review, lastRating: .easy) == .easy)
        #expect(LexiconStage.of(card: review, lastRating: .hard) == .review)
    }

    @Test func theLedgerUsesTheLatestAttempt() throws {
        let word = try #require(bank.words.first)
        let cards = [try card(word, rating: .easy, at: day1)]
        let earlier = attempt(word, .easy, at: day1)
        let later = attempt(word, .hard, at: day1.addingTimeInterval(60))
        #expect(LexiconLedger.stages(bank: bank, cards: cards, recalls: [earlier])[word.id] == .easy)
        #expect(LexiconLedger.stages(bank: bank, cards: cards, recalls: [later, earlier])[word.id] != .easy)
        #expect(LexiconLedger.stages(bank: bank, cards: [], recalls: [])[word.id] == .new)
    }

    // MARK: Daily Lexicon

    @Test func theDailyWordStaysTheSameAllDayAndMovesOnTomorrow() throws {
        let stages: [String: LexiconStage] = [:]
        let first = try #require(DailyLexicon.pick(bank: bank, state: LexiconState(), stages: stages, day: "2026-10-26"))
        #expect(first.word.id == bank.words[0].id)
        let again = try #require(DailyLexicon.pick(bank: bank, state: first.state, stages: stages, day: "2026-10-26"))
        #expect(again.word.id == first.word.id && again.state == first.state)
        let tomorrow = try #require(DailyLexicon.pick(bank: bank, state: first.state, stages: stages, day: "2026-10-27"))
        #expect(tomorrow.word.id == bank.words[1].id)
    }

    @Test func theDailyWordSkipsEasyWordsAndCyclesWhenAllWereShown() throws {
        let easy = [bank.words[0].id: LexiconStage.easy]
        let pick = try #require(DailyLexicon.pick(bank: bank, state: LexiconState(), stages: easy, day: "2026-10-26"))
        #expect(pick.word.id == bank.words[1].id)
        var state = LexiconState()
        state.shownDailyWordIDs = bank.words.map(\.id)
        let restart = try #require(DailyLexicon.pick(bank: bank, state: state, stages: [:], day: "2026-10-26"))
        #expect(restart.word.id == bank.words[0].id)
        #expect(restart.state.shownDailyWordIDs == [bank.words[0].id])
        let allEasy = Dictionary(uniqueKeysWithValues: bank.words.map { ($0.id, LexiconStage.easy) })
        #expect(DailyLexicon.pick(bank: bank, state: LexiconState(), stages: allEasy, day: "2026-10-26") == nil)
    }

    @Test func dayStringIsTheLocalCalendarDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Manila")!
        let date = Date(timeIntervalSince1970: 1_792_000_000)
        #expect(DailyLexicon.dayString(date, calendar: calendar).count == 10)
    }

    // MARK: Daily Training

    @Test func newWordsComeFromActiveGroupsUpToTheDailyLimit() {
        var state = LexiconState()
        let words = LexiconTrainingPlan.newWords(bank: bank, state: state, enrollments: [], now: day1)
        #expect(words.count == 10)
        #expect(words.allSatisfy { $0.groupId == "everyday-a1" })
        state.setActive(bank.groups[1], true, in: bank)
        #expect(state.activeGroupIDs == ["everyday-a1", "work-office"])
        state.newPerDay = 45
        let many = LexiconTrainingPlan.newWords(bank: bank, state: state, enrollments: [], now: day1)
        #expect(many.count == 45)
        #expect(many[40].groupId == "work-office")
    }

    @Test func wordsAlreadyStartedTodayUseUpTheLimit() {
        let enrollments = bank.words.prefix(10).map { LexiconTrainingPlan.enrollment(for: $0, bankVersion: "1", now: day1) }
        #expect(LexiconTrainingPlan.newWords(bank: bank, state: LexiconState(), enrollments: enrollments, now: day1).isEmpty)
        let tomorrow = day1.addingTimeInterval(86_400)
        let next = LexiconTrainingPlan.newWords(bank: bank, state: LexiconState(), enrollments: enrollments, now: tomorrow)
        #expect(next.count == 10)
        #expect(Set(next.map(\.id)).isDisjoint(with: Set(bank.words.prefix(10).map(\.id))))
    }

    @Test func turningAGroupOffLeavesTheDefaultAlone() {
        var state = LexiconState()
        #expect(state.activeGroups(in: bank).map(\.id) == ["everyday-a1"])
        state.setActive(bank.groups[0], false, in: bank)
        #expect(state.activeGroups(in: bank).isEmpty)
    }

    // MARK: Lexicon in Action

    @Test func onlyEasyWordsWhoseWaitIsOverAreEligible() throws {
        let words = Array(bank.words.prefix(3))
        let stages = [words[0].id: LexiconStage.easy, words[1].id: .easy, words[2].id: .review]
        var state = LexiconState()
        state.action[words[1].id] = LexiconActionProgress(correctStreak: 1, nextDue: day1.addingTimeInterval(86_400))
        let ready = LexiconActionBuilder.eligible(bank: bank, stages: stages, state: state, now: day1)
        #expect(ready.map(\.id) == [words[0].id])
        let later = LexiconActionBuilder.eligible(bank: bank, stages: stages, state: state, now: day1.addingTimeInterval(2 * 86_400))
        #expect(Set(later.map(\.id)) == [words[0].id, words[1].id])
    }

    @Test func questionsAreValidExercisesWithTheRightAnswer() throws {
        var generator = SeededGenerator(state: 11)
        let questions = LexiconActionBuilder.questions(words: Array(bank.words.prefix(12)), bank: bank, count: 10, using: &generator)
        #expect(questions.count == 10)
        #expect(Set(questions.map(\.wordID)).count == 10)
        for question in questions {
            let spec = try #require(question.activity.exercise)
            #expect(spec.problem() == nil)
            let model = try #require(spec.accepted?.first)
            #expect(spec.evaluate(.text(model)) == .correct)
            if question.kind == .chooseSentence {
                #expect((spec.options ?? []).count >= 2)
                #expect(spec.evaluate(.text(spec.options?.first { $0 != model } ?? "")) == .incorrect)
            }
            if question.kind == .clozeChoice { #expect((spec.options ?? []).count == 4) }
            #expect(question.activity.prompt?.contains("{") == false)
        }
        #expect(Set(questions.map(\.kind)) == [.clozeChoice, .chooseSentence, .clozeTyped])
    }

    @Test func aCorrectAnswerLengthensTheWaitAndAMissClearsIt() {
        var state = LexiconState()
        let id = "everyday-a1.happy"
        state = LexiconActionBuilder.updated(state, wordID: id, correct: true, now: day1)
        #expect(state.action[id]?.correctStreak == 1)
        #expect(state.action[id]?.nextDue == day1.addingTimeInterval(1 * 86_400))
        state = LexiconActionBuilder.updated(state, wordID: id, correct: true, now: day1)
        #expect(state.action[id]?.nextDue == day1.addingTimeInterval(3 * 86_400))
        for _ in 0..<10 { state = LexiconActionBuilder.updated(state, wordID: id, correct: true, now: day1) }
        #expect(state.action[id]?.nextDue == day1.addingTimeInterval(60 * 86_400))
        state = LexiconActionBuilder.updated(state, wordID: id, correct: false, now: day1)
        #expect(state.action[id] == nil)
    }

    // MARK: Storage

    @Test func startedWordsAndLexiconStateSurviveARestart() throws {
        let (repo, root) = try repository()
        defer { try? FileManager.default.removeItem(at: root) }
        let words = Array(bank.words.prefix(3))
        let started = try repo.startLexiconWords(words, bankVersion: "1")
        #expect(started.count == 3)
        #expect(try repo.startLexiconWords(words, bankVersion: "1").isEmpty)
        var state = try repo.lexiconState()
        state.newPerDay = 5
        state.setActive(bank.groups[1], true, in: bank)
        try repo.saveLexiconState(state)
        repo.close()
        let reopened = try LearnerRepository(root: root, now: { Date() }, protectedDataAvailable: { true })
        #expect(try reopened.lexiconState().newPerDay == 5)
        #expect(try reopened.reviewQueue().due.count == 3)
        #expect(try reopened.meaningNote(itemId: words[0].itemId, senseId: LexiconWord.senseId) == words[0].meaning)
    }

    @Test func aMissedActionAnswerSendsTheWordBackAsHard() throws {
        let (repo, root) = try repository()
        defer { try? FileManager.default.removeItem(at: root) }
        let word = bank.words[0]
        let card = try #require(try repo.startLexiconWords([word], bankVersion: "1").first)
        _ = try repo.recordVocabularyRecall(card: card, rating: .easy, draft: RecallDraft(revealed: true))
        #expect(try repo.lexiconStages(bank: bank)[word.id] == .easy)
        try repo.recordLexiconAction(word: word, correct: true)
        #expect(try repo.lexiconState().action[word.id]?.correctStreak == 1)
        try repo.recordLexiconAction(word: word, correct: false)
        #expect(try repo.lexiconStages(bank: bank)[word.id] != .easy)
        #expect(try repo.lexiconState().action[word.id] == nil)
    }
}
