import SwiftUI

/// The Lexicon tab (Phase 8): Daily Training with its next review, Practice, the packs in training,
/// the learner's own packs, and saved words. Pack choice, ranks and hiding live in Training settings.
struct LexiconHome: View {
    var storage: LearnerStorageController
    var bank: LexiconBank = LexiconBankLoader.bundled
    @State private var state = LexiconState()
    @State private var stages: [String: LexiconStage] = [:]
    @State private var due = 0
    @State private var newCount = 0
    @State private var nextDue: Date?
    @State private var actionCount = 0
    @State private var practiceCount = 0
    @State private var topics: [CustomVocabularyTopic] = []
    @State private var enrollments: [VocabularyEnrollment] = []
    @State private var loaded = false
    @State private var startLevel = "A1"
    @State private var showSettings = false
    @State private var showNewPack = false

    var body: some View {
        VStack(alignment: .leading, spacing: Kit.Space.xl) {
            Text("A few words a day.").foregroundStyle(Kit.secondary).padding(.top, -Kit.Space.m)
            trainingCard
            if actionCount > 0 { actionRow }
            if loaded, state.trainingGroups(in: bank, startLevel: startLevel).flatMap(\.words).count >= LexiconPracticeBuilder.minimumWords {
                enricherRow
            }
            trainingPacks
            yourPacks
            savedWordsRow
        }
        .onAppear(perform: refresh)
        .sheet(isPresented: $showSettings, onDismiss: refresh) {
            NavigationStack { LexiconSettingsView(storage: storage, bank: bank) }
                .environment(\.kitTheme, KitTheme(storage.preferences.background))
                .tint(Kit.accent)
        }
        .sheet(isPresented: $showNewPack, onDismiss: refresh) {
            NewPackSheet(storage: storage).environment(\.kitTheme, KitTheme(storage.preferences.background)).tint(Kit.accent)
        }
    }

    // MARK: Daily Training

    private var trainingCard: some View {
        HeroCard(eyebrow: "Daily Training", title: trainingTitle, detail: trainingDetail) {
            if due + newCount > 0 {
                NavigationLink("Start") { LexiconTrainingView(storage: storage, bank: bank) }
                    .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("lexicon.train")
            }
            if practiceCount >= LexiconPracticeBuilder.minimumWords {
                NavigationLink("Practice") { LexiconPracticeView(storage: storage, bank: bank) }
                    .buttonStyle(KitSecondaryButtonStyle()).accessibilityIdentifier("lexicon.practice")
            }
        }
    }

    private var trainingTitle: String {
        if !loaded { return "One moment." }
        if due + newCount == 0, state.trainingGroups(in: bank, startLevel: startLevel).isEmpty { return "Choose packs to learn" }
        if due + newCount == 0 { return "All done for today" }
        var parts: [String] = []
        if due > 0 { parts.append("\(due) to review") }
        if newCount > 0 { parts.append("\(newCount) new") }
        return parts.joined(separator: " · ")
    }

    private var trainingDetail: String? {
        guard loaded else { return nil }
        let ranks = state.ranks.map { $0.joined(separator: ", ") } ?? "All ranks"
        if due + newCount == 0, let nextDue {
            return "Next review in \(ReviewSchedule.returnPhrase(due: nextDue, now: .now)) · \(ranks)"
        }
        return ranks
    }

    private var actionRow: some View {
        NavigationLink { LexiconActionView(storage: storage, bank: bank) } label: {
            KitCard {
                KitContentRow(symbol: "bolt.fill", title: "Lexicon in Action",
                              detail: "\(actionCount) \(actionCount == 1 ? "word" : "words") ready", showsChevron: true)
            }
        }.buttonStyle(.kitCard).accessibilityIdentifier("lexicon.action")
    }

    private var enricherRow: some View {
        NavigationLink { LexiconPracticeView(storage: storage, bank: bank, mode: .enricher) } label: {
            KitCard {
                KitContentRow(symbol: "sparkles", title: "Vocabulary Enricher", detail: "Any word from your packs", showsChevron: true)
            }
        }.buttonStyle(.kitCard).accessibilityIdentifier("lexicon.enricher")
    }

    // MARK: Packs

    private var trainingPacks: some View {
        let packs = state.trainingGroups(in: bank, startLevel: startLevel)
        return VStack(alignment: .leading, spacing: Kit.Space.m) {
            SectionHeader(title: "Training from") {
                Button("Settings") { showSettings = true }.accessibilityIdentifier("lexicon.settings")
            }
            if packs.isEmpty {
                KitCard {
                    Text("No packs chosen yet.").font(Kit.Fonts.rowTitle)
                    Button("Choose packs") { showSettings = true }
                        .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("lexicon.choosePacks")
                }
            }
            ForEach(packs) { group in
                KitCard {
                    HStack(alignment: .center, spacing: Kit.Space.m) {
                        VStack(alignment: .leading, spacing: Kit.Space.xs) {
                            Text(group.title).font(Kit.Fonts.rowTitle)
                            Text("\(started(in: group)) of \(group.words.count) started").font(Kit.Fonts.detail).foregroundStyle(Kit.secondary)
                        }
                        Spacer()
                        Text(group.isField ? "Field" : group.level).font(Kit.Fonts.caption)
                            .padding(.horizontal, Kit.Space.s).padding(.vertical, 2).background(Kit.soft, in: Capsule())
                    }
                    ProgressView(value: Double(started(in: group)), total: Double(max(group.words.count, 1))).tint(Kit.accent)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("lexicon.group.\(group.id)")
            }
        }
    }

    private var yourPacks: some View {
        VStack(alignment: .leading, spacing: Kit.Space.m) {
            SectionHeader(title: "Your packs") {
                Button { showNewPack = true } label: { Label("New pack", systemImage: "plus") }
                    .accessibilityIdentifier("vocabulary.topic.new")
            }
            if topics.isEmpty {
                Text("Make a pack for words you need, like a job or a hobby.").font(Kit.Fonts.detail).foregroundStyle(Kit.secondary)
            }
            NavigationLink { LexiconAddWordView(storage: storage, bank: bank) } label: {
                KitCard { KitContentRow(symbol: "plus.circle", title: "Add a word", detail: "Saved in your “My words” pack", showsChevron: true) }
            }
            .buttonStyle(.kitCard).accessibilityIdentifier("lexicon.add")
            ForEach(topics) { topic in
                NavigationLink { CustomTopicEditor(storage: storage, topicID: topic.id) } label: {
                    KitCard {
                        KitContentRow(symbol: "folder", title: topic.title, detail: packDetail(topic), showsChevron: true)
                    }
                }
                .buttonStyle(.kitCard).accessibilityIdentifier("vocabulary.topic.open.\(topic.id.uuidString)")
            }
        }
    }

    private var savedWordsRow: some View {
        let saved = enrollments.filter { $0.origin == .saved }.count
        return NavigationLink { SavedWordsView(storage: storage) } label: {
            KitCard {
                KitContentRow(symbol: "bookmark", title: "Saved words",
                              detail: saved == 0 ? "Words you keep from lessons" : "\(saved) saved", showsChevron: true)
            }
        }
        .buttonStyle(.kitCard).accessibilityIdentifier("lexicon.mywords")
    }

    private func packDetail(_ topic: CustomVocabularyTopic) -> String {
        let training = enrollments.filter { $0.lessonID == topic.id.uuidString && $0.inReview }.count
        let words = "\(topic.senses.count) \(topic.senses.count == 1 ? "word" : "words")"
        return training == 0 ? words : "\(words) · \(training) in training"
    }

    private func started(in group: LexiconGroup) -> Int {
        group.words.filter { (stages[$0.id] ?? .new) != .new }.count
    }

    private func refresh() {
        guard let repository = storage.repository else { return }
        let now = Date()
        startLevel = storage.levelGate(install: CurriculumCatalogLoader.bundled).unlockedLevels.last ?? "A1"
        state = (try? repository.lexiconState()) ?? LexiconState()
        stages = (try? repository.lexiconStages(bank: bank)) ?? [:]
        enrollments = (try? repository.vocabularyEnrollments()) ?? []
        topics = (try? repository.customTopics()) ?? []
        let queue = try? repository.reviewQueue()
        due = queue?.due.count ?? 0
        nextDue = queue?.nextDue
        newCount = LexiconTrainingPlan.newWords(bank: bank, state: state, enrollments: enrollments, now: now, startLevel: startLevel).count
        actionCount = LexiconActionBuilder.eligible(bank: bank, stages: stages, state: state, now: now).count
        practiceCount = LexiconPracticeBuilder.pool(bank: bank, stages: stages, state: state, startLevel: startLevel).count
        loaded = true
    }
}

/// Name a new pack of the learner's own words.
private struct NewPackSheet: View {
    var storage: LearnerStorageController
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var subtopic = ""
    @State private var message: String?

    var body: some View {
        NavigationStack {
            Form { KitRows {
                Section {
                    TextField("Pack name", text: $title).accessibilityIdentifier("vocabulary.topic.title").dictation($title)
                    TextField("Subtopic, optional", text: $subtopic).accessibilityIdentifier("vocabulary.topic.subtopic").dictation($subtopic)
                }
                if let message { Text(message).foregroundStyle(Kit.error) }
            }}
            .navigationTitle("New pack")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create", action: create).disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityIdentifier("vocabulary.topic.save")
                }
            }
        }
    }

    private func create() {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            _ = try repository.createCustomTopic(title: title, subtopic: subtopic)
            dismiss()
        } catch { message = "Use a name under 80 characters and try again." }
    }
}
