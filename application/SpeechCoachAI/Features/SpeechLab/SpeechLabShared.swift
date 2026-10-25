import AVFAudio
import Observation
import SwiftUI

@MainActor @Observable
final class SpeechLabStore {
    private(set) var state = SpeechLabState()
    var message: String?
    let repository: LearnerRepository?
    private let epoch: UUID?
    init(_ repository: LearnerRepository?) { self.repository = repository; epoch = try? repository?.learningDataEpoch(); reload() }
    func reload() {
        do { guard let repository else { throw LearnerStorageError.unavailable }; state = try repository.speechLabState() }
        catch { message = "Couldn’t load your practice." }
    }
    @discardableResult func save(_ attempt: SpeechLabAttempt) -> Bool {
        do {
            guard let repository, let epoch, try repository.learningDataEpoch() == epoch else { throw LearnerStorageError.staleVersion }
            try repository.recordSpeechLabAttempt(attempt); reload(); message = nil; return true
        } catch { message = "Couldn’t save your practice."; return false }
    }
    func strict(_ value: Bool) {
        do {
            guard let repository, let epoch, try repository.learningDataEpoch() == epoch else { throw LearnerStorageError.staleVersion }
            try repository.setSpeechLabStrictDictation(value); reload(); message = nil
        } catch { message = "Couldn’t save your setting." }
    }
    func remove(_ attempt: SpeechLabAttempt) {
        do {
            guard let repository, let epoch, try repository.learningDataEpoch() == epoch else { throw LearnerStorageError.staleVersion }
            if let id = attempt.recordingID {
                if let recording = try? repository.attempt(id), recording.audio.state == .saved {
                    _ = try repository.softDelete(id, scope: .audio, expectedVersion: recording.version)
                }
            }
            try repository.removeSpeechLabAttempt(attempt.id); reload(); message = nil
        } catch { message = "Couldn’t delete your practice." }
    }
}

struct SpeechLabPage<Content: View>: View {
    var storage: LearnerStorageController
    var title: String
    @ViewBuilder var content: () -> Content
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20, content: content)
                .frame(maxWidth: 700, alignment: .leading).padding(20).frame(maxWidth: .infinity)
        }.background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
            .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
    }
}

struct SpeechLabHistory: View {
    var store: SpeechLabStore
    var area: SpeechLabArea
    @State private var showAll = false
    @State private var deleting: SpeechLabAttempt?
    var body: some View {
        let results = store.state.results(for: area)
        if let last = results.last {
            KitCard {
                Text("Last result").font(.headline)
                Text(last.summary).accessibilityIdentifier("speechlab.last")
                Text(last.date.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(Kit.secondary)
                if let trend = store.state.trend(for: area) { Text(trend).font(.callout).accessibilityIdentifier("speechlab.trend") }
                Button("History") { showAll = true }.accessibilityIdentifier("speechlab.history")
            }
            .sheet(isPresented: $showAll) {
                NavigationStack {
                    List(results.reversed()) { attempt in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(SpeechLabCatalog.bundled.title(for: attempt)).font(.headline)
                            Text(attempt.summary)
                            Text(attempt.date.formatted()).font(.caption)
                            if let recordingID = attempt.recordingID, let repository = store.repository,
                               let value = try? repository.attempt(recordingID), value.audio.state == .saved {
                                SpeechLabSavedAudio(repository: repository, recordingID: recordingID)
                            }
                            Button("Delete", role: .destructive) { deleting = attempt }
                        }
                    }.navigationTitle("Practice history")
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showAll = false } } }
                        .confirmationDialog("Delete this result and its saved audio?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }), titleVisibility: .visible) {
                            if let deleting { Button("Delete", role: .destructive) { store.remove(deleting); self.deleting = nil } }
                        }
                }
            }
        }
        if let message = store.message { Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("speechlab.error") }
    }
}

struct SpeechLabDiffView: View {
    var entries: [WordDiffEntry]
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: entry.mark == .correct ? "checkmark.circle" : "exclamationmark.circle")
                        .foregroundStyle(entry.mark == .correct ? Kit.accent : Kit.error).accessibilityHidden(true)
                    Text(entry.word).bold()
                    Text(label(entry)).foregroundStyle(Kit.secondary)
                }.accessibilityElement(children: .combine)
            }
        }.accessibilityIdentifier("speechlab.diff")
    }
    private func label(_ entry: WordDiffEntry) -> String {
        switch entry.mark {
        case .correct: "Correct"
        case .missing: "Missing"
        case .extra: "Extra"
        case .misspelled: "Expected: \(entry.expected ?? "")"
        }
    }
}

struct SpeechLabModelAudio: View {
    var text: String
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack { buttons }
            VStack(alignment: .leading) { buttons }
        }.buttonStyle(.bordered).controlSize(.large)
    }
    @ViewBuilder private var buttons: some View {
        Button { SpeechSynthesizer.shared.speak(text) } label: { Label("Listen", systemImage: "speaker.wave.2") }
            .accessibilityIdentifier("speechlab.listen")
        Button { SpeechSynthesizer.shared.speak(text, slow: true) } label: { Label("Slow", systemImage: "tortoise") }
            .accessibilityIdentifier("speechlab.slow")
    }
}

struct SpeechLabInfoButton: View {
    @State private var visible = false
    var body: some View {
        Button { visible = true } label: { Label("About Speech Lab", systemImage: "info.circle") }
            .accessibilityIdentifier("speech.info")
            .sheet(isPresented: $visible) {
                NavigationStack {
                    ScrollView {
                        Text("“We heard” is what the phone recognized. It helps you notice clarity; it is not a pronunciation score.")
                            .padding(24)
                    }.navigationTitle("Speech Lab")
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { visible = false } } }
                }
            }
    }
}

private struct SpeechLabSavedAudio: View {
    var repository: LearnerRepository
    var recordingID: UUID
    @State private var player: AVAudioPlayer?
    @State private var message: String?
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        Button("Play recording") {
            do {
                stop(); SpeechSynthesizer.shared.stop()
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                player = try AVAudioPlayer(contentsOf: repository.recordingURL(recordingID))
                guard player?.play() == true else { throw LearnerStorageError.invalidState }
            } catch { message = "Couldn’t play this recording." }
        }.accessibilityIdentifier("speechlab.history.play")
        if let message { Text(message).foregroundStyle(Kit.error) }
        Color.clear.frame(height: 0).onDisappear(perform: stop)
            .onChange(of: scenePhase) { _, value in if value != .active { stop() } }
    }
    private func stop() {
        guard player != nil else { return }
        player?.stop(); player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
