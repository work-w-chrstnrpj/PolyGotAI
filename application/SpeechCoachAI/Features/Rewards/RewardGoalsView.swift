import SwiftUI
import Observation

struct RewardGoalsView: View {
    var storage: LearnerStorageController
    var ledger: RewardLedger
    var reload: () -> Void
    @State private var lessonID = ""
    @State private var message: String?
    @Environment(\.scenePhase) private var scene
    private var day: String { RewardPolicy.day(.now) }
    var body: some View {
        KitCard {
            Text("Today's separate goals").font(.headline)
            Text("\(Int(ledger.activeSeconds[day, default: 0] / 60)) active minutes\(ledger.settings.activeMinutesGoal.map { " / \($0)" } ?? " · target not set")")
            let count = ledger.transactions.filter { $0.day == day && ["exercise","speaking","review"].contains($0.kind) }.count
            Text("\(count) activities\(ledger.settings.activityGoal.map { " / \($0)" } ?? " · target not set")")
            if let plan = ledger.plans.first(where: { $0.day == day }) {
                Text(plan.completed ? "Chosen lesson plan complete · +25 XP / +10 gold already committed" : "Plan: \(plan.lessonID), version \(plan.contentVersion) · finish its \(plan.activityIDs.count) practice tasks today")
                Text("Correction/self-review is included. The time target is independent.").font(.footnote)
            } else {
                Picker("Choose today's lesson plan", selection: $lessonID) {
                    Text("Choose a lesson").tag("")
                    ForEach(CurriculumCatalogLoader.bundled.lessons.filter(\.isReady)) { lesson in Text(lesson.title).tag(lesson.id) }
                }
                Button("Start this lesson plan") { startPlan() }.disabled(lessonID.isEmpty).frame(minHeight: 44).accessibilityIdentifier("rewards.plan.start")
                Text("Only its named current-version tasks completed after you start count. One plan bonus per local date; learning remains available without a plan.").font(.footnote)
            }
            if let minutes = ledger.settings.breakMinutes {
                if let end = storage.rewardEngagement.breakEnd {
                    TimelineView(.periodic(from: .now, by: 1)) { timeline in
                        if timeline.date >= end { Text("Timer finished. Continue your exercise or take a break. Nothing was saved or rewarded.").accessibilityIdentifier("rewards.break.finished") }
                        else { Text("Timer: \(Int(end.timeIntervalSince(timeline.date))) seconds remaining") }
                    }
                    Button("Stop timer") { storage.rewardEngagement.stopBreak() }.frame(minHeight: 44)
                } else { Button("Start \(minutes)-minute break timer") { storage.rewardEngagement.startBreak(minutes: minutes) }.frame(minHeight: 44) }
            }
            if let message { Text(message).foregroundStyle(Kit.error) }
        }
        .onChange(of: scene) { _, phase in storage.rewardEngagement.setActive(phase == .active) }
    }
    private func startPlan() {
        do {
            guard let repository = storage.repository, let lesson = CurriculumCatalogLoader.bundled.lessons.first(where: { $0.id == lessonID }) else { throw RewardError.invalidRequest }
            try repository.startRewardPlan(lessonID: lesson.id, contentVersion: lesson.contentVersion, epoch: ledger.epoch, revision: ledger.revision)
            message = nil; reload()
        } catch { message = (error as? RewardError)?.message ?? "Plan could not be saved. Reload before trying again." }
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
