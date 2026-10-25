import SwiftUI

/// The Lexicon tab: Daily Training, Lexicon in Action, groups, and the learner's own words.
struct LexiconHome: View {
    var storage: LearnerStorageController
    var bank: LexiconBank = LexiconBankLoader.bundled
    @State private var state = LexiconState()
    @State private var stages: [String: LexiconStage] = [:]
    @State private var due = 0
    @State private var newCount = 0
    @State private var actionCount = 0
    @State private var wordCount = 0
    @State private var loaded = false
    @State private var startLevel = "A1"
    @State private var onlineAvailable = AIFeedbackController(service: AIFeedbackController.localService()).isAvailable

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("A few words a day.").foregroundStyle(Kit.secondary)
            trainingCard
            if actionCount > 0 { actionCard }
            groupsSection
            myWordsSection
        }
        .onAppear(perform: refresh)
    }

    private var trainingCard: some View {
        KitCard {
            Text("Daily Training").font(.title2.bold())
            Text(trainingDetail).foregroundStyle(Kit.secondary)
            if due + newCount > 0 {
                NavigationLink("Start") { LexiconTrainingView(storage: storage, bank: bank) }
                    .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("lexicon.train")
            }
        }
    }

    private var trainingDetail: String {
        if due + newCount == 0 { return loaded ? "All done for today." : "One moment." }
        var parts: [String] = []
        if due > 0 { parts.append("\(due) to review") }
        if newCount > 0 { parts.append("\(newCount) new") }
        return parts.joined(separator: " · ")
    }

    private var actionCard: some View {
        NavigationLink {
            LexiconActionView(storage: storage, bank: bank)
        } label: {
            KitCard {
                KitContentRow(symbol: "bolt.fill", title: "Lexicon in Action",
                              detail: "\(actionCount) \(actionCount == 1 ? "word" : "words") ready", showsChevron: true)
            }
        }.buttonStyle(.plain).accessibilityIdentifier("lexicon.action")
    }

    private var groupsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Groups").font(.title3.bold())
            ForEach(bank.groups.filter { !$0.isField }) { group in groupCard(group) }
            if bank.groups.contains(where: \.isField) {
                Text("Field packs").font(.title3.bold()).padding(.top, 8)
                ForEach(bank.groups.filter(\.isField)) { group in groupCard(group) }
            }
        }
    }

    private func groupCard(_ group: LexiconGroup) -> some View {
        KitCard {
            Toggle(isOn: binding(for: group)) {
                VStack(alignment: .leading, spacing: 4) {
                    ViewThatFits(in: .horizontal) {
                        groupHeading(group)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(group.title).font(.headline).fixedSize(horizontal: false, vertical: true)
                            groupBadge(group)
                        }
                    }
                    Text("\(started(in: group)) of \(group.words.count) started · \(group.tagline)")
                        .font(.subheadline).foregroundStyle(Kit.secondary)
                }
            }
            .accessibilityIdentifier("lexicon.group.\(group.id)")
        }
    }

    private func groupHeading(_ group: LexiconGroup) -> some View {
        HStack(spacing: 8) {
            Text(group.title).font(.headline).fixedSize()
            groupBadge(group)
        }
    }

    private func groupBadge(_ group: LexiconGroup) -> some View {
        HStack(spacing: 8) {
            Text(group.isField ? "Field" : group.level).font(.caption.weight(.semibold))
                .padding(.horizontal, 8).padding(.vertical, 2)
                .background(Kit.soft, in: Capsule())
            if suggested?.id == group.id {
                Text("Next").font(.caption.weight(.semibold)).foregroundStyle(Kit.accent)
            }
        }.fixedSize()
    }

    private var myWordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My words").font(.title3.bold())
            NavigationLink {
                LexiconAddWordView(storage: storage, bank: bank)
            } label: {
                KitCard { KitContentRow(symbol: "plus.circle", title: "Add a word", detail: "Keep your own words", showsChevron: true) }
            }.buttonStyle(.plain).accessibilityIdentifier("lexicon.add")
            NavigationLink {
                ScrollView { CustomTopicList(storage: storage).padding(20) }
                    .background(Kit.canvas(storage.preferences.background)).navigationTitle("My words")
            } label: {
                KitCard { KitContentRow(symbol: "square.stack", title: "Saved words and topics",
                                        detail: wordCount == 0 ? "From lessons and your topics" : "\(wordCount) saved", showsChevron: true) }
            }.buttonStyle(.plain).accessibilityIdentifier("lexicon.mywords")
            if onlineAvailable {
                NavigationLink {
                    SpecializedLexiconView(storage: storage, bank: bank)
                } label: {
                    KitCard { KitContentRow(symbol: "sparkles", title: "Specialized words", detail: "Words for any topic", showsChevron: true) }
                }.buttonStyle(.plain).accessibilityIdentifier("lexicon.specialized")
            }
        }
    }

    private var suggested: LexiconGroup? {
        LexiconSuggestion.nextGroup(bank: bank, state: state, stages: stages, startLevel: startLevel)
    }

    private func started(in group: LexiconGroup) -> Int {
        group.words.filter { (stages[$0.id] ?? .new) != .new }.count
    }

    private func binding(for group: LexiconGroup) -> Binding<Bool> {
        Binding(get: { state.isActive(group, in: bank, startLevel: startLevel) }, set: { active in
            state.setActive(group, active, in: bank, startLevel: startLevel)
            try? storage.repository?.saveLexiconState(state)
            refresh()
        })
    }

    private func refresh() {
        guard let repository = storage.repository else { return }
        let now = Date()
        startLevel = storage.levelGate(install: CurriculumCatalogLoader.bundled).unlockedLevels.last ?? "A1"
        state = (try? repository.lexiconState()) ?? LexiconState()
        stages = (try? repository.lexiconStages(bank: bank)) ?? [:]
        let enrollments = (try? repository.vocabularyEnrollments()) ?? []
        wordCount = enrollments.count
        due = (try? repository.reviewQueue().due.count) ?? 0
        newCount = LexiconTrainingPlan.newWords(bank: bank, state: state, enrollments: enrollments, now: now, startLevel: startLevel).count
        actionCount = LexiconActionBuilder.eligible(bank: bank, stages: stages, state: state, now: now).count
        loaded = true
    }
}
