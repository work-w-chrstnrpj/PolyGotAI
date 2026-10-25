import SwiftUI
import UIKit

/// Progress evidence for SC-T052 and SC-T054. Page 1 T09 2:38732, using Kit card, status, and content row.
struct ProgressOverview: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    @State private var board: LearningBoard?
    @Environment(\.scenePhase) private var scenePhase
    @State private var message: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RewardSummary(storage: storage)
            if let board {
                weekCard(board)
                evidenceCard(board)
                confidenceCard
                comparisonSection(board)
            } else if let message {
                AvailabilityCard(title: "Progress is unavailable", detail: message, symbol: "exclamationmark.triangle")
            }
        }
        .onAppear { reload() }
        .onChange(of: storage.repository != nil) { _, _ in reload() }
        .onDisappear(perform: saveNote)
        .task(id: storage.confidenceDraft?.text) {
            do { try await Task.sleep(for: .milliseconds(400)) } catch { return }
            saveNote()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { reload() } else { saveNote() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in reload() }
        .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in reload() }
    }

    private func weekCard(_ board: LearningBoard) -> some View {
        KitCard {
            Text("THIS WEEK").font(.caption.weight(.semibold)).foregroundStyle(Kit.accent)
            Text(board.week.narrative).fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("progress.week")
            Text(board.suggestion.title).font(.headline).padding(.top, 4).accessibilityIdentifier("progress.focus")
            Text(board.suggestion.reason).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
            if board.suggestion.chosenByLearner {
                Text("Suggested from your practice: \(board.suggestion.groundedReason)")
                    .font(.footnote).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
            }
            Text("Practice time and text stay separate from speech, and neither is an English level.")
                .font(.footnote).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func evidenceCard(_ board: LearningBoard) -> some View {
        KitCard {
            Text("What the record can show").font(.headline)
            ForEach(board.evidence) { row in
                VStack(alignment: .leading, spacing: 2) {
                    Text(row.kind.title).font(.subheadline.weight(.semibold))
                    Text(row.summary).font(.subheadline).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("progress.evidence.\(row.kind.rawValue)")
            }
        }
    }

    private var confidenceCard: some View {
        KitCard {
            Text("Your confidence").font(.headline)
            Text("This is only what you choose to write. It is not inferred from a recording.")
                .font(.subheadline).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
            TextField("Optional note", text: Binding(get: { storage.confidenceDraft?.text ?? "" }, set: { storage.editConfidenceDraft($0) }), prompt: Text("How did practice feel?").foregroundStyle(Kit.secondary))
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                .accessibilityIdentifier("progress.confidence")
                .onSubmit(saveNote)
            Text("Up to 280 characters").font(.caption).foregroundStyle(Kit.secondary)
            if storage.confidenceDraft?.hasSaveFailure == true {
                Text("Your note could not be saved. It is kept here while the app is open. Retry after unlocking your device.")
                    .font(.callout).foregroundStyle(Kit.error).fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("progress.confidence.error")
                Button("Retry saving note", action: saveNote).buttonStyle(.bordered)
            } else {
                Text(storage.confidenceDraft?.isDirty == true ? "Saving your note…" : "Saved")
                    .font(.caption).foregroundStyle(Kit.secondary)
                    .accessibilityIdentifier("progress.confidence.status")
            }
        }
    }

    private func comparisonSection(_ board: LearningBoard) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comparisons").font(.title3.bold())
            Text("Label a saved take before it can be paired. A pair shows its task, rubric, provider, and support. It does not show a score.")
                .font(.subheadline).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
            ForEach(ComparisonFormat.allCases, id: \.self) { format in
                if let link = board.links.first(where: { $0.format == format }) {
                    KitCard {
                        Text(format.title).font(.headline)
                        Text("Earlier \(link.earlierPrompt) · Later \(link.recentPrompt)").font(.subheadline)
                        Text("Rubric: \(link.rubric)").font(.caption).foregroundStyle(Kit.secondary)
                        Text("Provider: \(link.provider)").font(.caption).foregroundStyle(Kit.secondary)
                        Text("Support: \(link.support)").font(.caption).foregroundStyle(Kit.secondary)
                        Text(replayLine(link)).font(.caption).foregroundStyle(Kit.secondary)
                        Text(link.limitation).font(.footnote).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("progress.comparison.\(format.rawValue)")
                } else {
                    AvailabilityCard(title: format.title, detail: "No earlier and later take is labeled for this yet.", symbol: "arrow.left.arrow.right")
                        .accessibilityIdentifier("progress.comparison.\(format.rawValue)")
                }
            }
        }
    }

    private func replayLine(_ link: ComparisonLink) -> String {
        let earlier = link.earlierReplay ? "Earlier voice can be replayed" : "Earlier voice cannot be replayed"
        let recent = link.recentReplay ? "later voice can be replayed" : "later voice cannot be replayed"
        return "\(earlier); \(recent)."
    }

    private func reload() {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let loaded = try repository.learningBoard(install: install)
            board = loaded
            storage.loadConfidenceDraft(saved: loaded.confidence.note, epoch: try repository.learningDataEpoch())
            message = nil
        } catch {
            board = nil
            message = "Unlock your device to load local progress. Existing data has been kept."
        }
    }

    private func saveNote() {
        storage.saveConfidenceDraft()
    }
}
