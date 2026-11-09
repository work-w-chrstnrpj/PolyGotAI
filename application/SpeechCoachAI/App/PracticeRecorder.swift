import Foundation
import SwiftUI
import UIKit

/// Records practice time (ticket #6). The `.practiceScreen(area:)` marker says which area is open; this recorder owns the
/// clock, the app's foreground state, touch-based idle, the heartbeat snapshot, crash recovery and saving.
/// It records times and areas only: never screens, content or answers. A stretch that cannot be saved yet waits, also
/// across a restart, and is saved later (same pattern as `UsageRecorder`).
@MainActor
final class PracticeRecorder {
    private var tracker = PracticeTracker()
    private let defaults: UserDefaults
    private let save: (PracticeStretch) throws -> Void
    private let clock: () -> Date
    private var pending: [PracticeStretch]

    private enum Key {
        static let open = "practice.open"        // PracticeOpenSnapshot of the stretch in progress
        static let pending = "practice.pending"  // [PracticeStretch] finished but not yet saved
    }

    init(defaults: UserDefaults = .standard, clock: @escaping () -> Date = Date.init, save: @escaping (PracticeStretch) throws -> Void) {
        self.defaults = defaults
        self.clock = clock
        self.save = save
        pending = (defaults.data(forKey: Key.pending)).flatMap { try? JSONDecoder().decode([PracticeStretch].self, from: $0) } ?? []
    }

    /// The area of the practice screen open right now, if any.
    var openArea: PracticeArea? { tracker.area }

    /// Call once at launch: a stretch left open by a crash or force-quit is closed at its last heartbeat.
    func recoverLeftover() {
        if let data = defaults.data(forKey: Key.open),
           let snapshot = try? JSONDecoder().decode(PracticeOpenSnapshot.self, from: data),
           let stretch = PracticeTracker.recover(snapshot) {
            hold([stretch])
        }
        defaults.removeObject(forKey: Key.open)
        flushPending()
    }

    /// The marker's area changed: nil when no practice screen is open. Same area again changes nothing.
    func areaChanged(_ area: PracticeArea?) {
        guard area != tracker.area else { return }
        let now = clock()
        var finished: [PracticeStretch] = []
        if let area { finished = tracker.screenOpened(area, at: now) }
        else { finished = tracker.screenClosed(at: now) }
        hold(finished)
        persistOpen()
        flushPending()
    }

    /// A touch happened somewhere in the app. Only the fact is kept.
    func touched() { tracker.touch(at: clock()); }

    func scenePhaseChanged(_ phase: ScenePhase) {
        let now = clock()
        switch phase {
        case .active:
            hold(tracker.becameActive(at: now))
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
        hold(tracker.finishIfAway(at: now))
        persistOpen()
        flushPending()
    }

    private func persistOpen() {
        if let snapshot = tracker.openSnapshot, let data = try? JSONEncoder().encode(snapshot) { defaults.set(data, forKey: Key.open) }
        else { defaults.removeObject(forKey: Key.open) }
    }

    private func hold(_ stretches: [PracticeStretch]) {
        guard !stretches.isEmpty else { return }
        pending += stretches
        defaults.set(try? JSONEncoder().encode(pending), forKey: Key.pending)
    }

    private func flushPending() {
        guard !pending.isEmpty else { return }
        var remaining: [PracticeStretch] = []
        for stretch in pending {
            do { try save(stretch) } catch { remaining.append(stretch) }
        }
        pending = remaining
        if remaining.isEmpty { defaults.removeObject(forKey: Key.pending) }
        else { defaults.set(try? JSONEncoder().encode(remaining), forKey: Key.pending) }
        NotificationCenter.default.post(name: .practiceLogChanged, object: nil)
    }
}

extension Notification.Name { static let practiceLogChanged = Notification.Name("SpeechCoachAI.practiceLogChanged") }

// MARK: Touch signal

/// A window-level recogniser that reports only that a touch happened. It never reads locations or targets, never
/// delays or cancels touches, and fails at once so it cannot interfere with other gestures.
private final class TouchSignalRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {
    var onTouch: (() -> Void)?
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        cancelsTouchesInView = false; delaysTouchesBegan = false; delaysTouchesEnded = false
        delegate = self
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) { onTouch?(); state = .failed }
    func gestureRecognizer(_ g: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }
}

enum TouchSignal {
    /// Adds the recogniser to every window of the app's scenes once. Safe to call again.
    @MainActor
    static func install(onTouch: @escaping () -> Void) {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows where !(window.gestureRecognizers ?? []).contains(where: { $0 is TouchSignalRecognizer }) {
                let recognizer = TouchSignalRecognizer(target: nil, action: nil)
                recognizer.onTouch = onTouch
                window.addGestureRecognizer(recognizer)
            }
        }
    }
}
