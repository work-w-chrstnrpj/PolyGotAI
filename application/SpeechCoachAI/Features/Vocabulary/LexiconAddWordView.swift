import SwiftUI

/// Add a word to the learner's own list. A word already in the Lexicon is not added twice.
struct LexiconAddWordView: View {
    var storage: LearnerStorageController
    var bank: LexiconBank
    @Environment(\.dismiss) private var dismiss
    @State private var lemma = ""
    @State private var pos = ""
    @State private var meaning = ""
    @State private var duplicate: LexiconDuplicate?
    @State private var message: String?
    @State private var saved = false

    private static let partsOfSpeech = ["", "noun", "verb", "adjective", "adverb", "phrase"]
    private var canSave: Bool {
        !lemma.trimmingCharacters(in: .whitespaces).isEmpty && !meaning.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Word", text: $lemma).textFieldStyle(.roundedBorder).autocorrectionDisabled()
                    .textInputAutocapitalization(.never).accessibilityIdentifier("lexicon.add.word")
                    .dictation($lemma)
                Picker("Type", selection: $pos) {
                    ForEach(Self.partsOfSpeech, id: \.self) { Text($0.isEmpty ? "Not sure" : $0).tag($0) }
                }.accessibilityIdentifier("lexicon.add.pos")
                TextField("Meaning", text: $meaning, axis: .vertical).lineLimit(2...4).textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("lexicon.add.meaning").dictation($meaning)
                if let duplicate { existingCard(duplicate) }
                if saved {
                    Text("Added.").font(.headline).accessibilityIdentifier("lexicon.add.saved")
                    Button("Done") { dismiss() }.buttonStyle(KitPrimaryButtonStyle())
                } else {
                    Button("Add") { add() }.buttonStyle(KitPrimaryButtonStyle()).disabled(!canSave)
                        .accessibilityIdentifier("lexicon.add.save")
                }
                if let message { Text(message).font(.callout).foregroundStyle(Kit.error) }
            }
            .padding(20).frame(maxWidth: 700, alignment: .leading).frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(storage.preferences.background))
        .foregroundStyle(Kit.ink)
        .navigationTitle("Add a word").navigationBarTitleDisplayMode(.inline)
        .onChange(of: lemma) { _, _ in duplicate = nil; saved = false }
        .onChange(of: pos) { _, _ in duplicate = nil }
    }

    private func existingCard(_ found: LexiconDuplicate) -> some View {
        let word = found.wordId.flatMap { bank.word(id: $0) }
        return KitCard {
            Label("Already in your Lexicon", systemImage: "checkmark.circle").font(.headline)
                .accessibilityIdentifier("lexicon.add.duplicate")
            Text(found.lemma).font(.title3.bold())
            if let word { Text(word.meaning).foregroundStyle(Kit.secondary) }
        }
    }

    private func add() {
        guard let repository = storage.repository else { message = "Your words could not be saved."; return }
        do {
            let topics = try repository.customTopics()
            let enrollments = try repository.vocabularyEnrollments()
            if let found = LexiconDuplicateCheck.find(lemma: lemma, partOfSpeech: pos.isEmpty ? nil : pos,
                                                      bank: bank, topics: topics, enrollments: enrollments) {
                duplicate = found
                return
            }
            let topic = try topics.first { $0.title == "My words" } ?? repository.createCustomTopic(title: "My words", subtopic: "")
            let change = try repository.addCustomSense(topicID: topic.id, lemma: lemma, note: meaning)
            _ = try repository.enrollCustomSense(topicID: topic.id, senseID: change.sense.id)
            saved = true
            message = nil
        } catch {
            message = "That word could not be added."
        }
    }
}
