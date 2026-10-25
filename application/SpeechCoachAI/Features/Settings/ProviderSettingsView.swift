import SwiftUI

struct ProviderSettingsView: View {
    @State private var model: ProviderSettingsModel
    @State private var showRemoval = false
    @State private var showPrivacy = false
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var focused: Bool

    init(credentials: (any ProviderSettingsCredentialAccess)? = nil) {
        _model = State(initialValue: ProviderSettingsModel(credentials: credentials ?? ProviderSettingsModel.defaultCredentials()))
    }

    var body: some View {
        Form {
            Section("Alibaba Cloud · Singapore") {
                SecureField("Workspace ID", text: $model.workspace)
                    .textInputAutocapitalization(.never).autocorrectionDisabled().privacySensitive()
                    .disabled(model.configured != nil).accessibilityIdentifier("provider.workspace")
                SecureField(model.configured == nil ? "API key" : "Replacement API key", text: $model.key)
                    .textContentType(.password).textInputAutocapitalization(.never).autocorrectionDisabled()
                    .focused($focused).privacySensitive().accessibilityIdentifier("provider.key")
                Button(model.configured == nil ? "Save key" : "Replace key") { model.save(); focused = false }
                    .disabled(model.key.isEmpty || model.workspace.isEmpty).accessibilityIdentifier("provider.save")
                Button("Test") { model.testSavedValues() }.accessibilityIdentifier("provider.test")
                Text("Checks saved values on this device.").font(.footnote).foregroundStyle(Kit.secondary)
                if model.configured != nil {
                    Label("Key saved", systemImage: "key.fill").accessibilityIdentifier("provider.saved")
                    Button("Remove key", role: .destructive) { showRemoval = true }.accessibilityIdentifier("provider.remove")
                }
            }
            Section("Privacy") {
                Text("Your key stays in Keychain on this device.")
                if let scope = model.configured, ProviderVerification.bundled?.permits(scope) == true {
                    Button("Cost and privacy") { showPrivacy = true }.accessibilityIdentifier("provider.privacy")
                }
            }
            if let message = model.message { Section { Text(message).accessibilityIdentifier("provider.message") } }
        }
        .navigationTitle("Provider setup").navigationBarTitleDisplayMode(.inline).foregroundStyle(Kit.ink)
        .confirmationDialog("Remove the saved key?", isPresented: $showRemoval, titleVisibility: .visible) {
            Button("Remove key", role: .destructive) { model.remove() }
            Button("Keep key", role: .cancel) { }
        }
        .sheet(isPresented: $showPrivacy) {
            AIFeedbackPrivacyView(disclosure: .current(mode: .speaking, includesAudio: false),
                retention: ProviderVerification.bundled?.retentionDisclosure)
        }
        .onAppear { model.refresh() }
        .onDisappear { model.clearDrafts() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { model.clearDrafts(); focused = false }
            else { model.refresh() }
        }
    }
}
