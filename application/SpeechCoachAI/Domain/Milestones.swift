import Foundation

/// A marker on the learner's way: a level reached, a level test passed, a coach stage finished, time spent, words mastered.
/// Milestones are worked out from data the app already keeps, so they need no storage of their own.
struct Milestone: Identifiable, Equatable {
    enum Group: String, CaseIterable, Identifiable {
        case level, test, stage, time, words, videos
        var id: String { rawValue }
        var title: String {
            switch self {
            case .level: "Levels"
            case .test: "Rank tests"
            case .stage: "Coach stages"
            case .time: "Time"
            case .words: "Words"
            case .videos: "Videos"
            }
        }
    }
    var id: String
    var group: Group
    var title: String
    var detail: String
    var achieved: Bool
    var date: Date?
    /// How far along, 0…1 (1 when achieved).
    var progress: Double = 0
}

extension Milestone {
    /// The next unreached milestones, closest first, at most one per group.
    static func upNext(_ all: [Milestone], limit: Int = 3) -> [Milestone] {
        var seen = Set<Group>()
        return all.filter { !$0.achieved }
            .sorted { $0.progress > $1.progress }
            .filter { seen.insert($0.group).inserted }
            .prefix(limit).map { $0 }
    }
}

enum MilestoneBoard {
    static let levels = [2, 5, 10, 15, 20, 30, 40]
    static let hours = [1, 5, 10, 25, 50, 100, 250]
    static let days = [7, 30, 100, 365]
    static let easyWords = [10, 50, 100, 250, 500]
    static let videos = [5, 10, 25, 50, 100]
    static let videoTopics = [1, 5, 14]

    /// All milestones, achieved or not. `easyWords` is the number of Lexicon words the learner rates Easy.
    static func compute(ledger: RewardLedger, passedTests: Set<String>, journeys: [LessonJourney], tracks: TrackCatalog,
                        usage: UsageReport, easyWordCount: Int, watched: [String: Date] = [:]) -> [Milestone] {
        var out: [Milestone] = []

        // Levels, with the day the XP crossed the line.
        let ordered = ledger.transactions.sorted { $0.createdAt < $1.createdAt }
        let xp = ledger.xp
        for level in levels {
            let need = XPLevel.threshold(for: level)
            var running = 0, date: Date?
            for row in ordered { running += row.xp; if running >= need { date = row.createdAt; break } }
            out.append(Milestone(id: "level.\(level)", group: .level, title: "Level \(level)", detail: "\(need) XP",
                                 achieved: xp >= need, date: xp >= need ? date : nil, progress: min(1, Double(xp) / Double(max(1, need)))))
        }

        // Level tests.
        for level in LevelGate.levels.dropFirst() {
            out.append(Milestone(id: "test.\(level)", group: .test, title: "\(level) test passed", detail: "Opens rank \(level) and every rank below",
                                 achieved: passedTests.contains(level), date: nil, progress: passedTests.contains(level) ? 1 : 0))
        }

        // A coach stage is finished when every lesson in it is done.
        for track in tracks.tracks {
            for stage in track.stages where !stage.lessons.isEmpty {
                let finished = stage.lessons.filter { LessonProgress.of($0, journeys: journeys).state == .done }.count
                let done = finished == stage.lessons.count
                let dates = stage.lessons.compactMap { lesson in
                    journeys.filter { $0.lessonID == lesson.id && $0.contentVersion == lesson.contentVersion }.compactMap(\.completedAt).max()
                }
                out.append(Milestone(id: "stage.\(track.id).\(stage.id)", group: .stage, title: "\(track.title) · \(stage.title)",
                                     detail: "\(finished) of \(stage.lessons.count) lessons", achieved: done, date: done ? dates.max() : nil,
                                     progress: min(1, Double(finished) / Double(max(1, stage.lessons.count)))))
            }
        }

        // Time on screen.
        let seconds = usage.allSeconds
        for hour in hours {
            out.append(Milestone(id: "time.\(hour)", group: .time, title: "\(hour) \(hour == 1 ? "hour" : "hours") of practice time",
                                 detail: "Time in the app", achieved: seconds >= hour * 3600, date: nil,
                                 progress: min(1, Double(seconds) / Double(max(1, hour * 3600)))))
        }
        let usedDays = usage.allDaysUsed
        for count in days {
            out.append(Milestone(id: "days.\(count)", group: .time, title: "\(count) days of practice",
                                 detail: "\(min(usedDays, count)) of \(count) days", achieved: usedDays >= count, date: nil,
                                 progress: min(1, Double(usedDays) / Double(max(1, count)))))
        }

        // Words.
        for count in easyWords {
            out.append(Milestone(id: "words.\(count)", group: .words, title: "\(count) words rated Easy",
                                 detail: "\(min(easyWordCount, count)) of \(count) words", achieved: easyWordCount >= count, date: nil,
                                 progress: min(1, Double(easyWordCount) / Double(max(1, count)))))
        }

        // Lab videos (2026-10-31): videos watched and topics with every video watched.
        let seen = LabVideoCatalog.watchedCount(watched)
        let dates = watched.filter { LabVideoCatalog.isValidID($0.key) }.values.sorted()
        for count in videos {
            let done = seen >= count
            out.append(Milestone(id: "videos.\(count)", group: .videos, title: "\(count) videos watched",
                                 detail: "\(min(seen, count)) of \(count) videos", achieved: done,
                                 date: done && dates.count >= count ? dates[count - 1] : nil,
                                 progress: min(1, Double(seen) / Double(max(1, count)))))
        }
        let topicsDone = LabVideoTopic.allCases.filter { topic in
            let list = LabVideoCatalog.videos(for: topic)
            return !list.isEmpty && list.allSatisfy { watched[$0.id] != nil }
        }.count
        for count in videoTopics {
            out.append(Milestone(id: "videoTopics.\(count)", group: .videos,
                                 title: count == 1 ? "A whole video topic" : "\(count) video topics",
                                 detail: "\(min(topicsDone, count)) of \(count) topics fully watched", achieved: topicsDone >= count, date: nil,
                                 progress: min(1, Double(topicsDone) / Double(max(1, count)))))
        }
        return out
    }
}
