import Foundation

/// Bundled curriculum contract from SC-T005. A fixture or an empty pack is not a published lesson.
struct CurriculumManifest: Codable, Equatable {
    var schemaVersion: Int
    var packId: String
    var contentVersion: String
    var locale: String
    var minimumSchemaVersion: Int
    /// A non-empty reference is required. A boolean cannot stand in for a review.
    var editorialApprovalReference: String
    var rightsReference: String
    var assets: [CurriculumAsset]
    var lessons: [CurriculumLesson]
    /// Exact older content retained for existing journeys; never appears as a second browse row.
    var archivedLessons: [CurriculumLesson]? = nil
}

/// Offline teaching and optional practice share the course's content version and sense identities.
struct CurriculumSupplement: Codable, Equatable {
    var teaching: String
    var concepts: [CurriculumActivity]
    var pronunciation: String
    var workplace: String
    var reviewNotice: String
}

struct CurriculumAsset: Codable, Equatable, Identifiable {
    var id: String
    var relativePath: String
    var byteCount: Int
    var sha256: String
    var mediaType: String
}

struct CurriculumLesson: Codable, Equatable, Identifiable {
    var id: String
    var contentVersion: String
    var level: String
    var title: String
    var objectiveId: String
    var activities: [CurriculumActivity]
    /// Shared item and sense identities. Omitted packs simply have no vocabulary references.
    var senses: [CurriculumSense]
    var supplement: CurriculumSupplement? = nil
    /// v2: the coach tip shown before the exercises (2–4 sentences).
    var tip: String? = nil
    /// v2: `course` or a coach track id, and the unit inside it.
    var trackId: String? = nil
    var unitId: String? = nil
    /// v2: credits for the ideas and public-domain material behind the lesson.
    var sources: [String]? = nil

    init(id: String, contentVersion: String, level: String, title: String, objectiveId: String,
         activities: [CurriculumActivity], senses: [CurriculumSense] = []) {
        self.id = id
        self.contentVersion = contentVersion
        self.level = level
        self.title = title
        self.objectiveId = objectiveId
        self.activities = activities
        self.senses = senses
    }

    private enum CodingKeys: String, CodingKey {
        case id, contentVersion, level, title, objectiveId, activities, senses, supplement, tip, trackId, unitId, sources
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        contentVersion = try container.decode(String.self, forKey: .contentVersion)
        level = try container.decode(String.self, forKey: .level)
        title = try container.decode(String.self, forKey: .title)
        objectiveId = try container.decode(String.self, forKey: .objectiveId)
        activities = try container.decode([CurriculumActivity].self, forKey: .activities)
        senses = try container.decodeIfPresent([CurriculumSense].self, forKey: .senses) ?? []
        supplement = try container.decodeIfPresent(CurriculumSupplement.self, forKey: .supplement)
        tip = try container.decodeIfPresent(String.self, forKey: .tip)
        trackId = try container.decodeIfPresent(String.self, forKey: .trackId)
        unitId = try container.decodeIfPresent(String.self, forKey: .unitId)
        sources = try container.decodeIfPresent([String].self, forKey: .sources)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(contentVersion, forKey: .contentVersion)
        try container.encode(level, forKey: .level)
        try container.encode(title, forKey: .title)
        try container.encode(objectiveId, forKey: .objectiveId)
        try container.encode(activities, forKey: .activities)
        try container.encode(senses, forKey: .senses)
        try container.encodeIfPresent(supplement, forKey: .supplement)
        try container.encodeIfPresent(tip, forKey: .tip)
        try container.encodeIfPresent(trackId, forKey: .trackId)
        try container.encodeIfPresent(unitId, forKey: .unitId)
        try container.encodeIfPresent(sources, forKey: .sources)
    }
}

struct CurriculumActivity: Codable, Equatable, Identifiable {
    var id: String
    var kind: String
    var required: Bool
    var prompt: String?
    var answer: String?
    var assetId: String?
    /// Filled when a ready lesson has a bundled file the player can open.
    var playbackPath: String?
    /// Reserved baseline and transfer prompts stay out of ordinary practice.
    var withheldFromPractice: Bool? = nil
    /// A quiet equivalent replaces this named activity; it is not an extra compulsory exercise.
    var alternativeToActivityID: String? = nil
    /// Bounded answer buttons. Absent on open responses. A present set does not change completion.
    var choiceSet: [String]? = nil
    /// Pattern note for use after an unaided attempt. It is not a score.
    var explanation: String? = nil
    /// Foundation child objectives practiced by this item. They do not add required activities.
    var childObjectiveIds: [String]? = nil
    /// v2: typed, auto-checked behavior. Absent on legacy activities (see `resolvedExercise`).
    var exercise: ExerciseSpec? = nil

    init(id: String, kind: String, required: Bool, prompt: String? = nil, answer: String? = nil,
         assetId: String? = nil, playbackPath: String? = nil, withheldFromPractice: Bool? = nil,
         alternativeToActivityID: String? = nil, choiceSet: [String]? = nil, explanation: String? = nil,
         childObjectiveIds: [String]? = nil, exercise: ExerciseSpec? = nil) {
        self.id = id
        self.kind = kind
        self.required = required
        self.prompt = prompt
        self.answer = answer
        self.assetId = assetId
        self.playbackPath = playbackPath
        self.withheldFromPractice = withheldFromPractice
        self.alternativeToActivityID = alternativeToActivityID
        self.choiceSet = choiceSet
        self.explanation = explanation
        self.childObjectiveIds = childObjectiveIds
        self.exercise = exercise
    }

    private enum CodingKeys: String, CodingKey {
        case id, kind, required, prompt, answer, assetId, playbackPath, withheldFromPractice, alternativeToActivityID
        case choiceSet, explanation, childObjectiveIds, exercise
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        kind = try container.decode(String.self, forKey: .kind)
        required = try container.decode(Bool.self, forKey: .required)
        prompt = try container.decodeIfPresent(String.self, forKey: .prompt)
        answer = try container.decodeIfPresent(String.self, forKey: .answer)
        assetId = try container.decodeIfPresent(String.self, forKey: .assetId)
        playbackPath = try container.decodeIfPresent(String.self, forKey: .playbackPath)
        withheldFromPractice = try container.decodeIfPresent(Bool.self, forKey: .withheldFromPractice)
        alternativeToActivityID = try container.decodeIfPresent(String.self, forKey: .alternativeToActivityID)
        choiceSet = try Self.stringArray(container, key: .choiceSet)
        explanation = try Self.stringValue(container, key: .explanation)
        childObjectiveIds = try Self.stringArray(container, key: .childObjectiveIds)
        if container.contains(.exercise), !(try container.decodeNil(forKey: .exercise)) {
            // A malformed spec becomes an unknown type so this lesson fails closed without rejecting the catalog.
            exercise = (try? container.decode(ExerciseSpec.self, forKey: .exercise)) ?? ExerciseSpec(type: "")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(kind, forKey: .kind)
        try container.encode(required, forKey: .required)
        try container.encodeIfPresent(prompt, forKey: .prompt)
        try container.encodeIfPresent(answer, forKey: .answer)
        try container.encodeIfPresent(assetId, forKey: .assetId)
        try container.encodeIfPresent(playbackPath, forKey: .playbackPath)
        try container.encodeIfPresent(withheldFromPractice, forKey: .withheldFromPractice)
        try container.encodeIfPresent(alternativeToActivityID, forKey: .alternativeToActivityID)
        try container.encodeIfPresent(choiceSet, forKey: .choiceSet)
        try container.encodeIfPresent(explanation, forKey: .explanation)
        try container.encodeIfPresent(childObjectiveIds, forKey: .childObjectiveIds)
        try container.encodeIfPresent(exercise, forKey: .exercise)
    }

    /// Present optional metadata is either usable or a reason to keep this lesson closed.
    /// A nil field is legacy content and stays valid. This check does not score the learner.
    func metadataProblem() -> String? {
        if let choiceSet {
            if choiceSet.isEmpty || choiceSet.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                return id
            }
            let folded = choiceSet.map { $0.lowercased() }
            if Set(folded).count != folded.count { return id }
            let answer = self.answer?.lowercased() ?? ""
            if answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return id }
            if folded.filter({ $0 == answer }).count != 1 { return id }
        }
        if let explanation, explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return id }
        if let childObjectiveIds {
            let trimmed = childObjectiveIds.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if trimmed.isEmpty || trimmed.contains(where: \.isEmpty) || Set(childObjectiveIds).count != childObjectiveIds.count {
                return id
            }
        }
        if let exercise, exercise.problem(hasClip: assetId != nil) != nil { return id }
        return nil
    }

    /// Missing and JSON null stay nil. A present value of the wrong JSON type becomes a blank sentinel so this activity fails closed without rejecting the rest of the catalog.
    private static func stringValue(_ container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) throws -> String? {
        guard container.contains(key) else { return nil }
        if try container.decodeNil(forKey: key) { return nil }
        if let value = try? container.decode(String.self, forKey: key) { return value }
        return ""
    }

    private static func stringArray(_ container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) throws -> [String]? {
        guard container.contains(key) else { return nil }
        if try container.decodeNil(forKey: key) { return nil }
        if let values = try? container.decode([String].self, forKey: key) { return values }
        return [""]
    }
}

enum CurriculumActivityKind: String {
    case reading, listening, grammar, recall, guidedSpeaking, selfReview, quietText
}

struct InspectedAsset: Equatable {
    var byteCount: Int
    var sha256: String
    var readable: Bool
}

struct ResolvedLesson: Equatable, Identifiable {
    var id: String
    var level: String
    var title: String
    var objectiveId: String
    var contentVersion: String
    var availability: LessonAvailability
    var practiceActivities: [CurriculumActivity]
    var senses: [CurriculumSense] = []
    var supplement: CurriculumSupplement? = nil
    var reservedActivities: [CurriculumActivity] = []
    /// v2: coach tip and track placement. Nil for lessons that predate them.
    var tip: String? = nil
    var trackId: String? = nil
    var unitId: String? = nil
    var sources: [String]? = nil

    /// True when at least one practice activity is auto-checked, so the player should run the exercise flow.
    var hasCheckedExercises: Bool { sessionActivities.contains { $0.resolvedExercise.isChecked && $0.exercise != nil } }

    var sessionActivities: [CurriculumActivity] {
        practiceActivities.filter { activity in
            guard let original = activity.alternativeToActivityID else { return true }
            return !practiceActivities.contains { $0.id == original && $0.kind == "guidedSpeaking" }
        }
    }

    var isReady: Bool {
        if case .ready = availability { return true }
        return false
    }
}

enum LessonAvailability: Equatable {
    case ready
    case unavailable(LessonUnavailableReason)
}

enum LessonUnavailableReason: Equatable {
    case missingReview
    case unsupportedSchema
    case missingAsset(String)
    case corruptAsset(String)
    case unsupportedActivity(String)
    case incompleteActivity(String)
    case duplicateIdentity(String)
    case malformedMetadata(String)

    var explanation: String {
        switch self {
        case .missingReview:
            "This lesson stays closed until the pack records its source and its right to use the material."
        case .unsupportedSchema:
            "This lesson uses a content version the app cannot open."
        case .missingAsset(let name):
            "A required offline file is missing (\(name))."
        case .corruptAsset(let name):
            "A required offline file does not match its recorded size or contents (\(name))."
        case .unsupportedActivity(let name):
            "This lesson includes an activity the app cannot present (\(name))."
        case .incompleteActivity(let name):
            "A required activity is missing its reviewed text or audio (\(name))."
        case .duplicateIdentity(let name):
            "This lesson repeats an id, so it stays closed (\(name))."
        case .malformedMetadata(let name):
            "This lesson's optional activity details are incomplete, so it stays closed (\(name))."
        }
    }
}

enum CurriculumAvailability {
    static let supportedSchemaVersion = 1
    static let supportedKinds = Set(CurriculumActivityKind.allCases.map(\.rawValue))

    static func resolve(manifest: CurriculumManifest, inspected: [String: InspectedAsset]) -> [ResolvedLesson] {
        let reviewRecorded = !manifest.editorialApprovalReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !manifest.rightsReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let schemaSupported = manifest.schemaVersion == supportedSchemaVersion
            && manifest.minimumSchemaVersion <= supportedSchemaVersion
        let duplicateAssets = duplicateIDs(in: manifest.assets.map(\.id))
        let assets = assetMap(manifest.assets, excluding: duplicateAssets)
        let duplicateLessons = duplicateIDs(in: manifest.lessons.map(\.id))
        return manifest.lessons.map { lesson in
            resolve(lesson, reviewRecorded: reviewRecorded, schemaSupported: schemaSupported, assets: assets,
                    duplicateAssets: duplicateAssets, lessonIdentityDuplicated: duplicateLessons.contains(lesson.id), inspected: inspected)
        }
    }

    private static func resolve(
        _ lesson: CurriculumLesson,
        reviewRecorded: Bool,
        schemaSupported: Bool,
        assets: [String: CurriculumAsset],
        duplicateAssets: Set<String>,
        lessonIdentityDuplicated: Bool,
        inspected: [String: InspectedAsset]
    ) -> ResolvedLesson {
        let practice = lesson.activities.filter { $0.withheldFromPractice != true }
        let availability = availability(of: lesson, reviewRecorded: reviewRecorded, schemaSupported: schemaSupported, assets: assets,
                                        duplicateAssets: duplicateAssets, lessonIdentityDuplicated: lessonIdentityDuplicated, inspected: inspected)
        let ready = availability == .ready
        return ResolvedLesson(id: lesson.id, level: lesson.level, title: lesson.title, objectiveId: lesson.objectiveId,
                              contentVersion: lesson.contentVersion, availability: availability,
                              practiceActivities: ready ? practice.map { stamped($0, assets: assets) } : [],
                              senses: ready ? CurriculumSense.normalized(lesson.senses) : [],
                              supplement: ready ? lesson.supplement : nil,
                              reservedActivities: ready ? lesson.activities.filter { $0.withheldFromPractice == true } : [],
                              tip: lesson.tip, trackId: lesson.trackId, unitId: lesson.unitId, sources: lesson.sources)
    }

    private static func availability(
        of lesson: CurriculumLesson,
        reviewRecorded: Bool,
        schemaSupported: Bool,
        assets: [String: CurriculumAsset],
        duplicateAssets: Set<String>,
        lessonIdentityDuplicated: Bool,
        inspected: [String: InspectedAsset]
    ) -> LessonAvailability {
        guard schemaSupported else { return .unavailable(.unsupportedSchema) }
        guard reviewRecorded else { return .unavailable(.missingReview) }
        if lessonIdentityDuplicated { return .unavailable(.duplicateIdentity(lesson.id)) }
        if let activityID = firstDuplicate(in: lesson.activities.map(\.id)) {
            return .unavailable(.duplicateIdentity(activityID))
        }
        if CurriculumSense.problem(in: lesson.senses) != nil { return .unavailable(.incompleteActivity("vocabulary")) }
        if let supplement = lesson.supplement {
            let text = [supplement.teaching, supplement.pronunciation, supplement.workplace, supplement.reviewNotice]
            if text.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
                || supplement.concepts.isEmpty
                || firstDuplicate(in: supplement.concepts.map(\.id)) != nil {
                return .unavailable(.malformedMetadata("teaching"))
            }
            for item in supplement.concepts {
                if item.kind != "grammar" || item.metadataProblem() != nil
                    || (item.answer ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return .unavailable(.malformedMetadata(item.id))
                }
                if let reason = activityProblem(item, assets: assets, duplicateAssets: duplicateAssets, inspected: inspected) {
                    return .unavailable(reason)
                }
            }
        }
        for activity in lesson.activities {
            if activity.metadataProblem() != nil { return .unavailable(.malformedMetadata(activity.id)) }
        }
        for activity in lesson.activities where activity.required {
            if let reason = activityProblem(activity, assets: assets, duplicateAssets: duplicateAssets, inspected: inspected) {
                return .unavailable(reason)
            }
        }
        return .ready
    }

    private static func activityProblem(
        _ activity: CurriculumActivity,
        assets: [String: CurriculumAsset],
        duplicateAssets: Set<String>,
        inspected: [String: InspectedAsset]
    ) -> LessonUnavailableReason? {
        if let assetId = activity.assetId, duplicateAssets.contains(assetId) {
            return .duplicateIdentity(assetId)
        }
        guard let kind = CurriculumActivityKind(rawValue: activity.kind) else {
            return .unsupportedActivity(activity.id)
        }
        switch kind {
        case .listening:
            return assetProblem(activity, assets: assets, inspected: inspected, requiresAudio: true)
        case .reading, .grammar, .recall, .guidedSpeaking, .selfReview, .quietText:
            if activity.assetId != nil {
                return assetProblem(activity, assets: assets, inspected: inspected, requiresAudio: false)
            }
            let prompt = activity.prompt?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return prompt.isEmpty ? .incompleteActivity(activity.id) : nil
        }
    }

    private static func assetProblem(
        _ activity: CurriculumActivity,
        assets: [String: CurriculumAsset],
        inspected: [String: InspectedAsset],
        requiresAudio: Bool
    ) -> LessonUnavailableReason? {
        guard let assetId = activity.assetId, let declared = assets[assetId] else {
            return .incompleteActivity(activity.id)
        }
        if requiresAudio, !declared.mediaType.hasPrefix("audio/") {
            return .incompleteActivity(activity.id)
        }
        guard let found = inspected[assetId], found.readable else {
            return .missingAsset(declared.relativePath)
        }
        guard found.byteCount == declared.byteCount, found.sha256 == declared.sha256.lowercased() else {
            return .corruptAsset(declared.relativePath)
        }
        return nil
    }

    private static func duplicateIDs(in ids: [String]) -> Set<String> {
        var counts: [String: Int] = [:]
        for id in ids { counts[id, default: 0] += 1 }
        var duplicates: Set<String> = []
        for (id, count) in counts where count > 1 { duplicates.insert(id) }
        return duplicates
    }

    private static func firstDuplicate(in ids: [String]) -> String? {
        var seen: Set<String> = []
        for id in ids where !seen.insert(id).inserted { return id }
        return nil
    }

    /// Drops repeated asset ids instead of trapping. Callers treat those ids as unusable.
    private static func assetMap(_ assets: [CurriculumAsset], excluding duplicates: Set<String>) -> [String: CurriculumAsset] {
        var map: [String: CurriculumAsset] = [:]
        for asset in assets where !duplicates.contains(asset.id) {
            map[asset.id] = asset
        }
        return map
    }

    private static func stamped(_ activity: CurriculumActivity, assets: [String: CurriculumAsset]) -> CurriculumActivity {
        var copy = activity
        if let assetId = activity.assetId, let asset = assets[assetId] {
            copy.playbackPath = asset.relativePath
        }
        return copy
    }
}

extension CurriculumActivityKind: CaseIterable {}

/// Owner-approved personal-use subset, 2026-10-23. This is not educator review, a learning result, or a complete A1 curriculum.
struct PersonalUseA1Course: Equatable {
    static let version = "personal-use-a1-3-2026-10-23"

    struct Lesson: Equatable {
        var id: String
        var contentVersion: String
        var objectiveId: String
    }

    static let lessons = [
        Lesson(id: "family-01", contentVersion: "2", objectiveId: "FAMILY-01"),
        Lesson(id: "routine-01", contentVersion: "2", objectiveId: "ROUTINE-01"),
        Lesson(id: "food-01", contentVersion: "2", objectiveId: "FOOD-01"),
    ]

    static func contains(_ lesson: ResolvedLesson) -> Bool {
        lessons.contains {
            $0.id == lesson.id && $0.contentVersion == lesson.contentVersion && $0.objectiveId == lesson.objectiveId
        }
    }
}
