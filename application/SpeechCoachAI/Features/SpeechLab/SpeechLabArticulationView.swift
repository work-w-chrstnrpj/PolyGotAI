import SwiftUI

struct SpeechLabArticulationView: View {
    var storage: LearnerStorageController
    @State private var store: SpeechLabStore
    @State private var category = "Minimal pairs"
    private let items = SpeechLabCatalog.bundled.articulation
    init(storage: LearnerStorageController) { self.storage = storage; _store = State(initialValue: SpeechLabStore(storage.repository)) }
    var body: some View {
        SpeechLabPage(storage: storage, title: "Articulation") {
            Text("Make each sound clear.").foregroundStyle(Kit.secondary).lineLimit(1)
            SpeechLabHistory(store: store, area: .articulation)
            Picker("Practice", selection: $category) {
                ForEach(["Minimal pairs", "Word endings", "Clusters & linking", "Tongue twisters"], id: \.self) { Text($0).tag($0) }
            }.pickerStyle(.menu).accessibilityIdentifier("articulation.category")
            ForEach(items.filter { $0.category == category }) { item in
                NavigationLink {
                    SpeechLabArticulationExercise(storage: storage, store: store, item: item)
                } label: { KitCard { KitContentRow(symbol: "waveform", title: item.title, detail: item.grade, showsChevron: true) } }
                    .buttonStyle(.plain).accessibilityIdentifier("articulation.item.\(item.id)")
            }
        }.onAppear { store.reload() }
    }
}
private struct SpeechLabArticulationExercise: View {
    var storage: LearnerStorageController
    var store: SpeechLabStore
    var item: SpeechLabArticulationItem
    @State private var step = 0
    @State private var pending: SpeechLabAttempt?
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        Group {
            if step == 1 {
                ExerciseActivityView(activity: item.activity, progress: 0.5, positionText: "Ear training", isLast: true,
                    message: store.message, onSubmit: { stored in
                        let correct = item.activity.resolvedExercise.result(forStored: stored) == .correct
                        let attempt = SpeechLabAttempt(area: .articulation, itemID: item.id + "-listen", correct: correct ? 1 : 0, total: 1)
                        pending = attempt; return store.save(attempt)
                    }, onContinue: { step = 0 })
            } else {
                SpeechLabPage(storage: storage, title: item.title) {
                    KitCard {
                        Text(item.text).font(.title2.bold())
                        Text(item.tip).foregroundStyle(Kit.secondary)
                        SpeechLabModelAudio(text: item.text)
                    }
                    // Phase 10: speak first; the listening question is optional ear training.
                    SpeechLabCaptureView(storage: storage, store: store, area: .articulation, itemID: item.id, text: item.text)
                    if let pending, !store.state.attempts.contains(where: { $0.id == pending.id }) {
                        Button("Save again") { _ = store.save(pending) }.buttonStyle(.bordered)
                    }
                    Button { step = 1 } label: { Label("Ear training", systemImage: "ear") }
                        .buttonStyle(.bordered).accessibilityIdentifier("articulation.practice")
                }
            }
        }.navigationTitle(item.title).navigationBarTitleDisplayMode(.inline)
            .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
            .onDisappear { SpeechSynthesizer.shared.stop() }
            .onChange(of: scenePhase) { _, value in if value != .active { SpeechSynthesizer.shared.stop() } }
    }
}
