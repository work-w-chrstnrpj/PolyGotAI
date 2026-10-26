import SwiftUI

struct SpeechLabPhoneticsView: View {
    var storage: LearnerStorageController
    @State private var store: SpeechLabStore
    @Environment(\.dynamicTypeSize) private var size
    private let catalog = SpeechLabCatalog.bundled
    init(storage: LearnerStorageController) { self.storage = storage; _store = State(initialValue: SpeechLabStore(storage.repository)) }
    var body: some View {
        SpeechLabPage(storage: storage, title: "Phonetics") {
            Text("Say the sounds. See what we heard.").foregroundStyle(Kit.secondary).lineLimit(1)
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

/// Phase 10: hear the sound, then say minimal-pair words and see what the phone heard. The listening quiz is optional.
private struct SpeechLabSoundView: View {
    var storage: LearnerStorageController
    var store: SpeechLabStore
    var sound: SpeechLabSound
    @State private var pairIndex = 0
    @State private var earTraining = false
    private var pairs: [MinimalPair] { SpeechLabCatalog.bundled.pairs(for: sound) }

    var body: some View {
        Group {
            if earTraining {
                ExerciseActivityView(activity: sound.activity, progress: 0.5, positionText: "Ear training", isLast: true,
                    message: store.message, onSubmit: { stored in
                        let correct = sound.activity.resolvedExercise.result(forStored: stored) == .correct
                        return store.save(SpeechLabAttempt(area: .phonetics, itemID: sound.id + "-listen", correct: correct ? 1 : 0, total: 1))
                    }, onContinue: { earTraining = false })
            } else {
                SpeechLabPage(storage: storage, title: "/\(sound.ipa)/") {
                    KitCard {
                        Text(sound.tip).font(.title3).fixedSize(horizontal: false, vertical: true)
                        Text(sound.examples.joined(separator: " · ")).font(.headline)
                        Button { SpeechSynthesizer.shared.speakPronunciation(sound.ipa, ipa: sound.ipa) } label: {
                            Label("Hear the sound", systemImage: "speaker.wave.2.fill")
                        }.buttonStyle(.bordered).accessibilityIdentifier("phonetics.hear")
                    }
                    if pairs.isEmpty {
                        SpeakCheckView(storage: storage, store: store, mode: .stress(sound.cue)).id(sound.cue)
                    } else {
                        let pair = pairs[pairIndex % pairs.count]
                        SpeakCheckView(storage: storage, store: store, mode: .pair(pair)).id(pair.id)
                        if pairs.count > 1 {
                            Button { pairIndex += 1 } label: { Label("Next word", systemImage: "arrow.right") }
                                .buttonStyle(KitSecondaryButtonStyle()).accessibilityIdentifier("phonetics.nextPair")
                        }
                    }
                    Button { earTraining = true } label: { Label("Ear training", systemImage: "ear") }
                        .buttonStyle(.bordered).accessibilityIdentifier("phonetics.practice")
                }
            }
        }
        .navigationTitle("/\(sound.ipa)/").navigationBarTitleDisplayMode(.inline)
        .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
        .onAppear { SpeechSynthesizer.shared.speakPronunciation(sound.ipa, ipa: sound.ipa) }
        .onDisappear { SpeechSynthesizer.shared.stop() }
    }
}

/// Phase 10: say the word or sentence first and compare your pitch line with the model's. The quiz is optional.
private struct SpeechLabProsodyView: View {
    var storage: LearnerStorageController
    var store: SpeechLabStore
    var item: SpeechLabProsody
    @State private var earTraining = false
    var body: some View {
        Group {
            if earTraining {
                ExerciseActivityView(activity: item.activity, progress: 0.5, positionText: "Ear training", isLast: true,
                    message: store.message, onSubmit: { stored in
                        let correct = item.activity.resolvedExercise.result(forStored: stored) == .correct
                        return store.save(SpeechLabAttempt(area: .phonetics, itemID: item.id, correct: correct ? 1 : 0, total: 1))
                    }, onContinue: { earTraining = false })
            } else {
                SpeechLabPage(storage: storage, title: item.title) {
                    Text(item.tip).font(.title3).fixedSize(horizontal: false, vertical: true)
                    SpeakCheckView(storage: storage, store: store, mode: item.kind == "intonation" ? .intonation(item.text) : .stress(item.text))
                    Button { earTraining = true } label: { Label("Ear training", systemImage: "ear") }
                        .buttonStyle(.bordered).accessibilityIdentifier("prosody.listen")
                }
            }
        }
        .navigationTitle(item.title).navigationBarTitleDisplayMode(.inline)
        .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
        .onDisappear { SpeechSynthesizer.shared.stop() }
    }
}
