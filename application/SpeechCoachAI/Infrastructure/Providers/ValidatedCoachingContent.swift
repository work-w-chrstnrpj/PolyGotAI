import Foundation

enum CoachingValidationError: Error { case invalidResponse, unconfirmedTranscript, ungroundedEvidence, invalidPreference }

/// Accepts model content only after structural and quoted-evidence checks.
/// Educational correctness/usefulness still needs qualified review, not just JSON validation.
struct ValidatedCoachingContent {
    let transcriptID: UUID
    let transcriptRevision: Int
    let transcriptChecksum: String
    let summary: String
    let strengths: [String]
    let improvements: [FeedbackSnapshot.Improvement]
    let limitations: [String]

    init(response: Data, confirmed: TranscriptSnapshot, expanded: Bool = false, hintsOnly: Bool = false) throws {
        guard confirmed.kind == .learnerConfirmed, confirmed.sourceTranscriptID != nil, confirmed.text.unicodeScalars.count <= 12_000,
              !confirmed.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CoachingValidationError.unconfirmedTranscript
        }
        guard response.count <= 64 * 1024 else { throw CoachingValidationError.invalidResponse }
        let raw: Any
        do { raw = try JSONSerialization.jsonObject(with: response) }
        catch { throw CoachingValidationError.invalidResponse }
        guard let object = raw as? [String: Any],
              Set(object.keys) == ["summary", "strengths", "improvements", "limitations", "speechAssessmentStatus"],
              let items = object["improvements"] as? [[String: Any]],
              items.allSatisfy({ Set($0.keys) == ["category", "evidenceQuote", "explanation", "suggestedRevision", "hint", "retryPrompt"] }) else {
            throw CoachingValidationError.invalidResponse
        }
        struct Content: Decodable {
            let summary: String
            let strengths: [String]
            let improvements: [FeedbackSnapshot.Improvement]
            let limitations: [String]
            let speechAssessmentStatus: String
        }
        let content: Content
        do { content = try JSONDecoder().decode(Content.self, from: response) }
        catch { throw CoachingValidationError.invalidResponse }
        func valid(_ text: String, maximum: Int) -> Bool {
            !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && text.unicodeScalars.count <= maximum
        }
        guard valid(content.summary, maximum: 600), content.strengths.count <= 2,
              content.strengths.allSatisfy({ valid($0, maximum: 300) }),
              content.improvements.count <= (expanded ? 5 : 2), content.limitations.count <= 5,
              content.limitations.allSatisfy({ valid($0, maximum: 300) }),
              content.speechAssessmentStatus == "not_assessed" else { throw CoachingValidationError.invalidResponse }
        for item in content.improvements {
            guard valid(item.evidenceQuote, maximum: 500), valid(item.explanation, maximum: 600),
                  valid(item.retryPrompt, maximum: 400),
                  item.suggestedRevision.map({ valid($0, maximum: 600) }) ?? true,
                  item.hint.map({ valid($0, maximum: 600) }) ?? true else {
                throw CoachingValidationError.invalidResponse
            }
            guard confirmed.text.contains(item.evidenceQuote) else { throw CoachingValidationError.ungroundedEvidence }
            if hintsOnly, item.suggestedRevision != nil || item.hint == nil { throw CoachingValidationError.invalidPreference }
        }
        transcriptID = confirmed.id; transcriptRevision = confirmed.revision
        transcriptChecksum = PrivateFileStore.checksum(Data(confirmed.text.utf8))
        summary = content.summary; strengths = content.strengths
        improvements = content.improvements; limitations = content.limitations
    }
}
