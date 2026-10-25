import SwiftUI

struct SpeechLabDictationView: View {
    var storage: LearnerStorageController
    @State private var store: SpeechLabStore
    @State private var level = "A1"
    private let items = SpeechLabCatalog.bundled.dictation
    init(storage: LearnerStorageController) {
        self.storage = storage; _store = State(initialValue: SpeechLabStore(storage.repository))
    }
    var body: some View {
        SpeechLabPage(storage: storage, title: "Dictation") {
            Text("Listen and write.").foregroundStyle(Kit.secondary).lineLimit(1)
            SpeechLabHistory(store: store, area: .dictation)
            Picker("Level", selection: $level) {
                ForEach(LevelGate.levels + ["Numbers", "Dates", "Names", "Spelling"], id: \.self) { Text($0).tag($0) }
            }.pickerStyle(.menu).accessibilityIdentifier("dictation.level")
            Toggle("Check capitals and punctuation", isOn: Binding(get: { store.state.strictDictation }, set: { store.strict($0) }))
                .accessibilityIdentifier("dictation.strict")
            if !store.state.missedDictation.isEmpty {
                NavigationLink("Practice missed") {
                    SpeechLabPage(storage: storage, title: "Practice missed") {
                        rows(items.filter { store.state.missedDictation.contains($0.id) })
                    }
                }.accessibilityIdentifier("dictation.missed")
            }
            rows(items.filter { LevelGate.levels.contains(level) ? $0.level == level && $0.category == "Sentences" : $0.category == level })
        }.onAppear { store.reload() }
    }
    private func rows(_ items: [SpeechLabDictationItem]) -> some View {
        ForEach(items) { item in
            NavigationLink {
                SpeechLabDictationExercise(storage: storage, store: store, item: item)
            } label: { KitCard { KitContentRow(symbol: "headphones", title: item.title, detail: item.category, showsChevron: true) } }
                .buttonStyle(.plain).accessibilityIdentifier("dictation.item.\(item.id)")
        }
    }
}

private struct SpeechLabDictationExercise: View {
    var storage: LearnerStorageController
    var store: SpeechLabStore
    var item: SpeechLabDictationItem
    @State private var answer = ""
    @State private var result: SpeechLabDictationResult?
    @State private var attempt: SpeechLabAttempt?
    @State private var saved = false
    @FocusState private var typing: Bool
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        SpeechLabPage(storage: storage, title: item.title) {
            SpeechLabModelAudio(text: item.spoken)
            if let result {
                KitCard {
                    Text(result.summary).font(.title2.bold()).accessibilityIdentifier("dictation.result")
                    SpeechLabDiffView(entries: result.diff)
                }
                if !saved, let attempt {
                    Button("Save again") { saved = store.save(attempt) }.buttonStyle(KitPrimaryButtonStyle())
                }
                Button("Retry") { answer = ""; self.result = nil; attempt = nil; saved = false }
                    .buttonStyle(.bordered).accessibilityIdentifier("dictation.retry")
            } else {
                TextField("What did you hear?", text: $answer, axis: .vertical)
                    .lineLimit(3...8).textInputAutocapitalization(.sentences).autocorrectionDisabled()
                    .padding(16).background(Kit.surface, in: RoundedRectangle(cornerRadius: 14))
                    .focused($typing).accessibilityIdentifier("dictation.answer")
                    .onChange(of: answer) { _, value in if value.count > 2000 { answer = String(value.prefix(2000)) } }
                Button("Check", action: check).buttonStyle(KitPrimaryButtonStyle())
                    .disabled(answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("dictation.check")
            }
            if let message = store.message { Text(message).foregroundStyle(Kit.error) }
        }
        .onDisappear { SpeechSynthesizer.shared.stop() }
        .onChange(of: scenePhase) { _, phase in if phase != .active { SpeechSynthesizer.shared.stop() } }
    }
    private func check() {
        typing = false
        let result = SpeechLabDictationChecker.check(answer, expected: item.text, strict: store.state.strictDictation)
        self.result = result
        let attempt = SpeechLabAttempt(area: .dictation, itemID: item.id, correct: result.correct, total: result.total, errors: result.diff.filter { $0.mark != .correct }.count)
        self.attempt = attempt; saved = store.save(attempt)
    }
}
