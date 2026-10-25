import Foundation

enum GeneratedPracticeTransportError: Error, Equatable {
    case cancelled, failed, unknownOutcome, offline
}

/// Prepares one practice variation through an injected transport.
/// This type does not open a connection, read a credential, or send a request twice.
struct GeneratedPracticeClient: Sendable {
    static let forbiddenEnvelopeKeys: Set<String> = [
        "apiKey", "authorization", "credential", "learnerResponse", "transcript", "audio", "prompt"
    ]

    func submit(
        _ session: GeneratedPracticeSession,
        policy: GenerationPolicy?,
        connected: Bool,
        now: Date,
        beforeSend: (@Sendable (GeneratedPracticeRecord) -> Bool)?,
        send: (@Sendable (Data) async throws -> Data)?
    ) async -> GeneratedPracticeSession {
        var session = session
        guard !Task.isCancelled else { session.lastRefusal = .cancelled; return session }
        guard let send else { session.lastRefusal = .liveCallBlocked; return session }
        let began = session.beginFresh(policy: policy, connected: connected, now: now)
        guard began == nil, session.phase == .awaiting, let requestID = session.requestID, session.envelope != nil else {
            return session
        }
        guard let beforeSend, beforeSend(session.durableRecord()), session.consumeTransportAttempt(requestID) else {
            session.requests[requestID] = .failed
            session.phase = .failed
            session.working.unresolvedRequestID = nil
            session.lastRefusal = .storageFailure
            return session
        }
        if Task.isCancelled {
            _ = session.cancelRequest()
            return session
        }
        do {
            let body = try JSONEncoder().encode(session.envelope)
            let data = try await send(body)
            if Task.isCancelled {
                _ = session.cancelRequest()
                return session
            }
            _ = session.receive(data: data, policy: policy, requestID: requestID, now: now)
        } catch is CancellationError {
            _ = session.cancelRequest()
        } catch let error as GeneratedPracticeTransportError {
            switch error {
            case .cancelled:
                _ = session.cancelRequest()
            case .unknownOutcome:
                session.requests[requestID] = .unknownOutcome
                session.phase = .unknownOutcome
                session.working.unresolvedRequestID = nil
                session.lastRefusal = .unknownOutcome
            case .offline:
                session.requests[requestID] = .failed
                session.phase = .failed
                session.working.unresolvedRequestID = nil
                session.lastRefusal = .offline
            case .failed:
                session.requests[requestID] = .failed
                session.phase = .failed
                session.working.unresolvedRequestID = nil
                session.lastRefusal = .malformed
            }
        } catch {
            session.requests[requestID] = .failed
            session.phase = .failed
            session.working.unresolvedRequestID = nil
            session.lastRefusal = .malformed
        }
        return session
    }
}
