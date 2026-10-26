import SwiftUI

/// Progress (Phase 7): level, streak and this week's time at a glance; badges; time in the app; next milestones.
struct ProgressOverview: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    @State private var ledger: RewardLedger?
    @State private var weekSeconds = 0
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(alignment: .leading, spacing: Kit.Space.xl) {
            if let ledger {
                LevelCard(storage: storage, ledger: ledger, weekSeconds: weekSeconds)
                BadgeGrid(storage: storage, ledger: ledger)
            }
            UsageAnalyticsView(storage: storage)
            NextMilestones(storage: storage, install: install)
            NavigationLink {
                ScrollView { PracticeHistoryContent(storage: storage).padding(20) }
                    .background(Kit.canvas(storage.preferences.background))
                    .navigationTitle("Saved practice")
            } label: {
                KitCard { KitContentRow(symbol: "clock.arrow.circlepath", title: "Saved practice", detail: "Recordings and notes", showsChevron: true) }
            }
            .buttonStyle(.plain).accessibilityIdentifier("progress.history")
        }
        .onAppear(perform: reload)
        .onChange(of: storage.repository != nil) { _, _ in reload() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { reload() } }
        .onReceive(NotificationCenter.default.publisher(for: .rewardLedgerChanged)) { _ in reload() }
        .onReceive(NotificationCenter.default.publisher(for: .usageLogChanged)) { _ in reload() }
    }

    private func reload() {
        guard let repository = storage.repository else { return }
        ledger = try? repository.rewardLedger()
        if var log = try? repository.usageLog() {
            if let open = storage.usage.openStretch() { log.record(start: open.start, end: open.end) }
            weekSeconds = UsageReport(log: log).total(.week, containing: .now)
        }
    }
}

/// Level with a bar to the next one, streak and this week's time. Taps through to badges.
private struct LevelCard: View {
    var storage: LearnerStorageController
    var ledger: RewardLedger
    var weekSeconds: Int

    var body: some View {
        let level = XPLevel(xp: ledger.xp)
        VStack(spacing: Kit.Space.m) {
            NavigationLink { RewardOverview(storage: storage) } label: {
                KitCard {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Level \(level.level)").font(Kit.Fonts.hero).accessibilityIdentifier("progress.level")
                        Spacer()
                        Text("\(ledger.xp) XP").font(.headline).foregroundStyle(Kit.secondary)
                    }
                    ProgressView(value: level.fraction).tint(Kit.accent).accessibilityHidden(true)
                    HStack {
                        Text("\(level.xpToNext) XP to Level \(level.level + 1)").font(Kit.Fonts.detail).foregroundStyle(Kit.secondary)
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(Kit.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("progress.levelCard")
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Kit.Space.m) { tiles }
                VStack(spacing: Kit.Space.m) { tiles }
            }
        }
    }

    @ViewBuilder private var tiles: some View {
        StatTile(title: "Day streak", value: "\(ledger.currentStreak(day: RewardPolicy.day(.now)))", symbol: "flame")
        StatTile(title: "This week", value: UsageFormat.duration(weekSeconds), symbol: "clock")
    }
}

/// Earned badges first, then the next ones to earn, up to six. "See all" opens the full list.
private struct BadgeGrid: View {
    var storage: LearnerStorageController
    var ledger: RewardLedger
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        let earnedIDs = ledger.awards.sorted { $0.earnedAt > $1.earnedAt }.map(\.family)
        let earned = AwardFamily.catalog.filter { earnedIDs.contains($0.id) }
            .sorted { (earnedIDs.firstIndex(of: $0.id) ?? 0) < (earnedIDs.firstIndex(of: $1.id) ?? 0) }
        let next = AwardFamily.catalog.filter { $0.collectible && !earnedIDs.contains($0.id) }
        let shown = Array((earned + next).prefix(6))
        VStack(alignment: .leading, spacing: Kit.Space.m) {
            SectionHeader(title: "Badges · \(earned.count) earned") {
                NavigationLink("See all") { RewardOverview(storage: storage) }.accessibilityIdentifier("progress.badges.all")
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: textSize.isAccessibilitySize ? 160 : 100), spacing: Kit.Space.m)],
                      spacing: Kit.Space.m) {
                ForEach(shown) { family in
                    let isEarned = earnedIDs.contains(family.id)
                    BadgeTile(title: family.title, detail: isEarned ? nil : "Not earned yet") {
                        RewardArtwork(family: family, size: 56, status: isEarned ? "Earned" : "Not earned yet")
                    }
                    .accessibilityIdentifier("progress.badge.\(family.id)")
                }
            }
        }
    }
}
