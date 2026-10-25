import Foundation
import Testing
@testable import SpeechCoachAI

struct DailyProgressDeliveryTests {
    private let calendar = Calendar(identifier: .gregorian)
    private let banned = ["CEFR", "Librarian", "Grammarian", "Journalist", "Business Professional", "Creative Writer", "gold", "XP"]

    @Test func noGoalKeepsTheReadyLesson() {
        let suggestion = PracticeRecommendation.suggest(facts(due: 0), calendar: calendar)
        #expect(suggestion.action == .openLesson)
        #expect(suggestion.evidenceIsInsufficient)
        #expect(!suggestion.reason.localizedCaseInsensitiveContains("prefer"))
        expectHonest(suggestion.reason)
    }

    @Test func preferenceLabelsStayPlain() {
        #expect(SuggestionAction.noPreferenceTitle == "No preference")
        #expect(SuggestionAction.allCases.map(\.preferenceTitle) == ["Review due words", "Open a lesson", "Speech Lab"])
        expectHonest(PracticeRecommendation.preferenceExplanation)
        #expect(PracticeRecommendation.preferenceExplanation.contains("not a daily target"))
        #expect(PracticeRecommendation.preferenceExplanation.contains("choice for today still comes first"))
    }

    @Test func speechLabPreferenceBeatsAReadyLessonWhenNothingIsDue() {
        let suggestion = PracticeRecommendation.suggest(facts(due: 0, goal: .speechLab), calendar: calendar)
        #expect(suggestion.action == .speechLab)
        #expect(suggestion.title == "Record in Speech Lab")
        #expect(!suggestion.chosenByLearner)
        #expect(suggestion.evidenceIsInsufficient)
        #expect(suggestion.reason.contains("prefer Speech Lab"))
        #expect(suggestion.reason.contains("not enough evidence"))
        #expect(suggestion.reason.contains("not an English-level placement"))
        #expect(suggestion.alternatives.contains { $0.action == .openLesson })
        expectHonest(suggestion.reason)
    }

    @Test func lessonPreferenceUsesTheReadyLesson() {
        var facts = facts(due: 0, goal: .openLesson)
        facts.resuming = true
        let suggestion = PracticeRecommendation.suggest(facts, calendar: calendar)
        #expect(suggestion.action == .openLesson)
        #expect(suggestion.title == "Continue Introductions")
        #expect(suggestion.lessonID == "intro-01")
        #expect(suggestion.reason.contains("prefer the lesson"))
        expectHonest(suggestion.reason)
    }

    @Test func reviewPreferenceExplainsWhenNothingIsDue() {
        let suggestion = PracticeRecommendation.suggest(facts(due: 0, goal: .reviewWords), calendar: calendar)
        #expect(suggestion.action == .openLesson)
        #expect(suggestion.reason.contains("nothing is due"))
        #expect(suggestion.reason.contains("cannot be used"))
        #expect(suggestion.reason.contains("Introductions is ready."))
        #expect(!suggestion.alternatives.contains { $0.action == .reviewWords })
        expectHonest(suggestion.reason)
    }

    @Test func lessonPreferenceExplainsWhenNoLessonIsReady() {
        let suggestion = PracticeRecommendation.suggest(facts(due: 0, lesson: nil, goal: .openLesson), calendar: calendar)
        #expect(suggestion.action == .speechLab)
        #expect(suggestion.title == "Record an introduction")
        #expect(suggestion.reason.contains("no lesson is ready"))
        #expect(suggestion.reason.contains("cannot be used"))
        #expect(suggestion.reason.contains("No lesson is ready."))
        expectHonest(suggestion.reason)
    }

    @Test func dueReviewsStayAheadOfASpeechLabPreference() {
        let suggestion = PracticeRecommendation.suggest(facts(due: 2, goal: .speechLab), calendar: calendar)
        #expect(suggestion.action == .reviewWords)
        #expect(suggestion.title == "Revisit 2 words")
        #expect(suggestion.evidenceIsInsufficient)
        #expect(!suggestion.reason.localizedCaseInsensitiveContains("prefer"))
        #expect(suggestion.alternatives.contains { $0.action == .speechLab && $0.detail == "Your practice preference" })
    }

    @Test func aNamedDifficultyStaysAheadOfThePreference() {
        var tied = facts(due: 1, goal: .speechLab)
        tied.assistedGrammarAt = day(3)
        tied.recallMissedAt = day(3)
        let grammar = PracticeRecommendation.suggest(tied, calendar: calendar)
        #expect(grammar.action == .openLesson)
        #expect(grammar.title == "Practice that grammar again")
        #expect(!grammar.evidenceIsInsufficient)

        var missed = facts(due: 2, goal: .openLesson)
        missed.recallMissedAt = day(2)
        let retrieval = PracticeRecommendation.suggest(missed, calendar: calendar)
        #expect(retrieval.action == .reviewWords)
        #expect(retrieval.reason.contains("Again"))
        #expect(!retrieval.evidenceIsInsufficient)

        let followUp = PracticeRecommendation.suggest(
            facts(due: 0, goal: .openLesson),
            reported: [DifficultyObservation(difficulty: .followUp, at: day(4))],
            calendar: calendar)
        #expect(followUp.action == .speechLab)
        #expect(followUp.reason.contains("practice is unavailable"))
        #expect(followUp.alternatives.contains { $0.action == .openLesson && $0.detail == "Your practice preference" })
        #expect(!followUp.reason.localizedCaseInsensitiveContains("prefer"))

        let clarity = PracticeRecommendation.suggest(
            facts(due: 0, goal: .speechLab),
            reported: [DifficultyObservation(difficulty: .clarity, at: day(4))],
            calendar: calendar)
        #expect(clarity.action == .openLesson)
        #expect(clarity.reason.contains("has not been scored"))
        #expect(clarity.alternatives.contains { $0.action == .speechLab && $0.detail == "Your practice preference" })
    }

    @Test func missingLessonDoesNotInventATrainer() {
        let clarity = facts(due: 0, lesson: nil)
        let spoken = PracticeRecommendation.suggest(clarity, reported: [DifficultyObservation(difficulty: .clarity, at: day(4))], calendar: calendar)
        #expect(spoken.action == .speechLab)
        #expect(spoken.reason.contains("No lesson is ready."))
        #expect(spoken.reason.contains("has not been scored"))
        expectHonest(spoken.reason)

        var retrieval = facts(due: 0, lesson: nil)
        retrieval.recallMissedAt = day(4)
        let missed = PracticeRecommendation.suggest(retrieval, calendar: calendar)
        #expect(missed.action == .speechLab)
        #expect(missed.reason.contains("Again"))
        #expect(missed.reason.contains("No lesson is ready."))
        expectHonest(missed.reason)
    }

    @Test func todaysChoiceBeatsThePreferenceAndYesterdaysChoiceDoesNot() {
        var today = facts(due: 0, goal: .speechLab)
        today.savedChoice = DailyPracticeChoice(day: PracticeRecommendation.localDay(day(5), calendar: calendar), action: .openLesson)
        let chosen = PracticeRecommendation.suggest(today, calendar: calendar)
        #expect(chosen.chosenByLearner)
        #expect(chosen.action == .openLesson)
        #expect(chosen.reason == "You chose this for today.")
        #expect(chosen.groundedAction == .speechLab)
        #expect(chosen.groundedReason.contains("prefer Speech Lab"))

        var yesterday = facts(due: 0, goal: .speechLab)
        yesterday.savedChoice = DailyPracticeChoice(day: PracticeRecommendation.localDay(day(4), calendar: calendar), action: .openLesson)
        let expired = PracticeRecommendation.suggest(yesterday, calendar: calendar)
        #expect(!expired.chosenByLearner)
        #expect(expired.action == .speechLab)

        var ignored = facts(due: 0, goal: .speechLab)
        ignored.savedChoice = DailyPracticeChoice(day: PracticeRecommendation.localDay(day(5), calendar: calendar), action: .reviewWords)
        let unused = PracticeRecommendation.suggest(ignored, calendar: calendar)
        #expect(!unused.chosenByLearner)
        #expect(unused.action == .speechLab)
        #expect(!unused.alternatives.contains { $0.action == .reviewWords })
    }

    @Test func unsavedPreferenceSurvivesAFailedSaveAndAResetDropsIt() {
        let epoch = UUID()
        var draft = PracticeGoalDraft(epoch: epoch, selection: .speechLab, saved: nil, hasSaveFailure: true)
        let kept = draft.refreshed(saved: nil, epoch: epoch)
        #expect(kept.selection == .speechLab)
        #expect(kept.hasSaveFailure)
        #expect(kept.isDirty)
        draft.recordSaveSuccess()
        #expect(draft.saved == .speechLab)
        #expect(!draft.isDirty)
        #expect(!draft.hasSaveFailure)
        draft.selection = .openLesson
        draft.recordSaveFailure()
        #expect(draft.hasSaveFailure)
        #expect(draft.saved == .speechLab)
        let reset = draft.refreshed(saved: nil, epoch: UUID())
        #expect(reset.selection == nil)
        #expect(reset.saved == nil)
        #expect(!reset.hasSaveFailure)
        let adopted = PracticeGoalDraft(epoch: epoch, selection: .speechLab, saved: .speechLab)
            .refreshed(saved: .openLesson, epoch: epoch)
        #expect(adopted.selection == .openLesson)
        #expect(!adopted.isDirty)
    }

    @Test func sharedDraftKeepsFailedSaveAndClearAcrossReloadsUntilRetry() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-D004-draft-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { repo.close() }
        let storage = LearnerStorageController(repository: repo)
        storage.loadPracticeGoalDraft()
        storage.editPracticeGoalDraft(.speechLab)
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(!storage.savePracticeGoalDraft())
        // A newly created Today view reloads this same controller after sidebar navigation.
        storage.loadPracticeGoalDraft()
        #expect(storage.practiceGoalDraft?.selection == .speechLab)
        #expect(storage.practiceGoalDraft?.saved == nil)
        #expect(storage.practiceGoalDraft?.hasSaveFailure == true)
        #expect(storage.practiceGoalMessage != nil)
        #expect(try repo.practiceGoal() == nil)
        repo.beforeCommit = nil
        #expect(storage.savePracticeGoalDraft())
        #expect(try repo.practiceGoal() == .speechLab)
        #expect(storage.practiceGoalMessage == nil)
        storage.editPracticeGoalDraft(nil)
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(!storage.savePracticeGoalDraft())
        storage.loadPracticeGoalDraft()
        #expect(storage.practiceGoalDraft?.selection == nil)
        #expect(storage.practiceGoalDraft?.saved == .speechLab)
        #expect(storage.practiceGoalDraft?.hasSaveFailure == true)
        repo.beforeCommit = nil
        #expect(storage.savePracticeGoalDraft())
        #expect(try repo.practiceGoal() == nil)
        #expect(storage.practiceGoalDraft?.isDirty == false)
        #expect(storage.practiceGoalMessage == nil)
    }

    @Test(arguments: [false, true])
    func resetDropsSharedDraftBeforeReloadOrRetry(reloadFirst: Bool) throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-D004-draft-reset-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { repo.close() }
        let storage = LearnerStorageController(repository: repo)
        storage.loadPracticeGoalDraft()
        let epoch = try repo.learningDataEpoch()
        storage.editPracticeGoalDraft(.speechLab)
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(!storage.savePracticeGoalDraft())
        repo.beforeCommit = nil
        try repo.deleteAllLearningData()
        if reloadFirst {
            storage.loadPracticeGoalDraft()
            #expect(storage.practiceGoalMessage == nil)
        } else {
            #expect(!storage.savePracticeGoalDraft())
            #expect(storage.practiceGoalMessage?.contains("reset") == true)
        }
        #expect(storage.practiceGoalDraft?.epoch != epoch)
        #expect(storage.practiceGoalDraft?.selection == nil)
        #expect(storage.practiceGoalDraft?.hasSaveFailure == false)
        #expect(try repo.practiceGoal() == nil)
    }

    @Test func practiceGoalDefaultsToNilAndSurvivesRestart() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-D004-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        var repo = try LearnerRepository(root: root, now: { day(8) }, protectedDataAvailable: { true })
        #expect(try repo.practiceGoal() == nil)
        let epoch = try repo.learningDataEpoch()
        try repo.savePracticeGoal(.speechLab, expectedEpoch: epoch)
        repo.close()
        repo = try LearnerRepository(root: root, now: { day(8) }, protectedDataAvailable: { true })
        #expect(try repo.practiceGoal() == .speechLab)
        #expect(try repo.learningDataEpoch() == epoch)
        try repo.savePracticeGoal(nil, expectedEpoch: epoch)
        #expect(try repo.practiceGoal() == nil)
        repo.close()
    }

    @Test func failedGoalWriteKeepsTheEarlierPreference() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-D004-save-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, now: { day(8) }, protectedDataAvailable: { true })
        defer { repo.close() }
        try repo.savePracticeGoal(.speechLab)
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) {
            try repo.savePracticeGoal(.openLesson, expectedEpoch: try repo.learningDataEpoch())
        }
        #expect(try repo.practiceGoal() == .speechLab)
    }

    @Test func deleteAllClearsTheGoalAndAStaleEpochCannotRestoreIt() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-D004-reset-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, now: { day(8) }, protectedDataAvailable: { true })
        defer { repo.close() }
        try repo.savePracticeGoal(.openLesson)
        let epoch = try repo.learningDataEpoch()
        try repo.deleteAllLearningData()
        #expect(try repo.practiceGoal() == nil)
        #expect(throws: LearnerStorageError.invalidState) {
            try repo.savePracticeGoal(.speechLab, expectedEpoch: epoch)
        }
        #expect(try repo.practiceGoal() == nil)
        try repo.savePracticeGoal(.speechLab)
        #expect(try repo.practiceGoal() == .speechLab)
    }

    @Test func learningBoardAppliesTheSavedPracticeGoal() throws {
        // Passes only after LearnerRepository.learningBoard supplies goal: stored.practiceGoal.
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-D004-board-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, now: { day(8) }, protectedDataAvailable: { true })
        defer { repo.close() }
        let install = sampleInstall()
        #expect(try repo.practiceSuggestion(install: install, calendar: calendar).action == .openLesson)
        try repo.savePracticeGoal(.speechLab)
        let suggestion = try repo.practiceSuggestion(install: install, calendar: calendar)
        #expect(suggestion.action == .speechLab)
        #expect(suggestion.reason.contains("prefer Speech Lab"))
        #expect(!suggestion.chosenByLearner)
    }

    private func facts(due: Int, lesson: LessonOffer? = LessonOffer(id: "intro-01", title: "Introductions"), goal: SuggestionAction? = nil) -> PracticeFacts {
        PracticeFacts(now: day(5), dueReviewCount: due, lesson: lesson, resuming: false, goal: goal)
    }

    private func day(_ number: Int) -> Date { Date(timeIntervalSince1970: TimeInterval(number * 86_400)) }

    private func expectHonest(_ text: String) {
        for word in banned { #expect(!text.localizedCaseInsensitiveContains(word)) }
    }

    private func sampleInstall() -> CurriculumInstall {
        CurriculumInstall(lessons: [ResolvedLesson(
            id: "intro-01", level: "A1", title: "Introductions", objectiveId: "INTRO-01", contentVersion: "1",
            availability: .ready, practiceActivities: [])])
    }
}
