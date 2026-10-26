import SwiftUI

/// The three closest milestones with progress bars, and a link to all of them.
struct NextMilestones: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    @State private var milestones: [Milestone] = []

    var body: some View {
        let reached = milestones.filter(\.achieved).count
        VStack(alignment: .leading, spacing: Kit.Space.m) {
            SectionHeader(title: "Milestones") {
                NavigationLink("Show all") { MilestoneListView(milestones: milestones) }
                    .accessibilityIdentifier("milestones.toggle")
            }
            Text("\(reached) of \(milestones.count) reached").font(Kit.Fonts.detail).foregroundStyle(Kit.secondary)
                .accessibilityIdentifier("milestones.count")
            ForEach(Milestone.upNext(milestones)) { row in
                KitCard {
                    HStack(alignment: .firstTextBaseline) {
                        Text(row.title).font(Kit.Fonts.rowTitle)
                        Spacer()
                        Text(row.progress.formatted(.percent.precision(.fractionLength(0))))
                            .font(Kit.Fonts.detail).monospacedDigit().foregroundStyle(Kit.secondary)
                    }
                    ProgressView(value: row.progress).tint(Kit.accent)
                    Text(row.detail).font(Kit.Fonts.detail).foregroundStyle(Kit.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("milestone.\(row.id)")
            }
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

/// Every milestone by group: reached ones with their date, open ones with a bar.
struct MilestoneListView: View {
    var milestones: [Milestone]

    var body: some View {
        List {
            ForEach(Milestone.Group.allCases) { group in
                let rows = milestones.filter { $0.group == group }
                if !rows.isEmpty {
                    Section(group.title) {
                        ForEach(rows) { row in
                            HStack(alignment: .center, spacing: Kit.Space.m) {
                                Image(systemName: row.achieved ? "checkmark.seal.fill" : "circle.dashed")
                                    .foregroundStyle(row.achieved ? Kit.accent : Kit.secondary).accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: Kit.Space.xs) {
                                    Text(row.title)
                                    if row.achieved {
                                        Text(row.date.map { "Reached \($0.formatted(date: .abbreviated, time: .omitted))" } ?? "Reached")
                                            .font(.caption).foregroundStyle(Kit.secondary)
                                    } else {
                                        ProgressView(value: row.progress).tint(Kit.accent)
                                        Text(row.detail).font(.caption).foregroundStyle(Kit.secondary)
                                    }
                                }
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityValue(row.achieved ? "Reached" : row.progress.formatted(.percent.precision(.fractionLength(0))))
                            .accessibilityIdentifier("milestone.\(row.id)")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Milestones")
    }
}
