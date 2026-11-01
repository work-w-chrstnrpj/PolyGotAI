import Foundation
import Testing
@testable import SpeechCoachAI

@MainActor struct SpeechLabDictationTests {
    @Test func diffHandlesCasePunctuationSpellingMissingAndExtra() {
        let result = SpeechLabDictationChecker.check("THE smal cat, sleeps extra", expected: "The small cat sleeps here.")
        #expect(result.correct == 3)
        #expect(result.total == 5)
        #expect(result.diff.contains { $0.mark == .misspelled && $0.expected == "small" })
        #expect(result.diff.contains { $0.mark == .missing && $0.word == "here" })
        #expect(result.diff.contains { $0.mark == .extra && $0.word == "extra" })
        #expect(SpeechLabDictationChecker.check("hello", expected: "Hello.", strict: true).correct == 0)
        #expect(SpeechLabDictationChecker.check("hello", expected: "Hello.").correct == 1)
    }
    @Test func emptyAndRepeatedWordsAreAligned() {
        #expect(SpeechLabDictationChecker.check("", expected: "one two").diff.allSatisfy { $0.mark == .missing })
        #expect(SpeechLabDictationChecker.check("one", expected: "").diff.first?.mark == .extra)
        #expect(SpeechLabDictationChecker.check("we we go", expected: "we go").correct == 2)
        #expect(SpeechLabDictationChecker.check("I'm here", expected: "I'm here").total == 2)
        #expect(SpeechLabDictationChecker.check("Im here well known", expected: "I'm here — well-known.").correct == 4)
    }
    @Test func bundledSentencesCoverEveryLevelAndSpecialCategories() {
        let items = SpeechLabCatalog.bundled.dictation
        #expect(Set(items.map(\.id)).count == items.count)
        for level in LevelGate.levels { #expect(items.filter { $0.level == level && $0.category == "Sentences" }.count >= 6) }
        for category in ["Numbers", "Dates", "Names", "Spelling"] { #expect(items.contains { $0.category == category }) }
    }
    @Test func resultsSettingsMissesAndDeletionSurviveReopen() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SpeechLab-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        var repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        #expect(try repo.speechLabState() == SpeechLabState())
        let first = SpeechLabAttempt(area: .dictation, itemID: "dict-a1-1", correct: 2, total: 4)
        try repo.recordSpeechLabAttempt(first); try repo.recordSpeechLabAttempt(first)
        try repo.setSpeechLabStrictDictation(true)
        repo.close(); repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        #expect(try repo.speechLabState().attempts.count == 1)
        #expect(try repo.speechLabState().strictDictation)
        #expect(try repo.speechLabState().missedDictation == ["dict-a1-1"])
        try repo.recordSpeechLabAttempt(.init(area: .dictation, itemID: "dict-a1-1", correct: 4, total: 4))
        #expect(try repo.speechLabState().missedDictation.isEmpty)
        #expect(try repo.speechLabState().trend(for: .dictation) == "Accuracy: +50 points from last time")
        try repo.removeSpeechLabAttempt(first.id)
        #expect(try repo.speechLabState().attempts.count == 1)
        #expect(throws: LearnerStorageError.invalidContent) { try repo.recordSpeechLabAttempt(.init(area: .dictation, itemID: "bad", correct: 3, total: 2)) }
        repo.close()
    }
    @Test func failedSaveDoesNotCreateAMissedResult() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SpeechLab-fail-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) { try repo.recordSpeechLabAttempt(.init(area: .dictation, itemID: "x", correct: 0, total: 2)) }
        repo.beforeCommit = nil
        #expect(try repo.speechLabState().attempts.isEmpty)
        repo.close()
    }
}
