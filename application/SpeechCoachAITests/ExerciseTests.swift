import Foundation
import Testing
@testable import SpeechCoachAI

struct ExerciseTests {
    private let choice = ExerciseSpec(type: "choice", options: ["am", "is", "are"], accepted: ["am"])
    private let wordBank = ExerciseSpec(type: "wordBank", options: ["I", "am", "fine.", "is"], accepted: ["I am fine."])
    private let fill = ExerciseSpec(type: "fillBlank", accepted: ["library"])
    private let match = ExerciseSpec(type: "match", pairs: [["hello", "greeting"], ["bye", "farewell"], ["thanks", "gratitude"]])
    private let order = ExerciseSpec(type: "order", items: ["Wake up", "Eat breakfast", "Go to work"])

    @Test func choiceIsExactAndNeverAlmost() {
        #expect(choice.evaluate(.text("am")) == .correct)
        #expect(choice.evaluate(.text("is")) == .incorrect)
        let caps = ExerciseSpec(type: "choice", options: ["My name is Ben.", "my name is ben."], accepted: ["My name is Ben."])
        #expect(caps.evaluate(.text("my name is ben.")) == .incorrect)
    }

    @Test func wordBankJoinsTiles() {
        #expect(wordBank.evaluate(.sequence(["I", "am", "fine."])) == .correct)
        #expect(wordBank.evaluate(.sequence(["I", "is", "fine."])) == .incorrect)
    }

    @Test func fillBlankAllowsASpellingSlip() {
        #expect(fill.evaluate(.text("Library")) == .correct)
        #expect(fill.evaluate(.text("libary")) == .almost(hint: "Check the spelling of “library”."))
        #expect(fill.evaluate(.text("school")) == .incorrect)
    }

    @Test func matchNeedsEveryPair() {
        #expect(match.evaluate(.pairs([["hello", "greeting"], ["bye", "farewell"], ["thanks", "gratitude"]])) == .correct)
        #expect(match.evaluate(.pairs([["hello", "farewell"], ["bye", "greeting"], ["thanks", "gratitude"]])) == .incorrect)
    }

    @Test func orderMustMatchExactly() {
        #expect(order.evaluate(.sequence(["Wake up", "Eat breakfast", "Go to work"])) == .correct)
        #expect(order.evaluate(.sequence(["Eat breakfast", "Wake up", "Go to work"])) == .incorrect)
    }

    @Test func openExercisesAreNotChecked() {
        #expect(ExerciseSpec(type: "open").evaluate(.text("anything")) == nil)
        #expect(!ExerciseSpec(type: "open").isChecked)
    }

    @Test func wrongResponseShapeIsIncorrect() {
        #expect(choice.evaluate(.sequence(["am"])) == .incorrect)
    }

    @Test func specValidationCatchesBrokenContent() {
        #expect(choice.problem() == nil && wordBank.problem() == nil && fill.problem() == nil)
        #expect(match.problem() == nil && order.problem() == nil)
        #expect(ExerciseSpec(type: "choice", options: ["am", "is"], accepted: ["are"]).problem() != nil)
        #expect(ExerciseSpec(type: "choice", options: ["am", "am"], accepted: ["am"]).problem() != nil)
        #expect(ExerciseSpec(type: "choice", options: ["My name is Ben.", "my name is ben."], accepted: ["My name is Ben."]).problem() == nil)
        #expect(ExerciseSpec(type: "wordBank", options: ["I", "fine."], accepted: ["I am fine."]).problem() != nil)
        #expect(ExerciseSpec(type: "fillBlank").problem() != nil)
        #expect(ExerciseSpec(type: "listenType", accepted: ["Hello."]).problem() != nil)
        #expect(ExerciseSpec(type: "listenType", accepted: ["Hello."]).problem(hasClip: true) == nil)
        #expect(ExerciseSpec(type: "listenType", accepted: ["Hello."], audioText: "Hello.").problem() == nil)
        #expect(ExerciseSpec(type: "match", pairs: [["a", "b"], ["c", "d"]]).problem() != nil)
        #expect(ExerciseSpec(type: "order", items: ["a", "b"]).problem() != nil)
        #expect(ExerciseSpec(type: "").problem() != nil)
        #expect(ExerciseSpec(type: "sing").problem() != nil)
    }

    @Test func legacyActivitiesKeepTheirBehavior() {
        let open = CurriculumActivity(id: "a", kind: "recall", required: true, prompt: "Write", answer: "Hello.")
        #expect(open.resolvedExercise.kind == .open)
        let buttons = CurriculumActivity(id: "b", kind: "grammar", required: true, prompt: "Pick", answer: "am", choiceSet: ["am", "is"])
        #expect(buttons.resolvedExercise.kind == .choice)
        #expect(buttons.resolvedExercise.evaluate(.text("am")) == .correct)
    }

    @Test func brokenSpecClosesTheActivity() {
        var activity = CurriculumActivity(id: "c", kind: "grammar", required: true, prompt: "Pick", answer: "am")
        activity.exercise = ExerciseSpec(type: "choice", options: ["am"], accepted: ["am"])
        #expect(activity.metadataProblem() == "c")
        activity.exercise = choice
        #expect(activity.metadataProblem() == nil)
    }

    @Test func exerciseFieldDecodesAndRoundTrips() throws {
        let json = """
        {"id":"x","kind":"grammar","required":true,"prompt":"p","answer":"am",
         "exercise":{"type":"choice","options":["am","is"],"accepted":["am"]}}
        """
        let decoded = try JSONDecoder().decode(CurriculumActivity.self, from: Data(json.utf8))
        #expect(decoded.exercise?.kind == .choice)
        let again = try JSONDecoder().decode(CurriculumActivity.self, from: JSONEncoder().encode(decoded))
        #expect(again == decoded)
        let broken = """
        {"id":"x","kind":"grammar","required":true,"prompt":"p","exercise":{"type":5}}
        """
        let bad = try JSONDecoder().decode(CurriculumActivity.self, from: Data(broken.utf8))
        #expect(bad.metadataProblem() == "x")
    }

    @Test func lessonTrackFieldsAreOptional() throws {
        let json = """
        {"id":"l","contentVersion":"1","level":"A1","title":"T","objectiveId":"O","activities":[],
         "tip":"Tip.","trackId":"grammarian","unitId":"u1","sources":["Elements of Style"]}
        """
        let lesson = try JSONDecoder().decode(CurriculumLesson.self, from: Data(json.utf8))
        #expect(lesson.tip == "Tip." && lesson.trackId == "grammarian" && lesson.sources == ["Elements of Style"])
    }
}

struct ExerciseSessionTests {
    private func session() -> ExerciseSession {
        ExerciseSession(items: [
            .init(id: "1", spec: ExerciseSpec(type: "choice", options: ["a", "b"], accepted: ["a"])),
            .init(id: "2", spec: ExerciseSpec(type: "fillBlank", accepted: ["library"])),
            .init(id: "3", spec: ExerciseSpec(type: "open")),
        ])
    }

    @Test func correctAnswersFlowThroughAndScore() {
        var s = session()
        #expect(s.current?.id == "1")
        #expect(s.submit(.text("a")) == .correct)
        #expect(s.awaitingContinue)
        s.advance()
        #expect(s.submit(.text("libary")) == .almost(hint: "Check the spelling of “library”."))
        s.advance()
        #expect(s.submit(.text("my story")) == nil)
        s.advance()
        #expect(s.isFinished)
        #expect(s.accuracy == 0.75)
        #expect(s.progress == 1)
    }

    @Test func wrongAnswerReturnsOnceAtTheEnd() {
        var s = session()
        s.submit(.text("b")); s.advance()
        #expect(s.current?.id == "2")
        s.submit(.text("library")); s.advance()
        s.submit(.text("note")); s.advance()
        #expect(s.current?.id == "1")
        #expect(s.totalSteps == 4)
        s.submit(.text("b")); s.advance()          // wrong again: not queued a second time
        #expect(s.isFinished)
        #expect(s.firstResults["1"] == .incorrect)  // first try stays the score
        #expect(s.accuracy == 0.5)
    }

    @Test func retryCorrectDoesNotChangeFirstTryScore() {
        var s = session()
        s.submit(.text("b")); s.advance()
        s.submit(.text("library")); s.advance()
        s.submit(.text("note")); s.advance()
        s.submit(.text("a")); s.advance()
        #expect(s.isFinished)
        #expect(s.firstResults["1"] == .incorrect)
    }

    @Test func submitIsIgnoredUntilContinue() {
        var s = session()
        #expect(s.submit(.text("b")) == .incorrect)
        #expect(s.submit(.text("a")) == nil)   // already answered
        #expect(s.firstResults["1"] == .incorrect)
    }

    @Test func legacyActivitiesBuildASession() {
        let s = ExerciseSession(activities: [
            CurriculumActivity(id: "r", kind: "reading", required: true, prompt: "Read", answer: "x"),
            CurriculumActivity(id: "g", kind: "grammar", required: true, prompt: "Pick", answer: "am", choiceSet: ["am", "is"]),
        ])
        #expect(s.items.map(\.spec.type) == ["open", "choice"])
        #expect(s.accuracy == nil)
    }
}

struct DictationTests {
    @Test func spokenTextIsAppendedAfterExistingText() {
        #expect(DictationButton.joined("", "hello there") == "hello there")
        #expect(DictationButton.joined("I like ", "tea") == "I like tea")
        #expect(DictationButton.joined("I like", "tea") == "I like tea")
    }
}
