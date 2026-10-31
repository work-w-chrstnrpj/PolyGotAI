import Foundation
import Testing
@testable import SpeechCoachAI

/// v2 badges (2026-10-30): worked out from stored data, so earlier work counts too.
struct AwardEvaluatorTests {
    private let install = CurriculumCatalogLoader.bundled
    private let now = Date(timeIntervalSince1970: 1_792_800_000)

    private func ledger() -> RewardLedger { RewardLedger(epoch: UUID(), startedAt: now) }

    private func inputs(journeys: [LessonJourney] = [], watched: [String: Date] = [:], activities: [LabActivity] = [],
                        feedback: [LabFeedbackMode] = [], topics: Int = 0, action: Int = 0) -> AwardInputs {
        AwardInputs(journeys: journeys, course: LevelGate.levels.map { (rank: $0, lessons: install.lessons(at: $0).filter(\.isReady)) },
                    tracks: install.tracks.tracks, watched: watched, activities: activities, legacyFeedback: feedback,
                    customTopicCount: topics, wordsInAction: action)
    }

    private func finished(_ lesson: ResolvedLesson) -> LessonJourney {
        LessonJourney(id: UUID(), lessonID: lesson.id, objectiveID: lesson.objectiveId, contentVersion: lesson.contentVersion,
                      presenter: "synthetic", currentActivityID: nil, responses: [], completedAt: now)
    }

    private func families(_ value: RewardLedger) -> Set<String> { Set(value.awards.map(\.family)) }
    private func tiers(_ value: RewardLedger, _ family: String) -> [Int] { value.awards.filter { $0.family == family }.compactMap(\.tier).sorted() }

    @Test func everyEvaluatedFamilyIsInTheCatalogAndShown() throws {
        var value = ledger()
        let grammarian = try #require(install.tracks.tracks.first { $0.coach == .grammarian })
        let everyCoach = install.tracks.tracks.flatMap(\.lessons) + LevelGate.levels.flatMap { install.lessons(at: $0) }
        let watched = Dictionary(uniqueKeysWithValues: LabVideoCatalog.all.map { ($0.id, now) })
        let activities = (0..<100).flatMap { _ in
            ["talk.freeTalk", "talk.interview", "timed.writing", "timed.reading", "timed.analogies"].map { LabActivity(id: UUID(), kind: $0, date: now) }
        }
        AwardEvaluator.evaluate(&value, inputs(journeys: everyCoach.map(finished) + grammarian.lessons.map(finished), watched: watched,
                                               activities: activities, topics: 1, action: 100), now: now)
        let catalog = Dictionary(uniqueKeysWithValues: AwardFamily.catalog.map { ($0.id, $0) })
        for family in families(value) {
            let entry = try #require(catalog[family], "\(family) is missing from AwardCatalog.json")
            #expect(entry.isShown(in: value) && entry.availability == "personalUseParticipation", "\(family)")
            if let list = entry.tiers { #expect(tiers(value, family) == list, "\(family) tiers") }
        }
        #expect(families(value).isSuperset(of: ["AW-CR-04", "AW-CR-09", "AW-CR-10", "AW-TK-03", "AW-TK-04", "AW-TK-06", "AW-VD-03", "AW-TT-03"]))
    }

    @Test func coachBadgesNeedEveryLessonOfTheTrack() throws {
        let grammarian = try #require(install.tracks.tracks.first { $0.coach == .grammarian })
        var value = ledger()
        AwardEvaluator.evaluate(&value, inputs(journeys: grammarian.lessons.dropLast().map(finished)), now: now)
        #expect(families(value) == ["AW-TK-01"])
        AwardEvaluator.evaluate(&value, inputs(journeys: grammarian.lessons.map(finished)), now: now)
        #expect(families(value) == ["AW-TK-01", "AW-TK-03", "AW-TK-05"] && tiers(value, "AW-TK-05") == [1])
        // A finished journey of an older version does not count.
        var old = finished(try #require(grammarian.lessons.first)); old.contentVersion = "old"
        var other = ledger()
        AwardEvaluator.evaluate(&other, inputs(journeys: [old]), now: now)
        #expect(other.awards.isEmpty)
    }

    @Test func courseRankBadgeNeedsEveryReadyLessonOfThatRank() {
        let a1 = install.lessons(at: "A1").filter(\.isReady)
        var value = ledger()
        AwardEvaluator.evaluate(&value, inputs(journeys: a1.dropFirst().map(finished)), now: now)
        #expect(!families(value).contains("AW-CR-04"))
        AwardEvaluator.evaluate(&value, inputs(journeys: a1.map(finished)), now: now)
        #expect(families(value).contains("AW-CR-04") && !families(value).contains("AW-CR-10"))
    }

    @Test func talkAndTimedTestsCountTheLogAndFallBackToOldFeedback() {
        var value = ledger()
        let log = (0..<5).map { _ in LabActivity(id: UUID(), kind: "talk.scenario", date: now) } + [LabActivity(id: UUID(), kind: "timed.reading", date: now)]
        AwardEvaluator.evaluate(&value, inputs(activities: log), now: now)
        #expect(families(value) == ["AW-P-06", "AW-CV-01", "AW-TT-01"] && tiers(value, "AW-CV-01") == [5])
        // Before the log existed: saved interview and writing feedback stand in.
        var older = ledger()
        AwardEvaluator.evaluate(&older, inputs(feedback: [.interview, .writing, .coachReview]), now: now)
        #expect(families(older) == ["AW-P-07", "AW-TT-01"])
    }

    @Test func videosAndLexiconAndEarnedBadgesStay() {
        let speaking = LabVideoCatalog.videos(for: .speaking)
        let watched = Dictionary(uniqueKeysWithValues: speaking.map { ($0.id, now) })
        var value = ledger()
        for index in 0..<50 {
            value.transactions.append(RewardTransaction(id: "r\(index)", source: "r\(index)", activity: "sense/\(index)", day: "2026-10-\(10 + index % 7)",
                createdAt: now, xp: 10, gold: 0, reason: "", kind: "review", multiplier: 2))
        }
        AwardEvaluator.evaluate(&value, inputs(watched: watched.merging(["not-a-video": now]) { a, _ in a }, topics: 1, action: 10), now: now)
        let expected: Set<String> = ["AW-VD-01", "AW-VD-03", "AW-LX-01", "AW-LX-02", "AW-LX-05", "AW-LX-06"]
        #expect(families(value) == expected.union(speaking.count >= 10 ? ["AW-VD-02"] : []))
        #expect(tiers(value, "AW-LX-02") == [7])
        // Un-marking the videos later never takes a badge back.
        let count = value.awards.count
        AwardEvaluator.evaluate(&value, inputs(), now: now)
        #expect(value.awards.count == count)
    }

    @Test func theRepositoryAwardsStoredWorkAndOldDocumentsStillOpen() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-AWARDS-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, now: { now }, uptime: { 0 }, protectedDataAvailable: { true })
        let video = LabVideoCatalog.all[0].id
        try repo.setLabVideoWatched(video, true)
        #expect(try repo.rewardLedger().awards.map(\.family).contains("AW-VD-01"), "awarded on the save that marked it")
        try repo.recordLabActivity("timed.analogies", id: UUID())
        try repo.refreshAwards()
        #expect(try repo.rewardLedger().awards.map(\.family).contains("AW-TT-01"))
        #expect(throws: LearnerStorageError.invalidContent) { try repo.recordLabActivity("talk.unknown", id: UUID()) }
        // Old Lab data without the activity log still decodes.
        let old = try JSONDecoder().decode(LabExtrasState.self, from: Data(#"{"watched":{},"fingerprints":{},"recentThemes":{}}"#.utf8))
        #expect(old.activities == nil)
    }
}
