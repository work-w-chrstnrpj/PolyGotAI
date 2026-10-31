import AVFoundation
import UIKit

/// Background music, sound effects and haptics (2026-10-30). The sounds are original and synthesized by
/// `tools/audio/make_sounds.py`. Music and effects use the ambient category, so they mix with other apps and stay silent
/// when the ringer switch is off. Anything that speaks, listens or plays lesson audio holds the audio for a moment
/// (`hold` / `release`), and music pauses until every hold is released.
@MainActor
final class SoundCenter {
    enum Effect: String, CaseIterable { case correct, wrong, complete, badge }

    static let shared = SoundCenter()
    static let musicVolume: Float = 0.14
    static let effectVolume: Float = 0.5

    private(set) var musicOn = false
    private(set) var effectsOn = false
    private(set) var hapticsOn = false
    /// Who is using audio now ("speech", "dictation", "recording", ...). Music waits while any is present.
    private(set) var holders: Set<String> = []
    private var isActive = true
    private var music: AVAudioPlayer?
    private var players: [Effect: AVAudioPlayer] = [:]
    private let success = UINotificationFeedbackGenerator()

    /// Applies the learner's choices from Badges → Preferences or Settings.
    func configure(_ settings: RewardSettings) {
        musicOn = settings.music && !settings.quiet
        effectsOn = settings.effects && !settings.quiet
        hapticsOn = settings.haptics
        update()
    }

    func hold(_ holder: String) { holders.insert(holder); update() }
    func release(_ holder: String) { holders.remove(holder); update() }

    /// For code that may run off the main actor (recognizers, capture). On the main thread it applies at once.
    nonisolated static func holdAudio(_ holder: String) {
        if Thread.isMainThread { MainActor.assumeIsolated { shared.hold(holder) } } else { Task { @MainActor in shared.hold(holder) } }
    }

    nonisolated static func releaseAudio(_ holder: String) {
        if Thread.isMainThread { MainActor.assumeIsolated { shared.release(holder) } } else { Task { @MainActor in shared.release(holder) } }
    }

    func setAppActive(_ active: Bool) { isActive = active; update() }

    /// Right or wrong answer: a chime and a haptic.
    func answer(correct: Bool) {
        play(correct ? .correct : .wrong)
        guard hapticsOn else { return }
        success.notificationOccurred(correct ? .success : .error)
    }

    func play(_ effect: Effect) {
        if effect == .badge || effect == .complete, hapticsOn { success.notificationOccurred(.success) }
        guard effectsOn, holders.isEmpty, isActive, prepareAmbient() else { return }
        let player = players[effect] ?? Self.player(named: "sfx-" + effect.rawValue)
        players[effect] = player
        player?.volume = Self.effectVolume
        player?.currentTime = 0
        player?.play()
    }

    private func update() {
        let wanted = musicOn && holders.isEmpty && isActive
        if wanted {
            guard prepareAmbient() else { return }
            if music == nil {
                music = Self.player(named: "music-calm")
                music?.numberOfLoops = -1
                music?.volume = Self.musicVolume
            }
            if music?.isPlaying == false { music?.play() }
        } else {
            music?.pause()
            if !musicOn { music = nil }
        }
    }

    /// Switches to the ambient category only while nothing else holds the audio, and never over another app's audio.
    private func prepareAmbient() -> Bool {
        let session = AVAudioSession.sharedInstance()
        guard holders.isEmpty, !session.secondaryAudioShouldBeSilencedHint else { return false }
        if session.category != .ambient { try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers]) }
        try? session.setActive(true)
        return true
    }

    private static func player(named name: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return nil }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        return player
    }
}
