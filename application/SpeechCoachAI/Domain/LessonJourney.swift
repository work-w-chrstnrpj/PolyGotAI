import Foundation

/// One local lesson attempt. It stores the learner's responses, not a copy of the reviewed answers.
struct LessonJourney: Codable, Equatable, Identifiable {
    var id: UUID
    var lessonID: String
    var objectiveID: String
    var contentVersion: String
    var presenter: String
    var currentActivityID: String?
    var responses: [LessonResponse]
    var completedAt: Date?
    /// Unsubmitted text and navigation survive leaving a lesson; neither earns completion.
    var drafts: [String: String]? = nil
    /// Separate optional practice cites its course without completing or replacing it.
    var practiceOrigin: LessonPracticeOrigin? = nil
    var teachingBeganAt: Date? = nil
    var personalCheck: IntroCheckSnapshot? = nil
    var practiceConditions: CurriculumPracticeConditions? = nil
}

/// Frozen conditions for optional topic practice; never substitutes for the source course result.
struct CurriculumPracticeConditions: Codable, Equatable {
    var purpose: String
    var sourceContentVersion: String
    var startedAt: Date
    var teachingBeganAt: Date?
    var supported: Bool
    var retainedText: Bool
    var teachingMayHaveBeenSeen: Bool? = nil
    var rubricVersion: String? = nil

    var timingDescription: String {
        guard let teachingBeganAt else { return "Teaching date unavailable; delay is not verified." }
        let days = startedAt.timeIntervalSince(teachingBeganAt) / 86_400
        guard days.isFinite, days >= 0 else { return "Clock inconsistency; delay is not verified." }
        return String(format: "%.1f days after teaching. No learning assessment has been made.", days)
    }
}

struct LessonPracticeOrigin: Codable, Equatable {
    var journeyID: UUID
    var lessonID: String
    var objectiveID: String
    var activityID: String?
}

struct LessonResponse: Codable, Equatable, Identifiable {
    var id: String { activityID }
    var activityID: String
    var kind: String
    /// speaking, listening, or text. Quiet practice stays text evidence.
    var modality: String
    var unaidedText: String?
    var assistedText: String?
    var answerRevealed = false
    /// Keeps the first supported response too; assistedText may hold later retries.
    var firstResponseText: String? = nil
    /// A completed local recording/self-review is participation, not an acoustic assessment.
    var recordedPracticeID: UUID? = nil
    /// An explicit local participation event without retaining the learner's written response.
    var participatedWithoutText: Bool? = nil
    var attemptWasSupported: Bool? = nil
}

enum LessonProgressError: Error, Equatable {
    case unknownActivity
    case invalidResponse
    case answerStillHidden
    case answerNotInPack
    case versionMismatch
    case objectiveMismatch
    case unfinished
    case alreadyComplete
}

struct LessonSession: Equatable {
    var journey: LessonJourney
    var activities: [CurriculumActivity]

    static func begin(lesson: ResolvedLesson, presenter: String, now: Date, existing: LessonJourney? = nil) throws -> LessonSession {
        guard lesson.isReady else { throw LessonProgressError.unfinished }
        let activities = lesson.sessionActivities
        if let existing {
            guard existing.lessonID == lesson.id else { throw LessonProgressError.unknownActivity }
            guard existing.objectiveID == lesson.objectiveId else { throw LessonProgressError.objectiveMismatch }
            guard existing.contentVersion == lesson.contentVersion else { throw LessonProgressError.versionMismatch }
            var continued = existing
            continued.presenter = presenter
            // The previous player accepted typed input only. Repair its misleading speaking label.
            for index in continued.responses.indices where continued.responses[index].kind == "guidedSpeaking" && continued.responses[index].recordedPracticeID == nil {
                continued.responses[index].modality = "text"
            }
            return LessonSession(journey: continued, activities: activities)
        }
        let journey = LessonJourney(
            id: UUID(), lessonID: lesson.id, objectiveID: lesson.objectiveId, contentVersion: lesson.contentVersion,
            presenter: presenter, currentActivityID: activities.first?.id, responses: [], completedAt: nil)
        return LessonSession(journey: journey, activities: activities)
    }

    func response(for activityID: String) -> LessonResponse? {
        journey.responses.first { $0.activityID == activityID }
    }

    func hasAttempt(for activityID: String) -> Bool {
        guard let response = response(for: activityID) else { return false }
        return response.unaidedText != nil || response.assistedText != nil || response.recordedPracticeID != nil || response.participatedWithoutText == true
    }

    mutating func recordWithoutText(activityID: String) throws {
        guard journey.completedAt == nil else { throw LessonProgressError.alreadyComplete }
        guard let conditions = journey.practiceConditions, !conditions.retainedText,
              let activity = activities.first(where: { $0.id == activityID }) else { throw LessonProgressError.invalidResponse }
        guard !journey.responses.contains(where: { $0.activityID == activityID }) else { return }
        journey.responses.append(LessonResponse(activityID: activityID, kind: activity.kind, modality: "text",
            participatedWithoutText: true, attemptWasSupported: conditions.supported))
        journey.drafts?.removeValue(forKey: activityID)
    }

    mutating func recordSpeakingPractice(activityID: String, completionID: UUID) throws {
        guard journey.completedAt == nil else { throw LessonProgressError.alreadyComplete }
        guard let activity = activities.first(where: { $0.id == activityID && $0.kind == "guidedSpeaking" }) else { throw LessonProgressError.unknownActivity }
        if let index = journey.responses.firstIndex(where: { $0.activityID == activityID }) {
            journey.responses[index].recordedPracticeID = completionID
        } else {
            journey.responses.append(LessonResponse(activityID: activityID, kind: activity.kind, modality: "speaking", recordedPracticeID: completionID))
        }
    }

    mutating func move(to activityID: String) throws {
        guard activities.contains(where: { $0.id == activityID }) else { throw LessonProgressError.unknownActivity }
        journey.currentActivityID = activityID
    }

    mutating func saveDraft(_ text: String, for activityID: String) throws {
        guard activities.contains(where: { $0.id == activityID }) else { throw LessonProgressError.unknownActivity }
        guard journey.practiceConditions?.retainedText != false else { return }
        guard text.unicodeScalars.count <= 12_000 else { throw LessonProgressError.invalidResponse }
        var drafts = journey.drafts ?? [:]
        drafts[activityID] = text
        journey.drafts = drafts
    }

    mutating func record(activityID: String, text: String, assisted: Bool) throws {
        guard journey.completedAt == nil else { throw LessonProgressError.alreadyComplete }
        guard let activity = activities.first(where: { $0.id == activityID }) else { throw LessonProgressError.unknownActivity }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.unicodeScalars.count <= 12_000 else { throw LessonProgressError.invalidResponse }
        if journey.practiceConditions?.retainedText == false {
            try recordWithoutText(activityID: activityID)
            return
        }
        let assisted = assisted || journey.practiceConditions?.supported == true
        journey.currentActivityID = activityID
        guard let index = journey.responses.firstIndex(where: { $0.activityID == activityID }) else {
            journey.responses.append(LessonResponse(
                activityID: activityID, kind: activity.kind, modality: Self.modality(for: activity.kind),
                unaidedText: assisted ? nil : trimmed, assistedText: assisted ? trimmed : nil, firstResponseText: trimmed))
            return
        }
        if journey.responses[index].firstResponseText == nil {
            journey.responses[index].firstResponseText = journey.responses[index].unaidedText ?? journey.responses[index].assistedText
        }
        journey.responses[index].modality = Self.modality(for: activity.kind)
        if assisted || journey.responses[index].answerRevealed || journey.responses[index].assistedText != nil {
            journey.responses[index].assistedText = trimmed
        } else if journey.responses[index].unaidedText == nil {
            journey.responses[index].unaidedText = trimmed
        }
    }

    mutating func revealAnswer(activityID: String) throws -> String {
        guard let activity = activities.first(where: { $0.id == activityID }) else { throw LessonProgressError.unknownActivity }
        guard let index = journey.responses.firstIndex(where: { $0.activityID == activityID }),
              hasAttempt(for: activityID) else { throw LessonProgressError.answerStillHidden }
        let answer = activity.answer?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !answer.isEmpty else { throw LessonProgressError.answerNotInPack }
        journey.responses[index].answerRevealed = true
        return answer
    }

    /// INTRO v4 compares every unscored comprehension/grammar/recall attempt without an accuracy gate.
    /// Earlier content keeps its original completion contract.
    func needsComparison(_ activityID: String) -> Bool {
        guard journey.lessonID == "intro-01", journey.contentVersion == "4",
              let activity = activities.first(where: { $0.id == activityID }), activity.required,
              ["reading", "listening", "grammar", "recall"].contains(activity.kind),
              let response = response(for: activityID) else { return false }
        return !response.answerRevealed
    }

    mutating func finish(now: Date) throws {
        guard journey.completedAt == nil else { return }
        let required = activities.filter { $0.required && $0.withheldFromPractice != true }
        let attempted = Set(journey.responses.filter { $0.unaidedText != nil || $0.assistedText != nil || $0.recordedPracticeID != nil || $0.participatedWithoutText == true }.map(\.activityID))
        guard !required.isEmpty, required.allSatisfy({ attempted.contains($0.id) }) else { throw LessonProgressError.unfinished }
        guard !required.contains(where: { needsComparison($0.id) }) else { throw LessonProgressError.unfinished }
        journey.completedAt = now
    }

    private static func modality(for kind: String) -> String {
        switch kind {
        case CurriculumActivityKind.guidedSpeaking.rawValue: "text"
        case CurriculumActivityKind.listening.rawValue: "listening"
        case CurriculumActivityKind.quietText.rawValue: "text"
        default: "text"
        }
    }
}

extension LessonSession {
    mutating func recordPersonalCheck(text: String, speakingID: UUID? = nil) throws {
        guard journey.completedAt == nil, var frozen = journey.personalCheck,
              let id = journey.currentActivityID,
              let index = Int(id.replacingOccurrences(of: "check-", with: "")),
              frozen.prompts.indices.contains(index), !frozen.completedItems.contains(index) else {
            throw LessonProgressError.unknownActivity
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard speakingID != nil || (!trimmed.isEmpty && trimmed.unicodeScalars.count <= 12_000) else {
            throw LessonProgressError.invalidResponse
        }
        if let speakingID {
            journey.responses.append(LessonResponse(activityID: id, kind: "personalCheck", modality: "speaking", recordedPracticeID: speakingID))
        } else if frozen.retainedText {
            try record(activityID: id, text: trimmed, assisted: frozen.supported)
        }
        frozen.completedItems.append(index)
        var modalities = frozen.modalities ?? [:]; modalities[id] = speakingID == nil ? "text" : "speaking"
        frozen.modalities = modalities
        journey.drafts?.removeValue(forKey: id)
        journey.personalCheck = frozen
        journey.currentActivityID = "check-\(index + 1)"
    }

    mutating func finishPersonalCheck(now: Date) throws {
        guard var frozen = journey.personalCheck,
              Set(frozen.completedItems) == Set(frozen.prompts.indices) else { throw LessonProgressError.unfinished }
        guard journey.completedAt == nil else { return }
        frozen.selfReviewCompleted = true
        journey.personalCheck = frozen; journey.completedAt = now
    }
}

/// Optional routes use the same player and repository, with separate source-linked journeys.
enum CurriculumPracticeKind: String, CaseIterable, Identifiable {
    case concepts, pronunciation, workplace, baseline, transfer, day7, day28
    var id: String { rawValue }
    var title: String {
        switch self {
        case .concepts: "Notice how English works"
        case .pronunciation: "Listen and self-review"
        case .workplace: "Try it at work"
        case .baseline: "First check"
        case .transfer: "Try an unfamiliar situation"
        case .day7: "Day 7 check"
        case .day28: "Day 28 check"
        }
    }

    func lesson(from source: ResolvedLesson) -> ResolvedLesson? {
        guard source.isReady, let supplement = source.supplement else { return nil }
        let items: [CurriculumActivity]
        switch self {
        case .concepts: items = supplement.concepts
        case .pronunciation:
            items = Array(source.practiceActivities.filter { $0.kind == "listening" }.prefix(1)) + [CurriculumActivity(id: "pronunciation-self-review", kind: "selfReview", required: true,
                prompt: supplement.pronunciation, answer: "Record what you noticed; no pronunciation grade is assigned.")]
        case .workplace:
            items = [CurriculumActivity(id: "workplace-response", kind: "guidedSpeaking", required: true,
                prompt: supplement.workplace, answer: "Check whether your intended message is clear. Different wording can be valid.")]
        case .baseline, .transfer, .day7, .day28:
            guard let task = source.reservedActivities.first(where: { $0.id.contains("-\(rawValue)") }),
                  !(task.prompt ?? "").isEmpty else { return nil }
            items = [CurriculumActivity(id: task.id, kind: "guidedSpeaking", required: true,
                prompt: task.prompt, answer: task.answer)]
        }
        let reflection = CurriculumActivity(id: "practice-reflection", kind: "selfReview", required: true,
            prompt: "What could you communicate? What would you like to try next? If you wrote quietly, speaking and pronunciation remain unassessed.",
            answer: "Completion records participation, not accuracy, retention, transfer or an English level.")
        return ResolvedLesson(id: "\(source.id)-practice-\(rawValue)", level: source.level, title: title,
            objectiveId: "\(source.objectiveId)/\(rawValue)", contentVersion: source.contentVersion,
            availability: .ready, practiceActivities: items + [reflection], senses: source.senses)
    }
}

struct CurriculumPracticeRoute: Identifiable {
    var id: String { lesson.id }
    var lesson: ResolvedLesson
    var origin: LessonPracticeOrigin
    var conditions: CurriculumPracticeConditions
}
