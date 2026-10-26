import Foundation
import LocalAuthentication

/// Confirms the device owner (Face ID, Touch ID, or the device passcode when biometrics fail).
protocol OwnerAuthenticator {
    func authenticate(reason: String) async throws
}

enum LearnerResetError: Error, Equatable {
    /// The owner cancelled the prompt. Show nothing.
    case cancelled
    /// The device has no passcode or biometrics set up.
    case unavailable
    /// The owner could not be confirmed.
    case failed
    /// Some files could not be removed.
    case eraseFailed

    /// One plain sentence for the Settings screen; nil when nothing should be shown.
    var message: String? {
        switch self {
        case .cancelled: nil
        case .unavailable: "Set up a passcode on this device to erase data."
        case .failed: "Your identity could not be confirmed."
        case .eraseFailed: "Some data could not be erased. Try again."
        }
    }
}

struct DeviceOwnerAuthenticator: OwnerAuthenticator {
    func authenticate(reason: String) async throws {
        let context = LAContext()
        var problem: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &problem) else { throw LearnerResetError.unavailable }
        do {
            _ = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .appCancel, .systemCancel: throw LearnerResetError.cancelled
            case .passcodeNotSet, .biometryNotEnrolled, .biometryNotAvailable: throw LearnerResetError.unavailable
            default: throw LearnerResetError.failed
            }
        } catch {
            throw LearnerResetError.failed
        }
    }
}

#if DEBUG
/// UI tests set `SC_OWNER_AUTH` to "pass" or "cancel" so the erase flow runs without a real prompt.
struct FixtureOwnerAuthenticator: OwnerAuthenticator {
    var passes: Bool
    func authenticate(reason: String) async throws { if !passes { throw LearnerResetError.cancelled } }
}
#endif

/// Settings › Erase all data (owner request 2026-10-26).
enum LearnerReset {
    static let reason = "Erase all your progress, words, recordings and settings."

    static var defaultAuthenticator: OwnerAuthenticator {
        #if DEBUG
        if let mode = ProcessInfo.processInfo.environment["SC_OWNER_AUTH"] { return FixtureOwnerAuthenticator(passes: mode == "pass") }
        #endif
        return DeviceOwnerAuthenticator()
    }

    /// Asks the device owner, then erases the store and private files, the provider key and saved settings,
    /// and reopens storage as a first launch.
    @MainActor
    static func erase(storage: LearnerStorageController,
                      authenticator: OwnerAuthenticator = LearnerReset.defaultAuthenticator,
                      credentials: ProviderCredentialStore = ProviderCredentialStore(),
                      defaults: UserDefaults = .standard,
                      defaultsDomain: String? = Bundle.main.bundleIdentifier) async throws {
        try await authenticator.authenticate(reason: reason)
        var failed = false
        do { try credentials.removeAll() } catch { failed = true }
        if let defaultsDomain { defaults.removePersistentDomain(forName: defaultsDomain) }
        do { try storage.eraseAllLearnerFiles() } catch { failed = true }
        SpeechSynthesizer.shared.stop()
        if failed { throw LearnerResetError.eraseFailed }
    }
}
