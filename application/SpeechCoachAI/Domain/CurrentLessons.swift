import Foundation

/// What Today offers to continue: the learner's place in the CEFR course and in their coach tracks.
/// Replaces the v1 recommendation on Today (owner review 2026-10-26: "Current lesson is not showing up").
struct CurrentLessons: Equatable {
    struct Entry: Equatable, Identifiable {
        var lesson: ResolvedLesson
        /// True when the lesson was started and not finished.
        var resuming: Bool
        /// The coach for a coach-track lesson; nil for a course lesson.
        var coach: TrackCoach?
        /// CEFR rank of a course lesson ("A1"…"C2"); nil for a coach lesson.
        var rank: String?
        var id: String { lesson.id }
    }

    /// The course lesson to open next; nil when every open rank is finished.
    var course: Entry?
    /// Up to two coach lessons: those in progress, else the next lesson of the coach used last.
    var coaches: [Entry]
    /// Words due for review in Daily Training.
    var dueWords: Int

    static let maximumCoaches = 2

    /// - Parameter journeys: saved lesson attempts in the order they were started (oldest first).
    static func make(install: CurriculumInstall, journeys: [LessonJourney], gate: LevelGate, dueWords: Int) -> CurrentLessons {
        CurrentLessons(course: course(install: install, journeys: journeys, gate: gate),
                       coaches: coaches(tracks: install.tracks, journeys: journeys),
                       dueWords: dueWords)
    }

    private static func isFinished(_ lesson: ResolvedLesson, _ journeys: [LessonJourney]) -> Bool {
        journeys.contains { $0.lessonID == lesson.id && $0.completedAt != nil && $0.practiceOrigin == nil }
    }

    private static func course(install: CurriculumInstall, journeys: [LessonJourney], gate: LevelGate) -> Entry? {
        let courseLessons = LevelGate.levels.flatMap { install.lessons(at: $0) }.filter(\.isReady)
        let ids = Set(courseLessons.map(\.id))
        let attempts = journeys.filter { ids.contains($0.lessonID) && $0.practiceOrigin == nil }
        // 1. The course lesson started most recently and not finished.
        for journey in attempts.reversed() where journey.completedAt == nil {
            if let lesson = courseLessons.first(where: { $0.id == journey.lessonID }), !isFinished(lesson, attempts) {
                return Entry(lesson: lesson, resuming: true, coach: nil, rank: lesson.level.uppercased())
            }
        }
        // 2. The first unfinished lesson at the highest open rank, then the ranks below it.
        for rank in gate.unlockedLevels.reversed() {
            let atRank = courseLessons.filter { $0.level.caseInsensitiveCompare(rank) == .orderedSame }
            if let next = atRank.first(where: { !isFinished($0, attempts) }) {
                return Entry(lesson: next, resuming: false, coach: nil, rank: rank)
            }
        }
        return nil
    }

    private static func coaches(tracks: TrackCatalog, journeys: [LessonJourney]) -> [Entry] {
        var trackOf: [String: Track] = [:]
        for track in tracks.tracks { for lesson in track.lessons { trackOf[lesson.id] = track } }
        let attempts = journeys.filter { trackOf[$0.lessonID] != nil && $0.practiceOrigin == nil }
        var entries: [Entry] = []
        for journey in attempts.reversed() where journey.completedAt == nil && entries.count < maximumCoaches {
            guard let track = trackOf[journey.lessonID],
                  let lesson = track.lessons.first(where: { $0.id == journey.lessonID }),
                  !isFinished(lesson, attempts), !entries.contains(where: { $0.id == lesson.id }) else { continue }
            entries.append(Entry(lesson: lesson, resuming: true, coach: track.coach, rank: nil))
        }
        if entries.isEmpty, let last = attempts.last, let track = trackOf[last.lessonID],
           let next = track.lessons.first(where: { !isFinished($0, attempts) }) {
            entries.append(Entry(lesson: next, resuming: false, coach: track.coach, rank: nil))
        }
        return entries
    }
}
