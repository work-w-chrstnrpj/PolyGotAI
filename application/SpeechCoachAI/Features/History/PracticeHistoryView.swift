import AVFAudio
import SwiftUI

struct PracticeHistoryContent: View {
    var storage: LearnerStorageController
    var recentlyDeleted = false
    @State private var records: [AttemptSnapshot] = []
    @State private var completed = 0
    @State private var savedWords = 0
    @State private var recalls = 0
    @State private var message: String?
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !recentlyDeleted {
                KitCard {
                    Text("\(completed) self-reviews completed").font(.title2.bold()).accessibilityIdentifier("progress.completions")
                    Text("\(savedWords) words saved · \(recalls) recall ratings").font(.headline).accessibilityIdentifier("progress.words")
                    Text("Speaking completions, saved words, and recall ratings stay separate. None of them is an English level.")
                        .foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                }
                NavigationLink("Recently Deleted") {
                    ScrollView { PracticeHistoryContent(storage: storage, recentlyDeleted: true).padding(20) }
                        .navigationTitle("Recently Deleted")
                }.accessibilityIdentifier("history.trash")
                Text("Saved practice").font(.title3.bold())
            } else {
                Text("Saved components can be restored for 30 days. Permanent deletion cannot be undone. Temporary drafts are not stored here.")
                    .foregroundStyle(Kit.secondary)
            }
            if records.isEmpty {
                AvailabilityCard(title: recentlyDeleted ? "No recently deleted practice" : "No saved practice yet",
                    detail: recentlyDeleted ? "Deleted saved voice and text components will appear here until their expiry." : "Saving voice and saving text are independent choices. Completing self-review does not require saving either.", symbol: "tray")
            }
            ForEach(records, id: \.id) { record in
                NavigationLink {
                    PracticeRecordDetail(storage: storage, attemptID: record.id, recentlyDeleted: recentlyDeleted)
                } label: {
                    KitCard {
                        Text(record.createdAt.formatted(date: .abbreviated, time: .shortened)).font(.headline)
                        Text(record.retryOfAttemptID == nil ? "First take" : "Retry take").font(.callout)
                        Text("Voice: \(record.audio.state.description) · Text: \(record.text.state.description)")
                            .font(.caption).foregroundStyle(Kit.secondary)
                    }
                }.buttonStyle(.plain).accessibilityIdentifier("history.\(record.id.uuidString)")
            }
            if let message { Text(message).foregroundStyle(Kit.error) }
            Button("Refresh") { reload() }.buttonStyle(.bordered)
        }
        .onAppear { reload() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { reload() }
            else if phase == .background { records = [] }
        }
    }
    private func reload() {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            records = try repository.history(recentlyDeleted: recentlyDeleted)
            completed = try repository.completedPracticeCount()
            savedWords = try repository.vocabularyEnrollments().count
            recalls = try repository.vocabularyRecalls().count
            message = nil
        } catch { records = []; message = "Unlock your device to load local history. Existing data has been kept." }
    }
}

struct PracticeRecordDetail: View {
    var storage: LearnerStorageController
    let attemptID: UUID
    var recentlyDeleted = false
    @State private var record: AttemptSnapshot?
    @State private var message: String?
    @State private var player: AVAudioPlayer?
    @State private var deleteID: UUID?
    @State private var confirmDelete = false
    @State private var confirmSoftDelete = false
    @State private var formatChoice: ComparisonFormat?
    @State private var loadedFormat: ComparisonFormat?
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let record {
                    Text(record.createdAt.formatted(date: .abbreviated, time: .shortened)).font(.headline)
                    Text(record.retryOfAttemptID == nil ? "First take · Self-review" : "Retry take · Self-review")
                    if let source = record.speakingProvenance {
                        KitCard {
                            Text("\(source.role.capitalized) · \(source.purpose == "specialistPractice" ? "Specialist practice" : source.purpose)").font(.headline)
                            Text(source.method)
                            Text(source.supported ? "Supported practice" : "Attempt without an example")
                            Text("Objective: \(source.primaryObjectiveID) · Pack \(source.packVersion)").font(.caption)
                        }
                    }
                    if record.audio.state == .saved, record.recording != nil {
                        Button("Replay saved voice") { replay() }.buttonStyle(.bordered).frame(minHeight: 44).accessibilityIdentifier("history.replay")
                        Button("Stop playback") { stop() }.buttonStyle(.bordered).frame(minHeight: 44)
                    } else { Text("Voice playback: \(record.audio.state.description)").foregroundStyle(Kit.secondary) }
                    if !recentlyDeleted {
                        Picker("Comparison label", selection: $formatChoice) {
                            Text("Not labeled").tag(Optional<ComparisonFormat>.none)
                            ForEach(ComparisonFormat.allCases, id: \.self) { Text($0.title).tag(Optional($0)) }
                        }
                        .pickerStyle(.menu)
                        .accessibilityIdentifier("history.format")
                        .onChange(of: formatChoice) { _, new in
                            guard new != loadedFormat else { return }
                            loadedFormat = new
                            mutate { repo, _ in try repo.setAttemptFormat(attemptID, new) }
                        }
                    }
                    if record.text.isVisible, !record.transcripts.isEmpty {
                        ForEach(record.transcripts, id: \.id) { transcript in
                            KitCard {
                                Text(transcript.kind == .asrOriginal ? "Original recognition · Revision \(transcript.revision)" : "Confirmed text · Revision \(transcript.revision)").font(.headline)
                                Text(transcript.text).textSelection(.enabled)
                            }
                        }
                        ForEach(record.feedback, id: \.id) { feedback in
                            FeedbackContent(feedback: feedback, historical: feedback.transcriptID != record.transcripts.last(where: { $0.kind == .learnerConfirmed })?.id)
                        }
                    } else { Text("Transcript and feedback: \(record.text.state.description)").foregroundStyle(Kit.secondary) }
                    if !recentlyDeleted && (record.audio.state == .saved || record.text.state == .saved) {
                        Button("Delete saved components", role: .destructive) { stop(); confirmSoftDelete = true }
                            .accessibilityIdentifier("history.delete")
                    }
                    if recentlyDeleted {
                        recoveryButtons(record.audio, title: "voice")
                        recoveryButtons(record.text, title: "text and feedback")
                    }
                }
                if let message { Text(message).foregroundStyle(Kit.secondary).accessibilityIdentifier("history.message") }
            }.padding(20).frame(maxWidth: 700).frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
        .navigationTitle(recentlyDeleted ? "Deleted practice" : "Your practice")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { reload() }
        .onDisappear { stop(); record = nil }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { reload() } else { stop(); record = nil }
        }
        .confirmationDialog("Move saved components to Recently Deleted?", isPresented: $confirmSoftDelete, titleVisibility: .visible) {
            if record?.audio.state == .saved { Button("Delete voice", role: .destructive) { softDelete(.audio) } }
            if record?.text.state == .saved { Button("Delete text and feedback", role: .destructive) { softDelete(.text) } }
            Button("Delete all saved components", role: .destructive) { softDelete(.all) }
            Button("Keep practice", role: .cancel) { }
        }
        .alert("Permanently delete this component?", isPresented: $confirmDelete) {
            Button("Delete permanently", role: .destructive) {
                guard let deleteID else { return }
                mutate { repo, value in try repo.purge(deleteID, expectedVersion: value.version) }
            }
            Button("Keep deleted component", role: .cancel) { }
        } message: { Text("This cannot be undone. Other saved components and your minimal completion record are kept.") }
    }
    @ViewBuilder private func recoveryButtons(_ component: ComponentLifecycle, title: String) -> some View {
        if component.state == .recentlyDeleted, let id = component.deletionID {
            if let expiry = component.expiresAt { Text("\(title.capitalized) expires \(expiry.formatted(date: .abbreviated, time: .shortened))").font(.caption) }
            Button("Restore \(title)") { mutate { repo, value in try repo.restore(id, expectedVersion: value.version) } }
                .buttonStyle(.bordered)
            Button("Permanently delete \(title)", role: .destructive) { deleteID = id; confirmDelete = true }
        }
    }
    private func mutate(_ action: (LearnerRepository, AttemptSnapshot) throws -> Void) {
        stop()
        do {
            guard let repo = storage.repository else { throw LearnerStorageError.unavailable }
            let current = try repo.attempt(attemptID)
            try action(repo, current); reload(); message = "Local history updated."
        } catch { message = "The change could not finish. Unlock your device and refresh before trying again."; reload() }
    }
    private func softDelete(_ scope: PayloadScope) { mutate { repo, value in _ = try repo.softDelete(attemptID, scope: scope, expectedVersion: value.version) } }
    private func reload() {
        do {
            guard let repo = storage.repository else { throw LearnerStorageError.unavailable }
            record = try repo.attempt(attemptID)
            let format = try repo.attemptFormat(attemptID)
            loadedFormat = format
            formatChoice = format
        } catch { record = nil; message = "This practice is unavailable. Unlock your device and try again." }
    }
    private func replay() {
        stop()
        do {
            guard let repo = storage.repository else { throw LearnerStorageError.unavailable }
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            let player = try AVAudioPlayer(contentsOf: repo.recordingURL(attemptID))
            guard player.play() else { throw LearnerStorageError.unavailable }; self.player = player
        } catch { stop(); message = "Saved voice could not be replayed. Other saved practice is kept." }
    }
    private func stop() {
        guard let player else { return }
        player.stop(); self.player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

extension PayloadState {
    var description: String {
        switch self {
        case .temporary: "temporary"
        case .saved: "saved"
        case .recentlyDeleted: "recently deleted"
        case .purged: "not saved"
        case .unavailable: "unavailable"
        }
    }
}

struct FeedbackContent: View {
    let feedback: FeedbackSnapshot
    var historical = false
    var body: some View {
        KitCard {
            Text(historical ? "Earlier feedback · Revision \(feedback.transcriptRevision)" : "A little guidance").font(.title3.bold())
            Text(feedback.summary)
            ForEach(Array(feedback.strengths.enumerated()), id: \.offset) { _, strength in Text(strength) }
            ForEach(Array(feedback.improvements.enumerated()), id: \.offset) { _, item in
                Divider()
                Text(item.category.rawValue.capitalized).font(.headline)
                Text("“\(item.evidenceQuote)”").italic()
                Text(item.explanation)
                if let hint = item.hint { Text(hint) }
                if let revision = item.suggestedRevision { Text(revision) }
                Text(item.retryPrompt).font(.callout.bold())
            }
            if feedback.improvements.isEmpty { Text("No corrections were suggested for this text.") }
            ForEach(Array(feedback.limitations.enumerated()), id: \.offset) { _, limitation in Text(limitation).font(.footnote) }
        }
    }
}
