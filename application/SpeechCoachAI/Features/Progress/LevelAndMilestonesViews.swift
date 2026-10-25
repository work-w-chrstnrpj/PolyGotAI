import SwiftUI

/// The learner's level, with a bar to the next one. Taps through to badges.
struct LevelCard: View {
    var storage: LearnerStorageController
    @State private var ledger: RewardLedger?

    var body: some View {
        NavigationLink { RewardOverview(storage: storage) } label: {
            KitCard {
                if let ledger {
                    let level = XPLevel(xp: ledger.xp)
                    HStack(alignment: .firstTextBaseline) {
                        Text("Level \(level.level)").font(.title.bold()).accessibilityIdentifier("progress.level")
                        Spacer()
                        Text("\(ledger.xp) XP").font(.headline).foregroundStyle(Kit.secondary)
                    }
                    ProgressView(value: level.fraction).tint(Kit.accent).accessibilityHidden(true)
                    HStack {
                        Text("\(level.xpToNext) XP to Level \(level.level + 1)").font(.subheadline).foregroundStyle(Kit.secondary)
                        Spacer()
                        Label("Badges", systemImage: "seal").font(.subheadline.weight(.semibold))
                    }
                } else {
                    Text("One moment.").foregroundStyle(Kit.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("progress.levelCard")
        .onAppear(perform: load)
        .onReceive(NotificationCenter.default.publisher(for: .rewardLedgerChanged)) { _ in load() }
    }

    private func load() { ledger = try? storage.repository?.rewardLedger() }
}

/// Milestones reached, and the next one in each group.
struct MilestonesCard: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    @State private var milestones: [Milestone] = []
    @State private var showAll = false

    var body: some View {
        KitCard {
            Text("Milestones").font(.title3.bold())
            let reached = milestones.filter(\.achieved)
            Text("\(reached.count) of \(milestones.count) reached").font(.footnote).foregroundStyle(Kit.secondary)
                .accessibilityIdentifier("milestones.count")
            ForEach(Milestone.Group.allCases) { group in
                let rows = milestones.filter { $0.group == group }
                let shown = showAll ? rows : rows.filter(\.achieved).suffix(2) + rows.filter { !$0.achieved }.prefix(1)
                if !shown.isEmpty {
                    Text(group.title).font(.subheadline.weight(.semibold)).padding(.top, 6)
                    ForEach(shown) { row in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: row.achieved ? "checkmark.seal.fill" : "circle.dashed")
                                .foregroundStyle(row.achieved ? Kit.accent : Kit.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(row.title).font(.body)
                                Text(row.achieved ? (row.date.map { "Reached \($0.formatted(date: .abbreviated, time: .omitted))" } ?? "Reached") : row.detail)
                                    .font(.caption).foregroundStyle(Kit.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityValue(row.achieved ? "Reached" : "Not yet")
                        .accessibilityIdentifier("milestone.\(row.id)")
                    }
                }
            }
            Button(showAll ? "Show fewer" : "Show all") { showAll.toggle() }
                .frame(minHeight: 44).accessibilityIdentifier("milestones.toggle")
        }
        .onAppear(perform: load)
        .onReceive(NotificationCenter.default.publisher(for: .rewardLedgerChanged)) { _ in load() }
        .onReceive(NotificationCenter.default.publisher(for: .usageLogChanged)) { _ in load() }
    }

    private func load() {
        guard let repository = storage.repository else { return }
        do {
            let ledger = try repository.rewardLedger()
            let passed = try repository.passedJumpTests()
            let journeys = try repository.allLessonJourneys()
            let usage = UsageReport(log: try repository.usageLog())
            let easy = try repository.lexiconStages(bank: LexiconBankLoader.bundled).values.filter { $0 == .easy }.count
            milestones = MilestoneBoard.compute(ledger: ledger, passedTests: passed, journeys: journeys, tracks: install.tracks,
                                                usage: usage, easyWordCount: easy)
        } catch { milestones = [] }
    }
}
