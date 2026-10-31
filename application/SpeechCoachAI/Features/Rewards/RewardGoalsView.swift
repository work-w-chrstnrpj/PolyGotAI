import SwiftUI
import Observation

/// Today's goals (redesigned 2026-10-31): active time and activities against the learner's own targets, an optional
/// lesson plan worth +25 XP, and the optional break timer. Targets and the timer length are set in Badges → Preferences.
struct RewardGoalsView: View {
    var storage: LearnerStorageController
    var ledger: RewardLedger
    var reload: () -> Void
    @State private var message: String?
    @Environment(\.scenePhase) private var scene
    private var day: String { RewardPolicy.day(.now) }
    private var catalog: CurriculumInstall { CurriculumCatalogLoader.bundled }

    var body: some View {
        KitCard {
            HStack {
                Text("Today's goals").font(.headline)
                Spacer()
                NavigationLink("Set goals") { RewardSettingsView(storage: storage) }
                    .font(.subheadline).accessibilityIdentifier("rewards.goals.set")
            }
            let minutes = Int(ledger.activeSeconds[day, default: 0] / 60)
            goalRow("Active time", value: minutes, goal: ledger.settings.activeMinutesGoal, unit: "min", id: "rewards.goal.time")
            let count = ledger.transactions.filter { $0.day == day && ["exercise", "speaking", "review"].contains($0.kind) }.count
            goalRow("Activities", value: count, goal: ledger.settings.activityGoal, unit: "", id: "rewards.goal.count")
            Divider()
            planSection
            if let minutes = ledger.settings.breakMinutes { breakTimer(minutes) }
            if let message { Text(message).font(.footnote).foregroundStyle(Kit.error) }
        }
        .onChange(of: scene) { _, phase in storage.rewardEngagement.setActive(phase == .active) }
    }

    /// "Active time   12 / 20 min" with a bar, or just the value when no target is set.
    private func goalRow(_ title: String, value: Int, goal: Int?, unit: String, id: String) -> some View {
        let suffix = unit.isEmpty ? "" : " \(unit)"
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text(goal.map { "\(value) / \($0)\(suffix)" } ?? "\(value)\(suffix)")
                    .monospacedDigit().foregroundStyle(goal.map { value >= $0 } == true ? Kit.accent : Kit.ink)
            }
            if let goal {
                ProgressView(value: Double(min(value, goal)), total: Double(max(goal, 1))).tint(Kit.accent).accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(id)
    }

    // MARK: Lesson plan

    @ViewBuilder private var planSection: some View {
        if let plan = ledger.plans.first(where: { $0.day == day }) {
            let title = catalog.lesson(id: plan.lessonID, version: plan.contentVersion)?.title ?? plan.lessonID
            let done = planDone(plan)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label(title, systemImage: plan.completed ? "checkmark.circle.fill" : "book")
                        .foregroundStyle(plan.completed ? Kit.accent : Kit.ink)
                    Spacer()
                    Text(plan.completed ? "+25 XP" : "\(done) of \(plan.activityIDs.count)").monospacedDigit().foregroundStyle(Kit.secondary)
                }
                if !plan.completed {
                    ProgressView(value: Double(done), total: Double(max(plan.activityIDs.count, 1))).tint(Kit.accent).accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("rewards.plan")
        } else {
            Menu {
                ForEach(LevelGate.levels, id: \.self) { level in
                    let lessons = catalog.lessons(at: level).filter(\.isReady)
                    if !lessons.isEmpty {
                        Section(level) {
                            ForEach(lessons) { lesson in Button(lesson.title) { startPlan(lesson) } }
                        }
                    }
                }
            } label: {
                Label("Plan a lesson for today · +25 XP", systemImage: "calendar.badge.plus").frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            }
            .accessibilityIdentifier("rewards.plan.start")
        }
    }

    /// Plan tasks finished today since the plan started.
    private func planDone(_ plan: RewardPlan) -> Int {
        let finished = Set(ledger.transactions.filter { $0.day == plan.day && $0.createdAt >= plan.startedAt
            && ["exercise", "speaking", "completion"].contains($0.kind) }.map(\.activity))
        return plan.activityIDs.filter { finished.contains("\(plan.lessonID)/\(plan.contentVersion)/\($0)") }.count
    }

    private func startPlan(_ lesson: ResolvedLesson) {
        do {
            guard let repository = storage.repository else { throw RewardError.invalidRequest }
            try repository.startRewardPlan(lessonID: lesson.id, contentVersion: lesson.contentVersion, epoch: ledger.epoch, revision: ledger.revision)
            message = nil; reload()
        } catch { message = (error as? RewardError)?.message ?? "Plan could not be saved. Reload before trying again." }
    }

    // MARK: Break timer

    @ViewBuilder private func breakTimer(_ minutes: Int) -> some View {
        Divider()
        if let end = storage.rewardEngagement.breakEnd {
            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                HStack {
                    if timeline.date >= end {
                        Label("Break over", systemImage: "bell").accessibilityIdentifier("rewards.break.finished")
                    } else {
                        let left = Int(end.timeIntervalSince(timeline.date))
                        Label(String(format: "Break · %d:%02d", left / 60, left % 60), systemImage: "cup.and.saucer").monospacedDigit()
                    }
                    Spacer()
                    Button("Stop") { storage.rewardEngagement.stopBreak() }.frame(minHeight: 44)
                }
            }
        } else {
            Button { storage.rewardEngagement.startBreak(minutes: minutes) } label: {
                Label("Take a \(minutes)-minute break", systemImage: "cup.and.saucer").frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            }
        }
    }
}


/// A shared focus stack prevents a presented practice/recording sheet and its parent counting twice.
@Observable
final class RewardEngagementState {
    var owners: [UUID] = []
    var clock = RewardActiveClock()
    var epoch: UUID?
    var pending: [(UUID, String, Double)] = []
    var message: String?
    var breakEnd: Date?
    var pausedBreak: Double?
    func startBreak(minutes: Int) { breakEnd = Date().addingTimeInterval(Double(minutes) * 60); pausedBreak = nil }
    func stopBreak() { breakEnd = nil; pausedBreak = nil }
    func setActive(_ active: Bool) {
        clock.previous = nil
        if !active, let end = breakEnd { pausedBreak = max(0, end.timeIntervalSinceNow); breakEnd = nil }
        else if active, let remaining = pausedBreak { breakEnd = Date().addingTimeInterval(remaining); pausedBreak = nil }
    }
    func claim(_ id: UUID, epoch: UUID?) {
        if self.epoch != epoch { owners = []; pending = []; clock = RewardActiveClock(); stopBreak(); self.epoch = epoch }
        owners.removeAll { $0 == id }; owners.append(id); clock.previous = nil
        clock.interact(at: ProcessInfo.processInfo.systemUptime)
    }
    func release(_ id: UUID) { owners.removeAll { $0 == id }; clock.previous = nil }
    func pulse(_ id: UUID, storage: LearnerStorageController, audio: Bool) {
        guard owners.last == id else { return }
        do {
            guard let repo = storage.repository, let epoch, try repo.learningDataEpoch() == epoch else {
                pending = []; stopBreak(); return
            }
            let seconds = clock.sample(at: ProcessInfo.processInfo.systemUptime, active: true, audio: audio)
            if seconds > 0 { pending.append((UUID(), RewardPolicy.day(.now), seconds)) }
            while let sample = pending.first {
                try repo.addRewardActiveTime(seconds: sample.2, day: sample.1, epoch: epoch, sampleID: sample.0)
                pending.removeFirst()
            }
            message = nil
        } catch { message = "Active time could not be saved. It will retry while this practice is open." }
    }
}

struct RewardEngagementModifier: ViewModifier {
    var storage: LearnerStorageController
    var audio: () -> Bool
    @Environment(\.scenePhase) private var scene
    @State private var id = UUID()
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(TapGesture().onEnded { storage.rewardEngagement.clock.interact(at: ProcessInfo.processInfo.systemUptime) })
            .simultaneousGesture(DragGesture(minimumDistance: 10).onChanged { _ in storage.rewardEngagement.clock.interact(at: ProcessInfo.processInfo.systemUptime) })
            .onAppear { storage.rewardEngagement.claim(id, epoch: try? storage.repository?.learningDataEpoch()) }
            .onDisappear { storage.rewardEngagement.release(id) }
            .onChange(of: scene) { _, value in storage.rewardEngagement.setActive(value == .active) }
            .safeAreaInset(edge: .bottom) {
                if let message = storage.rewardEngagement.message { Text(message).font(.footnote).padding(8).background(Kit.surface) }
            }
            .task(id: scene) {
                guard scene == .active else { return }
                while !Task.isCancelled {
                    storage.rewardEngagement.pulse(id, storage: storage, audio: audio())
                    do { try await Task.sleep(for: .seconds(5)) } catch { return }
                }
            }
    }
}

/// A dashboard presented inside an existing learning NavigationStack suppresses the covered practice owner.
struct RewardDashboardFocus: ViewModifier {
    var storage: LearnerStorageController
    @State private var id = UUID()
    func body(content: Content) -> some View {
        content
            .onAppear { storage.rewardEngagement.claim(id, epoch: try? storage.repository?.learningDataEpoch()) }
            .onDisappear { storage.rewardEngagement.release(id) }
    }
}
