import SwiftUI

/// Daily Training: due words first, then today's new words. Show the meaning, then rate Again, Hard, Good or Easy.
/// Each button shows when the word comes back, as in Anki (FSRS-6); a word due again within 20 minutes returns in this sitting.
struct LexiconTrainingView: View {
    var storage: LearnerStorageController
    var bank: LexiconBank
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var textSize
    @State private var sitting = TrainingSitting(waiting: [])
    @State private var current: VocabularyEnrollment?
    /// Cards shown so far in this sitting, repeats included (for the progress bar).
    @State private var shown = 0
    @State private var revealed = false
    /// Words rated at least once (a word repeated after Again counts once).
    @State private var trained: Set<String> = []
    @State private var stages: [String: LexiconStage] = [:]
    @State private var loaded = false
    @State private var message: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !loaded {
                    Text("One moment.").foregroundStyle(Kit.secondary)
                } else if let current {
                    ProgressView(value: Double(shown - 1), total: Double(shown + sitting.remaining)).tint(Kit.accent).accessibilityHidden(true)
                    card(current)
                } else {
                    finished(title: trained.isEmpty ? "All done for today." : "Nice work.")
                }
                if let message { Text(message).font(.callout).foregroundStyle(Kit.error) }
            }
            .padding(20).frame(maxWidth: 700, alignment: .leading).frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(storage.preferences.background))
        .foregroundStyle(Kit.ink)
        .navigationTitle("Daily Training").navigationBarTitleDisplayMode(.inline)
        .practiceScreen(area: .lexicon)
        .onAppear(perform: load)
    }

    private func finished(title: String) -> some View {
        KitCard {
            Text(title).font(.title2.bold())
            if !trained.isEmpty { Text("\(trained.count) \(trained.count == 1 ? "word" : "words") trained.").foregroundStyle(Kit.secondary) }
            Button("Done") { dismiss() }.buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("lexicon.train.done")
        }
    }

    private func card(_ item: VocabularyEnrollment) -> some View {
        let word = bank.word(itemId: item.itemId, senseId: item.senseId)
        return KitCard {
            HStack {
                Text("\(sitting.remaining + 1) left").font(.caption).foregroundStyle(Kit.secondary)
                    .accessibilityIdentifier("lexicon.left")
                Spacer()
                if let word, let stage = stages[word.id] {
                    Text(stage.title).font(.caption.weight(.semibold)).padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Kit.soft, in: Capsule()).accessibilityIdentifier("lexicon.stage")
                }
            }
            Text(item.lemma).font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("lexicon.lemma")
            if let ipa = word?.ipa { PronunciationText(ipa: ipa) }
            if let word { Text(word.pos).font(.subheadline).foregroundStyle(Kit.secondary) }
            if revealed {
                Text(item.meaning ?? "").font(.title3).fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("lexicon.meaning")
                if let example = word?.parsedExamples.first {
                    Text(example.plain).font(.body).italic().foregroundStyle(Kit.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Button { SpeechSynthesizer.shared.speak(example.plain) } label: { Label("Listen", systemImage: "speaker.wave.2.fill") }
                        .buttonStyle(KitSecondaryButtonStyle())
                }
                ratings(item)
            } else {
                Button("Show") { revealed = true }.buttonStyle(KitPrimaryButtonStyle())
                    .accessibilityIdentifier("lexicon.show")
            }
        }
    }

    @ViewBuilder private func ratings(_ item: VocabularyEnrollment) -> some View {
        let layout = textSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8)) : AnyLayout(HStackLayout(spacing: 8))
        layout {
            let now = Date()
            let preview = intervals(item, now: now)
            ForEach(RecallRating.allCases, id: \.self) { rating in
                let interval = preview[rating].map { ReviewSchedule.shortInterval(from: now, to: $0) }
                Button { rate(item, rating) } label: {
                    VStack(spacing: 2) {
                        Text(rating.title).font(.headline)
                        if let interval { Text(interval).font(.caption).monospacedDigit().foregroundStyle(Kit.secondary) }
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(KitSecondaryButtonStyle())
                .accessibilityLabel(rating.title)
                .accessibilityValue(interval.map { "Back in \($0)" } ?? "")
                .accessibilityHint(rating.detail)
                .accessibilityIdentifier("lexicon.rate.\(rating.rawValue)")
            }
        }
    }

    private func intervals(_ item: VocabularyEnrollment, now: Date) -> [RecallRating: Date] {
        guard let repository = storage.repository else { return [:] }
        let existing = try? repository.recognitionSchedule(itemId: item.itemId, senseId: item.senseId)
        let settings = (try? repository.reviewSettings()) ?? ReviewSettings()
        return ReviewSchedule.preview(existing: existing, now: now, itemId: item.itemId, senseId: item.senseId, settings: settings)
    }

    private func load() {
        guard !loaded, let repository = storage.repository else { return }
        do {
            let state = try repository.lexiconState()
            let enrollments = try repository.vocabularyEnrollments()
            let level = storage.levelGate(install: CurriculumCatalogLoader.bundled).unlockedLevels.last ?? "A1"
            let fresh = LexiconTrainingPlan.newWords(bank: bank, state: state, enrollments: enrollments, now: Date(), startLevel: level)
            try repository.startLexiconWords(fresh, bankVersion: LexiconBankLoader.bankVersion)
            let plan = try ReviewSessionPlan(queue: repository.reviewQueue(), settings: repository.reviewSettings(), open: nil)
            sitting = TrainingSitting(waiting: plan.cards)
            advance()
            stages = try repository.lexiconStages(bank: bank)
            loaded = true
        } catch {
            loaded = true
            message = "Your words could not be opened."
        }
    }

    private func advance() {
        current = sitting.next(now: Date())
        if current != nil { shown += 1 }
    }

    private func rate(_ item: VocabularyEnrollment, _ rating: RecallRating) {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            _ = try repository.recordVocabularyRecall(card: item, rating: rating, draft: RecallDraft(revealed: true))
            stages = try repository.lexiconStages(bank: bank)
            let now = Date()
            if let due = try repository.recognitionSchedule(itemId: item.itemId, senseId: item.senseId)?.due {
                sitting.rated(item, due: due, now: now)
            }
            trained.insert(item.itemId + "/" + item.senseId); revealed = false; message = nil
            advance()
        } catch {
            message = "That rating could not be saved."
        }
    }
}
