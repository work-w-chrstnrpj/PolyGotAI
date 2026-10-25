import Foundation

/// Recognition and productive use stay separate. Only recognition is scheduled.
enum ReviewCardKind: String, Codable, Equatable {
    case recognition
    case productiveUse
}

/// A hint is assistance. It is recorded and is not unaided recall.
enum ReviewAssistance: String, Codable, Equatable {
    case none
    case hint
}

/// The learner action that might be mistaken for a review.
enum ReviewTask: String, Codable, Equatable {
    case explicitRating
    case lessonExposure
    case grammarCorrection
    case productiveUse
}

enum ReviewCredit: Equatable {
    case schedule
    case unchanged(Reason)

    enum Reason: String, Equatable {
        case lessonExposure
        case grammarCorrection
        case answerHidden
        case productiveUseKeptSeparate
        case duplicateEvent
        case missingSense
    }
}

/// A stored non-rating. It cannot move a recognition due time.
struct SenseCreditEvent: Codable, Equatable, Identifiable {
    var id: UUID
    var itemId: String
    var senseId: String
    var task: String
    var cardKind: String
    var rating: String?
    var createdAt: Date
}

enum ReviewCreditPolicy {
    /// The same item and sense keep one recognition card. A new sense does not inherit it.
    /// The written word is not the identity.
    static func sameSense(itemId: String, senseId: String, otherItemId: String, otherSenseId: String) -> Bool {
        !itemId.isEmpty && itemId == otherItemId && !senseId.isEmpty && senseId == otherSenseId
    }

    static func decide(
        task: ReviewTask,
        revealed: Bool,
        kind: ReviewCardKind,
        sourceEventID: UUID?,
        alreadyRecorded: Set<UUID>,
        enrolled: Bool
    ) -> ReviewCredit {
        guard enrolled else { return .unchanged(.missingSense) }
        if let sourceEventID, alreadyRecorded.contains(sourceEventID) {
            return .unchanged(.duplicateEvent)
        }
        switch task {
        case .lessonExposure:
            return .unchanged(.lessonExposure)
        case .grammarCorrection:
            return .unchanged(.grammarCorrection)
        case .productiveUse:
            return .unchanged(.productiveUseKeptSeparate)
        case .explicitRating:
            guard kind == .recognition else { return .unchanged(.productiveUseKeptSeparate) }
            guard revealed else { return .unchanged(.answerHidden) }
            return .schedule
        }
    }
}
