import Foundation
import Testing
@testable import SpeechCoachAI

/// Phase 5b core: turn-taking rules, the scripted question bank, follow-up rule and the session model. No screens.
struct HandsFreeInterviewTests {
    private let t0 = Date(timeIntervalSince1970: 1_800_000_000)
    private let bank = SpeechLabCatalog.bundled.interview

    private func at(_ seconds: Double) -> Date { t0.addingTimeInterval(seconds) }

    // MARK: Bank

    @Test func theBankHasThreeCompleteSets() {
        #expect(Set(bank.map(\.set)) == ["general", "job", "study"])
        #expect(bank.count == 39)
        for set in ["general", "job", "study"] {
            let rows = bank.filter { $0.set == set }
            #expect(rows.contains { $0.stage == .opening } && rows.contains { $0.stage == .closing })
            #expect(rows.filter { $0.stage == .core }.count >= 6)
            #expect(rows.contains { $0.stage == .core && ["A1", "A2"].contains($0.level) }, "\(set) has an easy core question")
        }
        #expect(Set(bank.map(\.id)).count == bank.count)
        #expect(bank.allSatisfy { !$0.followUpShort.isEmpty && !$0.followUpLong.isEmpty && $0.followUpShort != $0.followUpLong })
    }

    // MARK: Turn taking

    @Test func silenceAfterSpeechEndsTheTurn() {
        var detector = TurnDetector(startedAt: t0)
        #expect(detector.tick(at: at(1)) == .keepListening)
        detector.heard(words: 3, at: at(2))
        #expect(detector.tick(at: at(3.5)) == .keepListening)
        #expect(detector.tick(at: at(4)) == .endTurn(.silence))
    }

    @Test func newWordsRestartTheSilenceClock() {
        var detector = TurnDetector(startedAt: t0)
        detector.heard(words: 2, at: at(1))
        detector.heard(words: 2, at: at(2.5))   // the caption repeated itself: not new speech
        #expect(detector.tick(at: at(3)) == .endTurn(.silence))
        var other = TurnDetector(startedAt: t0)
        other.heard(words: 2, at: at(1))
        other.heard(words: 5, at: at(2.5))
        #expect(other.tick(at: at(3)) == .keepListening)
        #expect(other.tick(at: at(4.5)) == .endTurn(.silence))
    }

    @Test func nothingSaidPromptsTwiceThenOffersSkip() {
        var detector = TurnDetector(startedAt: t0)
        #expect(detector.tick(at: at(7)) == .keepListening)
        #expect(detector.tick(at: at(8)) == .promptToSpeak(1))
        #expect(detector.tick(at: at(12)) == .keepListening)
        #expect(detector.tick(at: at(16)) == .promptToSpeak(2))
        #expect(detector.tick(at: at(24)) == .offerSkip)
    }

    @Test func aLongAnswerEndsAtTheTimeLimit() {
        var detector = TurnDetector(rules: TurnTakingRules(maxTurn: 20), startedAt: t0)
        detector.heard(words: 4, at: at(18))
        #expect(detector.tick(at: at(19)) == .keepListening)
        detector.heard(words: 9, at: at(19.5))
        #expect(detector.tick(at: at(20)) == .endTurn(.maxLength))
        var silent = TurnDetector(rules: TurnTakingRules(maxTurn: 20), startedAt: t0)
        #expect(silent.tick(at: at(20)) == .offerSkip)
    }

    // MARK: Follow-ups and planning

    @Test func shortAnswersGetTheTellMeMoreFollowUp() throws {
        let question = try #require(bank.first { $0.stage == .core })
        #expect(InterviewFollowUpRule.text(for: question, wordCount: 5) == question.followUpShort)
        #expect(InterviewFollowUpRule.text(for: question, wordCount: 12) == question.followUpLong)
    }

    @Test func thePlanHasOneOpeningCoreQuestionsAndOneClosing() {
        let plan = HandsFreeInterview.plan(set: "job", level: "B1", bank: bank, count: 6)
        #expect(plan.count == 6)
        #expect(plan.first?.stage == .opening && plan.last?.stage == .closing)
        #expect(plan.dropFirst().dropLast().allSatisfy { $0.stage == .core })
        func rank(_ level: String) -> Int { LevelGate.levels.firstIndex(of: level) ?? 99 }
        #expect(plan.allSatisfy { rank($0.level) <= rank("B1") })
        let ranks = plan.dropFirst().dropLast().map { rank($0.level) }
        #expect(ranks == ranks.sorted(), "easiest core question first")
        #expect(plan.allSatisfy { $0.set == "job" })
    }

    @Test func aDifferentSeedAsksDifferentQuestions() {
        let first = HandsFreeInterview.plan(set: "general", level: "C1", bank: bank, count: 6, seed: 0).map(\.id)
        let second = HandsFreeInterview.plan(set: "general", level: "C1", bank: bank, count: 6, seed: 3).map(\.id)
        #expect(first != second)
        #expect(HandsFreeInterview.plan(set: "general", level: "C1", bank: bank, count: 6, seed: 0).map(\.id) == first, "deterministic")
    }

    @Test func aLowLevelOnlyGetsEasyQuestions() {
        let plan = HandsFreeInterview.plan(set: "general", level: "A1", bank: bank)
        #expect(plan.map(\.level).allSatisfy { $0 == "A1" })
        #expect(HandsFreeInterview.plan(set: "nope", level: "C2", bank: bank).isEmpty)
    }

    // MARK: Session

    private func session(count: Int = 4) -> HandsFreeInterview {
        HandsFreeInterview(setID: "general", questions: HandsFreeInterview.plan(set: "general", level: "B2", bank: bank, count: count), now: t0)
    }

    @Test func aCoreAnswerGetsExactlyOneFollowUp() throws {
        var interview = session()
        #expect(interview.progress == "Question 1 of 4")
        interview.record(transcript: "My name is Lee and I am from Cebu.", duration: 6, end: .silence, now: at(10))  // opening: no follow-up
        #expect(interview.progress == "Question 2 of 4")
        let question = try #require(interview.current)
        #expect(interview.prompt == question.text)
        interview.record(transcript: "I work from Monday to Friday.", duration: 5, end: .silence, now: at(20))
        #expect(interview.prompt == question.followUpShort, "a short answer gets the short follow-up")
        #expect(interview.progress == "Question 2 of 4", "a follow-up does not change the count")
        interview.record(transcript: "Every day is busy.", duration: 3, end: .silence, now: at(30))
        #expect(interview.progress == "Question 3 of 4")
        #expect(interview.turns.map(\.kind) == [.question, .question, .followUp])
    }

    @Test func aLongAnswerGetsTheDeeperFollowUp() throws {
        var interview = session()
        interview.record(transcript: "Hello", duration: 1, end: .manual, now: at(1))
        let question = try #require(interview.current)
        let longAnswer = Array(repeating: "word", count: 20).joined(separator: " ")
        interview.record(transcript: longAnswer, duration: 15, end: .silence, now: at(20))
        #expect(interview.prompt == question.followUpLong)
    }

    @Test func skippingAndRepeatingAreNoted() throws {
        var interview = session()
        let first = try #require(interview.prompt)
        #expect(interview.repeatPrompt() == first)
        interview.skip(now: at(5))
        #expect(interview.turns.first?.skipped == true && interview.turns.first?.repeats == 1)
        // A skipped core question gets no follow-up.
        interview.skip(now: at(8))
        #expect(interview.progress == "Question 3 of 4")
        #expect(interview.turns.count == 2)
    }

    @Test func anEmptyAnswerDoesNotTriggerAFollowUp() {
        var interview = session()
        interview.record(transcript: "Hi", duration: 1, end: .silence, now: at(1))
        interview.record(transcript: "  ", duration: 90, end: .maxLength, now: at(95))
        #expect(interview.progress == "Question 3 of 4")
    }

    @Test func theSessionFinishesAfterTheLastQuestionAndSummarizes() {
        var interview = session(count: 3)   // opening, one core, closing
        interview.record(transcript: "I am Lee from Cebu city in the Philippines.", duration: 8, end: .silence, now: at(10))
        interview.record(transcript: "I like to read and um walk in the evening after work.", duration: 10, end: .silence, now: at(25))
        interview.skip(now: at(26))                      // the follow-up
        interview.record(transcript: "No thank you.", duration: 2, end: .silence, now: at(30))
        #expect(interview.isFinished && interview.current == nil && interview.prompt == nil && interview.progress == nil)
        let summary = interview.summary
        #expect(summary.answered == 3 && summary.skipped == 1 && summary.followUps == 0)
        #expect(summary.fillers == 1)
        #expect(summary.longestAnswerWords >= 10)
        #expect(summary.wordsPerMinute == Int((Double(summary.totalWords) * 60 / 20).rounded()))
        #expect(summary.lines.first == "3 answers, 1 skipped")
    }

    @Test func finishingEarlyKeepsTheTurnsSoFar() {
        var interview = session()
        interview.record(transcript: "Hello there, I am Lee.", duration: 4, end: .silence, now: at(5))
        interview.finish(now: at(6))
        #expect(interview.isFinished && interview.turns.count == 1)
        interview.record(transcript: "late", duration: 1, end: .manual, now: at(7))
        #expect(interview.turns.count == 1, "nothing is recorded after the interview ends")
        #expect(interview.summary.wordsPerMinute == nil, "too little speech for a pace")
    }

    @Test func theSessionRoundTripsThroughJSON() throws {
        var interview = session()
        interview.record(transcript: "Hello there, I am Lee.", duration: 4, end: .silence, now: at(5))
        let data = try JSONEncoder().encode(interview)
        #expect(try JSONDecoder().decode(HandsFreeInterview.self, from: data) == interview)
    }
}
