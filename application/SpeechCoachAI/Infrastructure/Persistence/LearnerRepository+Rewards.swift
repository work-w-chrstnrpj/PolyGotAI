import Foundation
import SwiftData

/// XP, badges, reward settings and reconciliation on every write.
extension LearnerRepository {
    func rewardLedger() throws -> RewardLedger {
        let stored = try document()
        if let ledger = stored.rewards { return ledger }
        return RewardLedger(epoch: try learningDataEpoch(), startedAt: try effectiveNow())
    }

    func saveRewardSettings(_ settings: RewardSettings, expectedEpoch: UUID, expectedRevision: Int) throws {
        try settings.validate()
        try mutateRewards(epoch: expectedEpoch, revision: expectedRevision) { $0.settings = settings }
    }

    func acknowledgeRewards(_ ids: [String], epoch: UUID, revision: Int) throws {
        try mutateRewards(epoch: epoch, revision: revision) { ledger in
            let valid = Set(ledger.awards.map(\.id))
            ledger.acknowledged = Array(Set(ledger.acknowledged).union(ids.filter { valid.contains($0) })).sorted()
        }
    }

    func startRewardPlan(lessonID: String, contentVersion: String, epoch: UUID, revision: Int) throws {
        guard let lesson = CurriculumCatalogLoader.bundled.lesson(id: lessonID, version: contentVersion), lesson.isReady,
              AwardFamily.supports(lessonID: lessonID, version: contentVersion) else { throw RewardError.invalidRequest }
        let date = try effectiveNow()
        try mutateRewards(epoch: epoch, revision: revision) { try $0.startPlan(lesson: lesson, day: RewardPolicy.day(date), now: date) }
    }

    func addRewardActiveTime(seconds: Double, day: String, epoch: UUID, sampleID: UUID = UUID()) throws {
        guard seconds.isFinite, seconds > 0, seconds <= RewardPolicy.inactivitySeconds,
              RewardPolicy.ordinal(day) != nil, day <= RewardPolicy.day(try effectiveNow()) else { throw RewardError.invalidRequest }
        let ledger = try rewardLedger()
        try mutateRewards(epoch: epoch, revision: ledger.revision) { value in
            guard !value.timeSampleIDs.contains(sampleID) else { return }
            value.timeSampleIDs.append(sampleID)
            value.activeSeconds[day, default: 0] += seconds
        }
    }

    func refreshRewardContinuity(epoch: UUID, revision: Int) throws {
        let date = try effectiveNow()
        try mutateRewards(epoch: epoch, revision: revision) { value in
            let day = RewardPolicy.day(date)
            try value.acceptDay(day)
            if value.settings.autoFreeze { value.protectMissedDays(endingAt: day, now: date) }
        }
    }

    func mutateRewards(epoch: UUID, revision: Int, _ change: (inout RewardLedger) throws -> Void) throws {
        guard try learningDataEpoch() == epoch else { throw LearnerStorageError.staleVersion }
        var stored = try document()
        var ledger = try stored.rewards ?? RewardLedger(epoch: epoch, startedAt: effectiveNow())
        guard ledger.epoch == epoch, ledger.revision == revision else { throw RewardError.stale }
        let original = ledger
        try change(&ledger)
        guard ledger != original else { return }
        ledger.revision += 1
        stored.rewards = ledger
        try write(stored)
    }

    func reconcileRewards(previous: LearnerDocument, next: inout LearnerDocument) throws {
        let epoch = try learningDataEpoch(), date = try effectiveNow(), day = RewardPolicy.day(date)
        var ledger = next.rewards ?? RewardLedger(epoch: epoch, startedAt: date)
        guard ledger.epoch == epoch else { throw LearnerStorageError.staleVersion }
        let initial = ledger
        for journey in next.lessonJourneys where journey.personalCheck == nil {
            guard let lesson = CurriculumCatalogLoader.bundled.lesson(id: journey.lessonID, version: journey.contentVersion)
                ?? IntroPracticePack.allCases.first(where: { $0.id == journey.lessonID && $0.lesson.contentVersion == journey.contentVersion })?.lesson,
                  lesson.isReady, lesson.objectiveId == journey.objectiveID,
                  AwardFamily.supports(lessonID: lesson.id, version: lesson.contentVersion) else { continue }
            let prior = previous.lessonJourneys.first { $0.id == journey.id }
            for response in journey.responses {
                guard let task = lesson.sessionActivities.first(where: { $0.id == response.activityID && $0.kind == response.kind }), task.kind != "selfReview",
                      response.firstResponseText != nil || response.participatedWithoutText == true || response.recordedPracticeID != nil else { continue }
                let old = prior?.responses.first { $0.activityID == response.activityID }
                let reviewed = response.answerRevealed || (task.kind == "guidedSpeaking" && journey.completedAt != nil)
                let wasReviewed = old?.answerRevealed == true || (task.kind == "guidedSpeaking" && prior?.completedAt != nil)
                guard reviewed && !wasReviewed else { continue }
                let source = "lesson/\(journey.id)/\(task.id)"
                let activity = "\(lesson.id)/\(lesson.contentVersion)/\(task.id)"
                do { try ledger.credit(source: source, activity: activity, kind: "exercise", day: day, now: date) }
                catch RewardError.clockChanged { continue } // Clock anomalies never block learning persistence.
            }
            if journey.completedAt != nil, prior?.completedAt == nil, journey.practiceOrigin != nil {
                let family = ["intro-01-pack-teacher": "AW-TR-01C", "intro-01-pack-grammarian": "AW-TR-02C", "intro-01-pack-journalist": "AW-TR-04C"][journey.lessonID]
                if let family {
                    var verified = try LessonSession.begin(lesson: lesson, presenter: journey.presenter, now: date, existing: journey)
                    verified.journey.completedAt = nil
                    if (try? verified.finish(now: date)) != nil { ledger.award(family, now: date, evidence: [journey.id.uuidString]) }
                }
            }
            if journey.completedAt != nil, prior?.completedAt == nil, journey.practiceOrigin == nil {
                var verified = try LessonSession.begin(lesson: lesson, presenter: journey.presenter, now: date, existing: journey)
                verified.journey.completedAt = nil
                if (try? verified.finish(now: date)) != nil {
                    for task in lesson.sessionActivities where task.kind == "selfReview" {
                        let source = "lesson/\(journey.id)/\(task.id)"
                        if !ledger.transactions.contains(where: { $0.source == source }) {
                            ledger.transactions.append(RewardTransaction(id: "completion/" + source, source: source,
                                activity: "\(lesson.id)/\(lesson.contentVersion)/\(task.id)", day: day, createdAt: date,
                                xp: 0, gold: 0, reason: "Required final self-review completed · included, no extra payout", kind: "completion", multiplier: 0))
                        }
                    }
                    ledger.completePlans(now: date)
                    if journey.objectiveID == "INTRO-01" { ledger.award("AW-P-02", now: date, evidence: [journey.id.uuidString]) }
                    ledger.award("AW-P-03", now: date, evidence: [journey.id.uuidString])
                    let checkpoint = RewardCheckpoint(lessonID: lesson.id, version: lesson.contentVersion, journeyID: journey.id, completedAt: date)
                    if !ledger.checkpoints.contains(where: { $0.lessonID == lesson.id && $0.version == lesson.contentVersion }) { ledger.checkpoints.append(checkpoint) }
                }
            }
        }
        // Explicit rated reviews use the schedule's fresh due opportunity, never a reveal alone.
        let priorIDs = Set(previous.vocabularyRecalls.map(\.id))
        for attempt in next.vocabularyRecalls where !priorIDs.contains(attempt.id) {
            let activity = "sense/\(attempt.itemId)/\(attempt.senseId)"
            let oldCard = previous.reviewCards.first { $0.itemId == attempt.itemId && $0.senseId == attempt.senseId }
            let fresh = oldCard.map { $0.due <= date } ?? true
            do { try ledger.credit(source: "review/\(attempt.sourceEventID ?? attempt.id)", activity: activity, kind: "review", day: day, now: date, freshReview: fresh) }
            catch RewardError.clockChanged { continue }
        }
        AwardEvaluator.evaluate(&ledger, AwardInputs(document: next), now: date)
        if ledger != initial { ledger.revision += 1; next.rewards = ledger }
    }

    /// Turns music, sound effects and haptics on once (2026-10-30); later changes by the learner are kept.
    func applySoundDefaultsOnce() throws {
        let ledger = try rewardLedger()
        guard ledger.settings.soundDefaultsApplied == nil else { return }
        try mutateRewards(epoch: ledger.epoch, revision: ledger.revision) { value in
            value.settings.music = true; value.settings.effects = true; value.settings.haptics = true
            value.settings.soundDefaultsApplied = true
        }
    }

    func setSound(music: Bool? = nil, effects: Bool? = nil, haptics: Bool? = nil) throws {
        let ledger = try rewardLedger()
        try mutateRewards(epoch: ledger.epoch, revision: ledger.revision) { value in
            if let music { value.settings.music = music }
            if let effects { value.settings.effects = effects }
            if let haptics { value.settings.haptics = haptics }
            value.settings.soundDefaultsApplied = true
        }
    }

    /// Records milestones as celebrated so each one is celebrated once.
    func markMilestonesCelebrated(_ ids: [String]) throws {
        let ledger = try rewardLedger()
        try mutateRewards(epoch: ledger.epoch, revision: ledger.revision) { value in
            value.celebratedMilestones = Array(Set(value.celebratedMilestones ?? []).union(ids)).sorted()
        }
    }

    /// Awards badges for work stored before the badge existed (called when the badge screens open).
    func refreshAwards() throws {
        let stored = try document()
        var ledger = try rewardLedger()
        let before = ledger
        AwardEvaluator.evaluate(&ledger, AwardInputs(document: stored), now: try effectiveNow())
        if ledger != before { try write(stored) }   // `write` reconciles and saves the new awards.
    }

    /// Levels the learner opened by passing the jump test. Kept in the learner document; no schema migration.
}

extension AwardInputs {
    init(document: LearnerRepository.LearnerDocument, install: CurriculumInstall = CurriculumCatalogLoader.bundled) {
        let extras = document.speechLab?.extras
        self.init(
            journeys: document.lessonJourneys,
            course: LevelGate.levels.map { (rank: $0, lessons: install.lessons(at: $0).filter(\.isReady)) },
            tracks: install.tracks.tracks,
            watched: extras?.watched ?? [:],
            activities: extras?.activities ?? [],
            legacyFeedback: (document.labFeedback ?? []).map(\.mode),
            customTopicCount: document.customTopics.count,
            wordsInAction: (document.lexicon?.action ?? [:]).values.filter { $0.correctStreak > 0 }.count)
    }
}
