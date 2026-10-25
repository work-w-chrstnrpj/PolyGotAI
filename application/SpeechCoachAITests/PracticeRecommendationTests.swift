import Foundation
import Testing
@testable import SpeechCoachAI

struct PracticeRecommendationTests {
    private let calendar = Calendar(identifier: .gregorian)
    private let banned = ["CEFR", "Librarian", "Grammarian", "Journalist", "Business Professional", "Creative Writer"]

    @Test func insufficientEvidenceUsesTheReadyLessonAndNamesNoDiagnosis() {
        let suggestion = PracticeRecommendation.suggest(facts(due: 0), calendar: calendar)
        #expect(suggestion.action == .openLesson)
        #expect(suggestion.evidenceIsInsufficient)
        #expect(suggestion.reason.contains("not enough evidence"))
        #expect(suggestion.reason.contains("not an English-level placement"))
        #expect(suggestion.alternatives.map(\.action) == [.speechLab])
        expectHonest(suggestion.reason)
        expectHonest(suggestion.title)
    }

    @Test func dueReviewsAreTheFallbackAndAMissBeatsThem() {
        let due = PracticeRecommendation.suggest(facts(due: 2), calendar: calendar)
        #expect(due.action == .reviewWords)
        #expect(due.title == "Revisit 2 words")
        #expect(due.evidenceIsInsufficient)
        var missed = facts(due: 2)
        missed.recallMissedAt = day(2)
        let retrieval = PracticeRecommendation.suggest(missed, calendar: calendar)
        #expect(retrieval.action == .reviewWords)
        #expect(retrieval.reason.contains("Again"))
        #expect(!retrieval.evidenceIsInsufficient)
        expectHonest(retrieval.reason)
    }

    @Test func theSameTimeKeepsGrammarAheadOfRetrieval() {
        var facts = facts(due: 1)
        facts.assistedGrammarAt = day(3)
        facts.recallMissedAt = day(3)
        let suggestion = PracticeRecommendation.suggest(facts, calendar: calendar)
        #expect(suggestion.title == "Practice that grammar again")
        #expect(suggestion.action == .openLesson)
    }

    @Test func reportedFollowUpAndClarityStayOnAvailablePractice() {
        let followUp = PracticeRecommendation.suggest(facts(due: 0), reported: [DifficultyObservation(difficulty: .followUp, at: day(4))], calendar: calendar)
        #expect(followUp.action == .speechLab)
        #expect(followUp.reason.contains("practice is unavailable"))
        expectHonest(followUp.reason)
        let clarity = PracticeRecommendation.suggest(facts(due: 0), reported: [DifficultyObservation(difficulty: .clarity, at: day(4))], calendar: calendar)
        #expect(clarity.action == .openLesson)
        #expect(clarity.reason.contains("has not been scored"))
        expectHonest(clarity.reason)
    }

    @Test func todaysChoiceWinsAndYesterdaysChoiceDoesNot() {
        var today = facts(due: 0)
        today.savedChoice = DailyPracticeChoice(day: PracticeRecommendation.localDay(day(5), calendar: calendar), action: .speechLab)
        let chosen = PracticeRecommendation.suggest(today, calendar: calendar)
        #expect(chosen.chosenByLearner)
        #expect(chosen.action == .speechLab)
        #expect(chosen.reason == "You chose this for today.")
        #expect(chosen.groundedAction == .openLesson)
        #expect(chosen.groundedReason.contains("not enough evidence"))
        #expect(chosen.alternatives.contains { $0.action == .openLesson })
        var yesterday = facts(due: 0)
        yesterday.savedChoice = DailyPracticeChoice(day: PracticeRecommendation.localDay(day(4), calendar: calendar), action: .speechLab)
        #expect(!PracticeRecommendation.suggest(yesterday, calendar: calendar).chosenByLearner)
    }

    @Test func anEmptyReviewChoiceIsIgnoredAndOrganizationIsNotAFollowUp() {
        var facts = facts(due: 0)
        facts.savedChoice = DailyPracticeChoice(day: PracticeRecommendation.localDay(day(5), calendar: calendar), action: .reviewWords)
        #expect(PracticeRecommendation.suggest(facts, calendar: calendar).action == .openLesson)
        let attempt = sampleAttempt(id: UUID(), promptID: "g", created: day(1))
        var withFeedback = attempt
        withFeedback.text = ComponentLifecycle(state: .saved)
        withFeedback.feedback = [sampleFeedback(category: .organization, at: day(1))]
        #expect(PracticeRecommendation.feedbackDates([withFeedback]) == (nil, nil))
        withFeedback.feedback = [sampleFeedback(category: .grammar, at: day(2))]
        #expect(PracticeRecommendation.feedbackDates([withFeedback]).grammar == day(2))
    }

    @Test func aSavedChoiceSurvivesRestartAndResetClearsIt() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-T051-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let now = day(8)
        var repo = try LearnerRepository(root: root, now: { now }, protectedDataAvailable: { true })
        let install = sampleInstall()
        #expect(try repo.practiceSuggestion(install: install, calendar: calendar).action == .openLesson)
        try repo.saveDailyChoice(.speechLab)
        try repo.saveConfidenceNote("   Steady   ")
        repo.close()
        repo = try LearnerRepository(root: root, now: { now }, protectedDataAvailable: { true })
        let chosen = try repo.practiceSuggestion(install: install, calendar: calendar)
        #expect(chosen.chosenByLearner)
        #expect(chosen.action == .speechLab)
        #expect(try repo.learningBoard(install: install, calendar: calendar).confidence.note == "Steady")
        try repo.deleteAllLearningData()
        let reset = try repo.learningBoard(install: install, calendar: calendar)
        #expect(!reset.suggestion.chosenByLearner)
        #expect(reset.confidence.note == nil)
        repo.close()
    }

    @Test func failedChoiceAndConfidenceWritesPreserveEarlierValues() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("daily-save-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, now: { day(8) }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        defer { repo.close() }
        try repo.saveDailyChoice(.speechLab)
        try repo.saveConfidenceNote("Earlier")
        let storage = LearnerStorageController(repository: repo)
        storage.loadConfidenceDraft(saved: "Earlier", epoch: try repo.learningDataEpoch())
        storage.editConfidenceDraft("New note")
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) { try repo.saveDailyChoice(.openLesson) }
        #expect(throws: LearnerStorageError.storageFailure) { try repo.clearDailyChoice() }
        storage.saveConfidenceDraft()
        #expect(storage.confidenceDraft?.text == "New note")
        #expect(storage.confidenceDraft?.hasSaveFailure == true)
        storage.loadConfidenceDraft(saved: "Earlier", epoch: try repo.learningDataEpoch())
        #expect(storage.confidenceDraft?.text == "New note")
        let unchanged = try repo.learningBoard(install: sampleInstall(), calendar: calendar)
        #expect(unchanged.suggestion.action == .speechLab)
        #expect(unchanged.confidence.note == "Earlier")
        repo.beforeCommit = nil
        storage.saveConfidenceDraft()
        #expect(storage.confidenceDraft?.hasSaveFailure == false)
        #expect(storage.confidenceDraft?.isDirty == false)
        #expect(try repo.learningBoard(install: sampleInstall(), calendar: calendar).confidence.note == "New note")
        storage.editConfidenceDraft("")
        storage.saveConfidenceDraft()
        storage.loadConfidenceDraft(saved: nil, epoch: try repo.learningDataEpoch())
        #expect(storage.confidenceDraft?.text == "")
        #expect(try repo.learningBoard(install: sampleInstall(), calendar: calendar).confidence.note == nil)
        storage.editConfidenceDraft("Do not restore after reset")
        let oldEpoch = try repo.learningDataEpoch()
        try repo.deleteAllLearningData()
        #expect(throws: LearnerStorageError.invalidState) { try repo.saveConfidenceNote("stale", expectedEpoch: oldEpoch) }
        storage.saveConfidenceDraft()
        #expect(storage.confidenceDraft == nil)
        #expect(try repo.learningBoard(install: sampleInstall(), calendar: calendar).confidence.note == nil)
    }

    @Test func localMidnightAndTimezoneRecomputeTheSavedChoice() {
        var local = Calendar(identifier: .gregorian)
        local.timeZone = TimeZone(secondsFromGMT: 8 * 3600)!
        let before = Date(timeIntervalSince1970: 1_792_684_799) // Fixed instant; derive the day boundary below.
        let start = local.startOfDay(for: before)
        let end = local.date(byAdding: .day, value: 1, to: start)!
        var input = facts(due: 1)
        input.now = end.addingTimeInterval(-1)
        input.savedChoice = DailyPracticeChoice(day: PracticeRecommendation.localDay(input.now, calendar: local), action: .speechLab)
        #expect(PracticeRecommendation.suggest(input, calendar: local).action == .speechLab)
        input.now = end
        #expect(PracticeRecommendation.suggest(input, calendar: local).action == .reviewWords)
        var previousZone = local
        previousZone.timeZone = TimeZone(secondsFromGMT: -8 * 3600)!
        #expect(PracticeRecommendation.suggest(input, calendar: previousZone).action == .speechLab)
    }

    @Test func supportedDifficultiesMapToInstalledFocusAndDueRetrievalStaysInReview() throws {
        var input = facts(due: 0)
        input.focusLesson = input.lesson
        for difficulty in ObservedDifficulty.allCases {
            let suggestion = PracticeRecommendation.suggest(input, reported: [.init(difficulty: difficulty, at: day(4))])
            #expect(suggestion.focus == difficulty)
            #expect(suggestion.action == .openLesson)
            #expect(suggestion.reason.contains("You reported"))
            #expect(!suggestion.alternatives.isEmpty)
        }
        input.dueReviewCount = 2
        let due = PracticeRecommendation.suggest(input, reported: [.init(difficulty: .retrieval, at: day(4))])
        #expect(due.action == .reviewWords)
        #expect(due.focus == nil)
        let legacy = try JSONDecoder().decode(DailyPracticeChoice.self, from: Data(#"{"day":"2026-10-25","action":"speechLab"}"#.utf8))
        #expect(legacy.difficulty == nil)
    }

    @Test func feedbackReasonsDoNotInventRecallRatingsOrAssistance() {
        var input = facts(due: 1)
        input.vocabularyFeedbackAt = day(4)
        let vocabulary = PracticeRecommendation.suggest(input)
        #expect(vocabulary.reason.contains("coaching feedback"))
        #expect(!vocabulary.reason.contains("Again"))
        input.grammarFeedbackAt = day(5)
        let grammar = PracticeRecommendation.suggest(input)
        #expect(grammar.reason.contains("coaching feedback"))
        #expect(!grammar.reason.contains("used an example"))
    }

    @Test func allFourFocusChoicesPersistAndExpireWithoutChangingGroundedReason() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        var now = day(8)
        let repository = try LearnerRepository(root: root, now: { now }, protectedDataAvailable: { true })
        defer { repository.close() }
        let install = CurriculumCatalogLoader.bundled
        #expect(PracticeRecommendation.focusLesson(journeys: [], install: install) != nil)
        let grounded = try repository.practiceSuggestion(install: install)
        for difficulty in ObservedDifficulty.allCases {
            try repository.saveDailyChoice(.openLesson, difficulty: difficulty)
            let board = try repository.learningBoard(install: install)
            #expect(board.suggestion.focus == difficulty)
            #expect(board.suggestion.chosenByLearner)
            #expect(board.suggestion.groundedReason == grounded.reason)
            #expect(board.suggestion.reason.contains("not had qualified educator review"))
            #expect(board.suggestion.lessonID == "intro-01")
        }
        repository.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) { try repository.saveDailyChoice(.openLesson, difficulty: .grammar) }
        #expect(try repository.practiceSuggestion(install: install).focus == .clarity)
        repository.beforeCommit = nil
        now = day(10)
        #expect(try repository.practiceSuggestion(install: install).focus == nil)
        let oldEpoch = try repository.learningDataEpoch()
        try repository.deleteAllLearningData()
        #expect(throws: LearnerStorageError.invalidState) { try repository.saveDailyChoice(.openLesson, difficulty: .grammar, expectedEpoch: oldEpoch) }
        #expect(throws: LearnerStorageError.invalidState) { try repository.clearDailyChoice(expectedEpoch: oldEpoch) }
        #expect(try repository.practiceSuggestion(install: install).focus == nil)
    }

    @Test func unavailableFocusDoesNotSilentlyBecomeAnOrdinaryLessonChoice() {
        var input = facts(due: 0)
        input.goal = .speechLab
        input.savedChoice = DailyPracticeChoice(day: PracticeRecommendation.localDay(input.now), action: .openLesson, difficulty: .grammar)
        let fallback = PracticeRecommendation.suggest(input)
        #expect(fallback.action == .speechLab)
        #expect(!fallback.chosenByLearner)
        #expect(fallback.reason.contains("chosen focus is unavailable"))
        input.focusLesson = input.lesson
        #expect(PracticeRecommendation.suggest(input).focus == .grammar)
    }

    @Test func lessonOffersRespectUnavailableSavedVersionsAndCompletedCourses() throws {
        let intro = sampleInstall().lessons[0]
        var next = intro
        next.id = "family-01"; next.objectiveId = "FAMILY-01"; next.title = "Family"
        var journey = try LessonSession.begin(lesson: intro, presenter: "teacher", now: day(1)).journey
        journey.contentVersion = "old"
        let blocked = PracticeRecommendation.selectLesson(journeys: [journey], lessons: [intro, next])
        #expect(blocked.lesson?.id == next.id)
        var archive = intro; archive.contentVersion = "old"; archive.title = "Saved Introductions"
        let resumed = PracticeRecommendation.selectLesson(journeys: [journey], lessons: [intro, next], archivedLessons: [archive])
        #expect(resumed.resuming)
        #expect(resumed.lesson?.title == archive.title)
        journey.contentVersion = intro.contentVersion; journey.completedAt = day(2)
        #expect(PracticeRecommendation.selectLesson(journeys: [journey], lessons: [intro, next]).lesson?.id == next.id)
        #expect(PracticeRecommendation.selectLesson(journeys: [journey], lessons: [intro]).lesson == nil)
        #expect(PracticeRecommendation.focusLesson(journeys: [], install: sampleInstall()) == nil)
    }

    private func facts(due: Int) -> PracticeFacts {
        PracticeFacts(now: day(5), dueReviewCount: due, lesson: LessonOffer(id: "intro-01", title: "Introductions"), resuming: false)
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

struct LearningEvidenceTests {
    @Test func recognitionRecallUseRetentionAndTransferStaySeparate() {
        let recall = VocabularyRecallAttempt(
            id: UUID(), itemId: "item", senseId: "sense", lemma: "hello", rating: .good, revealed: true,
            typedAttempt: nil, modality: "text", createdAt: Date(timeIntervalSince1970: 10), assistance: "hint")
        let credit = SenseCreditEvent(id: UUID(), itemId: "item", senseId: "sense", task: ReviewTask.productiveUse.rawValue, cardKind: ReviewCardKind.recognition.rawValue, rating: nil, createdAt: Date(timeIntervalSince1970: 20))
        let rows = LearningEvidence.rows(recalls: [recall], credits: [credit], transferCount: 0)
        #expect(rows.first { $0.kind == .recognition }?.available == true)
        #expect(rows.first { $0.kind == .recognition }?.summary.contains("with a hint") == true)
        #expect(rows.first { $0.kind == .recall }?.summary.contains("Recognition ratings stay on their own row") == true)
        #expect(rows.first { $0.kind == .use }?.available == true)
        #expect(rows.first { $0.kind == .retention }?.available == false)
        #expect(rows.first { $0.kind == .transfer }?.available == false)
        #expect(rows.first { $0.kind == .recognition }?.summary.contains("not a level") == true)
        #expect(rows.first { $0.kind == .use }?.summary.contains("not a level") == true)
    }

    @Test func fourFormatsLinkTheMatchingTakesAndRejectIncompatibleOnes() {
        let baseline = candidate(.baseline, id: 1, prompt: "b", support: .independent, replay: true)
        let repeated = candidate(.repeatedBaseline, id: 2, prompt: "b", support: .independent, replay: true)
        let practiceEarly = candidate(.practice, id: 3, prompt: "p1", support: .independent, replay: true)
        let practiceLate = candidate(.practice, id: 4, prompt: "p2", support: .independent, replay: true)
        let transfer = candidate(.reservedTransfer, id: 5, prompt: "x", support: .independent, replay: true)
        let baselineAgain = candidate(.baseline, id: 6, prompt: "b", support: .independent, replay: true)
        let links = LearningEvidence.links([baseline, repeated, practiceEarly, practiceLate, transfer, baselineAgain])
        #expect(links.map(\.format) == ComparisonFormat.allCases)
        #expect(links.first { $0.format == .baseline }?.recentID == baselineAgain.attemptID)
        #expect(links.first { $0.format == .repeatedBaseline }?.earlierID == baseline.attemptID)
        #expect(links.first { $0.format == .repeatedBaseline }?.recentID == repeated.attemptID)
        #expect(links.first { $0.format == .practice }?.earlierID == practiceEarly.attemptID)
        #expect(links.first { $0.format == .reservedTransfer }?.recentID == transfer.attemptID)
        #expect(links.allSatisfy { $0.comparable })
        #expect(links.allSatisfy { $0.limitation.contains("No proficiency change is shown.") })

        var mismatched = repeated
        mismatched.rubricVersion = "rubric-2"
        let rubric = LearningEvidence.links([baseline, mismatched])
        #expect(rubric.first?.comparable == false)
        #expect(rubric.first?.limitation.contains("rubric") == true)

        var assisted = repeated
        assisted.support = .assisted
        #expect(LearningEvidence.links([baseline, assisted]).first?.limitation.contains("support") == true)

        var text = repeated
        text.modality = .text
        #expect(LearningEvidence.links([baseline, text]).first?.limitation.contains("Text is not speech.") == true)

        var deleted = repeated
        deleted.audioReplayEnabled = false
        let missing = LearningEvidence.links([baseline, deleted]).first
        #expect(missing?.recentReplay == false)
        #expect(missing?.limitation.contains("cannot be replayed") == true)
        #expect(missing?.comparable == false)

        var removed = repeated
        removed.excluded = true
        #expect(LearningEvidence.links([baseline, removed]).isEmpty)
    }

    @Test func selfReviewIsLinkedWithoutAnImprovementClaim() throws {
        let earlier = candidate(.baseline, id: 1, prompt: "b", support: .selfReview, replay: true)
        let recent = candidate(.repeatedBaseline, id: 2, prompt: "b", support: .selfReview, replay: false)
        let link = try #require(LearningEvidence.links([earlier, recent]).first)
        #expect(!link.comparable)
        #expect(link.limitation.contains("no improvement"))
        #expect(!link.recentReplay)
    }

    @Test func aQuietWeekAndADeletedRecordingStayHonest() {
        let interval = DateInterval(start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 86_400))
        let empty = LearningEvidence.week([], interval: interval)
        #expect(empty.narrative.contains("quiet week"))
        #expect(!empty.narrative.contains("you improved"))
        let spoken = WeekActivity(createdAt: Date(timeIntervalSince1970: 10), kind: .speaking, savedSpeakingMilliseconds: 90_000, audioMissing: false)
        let deleted = WeekActivity(createdAt: Date(timeIntervalSince1970: 20), kind: .speaking, savedSpeakingMilliseconds: nil, audioMissing: true)
        let outside = WeekActivity(createdAt: Date(timeIntervalSince1970: 90_000), kind: .recall, savedSpeakingMilliseconds: nil, audioMissing: false)
        let full = LearningEvidence.week([spoken, deleted, outside], interval: interval)
        #expect(full.speakingCompletions == 2)
        #expect(full.savedSpeakingMilliseconds == 90_000)
        #expect(full.missingAudioCompletions == 1)
        #expect(full.recallRatings == 0)
        #expect(full.narrative.contains("not an improvement score"))
        let remaining = LearningEvidence.week([deleted], interval: interval)
        #expect(remaining.speakingCompletions == 1)
        #expect(remaining.savedSpeakingMilliseconds == 0)
    }

    @Test func confidenceIsStoredOnlyWhenTheLearnerWritesIt() {
        #expect(ConfidenceStatement.normalize("  ") == nil)
        #expect(ConfidenceStatement.normalize(String(repeating: "a", count: 300))?.unicodeScalars.count == 280)
        #expect(ConfidenceStatement(note: nil).summary.contains("does not decide"))
    }

    @Test func weekBoundariesDoNotCountTheNextWeekTwice() {
        let start = Date(timeIntervalSince1970: 100)
        let interval = DateInterval(start: start, duration: 100)
        let items = [99.0, 100.0, 199.0, 200.0].map {
            WeekActivity(createdAt: Date(timeIntervalSince1970: $0), kind: .recall, savedSpeakingMilliseconds: nil, audioMissing: false)
        }
        #expect(LearningEvidence.week(items, interval: interval).recallRatings == 2)
        #expect(LearningEvidence.week(items, interval: DateInterval(start: interval.end, duration: 100)).recallRatings == 1)
    }

    @Test func missingOrDifferentAssessmentIdentityNeverCompares() throws {
        var earlier = candidate(.baseline, id: 1, prompt: "b", support: .independent, replay: true)
        var recent = candidate(.repeatedBaseline, id: 2, prompt: "b", support: .independent, replay: true)
        earlier.rubricVersion = nil; recent.rubricVersion = nil
        #expect(try #require(LearningEvidence.links([earlier, recent]).first).comparable == false)
        earlier.rubricVersion = "r1"; recent.rubricVersion = "r1"
        earlier.provider = " "; recent.provider = nil
        #expect(try #require(LearningEvidence.links([earlier, recent]).first).comparable == false)
        earlier.provider = "one"; recent.provider = "two"
        #expect(try #require(LearningEvidence.links([earlier, recent]).first).limitation.contains("providers differ"))
    }

    @Test func weeklySpeakingUsesCompletionTimeAndHiddenRecallIsNotARating() {
        var attempt = sampleAttempt(id: UUID(), promptID: "b", created: Date(timeIntervalSince1970: 10))
        attempt.didCompleteSelfReview = true
        attempt.finishedAt = Date(timeIntervalSince1970: 110)
        let hidden = VocabularyRecallAttempt(id: UUID(), itemId: "i", senseId: "s", lemma: "hello", rating: .good,
            revealed: false, typedAttempt: nil, modality: "text", createdAt: Date(timeIntervalSince1970: 120), assistance: "none")
        let activities = LearningEvidence.activities(attempts: [attempt], journeys: [], recalls: [hidden])
        let before = LearningEvidence.week(activities, interval: DateInterval(start: .init(timeIntervalSince1970: 0), duration: 100))
        let after = LearningEvidence.week(activities, interval: DateInterval(start: .init(timeIntervalSince1970: 100), duration: 100))
        #expect(before.speakingCompletions == 0)
        #expect(after.speakingCompletions == 1)
        #expect(after.recallRatings == 0)
    }

    private func candidate(_ format: ComparisonFormat, id: Int, prompt: String, support: ComparisonSupport, replay: Bool) -> ComparisonCandidate {
        ComparisonCandidate(
            attemptID: UUID(),
            createdAt: Date(timeIntervalSince1970: TimeInterval(id * 10)), objectiveID: "INTRO-01",
            promptID: prompt, promptVersion: "1", format: format, rubricVersion: "rubric-1", provider: "none",
            support: support, modality: .speaking, audioReplayEnabled: replay, excluded: false)
    }
}

private func sampleAttempt(id: UUID, promptID: String, created: Date) -> AttemptSnapshot {
    AttemptSnapshot(
        id: id, epoch: UUID(),
        prompt: PromptSnapshot(id: promptID, version: "1", objectiveID: "INTRO-01", text: "Hello", isPrivate: false, selectedLevel: "A1"),
        createdAt: created, recoveryDeadline: created.addingTimeInterval(3600))
}

private func sampleFeedback(category: FeedbackSnapshot.Improvement.Category, at: Date) -> FeedbackSnapshot {
    FeedbackSnapshot(
        id: UUID(), requestID: UUID(), transcriptID: UUID(), transcriptRevision: 1, schemaVersion: 1,
        rubricVersion: "rubric-1", provider: "fixture", model: "fixture", region: "none", createdAt: at,
        summary: "A note", strengths: [], improvements: [FeedbackSnapshot.Improvement(
            category: category, evidenceQuote: "hello", explanation: "A grammar note", retryPrompt: "Try again")],
        limitations: [])
}
