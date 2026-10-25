import Foundation

/// The ten coach tracks of the Lesson tab. The Teacher hosts the CEFR course and is not one of them.
/// `artwork` names an asset when final art exists; otherwise `symbol` (an SF Symbol) stands in.
enum TrackCoach: String, Codable, CaseIterable, Identifiable {
    case grammarian, readingListening, debater, negotiator, publicSpeaker
    case journalist, creativeWriter, business, storyteller, copywriter

    var id: String { rawValue }

    var title: String {
        switch self {
        case .grammarian: "Grammarian"
        case .readingListening: "Reading & Listening"
        case .debater: "Debater & Argument"
        case .negotiator: "Persuasion & Negotiation"
        case .publicSpeaker: "Public Speaking & Rhetoric"
        case .journalist: "Journalist"
        case .creativeWriter: "Creative Writing"
        case .business: "Business & Professional"
        case .storyteller: "Storytelling"
        case .copywriter: "Advertising & Copywriting"
        }
    }

    /// One line, so it never wraps on a card.
    var tagline: String {
        switch self {
        case .grammarian: "Build accurate sentences"
        case .readingListening: "Read and listen closely"
        case .debater: "Argue clearly and fairly"
        case .negotiator: "Persuade and agree"
        case .publicSpeaker: "Speak with impact"
        case .journalist: "Ask, check, report"
        case .creativeWriter: "Write vivid stories"
        case .business: "Speak well at work"
        case .storyteller: "Tell stories that land"
        case .copywriter: "Write words that sell"
        }
    }

    /// Asset-catalog image name, or nil while art is pending.
    var artwork: String? {
        switch self {
        case .grammarian: "CoachGrammarian"
        case .readingListening: "CoachLibrarian"
        case .publicSpeaker: "CoachSpeaker"
        case .journalist: "CoachJournalist"
        case .business: "CoachBusiness"
        case .debater, .negotiator, .creativeWriter, .storyteller, .copywriter: nil
        }
    }

    /// Placeholder icon for coaches without final art.
    var symbol: String {
        switch self {
        case .grammarian: "text.book.closed"
        case .readingListening: "book"
        case .debater: "scale.3d"
        case .negotiator: "arrow.left.arrow.right"
        case .publicSpeaker: "mic"
        case .journalist: "newspaper"
        case .creativeWriter: "pencil.and.scribble"
        case .business: "briefcase"
        case .storyteller: "book.pages"
        case .copywriter: "text.quote"
        }
    }
}

// MARK: Stored definition (the "track" object in Resources/Tracks/track-*.json)

struct TrackDefinition: Codable, Equatable {
    struct Unit: Codable, Equatable { var id: String; var title: String }
    struct Stage: Codable, Equatable { var id: String; var title: String; var units: [Unit] }
    var id: String
    var coach: String
    var stages: [Stage]
}

// MARK: Resolved tree for screens

struct TrackUnit: Equatable, Identifiable {
    var id: String
    var title: String
    var lessons: [ResolvedLesson]
}

struct TrackStage: Equatable, Identifiable {
    var id: String
    var title: String
    var units: [TrackUnit]
    var lessons: [ResolvedLesson] { units.flatMap(\.lessons) }
}

struct Track: Equatable, Identifiable {
    var id: String
    var coach: TrackCoach
    var stages: [TrackStage]
    var title: String { coach.title }
    var tagline: String { coach.tagline }
    var lessons: [ResolvedLesson] { stages.flatMap(\.lessons) }

    /// Share of this track's lessons the learner has finished, 0...1 (drives the card's progress ring).
    func completedFraction(journeys: [LessonJourney]) -> Double {
        let all = lessons
        guard !all.isEmpty else { return 0 }
        let done = all.filter { LessonProgress.of($0, journeys: journeys).state == .done }.count
        return Double(done) / Double(all.count)
    }

    /// The lesson started but not finished, most recently saved last.
    func lessonInProgress(journeys: [LessonJourney]) -> ResolvedLesson? {
        let open = Set(journeys.filter { $0.completedAt == nil }.map(\.lessonID))
        return lessons.last { open.contains($0.id) }
    }
}

struct TrackCatalog: Equatable {
    /// Only coaches that have at least one ready lesson, in `TrackCoach` order.
    var tracks: [Track] = []
    var problem: String?

    var lessons: [ResolvedLesson] { tracks.flatMap(\.lessons) }

    func track(id: String) -> Track? { tracks.first { $0.id == id } }

    /// The "Continue" card: the unfinished coach lesson, if any.
    func continueLesson(journeys: [LessonJourney]) -> (track: Track, lesson: ResolvedLesson)? {
        for track in tracks {
            if let lesson = track.lessonInProgress(journeys: journeys) { return (track, lesson) }
        }
        return nil
    }

    /// Joins a definition to its resolved lessons by `trackId` and `unitId`. Units and stages without a ready lesson are dropped.
    static func resolve(definitions: [TrackDefinition], lessons: [ResolvedLesson]) -> TrackCatalog {
        let ready = lessons.filter(\.isReady)
        let tracks: [Track] = definitions.compactMap { definition in
            guard let coach = TrackCoach(rawValue: definition.coach) else { return nil }
            let stages: [TrackStage] = definition.stages.compactMap { stage in
                let units: [TrackUnit] = stage.units.compactMap { unit in
                    let inUnit = ready.filter { $0.trackId == definition.id && $0.unitId == unit.id }
                    return inUnit.isEmpty ? nil : TrackUnit(id: unit.id, title: unit.title, lessons: inUnit)
                }
                return units.isEmpty ? nil : TrackStage(id: stage.id, title: stage.title, units: units)
            }
            return stages.isEmpty ? nil : Track(id: definition.id, coach: coach, stages: stages)
        }
        let order = Dictionary(uniqueKeysWithValues: TrackCoach.allCases.enumerated().map { ($1, $0) })
        return TrackCatalog(tracks: tracks.sorted { (order[$0.coach] ?? 0) < (order[$1.coach] ?? 0) })
    }
}

// MARK: Lesson state for rows (shared by Course and Coaches)

struct LessonProgress: Equatable {
    enum State: Equatable { case new, inProgress, done }
    var state: State
    /// Weighted first-try accuracy of the checked exercises, when any were answered.
    var accuracy: Double?

    static func of(_ lesson: ResolvedLesson, journeys: [LessonJourney]) -> LessonProgress {
        let mine = journeys.filter { $0.lessonID == lesson.id }
        guard !mine.isEmpty else { return LessonProgress(state: .new, accuracy: nil) }
        let finished = mine.last { $0.completedAt != nil && $0.contentVersion == lesson.contentVersion }
        let journey = finished ?? mine.last { $0.contentVersion == lesson.contentVersion }
        let accuracy = journey.flatMap { saved in
            (try? LessonSession.begin(lesson: lesson, presenter: "", now: Date(), existing: saved))?.exerciseAccuracy
        }
        return LessonProgress(state: finished != nil ? .done : .inProgress, accuracy: accuracy)
    }
}
