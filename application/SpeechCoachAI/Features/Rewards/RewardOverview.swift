import SwiftUI

struct RewardOverview: View {
    var storage: LearnerStorageController
    @State private var ledger: RewardLedger?
    @State private var message: String?
    @State private var category = "All"
    @State private var quote: RewardPurchase?
    @Environment(\.scenePhase) private var scene
    private var day: String { RewardPolicy.day(.now) }
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                if let ledger {
                    KitCard {
                        Text("A little practice. Real participation.").font(.title2.bold())
                        Text("\(ledger.xp) XP · \(ledger.gold) gold").font(.title3).accessibilityIdentifier("rewards.balance")
                        Text("XP is participation, not English proficiency. Gold is earned here; there are no real-money purchases.").foregroundStyle(Kit.secondary)
                        Text("\(ledger.currentStreak(day: day)) continuity days · \(ledger.freezes) Freeze items")
                        Text("Protected dates: \(ledger.protectedDays.count). Protection never creates practice or skill evidence.").font(.footnote)
                        NavigationLink("Reward preferences") { RewardSettingsView(storage: storage) }
                            .frame(minHeight: 44).accessibilityIdentifier("rewards.settings")
                    }
                    if !ledger.pendingAwards.isEmpty && ledger.settings.celebration != .off {
                        RewardCelebrationView(ledger: ledger) { perform {
                            try storage.repository?.acknowledgeRewards(ledger.pendingAwards.map(\.id), epoch: ledger.epoch, revision: ledger.revision)
                        } }
                    }
                    KitCard {
                        Text("Continuity tools").font(.headline)
                        Text("Freeze: 20 gold for one missed day. Repair: 30 gold per missed day, up to seven days.")
                        Button("Buy a Freeze · 20 gold") { prepare(.freeze) }.frame(minHeight: 44).accessibilityIdentifier("rewards.buy-freeze")
                        Button("Review Repair cost") { prepare(.repair) }.frame(minHeight: 44).accessibilityIdentifier("rewards.repair")
                        Text("Explanations, corrections, accessibility, replay and retries stay free with zero gold.").font(.footnote)
                        Button("Answer elimination · price not selected") {}.disabled(true)
                    }
                    RewardGoalsView(storage: storage, ledger: ledger, reload: load)
                    DisclosureGroup("Course checkpoints · no collectible or payout") {
                        ForEach(ledger.checkpoints, id: \.journeyID) { checkpoint in
                            Text("\(checkpoint.lessonID) · version \(checkpoint.version) · practice completed \(checkpoint.completedAt.formatted(date: .abbreviated, time: .omitted))")
                        }
                    }
                    DisclosureGroup("Operational indicators · separate from badges") {
                        Text("SYS-01: Active time \(Int(ledger.activeSeconds[day, default: 0])) seconds; target \(ledger.settings.activeMinutesGoal.map { String($0) + " minutes" } ?? "not set").")
                        Text("SYS-02: Activity target \(ledger.settings.activityGoal.map(String.init) ?? "not set"); see today's actual activity count above.")
                        Text("SYS-03: Today's chosen plan \(ledger.plans.first(where: { $0.day == day })?.completed == true ? "complete" : "not complete").")
                        Text("SYS-05: Actual practice dates \(ledger.practiceDays.count); protected dates \(ledger.protectedDays.count).")
                        Text("SYS-06 / SYS-07: Freeze use and Repairs are continuity transactions in wallet history.")
                        NavigationLink("SYS-08: Private weekly evidence summary") { ProgressOverview(storage: storage, install: CurriculumCatalogLoader.bundled) }
                    }
                    Text("Achievements · all 68 adopted families").font(.title3.bold())
                    Picker("Achievement category", selection: $category) {
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
                                    Text(family.collectible ? family.classification : "Noncollectible checkpoint").font(.caption)
                                    Text(family.state(ledger: ledger)).font(.footnote).foregroundStyle(Kit.secondary)
                                }.foregroundStyle(Kit.ink)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }.buttonStyle(.plain).accessibilityIdentifier("rewards.family.\(family.id)")
                    }
                    DisclosureGroup("Wallet history") {
                        ForEach(ledger.transactions.reversed()) { row in
                            VStack(alignment: .leading) {
                                Text(row.reason)
                                Text("\(row.xp >= 0 ? "+" : "")\(row.xp) XP · \(row.gold >= 0 ? "+" : "")\(row.gold) gold · \(row.day)")
                                    .font(.footnote).foregroundStyle(Kit.secondary)
                            }.padding(.vertical, 6)
                        }
                    }
                } else { AvailabilityCard(title: "Rewards unavailable", detail: "Unlock your device and try loading again. Existing data has been kept.", symbol: "exclamationmark.triangle") }
                if let message { Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("rewards.error") }
                Button("Reload", action: load).frame(minHeight: 44)
            }.frame(maxWidth: 700, alignment: .leading).padding(20).frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
        .navigationTitle("Rewards & achievements")
        .modifier(RewardDashboardFocus(storage: storage))
        .onAppear(perform: load)
        .onReceive(NotificationCenter.default.publisher(for: .rewardLedgerChanged)) { _ in
            ledger = try? storage.repository?.rewardLedger()
        }
        .onChange(of: scene) { _, value in if value == .active { load() } else { quote = nil } }
        .alert("Confirm gold purchase", isPresented: Binding(get: { quote != nil }, set: { if !$0 { quote = nil } })) {
            Button("Confirm purchase") {
                guard let quote else { return }; self.quote = nil
                perform { try storage.repository?.purchaseReward(quote) }
            }.accessibilityIdentifier("rewards.purchase.confirm")
            Button("Cancel", role: .cancel) { quote = nil }
        } message: {
            Text("Cost: \(quote?.cost ?? 0) gold. Remaining balance: \((ledger?.gold ?? 0) - (quote?.cost ?? 0)) gold.\n\(quote?.missedDays.joined(separator: ", ") ?? "")\nOnly continuity changes; no learning evidence is created.")
        }
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
        } catch { message = (error as? RewardError)?.message ?? "Rewards could not be loaded. Your saved data is kept." }
    }
    private func prepare(_ kind: RewardPurchase.Kind) {
        do { guard let ledger else { throw RewardError.invalidRequest }; quote = try ledger.quote(kind, day: day); message = nil }
        catch { message = (error as? RewardError)?.message ?? "Purchase unavailable." }
    }
    private func perform(_ action: () throws -> Void) {
        do { guard storage.repository != nil else { throw LearnerStorageError.unavailable }; try action(); load() }
        catch { message = (error as? RewardError)?.message ?? "Nothing was committed. Reload and try again." }
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
                Text(family.collectible ? family.classification : "Noncollectible checkpoint · no badge or payout")
                Text(family.state(ledger: ledger)).font(.headline)
                Text(family.criteria)
                Text("Binding: \(family.bindingVersion). \(family.finiteSet)").font(.footnote)
                Text("Manifest owner: \(family.manifestOwner) · \(family.ruleTemplate)").font(.footnote)
                if family.availability == "unavailable" { Text(family.unavailableReason).foregroundStyle(Kit.secondary) }
                ForEach(ledger.awards.filter { $0.family == family.id }) { award in
                    Text("Earned \(award.earnedAt.formatted(date: .abbreviated, time: .omitted))\(award.tier.map { " · tier \($0)" } ?? "")")
                    DisclosureGroup("Why earned?") {
                        Text("Rule: \(family.ruleVersion). Participation/completion only; no additional currency.")
                        ForEach(award.evidence, id: \.self) { Text($0).font(.caption).textSelection(.enabled) }
                        if award.evidenceUnavailable { Text("Supporting evidence unavailable. No current skill claim.") }
                    }
                }
            }.padding(24).frame(maxWidth: 680).frame(maxWidth: .infinity)
        }.navigationTitle("Achievement details")
    }
}
