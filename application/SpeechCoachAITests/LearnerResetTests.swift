import Foundation
import Testing
@testable import SpeechCoachAI

/// Settings › Erase all data (Phase 7, C5). Isolated folder, Keychain service and defaults suite only.
@MainActor @Suite(.serialized)
struct LearnerResetTests {
    private struct Fake: OwnerAuthenticator {
        var outcome: LearnerResetError?
        func authenticate(reason: String) async throws { if let outcome { throw outcome } }
    }

    private struct Fixture {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-reset-\(UUID().uuidString)", isDirectory: true)
        let suite = "SC-reset-defaults-\(UUID().uuidString)"
        let credentials = ProviderCredentialStore(service: "SC-reset-synthetic-\(UUID().uuidString)")
        let storage: LearnerStorageController
        let defaults: UserDefaults

        init() throws {
            storage = LearnerStorageController(root: root)
            defaults = UserDefaults(suiteName: suite)!
            storage.open()
            var preferences = storage.preferences
            preferences.background = .mixedMediaStudio
            storage.savePreferences(preferences)
            try FileManager.default.createDirectory(at: root.appendingPathComponent("Recordings"), withIntermediateDirectories: true)
            try Data("synthetic".utf8).write(to: root.appendingPathComponent("Recordings/take.m4a"))
            defaults.set(42, forKey: "usage.pending")
            try credentials.save("synthetic-key-123", scope: ProviderScope(workspace: "synthetic"))
        }

        func erase(_ authenticator: Fake) async throws {
            try await LearnerReset.erase(storage: storage, authenticator: authenticator, credentials: credentials,
                                         defaults: defaults, defaultsDomain: suite)
        }

        func cleanUp() {
            storage.close()
            try? FileManager.default.removeItem(at: root)
            try? credentials.removeAll()
            UserDefaults().removePersistentDomain(forName: suite)
            KitTheme.current = .academy
        }
    }

    @Test func confirmedEraseRemovesEverythingAndReopensFresh() async throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        #expect(fixture.storage.preferences.background == .mixedMediaStudio)

        try await fixture.erase(Fake(outcome: nil))

        #expect(fixture.storage.repository != nil)
        #expect(fixture.storage.hasStorageFailure == false)
        #expect(fixture.storage.preferences == LearnerPreferences())
        #expect(!FileManager.default.fileExists(atPath: fixture.root.appendingPathComponent("Recordings/take.m4a").path))
        #expect(fixture.defaults.object(forKey: "usage.pending") == nil)
        #expect(try fixture.credentials.configuredScope() == nil)
        #expect(KitTheme.current == .academy)
    }

    @Test(arguments: [LearnerResetError.cancelled, .failed, .unavailable])
    func withoutConfirmationNothingIsErased(_ outcome: LearnerResetError) async throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }

        await #expect(throws: outcome) { try await fixture.erase(Fake(outcome: outcome)) }

        #expect(fixture.storage.preferences.background == .mixedMediaStudio)
        #expect(FileManager.default.fileExists(atPath: fixture.root.appendingPathComponent("Recordings/take.m4a").path))
        #expect(fixture.defaults.integer(forKey: "usage.pending") == 42)
        #expect(try fixture.credentials.configuredScope() != nil)
    }

    @Test func cancellingShowsNoMessage() {
        #expect(LearnerResetError.cancelled.message == nil)
        #expect(LearnerResetError.unavailable.message != nil)
    }
}
