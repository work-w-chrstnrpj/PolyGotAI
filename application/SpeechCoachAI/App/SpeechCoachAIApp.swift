import SwiftUI
import UIKit

@main
struct SpeechCoachAIApp: App {
    @State private var storage = LearnerStorageController()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            AppShell(storage: storage)
                .task {
                    storage.open()
                    storage.usage.recoverLeftover()
                    storage.usage.scenePhaseChanged(scenePhase)
                    storage.practice.recoverLeftover()
                    storage.practice.scenePhaseChanged(scenePhase)
                    TouchSignal.install { storage.practice.touched() }
                    while !Task.isCancelled {
                        try? await Task.sleep(for: .seconds(15))
                        storage.usage.tick()
                        storage.practice.tick()
                        TouchSignal.install { storage.practice.touched() }
                    }
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { storage.open() }
                    storage.usage.scenePhaseChanged(phase)
                    storage.practice.scenePhaseChanged(phase)
                    if phase == .active { TouchSignal.install { storage.practice.touched() } }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.protectedDataWillBecomeUnavailableNotification)) { _ in
                    storage.close()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.protectedDataDidBecomeAvailableNotification)) { _ in
                    storage.open()
                }
        }
    }
}
