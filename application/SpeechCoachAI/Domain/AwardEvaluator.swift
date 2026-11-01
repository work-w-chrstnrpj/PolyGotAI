import Foundation

/// What the v2 badges are worked out from. Everything here is already stored, so badges also reach learners who did the work
/// before the badge existed.
struct AwardInputs {
    var journeys: [LessonJourney]
    /// CEFR course lessons by rank, A1 first.
    var course: [(rank: String, lessons: [ResolvedLesson])]
    var tracks: [Track]
    var watched: [String: Date]
    /// Finished Talk conversations and timed tests ("talk.freeTalk", "timed.reading", ...).
    var activities: [LabActivity]
    /// Saved AI feedback modes. Used only before the activity log existed, so older Talk and writing practice still counts.
    var legacyFeedback: [LabFeedbackMode]
    var customTopicCount: Int
    /// Lexicon in Action words answered correctly at least once.
    var wordsInAction: Int
    var enricherRounds = 0
    var perfectRounds = 0
    /// Ranks opened by passing their test.
    var passedTests: Set<String> = []

    /// "lessonID@version" of every finished journey.
    var finished: Set<String> { Set(journeys.filter { $0.completedAt != nil }.map { $0.lessonID + "@" + $0.contentVersion }) }
}

/// v2 badges (2026-10-30). Earned badges are never taken back, even if the learner later un-marks a video.
enum AwardEvaluator {
    static let conversationTiers = [5, 10, 25, 50]
    static let interviewTiers = [5, 10, 25]
    static let reviewTiers = [50, 250, 1_000, 5_000]
    static let lexiconDayTiers = [7, 30, 100]
    static let actionTiers = [10, 50, 100]
    static let coachTiers = [1, 3, 6, 11]
    static let videoTiers = [10, 25, 50, 100]
    static let topicTiers = [1, 5, 14]
    static let timedTiers = [5, 25, 100]
    static let enricherTiers = [1, 10, 50]
    static let perfectTiers = [1, 10, 25]
    /// Each current lesson needs a completed attempt at this first-try exercise accuracy.
    static let coachExamPassingAccuracy = 0.8
    static let coachExamFamilies: [TrackCoach: String] = [
        .grammarian: "AW-TK-07", .pronunciation: "AW-TK-08", .readingListening: "AW-TK-09",
        .debater: "AW-TK-10", .negotiator: "AW-TK-11", .publicSpeaker: "AW-TK-12",
        .journalist: "AW-TK-13", .creativeWriter: "AW-TK-14", .business: "AW-TK-15",
        .storyteller: "AW-TK-16", .copywriter: "AW-TK-17"
    ]
    /// Course rank → badge family.
    static let courseFamilies = ["A1": "AW-CR-04", "A2": "AW-CR-05", "B1": "AW-CR-06", "B2": "AW-CR-07", "C1": "AW-CR-08", "C2": "AW-CR-09"]

    static func evaluate(_ ledger: inout RewardLedger, _ inputs: AwardInputs, now: Date) {
        talk(&ledger, inputs, now: now)
        course(&ledger, inputs, now: now)
        coaches(&ledger, inputs, now: now)
        lexicon(&ledger, inputs, now: now)
        videos(&ledger, inputs, now: now)
        timedTests(&ledger, inputs, now: now)
    }

    private static func tiers(_ family: String, _ list: [Int], count: Int, _ ledger: inout RewardLedger, now: Date, evidence: [String]) {
        for tier in list where count >= tier { ledger.award(family, tier: tier, now: now, evidence: evidence) }
    }

    /// Counts of one kind of finished activity; the old feedback history stands in until the log has any rows.
    private static func count(_ kinds: Set<String>, legacy: Set<LabFeedbackMode>, _ inputs: AwardInputs) -> Int {
        if !inputs.activities.isEmpty { return inputs.activities.filter { kinds.contains($0.kind) }.count }
        return inputs.legacyFeedback.filter(legacy.contains).count
    }

    private static func talk(_ ledger: inout RewardLedger, _ inputs: AwardInputs, now: Date) {
        let conversations = count(["talk.freeTalk", "talk.scenario"], legacy: [.conversation], inputs)
        let interviews = count(["talk.interview"], legacy: [.interview], inputs)
        if conversations > 0 { ledger.award("AW-P-06", now: now, evidence: ["talk"]) }
        if interviews > 0 { ledger.award("AW-P-07", now: now, evidence: ["talk.interview"]) }
        tiers("AW-CV-01", conversationTiers, count: conversations, &ledger, now: now, evidence: ["talk"])
        tiers("AW-IV-01", interviewTiers, count: interviews, &ledger, now: now, evidence: ["talk.interview"])
    }

    /// Same rule as `LessonProgress.of` (a finished journey of the current version) without rebuilding the session,
    /// because this runs on every save.
    private static func done(_ lesson: ResolvedLesson, _ finished: Set<String>) -> Bool {
        finished.contains(lesson.id + "@" + lesson.contentVersion)
    }

    private static func course(_ ledger: inout RewardLedger, _ inputs: AwardInputs, now: Date) {
        let finished = inputs.finished
        var finishedRanks = 0
        for (rank, lessons) in inputs.course where !lessons.isEmpty && lessons.allSatisfy({ done($0, finished) }) {
            finishedRanks += 1
            if let family = courseFamilies[rank] { ledger.award(family, now: now, evidence: lessons.map(\.id)) }
        }
        if !inputs.passedTests.isEmpty { ledger.award("AW-CR-11", now: now, evidence: inputs.passedTests.sorted()) }
        if finishedRanks == courseFamilies.count { ledger.award("AW-CR-10", now: now, evidence: Array(courseFamilies.keys).sorted()) }
    }

    private static func coaches(_ ledger: inout RewardLedger, _ inputs: AwardInputs, now: Date) {
        let finishedLessons = inputs.finished
        let examJourneys = Dictionary(grouping: inputs.journeys.filter {
            $0.completedAt != nil && $0.practiceOrigin == nil && $0.practiceConditions == nil && $0.personalCheck == nil
        }, by: { $0.lessonID + "@" + $0.contentVersion })
        var finished: [String] = []
        var started = 0
        for track in inputs.tracks where !track.lessons.isEmpty {
            let doneCount = track.lessons.filter { done($0, finishedLessons) }.count
            if doneCount > 0 { started += 1 }
            guard doneCount == track.lessons.count else { continue }
            finished.append(track.id)
            if track.coach == .grammarian { ledger.award("AW-TK-03", now: now, evidence: [track.id]) }
            if track.coach == .pronunciation { ledger.award("AW-TK-04", now: now, evidence: [track.id]) }
            if let family = coachExamFamilies[track.coach], !ledger.awards.contains(where: { $0.family == family }) {
                let evidence = track.lessons.compactMap { lesson -> String? in
                    let key = lesson.id + "@" + lesson.contentVersion
                    guard let attempt = examJourneys[key]?.first(where: { passesCoachExam(lesson, journey: $0, now: now) }) else { return nil }
                    return key + "/" + attempt.id.uuidString
                }
                if evidence.count == track.lessons.count { ledger.award(family, now: now, evidence: evidence) }
            }
        }
        if started > 0 { ledger.award("AW-TK-01", now: now, evidence: ["coach"]) }
        tiers("AW-TK-05", coachTiers, count: finished.count, &ledger, now: now, evidence: finished)
        if !inputs.tracks.isEmpty, started == inputs.tracks.count { ledger.award("AW-TK-06", now: now, evidence: inputs.tracks.map(\.id)) }
    }

    /// Reuses the score shown by the lesson player. Partial results, open-only lessons and a corrected retry within
    /// the same attempt cannot turn a missing/low exam score into a pass. A separate completed retake can qualify.
    private static func passesCoachExam(_ lesson: ResolvedLesson, journey: LessonJourney, now: Date) -> Bool {
        guard var session = try? LessonSession.begin(lesson: lesson, presenter: journey.presenter, now: now, existing: journey) else { return false }
        let checked = session.activities.filter { $0.exercise != nil && $0.resolvedExercise.isChecked }
        guard !checked.isEmpty, session.exerciseResults.count == checked.count,
              checked.allSatisfy({ session.response(for: $0.id)?.kind == $0.kind }),
              let accuracy = session.exerciseAccuracy, accuracy >= coachExamPassingAccuracy else { return false }
        session.journey.completedAt = nil
        return (try? session.finish(now: now)) != nil
    }

    private static func lexicon(_ ledger: inout RewardLedger, _ inputs: AwardInputs, now: Date) {
        let reviews = ledger.transactions.filter { $0.kind == "review" }
        tiers("AW-LX-01", reviewTiers, count: reviews.count, &ledger, now: now, evidence: ["review"])
        tiers("AW-LX-02", lexiconDayTiers, count: Set(reviews.map(\.day)).count, &ledger, now: now, evidence: ["review"])
        if inputs.customTopicCount > 0 { ledger.award("AW-LX-05", now: now, evidence: ["topic"]) }
        tiers("AW-LX-06", actionTiers, count: inputs.wordsInAction, &ledger, now: now, evidence: ["action"])
        tiers("AW-LX-07", enricherTiers, count: inputs.enricherRounds, &ledger, now: now, evidence: ["enricher"])
        tiers("AW-LX-08", perfectTiers, count: inputs.perfectRounds, &ledger, now: now, evidence: ["practice"])
    }

    private static func videos(_ ledger: inout RewardLedger, _ inputs: AwardInputs, now: Date) {
        let watched = LabVideoCatalog.watchedCount(inputs.watched)
        if watched > 0 { ledger.award("AW-VD-01", now: now, evidence: ["video"]) }
        tiers("AW-VD-02", videoTiers, count: watched, &ledger, now: now, evidence: ["video"])
        let topics = LabVideoTopic.allCases.filter { topic in
            let list = LabVideoCatalog.videos(for: topic)
            return !list.isEmpty && list.allSatisfy { inputs.watched[$0.id] != nil }
        }
        tiers("AW-VD-03", topicTiers, count: topics.count, &ledger, now: now, evidence: topics.map(\.rawValue))
    }

    private static func timedTests(_ ledger: inout RewardLedger, _ inputs: AwardInputs, now: Date) {
        var kinds = Set(inputs.activities.map(\.kind).filter { $0.hasPrefix("timed.") })
        var total = inputs.activities.filter { $0.kind.hasPrefix("timed.") }.count
        if inputs.activities.isEmpty, inputs.legacyFeedback.contains(.writing) {
            kinds.insert("timed.writing"); total = inputs.legacyFeedback.filter { $0 == .writing }.count
        }
        if total > 0 { ledger.award("AW-TT-01", now: now, evidence: ["timed"]) }
        tiers("AW-TT-02", timedTiers, count: total, &ledger, now: now, evidence: ["timed"])
        if kinds.count == TimedTestKind.allCases.count { ledger.award("AW-TT-03", now: now, evidence: kinds.sorted()) }
    }
}
