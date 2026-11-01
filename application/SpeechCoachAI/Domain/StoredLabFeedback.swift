import Foundation

/// One saved online feedback result. Stored on the device only; the learner can delete any of them.
struct StoredLabFeedback: Codable, Equatable, Identifiable {
    static let maximumCount = 100
    var id: UUID
    var createdAt: Date
    var mode: LabFeedbackMode
    /// What was practiced, for the list ("Free talk", "Job interview").
    var title: String
    /// The text that was reviewed (what the learner confirmed).
    var transcript: String
    var feedback: LabFeedback

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && title.unicodeScalars.count <= 120
            && !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && transcript.unicodeScalars.count <= LabFeedbackRequest.maximumScalars
    }
}
