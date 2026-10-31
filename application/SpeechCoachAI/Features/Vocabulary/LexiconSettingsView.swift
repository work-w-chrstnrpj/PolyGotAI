import SwiftUI

/// Training settings (Phase 8): which ranks and packs Daily Training uses, new words per day, and hidden packs.
struct LexiconSettingsView: View {
    var storage: LearnerStorageController
    var bank: LexiconBank
    @Environment(\.dismiss) private var dismiss
    @State private var state = LexiconState()
    @State private var startLevel = "A1"
    @State private var message: String?
    /// Ranks whose pack list is open; each rank has up to ten packs, so lists start closed.
    @State private var openRanks: Set<String> = []

    var body: some View {
        Form { KitRows {
            Section {
                ForEach(LevelGate.levels, id: \.self) { rank in
                    // At least one rank stays on: the last one left cannot be turned off.
                    Toggle(rank, isOn: rankBinding(rank))
                        .disabled(chosenRanks == [rank])
                        .accessibilityIdentifier("lexicon.settings.rank.\(rank)")
                }
            } header: { Text("Ranks") } footer: {
                Text("New words come only from the ranks you turn on.")
            }
            Section("New words per day") {
                Stepper("\(state.newPerDay) words", value: Binding(get: { state.newPerDay }, set: { value in
                    update { $0.newPerDay = value }
                }), in: 0...30).accessibilityIdentifier("lexicon.settings.perDay")
            }
            ForEach(visibleRanks, id: \.self) { rank in
                let packs = bank.groups.filter { !$0.isField && $0.level == rank && !state.hidden.contains($0.id) }
                if !packs.isEmpty {
                    Section {
                        DisclosureGroup(isExpanded: openBinding(rank)) {
                            ForEach(packs) { packRow($0) }
                        } label: {
                            LabeledContent("\(rank) packs", value: "\(packs.filter { state.isActive($0, in: bank, startLevel: startLevel) }.count) of \(packs.count) on")
                                .accessibilityIdentifier("lexicon.settings.rankPacks.\(rank)")
                        }
                    }
                }
            }
            let fields = bank.groups.filter { $0.isField && !state.hidden.contains($0.id) }
            if !fields.isEmpty {
                Section("Field packs") { ForEach(fields) { packRow($0) } }
            }
            let hidden = bank.groups.filter { state.hidden.contains($0.id) }
            if !hidden.isEmpty {
                Section("Hidden packs") {
                    ForEach(hidden) { group in
                        HStack {
                            Text(group.title)
                            Spacer()
                            Button("Show") { update { $0.setHidden(group, false, in: bank, startLevel: startLevel) } }
                                .accessibilityIdentifier("lexicon.settings.unhide.\(group.id)")
                        }
                    }
                }
            }
            Section {
                NavigationLink("Review options") { ReviewOptionsView(storage: storage) }
                    .accessibilityIdentifier("vocabulary.options.open")
            }
            if let message { Section { Text(message).foregroundStyle(Kit.error) } }
        }}
        .navigationTitle("Training settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() }.accessibilityIdentifier("lexicon.settings.done") }
        }
        .onAppear(perform: load)
    }

    /// Packs of the chosen ranks; every rank when none is chosen.
    private var visibleRanks: [String] { state.ranks ?? LevelGate.levels }

    private func packRow(_ group: LexiconGroup) -> some View {
        Toggle(isOn: Binding(get: { state.isActive(group, in: bank, startLevel: startLevel) }, set: { on in
            update { $0.setActive(group, on, in: bank, startLevel: startLevel) }
        })) {
            VStack(alignment: .leading, spacing: 2) {
                Text(group.title)
                Text(group.tagline).font(.caption).foregroundStyle(Kit.secondary)
            }
        }
        .swipeActions {
            Button("Hide") { update { $0.setHidden(group, true, in: bank, startLevel: startLevel) } }.tint(Kit.secondary)
        }
        .accessibilityIdentifier("lexicon.settings.pack.\(group.id)")
        .accessibilityAction(named: "Hide pack") { update { $0.setHidden(group, true, in: bank, startLevel: startLevel) } }
    }

    private func openBinding(_ rank: String) -> Binding<Bool> {
        Binding(get: { openRanks.contains(rank) }, set: { open in
            if open { openRanks.insert(rank) } else { openRanks.remove(rank) }
        })
    }

    /// The ranks Daily Training takes new words from; no choice saved means every rank.
    private var chosenRanks: Set<String> { Set(state.ranks ?? LevelGate.levels) }

    private func rankBinding(_ rank: String) -> Binding<Bool> {
        Binding(get: { chosenRanks.contains(rank) }, set: { on in
            var chosen = chosenRanks
            if on { chosen.insert(rank) } else { chosen.remove(rank) }
            guard !chosen.isEmpty else { return }
            update { $0.setRanks(chosen) }
        })
    }

    private func update(_ change: (inout LexiconState) -> Void) {
        var next = state
        change(&next)
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            try repository.saveLexiconState(next)
            state = next; message = nil
        } catch { message = "That change could not be saved." }
    }

    private func load() {
        startLevel = storage.levelGate(install: CurriculumCatalogLoader.bundled).unlockedLevels.last ?? "A1"
        state = (try? storage.repository?.lexiconState()) ?? LexiconState()
    }
}
