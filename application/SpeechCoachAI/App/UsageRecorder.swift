import Foundation
import SwiftUI

/// Watches when the app is on screen and saves each stretch of a minute or more to the usage log.
/// It records times only: no screens, content or location. A stretch that cannot be saved yet (for example while the
/// device is locked) waits, also across a restart, and is saved later.
@MainActor
final class UsageRecorder {
    private var tracker = UsageTracker()
    private let defaults: UserDefaults
    private let save: (Date, Date) throws -> Void
    private let clock: () -> Date
    private var pending: [[Double]]

    private enum Key {
        static let open = "usage.open"          // [start, lastSeen] of the stretch in progress
        static let pending = "usage.pending"    // [[start, end]] finished but not yet saved
    }

    init(defaults: UserDefaults = .standard, clock: @escaping () -> Date = Date.init, save: @escaping (Date, Date) throws -> Void) {
        self.defaults = defaults
        self.clock = clock
        self.save = save
        pending = defaults.array(forKey: Key.pending) as? [[Double]] ?? []
    }

    /// The stretch on screen right now, once it has lasted a minute. Shown in Progress before it is saved.
    func openStretch(now: Date = .now) -> (start: Date, end: Date)? {
        guard tracker.isActive, let start = tracker.start, now.timeIntervalSince(start) >= TimeInterval(UsageLog.minimumSeconds) else { return nil }
        return (start, now)
    }

    /// Call once at launch: a stretch left open by a crash or a force-quit is closed at its last heartbeat.
    func recoverLeftover() {
        if let open = defaults.array(forKey: Key.open) as? [Double], open.count == 2, open[1] > open[0] {
            hold(Date(timeIntervalSince1970: open[0]), Date(timeIntervalSince1970: open[1]))
        }
        defaults.removeObject(forKey: Key.open)
        flushPending()
    }

    func scenePhaseChanged(_ phase: ScenePhase) {
        let now = clock()
        switch phase {
        case .active:
            if let finished = tracker.becameActive(at: now) { hold(finished.start, finished.end) }
            persistOpen()
            flushPending()
        case .inactive, .background:
            tracker.becameInactive(at: now)
            persistOpen()
        @unknown default:
            break
        }
    }

    /// Call every few seconds while the app runs.
    func tick() {
        let now = clock()
        tracker.heartbeat(at: now)
        if let finished = tracker.finishIfIdle(at: now) { hold(finished.start, finished.end); defaults.removeObject(forKey: Key.open) }
        else { persistOpen() }
        flushPending()
    }

    private func persistOpen() {
        guard let start = tracker.start, let seen = tracker.lastSeen else { return }
        defaults.set([start.timeIntervalSince1970, seen.timeIntervalSince1970], forKey: Key.open)
    }

    private func hold(_ start: Date, _ end: Date) {
        guard end.timeIntervalSince(start) >= TimeInterval(UsageLog.minimumSeconds) else { return }
        pending.append([start.timeIntervalSince1970, end.timeIntervalSince1970])
        defaults.set(pending, forKey: Key.pending)
    }

    private func flushPending() {
        guard !pending.isEmpty else { return }
        var remaining: [[Double]] = []
        for pair in pending {
            do { try save(Date(timeIntervalSince1970: pair[0]), Date(timeIntervalSince1970: pair[1])) }
            catch { remaining.append(pair) }
        }
        pending = remaining
        if remaining.isEmpty { defaults.removeObject(forKey: Key.pending) } else { defaults.set(remaining, forKey: Key.pending) }
        NotificationCenter.default.post(name: .usageLogChanged, object: nil)
    }
}

extension Notification.Name { static let usageLogChanged = Notification.Name("SpeechCoachAI.usageLogChanged") }
