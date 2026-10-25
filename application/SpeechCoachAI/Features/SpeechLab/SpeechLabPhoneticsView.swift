import SwiftUI

struct SpeechLabPhoneticsView: View {
    var storage: LearnerStorageController
    @State private var store: SpeechLabStore
    @Environment(\.dynamicTypeSize) private var size
    private let catalog = SpeechLabCatalog.bundled
    init(storage: LearnerStorageController) { self.storage = storage; _store = State(initialValue: SpeechLabStore(storage.repository)) }
    var body: some View {
        SpeechLabPage(storage: storage, title: "Phonetics") {
            Text("Meet the sounds.").foregroundStyle(Kit.secondary).lineLimit(1)
            SpeechLabHistory(store: store, area: .phonetics)
            ForEach(["Vowels", "Diphthongs", "R-colored vowels", "Consonants"], id: \.self) { group in
                Text(group).font(.title3.bold())
                LazyVGrid(columns: [GridItem(.adaptive(minimum: size.isAccessibilitySize ? 140 : 80))], spacing: 12) {
                    ForEach(catalog.sounds.filter { $0.group == group }) { sound in
                        NavigationLink {
                            SpeechLabSoundView(storage: storage, store: store, sound: sound)
                        } label: {
                            KitCard {
                                Text("/\(sound.ipa)/").font(.title2.bold())
                                if let partner = sound.partner { Text("/\(partner)/ pair").font(.caption).foregroundStyle(Kit.secondary) }
                            }.frame(minHeight: 60)
                        }.buttonStyle(.plain).accessibilityLabel("\(sound.title), \(sound.examples.first ?? "")")
                            .accessibilityIdentifier("phonetics.sound.\(sound.id)")
                    }
                }
            }
            Text("Stress & intonation").font(.title3.bold())
            ForEach(catalog.prosody) { item in
                NavigationLink {
                    SpeechLabProsodyView(storage: storage, store: store, item: item)
                } label: { KitCard { KitContentRow(symbol: "waveform", title: item.title, detail: item.kind.capitalized, showsChevron: true) } }
                    .buttonStyle(.plain).accessibilityIdentifier("phonetics.prosody.\(item.id)")
            }
        }.onAppear { store.reload() }
    }
}

private struct SpeechLabSoundView: View {
    var storage: LearnerStorageController
    var store: SpeechLabStore
    var sound: SpeechLabSound
    @State private var step = 0
    @State private var attempt: SpeechLabAttempt?
    var body: some View {
        Group {
            if step == 1 {
                ExerciseActivityView(activity: sound.activity, progress: 0.5, positionText: "Listen", isLast: true,
                    message: store.message, onSubmit: { stored in
                        let correct = sound.activity.resolvedExercise.result(forStored: stored) == .correct
                        let value = SpeechLabAttempt(area: .phonetics, itemID: sound.id + "-listen", correct: correct ? 1 : 0, total: 1)
                        attempt = value; return store.save(value)
                    }, onContinue: { step = 2 })
            } else {
                SpeechLabPage(storage: storage, title: "/\(sound.ipa)/") {
                    KitCard {
                        Text(sound.tip).font(.title3)
                        Text(sound.examples.joined(separator: " · ")).font(.headline)
                        Button("Hear sound") { SpeechSynthesizer.shared.speakPronunciation(sound.ipa, ipa: sound.ipa) }
                            .buttonStyle(.bordered).accessibilityIdentifier("phonetics.hear")
                        SpeechLabModelAudio(text: sound.examples.joined(separator: ", "))
                    }
                    if step == 0 {
                        Button("Practice") { step = 1 }.buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("phonetics.practice")
                    } else {
                        Text("Say it").font(.title2.bold())
                        Text(sound.cue).font(.title3)
                        SpeechLabCaptureView(storage: storage, store: store, area: .phonetics, itemID: sound.id, text: sound.cue)
                        if let attempt, !store.state.attempts.contains(where: { $0.id == attempt.id }) {
                            Button("Save again") { _ = store.save(attempt) }.buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
        .navigationTitle("/\(sound.ipa)/").navigationBarTitleDisplayMode(.inline)
        .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
        .onAppear { SpeechSynthesizer.shared.speakPronunciation(sound.ipa, ipa: sound.ipa) }
        .onDisappear { SpeechSynthesizer.shared.stop() }
    }
}

private struct SpeechLabProsodyView: View {
    var storage: LearnerStorageController
    var store: SpeechLabStore
    var item: SpeechLabProsody
    @State private var done = false
    @State private var pending: SpeechLabAttempt?
    var body: some View {
        Group {
            if done {
                SpeechLabPage(storage: storage, title: item.title) {
                    Text(item.tip).font(.title3)
                    if let pending, !store.state.attempts.contains(where: { $0.id == pending.id }) {
                        Button("Save again") { _ = store.save(pending) }.buttonStyle(.bordered)
                    }
                    SpeechLabCaptureView(storage: storage, store: store, area: .phonetics, itemID: item.id + "-say", text: item.text)
                }
            } else {
                VStack(spacing: 0) {
                    Button("Listen") {
                        if item.kind == "stress" { SpeechSynthesizer.shared.speakPronunciation(item.text, ipa: item.ipa) }
                        else { SpeechSynthesizer.shared.speak(item.text) }
                    }.buttonStyle(.bordered).padding().accessibilityIdentifier("prosody.listen")
                    ExerciseActivityView(activity: item.activity, progress: 0, positionText: item.kind.capitalized, isLast: true,
                        message: store.message, onSubmit: { stored in
                            let correct = item.activity.resolvedExercise.result(forStored: stored) == .correct
                            let value = SpeechLabAttempt(area: .phonetics, itemID: item.id, correct: correct ? 1 : 0, total: 1)
                            pending = value; return store.save(value)
                        }, onContinue: { done = true })
                }
            }
        }.navigationTitle(item.title).navigationBarTitleDisplayMode(.inline)
            .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
            .onDisappear { SpeechSynthesizer.shared.stop() }
    }
}
