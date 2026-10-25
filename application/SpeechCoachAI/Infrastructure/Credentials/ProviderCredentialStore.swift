import Foundation
import Security

enum CredentialError: Error { case invalidWorkspace, invalidCredential, locked, unavailable, inconsistentSetup }

/// Only the documented Singapore workspace host can be constructed. No arbitrary URLs.
struct ProviderScope: Equatable {
    let workspace: String
    init(workspace: String) throws {
        let value = workspace.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let bytes = Array(value.utf8)
        func alphanumeric(_ byte: UInt8) -> Bool { (97...122).contains(byte) || (48...57).contains(byte) }
        guard (1...63).contains(bytes.count), let first = bytes.first, let last = bytes.last,
              alphanumeric(first), alphanumeric(last), bytes.allSatisfy({ alphanumeric($0) || $0 == 45 }) else {
            throw CredentialError.invalidWorkspace
        }
        self.workspace = value
    }
    var account: String { "singapore:\(workspace)" }
    var endpoint: URL {
        // Validation above guarantees this fixed HTTPS URL is well formed.
        URL(string: "https://\(workspace).ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1/chat/completions")!
    }
}

/// Credentials never enter SwiftData, preferences, diagnostics or UI status messages.
/// Tests supply an isolated service name and synthetic values only.
final class ProviderCredentialStore {
    private let service: String
    init(service: String = "com.personal.SpeechCoachAI.modelstudio.credentials") { self.service = service }

    func configuredScope() throws -> ProviderScope? {
        var query = baseQuery()
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        try check(status)
        guard let rows = result as? [[String: Any]], rows.count == 1,
              let account = rows[0][kSecAttrAccount as String] as? String,
              account.hasPrefix("singapore:") else { throw CredentialError.inconsistentSetup }
        return try ProviderScope(workspace: String(account.dropFirst("singapore:".count)))
    }

    func save(_ input: String, scope: ProviderScope) throws {
        let key = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...4096).contains(key.utf8.count), key.utf8.allSatisfy({ (33...126).contains($0) }) else {
            throw CredentialError.invalidCredential
        }
        if let existing = try configuredScope(), existing != scope { throw CredentialError.inconsistentSetup }
        var query = baseQuery(); query[kSecAttrAccount as String] = scope.account
        let value: [String: Any] = [kSecValueData as String: Data(key.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly]
        let updated = SecItemUpdate(query as CFDictionary, value as CFDictionary)
        if updated == errSecItemNotFound {
            for (field, content) in value { query[field] = content }
            try check(SecItemAdd(query as CFDictionary, nil))
        } else { try check(updated) } // Never delete an existing key before a replacement succeeds.
    }

    func remove(scope: ProviderScope) throws {
        var query = baseQuery(); query[kSecAttrAccount as String] = scope.account
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecItemNotFound { try check(status) }
    }

    /// Only the eventual authorized transport consumes key bytes; no public display accessor.
    func credential(scope: ProviderScope) throws -> Data? {
        var query = baseQuery(); query[kSecAttrAccount as String] = scope.account
        query[kSecReturnData as String] = true; query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        try check(status)
        guard let data = result as? Data else { throw CredentialError.unavailable }
        return data
    }

    func hasRequiredProtection(scope: ProviderScope) throws -> Bool {
        var query = baseQuery(); query[kSecAttrAccount as String] = scope.account
        query[kSecReturnAttributes as String] = true
        var result: CFTypeRef?
        try check(SecItemCopyMatching(query as CFDictionary, &result))
        guard let attributes = result as? [String: Any] else { throw CredentialError.unavailable }
        return attributes[kSecAttrAccessible as String] as? String == kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
            && (attributes[kSecAttrSynchronizable as String] as? Bool ?? false) == false
    }

    private func baseQuery() -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service,
         kSecAttrSynchronizable as String: false, kSecUseDataProtectionKeychain as String: true]
    }
    private func check(_ status: OSStatus) throws {
        guard status != errSecSuccess else { return }
        if status == errSecInteractionNotAllowed || status == errSecNotAvailable { throw CredentialError.locked }
        throw CredentialError.unavailable
    }
}
