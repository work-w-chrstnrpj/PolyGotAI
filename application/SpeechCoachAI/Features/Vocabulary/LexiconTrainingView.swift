import SwiftUI

/// Daily Training: due words first, then today's new words. Show the meaning, then rate Again, Hard, Good or Easy.
struct LexiconTrainingView: View {
    var storage: LearnerStorageController
    var bank: LexiconBank
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var textSize
    @State private var cards: [VocabularyEnrollment] = []
    @State private var index = 0
    @State private var revealed = false
    @State private var rated = 0
    @State private var stages: [String: LexiconStage] = [:]
    @State private var loaded = false
    @State private var message: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !loaded {
                    Text("One moment.").foregroundStyle(Kit.secondary)
                } else if cards.isEmpty {
                    finished(title: "All done for today.")
                } else if index >= cards.count {
                    finished(title: "Nice work.")
                } else {
                    ProgressView(value: Double(index), total: Double(cards.count)).tint(Kit.accent).accessibilityHidden(true)
                    card(cards[index])
                }
                if let message { Text(message).font(.callout).foregroundStyle(Kit.error) }
            }
            .padding(20).frame(maxWidth: 700, alignment: .leading).frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(storage.preferences.background))
        .foregroundStyle(Kit.ink)
        .navigationTitle("Daily Training").navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: load)
    }

    private func finished(title: String) -> some View {
        KitCard {
            Text(title).font(.title2.bold())
            if rated > 0 { Text("\(rated) \(rated == 1 ? "word" : "words") trained.").foregroundStyle(Kit.secondary) }
            Button("Done") { dismiss() }.buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("lexicon.train.done")
        }
    }

    private func card(_ item: VocabularyEnrollment) -> some View {
        let word = bank.word(itemId: item.itemId, senseId: item.senseId)
        return KitCard {
            HStack {
                Text("\(index + 1) of \(cards.count)").font(.caption).foregroundStyle(Kit.secondary)
                Spacer()
                if let word, let stage = stages[word.id] {
                    Text(stage.title).font(.caption.weight(.semibold)).padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Kit.soft, in: Capsule()).accessibilityIdentifier("lexicon.stage")
                }
            }
            Text(item.lemma).font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("lexicon.lemma")
            if let word { Text(word.pos).font(.subheadline).foregroundStyle(Kit.secondary) }
            if revealed {
                Text(item.meaning ?? "").font(.title3).fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("lexicon.meaning")
                if let example = word?.parsedExamples.first {
                    Text(example.plain).font(.body).italic().foregroundStyle(Kit.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Button { SpeechSynthesizer.shared.speak(example.plain) } label: { Label("Listen", systemImage: "speaker.wave.2.fill") }
                        .buttonStyle(.bordered)
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
            ForEach(RecallRating.allCases, id: \.self) { rating in
                Button(rating.title) { rate(item, rating) }
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityHint(rating.detail)
                    .accessibilityIdentifier("lexicon.rate.\(rating.rawValue)")
            }
        }
    }

    private func load() {
        guard !loaded, let repository = storage.repository else { return }
        do {
            let state = try repository.lexiconState()
            let enrollments = try repository.vocabularyEnrollments()
            let fresh = LexiconTrainingPlan.newWords(bank: bank, state: state, enrollments: enrollments, now: Date())
            try repository.startLexiconWords(fresh, bankVersion: LexiconBankLoader.bankVersion)
            let plan = try ReviewSessionPlan(queue: repository.reviewQueue(), settings: repository.reviewSettings(), open: nil)
            cards = plan.cards
            stages = try repository.lexiconStages(bank: bank)
            loaded = true
        } catch {
            loaded = true
            message = "Your words could not be opened."
        }
    }

    private func rate(_ item: VocabularyEnrollment, _ rating: RecallRating) {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            _ = try repository.recordVocabularyRecall(card: item, rating: rating, draft: RecallDraft(revealed: true))
            stages = try repository.lexiconStages(bank: bank)
            rated += 1; index += 1; revealed = false; message = nil
        } catch {
            message = "That rating could not be saved."
        }
    }
}
