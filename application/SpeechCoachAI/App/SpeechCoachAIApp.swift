import SwiftUI
import UIKit

@main
struct SpeechCoachAIApp: App {
    @State private var storage = LearnerStorageController()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            AppShell(storage: storage)
                .task { storage.open() }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { storage.open() }
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
