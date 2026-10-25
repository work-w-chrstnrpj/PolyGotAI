import Foundation

enum RecallRating: String, Codable, Equatable, CaseIterable {
    case again, hard, good, easy

    var title: String {
        switch self {
        case .again: "Again"
        case .hard: "Hard"
        case .good: "Good"
        case .easy: "Easy"
        }
    }

    var detail: String {
        switch self {
        case .again: "I missed it"
        case .hard: "I knew it with effort"
        case .good: "I knew it"
        case .easy: "I knew it easily"
        }
    }

    /// Again is a miss. Hard, Good, and Easy are successful recall with different effort.
    var succeeded: Bool { self != .again }
}

enum RecallMode: String, Codable, Equatable, CaseIterable {
    case think, write, say

    var title: String {
        switch self {
        case .think: "Think"
        case .write: "Write"
        case .say: "Say"
        }
    }
}

struct RecallDraft: Equatable {
    var typed = ""
    var revealed = false
    var hinted = false
    private(set) var firstResponse: String?
    var mode: RecallMode = .write
    /// Stable through draft edits, reveal, failures and restart; a new card gets a new event.
    var sourceEventID = UUID()

    var modality: String {
        if mode == .say { return "spokenSelfCheck" }
        return firstResponse == nil ? "selfCheck" : "text"
    }

    mutating func reveal() {
        guard !revealed else { return }
        revealed = true
        let trimmed = typed.trimmingCharacters(in: .whitespacesAndNewlines)
        firstResponse = mode == .write && !trimmed.isEmpty ? trimmed : nil
    }

    mutating func hint() { hinted = true }

    mutating func restore(typed: String, revealed: Bool, firstResponse: String?, hinted: Bool) {
        self.typed = typed
        self.hinted = hinted
        self.revealed = revealed
        self.firstResponse = firstResponse
    }

    init(typed: String = "", revealed: Bool = false, hinted: Bool = false,
         firstResponse: String? = nil, mode: RecallMode = .write, sourceEventID: UUID = UUID()) {
        self.typed = typed
        self.revealed = revealed
        self.hinted = hinted
        self.firstResponse = firstResponse
        self.mode = mode
        self.sourceEventID = sourceEventID
    }

    init(_ open: OpenRecall) {
        self.init(typed: open.typed, revealed: open.revealed, hinted: open.hinted,
                  firstResponse: open.firstResponse, mode: open.mode ?? .write,
                  sourceEventID: open.sourceEventID ?? UUID())
    }
}

/// An unfinished recall, including a hidden draft. Leaving it does not create a rating.
struct OpenRecall: Codable, Equatable {
    var itemId: String
    var senseId: String
    var typed: String
    var revealed: Bool
    var firstResponse: String?
    var hinted: Bool
    /// Optional additions keep older preferences documents readable without a schema migration.
    var mode: RecallMode?
    var sourceEventID: UUID?
}

struct VocabularyRecallAttempt: Equatable, Identifiable {
    var id: UUID
    var itemId: String
    var senseId: String
    var lemma: String
    var rating: RecallRating
    var revealed: Bool
    var typedAttempt: String?
    /// text, selfCheck, or spokenSelfCheck (learner-reported, with no audio/assessment).
    var modality: String
    var createdAt: Date
    /// The same callback uses one id. A second delivery does not schedule again.
    var sourceEventID: UUID?
    /// none or hint. A hint still allows an explicit rating and is not unaided recall.
    var assistance: String
    var cardKind: String
    /// Optional scheduling provenance; older ratings retain unavailable provenance.
    var schedulerVersion: String?
    var desiredRetention: Double?

    var succeeded: Bool { rating.succeeded }
    var unaided: Bool { assistance == ReviewAssistance.none.rawValue }

    init(id: UUID, itemId: String, senseId: String, lemma: String, rating: RecallRating, revealed: Bool,
         typedAttempt: String?, modality: String, createdAt: Date, sourceEventID: UUID? = nil,
         assistance: String = ReviewAssistance.none.rawValue, cardKind: String = ReviewCardKind.recognition.rawValue, schedulerVersion: String? = nil, desiredRetention: Double? = nil) {
        self.id = id
        self.itemId = itemId
        self.senseId = senseId
        self.lemma = lemma
        self.rating = rating
        self.revealed = revealed
        self.typedAttempt = typedAttempt
        self.modality = modality
        self.createdAt = createdAt
        self.sourceEventID = sourceEventID
        self.assistance = assistance
        self.cardKind = cardKind
        self.schedulerVersion = schedulerVersion
        self.desiredRetention = desiredRetention
    }
}

extension VocabularyRecallAttempt: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, itemId, senseId, lemma, rating, revealed, typedAttempt, modality, createdAt, sourceEventID, assistance, cardKind, schedulerVersion, desiredRetention
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        itemId = try container.decode(String.self, forKey: .itemId)
        senseId = try container.decode(String.self, forKey: .senseId)
        lemma = try container.decode(String.self, forKey: .lemma)
        rating = try container.decode(RecallRating.self, forKey: .rating)
        revealed = try container.decode(Bool.self, forKey: .revealed)
        typedAttempt = try container.decodeIfPresent(String.self, forKey: .typedAttempt)
        modality = try container.decode(String.self, forKey: .modality)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        sourceEventID = try container.decodeIfPresent(UUID.self, forKey: .sourceEventID)
        assistance = try container.decodeIfPresent(String.self, forKey: .assistance) ?? ReviewAssistance.none.rawValue
        cardKind = try container.decodeIfPresent(String.self, forKey: .cardKind) ?? ReviewCardKind.recognition.rawValue
        schedulerVersion = try container.decodeIfPresent(String.self, forKey: .schedulerVersion)
        desiredRetention = try container.decodeIfPresent(Double.self, forKey: .desiredRetention)
    }
}

enum VocabularyRecallError: Error, Equatable {
    case stillHidden
    case unknownCard
    case missingMeaning
    case staleEvent
}

struct VocabularyRecallLog: Equatable {
    var attempts: [VocabularyRecallAttempt]

    mutating func record(card: VocabularyEnrollment, rating: RecallRating, draft: RecallDraft, now: Date, sourceEventID: UUID) throws -> VocabularyRecallAttempt {
        guard draft.revealed else { throw VocabularyRecallError.stillHidden }
        guard !card.itemId.isEmpty, !card.senseId.isEmpty, !card.lemma.isEmpty else { throw VocabularyRecallError.unknownCard }
        let attempt = VocabularyRecallAttempt(
            id: UUID(), itemId: card.itemId, senseId: card.senseId, lemma: card.lemma,
            rating: rating, revealed: true, typedAttempt: draft.firstResponse,
            modality: draft.modality, createdAt: now,
            sourceEventID: sourceEventID,
            assistance: draft.hinted ? ReviewAssistance.hint.rawValue : ReviewAssistance.none.rawValue)
        attempts.append(attempt)
        return attempt
    }
}
