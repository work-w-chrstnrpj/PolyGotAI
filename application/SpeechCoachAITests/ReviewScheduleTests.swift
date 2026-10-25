import Foundation
import Testing
import SwiftData
@testable import SpeechCoachAI

struct ReviewScheduleTests {
    @Test func firstRatingsMatchThePublishedFSRS6Examples() throws {
        let now = utc(year: 2022, month: 12, day: 29, hour: 12, minute: 30)
        let again = try schedule(.again, now)
        let hard = try schedule(.hard, now)
        let good = try schedule(.good, now)
        let easy = try schedule(.easy, now)

        #expect(again.stability == 0.212)
        #expect(hard.stability == 1.2931)
        #expect(good.stability == 2.3065)
        #expect(easy.stability == 8.2956)
        #expect(abs(again.difficulty - 6.4133) < 0.000001)
        #expect(abs(hard.difficulty - 5.11217071) < 0.000001)
        #expect(abs(good.difficulty - 2.11810397) < 0.000001)
        #expect(easy.difficulty == 1)
        #expect(again.scheduledDays == 0)
        #expect(hard.scheduledDays == 0)
        #expect(good.scheduledDays == 0)
        #expect(easy.scheduledDays == 8)
        #expect(again.phase == "learning")
        #expect(hard.phase == "learning")
        #expect(good.phase == "learning")
        #expect(easy.phase == "review")
        #expect(again.due.timeIntervalSince(now) == 60)
        #expect(hard.due.timeIntervalSince(now) == 6 * 60)
        #expect(good.due.timeIntervalSince(now) == 10 * 60)
        #expect(easy.due.timeIntervalSince(now) == 8 * 86_400)
        let repeated = try schedule(.easy, now)
        #expect(repeated.due == easy.due)
        #expect(repeated.stability == easy.stability)
    }

    @Test func aPublishedGoodAndAgainHistoryKeepsTheSameIntervals() throws {
        var card: ReviewCardState?
        var now = utc(year: 2022, month: 12, day: 29, hour: 12, minute: 30)
        let ratings: [RecallRating] = [
            .good, .good, .good, .good, .good, .good,
            .again, .again, .good, .good, .good, .good, .good,
        ]
        var intervals: [Int] = []
        for rating in ratings {
            let next = try ReviewSchedule.schedule(existing: card, rating: rating, now: now, itemId: "item", senseId: "sense")
            intervals.append(Int(next.scheduledDays))
            now = next.due
            card = next
        }
        #expect(intervals == [0, 2, 11, 46, 163, 498, 0, 0, 2, 4, 7, 12, 21])
    }

    @Test func anOverdueSuccessWaitsLongerThanAnOnTimeSuccess() throws {
        let start = utc(year: 2022, month: 12, day: 29, hour: 12, minute: 30)
        let learned = try schedule(.easy, start)
        let onTime = try ReviewSchedule.schedule(existing: learned, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        let late = try ReviewSchedule.schedule(
            existing: learned, rating: .good, now: learned.due.addingTimeInterval(40 * 86_400), itemId: "item", senseId: "sense")
        #expect(late.scheduledDays > onTime.scheduledDays)
        #expect(late.due > onTime.due)
    }

    @Test func clockRollbackAndUnknownVersionLeaveTheCardUnchanged() throws {
        let now = utc(year: 2022, month: 12, day: 29, hour: 12, minute: 30)
        let learned = try schedule(.easy, now)
        #expect(throws: ReviewScheduleError.clockRollback) {
            try ReviewSchedule.schedule(existing: learned, rating: .good, now: learned.lastReview.addingTimeInterval(-1), itemId: "item", senseId: "sense")
        }
        var foreign = learned
        foreign.schedulerVersion = "fsrs-5.0"
        #expect(throws: ReviewScheduleError.unsupportedVersion) {
            try ReviewSchedule.schedule(existing: foreign, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        }
        let enrollment = VocabularyEnrollment(
            itemId: "item", senseId: "sense", lemma: "menu", lessonID: "topic",
            objectiveID: "personal-vocabulary", contentVersion: "personal", enrolledAt: now)
        let plan = ReviewQueue.plan(enrollments: [enrollment], cards: [foreign], now: learned.due)
        #expect(plan.due.isEmpty)
        #expect(plan.blocked == 1)
        let waiting = ReviewQueue.plan(enrollments: [enrollment], cards: [learned], now: now)
        #expect(waiting.due.isEmpty)
        #expect(waiting.waiting == 1)
        let dueInstant = ReviewQueue.plan(enrollments: [enrollment], cards: [learned], now: learned.due)
        #expect(dueInstant.due.map(\.id) == [enrollment.id])
    }

    @Test func savingAWordDoesNotScheduleUntilAnExplicitRating() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-T046-\(UUID().uuidString)")
        var clock = utc(year: 2022, month: 12, day: 29, hour: 12, minute: 30)
        let repo = try LearnerRepository(root: root, now: { clock }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        defer { repo.close() }
        let topic = try repo.createCustomTopic(title: "Kitchen", subtopic: "")
        let sense = try repo.addCustomSense(topicID: topic.id, lemma: "menu", note: "a list of dishes")
        let saved = try repo.enrollCustomSense(topicID: topic.id, senseID: sense.sense.id)
        #expect(try repo.recognitionSchedule(itemId: saved.itemId, senseId: saved.senseId) == nil)
        #expect(try repo.reviewQueue().due.map(\.id) == [saved.id])

        var draft = RecallDraft()
        draft.reveal()
        _ = try repo.recordVocabularyRecall(card: saved, rating: .good, draft: draft)
        let scheduled = try #require(try repo.recognitionSchedule(itemId: saved.itemId, senseId: saved.senseId))
        #expect(scheduled.due.timeIntervalSince(clock) == 10 * 60)
        #expect(scheduled.kind == "recognition")
        #expect(try repo.reviewQueue().due.isEmpty)
        #expect(try repo.reviewQueue().waiting == 1)

        repo.close()
        let reopened = try LearnerRepository(root: root, now: { clock }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
        defer { reopened.close() }
        #expect(try reopened.recognitionSchedule(itemId: saved.itemId, senseId: saved.senseId)?.due == scheduled.due)

        clock = scheduled.due
        #expect(try reopened.reviewQueue().due.map(\.id) == [saved.id])

        reopened.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) {
            try reopened.recordVocabularyRecall(card: saved, rating: .easy, draft: draft, sourceEventID: UUID())
        }
        reopened.beforeCommit = nil
        #expect(try reopened.vocabularyRecalls().count == 1)
        #expect(try reopened.recognitionSchedule(itemId: saved.itemId, senseId: saved.senseId)?.due == scheduled.due)

        try reopened.deleteAllLearningData()
        #expect(try reopened.recognitionSchedule(itemId: saved.itemId, senseId: saved.senseId) == nil)
        #expect(try reopened.reviewQueue().due.isEmpty)
    }

    @Test func anHourIsNotDescribedAsOneDay() {
        let now = utc(year: 2022, month: 12, day: 29, hour: 12, minute: 30)
        #expect(ReviewSchedule.returnPhrase(due: now, now: now) == "now")
        #expect(ReviewSchedule.returnPhrase(due: now.addingTimeInterval(-1), now: now) == "now")
        #expect(ReviewSchedule.returnPhrase(due: now.addingTimeInterval(60), now: now) == "1 minute")
        #expect(ReviewSchedule.returnPhrase(due: now.addingTimeInterval(90), now: now) == "1 minute")
        #expect(ReviewSchedule.returnPhrase(due: now.addingTimeInterval(6 * 60), now: now) == "6 minutes")
        #expect(ReviewSchedule.returnPhrase(due: now.addingTimeInterval(10 * 60), now: now) == "10 minutes")
        #expect(ReviewSchedule.returnPhrase(due: now.addingTimeInterval(3_599), now: now) == "60 minutes")
        #expect(ReviewSchedule.returnPhrase(due: now.addingTimeInterval(3_600), now: now) == "1 hour")
        #expect(ReviewSchedule.returnPhrase(due: now.addingTimeInterval(2 * 3_600), now: now) == "2 hours")
        #expect(ReviewSchedule.returnPhrase(due: now.addingTimeInterval(12 * 3_600), now: now) == "12 hours")
        #expect(ReviewSchedule.returnPhrase(due: now.addingTimeInterval(23 * 3_600), now: now) == "23 hours")
        #expect(ReviewSchedule.returnPhrase(due: now.addingTimeInterval(86_400), now: now) == "1 day")
        #expect(ReviewSchedule.returnPhrase(due: now.addingTimeInterval(2 * 86_400), now: now) == "2 days")
        #expect(ReviewSchedule.returnPhrase(due: now.addingTimeInterval(8 * 86_400), now: now) == "8 days")
        #expect(ReviewSchedule.returnPhrase(due: Date(timeIntervalSince1970: .nan), now: now) == "now")
        #expect(ReviewSchedule.returnPhrase(due: Date(timeIntervalSince1970: .infinity), now: now) == "now")
        #expect(ReviewSchedule.returnPhrase(due: .distantFuture, now: .distantPast).hasSuffix(" days"))
    }

    @Test func duplicateAndInvalidHistoriesDoNotReplaceAUsableCard() throws {
        let start = utc(year: 2022, month: 12, day: 29, hour: 12, minute: 30)
        let appleCard = try ReviewSchedule.schedule(existing: nil, rating: .easy, now: start, itemId: "apple", senseId: "apple-sense")
        let menuA = try ReviewSchedule.schedule(existing: nil, rating: .easy, now: start, itemId: "menu", senseId: "menu-sense")
        var menuB = menuA
        menuB.stability = menuA.stability + 1
        var saltCard = try ReviewSchedule.schedule(existing: nil, rating: .good, now: start, itemId: "salt", senseId: "salt-sense")
        saltCard.stability = .nan
        let pearCard = try ReviewSchedule.schedule(existing: nil, rating: .easy, now: start, itemId: "pear", senseId: "pear-sense")
        let apple = enrollment("apple", "apple-sense", "apple", start)
        let menu = enrollment("menu", "menu-sense", "menu", start)
        let salt = enrollment("salt", "salt-sense", "salt", start)
        let bread = enrollment("bread", "bread-sense", "bread", start)
        let pear = enrollment("pear", "pear-sense", "pear", start)
        let plan = ReviewQueue.plan(
            enrollments: [menu, apple, salt, bread, pear, pear],
            cards: [menuA, menuB, appleCard, saltCard, pearCard],
            now: start)
        #expect(plan.due.map(\.id) == [bread.id])
        #expect(plan.waiting == 1)
        #expect(plan.nextDue == appleCard.due)
        #expect(plan.blocked == 3)
        #expect(plan.due.map(\.id).contains(menu.id) == false)
        #expect(plan.due.map(\.id).contains(pear.id) == false)
    }

    @Test func aStoredCardOutsideThePinnedRangesIsNotRescheduled() throws {
        let start = utc(year: 2022, month: 12, day: 29, hour: 12, minute: 30)
        let learned = try schedule(.easy, start)
        var held = learned
        held.stability = 0
        held.difficulty = 0
        #expect(throws: ReviewScheduleError.schedulingFailed) {
            try ReviewSchedule.schedule(existing: held, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        }
        #expect(held.stability == 0)
        #expect(held.difficulty == 0)
        #expect(held.due == learned.due)

        var belowStability = learned
        belowStability.stability = 0.0009999
        #expect(throws: ReviewScheduleError.schedulingFailed) {
            try ReviewSchedule.schedule(existing: belowStability, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        }
        var aboveDifficulty = learned
        aboveDifficulty.difficulty = 10.1
        #expect(throws: ReviewScheduleError.schedulingFailed) {
            try ReviewSchedule.schedule(existing: aboveDifficulty, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        }
        var negativeStep = learned
        negativeStep.learningSteps = -1
        #expect(throws: ReviewScheduleError.schedulingFailed) {
            try ReviewSchedule.schedule(existing: negativeStep, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        }
        var overflowedReps = learned
        overflowedReps.reps = Int.max
        #expect(throws: ReviewScheduleError.schedulingFailed) {
            try ReviewSchedule.schedule(existing: overflowedReps, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        }
        var negativeElapsed = learned
        negativeElapsed.elapsedDays = -1
        #expect(throws: ReviewScheduleError.schedulingFailed) {
            try ReviewSchedule.schedule(existing: negativeElapsed, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        }
        var openInterval = learned
        openInterval.scheduledDays = ReviewSchedule.maximumIntervalDays + 1
        #expect(throws: ReviewScheduleError.schedulingFailed) {
            try ReviewSchedule.schedule(existing: openInterval, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        }
        var undated = learned
        undated.due = Date(timeIntervalSince1970: .infinity)
        #expect(throws: ReviewScheduleError.schedulingFailed) {
            try ReviewSchedule.schedule(existing: undated, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        }
        #expect(throws: ReviewScheduleError.schedulingFailed) {
            try ReviewSchedule.schedule(existing: nil, rating: .good, now: Date(timeIntervalSince1970: .nan), itemId: "item", senseId: "sense")
        }

        var mastered = learned
        mastered.phase = "mastered"
        #expect(throws: ReviewScheduleError.unsupportedVersion) {
            try ReviewSchedule.schedule(existing: mastered, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        }
        var productive = learned
        productive.kind = "productive"
        #expect(throws: ReviewScheduleError.unsupportedVersion) {
            try ReviewSchedule.schedule(existing: productive, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        }
        #expect(throws: ReviewScheduleError.unsupportedVersion) {
            try ReviewSchedule.schedule(existing: learned, rating: .good, now: learned.due, itemId: "item", senseId: "other")
        }

        var lowerBound = learned
        lowerBound.stability = 0.001
        lowerBound.difficulty = 1
        let fromLowerBound = try ReviewSchedule.schedule(existing: lowerBound, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        #expect(fromLowerBound.itemId == "item")
        #expect(fromLowerBound.schedulerVersion == ReviewSchedule.version)

        var upperBound = learned
        upperBound.stability = 36_500
        upperBound.difficulty = 10
        upperBound.scheduledDays = ReviewSchedule.maximumIntervalDays
        upperBound.learningSteps = 9
        let fromUpperBound = try ReviewSchedule.schedule(existing: upperBound, rating: .good, now: learned.due, itemId: "item", senseId: "sense")
        #expect(fromUpperBound.kind == ReviewSchedule.kind)
        #expect(fromUpperBound.due > learned.due)

        let enrollment = VocabularyEnrollment(
            itemId: "item", senseId: "sense", lemma: "menu", lessonID: "topic",
            objectiveID: "personal-vocabulary", contentVersion: "personal", enrolledAt: start)
        let blockedPlan = ReviewQueue.plan(enrollments: [enrollment], cards: [held], now: learned.due)
        #expect(blockedPlan.due.isEmpty)
        #expect(blockedPlan.blocked == 1)
        let wrongKind = ReviewQueue.plan(enrollments: [enrollment], cards: [productive], now: learned.due)
        #expect(wrongKind.due.isEmpty)
        #expect(wrongKind.blocked == 1)
        let cardless = VocabularyEnrollment(
            itemId: "fresh", senseId: "fresh-sense", lemma: "bread", lessonID: "topic",
            objectiveID: "personal-vocabulary", contentVersion: "personal", enrolledAt: start)
        let nonfiniteClock = ReviewQueue.plan(
            enrollments: [cardless, cardless], cards: [], now: Date(timeIntervalSince1970: .nan))
        #expect(nonfiniteClock.due.isEmpty)
        #expect(nonfiniteClock.waiting == 0)
        #expect(nonfiniteClock.blocked == 1)
    }

    private func enrollment(_ itemId: String, _ senseId: String, _ lemma: String, _ now: Date) -> VocabularyEnrollment {
        VocabularyEnrollment(
            itemId: itemId, senseId: senseId, lemma: lemma, lessonID: "topic",
            objectiveID: "personal-vocabulary", contentVersion: "personal", enrolledAt: now)
    }

    private func schedule(_ rating: RecallRating, _ now: Date) throws -> ReviewCardState {
        try ReviewSchedule.schedule(existing: nil, rating: rating, now: now, itemId: "item", senseId: "sense")
    }

    private func utc(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }
}

struct ReviewDeliveryTests {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    @Test func retentionIsValidatedAndChangesOnlyTheNextSchedule() throws {
        for retention in [0.0, 1, -0.1, .infinity, .nan] {
            #expect(throws: ReviewScheduleError.invalidSettings) { try ReviewSettings(desiredRetention: retention).validate() }
        }
        #expect(throws: ReviewScheduleError.invalidSettings) { try ReviewSettings(sessionLimit: 0).validate() }
        #expect(throws: ReviewScheduleError.invalidSettings) { try ReviewSettings(sessionLimit: -1).validate() }
        let low = try ReviewSchedule.schedule(existing: nil, rating: .easy, now: now, itemId: "item", senseId: "sense", settings: ReviewSettings(desiredRetention: 0.8))
        let high = try ReviewSchedule.schedule(existing: nil, rating: .easy, now: now, itemId: "item", senseId: "sense", settings: ReviewSettings(desiredRetention: 0.95))
        #expect(low.due > high.due)
        #expect(high.desiredRetention == 0.95)
        let legacy = try ReviewSchedule.schedule(existing: nil, rating: .easy, now: now, itemId: "item", senseId: "sense")
        #expect(legacy.due.timeIntervalSince(now) == 8 * 86_400)
    }

    @Test func limitedSessionResumesFirstWithoutLosingTheBacklog() throws {
        let a = card("apple"), b = card("bread"), c = card("water")
        let queue = ReviewQueuePlan(due: [a, b, c], waiting: 2, nextDue: now, blocked: 1)
        let open = OpenRecall(itemId: c.itemId, senseId: c.senseId, typed: "draft", revealed: false, hinted: false)
        let limited = try ReviewSessionPlan(queue: queue, settings: ReviewSettings(sessionLimit: 1), open: open)
        #expect(limited.cards == [c])
        #expect(limited.deferred == 2)
        #expect(queue.due == [a, b, c])
        let all = try ReviewSessionPlan(queue: queue, settings: ReviewSettings(), open: open)
        #expect(all.cards == [c, a, b])
        #expect(all.deferred == 0)
        var unavailable = open
        unavailable.itemId = "unavailable"
        #expect(try ReviewSessionPlan(queue: queue, settings: ReviewSettings(sessionLimit: 1), open: unavailable).cards == [a])
    }

    @Test func settingsPersistProspectivelyAndFailuresKeepHistoryAndDrafts() throws {
        let root = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        var repo = try repository(root)
        defer { repo.close() }
        #expect(try repo.reviewSettings() == ReviewSettings())
        let card = try collectedCard(repo)
        #expect(try repo.reviewQueue().due.isEmpty)
        try repo.addCollectedVocabularyToReview(card)
        try repo.addCollectedVocabularyToReview(card)
        #expect(try repo.vocabularyEnrollments().count == 1)
        #expect(try repo.reviewQueue().due.count == 1)
        var draft = RecallDraft(typed: "a list")
        try repo.stageOpenRecall(card: card, draft: draft)
        let settings = ReviewSettings(desiredRetention: 0.95, sessionLimit: 1)
        try repo.saveReviewSettings(settings)
        #expect(try repo.openRecall()?.typed == "a list")
        #expect(try repo.recognitionSchedule(itemId: card.itemId, senseId: card.senseId) == nil)
        draft.reveal()
        try repo.stageOpenRecall(card: card, draft: draft)
        _ = try repo.recordVocabularyRecall(card: card, rating: .easy, draft: draft)
        let scheduled = try #require(try repo.recognitionSchedule(itemId: card.itemId, senseId: card.senseId))
        #expect(scheduled.desiredRetention == 0.95)
        #expect(try repo.vocabularyRecalls().last?.desiredRetention == 0.95)
        #expect(try repo.vocabularyRecalls().last?.schedulerVersion == ReviewSchedule.version)
        repo.close()
        repo = try repository(root)
        #expect(try repo.reviewSettings() == settings)
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) { try repo.saveReviewSettings(ReviewSettings()) }
        repo.beforeCommit = nil
        #expect(try repo.reviewSettings() == settings)
        #expect(try repo.recognitionSchedule(itemId: card.itemId, senseId: card.senseId) == scheduled)
        try repo.saveReviewSettings(ReviewSettings())
        #expect(try repo.recognitionSchedule(itemId: card.itemId, senseId: card.senseId) == scheduled)
        #expect(try repo.vocabularyRecalls().count == 1)
    }

    @Test func staleSettingsAndRecallCannotRepopulateAResetLearner() throws {
        let root = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try repository(root)
        defer { repo.close() }
        let epoch = try repo.learningDataEpoch()
        let card = try collectedCard(repo)
        try repo.addCollectedVocabularyToReview(card)
        try repo.saveReviewSettings(ReviewSettings(sessionLimit: 1), expectedEpoch: epoch)
        try repo.savePracticeGoal(.speechLab, expectedEpoch: epoch)
        try repo.deleteAllLearningData()
        #expect(try repo.reviewSettings() == ReviewSettings())
        #expect(try repo.practiceGoal() == nil)
        #expect(throws: LearnerStorageError.invalidState) { try repo.saveReviewSettings(ReviewSettings(sessionLimit: 2), expectedEpoch: epoch) }
        #expect(throws: LearnerStorageError.invalidState) { try repo.savePracticeGoal(.openLesson, expectedEpoch: epoch) }
        #expect(throws: LearnerStorageError.invalidState) { try repo.stageOpenRecall(card: card, draft: RecallDraft(), expectedEpoch: epoch) }
        #expect(throws: LearnerStorageError.invalidState) { try repo.recordVocabularyRecall(card: card, rating: .good, draft: RecallDraft(revealed: true), expectedEpoch: epoch) }
        #expect(try repo.vocabularyRecalls().isEmpty)
    }

    @Test func legacyCardAndRatingDecodeWithoutInventingParameterHistory() throws {
        let scheduled = try ReviewSchedule.schedule(existing: nil, rating: .easy, now: now, itemId: "item", senseId: "sense")
        var object = try #require(try JSONSerialization.jsonObject(with: JSONEncoder().encode(scheduled)) as? [String: Any])
        object.removeValue(forKey: "desiredRetention")
        let old = try JSONDecoder().decode(ReviewCardState.self, from: JSONSerialization.data(withJSONObject: object))
        #expect(old.desiredRetention == nil)
        #expect(old.due == scheduled.due)
        let next = try ReviewSchedule.schedule(existing: old, rating: .good, now: old.due, itemId: "item", senseId: "sense")
        #expect(next.schedulerVersion == ReviewSchedule.version)
        let rating = VocabularyRecallAttempt(id: UUID(), itemId: "item", senseId: "sense", lemma: "word", rating: .good, revealed: true, typedAttempt: nil, modality: "selfCheck", createdAt: now)
        let decoded = try JSONDecoder().decode(VocabularyRecallAttempt.self, from: JSONEncoder().encode(rating))
        #expect(decoded.schedulerVersion == nil)
        #expect(decoded.desiredRetention == nil)
    }

    @Test func sharedGoalAPIKeepsIndependentReviewSettingsAndSurvivesRestart() throws {
        let root = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        var repo = try repository(root)
        defer { repo.close() }
        #expect(try repo.practiceGoal() == nil)
        try repo.saveReviewSettings(ReviewSettings(sessionLimit: 3))
        try repo.savePracticeGoal(.speechLab)
        repo.close()
        repo = try repository(root)
        #expect(try repo.practiceGoal() == .speechLab)
        #expect(try repo.reviewSettings().sessionLimit == 3)
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) { try repo.savePracticeGoal(.openLesson) }
        repo.beforeCommit = nil
        #expect(try repo.practiceGoal() == .speechLab)
        try repo.savePracticeGoal(nil)
        #expect(try repo.practiceGoal() == nil)
        #expect(try repo.reviewSettings().sessionLimit == 3)
    }

    @Test func duplicateHistoryCannotBeBypassedByDirectRating() throws {
        let root = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        var repo = try repository(root)
        defer { repo.close() }
        let card = try collectedCard(repo)
        try repo.addCollectedVocabularyToReview(card)
        var first = RecallDraft(); first.reveal()
        _ = try repo.recordVocabularyRecall(card: card, rating: .easy, draft: first)
        repo.close()
        try duplicateHistory(root)
        repo = try repository(root)
        #expect(try repo.reviewQueue().blocked == 1)
        var next = RecallDraft(); next.reveal()
        try repo.stageOpenRecall(card: card, draft: next)
        #expect(throws: ReviewScheduleError.schedulingFailed) { try repo.recordVocabularyRecall(card: card, rating: .good, draft: next) }
        #expect(try repo.vocabularyRecalls().count == 1)
        #expect(try repo.openRecall()?.sourceEventID == next.sourceEventID)
        #expect(try repo.reviewQueue().blocked == 1)
    }

    private func card(_ name: String) -> VocabularyEnrollment {
        VocabularyEnrollment(itemId: name, senseId: name, lemma: name, lessonID: "test", objectiveID: "test", contentVersion: "1", enrolledAt: now)
    }
    private func temporaryRoot() -> URL { FileManager.default.temporaryDirectory.appendingPathComponent("review-delivery-\(UUID().uuidString)") }
    private func repository(_ root: URL) throws -> LearnerRepository {
        try LearnerRepository(root: root, now: { now }, uptime: { 0 }, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
    }
    private func collectedCard(_ repo: LearnerRepository) throws -> VocabularyEnrollment {
        let topic = try repo.createCustomTopic(title: "Kitchen", subtopic: "")
        let sense = try repo.addCustomSense(topicID: topic.id, lemma: "menu", note: "a list of dishes")
        return try repo.saveCustomSenseToCollection(topicID: topic.id, senseID: sense.sense.id)
    }
    private func duplicateHistory(_ root: URL) throws {
        let schema = Schema(versionedSchema: LearnerSchemaV1.self)
        let config = ModelConfiguration(root.lastPathComponent, schema: schema, url: root.appendingPathComponent("learner.store"), allowsSave: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, migrationPlan: LearnerMigrationPlan.self, configurations: [config])
        let context = ModelContext(container)
        let row = try #require(try context.fetch(FetchDescriptor<LearnerSchemaV1.StateRow>()).first)
        var object = try #require(try JSONSerialization.jsonObject(with: row.preferences) as? [String: Any])
        var cards = try #require(object["reviewCards"] as? [[String: Any]])
        cards.append(try #require(cards.first))
        object["reviewCards"] = cards
        row.preferences = try JSONSerialization.data(withJSONObject: object)
        try context.save()
    }
}
