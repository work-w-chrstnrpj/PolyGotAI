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
                    while !Task.isCancelled {
                        try? await Task.sleep(for: .seconds(15))
                        storage.usage.tick()
                    }
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { storage.open() }
                    storage.usage.scenePhaseChanged(phase)
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
