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
            ForEach(bank.groups) { group in
                KitCard {
                    Toggle(isOn: binding(for: group)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(group.title).font(.headline)
                            Text("\(started(in: group)) of \(group.words.count) started · \(group.tagline)")
                                .font(.subheadline).foregroundStyle(Kit.secondary)
                        }
                    }
                    .accessibilityIdentifier("lexicon.group.\(group.id)")
                }
            }
        }
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
        }
    }

    private func started(in group: LexiconGroup) -> Int {
        group.words.filter { (stages[$0.id] ?? .new) != .new }.count
    }

    private func binding(for group: LexiconGroup) -> Binding<Bool> {
        Binding(get: { state.isActive(group, in: bank) }, set: { active in
            state.setActive(group, active, in: bank)
            try? storage.repository?.saveLexiconState(state)
            refresh()
        })
    }

    private func refresh() {
        guard let repository = storage.repository else { return }
        let now = Date()
        state = (try? repository.lexiconState()) ?? LexiconState()
        stages = (try? repository.lexiconStages(bank: bank)) ?? [:]
        let enrollments = (try? repository.vocabularyEnrollments()) ?? []
        wordCount = enrollments.count
        due = (try? repository.reviewQueue().due.count) ?? 0
        newCount = LexiconTrainingPlan.newWords(bank: bank, state: state, enrollments: enrollments, now: now).count
        actionCount = LexiconActionBuilder.eligible(bank: bank, stages: stages, state: state, now: now).count
        loaded = true
    }
}
