import Foundation

// ADR-0013 (#10): each job has a ranked list of free-quota models. Only Alibaba's free-quota error
// (HTTP 403 AllocationQuota.FreeTierOnly) moves a request on to the next model; every other error stops at once.

/// The code Alibaba returns when Stop-on-Exhaust (Free Only) blocks a model whose free quota is used up.
nonisolated enum FreeTierOnlyReply {
    static let code = "AllocationQuota.FreeTierOnly"

    /// True when a 403 body carries the free-quota code, either at the top level or under `error`.
    static func matches(_ body: Data) -> Bool {
        guard body.count <= 64 * 1024, let object = try? JSONSerialization.jsonObject(with: body) as? [String: Any] else { return false }
        if object["code"] as? String == code { return true }
        return (object["error"] as? [String: Any])?["code"] as? String == code
    }
}

/// Remembers which models ran out of free quota today, on this device. A spent model is skipped until the next local day.
struct FreeQuotaLedger {
    static let key = "provider.freeQuota.spentOn"
    static var shared: FreeQuotaLedger { FreeQuotaLedger(defaults: .standard, now: { .now }) }

    let defaults: UserDefaults
    let now: () -> Date
    var calendar = Calendar.current

    private var today: String {
        let parts = calendar.dateComponents([.year, .month, .day], from: now())
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    func isSpent(_ model: String) -> Bool {
        (defaults.dictionary(forKey: Self.key) as? [String: String])?[model] == today
    }

    func markSpent(_ model: String) {
        var spent = (defaults.dictionary(forKey: Self.key) as? [String: String]) ?? [:]
        let day = today
        spent = spent.filter { $0.value == day } // Older days no longer matter.
        spent[model] = day
        defaults.set(spent, forKey: Self.key)
    }

    /// The models to try today, in ranked order.
    func available(_ models: [String]) -> [String] { models.filter { !isSpent($0) } }
}

/// A reply together with the model it was sent to. Each reader checks the envelope's model against `model`.
struct ProviderReply {
    let data: Data
    let model: String
}

nonisolated enum ProviderModelID {
    /// Lower-case model codes as the console shows them, for example `qwen3.5-flash` or `qwen-audio-3.0-asr-flash`.
    static func isValid(_ model: String) -> Bool {
        let bytes = Array(model.utf8)
        guard (1...64).contains(bytes.count), let first = bytes.first, (97...122).contains(first) || (48...57).contains(first) else { return false }
        return bytes.allSatisfy { (97...122).contains($0) || (48...57).contains($0) || $0 == 45 || $0 == 46 || $0 == 95 }
    }

    /// The same request body with only its `model` changed.
    static func body(_ body: Data, model: String) throws -> Data {
        guard var object = try JSONSerialization.jsonObject(with: body) as? [String: Any] else { throw SpeakingProviderError.invalidResponse }
        object["model"] = model
        return try JSONSerialization.data(withJSONObject: object)
    }

    static func model(in body: Data) -> String? {
        (try? JSONSerialization.jsonObject(with: body) as? [String: Any])?["model"] as? String
    }
}

extension SpeakingProvider {
    /// The models to try for a request: the verified ranked list, or the body's own model when no list is set
    /// (the real client then refuses it at the gate).
    func rankedModels(for stage: SpeakingRequestStage, body: Data) -> [String] {
        let listed = verification?.models(for: stage) ?? []
        if !listed.isEmpty { return listed }
        return ProviderModelID.model(in: body).map { [$0] } ?? []
    }

    /// Sends one request down the ranked list for its job. A model that answers with the free-quota error is marked spent
    /// for today and the same request goes to the next model, once per model. Any other error is thrown at once.
    /// When no model is left, throws `quotaExhausted` and sends nothing more.
    func sendRouted(body: Data, scope: ProviderScope, stage: SpeakingRequestStage, ledger: FreeQuotaLedger = .shared) async throws -> ProviderReply {
        for model in ledger.available(rankedModels(for: stage, body: body)) {
            try Task.checkCancellation()
            let routed = try ProviderModelID.body(body, model: model)
            do {
                return ProviderReply(data: try await send(body: routed, scope: scope, stage: stage), model: model)
            } catch SpeakingProviderError.freeQuotaExhausted {
                ledger.markSpent(model)
            }
        }
        throw SpeakingProviderError.quotaExhausted
    }
}
