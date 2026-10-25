import Foundation

/// Session choices never write learner defaults or replace curriculum/objective identity.
struct PracticeSessionContext: Equatable, Identifiable {
    let id: UUID
    let sourceLessonID: String?
    let objectiveID: String?
    let baseline: LearnerPreferences
    var coachOverride: LearnerPreferences.Coach?
    var quietPractice = false
    var sourceLessonJourneyID: UUID? = nil
    var provenance: SpeakingProvenance? = nil
    var promptOverride: PromptSnapshot? = nil

    init(id: UUID = UUID(), defaults: LearnerPreferences, sourceLessonID: String? = nil, objectiveID: String? = nil) {
        self.id = id; baseline = defaults; self.sourceLessonID = sourceLessonID; self.objectiveID = objectiveID
    }
    var effectivePreferences: LearnerPreferences {
        var value = baseline; value.coach = effectiveCoach; return value
    }
    var effectiveCoach: LearnerPreferences.Coach { coachOverride ?? baseline.coach }
}

/// Frozen attribution for an explicit practice entry; cosmetic coach choices do not rewrite it.
struct SpeakingProvenance: Codable, Equatable {
    var journeyID: UUID
    var activityID: String
    var sourceCourseJourneyID: UUID
    var sourceCourseLessonID: String
    var primaryObjectiveID: String
    var specialtyObjectiveID: String?
    var role: String
    var method: String
    var packID: String
    var packVersion: String
    var purpose: String
    var supported: Bool
    var communicationSource: CommunicationSource? = nil
}

extension PracticeSessionContext {
    static func recovering(_ attempt: AttemptSnapshot, defaults: LearnerPreferences) -> PracticeSessionContext {
        var result = PracticeSessionContext(id: attempt.practiceSessionID ?? UUID(),
            defaults: attempt.preferences ?? defaults, sourceLessonID: attempt.sourceLessonID,
            objectiveID: attempt.prompt.objectiveID)
        result.sourceLessonJourneyID = attempt.sourceLessonJourneyID
        result.provenance = attempt.speakingProvenance
        result.promptOverride = attempt.prompt
        return result
    }
}

/// Personal checks collect evidence, never automatic proficiency or retention judgments.
enum IntroCheckKind: String, Codable, CaseIterable, Identifiable {
    case baseline, transferNeighbor, transferClass, day7, day28
    var id: String { rawValue }
    var title: String {
        switch self {
        case .baseline: "Introduction baseline"
        case .transferNeighbor: "New situation: neighbor"
        case .transferClass: "New situation: classmate"
        case .day7: "Day 7 recall"
        case .day28: "Day 28 recall"
        }
    }
    var prompts: [String] {
        switch self {
        case .baseline: ["Introduce yourself to someone new. Give a chosen name, your work, study or daily role, and one interest. Fictional details are welcome.", "What do you like to do in your free time?"]
        case .transferNeighbor: ["You meet a new neighbor at the door. Give your name, what you do, and one interest.", "What do you do in the evening?"]
        case .transferClass: ["You sit next to a new classmate. Give your name, what you study or your daily role, and one interest.", "Where are you from?"]
        case .day7: ["You are signing up for a class. Write one sentence that gives your chosen name.", "A form asks for your home city or country. Write one sentence.", "A neighbor asks about your studies or your daily role. Write one sentence.", "A classmate asks what you enjoy doing. Write one sentence.", "The class starts and you meet the person beside you. Write one polite first line."]
        case .day28: ["You join a walking group. Write one sentence that tells the group your chosen name.", "The leader asks where you come from. Write one sentence.", "Someone asks about your study or your daily work. Write one sentence.", "Someone asks what you like to do on a free day. Write one sentence.", "You meet the leader for the first time. Write one polite line."]
        }
    }
    var window: ClosedRange<Double>? {
        switch self { case .day7: 5...9; case .day28: 25...31; default: nil }
    }
}

struct IntroCheckSnapshot: Codable, Equatable {
    var kind: IntroCheckKind
    var purpose: String
    var startedAt: Date
    var teachingBeganAt: Date?
    var priorExposure: Bool
    var supported: Bool
    var prompts: [String]
    var retainedText: Bool
    var completedItems: [Int]
    var selfReviewCompleted: Bool
    var interveningPractice: String
    var modalities: [String: String]? = nil
    var preparation: String = "Self-paced; no preparation timer"
    var rubricVersion: String = "INTRO-01-personal-draft-1"
    var sourceContentVersion: String? = nil
    var teachingMayHaveBeenSeen: Bool? = nil

    var timingDescription: String {
        guard let window = kind.window else { return "No delayed timing window for this check." }
        guard let teachingBeganAt else { return "Initial teaching date unavailable; timing is not verified." }
        let days = startedAt.timeIntervalSince(teachingBeganAt) / 86_400
        guard days.isFinite, days >= 0 else { return "Clock inconsistency; timing is not verified." }
        return String(format: "%.1f days after teaching · %@", days,
            window.contains(days) ? "within the planned window" : "outside the planned window")
    }

    static func begin(kind: IntroCheckKind, course: LessonJourney, previous: [LessonJourney], now: Date,
                      supported: Bool, retainedText: Bool, interveningPractice: String) -> IntroCheckSnapshot {
        let seen = previous.contains { $0.personalCheck?.kind == kind }
        var snapshot = IntroCheckSnapshot(kind: kind, purpose: kind == .baseline ? (seen ? "repeatedBaseline" : "baseline") : (kind.window == nil ? "transfer" : "delayedRecall"),
            startedAt: now, teachingBeganAt: course.teachingBeganAt, priorExposure: seen,
            supported: supported, prompts: kind.prompts, retainedText: retainedText, completedItems: [],
            selfReviewCompleted: false, interveningPractice: interveningPractice)
        snapshot.sourceContentVersion = course.contentVersion
        snapshot.teachingMayHaveBeenSeen = course.teachingBeganAt != nil || !course.responses.isEmpty || !(course.drafts ?? [:]).isEmpty
        return snapshot
    }

    func lesson() -> ResolvedLesson {
        ResolvedLesson(id: "intro-01-check-\(kind.rawValue)", level: "A1", title: kind.title,
            objectiveId: "INTRO-01", contentVersion: rubricVersion, availability: .ready,
            practiceActivities: prompts.enumerated().map {
                CurriculumActivity(id: "check-\($0.offset)", kind: "personalCheck", required: true, prompt: $0.element)
            })
    }
}
