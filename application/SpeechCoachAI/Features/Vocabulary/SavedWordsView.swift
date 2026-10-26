import SwiftUI

/// Saved words (Phase 8): words kept from lessons and the word of the day, apart from the Lexicon packs and the learner's own packs.
struct SavedWordsView: View {
    var storage: LearnerStorageController
    @State private var words: [VocabularyEnrollment] = []
    @State private var query = ""
    @State private var message: String?

    var body: some View {
        List {
            if filtered.isEmpty {
                Text(query.isEmpty ? "Words you save from lessons appear here." : "No matching words.")
                    .foregroundStyle(Kit.secondary)
            }
            ForEach(filtered) { item in
                VStack(alignment: .leading, spacing: Kit.Space.xs) {
                    Text(item.lemma).font(Kit.Fonts.rowTitle)
                    if let meaning = meaning(item) { Text(meaning).font(Kit.Fonts.detail).foregroundStyle(Kit.secondary) }
                    if item.inReview {
                        Text(status(item)).font(.caption).foregroundStyle(Kit.accent)
                    } else {
                        Button("Add to training") { addToTraining(item) }
                            .font(.subheadline.weight(.semibold))
                            .accessibilityIdentifier("vocabulary.collection.enroll.\(item.senseId)")
                    }
                }
                .padding(.vertical, Kit.Space.xs)
                .accessibilityIdentifier("vocabulary.saved.\(item.senseId)")
            }
            if let message { Text(message).foregroundStyle(Kit.error) }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Kit.canvas(storage.preferences.background))
        .searchable(text: $query, prompt: "Search saved words")
        .navigationTitle("Saved words")
        .onAppear(perform: reload)
    }

    private var filtered: [VocabularyEnrollment] {
        words.filter { VocabularySearch.matches(query, fields: [$0.lemma, meaning($0) ?? ""]) }
    }

    private func meaning(_ item: VocabularyEnrollment) -> String? {
        (try? storage.repository?.meaningNote(itemId: item.itemId, senseId: item.senseId)) ?? item.meaning
    }

    private func status(_ item: VocabularyEnrollment) -> String {
        guard let card = try? storage.repository?.recognitionSchedule(itemId: item.itemId, senseId: item.senseId) else { return "New in training" }
        return "Next review in \(ReviewSchedule.returnPhrase(due: card.due, now: .now))"
    }

    private func addToTraining(_ item: VocabularyEnrollment) {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            try repository.addCollectedVocabularyToReview(item)
            message = nil; reload()
        } catch { message = "This word could not be added." }
    }

    private func reload() {
        words = ((try? storage.repository?.vocabularyEnrollments()) ?? [])
            .filter { $0.origin == .saved }
            .sorted { $0.enrolledAt > $1.enrolledAt }
    }
}
