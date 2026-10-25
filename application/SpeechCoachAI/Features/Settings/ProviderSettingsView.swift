import SwiftUI

struct ProviderSettingsView: View {
    @State private var workspace = ""
    @State private var key = ""
    @State private var configured: ProviderScope?
    @State private var message: String?
    @State private var showRemoval = false
    @State private var showCheck = false
    @State private var checking = false
    @State private var checkTask: Task<Void, Never>?
    private var canCheck: Bool {
        guard let configured else { return false }
        return ProviderVerification.bundled?.permits(configured) == true
    }
    @FocusState private var keyFocused: Bool
    private let credentials = ProviderCredentialStore()

    var body: some View {
        Form {
            Section("Your provider account") {
                Text("Alibaba Cloud Model Studio · Singapore")
                Text("Your provider account pays for usage. Saving a key does not test it, make a request or upload a recording.")
                    .foregroundStyle(Kit.secondary)
                TextField("Workspace ID", text: $workspace)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                    .disabled(configured != nil).accessibilityIdentifier("provider.workspace")
                SecureField(configured == nil ? "API key" : "Replacement API key", text: $key)
                    .textContentType(.password).textInputAutocapitalization(.never).autocorrectionDisabled()
                    .focused($keyFocused).privacySensitive().accessibilityIdentifier("provider.key")
                Button(configured == nil ? "Save key on this device" : "Replace saved key") { save() }
                    .disabled(key.isEmpty || workspace.isEmpty).accessibilityIdentifier("provider.save")
                if configured != nil {
                    Label("A key is saved on this device. Its validity has not been checked.", systemImage: "key.fill")
                        .accessibilityIdentifier("provider.saved")
                    Button("Remove saved key", role: .destructive) { showRemoval = true }
                        .accessibilityIdentifier("provider.remove")
                }
            }
            Section("Online availability") {
                Label(canCheck ? "Ready for explicit submissions" : "Online requests await verification", systemImage: canCheck ? "network" : "network.slash")
                if canCheck {
                    if checking { ProgressView("Checking text connection") }
                    Button("Review connection check") { showCheck = true }.disabled(checking)
                    Text(ProviderVerification.bundled?.retentionDisclosure ?? "").font(.footnote)
                }
                Text("Provider account permissions, model access, processing and quota protection must be verified before connection checks or feedback. Recording and self-review stay available without a key.")
                    .foregroundStyle(Kit.secondary)
            }
            Section("Privacy and control") {
                Text("Your key stays in Apple Keychain on this device and is available only while unlocked. It is not included in learning history or exports.")
                Text("Removing the local key does not revoke it with the provider and does not delete your recordings. To change workspaces, remove the current local key first.")
                    .foregroundStyle(Kit.secondary)
            }
            if let message { Section { Text(message).accessibilityIdentifier("provider.message") } }
        }
        .navigationTitle("Provider setup").navigationBarTitleDisplayMode(.inline)
        .foregroundStyle(Kit.ink)
        .confirmationDialog("Remove the saved key from this device?", isPresented: $showRemoval, titleVisibility: .visible) {
            Button("Remove key", role: .destructive) {
                guard let configured else { return }
                do {
                    try credentials.remove(scope: configured)
                    self.configured = nil; key = ""; message = "Local key removed. Your learning data is unchanged."
                } catch { message = "The key could not be removed. Unlock your device and try again." }
            }
            Button("Keep key", role: .cancel) { }
        }
        .onAppear { refresh() }
        .alert("Check the text-coaching connection?", isPresented: $showCheck) {
            Button("Send connection check") { checkConnection() }
            Button("Cancel", role: .cancel) { }
        } message: { Text("This sends a fixed test phrase to Alibaba Cloud Model Studio in Singapore using your key. It may be billed to your provider account. No recording or learner text is sent; there is no automatic retry.") }
        .onDisappear { key = ""; checkTask?.cancel() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            key = ""; keyFocused = false; checkTask?.cancel()
        }
    }

    private func checkConnection() {
        guard canCheck, let scope = configured, !checking else { return }
        checking = true
        checkTask = Task {
            defer { checking = false; checkTask = nil }
            do {
                let body = try JSONSerialization.data(withJSONObject: ["model": "qwen-flash", "stream": false,
                    "enable_thinking": false, "messages": [["role": "user", "content": "Reply with OK only. This is a connection check."]]])
                let response = try await SpeakingProviderClient().send(body: body, scope: scope, stage: .coaching)
                let result = try ProviderCompletionContent(response: response, expectedModel: "qwen-flash", maximumScalars: 100)
                guard result.text.trimmingCharacters(in: .whitespacesAndNewlines) == "OK" else { throw SpeakingProviderError.invalidResponse }
                message = "Text-coaching connection responded. Transcription and feedback quality still require their own checks."
            } catch { message = (error as? SpeakingProviderError ?? .unknownOutcome).message }
        }
    }

    private func refresh() {
        do {
            configured = try credentials.configuredScope()
            if let configured { workspace = configured.workspace }
        } catch { message = "Provider setup is unavailable. Unlock your device and try again. Offline practice remains available." }
    }
    private func save() {
        do {
            let scope = try ProviderScope(workspace: workspace)
            try credentials.save(key, scope: scope)
            key = ""; keyFocused = false; configured = scope; workspace = scope.workspace
            message = "Key saved locally. No connection check or upload was made."
        } catch CredentialError.invalidWorkspace {
            message = "Enter the workspace ID only, using letters, numbers or hyphens. Do not enter a URL."
        } catch CredentialError.invalidCredential {
            message = "Enter a nonempty API key without spaces or line breaks."
        } catch {
            key = ""; message = "The key could not be saved. Any previous saved key is kept. Unlock your device and try again."
        }
    }
}
