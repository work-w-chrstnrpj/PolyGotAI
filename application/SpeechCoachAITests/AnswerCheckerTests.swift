import Foundation
import Testing
@testable import SpeechCoachAI

struct AnswerCheckerTests {
    @Test func caseQuotesAndPunctuationAreIgnored() {
        #expect(AnswerChecker.check("  I AM fine!  ", accepted: ["I am fine."]) == .correct)
        #expect(AnswerChecker.check("It\u{2019}s fine", accepted: ["it's fine"]) == .correct)
        #expect(AnswerChecker.check("well-known", accepted: ["well known"]) == .correct)
    }

    @Test func contractionsMatchTheirLongForms() {
        #expect(AnswerChecker.check("I'm tired", accepted: ["I am tired"]) == .correct)
        #expect(AnswerChecker.check("I am not tired", accepted: ["I'm not tired"]) == .correct)
        #expect(AnswerChecker.check("She doesn't know", accepted: ["She does not know"]) == .correct)
        #expect(AnswerChecker.check("We won't go", accepted: ["We will not go"]) == .correct)
        #expect(AnswerChecker.check("I can't swim", accepted: ["I can not swim"]) == .correct)
        #expect(AnswerChecker.check("They're here", accepted: ["They are here"]) == .correct)
        #expect(AnswerChecker.check("Let's go", accepted: ["Let us go"]) == .correct)
    }

    @Test func anyAcceptedAlternativeCounts() {
        let accepted = ["I am well, thank you.", "I'm fine, thanks."]
        #expect(AnswerChecker.check("im fine thanks", accepted: accepted) == .incorrect)
        #expect(AnswerChecker.check("I'm fine, thanks", accepted: accepted) == .correct)
        #expect(AnswerChecker.check("I am well thank you", accepted: accepted) == .correct)
    }

    @Test func smallSpellingSlipIsAlmost() {
        let result = AnswerChecker.check("She goes to the libary", accepted: ["She goes to the library"])
        #expect(result == .almost(hint: "Check the spelling of “library”."))
        #expect(AnswerChecker.check("I recieve mail", accepted: ["I receive mail"]) == .almost(hint: "Check the spelling of “receive”."))
    }

    @Test func shortWordsAndWrongWordsAreNotAlmost() {
        #expect(AnswerChecker.check("He is here", accepted: ["She is here"]) == .incorrect)
        #expect(AnswerChecker.check("I am fine", accepted: ["I is fine"]) == .incorrect)
        #expect(AnswerChecker.check("They went there", accepted: ["They went their"]) == .incorrect)
    }

    @Test func wrongWordCountAndEmptyAreIncorrect() {
        #expect(AnswerChecker.check("I am", accepted: ["I am fine"]) == .incorrect)
        #expect(AnswerChecker.check("   ", accepted: ["I am fine"]) == .incorrect)
        #expect(AnswerChecker.check("I am fine", accepted: []) == .incorrect)
    }

    @Test func almostCanBeTurnedOff() {
        #expect(AnswerChecker.check("libary", accepted: ["library"], allowAlmost: false) == .incorrect)
    }

    @Test func longWordsAllowTwoEdits() {
        #expect(AnswerChecker.isSpellingSlip("accomodation", "accommodation"))
        #expect(!AnswerChecker.isSpellingSlip("hat", "cat"))   // three-letter words must match exactly
        #expect(AnswerChecker.isSpellingSlip("form", "from"))
    }

    @Test func diffMarksEachWord() {
        let diff = AnswerChecker.diff(response: "the cat sat on mat", expected: "The cat sat on the mat.")
        #expect(diff.map(\.mark) == [.correct, .correct, .correct, .correct, .missing, .correct])
        #expect(diff[4].word == "the")
        #expect(AnswerChecker.accuracy(of: diff) == 5.0 / 6.0)
    }

    @Test func diffFindsMisspellingsAndExtraWords() {
        let diff = AnswerChecker.diff(response: "she goes to the libary today", expected: "She goes to the library")
        #expect(diff.contains(WordDiffEntry(mark: .misspelled, word: "libary", expected: "library")))
        #expect(diff.contains(WordDiffEntry(mark: .extra, word: "today")))
    }

    @Test func diffOfDifferentWordsIsExtraPlusMissing() {
        let diff = AnswerChecker.diff(response: "I like dogs", expected: "I like cats")
        #expect(diff.map(\.mark) == [.correct, .correct, .extra, .missing])
        #expect(AnswerChecker.accuracy(of: diff) == 2.0 / 3.0)
    }

    @Test func bestDiffPicksTheClosestAcceptedText() {
        let diff = AnswerChecker.bestDiff(response: "I am fine thanks", accepted: ["I am well, thank you.", "I am fine, thanks."])
        #expect(diff.allSatisfy { $0.mark == .correct })
    }
}
