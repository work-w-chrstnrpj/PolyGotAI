import Foundation

/// One meaning of a vocabulary item. The same identity can appear in more than one lesson.
struct CurriculumSense: Codable, Equatable, Identifiable {
    var itemId: String
    var senseId: String
    var lemma: String
    var meaning: String? = nil
    var id: String { "\(itemId)|\(senseId)" }

    static func problem(in senses: [CurriculumSense]) -> VocabularyLinkError? {
        var seen: Set<String> = []
        for sense in senses {
            guard let normalized = normalize(sense) else { return .blankIdentity }
            if !seen.insert(normalized.id).inserted { return .blankIdentity }
        }
        return nil
    }

    static func normalized(_ senses: [CurriculumSense]) -> [CurriculumSense] {
        senses.compactMap(normalize)
    }

    private static func normalize(_ sense: CurriculumSense) -> CurriculumSense? {
        let itemId = sense.itemId.trimmingCharacters(in: .whitespacesAndNewlines)
        let senseId = sense.senseId.trimmingCharacters(in: .whitespacesAndNewlines)
        let lemma = sense.lemma.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !itemId.isEmpty, !senseId.isEmpty, !lemma.isEmpty else { return nil }
        return CurriculumSense(itemId: itemId, senseId: senseId, lemma: lemma, meaning: sense.meaning)
    }
}

/// Optional collection membership. It is not curriculum membership and it carries no review rating.
struct VocabularyEnrollment: Equatable, Identifiable {
    var itemId: String
    var senseId: String
    var lemma: String
    var lessonID: String
    var objectiveID: String
    var contentVersion: String
    var enrolledAt: Date
    /// Collection-only words stay out of the due queue until the learner adds them to review.
    var inReview: Bool
    var meaning: String? = nil
    var id: String { "\(itemId)|\(senseId)" }

    init(itemId: String, senseId: String, lemma: String, lessonID: String, objectiveID: String,
         contentVersion: String, enrolledAt: Date, inReview: Bool = true, meaning: String? = nil) {
        self.itemId = itemId
        self.senseId = senseId
        self.lemma = lemma
        self.lessonID = lessonID
        self.objectiveID = objectiveID
        self.contentVersion = contentVersion
        self.enrolledAt = enrolledAt
        self.inReview = inReview
        self.meaning = meaning
    }
}

extension VocabularyEnrollment: Codable {
    private enum CodingKeys: String, CodingKey {
        case itemId, senseId, lemma, lessonID, objectiveID, contentVersion, enrolledAt, inReview, meaning
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        itemId = try container.decode(String.self, forKey: .itemId)
        senseId = try container.decode(String.self, forKey: .senseId)
        lemma = try container.decode(String.self, forKey: .lemma)
        lessonID = try container.decode(String.self, forKey: .lessonID)
        objectiveID = try container.decode(String.self, forKey: .objectiveID)
        contentVersion = try container.decode(String.self, forKey: .contentVersion)
        enrolledAt = try container.decode(Date.self, forKey: .enrolledAt)
        inReview = try container.decodeIfPresent(Bool.self, forKey: .inReview) ?? true
        meaning = try container.decodeIfPresent(String.self, forKey: .meaning)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(itemId, forKey: .itemId)
        try container.encode(senseId, forKey: .senseId)
        try container.encode(lemma, forKey: .lemma)
        try container.encode(lessonID, forKey: .lessonID)
        try container.encode(objectiveID, forKey: .objectiveID)
        try container.encode(contentVersion, forKey: .contentVersion)
        try container.encode(enrolledAt, forKey: .enrolledAt)
        try container.encode(inReview, forKey: .inReview)
        try container.encodeIfPresent(meaning, forKey: .meaning)
    }
}

/// The learner met the sense in a lesson. Recognition is not a scheduled recall.
struct VocabularyExposure: Codable, Equatable, Identifiable {
    var id: UUID
    var itemId: String
    var senseId: String
    var lessonID: String
    var objectiveID: String
    var contentVersion: String
    /// Always recognition. A rating is intentionally absent.
    var kind: String
    var createdAt: Date
}

enum VocabularyLinkError: Error, Equatable {
    case blankIdentity
    case notInLesson
    case lessonUnavailable
    case objectiveMismatch
}

struct VocabularyCollection: Equatable {
    var enrollments: [VocabularyEnrollment]
    var exposures: [VocabularyExposure]

    mutating func enroll(_ sense: CurriculumSense, lesson: ResolvedLesson, now: Date, inReview: Bool) throws -> VocabularyEnrollment {
        let listed = try listedSense(sense, lesson: lesson)
        if let index = enrollments.firstIndex(where: { $0.id == listed.id }) {
            if inReview { enrollments[index].inReview = true }
            if enrollments[index].meaning == nil { enrollments[index].meaning = listed.meaning }
            return enrollments[index]
        }
        let created = VocabularyEnrollment(
            itemId: listed.itemId, senseId: listed.senseId, lemma: listed.lemma,
            lessonID: lesson.id, objectiveID: lesson.objectiveId, contentVersion: lesson.contentVersion,
            enrolledAt: now, inReview: inReview, meaning: listed.meaning)
        enrollments.append(created)
        return created
    }

    mutating func expose(_ sense: CurriculumSense, lesson: ResolvedLesson, now: Date) throws {
        let listed = try listedSense(sense, lesson: lesson)
        let alreadySeen = exposures.contains {
            $0.itemId == listed.itemId && $0.senseId == listed.senseId
                && $0.lessonID == lesson.id && $0.contentVersion == lesson.contentVersion
        }
        guard !alreadySeen else { return }
        exposures.append(VocabularyExposure(
            id: UUID(), itemId: listed.itemId, senseId: listed.senseId,
            lessonID: lesson.id, objectiveID: lesson.objectiveId, contentVersion: lesson.contentVersion,
            kind: "recognition", createdAt: now))
    }

    private func listedSense(_ sense: CurriculumSense, lesson: ResolvedLesson) throws -> CurriculumSense {
        guard lesson.isReady else { throw VocabularyLinkError.lessonUnavailable }
        guard let listed = lesson.senses.first(where: { $0.itemId == sense.itemId && $0.senseId == sense.senseId }) else {
            throw VocabularyLinkError.notInLesson
        }
        guard CurriculumSense.problem(in: [listed]) == nil else { throw VocabularyLinkError.blankIdentity }
        return listed
    }
}

enum LessonSpeakingLink {
    static func canSpeak(_ lesson: ResolvedLesson, recordingObjectiveID: String) -> Bool {
        lesson.isReady && !recordingObjectiveID.isEmpty && lesson.objectiveId == recordingObjectiveID
    }

    /// Opens the existing recorder for this lesson's objective. It does not finish the lesson.
    static func context(lesson: ResolvedLesson, defaults: LearnerPreferences, recordingObjectiveID: String) throws -> PracticeSessionContext {
        guard lesson.isReady else { throw VocabularyLinkError.lessonUnavailable }
        guard canSpeak(lesson, recordingObjectiveID: recordingObjectiveID) else { throw VocabularyLinkError.objectiveMismatch }
        return PracticeSessionContext(defaults: defaults, sourceLessonID: lesson.id, objectiveID: lesson.objectiveId)
    }

    static func context(lesson: ResolvedLesson, journey: LessonJourney, defaults: LearnerPreferences) throws -> PracticeSessionContext {
        guard journey.lessonID == lesson.id, journey.objectiveID == lesson.objectiveId,
              journey.contentVersion == lesson.contentVersion else { throw VocabularyLinkError.objectiveMismatch }
        guard let activity = lesson.practiceActivities.first(where: { $0.id == journey.currentActivityID && $0.kind == "guidedSpeaking" })
                ?? (journey.completedAt != nil ? lesson.practiceActivities.first(where: { $0.kind == "guidedSpeaking" }) : nil)
        else { throw VocabularyLinkError.notInLesson }
        var result = try context(lesson: lesson, defaults: defaults, recordingObjectiveID: lesson.objectiveId)
        result.sourceLessonJourneyID = journey.id
        result.promptOverride = PromptSnapshot(id: activity.id, version: lesson.contentVersion, objectiveID: lesson.objectiveId,
            text: activity.prompt, isPrivate: false, selectedLevel: lesson.level)
        let origin = journey.practiceOrigin
        result.provenance = SpeakingProvenance(journeyID: journey.id, activityID: activity.id,
            sourceCourseJourneyID: origin?.journeyID ?? journey.id, sourceCourseLessonID: origin?.lessonID ?? lesson.id,
            primaryObjectiveID: origin?.objectiveID ?? lesson.objectiveId, specialtyObjectiveID: nil,
            role: result.effectiveCoach.rawValue, method: "Guided topic practice and self-review",
            packID: lesson.id, packVersion: lesson.contentVersion,
            purpose: origin == nil ? "coursePractice" : "topicPractice", supported: journey.practiceConditions?.supported ?? true)
        return result
    }
}
