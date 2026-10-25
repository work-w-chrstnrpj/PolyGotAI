import Foundation
import Testing
@testable import SpeechCoachAI

struct ProviderCredentialTests {
    @Test(arguments: ["", "https://example.com", "a.b", "a/b", "a@b", "a?b", "a#b", "-bad", "bad-", "a\nb", String(repeating: "a", count: 64)])
    func untrustedWorkspaceCannotChooseAnArbitraryDestination(_ workspace: String) {
        #expect(throws: CredentialError.self) { try ProviderScope(workspace: workspace) }
    }

    @Test func documentedWorkspaceProducesOnlyTheFixedSingaporeEndpoint() throws {
        let scope = try ProviderScope(workspace: "  Synthetic-123  ")
        #expect(scope.workspace == "synthetic-123")
        #expect(scope.endpoint.scheme == "https")
        #expect(scope.endpoint.host == "synthetic-123.ap-southeast-1.maas.aliyuncs.com")
        #expect(scope.endpoint.path == "/compatible-mode/v1/chat/completions")
        #expect(scope.endpoint.query == nil && scope.endpoint.user == nil && scope.endpoint.port == nil)
    }

    @Test func realKeychainLifecycleUsesIsolatedSyntheticCredentialAndProtection() throws {
        let store = ProviderCredentialStore(service: "SC-T012-synthetic-\(UUID().uuidString)")
        let scope = try ProviderScope(workspace: "synthetic-workspace")
        defer { try? store.remove(scope: scope) }
        #expect(try store.configuredScope() == nil)
        try store.save("synthetic-first-fixture-value", scope: scope)
        #expect(try store.configuredScope() == scope)
        #expect(try store.hasRequiredProtection(scope: scope))
        #expect(try store.credential(scope: scope) == Data("synthetic-first-fixture-value".utf8))
        try store.save("synthetic-replacement-fixture", scope: scope)
        #expect(try store.credential(scope: scope) == Data("synthetic-replacement-fixture".utf8))
        #expect(throws: CredentialError.self) { try store.save("bad\nheader", scope: scope) }
        #expect(try store.credential(scope: scope) == Data("synthetic-replacement-fixture".utf8))
        let other = try ProviderScope(workspace: "other-fixture-workspace")
        #expect(throws: CredentialError.self) { try store.save("another-synthetic-value", scope: other) }
        #expect(try store.configuredScope() == scope)
        try store.remove(scope: scope)
        #expect(try store.configuredScope() == nil && store.credential(scope: scope) == nil)
        try store.remove(scope: scope) // Removal is idempotent and never touches learning data.
    }
}
