import SwiftUI

/// A full-screen celebration when a badge is earned or a milestone is reached (2026-10-30): confetti, the badge popping in,
/// a chime and a haptic. It follows Badges → Preferences: Off shows nothing, Subtle and Reduce Motion skip the confetti.
/// Continue acknowledges the badges, so each one is celebrated once.
struct CelebrationOverlay: ViewModifier {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    @Environment(\.scenePhase) private var scene
    @State private var shown: Celebration?
    @State private var check: Task<Void, Never>?
    /// Progress the milestones were last worked out for; milestones are only recomputed when it changes.
    @State private var milestoneKey = ""

    /// UI tests with synthetic data see the overlay only when they ask for it.
    static var enabled: Bool {
        #if DEBUG
        if SpeakingEnvironment.fixtureID != nil { return ProcessInfo.processInfo.environment["SC_CELEBRATION_FIXTURE"] == "1" }
        #endif
        return true
    }

    struct Celebration: Equatable {
        var awards: [RewardAward]
        var milestones: [Milestone]
        var epoch: UUID
        var subtle: Bool
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                if let shown {
                    CelebrationCard(celebration: shown) { finish(shown) }
                        .transition(.opacity)
                        .zIndex(10)
                }
            }
            .animation(.easeOut(duration: 0.25), value: shown)
            .onAppear { schedule() }
            .onReceive(NotificationCenter.default.publisher(for: .rewardLedgerChanged)) { _ in schedule() }
            .onChange(of: scene) { _, phase in if phase == .active { schedule() } }
    }

    /// Waits a moment so a burst of saves (one answer can write several times) gives one celebration.
    private func schedule() {
        check?.cancel()
        check = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(700))
            guard !Task.isCancelled, shown == nil else { return }
            evaluate()
        }
    }

    private func evaluate() {
        guard Self.enabled, let repository = storage.repository, let ledger = try? repository.rewardLedger(),
              ledger.settings.celebration != .off else { return }
        let catalog = Dictionary(uniqueKeysWithValues: AwardFamily.catalog.map { ($0.id, $0) })
        let awards = ledger.pendingAwards.filter { award in
            guard let family = catalog[award.family] else { return false }
            return family.collectible && family.isShown(in: ledger)
        }
        let milestones = reachedMilestones(ledger: ledger, repository: repository)
        // Badges that are not shown (checkpoints, hidden) are acknowledged quietly.
        let quiet = ledger.pendingAwards.filter { award in !awards.contains(award) }.map(\.id)
        if !quiet.isEmpty { try? repository.acknowledgeRewards(quiet, epoch: ledger.epoch, revision: ledger.revision) }
        guard !awards.isEmpty || !milestones.isEmpty else { return }
        let subtle = ledger.settings.celebration == .subtle || ledger.settings.quiet
        shown = Celebration(awards: awards, milestones: milestones, epoch: ledger.epoch, subtle: subtle)
        SoundCenter.shared.play(.badge)
    }

    /// Milestones reached since the last check. The first check marks everything already reached, without a celebration.
    private func reachedMilestones(ledger: RewardLedger, repository: LearnerRepository) -> [Milestone] {
        guard let passed = try? repository.passedJumpTests(), let journeys = try? repository.allLessonJourneys(),
              let log = try? repository.usageLog(),
              let stages = try? repository.lexiconStages(bank: LexiconBankLoader.bundled) else { return [] }
        let easy = stages.values.filter { $0 == .easy }.count
        let key = "\(ledger.xp)|\(passed.count)|\(journeys.filter { $0.completedAt != nil }.count)|\(easy)|\(log.sessions.count)|\(((try? repository.labExtras().watched) ?? [:]).count)"
        if ledger.celebratedMilestones != nil, key == milestoneKey { return [] }
        milestoneKey = key
        let all = MilestoneBoard.compute(ledger: ledger, passedTests: passed, journeys: journeys, tracks: install.tracks,
                                         usage: UsageReport(log: log), easyWordCount: easy, watched: (try? repository.labExtras().watched) ?? [:])
        let reached = all.filter(\.achieved)
        guard let celebrated = ledger.celebratedMilestones else {
            try? repository.markMilestonesCelebrated(reached.map(\.id))
            return []
        }
        return reached.filter { !celebrated.contains($0.id) }
    }

    private func finish(_ celebration: Celebration) {
        shown = nil
        guard let repository = storage.repository else { return }
        if !celebration.milestones.isEmpty { try? repository.markMilestonesCelebrated(celebration.milestones.map(\.id)) }
        if let ledger = try? repository.rewardLedger(), !celebration.awards.isEmpty {
            try? repository.acknowledgeRewards(celebration.awards.map(\.id), epoch: ledger.epoch, revision: ledger.revision)
        }
    }
}

private struct CelebrationCard: View {
    var celebration: CelebrationOverlay.Celebration
    var dismiss: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var popped = false

    private var families: [(AwardFamily, RewardAward)] {
        celebration.awards.compactMap { award in AwardFamily.catalog.first { $0.id == award.family }.map { ($0, award) } }
    }
    private var motion: Bool { !reduceMotion && !celebration.subtle }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea().onTapGesture(perform: dismiss).accessibilityHidden(true)
            if motion { ConfettiView().ignoresSafeArea().allowsHitTesting(false).accessibilityHidden(true) }
            VStack(spacing: 16) {
                Text(heading).font(.title2.bold()).multilineTextAlignment(.center)
                    .accessibilityIdentifier("celebration.title")
                if let (family, award) = families.first {
                    RewardArtwork(family: family, size: 120)
                        .scaleEffect(popped ? 1 : 0.3)
                        .rotationEffect(.degrees(popped ? 0 : -25))
                    Text(family.title + (award.tier.map { " · \($0)" } ?? "")).font(.headline).multilineTextAlignment(.center)
                } else if let milestone = celebration.milestones.first {
                    Image(systemName: "flag.checkered").font(.system(size: 64)).foregroundStyle(Kit.accent)
                        .scaleEffect(popped ? 1 : 0.3)
                    Text(milestone.title).font(.headline).multilineTextAlignment(.center)
                }
                let more = extra
                if !more.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(more.prefix(4), id: \.self) { Label($0, systemImage: "sparkles").font(.subheadline) }
                        if more.count > 4 { Text("and \(more.count - 4) more").font(.subheadline).foregroundStyle(Kit.secondary) }
                    }
                }
                Button("Continue", action: dismiss).buttonStyle(KitPrimaryButtonStyle())
                    .accessibilityIdentifier("celebration.continue")
            }
            .padding(24)
            .frame(maxWidth: 360)
            .background(Kit.surface, in: RoundedRectangle(cornerRadius: Kit.Radius.card, style: .continuous))
            .foregroundStyle(Kit.ink)
            .padding(24)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("celebration")
        }
        .onAppear {
            withAnimation(motion ? .spring(response: 0.5, dampingFraction: 0.55) : nil) { popped = true }
            UIAccessibility.post(notification: .announcement, argument: heading)
        }
    }

    private var heading: String {
        let badges = celebration.awards.count, milestones = celebration.milestones.count
        if badges > 0 { return badges == 1 ? "Badge earned!" : "\(badges) badges earned!" }
        return milestones == 1 ? "Milestone reached!" : "\(milestones) milestones reached!"
    }

    /// Everything after the first item, as short lines.
    private var extra: [String] {
        let badges = families.map { family, award in family.title + (award.tier.map { " · \($0)" } ?? "") }
        let milestones = celebration.milestones.map(\.title)
        return Array((badges + milestones).dropFirst())
    }
}

/// Falling confetti drawn with Canvas; about three seconds, then it fades.
private struct ConfettiView: View {
    private struct Piece {
        var x: Double, delay: Double, speed: Double, spin: Double, size: Double, hue: Int, drift: Double
    }
    @State private var start = Date()
    private let pieces: [Piece] = (0..<70).map { index in
        var generator = SplitMix(seed: UInt64(index) &* 2_654_435_761)
        return Piece(x: generator.unit(), delay: generator.unit() * 0.6, speed: 0.35 + generator.unit() * 0.35,
                     spin: (generator.unit() - 0.5) * 12, size: 6 + generator.unit() * 6, hue: index % 5, drift: (generator.unit() - 0.5) * 0.15)
    }

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(start)
            Canvas { canvas, size in
                let colors: [Color] = [Kit.accent, .yellow, .pink, .orange, .mint]
                for piece in pieces {
                    let t = elapsed - piece.delay
                    guard t > 0 else { continue }
                    let y = -20 + t * piece.speed * size.height
                    guard y < size.height + 20 else { continue }
                    let x = (piece.x + sin(t * 3 + piece.spin) * piece.drift) * size.width
                    var copy = canvas
                    copy.opacity = max(0, min(1, 3.2 - elapsed))
                    copy.translateBy(x: x, y: y)
                    copy.rotate(by: .radians(t * piece.spin))
                    copy.fill(Path(CGRect(x: -piece.size / 2, y: -piece.size / 4, width: piece.size, height: piece.size / 2)),
                              with: .color(colors[piece.hue]))
                }
            }
        }
    }
}

/// Small deterministic generator so the confetti layout is the same each time.
private struct SplitMix {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
    mutating func unit() -> Double { Double(next() >> 11) / Double(1 << 53) }
}
