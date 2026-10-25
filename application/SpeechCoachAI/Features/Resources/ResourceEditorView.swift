import SwiftUI

struct ResourceEditorView: View {
    var storage: LearnerStorageController
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var confirmDiscard = false
    @State private var resetMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                if storage.resourceDraft != nil {
                    Section("Bookmark") {
                        field("Title", key: \.title, id: "title")
                        VStack(alignment: .leading, spacing: 8) {
                            Text("HTTPS link").font(.caption).foregroundStyle(Kit.secondary)
                            TextField("https://…", text: binding(\.destination), axis: .vertical)
                                .keyboardType(.URL).textInputAutocapitalization(.never).autocorrectionDisabled()
                                .accessibilityLabel("HTTPS link").accessibilityIdentifier("resources.editor.url")
                        }
                        field("Topic, optional", key: \.topic, id: "topic")
                    }
                    Section {
                        TextEditor(text: binding(\.notes)).frame(minHeight: 140)
                            .accessibilityLabel("Personal notes").accessibilityIdentifier("resources.editor.notes")
                    } header: { Text("Personal notes, optional") }
                    Section {
                        Text("No thumbnail or page content is downloaded. A saved link does not make the website available offline.")
                            .foregroundStyle(Kit.secondary)
                    }
                    if let message = storage.resourceDraft?.message {
                        Section { Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("resources.editor.error") }
                    }
                } else {
                    Text(resetMessage ?? "This draft is no longer available. Return to the library to start again.")
                        .accessibilityIdentifier("resources.editor.reset")
                }
            }
            .navigationTitle(storage.resourceDraft?.original == nil ? "Add resource" : "Edit resource")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundStyle(Kit.ink)
            .tint(Kit.accent)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if storage.resourceDraft?.isDirty == true { confirmDiscard = true }
                        else { storage.resourceDraft = nil; dismiss() }
                    }.accessibilityIdentifier("resources.editor.cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if storage.saveResourceDraft() { onSave(); dismiss() }
                        else if storage.resourceDraft == nil { resetMessage = "Learning data was reset. The old draft was discarded." }
                    }
                    .disabled(storage.resourceDraft == nil)
                    .accessibilityIdentifier("resources.editor.save")
                }
            }
            .alert("Discard unsaved changes?", isPresented: $confirmDiscard) {
                Button("Discard changes", role: .destructive) { storage.resourceDraft = nil; dismiss() }
                Button("Keep editing", role: .cancel) { }
            }
            .onAppear(perform: checkEpoch)
            .onChange(of: scenePhase) { _, phase in if phase == .active { checkEpoch() } }
        }
        .preferredColorScheme(storage.preferences.appearance.colorScheme)
        .interactiveDismissDisabled(storage.resourceDraft?.isDirty == true)
    }

    private func field(_ title: String, key: WritableKeyPath<ResourceEditorDraft, String>, id: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(Kit.secondary)
            TextField(title, text: binding(key), axis: .vertical)
                .accessibilityLabel(title).accessibilityIdentifier("resources.editor.\(id)")
        }
    }

    private func binding(_ key: WritableKeyPath<ResourceEditorDraft, String>) -> Binding<String> {
        Binding(get: { storage.resourceDraft?[keyPath: key] ?? "" }, set: { value in
            storage.resourceDraft?[keyPath: key] = value
            storage.resourceDraft?.message = nil
        })
    }

    private func checkEpoch() {
        do { try storage.validateResourceDraftEpoch() }
        catch LearnerStorageError.staleVersion { resetMessage = "Learning data was reset. The old draft was discarded." }
        catch { storage.resourceDraft?.message = "Local data is unavailable. Your edits are kept here. Try again after unlocking your device." }
    }
}
