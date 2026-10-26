import SwiftUI

struct SpellingView: View {
    var storage: LearnerStorageController
    @State private var rank = "A1"
    @State private var round: SpellingRound?
    @State private var answer = ""
    @State private var store: SpeechLabStore
    @State private var unsaved: SpeechLabAttempt?
    @FocusState private var typing: Bool
    @Environment(\.scenePhase) private var scene
    init(storage: LearnerStorageController) {
        self.storage = storage; _store = State(initialValue: SpeechLabStore(storage.repository))
    }
    var body: some View {
        SpeechLabPage(storage: storage, title: "Spelling") {
            if let round {
                if round.finished {
                    HeroCard(eyebrow: "Round complete", title: "\(round.correct) of \(round.words.count)", detail: "Words spelled correctly") {
                        Button("New round") { self.round = nil; answer = "" }.buttonStyle(KitPrimaryButtonStyle())
                    }.accessibilityIdentifier("spelling.summary")
                } else if let word = round.current {
                    Text("Word \(round.index + 1) of \(round.words.count)").font(.headline)
                    Button("Listen") { speak(SpellingRound.prompt(word)) }.buttonStyle(KitSecondaryButtonStyle()).accessibilityIdentifier("spelling.listen")
                    if let checked = round.checked {
                        KitCard {
                            Text(checked ? "Correct!" : word.lemma).font(.title2.bold()).accessibilityIdentifier("spelling.result")
                            Text(word.meaning)
                            if !checked { Button("Hear spelling") { speak(SpellingRound.correction(word)) } }
                        }
                        if let unsaved { Button("Save again") { if store.save(unsaved) { self.unsaved = nil } } }
                        Button(round.index + 1 == round.words.count ? "Finish" : "Next") {
                            SpeechSynthesizer.shared.stop(); self.round?.next(); answer = ""
                            if let word = self.round?.current { speak(SpellingRound.prompt(word)) }
                        }.buttonStyle(KitPrimaryButtonStyle()).disabled(unsaved != nil).accessibilityIdentifier("spelling.next")
                    } else {
                        TextField("Spell the word", text: $answer).textInputAutocapitalization(.never).autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder).focused($typing).accessibilityIdentifier("spelling.answer")
                            .onChange(of: answer) { _, value in if value.count > 200 { answer = String(value.prefix(200)) } }
                        Button("Check", action: check).buttonStyle(KitPrimaryButtonStyle())
                            .disabled(answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty).accessibilityIdentifier("spelling.check")
                    }
                }
            } else {
                Text("Listen, then spell the word.").foregroundStyle(Kit.secondary)
                Picker("Rank", selection: $rank) { ForEach(LevelGate.levels, id: \.self) { Text($0) } }
                    .accessibilityIdentifier("spelling.rank")
                Button("Start round") {
                    round = SpellingRound(bank: LexiconBankLoader.bundled, rank: rank, shuffle: !SpeechLabRecognizer.fixture)
                    if let word = round?.current { speak(SpellingRound.prompt(word)) }
                }.buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("spelling.start")
                SpeechLabHistory(store: store, area: .dictation)
            }
            if let message = store.message { Text(message).foregroundStyle(Kit.error) }
        }
        .onDisappear { SpeechSynthesizer.shared.stop() }
        .onChange(of: scene) { _, phase in if phase != .active { SpeechSynthesizer.shared.stop() } }
    }
    private func speak(_ text: String) { typing = false; SpeechSynthesizer.shared.speak(text) }
    private func check() {
        typing = false
        guard let word = round?.current, let correct = round?.check(answer) else { return }
        SpeechSynthesizer.shared.stop()
        if !correct { speak(SpellingRound.correction(word)) }
        let attempt = SpeechLabAttempt(area: .dictation, itemID: "spelling.\(word.id)", correct: correct ? 1 : 0, total: 1, errors: correct ? 0 : 1)
        if !store.save(attempt) { unsaved = attempt }
    }
}
