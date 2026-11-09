import Foundation

@MainActor protocol TalkStreaming {
    func stream(_ request: TalkRequest, receive: @escaping @MainActor (String) -> Void) async throws
}

nonisolated private final class TalkNoRedirects: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest, completionHandler: @escaping @Sendable (URLRequest?) -> Void) { completionHandler(nil) }
}

@MainActor final class TalkStreamingClient: TalkStreaming {
    let scope: ProviderScope
    let verification: ProviderVerification?
    let credentials: ProviderCredentialStore
    let ledger: FreeQuotaLedger
    init(scope: ProviderScope, verification: ProviderVerification? = .bundled, credentials: ProviderCredentialStore = .init(),
         ledger: FreeQuotaLedger = .shared) {
        self.scope = scope; self.verification = verification; self.credentials = credentials; self.ledger = ledger
    }
    static func local() -> TalkStreamingClient? {
        #if DEBUG
        if SpeakingEnvironment.fixtureID != nil { return nil }
        #endif
        let credentials = ProviderCredentialStore()
        guard let scope = try? credentials.configuredScope(), let verification = ProviderVerification.bundled,
              verification.permits(scope), (try? credentials.credential(scope: scope)?.isEmpty) == false else { return nil }
        return TalkStreamingClient(scope: scope, verification: verification, credentials: credentials)
    }
    /// Sends the turns to the first ranked model with free quota left. A free-quota reply, which comes before any text,
    /// moves the same turns to the next model; any other error stops (ADR-0013).
    func stream(_ request: TalkRequest, receive: @escaping @MainActor (String) -> Void) async throws {
        guard let verification, verification.permits(scope) else { throw TalkError.setup }
        guard let data = try credentials.credential(scope: scope), let key = String(data: data, encoding: .utf8) else { throw TalkError.setup }
        for model in ledger.available(verification.models(for: .coaching)) {
            var routed = request; routed.model = model
            do { return try await stream(routed, key: key, receive: receive) }
            catch TalkError.freeQuota { ledger.markSpent(model) }
        }
        throw TalkError.quota
    }

    private func stream(_ request: TalkRequest, key: String, receive: @escaping @MainActor (String) -> Void) async throws {
        let body = try request.body()
        try Task.checkCancellation()
        let config = SpeakingProviderClient.configuration(for: .coaching)
        let session = URLSession(configuration: config, delegate: TalkNoRedirects(), delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        var outbound = URLRequest(url: scope.endpoint)
        outbound.httpMethod = "POST"; outbound.httpBody = body
        outbound.setValue("application/json", forHTTPHeaderField: "Content-Type")
        outbound.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        outbound.setValue("Bearer " + key, forHTTPHeaderField: "Authorization")
        do {
            let (bytes, response) = try await session.bytes(for: outbound)
            guard let response = response as? HTTPURLResponse, response.url == scope.endpoint else { throw TalkError.invalidResponse }
            if response.statusCode != 200 {
                var errorBody = Data()
                if response.statusCode == 403 {
                    for try await byte in bytes { guard errorBody.count < 16 * 1024 else { break }; errorBody.append(byte) }
                }
                throw TalkError.from(status: response.statusCode, body: errorBody) ?? .interrupted
            }
            guard response.value(forHTTPHeaderField: "Content-Type")?.lowercased().hasPrefix("text/event-stream") == true else { throw TalkError.invalidResponse }
            var parser = TalkSSEParser(), line = Data(), count = 0
            // Byte framing caps even an unterminated line; AsyncBytes.lines has no line-size limit.
            for try await byte in bytes {
                try Task.checkCancellation(); count += 1
                guard count <= 256 * 1024, line.count <= 64 * 1024 else { throw TalkError.invalidResponse }
                if byte == 10 {
                    if line.last == 13 { line.removeLast() }
                    guard let text = String(data: line, encoding: .utf8) else { throw TalkError.invalidResponse }
                    line.removeAll(keepingCapacity: true)
                    if let delta = try parser.line(text), !delta.isEmpty { receive(delta) }
                    if parser.done { break }
                } else { line.append(byte) }
            }
            guard parser.done else { throw TalkError.interrupted }
        } catch is CancellationError { throw CancellationError() }
        catch let error as TalkError { throw error }
        catch let error as URLError {
            if error.code == .cancelled { throw CancellationError() }
            throw error.code == .notConnectedToInternet ? TalkError.offline : TalkError.interrupted
        } catch { throw TalkError.interrupted }
    }
}

#if DEBUG
@MainActor final class TalkFixtureClient: TalkStreaming {
    static var enabled: Bool { SpeakingEnvironment.fixtureID != nil && ProcessInfo.processInfo.environment["SC_TALK_FIXTURE"] == "1" }
    func stream(_ request: TalkRequest, receive: @escaping @MainActor (String) -> Void) async throws {
        let reply = request.mode == .interview ? "Thank you for that example. What did you learn from it?" : "That sounds interesting. Tell me a little more about it."
        for word in reply.split(separator: " ") {
            try await Task.sleep(for: .milliseconds(50)); try Task.checkCancellation(); receive(String(word) + " ")
        }
    }
}
#endif
