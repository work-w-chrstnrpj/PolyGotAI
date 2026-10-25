import SwiftUI

struct SettingsView: View {
    @Bindable var storage: LearnerStorageController
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Form {
            Section {
                Text("A little more you, in English.").font(.headline)
            }
            Section("Make it yours") {
                NavigationLink { AppearanceSettings(storage: storage) } label: {
                    LabeledContent("Appearance", value: "\(storage.preferences.background.title) · \(storage.preferences.appearance.title)")
                }.accessibilityIdentifier("settings.appearance")
                NavigationLink { CoachSettings(storage: storage) } label: {
                    LabeledContent("Your coach", value: storage.preferences.coach.title)
                }.accessibilityIdentifier("settings.coach")
                Toggle("Three-second recording countdown", isOn: Binding(get: { storage.preferences.countdownEnabled }, set: { value in
                    var next = storage.preferences; next.countdownEnabled = value; storage.savePreferences(next)
                })).accessibilityIdentifier("settings.countdown")
            }
            Section("Practice rewards") {
                NavigationLink("Rewards, wallet and achievements") { RewardOverview(storage: storage) }
                    .accessibilityIdentifier("settings.rewards")
            }
            Section("Online coaching") {
                NavigationLink("Provider setup") { ProviderSettingsView() }
                    .accessibilityIdentifier("settings.provider")
                Text("No key is needed for recording and self-review. Online requests stay off until your provider account is verified.")
                    .foregroundStyle(Kit.secondary)
            }
            Section("Privacy") {
                Text("Saving a recording and saving a transcript or feedback are separate choices. Nothing uploads automatically.")
                Text("Local learning data is excluded from device backups on a best-effort basis. Device loss or uninstalling can lose local data.")
                    .foregroundStyle(Kit.secondary)
            }
            if storage.hasPreferenceSaveFailure {
                Section {
                    Label("Your change could not be saved. Your previous preference is still selected. Try the change again.", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(Kit.error)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Kit.canvas(storage.preferences.background))
        .foregroundStyle(Kit.ink)
        .navigationTitle("Profile & settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Kit.canvas(storage.preferences.background), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() }.accessibilityIdentifier("settings.done") } }
    }
}

private struct AppearanceSettings: View {
    @Bindable var storage: LearnerStorageController
    @State private var preview: LearnerPreferences.Background?
    @Environment(\.dynamicTypeSize) private var textSize
    private var selection: LearnerPreferences.Background { preview ?? storage.preferences.background }

    var body: some View {
        Form {
            Section {
                Text("Three free ways to make this space yours.").foregroundStyle(Kit.secondary)
                ForEach(LearnerPreferences.Background.allCases, id: \.self) { style in
                    Button { preview = style } label: {
                        HStack(spacing: 16) {
                            CoachArtwork(name: style.previewArtwork).frame(width: 60, height: 60)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(style.title).foregroundStyle(Kit.ink)
                                Text(selection == style ? "Preview selected" : "Preview background").font(.caption).foregroundStyle(Kit.secondary)
                            }
                            Spacer(minLength: 0)
                            if selection == style { Image(systemName: "checkmark.circle.fill").foregroundStyle(Kit.accent) }
                        }.frame(minHeight: 60)
                    }
                    .accessibilityLabel(style.title)
                    .accessibilityAddTraits(selection == style ? [.isSelected] : [])
                    .accessibilityIdentifier("background.\(style.rawValue)")
                }
                VStack(alignment: .leading, spacing: 16) {
                    Text(selection.title).font(.headline)
                    CoachArtwork(name: selection.previewArtwork).frame(height: 140)
                    Text("Your coach and color theme stay independent.").foregroundStyle(Kit.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading).padding(16)
                .background(Kit.canvas(selection), in: RoundedRectangle(cornerRadius: 18))
                Button("Apply background") {
                    var value = storage.preferences; value.background = selection
                    storage.savePreferences(value)
                }
                .buttonStyle(.borderedProminent).foregroundStyle(Color("OnAccent")).controlSize(.large)
                .disabled(storage.repository == nil)
                .accessibilityIdentifier("background.apply")
                Text("Saved background: \(storage.preferences.background.title)").font(.caption)
                    .accessibilityIdentifier("background.saved")
            } header: { Text("Background style") } footer: {
                Text("Previewing does not change your saved style. Leaving without Apply keeps your previous background.")
            }
            Section("Color theme") {
                Picker("Color theme", selection: Binding(get: { storage.preferences.appearance }, set: { theme in
                    var next = storage.preferences; next.appearance = theme; storage.savePreferences(next)
                })) {
                    ForEach(LearnerPreferences.Appearance.allCases, id: \.self) { Text($0.title).tag($0) }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("appearance.theme")
                Text("System follows your device appearance.").font(.caption).foregroundStyle(Kit.secondary)
            }
            if storage.hasPreferenceSaveFailure {
                Text("The change could not be saved. Try again; your previous preference is still selected.").foregroundStyle(Kit.error)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Kit.canvas(storage.preferences.background))
        .navigationTitle("Appearance").navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Kit.canvas(storage.preferences.background), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

private struct CoachSettings: View {
    @Bindable var storage: LearnerStorageController
    @Environment(\.dynamicTypeSize) private var textSize
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("A friendly voice for every kind of practice.").font(.title2.bold())
                Text("All seven presenters are unlocked. Choosing a coach does not change your curriculum, progress, background or voice settings.").foregroundStyle(Kit.secondary)
                LazyVGrid(columns: textSize.isAccessibilitySize ? [GridItem(.flexible())] : [GridItem(.adaptive(minimum: 155))], spacing: 16) {
                    ForEach(LearnerPreferences.Coach.allCases, id: \.self) { coach in
                        Button {
                            var value = storage.preferences; value.coach = coach; storage.savePreferences(value)
                        } label: {
                            KitCard {
                                CoachArtwork(name: coach.portrait).frame(height: 115)
                                Text(coach.title).font(.headline).foregroundStyle(Kit.ink)
                                Label(storage.preferences.coach == coach ? "Selected" : "Choose presenter",
                                      systemImage: storage.preferences.coach == coach ? "checkmark.circle.fill" : "circle")
                                    .font(.callout).foregroundStyle(Kit.accent)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(coach.title)
                        .accessibilityValue(storage.preferences.coach == coach ? "Selected" : "Available")
                        .accessibilityAddTraits(storage.preferences.coach == coach ? [.isSelected] : [])
                        .accessibilityIdentifier("coach.\(coach.rawValue)")
                    }
                }
                if storage.hasPreferenceSaveFailure {
                    Text("Your coach change could not be saved. Your previous coach remains selected.").foregroundStyle(Kit.error)
                }
            }.padding(20).frame(maxWidth: 900)
                .frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(storage.preferences.background))
        .navigationTitle("Your coach").navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Kit.canvas(storage.preferences.background), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
