import SwiftUI

/// A pack of the learner's own words: name, words, Train all and Fill with AI.
struct CustomTopicEditor: View {
    private enum WordField: Hashable { case lemma, meaning }
    @FocusState private var wordField: WordField?
    var storage: LearnerStorageController
    var topicID: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var topic: CustomVocabularyTopic?
    @State private var details = CustomTopicDetailsDraft()
    @State private var lemma = ""
    @State private var note = ""
    @State private var message: String?
    @State private var collectedIDs: Set<String> = []
    @State private var reviewIDs: Set<String> = []
    @State private var confirmDelete = false
    @State private var editingSense: CustomVocabularySense?
    @State private var aiAvailable = AIFeedbackController(service: AIFeedbackController.localService()).isAvailable

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let topic {
                    packActions(topic)
                    KitCard {
                        TextField("Pack name", text: $details.title).textFieldStyle(.roundedBorder)
                            .accessibilityIdentifier("vocabulary.topic.edit.title").dictation($details.title)
                        TextField("Subtopic, if you want one", text: $details.subtopic).textFieldStyle(.roundedBorder)
                            .accessibilityIdentifier("vocabulary.topic.edit.subtopic").dictation($details.subtopic)
                        Button("Save name") { rename() }
                            .disabled(!details.isDirty)
                            .accessibilityIdentifier("vocabulary.topic.rename")
                        if details.isDirty {
                            Text("Unsaved name").font(.caption).foregroundStyle(Kit.secondary)
                                .accessibilityIdentifier("vocabulary.topic.unsaved")
                            Button("Discard") { details.accept(topic) }
                        }
                    }
                    KitCard {
                        Text("Add a word").font(.headline)
                        TextField("Word or phrase", text: $lemma)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .accessibilityIdentifier("vocabulary.sense.lemma")
                            .focused($wordField, equals: .lemma)
                            .dictation($lemma)
                        TextField("Meaning or useful context", text: $note)
                            .textFieldStyle(.roundedBorder)
                            .accessibilityIdentifier("vocabulary.sense.note")
                            .focused($wordField, equals: .meaning)
                            .dictation($note)
                        Button("Save word") { wordField = nil; add() }
                            .buttonStyle(.borderedProminent).foregroundStyle(Kit.onAccent)
                            .accessibilityIdentifier("vocabulary.sense.save")
                    }
                    ForEach(topic.senses) { sense in
                        senseCard(sense)
                    }
                    Button("Delete pack") { confirmDelete = true }
                        .foregroundStyle(Kit.error)
                        .accessibilityIdentifier("vocabulary.topic.delete")
                } else if let message {
                    Text(message).foregroundStyle(Kit.secondary)
                }
                if topic != nil, let message {
                    Text(message).foregroundStyle(Kit.secondary).accessibilityIdentifier("vocabulary.topic.message")
                }
            }
            .padding(20)
            .frame(maxWidth: 700, alignment: .leading)
        }
        .background(Kit.canvas(storage.preferences.background))
        .foregroundStyle(Kit.ink)
        .controlSize(.large)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(topic?.title ?? "Pack")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: load)
        .sheet(item: $editingSense) { sense in
            CustomSenseEditor(storage: storage, topicID: topicID, sense: sense, onSave: load)
        }
        .confirmationDialog("Delete this pack?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete pack", role: .destructive) { remove() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Words already in training stay there.")
        }
    }

    private func senseCard(_ sense: CustomVocabularySense) -> some View {
        KitCard {
            Text(sense.lemma).font(.headline)
            if !sense.note.isEmpty {
                Text(sense.note).font(.footnote).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
            }
            Button("Edit word and meaning") { editingSense = sense }
                .frame(minHeight: 44)
            Button(reviewIDs.contains("\(sense.itemId)|\(sense.senseId)") ? "In training" : "Train") { enroll(sense, inReview: true) }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, minHeight: 44)
                .disabled(reviewIDs.contains("\(sense.itemId)|\(sense.senseId)"))
                .accessibilityIdentifier("vocabulary.sense.enroll.\(sense.senseId)")
        }
    }

    /// Train every word of the pack, and fill the pack with AI words when online feedback is set up.
    @ViewBuilder private func packActions(_ topic: CustomVocabularyTopic) -> some View {
        let untrained = topic.senses.filter { !reviewIDs.contains("\($0.itemId)|\($0.senseId)") }
        HeroCard(eyebrow: "Your pack", title: "\(topic.senses.count) \(topic.senses.count == 1 ? "word" : "words")",
                 detail: untrained.isEmpty && !topic.senses.isEmpty ? "All in training" : nil) {
            if !untrained.isEmpty {
                Button("Train all") { untrained.forEach { enroll($0, inReview: true) }; message = "Added to Daily Training." }
                    .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("vocabulary.topic.trainAll")
            }
            if aiAvailable {
                NavigationLink("Fill with AI") { SpecializedLexiconView(storage: storage, pack: topic) }
                    .buttonStyle(KitSecondaryButtonStyle()).accessibilityIdentifier("vocabulary.topic.fillAI")
            }
        }
    }

    private func load() {
        guard let found = try? storage.repository?.customTopics().first(where: { $0.id == topicID }) else {
            message = "This topic could not be opened."
            return
        }
        topic = found
        details.refresh(found)
        let saved = (try? storage.repository?.vocabularyEnrollments()) ?? []
        collectedIDs = Set(saved.map { "\($0.itemId)|\($0.senseId)" })
        reviewIDs = Set(saved.filter(\.inReview).map { "\($0.itemId)|\($0.senseId)" })
    }

    private func rename() {
        guard let repository = storage.repository else {
            message = "Local data is unavailable. Unlock your device and try again."
            return
        }
        do {
            let saved = try repository.renameCustomTopic(id: topicID, title: details.title, subtopic: details.subtopic)
            topic = saved
            details.accept(saved)
            message = "Topic details saved."
        } catch CustomVocabularyError.blankTitle {
            message = "Write a topic name before saving it."
        } catch CustomVocabularyError.tooLong {
            message = "Use a shorter topic name or subtopic."
        } catch {
            message = "The topic could not be saved."
        }
    }

    private func add() {
        guard let repository = storage.repository else {
            message = "Local data is unavailable. Unlock your device and try again."
            return
        }
        do {
            let change = try repository.addCustomSense(topicID: topicID, lemma: lemma, note: note)
            lemma = ""
            note = ""
            if change.alreadyInTopic {
                message = "That word is already in this topic."
            } else if change.reusedIdentity {
                message = "That word was already in your topics. It is listed here too, still as one card."
            } else {
                message = "Word saved. Tap Train to add it to Daily Training."
            }
            load()
        } catch CustomVocabularyError.blankLemma {
            message = "Write a word before saving it."
        } catch CustomVocabularyError.tooLong {
            message = "Use a shorter word or note."
        } catch {
            message = "The word could not be saved."
        }
    }

    private func enroll(_ sense: CustomVocabularySense, inReview: Bool) {
        guard let repository = storage.repository else {
            message = "Local data is unavailable. Unlock your device and try again."
            return
        }
        do {
            let enrollment = inReview
                ? try repository.enrollCustomSense(topicID: topicID, senseID: sense.id)
                : try repository.saveCustomSenseToCollection(topicID: topicID, senseID: sense.id)
            collectedIDs.insert("\(sense.itemId)|\(sense.senseId)")
            if enrollment.inReview { reviewIDs.insert("\(sense.itemId)|\(sense.senseId)") }
            message = inReview ? "Added to Daily Training." : "Saved."
        } catch {
            message = "The word could not be saved."
        }
    }

    private func remove() {
        guard let repository = storage.repository else {
            message = "Local data is unavailable. Unlock your device and try again."
            return
        }
        do {
            try repository.deleteCustomTopic(id: topicID)
            dismiss()
        } catch {
            message = "The topic could not be removed."
        }
    }
}

private struct CustomSenseEditor: View {
    var storage: LearnerStorageController
    var topicID: UUID
    var sense: CustomVocabularySense
    var onSave: () -> Void
    @State private var word = ""
    @State private var meaning = ""
    @State private var message: String?
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Form {
                TextField("Word or phrase", text: $word).dictation($word)
                TextField("Meaning or useful context", text: $meaning, axis: .vertical).dictation($meaning)
                Text("This updates the same word in your topics and collection. Its review schedule is kept. For a different meaning, add a separate word entry.")
                    .font(.footnote)
                if let message { Text(message) }
            }.navigationTitle("Edit word")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button("Save") { save() } }
                }
                .onAppear { word = sense.lemma; meaning = sense.note }
        }.tint(Kit.accent)
    }
    private func save() {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            _ = try repository.editCustomSense(topicID: topicID, senseID: sense.id, lemma: word, note: meaning)
            onSave(); dismiss()
        } catch { message = "The word could not be saved. Check its length and try again. An identical word and meaning may already exist." }
    }
}

/// Page 1 T10 settings composition, reached in context from T08 Vocabulary.
struct ReviewOptionsView: View {
    var storage: LearnerStorageController
    @State private var retention = ""
    @State private var limit = ""
    @State private var epoch: UUID?
    @State private var loaded = false
    @State private var message: String?
    @FocusState private var editing: Bool

    var body: some View {
        Form {
            Section {
                Text("Choose the recall target and the amount offered in one review session. These are scheduling preferences, not measured learning results.")
            }
            Section(header: Text("Desired retention").foregroundStyle(Kit.secondary)) {
                Text("Target percentage").font(.callout)
                TextField("Percentage", text: $retention)
                    .keyboardType(.decimalPad).focused($editing)
                    .accessibilityIdentifier("vocabulary.options.retention")
                Text("Use a percentage greater than 0 and less than 100. Higher targets usually mean more frequent reviews. The current default is 90%. Existing due dates stay as they are; your next rating uses the saved target.")
                    .font(.footnote).foregroundStyle(Kit.secondary)
            }
            Section(header: Text("Session size").foregroundStyle(Kit.secondary)) {
                Text("Words per session, optional").font(.callout)
                TextField("All due words", text: $limit)
                    .keyboardType(.numberPad).focused($editing)
                    .accessibilityIdentifier("vocabulary.options.limit")
                Text("Leave empty for all due words, or enter a positive whole number. An interrupted word comes first. Other due words remain available for another session; this is not a daily cap.")
                    .font(.footnote).foregroundStyle(Kit.secondary)
            }
            Section {
                Button("Save review options") { save() }
                    .disabled(!loaded).accessibilityIdentifier("vocabulary.options.save")
                Button("Use default values") {
                    retention = "90"; limit = ""
                    message = "Default values are ready. Save to apply them to future reviews."
                }.disabled(!loaded).accessibilityIdentifier("vocabulary.options.defaults")
            }
            if let message {
                Section { Text(message).foregroundStyle(Kit.secondary).accessibilityIdentifier("vocabulary.options.message") }
            }
            Section(header: Text("Your review history").foregroundStyle(Kit.secondary)) {
                Text("Changing or restoring these options keeps earlier ratings and due dates. History from an unsupported scheduler stays unchanged and is not reviewed by this version. No automatic upgrade, rollback or reset is performed.")
                    .font(.footnote).foregroundStyle(Kit.secondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Kit.canvas(storage.preferences.background))
        .foregroundStyle(Kit.ink)
        .navigationTitle("Review options")
        .tint(Kit.accent)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { editing = false }.accessibilityIdentifier("vocabulary.options.keyboard.done") }
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard !loaded else { return }
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let settings = try repository.reviewSettings()
            epoch = try repository.learningDataEpoch()
            retention = (settings.desiredRetention * 100).formatted(.number.grouping(.never))
            limit = settings.sessionLimit.map(String.init) ?? ""
            loaded = true
        } catch { message = "Review options could not be loaded. Go back and try again after unlocking your device." }
    }

    private func save() {
        editing = false
        let separator = Locale.current.decimalSeparator ?? "."
        let raw = retention.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: separator, with: ".")
        let rawLimit = limit.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let percent = Double(raw), rawLimit.isEmpty || Int(rawLimit) != nil else {
            message = "Enter a percentage and, if wanted, a positive whole number of words."
            return
        }
        do {
            guard let repository = storage.repository, let epoch else { throw LearnerStorageError.unavailable }
            try repository.saveReviewSettings(ReviewSettings(desiredRetention: percent / 100, sessionLimit: rawLimit.isEmpty ? nil : Int(rawLimit)), expectedEpoch: epoch)
            message = "Review options saved. Existing due dates and earlier ratings are unchanged."
        } catch ReviewScheduleError.invalidSettings {
            message = "Use a percentage greater than 0 and less than 100, and a positive whole number of words or leave it empty."
        } catch LearnerStorageError.invalidState {
            loaded = false
            message = "Learning data changed. Go back and reopen Review options before saving."
        } catch { message = "Your options could not be saved. Your entries are still here. Try Save again after unlocking your device." }
    }
}
