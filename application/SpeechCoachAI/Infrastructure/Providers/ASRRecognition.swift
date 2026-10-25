import Foundation

enum ASRResponseError: Error { case oversized, malformed, incomplete, unsupportedModel, emptyRecognition }

/// Transient validated text only. Raw JSON is never persisted; no confidence is inferred.
struct ASRRecognition {
    let text: String
    let model: String
    var confidence: Double? { nil }

    init(response: Data, expectedModel: String) throws {
        let result = try ProviderCompletionContent(response: response, expectedModel: expectedModel, maximumScalars: 12_000)
        text = result.text; model = result.model
    }
}

struct ProviderCompletionContent {
    let text: String
    let model: String
    init(response: Data, expectedModel: String, maximumScalars: Int) throws {
        guard response.count <= 256 * 1024 else { throw ASRResponseError.oversized }
        struct Envelope: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable { let role: String; let content: String }
                let index: Int
                let finish_reason: String
                let message: Message
            }
            let model: String
            let choices: [Choice]
        }
        let envelope: Envelope
        do { envelope = try JSONDecoder().decode(Envelope.self, from: response) }
        catch { throw ASRResponseError.malformed }
        guard envelope.model == expectedModel, !expectedModel.isEmpty else { throw ASRResponseError.unsupportedModel }
        guard envelope.choices.count == 1, let choice = envelope.choices.first,
              choice.index == 0, choice.finish_reason == "stop", choice.message.role == "assistant" else {
            throw ASRResponseError.incomplete
        }
        guard !choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ASRResponseError.emptyRecognition
        }
        guard choice.message.content.unicodeScalars.count <= maximumScalars else { throw ASRResponseError.oversized }
        text = choice.message.content; model = envelope.model
    }
}
