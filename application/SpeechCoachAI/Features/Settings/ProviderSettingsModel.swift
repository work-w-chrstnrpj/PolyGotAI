import Foundation
import Observation

protocol ProviderSettingsCredentialAccess: AnyObject {
    func configuredScope() throws -> ProviderScope?
    func save(_ key: String, scope: ProviderScope) throws
    func remove(scope: ProviderScope) throws
    func containsCredential(scope: ProviderScope) throws -> Bool
}

extension ProviderCredentialStore: ProviderSettingsCredentialAccess {
    func containsCredential(scope: ProviderScope) throws -> Bool { try credential(scope: scope)?.isEmpty == false }
}

@MainActor @Observable final class ProviderSettingsModel {
    var workspace = ""
    var key = ""
    private(set) var configured: ProviderScope?
    private(set) var message: String?
    private let credentials: any ProviderSettingsCredentialAccess

    init(credentials: any ProviderSettingsCredentialAccess) { self.credentials = credentials }

    static func defaultCredentials() -> any ProviderSettingsCredentialAccess {
        #if DEBUG
        if SpeakingEnvironment.fixtureID != nil { return MemoryProviderSettingsCredentials() }
        #endif
        return ProviderCredentialStore()
    }

    func refresh() {
        do { configured = try credentials.configuredScope(); workspace = configured?.workspace ?? "" }
        catch { message = Self.notice(error) }
    }
    func save() {
        do {
            let scope = try ProviderScope(workspace: workspace)
            try credentials.save(key, scope: scope)
            configured = scope; workspace = scope.workspace; key = ""; message = "Saved on this device."
        } catch { key = ""; message = Self.notice(error) }
    }
    func testSavedValues() {
        do {
            guard let scope = try credentials.configuredScope(), try credentials.containsCredential(scope: scope) else {
                throw SpeakingProviderError.credentialMissing
            }
            message = "Saved values found."
        } catch { message = Self.notice(error) }
    }
    func remove() {
        do {
            if let configured { try credentials.remove(scope: configured) }
            configured = nil; clearDrafts(); message = "Saved key removed."
        } catch { message = Self.notice(error) }
    }
    func clearDrafts() { key = ""; workspace = "" }
    static func notice(_ error: Error) -> String {
        if let provider = error as? SpeakingProviderError { return firstSentence(provider.message) }
        switch error as? CredentialError {
        case .invalidWorkspace: return "Enter a workspace ID using letters, numbers or hyphens."
        case .invalidCredential: return "Enter a key without spaces or line breaks."
        default: return "Unlock your device and try again."
        }
    }
    static func firstSentence(_ text: String) -> String {
        guard let end = text.firstIndex(of: ".") else { return text }
        return String(text[...end])
    }
}

#if DEBUG
/// Synthetic UI and unit tests never open the real Keychain.
final class MemoryProviderSettingsCredentials: ProviderSettingsCredentialAccess {
    private var scope: ProviderScope?
    private var key: String?
    func configuredScope() throws -> ProviderScope? { scope }
    func save(_ value: String, scope: ProviderScope) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...4096).contains(trimmed.utf8.count), trimmed.utf8.allSatisfy({ (33...126).contains($0) }) else {
            throw CredentialError.invalidCredential
        }
        guard self.scope == nil || self.scope == scope else { throw CredentialError.inconsistentSetup }
        self.scope = scope; key = trimmed
    }
    func remove(scope: ProviderScope) throws { if self.scope == scope { self.scope = nil; key = nil } }
    func containsCredential(scope: ProviderScope) throws -> Bool { self.scope == scope && key != nil }
}
#endif
