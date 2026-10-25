import Foundation
import CryptoKit
import ImageIO
import Testing
@testable import SpeechCoachAI

@Suite(.serialized)
struct RewardDeliveryTests {
    let now = Date(timeIntervalSince1970: 1_792_800_000)
    func ledger() -> RewardLedger { RewardLedger(epoch: UUID(), startedAt: now) }
    func pay(_ value: inout RewardLedger, _ source: String, day: String = "2026-10-25", activity: String = "task", kind: String = "exercise", fresh: Bool = false) throws {
        try value.credit(source: source, activity: activity, kind: kind, day: day, now: now, freshReview: fresh)
    }
    func fund(_ value: inout RewardLedger, day: String = "2026-10-25") throws {
        for index in 0..<120 { try pay(&value, "fund\(index)", day: day, activity: "different\(index)") }
    }
    func repository(_ root: URL) throws -> LearnerRepository {
        try LearnerRepository(root: root, now: { now }, uptime: { 0 }, protectedDataAvailable: { true })
    }
    func root() -> URL { FileManager.default.temporaryDirectory.appendingPathComponent("SC-D005-\(UUID())") }
    func course() throws -> ResolvedLesson { try #require(CurriculumCatalogLoader.bundled.lesson(id: "intro-01", version: "4")) }
    func finished() throws -> LessonJourney {
        var session = try LessonSession.begin(lesson: course(), presenter: "synthetic", now: now)
        for activity in session.activities {
            try session.record(activityID: activity.id, text: "Synthetic deliberate practice", assisted: false)
            if session.needsComparison(activity.id) { _ = try session.revealAnswer(activityID: activity.id) }
        }
        try session.finish(now: now)
        return session.journey
    }

    @Test func originalEconomyRepeatAndSourceIdentitySurviveDates() throws {
        var value = ledger()
        try pay(&value, "one"); try pay(&value, "one", day: "2026-10-26")
        #expect(value.xp == 10 && value.gold == 2 && value.transactions.count == 1)
        try pay(&value, "two"); try pay(&value, "three")
        #expect(value.xp == 15 && value.gold == 3)
        try pay(&value, "four", day: "2026-10-26")
        #expect(value.xp == 25 && value.gold == 5)
        #expect(throws: RewardError.clockChanged) { try pay(&value, "back", day: "2026-10-25") }
    }
    @Test func nestedSpeakingPaysRemainingEntitlementAndKeepsHistory() throws {
        var value = ledger(); try pay(&value, "nested")
        try pay(&value, "nested", kind: "speaking"); try pay(&value, "nested", kind: "speaking")
        #expect(value.xp == 30 && value.gold == 6)
        #expect(value.transactions.count == 2 && value.transactions[0].xp == 10 && value.transactions[1].xp == 20)
        #expect(value.awards.filter { $0.family == "AW-P-05" }.count == 1)
        try pay(&value, "repeat", kind: "speaking")
        #expect(value.xp == 45 && value.gold == 9)
    }
    @Test func freshRatedOpportunityHasFullCreditButReplayDoesNot() throws {
        var value = ledger()
        try pay(&value, "review1", kind: "review", fresh: true)
        try pay(&value, "review2", kind: "review", fresh: true)
        try pay(&value, "review2", kind: "review", fresh: true)
        #expect(value.xp == 20 && value.gold == 4)
        #expect(value.awards.contains { $0.family == "AW-P-04" })
    }
    @Test func hintsResetOnlyOnForwardDateAndNeverCreateNegativeBalance() throws {
        var value = ledger()
        for _ in 0..<3 { let q = try value.quote(.hint, day: "2026-10-25"); try value.purchase(q, day: q.day, now: now); value.revision += 1 }
        #expect(value.gold == 0)
        #expect(throws: RewardError.insufficientGold) { try value.quote(.hint, day: "2026-10-25") }
        #expect(throws: RewardError.clockChanged) { try value.quote(.hint, day: "2026-10-24") }
        #expect(try value.quote(.hint, day: "2026-10-26").cost == 0)
    }
    @Test func explicitQuoteCancelStalenessAndDuplicatePurchase() throws {
        var value = ledger(); try fund(&value)
        let original = value
        let cancelled = try value.quote(.freeze, day: "2026-10-25")
        #expect(value == original && cancelled.cost == 20)
        try value.purchase(cancelled, day: cancelled.day, now: now); value.revision += 1
        let after = value
        try value.purchase(cancelled, day: cancelled.day, now: now)
        #expect(value == after && value.freezes == 1 && value.gold == original.gold - 20)
        let stale = try value.quote(.example, day: "2026-10-25"); value.revision += 1
        #expect(throws: RewardError.stale) { try value.purchase(stale, day: stale.day, now: now) }
    }
    @Test func freezeAutoUseIsOptInAndDoesNotInventPractice() throws {
        var value = ledger(); try fund(&value, day: "2026-10-20")
        let q = try value.quote(.freeze, day: "2026-10-20"); try value.purchase(q, day: q.day, now: now)
        #expect(!value.settings.autoFreeze && value.protectedDays.isEmpty)
        value.settings.autoFreeze = true
        try pay(&value, "next", day: "2026-10-22", activity: "new")
        #expect(value.protectedDays == ["2026-10-21"] && value.freezes == 0 && value.practiceDays.count == 2 && value.streak == 3)
        value.protectMissedDays(endingAt: "2026-10-22", now: now)
        #expect(value.transactions.filter { $0.kind == "freezeUse" }.count == 1)
    }
    @Test func repairExactBoundariesAndCooldown() throws {
        var value = ledger(); try fund(&value, day: "2026-10-20")
        let q = try value.quote(.repair, day: "2026-10-23")
        #expect(q.cost == 60 && q.missedDays == ["2026-10-21","2026-10-22"])
        try value.purchase(q, day: q.day, now: now)
        #expect(value.practiceDays == ["2026-10-20"] && value.protectedDays.count == 2)
        #expect(throws: RewardError.repairUnavailable) { try value.quote(.repair, day: "2026-10-24") }
        try pay(&value, "resume", day: "2026-10-23", activity: "resume")
        #expect(try value.quote(.repair, day: "2026-10-25").cost == 30)
        #expect(throws: RewardError.repairUnavailable) { try value.quote(.repair, day: "2026-11-05") }
    }
    @Test func repairWorksAfterTodaysPracticeAndDoesNotPayAgain() throws {
        var value = ledger(); try fund(&value, day: "2026-10-20")
        try pay(&value, "resume", day: "2026-10-23", activity: "new")
        let xp = value.xp
        let q = try value.quote(.repair, day: "2026-10-23"); try value.purchase(q, day: q.day, now: now)
        #expect(value.xp == xp && value.streak == 4)
    }
    @Test func persistenceFailedCompletionRetryReopenAndReset() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        var repo: LearnerRepository? = try repository(url)
        let journey = try finished()
        repo!.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) { try repo!.saveLessonJourney(journey) }
        #expect(try repo!.rewardLedger().xp == 0 && repo!.allLessonJourneys().isEmpty)
        repo!.beforeCommit = nil; try repo!.saveLessonJourney(journey)
        let earned = try repo!.rewardLedger()
        #expect(earned.xp > 0 && earned.checkpoints.count == 1)
        #expect(earned.awards.contains { $0.family == "AW-P-02" } && earned.awards.contains { $0.family == "AW-P-03" })
        try repo!.saveLessonJourney(journey)
        #expect(try repo!.rewardLedger() == earned)
        repo!.close(); repo = nil
        let reopened = try repository(url)
        #expect(try reopened.rewardLedger() == earned)
        let q = try earned.quote(.example, day: RewardPolicy.day(now))
        try reopened.deleteAllLearningData()
        #expect(try reopened.rewardLedger().gold == 0 && reopened.rewardLedger().awards.isEmpty)
        #expect(throws: LearnerStorageError.staleVersion) { try reopened.purchaseReward(q) }
    }
    @Test func purchaseFailureIsAtomicAndRetryHasOneDebit() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let repo = try repository(url); try repo.saveLessonJourney(finished())
        let before = try repo.rewardLedger(), q = try before.quote(.freeze, day: RewardPolicy.day(now))
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) { try repo.purchaseReward(q) }
        #expect(try repo.rewardLedger() == before)
        repo.beforeCommit = nil; try repo.purchaseReward(q); try repo.purchaseReward(q)
        #expect(try repo.rewardLedger().gold == before.gold - 20 && repo.rewardLedger().freezes == 1)
    }
    @Test func planBonusIsExactVersionOnceAndIndependentOfTimeTarget() throws {
        var value = ledger(); value.settings.activeMinutesGoal = 500
        let lesson = try course(); try value.startPlan(lesson: lesson, day: "2026-10-25", now: now)
        for task in value.plans[0].activityIDs { try pay(&value, "source/\(task)", activity: "\(lesson.id)/\(lesson.contentVersion)/\(task)") }
        #expect(value.plans[0].completed && value.transactions.filter { $0.kind == "plan" }.count == 1)
        #expect(value.transactions.first { $0.kind == "plan" }?.gold == 10 && value.activeSeconds.isEmpty)
        value.completePlans(now: now)
        #expect(value.transactions.filter { $0.kind == "plan" }.count == 1)
        #expect(throws: RewardError.invalidRequest) { try value.startPlan(lesson: lesson, day: "2026-10-25", now: now) }
    }
    @Test func timeClockPausesIdleBackgroundAndHonorsAudioException() {
        var clock = RewardActiveClock(); clock.interact(at: 0)
        #expect(clock.sample(at: 0, active: true, audio: false) == 0)
        #expect(clock.sample(at: 40, active: true, audio: false) == 40)
        #expect(clock.sample(at: 80, active: true, audio: false) == 20)
        #expect(clock.sample(at: 90, active: true, audio: false) == 0)
        #expect(clock.sample(at: 100, active: true, audio: true) == 10)
        #expect(clock.sample(at: 200, active: false, audio: true) == 0)
        #expect(clock.sample(at: 300, active: true, audio: true) == 0)
    }
    @Test func timeRetryIsIdempotentAndCannotCrossReset() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let repo = try repository(url), epoch = try repo.learningDataEpoch(), id = UUID(), day = RewardPolicy.day(now)
        try repo.addRewardActiveTime(seconds: 5, day: day, epoch: epoch, sampleID: id)
        try repo.addRewardActiveTime(seconds: 5, day: day, epoch: epoch, sampleID: id)
        #expect(try repo.rewardLedger().activeSeconds[day] == 5 && repo.rewardLedger().gold == 0)
        try repo.deleteAllLearningData()
        #expect(throws: LearnerStorageError.staleVersion) { try repo.addRewardActiveTime(seconds: 5, day: day, epoch: epoch, sampleID: id) }
    }
    @Test func settingsDefaultsAndInvalidReminderRemainSafe() throws {
        let settings = RewardSettings()
        #expect(!settings.music && !settings.effects && !settings.haptics && !settings.quiet && !settings.autoFreeze && !settings.reminderEnabled && settings.breakMinutes == nil)
        var invalid = settings; invalid.reminderEnabled = true
        #expect(throws: RewardError.invalidRequest) { try invalid.validate() }
        invalid.reminderWeekdays = [1]; invalid.activityGoal = 1
        try invalid.validate()
        invalid.reminderWeekdays = [1,1]
        #expect(throws: RewardError.invalidRequest) { try invalid.validate() }
    }
    @Test func reminderNextSelectedDateAndGoalsAreIndependent() throws {
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        var value = ledger(); value.settings.activityGoal = 1; value.settings.activeMinutesGoal = 10
        value.settings.reminderWeekdays = [2]; value.settings.reminderHour = 9
        let next = try #require(RewardReminderScheduler.nextDate(settings: value.settings, now: now, calendar: calendar))
        #expect(next > now && calendar.component(.weekday, from: next) == 2 && calendar.component(.hour, from: next) == 9)
        try pay(&value, "task", day: RewardPolicy.day(now, calendar: calendar))
        #expect(!RewardReminderScheduler.goalMet(value, now: now, calendar: calendar))
        value.activeSeconds[RewardPolicy.day(now, calendar: calendar)] = 600
        #expect(RewardReminderScheduler.goalMet(value, now: now, calendar: calendar))
    }
    @Test func all68AdoptedArtMappingsMatchSourceHashesAndRemainDecodableAtNativeSize() throws {
        #expect(AwardFamily.catalog.count == 68 && Set(AwardFamily.catalog.map(\.id)).count == 68)
        #expect(AwardFamily.supports(lessonID: "intro-01", version: "4"))
        #expect(!AwardFamily.supports(lessonID: "intro-01", version: "unadopted-future"))
        for family in AwardFamily.catalog {
            let url = try #require(Bundle.main.url(forResource: family.filename, withExtension: nil, subdirectory: "masters"))
            let data = try Data(contentsOf: url)
            #expect(SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined() == family.sha256)
            let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
            for size in [144,216,540] {
                #expect(CGImageSourceCreateThumbnailAtIndex(source, 0, [kCGImageSourceCreateThumbnailFromImageAlways: true, kCGImageSourceThumbnailMaxPixelSize: size] as CFDictionary) != nil)
            }
            #expect(!family.criteria.isEmpty && !family.ruleVersion.isEmpty)
        }
        #expect(AwardFamily.catalog.filter { !$0.collectible }.map(\.id) == ["AW-CR-01","AW-CR-02","AW-CR-03"])
    }
    @Test func practiceNeverGrantsLearningOrCourseLevelBadgesAndDeletedEvidenceIsLabeled() throws {
        var value = ledger(); try fund(&value)
        #expect(value.awards.allSatisfy { ["AW-P-01"].contains($0.family) })
        let family = try #require(AwardFamily.catalog.first { $0.id == "AW-LE-01" })
        #expect(family.state(ledger: value).contains("not yet available"))
        value.award("AW-LE-01", now: now, evidence: ["synthetic-deleted-evidence"])
        value.awards[value.awards.count-1].evidenceUnavailable = true
        #expect(family.state(ledger: value) == "Supporting evidence unavailable")
        #expect(value.gold == 240)
    }
    @Test func focusStackAndBreakSurviveNavigationWithoutDoubleCounting() {
        let state = RewardEngagementState(), epoch = UUID(), first = UUID(), sheet = UUID()
        state.claim(first, epoch: epoch); state.startBreak(minutes: 1); let end = state.breakEnd
        state.claim(sheet, epoch: epoch)
        #expect(state.owners.last == sheet && state.breakEnd == end)
        state.release(sheet)
        #expect(state.owners.last == first)
        state.setActive(false); #expect(state.breakEnd == nil && state.pausedBreak != nil)
        state.setActive(true); #expect(state.breakEnd != nil && state.pausedBreak == nil)
        state.claim(first, epoch: UUID()); #expect(state.breakEnd == nil)
    }
    @Test func optionalHelpHasFiniteDistinctContentAndAcknowledgementNeverPays() throws {
        #expect(RewardAssistanceContent.forActivity("grammar-be-am")?.example.contains("nurse") == true)
        #expect(RewardAssistanceContent.forActivity("reserved-check") == nil)
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let repo = try repository(url); try repo.saveLessonJourney(finished())
        let before = try repo.rewardLedger()
        try repo.acknowledgeRewards(before.pendingAwards.map(\.id), epoch: before.epoch, revision: before.revision)
        let after = try repo.rewardLedger()
        #expect(after.pendingAwards.isEmpty && after.gold == before.gold && after.xp == before.xp)
    }
    @Test func repositoryPlanRequiresFinalSelfReviewAndPaysOnlyOnce() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let repo = try repository(url), initial = try repo.rewardLedger(), lesson = try course()
        try repo.startRewardPlan(lessonID: lesson.id, contentVersion: lesson.contentVersion, epoch: initial.epoch, revision: initial.revision)
        var journey = try finished(); let completedAt = journey.completedAt; journey.completedAt = nil
        try repo.saveLessonJourney(journey)
        #expect(try repo.rewardLedger().plans[0].completed == false)
        journey.completedAt = completedAt; try repo.saveLessonJourney(journey)
        let after = try repo.rewardLedger()
        #expect(after.plans[0].completed && after.gold == 44 && after.xp == 195)
        #expect(after.transactions.filter { $0.kind == "completion" }.allSatisfy { $0.xp == 0 && $0.gold == 0 })
        try repo.saveLessonJourney(journey)
        #expect(try repo.rewardLedger() == after)
    }
    @Test func exactPersonalUseSpecialistCompletionsDoNotEarnLearningAwards() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let repo = try repository(url), originJourney = try finished()
        for pack in [IntroPracticePack.teacher, .grammarian, .journalist] {
            let origin = LessonPracticeOrigin(journeyID: originJourney.id, lessonID: originJourney.lessonID, objectiveID: originJourney.objectiveID, activityID: nil)
            var session = try LessonSession.begin(lesson: pack.lesson, presenter: "synthetic", now: now)
            session.journey.practiceOrigin = origin
            for activity in session.activities {
                try session.record(activityID: activity.id, text: "Synthetic optional practice", assisted: false)
                if session.needsComparison(activity.id) { _ = try session.revealAnswer(activityID: activity.id) }
            }
            try session.finish(now: now); try repo.saveLessonJourney(session.journey)
        }
        let value = try repo.rewardLedger()
        #expect(Set(value.awards.filter { $0.family.hasPrefix("AW-TR") }.map(\.family)) == Set(["AW-TR-01C","AW-TR-02C","AW-TR-04C"]))
        #expect(!value.awards.contains { $0.family.hasSuffix("S") || $0.family.hasPrefix("AW-LE") })
        #expect(value.checkpoints.isEmpty)
    }

}
