import Foundation

struct TalkTurn: Equatable, Identifiable, Sendable {
    enum Role: String, Sendable { case user, assistant }
    var id = UUID()
    var role: Role
    var text: String
}

enum TalkMode: String, CaseIterable, Identifiable {
    case freeTalk, interview, scenario
    var id: String { rawValue }
    var title: String { switch self { case .freeTalk: "Free talk"; case .interview: "Interview"; case .scenario: "Scenario" } }
    func instruction(scenario: String) -> String {
        let persona = switch self {
        case .freeTalk: "Have a friendly English conversation."
        case .interview: "Act as a job interviewer. Ask one practical job-interview question at a time and follow up on the answer."
        case .scenario: "Role-play this situation with the learner: \(scenario). Stay in the partner's role."
        }
        return "\(persona) Speak naturally in 1–3 short sentences, without lists or markdown. Ask one question to keep the conversation going. Help practice English; do not grade proficiency or judge pronunciation."
    }
}

/// Incremental sentence extraction; partial words and decimal points stay buffered.
struct SentenceBuffer {
    private(set) var pending = ""
    mutating func append(_ text: String) -> [String] { pending += text; return drain(final: false) }
    mutating func finish() -> [String] { drain(final: true) }
    private mutating func drain(final: Bool) -> [String] {
        var sentences: [String] = []
        while let boundary = boundary(final: final) {
            let sentence = String(pending[..<boundary]).trimmingCharacters(in: .whitespacesAndNewlines)
            pending = String(pending[boundary...])
            if !sentence.isEmpty { sentences.append(sentence) }
        }
        if final {
            let rest = pending.trimmingCharacters(in: .whitespacesAndNewlines); pending = ""
            if !rest.isEmpty { sentences.append(rest) }
        }
        return sentences
    }
    private func boundary(final: Bool) -> String.Index? {
        for index in pending.indices where ".!?\n".contains(pending[index]) {
            let next = pending.index(after: index)
            if next == pending.endIndex { if final || pending[index] == "\n" { return next }; continue }
            if pending[next].isWhitespace { return next }
        }
        return nil
    }
}

struct TalkRequest {
    var mode: TalkMode
    var scenario: String
    var turns: [TalkTurn]
    var model = "qwen-flash"
    func body() throws -> Data {
        guard model == "qwen-flash", scenario.count <= 1000, !turns.isEmpty,
              turns.allSatisfy({ !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && $0.text.count <= 6000 }) else { throw TalkError.invalidResponse }
        var messages = [["role": "system", "content": mode.instruction(scenario: scenario)]]
        messages += turns.suffix(8).map { ["role": $0.role.rawValue, "content": $0.text] }
        return try JSONSerialization.data(withJSONObject: ["model": model, "stream": true, "enable_thinking": false,
                                                           "max_tokens": 300, "messages": messages])
    }
}

enum TalkError: Error, Equatable {
    case unauthorized, quota, rateLimited, offline, interrupted, invalidResponse, setup, recognition
    var message: String {
        switch self {
        case .unauthorized: "Check your provider key in Settings."
        case .quota: "Check your remaining quota in your provider account."
        case .rateLimited: "Wait a moment before trying again."
        case .offline: "Connect to the internet and try again."
        case .interrupted: "The connection ended before the reply finished."
        case .invalidResponse: "The reply could not be read."
        case .setup: "Check your AI setup in Settings."
        case .recognition: "Allow microphone and speech access, then try again."
        }
    }
    static func status(_ status: Int) -> TalkError? {
        switch status { case 200: nil; case 401: .unauthorized; case 402, 403: .quota; case 429: .rateLimited; default: .interrupted }
    }
}

/// SSE framing is separate from the transport so split packets, comments and termination are testable.
struct TalkSSEParser {
    private var dataLines: [String] = []
    private(set) var done = false
    mutating func line(_ line: String) throws -> String? {
        guard !done else { return nil }
        if line.isEmpty {
            guard !dataLines.isEmpty else { return nil }
            let payload = dataLines.joined(separator: "\n"); dataLines = []
            if payload == "[DONE]" { done = true; return nil }
            guard let data = payload.data(using: .utf8),
                  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any], object["error"] == nil,
                  let choices = object["choices"] as? [[String: Any]] else { throw TalkError.invalidResponse }
            if choices.isEmpty { return nil } // optional usage frame
            guard let choice = choices.first, choice["index"] as? Int == 0,
                  let delta = choice["delta"] as? [String: Any], delta["tool_calls"] == nil,
                  choice["finish_reason"] as? String != "content_filter" else { throw TalkError.invalidResponse }
            return delta["content"] as? String
        }
        if line.hasPrefix("data:") {
            var value = String(line.dropFirst(5)); if value.first == " " { value.removeFirst() }
            dataLines.append(value)
            guard dataLines.reduce(0, { $0 + $1.utf8.count }) <= 64 * 1024 else { throw TalkError.invalidResponse }
        }
        return nil
    }
}
