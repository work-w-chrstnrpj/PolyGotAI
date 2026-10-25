import Foundation

/// Authored advisory content; never grades a response or changes course/assessment completion.
struct IntroductionReviewGuide: Codable, Equatable {
    struct Activity: Codable, Equatable, Identifiable {
        var id: String
        var alternatives: [String]
        var explanation: String
        var boundary: String
    }
    struct Dimension: Codable, Equatable, Identifiable {
        var id: String
        var title: String
        var notAssessed: String
        var anchors: [String]
    }
    struct Pack: Codable, Equatable, Identifiable {
        var id: String
        var packID: String
        var packVersion: String
        var objectiveID: String
        var method: [String]
        var priorities: [String]
        var criteria: String
        var boundary: String
    }
    var schemaVersion: Int
    var id: String
    var sourceLessonID: String
    var sourceContentVersion: String
    var rubricVersion: String
    var reviewState: String
    var notice: String
    var rights: String
    var references: [String]
    var selfReview: [String]
    var independentCriterion: String
    var dimensions: [Dimension]
    var activities: [Activity]
    var packs: [Pack]

    static let bundled: Self? = {
        guard let url = Bundle.main.url(forResource: "IntroductionReviewGuide", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? decode(data)
    }()

    static func decode(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard value.schemaVersion == 1, value.id == "intro-01-review-1",
              value.sourceLessonID == "intro-01", value.sourceContentVersion == "4",
              value.rubricVersion == "INTRO-01-personal-draft-1", value.reviewState == "personalUseDraft",
              !value.notice.isEmpty, !value.rights.isEmpty, !value.references.isEmpty,
              !value.selfReview.isEmpty, !value.independentCriterion.isEmpty,
              Set(value.dimensions.map(\.id)) == ["task", "vocabulary", "grammar", "intelligibility"],
              value.dimensions.count == 4,
              value.dimensions.allSatisfy({ !$0.notAssessed.isEmpty && $0.anchors.count == 3 && $0.anchors.allSatisfy { !$0.isEmpty } }),
              value.activities.count == 19, Set(value.activities.map(\.id)).count == 19,
              value.activities.allSatisfy({ !$0.alternatives.isEmpty && $0.alternatives.allSatisfy { !$0.isEmpty } && !$0.explanation.isEmpty && !$0.boundary.isEmpty }),
              value.packs.count == 4, Set(value.packs.map(\.id)) == ["foundations", "teacher", "grammarian", "journalist"],
              value.packs.allSatisfy({ !$0.packID.isEmpty && !$0.packVersion.isEmpty && !$0.objectiveID.isEmpty && !$0.method.isEmpty && !$0.priorities.isEmpty && !$0.criteria.isEmpty && !$0.boundary.isEmpty }) else {
            throw LearnerStorageError.invalidContent
        }
        return value
    }

    /// Answers/alternatives are only available after reveal and only for the exact authored lesson version.
    func review(activityID: String, lessonID: String, contentVersion: String, revealed: Bool) -> Activity? {
        guard revealed, lessonID == sourceLessonID, contentVersion == sourceContentVersion else { return nil }
        return activities.first { $0.id == activityID }
    }

    func pack(id: String, version: String) -> Pack? {
        packs.first { $0.packID == id && $0.packVersion == version }
    }
}
