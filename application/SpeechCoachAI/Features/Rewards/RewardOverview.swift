import SwiftUI

/// Badges, level and daily goals. XP is the only currency; it is participation, not an English level.
struct RewardOverview: View {
    var storage: LearnerStorageController
    @State private var ledger: RewardLedger?
    @State private var message: String?
    @State private var category = "All"
    @Environment(\.scenePhase) private var scene
    private var day: String { RewardPolicy.day(.now) }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                if let ledger {
                    let level = XPLevel(xp: ledger.xp)
                    KitCard {
                        Text("Level \(level.level)").font(.title.bold()).accessibilityIdentifier("rewards.level")
                        ProgressView(value: level.fraction).tint(Kit.accent).accessibilityHidden(true)
                        Text("\(ledger.xp) XP · \(level.xpToNext) to Level \(level.level + 1)").font(.title3).accessibilityIdentifier("rewards.balance")
                        Text("\(ledger.currentStreak(day: day)) days in a row")
                        NavigationLink("Preferences") { RewardSettingsView(storage: storage) }
                            .frame(minHeight: 44).accessibilityIdentifier("rewards.settings")
                    }
                    if !ledger.pendingAwards.isEmpty && ledger.settings.celebration != .off {
                        RewardCelebrationView(ledger: ledger) { perform {
                            try storage.repository?.acknowledgeRewards(ledger.pendingAwards.map(\.id), epoch: ledger.epoch, revision: ledger.revision)
                        } }
                    }
                    RewardGoalsView(storage: storage, ledger: ledger, reload: load)
                    Text("Badges").font(.title3.bold())
                    Picker("Badge category", selection: $category) {
                        ForEach(["All", "Participation", "Completion", "Learning", "Consistency", "Checkpoints"], id: \.self) { Text($0).tag($0) }
                    }.accessibilityIdentifier("rewards.category")
                    ForEach(AwardFamily.catalog.filter { family in
                        category == "All" || (category == "Checkpoints" ? !family.collectible : family.classification.localizedCaseInsensitiveContains(category))
                    }) { family in
                        NavigationLink { AwardDetail(family: family, ledger: ledger) } label: {
                            HStack(alignment: .center, spacing: 12) {
                                RewardArtwork(family: family, status: family.state(ledger: ledger))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(family.title).font(.headline)
                                    Text(family.state(ledger: ledger)).font(.footnote).foregroundStyle(Kit.secondary)
                                }.foregroundStyle(Kit.ink)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }.buttonStyle(.plain).accessibilityIdentifier("rewards.family.\(family.id)")
                    }
                    DisclosureGroup("XP history") {
                        ForEach(ledger.transactions.filter { $0.xp != 0 }.reversed()) { row in
                            VStack(alignment: .leading) {
                                Text(row.reason)
                                Text("\(row.xp >= 0 ? "+" : "")\(row.xp) XP · \(row.day)").font(.footnote).foregroundStyle(Kit.secondary)
                            }.padding(.vertical, 6)
                        }
                    }
                } else { AvailabilityCard(title: "Badges did not load", detail: "Unlock your device and try again. Your data is kept.", symbol: "exclamationmark.triangle") }
                if let message { Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("rewards.error") }
            }.frame(maxWidth: 700, alignment: .leading).padding(20).frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
        .navigationTitle("Badges")
        .modifier(RewardDashboardFocus(storage: storage))
        .onAppear(perform: load)
        .onReceive(NotificationCenter.default.publisher(for: .rewardLedgerChanged)) { _ in
            ledger = try? storage.repository?.rewardLedger()
        }
        .onChange(of: scene) { _, value in if value == .active { load() } }
    }

    private func load() {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            var value = try repository.rewardLedger()
            if value.settings.autoFreeze {
                try repository.refreshRewardContinuity(epoch: value.epoch, revision: value.revision)
                value = try repository.rewardLedger()
            }
            ledger = value; message = nil
        } catch { message = (error as? RewardError)?.message ?? "Badges could not be loaded. Your saved data is kept." }
    }

    private func perform(_ action: () throws -> Void) {
        do { guard storage.repository != nil else { throw LearnerStorageError.unavailable }; try action(); load() }
        catch { message = (error as? RewardError)?.message ?? "Nothing was saved. Reload and try again." }
    }
}

private struct AwardDetail: View {
    var family: AwardFamily
    var ledger: RewardLedger
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                RewardArtwork(family: family, size: 180, status: family.state(ledger: ledger)).frame(maxWidth: .infinity)
                Text(family.title).font(.title2.bold())
                Text(family.state(ledger: ledger)).font(.headline)
                Text(family.criteria)
                ForEach(ledger.awards.filter { $0.family == family.id }) { award in
                    Text("Earned \(award.earnedAt.formatted(date: .abbreviated, time: .omitted))\(award.tier.map { " · tier \($0)" } ?? "")")
                }
            }.padding(24).frame(maxWidth: 680).frame(maxWidth: .infinity)
        }.navigationTitle("Badge")
    }
}
