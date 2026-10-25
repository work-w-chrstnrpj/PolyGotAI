import Foundation

/// A marker on the learner's way: a level reached, a level test passed, a coach stage finished, time spent, words mastered.
/// Milestones are worked out from data the app already keeps, so they need no storage of their own.
struct Milestone: Identifiable, Equatable {
    enum Group: String, CaseIterable, Identifiable {
        case level, test, stage, time, words
        var id: String { rawValue }
        var title: String {
            switch self {
            case .level: "Levels"
            case .test: "Level tests"
            case .stage: "Coach stages"
            case .time: "Time"
            case .words: "Words"
            }
        }
    }
    var id: String
    var group: Group
    var title: String
    var detail: String
    var achieved: Bool
    var date: Date?
}

enum MilestoneBoard {
    static let levels = [2, 5, 10, 15, 20, 30, 40]
    static let hours = [1, 5, 10, 25, 50, 100, 250]
    static let days = [7, 30, 100, 365]
    static let easyWords = [10, 50, 100, 250, 500]

    /// All milestones, achieved or not. `easyWords` is the number of Lexicon words the learner rates Easy.
    static func compute(ledger: RewardLedger, passedTests: Set<String>, journeys: [LessonJourney], tracks: TrackCatalog,
                        usage: UsageReport, easyWordCount: Int) -> [Milestone] {
        var out: [Milestone] = []

        // Levels, with the day the XP crossed the line.
        let ordered = ledger.transactions.sorted { $0.createdAt < $1.createdAt }
        let xp = ledger.xp
        for level in levels {
            let need = XPLevel.threshold(for: level)
            var running = 0, date: Date?
            for row in ordered { running += row.xp; if running >= need { date = row.createdAt; break } }
            out.append(Milestone(id: "level.\(level)", group: .level, title: "Level \(level)", detail: "\(need) XP",
                                 achieved: xp >= need, date: xp >= need ? date : nil))
        }

        // Level tests.
        for level in LevelGate.levels.dropFirst() {
            out.append(Milestone(id: "test.\(level)", group: .test, title: "\(level) test passed", detail: "Opens \(level) and every level below",
                                 achieved: passedTests.contains(level), date: nil))
        }

        // A coach stage is finished when every lesson in it is done.
        for track in tracks.tracks {
            for stage in track.stages where !stage.lessons.isEmpty {
                let done = stage.lessons.allSatisfy { LessonProgress.of($0, journeys: journeys).state == .done }
                let dates = stage.lessons.compactMap { lesson in
                    journeys.filter { $0.lessonID == lesson.id && $0.contentVersion == lesson.contentVersion }.compactMap(\.completedAt).max()
                }
                out.append(Milestone(id: "stage.\(track.id).\(stage.id)", group: .stage, title: "\(track.title) · \(stage.title)",
                                     detail: "\(stage.lessons.count) lessons", achieved: done, date: done ? dates.max() : nil))
            }
        }

        // Time on screen.
        let seconds = usage.allSeconds
        for hour in hours {
            out.append(Milestone(id: "time.\(hour)", group: .time, title: "\(hour) \(hour == 1 ? "hour" : "hours") of practice time",
                                 detail: "Screen time in the app", achieved: seconds >= hour * 3600, date: nil))
        }
        let usedDays = usage.allDaysUsed
        for count in days {
            out.append(Milestone(id: "days.\(count)", group: .time, title: "\(count) days of practice",
                                 detail: "Days you used the app for a minute or more", achieved: usedDays >= count, date: nil))
        }

        // Words.
        for count in easyWords {
            out.append(Milestone(id: "words.\(count)", group: .words, title: "\(count) words rated Easy",
                                 detail: "From Daily Training", achieved: easyWordCount >= count, date: nil))
        }
        return out
    }
}
