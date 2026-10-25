import Foundation

struct LearnerPreferences: Codable, Equatable {
    enum Background: String, Codable, CaseIterable { case creativeAcademy, adventureAtlas, mixedMediaStudio }
    enum Appearance: String, Codable, CaseIterable { case system, light, dark }
    enum Coach: String, Codable, CaseIterable {
        case elephantTeacher, foxJournalist, owlGrammarian, bearLibrarian
        case tigerBusinessProfessional, parrotSpeaker, creativeWriter
    }
    var background: Background = .creativeAcademy
    var appearance: Appearance = .system
    var coach: Coach = .elephantTeacher
    var countdownEnabled = false
}

enum LearnerStorageError: Error, Equatable {
    case unavailable, invalidReference, staleVersion, invalidState, invalidContent, expired
    case storageFailure, integrityFailure
}

enum PayloadState: String, Codable { case temporary, saved, recentlyDeleted, purged, unavailable }
enum PayloadScope: String, Codable { case audio, text, all }

struct ComponentLifecycle: Codable, Equatable {
    var state: PayloadState = .temporary
    var deletionID: UUID?
    var deletedAt: Date?
    var expiresAt: Date?

    var isVisible: Bool { state == .temporary || state == .saved }
}

struct PromptSnapshot: Codable, Equatable {
    var id: String
    var version: String
    var objectiveID: String
    var text: String?
    var isPrivate: Bool
    var selectedLevel: String
    var language = "en"
    var variety = "en-US"
}

struct RecordingSnapshot: Codable, Equatable {
    var id: UUID
    var relativePath: String
    var byteCount: Int
    var sha256: String
    var durationMilliseconds: Int
    var sampleRate: Int
    var channelCount: Int
    var bitsPerSample: Int
}

struct TranscriptSnapshot: Codable, Equatable {
    enum Kind: String, Codable { case asrOriginal, learnerConfirmed }
    var id: UUID
    var revision: Int
    var kind: Kind
    var sourceTranscriptID: UUID?
    var text: String
    var createdAt: Date
    var provider: String?
    var model: String?
    var region: String?
}

/// Persisted only after domain validation. Provider wire bodies have no storage field.
struct FeedbackSnapshot: Codable, Equatable {
    struct Improvement: Codable, Equatable {
        enum Category: String, Codable { case grammar, vocabulary, organization }
        var category: Category
        var evidenceQuote: String
        var explanation: String
        var suggestedRevision: String?
        var hint: String?
        var retryPrompt: String
    }
    var id: UUID
    var requestID: UUID
    var transcriptID: UUID
    var transcriptRevision: Int
    var schemaVersion: Int
    var rubricVersion: String
    var provider: String
    var model: String
    var region: String
    var createdAt: Date
    var summary: String
    var strengths: [String]
    var improvements: [Improvement]
    var limitations: [String]
    // Text coaching never claims acoustic assessment.
    var speechAssessmentStatus: String { "not_assessed" }
}

struct RequestSnapshot: Codable, Equatable {
    enum Stage: String, Codable { case transcription, coaching }
    enum Status: String, Codable { case prepared, sent, succeeded, failed, cancelled, unknownOutcome }
    var id: UUID
    var stage: Stage
    var transcriptID: UUID?
    var model: String
    var region: String
    var status: Status
    var createdAt: Date
}

struct AttemptSnapshot: Codable, Equatable {
    enum Stage: String, Codable { case recorded, transcribing, transcriptReview, feedbackPending, feedbackReady }
    var id: UUID
    var epoch: UUID
    var version = 1
    var retryOfAttemptID: UUID?
    var prompt: PromptSnapshot
    var preferences: LearnerPreferences?
    var createdAt: Date
    var finishedAt: Date?
    var completionID: UUID?
    var didCompleteSelfReview: Bool?
    var stage: Stage = .recorded
    var recoveryDeadline: Date
    var interrupted = false
    var audio = ComponentLifecycle()
    var text = ComponentLifecycle()
    var practiceSessionID: UUID?
    var sourceLessonID: String?
    var sourceLessonJourneyID: UUID?
    var speakingProvenance: SpeakingProvenance?
    var pendingCaptureID: UUID? // Optional JSON field: older v1 snapshots decode unchanged.
    var recording: RecordingSnapshot?
    var transcripts: [TranscriptSnapshot] = []
    var feedback: [FeedbackSnapshot] = []
    var requests: [RequestSnapshot] = []
}

struct CallbackToken: Equatable {
    let attemptID: UUID
    let epoch: UUID
    let version: Int
}
