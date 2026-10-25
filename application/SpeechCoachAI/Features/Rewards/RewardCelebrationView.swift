import SwiftUI
import AVFAudio
import UIKit

/// Presentation consumes committed awards; viewing, skipping and Continue never mint currency.
struct RewardCelebrationView: View {
    var ledger: RewardLedger
    var acknowledge: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scene
    @State private var revealed = false
    @State private var feedback = RewardFeedback()
    private var motion: Bool { !reduceMotion && !ledger.settings.quiet && ledger.settings.celebration != .off }
    var body: some View {
        KitCard {
            Text("Your practice, recognized").font(.headline)
            Text("\(ledger.pendingAwards.count) new achievement\(ledger.pendingAwards.count == 1 ? "" : "s") · already saved")
            ForEach(ledger.pendingAwards) { award in
                if let family = AwardFamily.catalog.first(where: { $0.id == award.family }) {
                    HStack {
                        RewardArtwork(family: family, size: 48)
                            .opacity(revealed || !motion ? 1 : 0.6)
                            .scaleEffect(revealed || !motion || ledger.settings.celebration == .subtle ? 1 : 0.96)
                        Text(family.title + (award.tier.map { " · \($0)" } ?? ""))
                    }
                }
            }
            Button("Continue", action: acknowledge).frame(minHeight: 44).accessibilityIdentifier("rewards.continue")
            if motion { Button("Skip animation") { revealed = true }.frame(minHeight: 44) }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("rewards.celebration")
         .onAppear {
            withAnimation(motion ? .easeOut(duration: 0.2) : nil) { revealed = true }
            feedback.play(settings: ledger.settings)
        }
        .onDisappear { feedback.stop() }
        .onChange(of: scene) { _, phase in if phase != .active { revealed = true; feedback.stop() } }
    }
}

/// "+10 XP · +2 gold" for one answer, or nothing when it earned none.
struct RewardEarnedLine: View {
    var storage: LearnerStorageController
    var source: String
    @State private var ledger: RewardLedger?
    var body: some View {
        let rows = ledger?.transactions.filter { $0.source == source } ?? []
        let xp = rows.reduce(0) { $0 + $1.xp }, gold = rows.reduce(0) { $0 + $1.gold }
        Group {
            if xp > 0 || gold > 0 {
                Label("+\(xp) XP · +\(gold) gold", systemImage: "star.circle.fill")
                    .font(.headline).foregroundStyle(Kit.accent)
                    .accessibilityIdentifier("exercise.reward")
            }
        }
        .onAppear { ledger = try? storage.repository?.rewardLedger() }
        .onReceive(NotificationCenter.default.publisher(for: .rewardLedgerChanged)) { _ in ledger = try? storage.repository?.rewardLedger() }
    }
}

struct RewardSummary: View {
    var storage: LearnerStorageController
    var sourcePrefix: String? = nil
    var sourceTitle = "This practice"
    @State private var ledger: RewardLedger?
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let ledger {
                if let prefix = sourcePrefix {
                    let rows = ledger.transactions.filter { prefix.hasSuffix("/") ? $0.source.hasPrefix(prefix) : $0.source == prefix }
                    Text("\(sourceTitle): \(rows.reduce(0) { $0 + $1.xp }) XP · \(rows.reduce(0) { $0 + $1.gold }) gold")
                        .accessibilityIdentifier("rewards.result")
                    Text("Already included in your wallet. Completion and badges do not pay it again.")
                        .font(.footnote).foregroundStyle(Kit.secondary)
                }
                NavigationLink { RewardOverview(storage: storage) } label: {
                    Label("\(ledger.xp) XP · \(ledger.gold) gold · achievements", systemImage: "seal")
                }.frame(minHeight: 44).accessibilityIdentifier("rewards.open")
            }
        }.onAppear { ledger = try? storage.repository?.rewardLedger() }
        .onReceive(NotificationCenter.default.publisher(for: .rewardLedgerChanged)) { _ in ledger = try? storage.repository?.rewardLedger() }
    }
}

/// Original synthesized tones, no downloaded music, voice, network, or audio-session takeover.
final class RewardFeedback {
    private var player: AVAudioPlayer?
    func stop() { player?.stop(); player = nil }
    func play(settings: RewardSettings) {
        guard !settings.quiet, settings.celebration != .off else { return }
        if settings.haptics { UINotificationFeedbackGenerator().notificationOccurred(.success) }
        guard settings.music || settings.effects,
              !AVAudioSession.sharedInstance().isOtherAudioPlaying else { return }
        let notes: [Double] = (settings.effects ? [659.25] : []) + (settings.music ? [261.63, 329.63, 392, 523.25] : [])
        let rate = 22_050
        let perNote = settings.music ? 0.16 : 0.12
        let count = Int(perNote * Double(rate))
        var pcm = Data()
        for note in notes {
            for index in 0..<count {
                let envelope = sin(Double(index) / Double(count) * .pi)
                var sample = Int16(sin(2 * .pi * note * Double(index) / Double(rate)) * envelope * 1800).littleEndian
                withUnsafeBytes(of: &sample) { pcm.append(contentsOf: $0) }
            }
        }
        var wav = Data("RIFF".utf8)
        func word(_ v: UInt16) { var n = v.littleEndian; withUnsafeBytes(of: &n) { wav.append(contentsOf: $0) } }
        func dword(_ v: UInt32) { var n = v.littleEndian; withUnsafeBytes(of: &n) { wav.append(contentsOf: $0) } }
        dword(UInt32(pcm.count + 36)); wav.append(Data("WAVEfmt ".utf8)); dword(16); word(1); word(1)
        dword(UInt32(rate)); dword(UInt32(rate * 2)); word(2); word(16); wav.append(Data("data".utf8)); dword(UInt32(pcm.count)); wav.append(pcm)
        player = try? AVAudioPlayer(data: wav); player?.volume = 0.25; player?.play()
    }
}
