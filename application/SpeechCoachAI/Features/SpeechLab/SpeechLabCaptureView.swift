import AVFAudio
import SwiftUI

/// Shared say-it loop. Recognition text is evidence to compare, never an accuracy grade.
struct SpeechLabCaptureView: View {
    var storage: LearnerStorageController
    var store: SpeechLabStore
    var area: SpeechLabArea
    var itemID: String
    var text: String
    @State private var capture: SpeechLabCapture
    @State private var keepAudio = false
    @State private var saved = false
    @State private var pending: SpeechLabAttempt?
    @Environment(\.scenePhase) private var scenePhase
    init(storage: LearnerStorageController, store: SpeechLabStore, area: SpeechLabArea, itemID: String, text: String) {
        self.storage = storage; self.store = store; self.area = area; self.itemID = itemID; self.text = text
        _capture = State(initialValue: SpeechLabCapture(repository: storage.repository, preferences: storage.preferences, itemID: itemID, text: text))
    }
    var body: some View {
        if SpeechLabRecognizer.supported {
            VStack(alignment: .leading, spacing: 16) {
                if capture.isRecording {
                    Text("\(Int(capture.elapsed)) seconds").monospacedDigit()
                    Button("Stop") { capture.stop() }.buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("speechlab.stop")
                } else if capture.recognizing { ProgressView("Listening…") }
                else if let transcript = capture.transcript {
                    if !saved || keepAudio {
                        Button("Play yours") { capture.replay() }.buttonStyle(KitSecondaryButtonStyle()).accessibilityIdentifier("speechlab.replay")
                    }
                    Text("We heard: \(transcript.text)").font(.headline).accessibilityIdentifier("speechlab.heard")
                    SpeechLabDiffView(entries: AnswerChecker.diff(response: transcript.text, expected: text))
                    AIFeedbackSection(request: .pronunciation(target: text, heard: transcript.text, level: storage.feedbackLevel),
                                      title: "Pronunciation", storage: storage)
                    if !saved {
                        Toggle("Keep recording", isOn: $keepAudio).disabled(pending != nil).accessibilityIdentifier("speechlab.keep")
                        Button(pending == nil ? "Save" : "Save again", action: save)
                            .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("speechlab.save")
                    } else { Text("Saved").foregroundStyle(Kit.accent).accessibilityIdentifier("speechlab.saved") }
                    Button("Retry") { capture.leave(); capture.start(); saved = false; pending = nil }
                        .buttonStyle(KitSecondaryButtonStyle()).accessibilityIdentifier("speechlab.retry")
                } else {
                    Button("Record") { capture.start() }.buttonStyle(KitPrimaryButtonStyle())
                        .disabled(capture.busy).accessibilityIdentifier("speechlab.record")
                }
                if let message = capture.message { Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("speechlab.capture.error") }
                if let message = store.message { Text(message).foregroundStyle(Kit.error) }
            }
            .task {
                while !Task.isCancelled {
                    do { try await Task.sleep(for: .milliseconds(100)) } catch { return }
                    capture.tick(maximum: 60)
                }
            }
            .onDisappear { capture.leave() }
            .onChange(of: scenePhase) { _, value in if value != .active { capture.leave() } }
            .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { _ in capture.leave() }
            .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)) { notification in
                if let raw = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
                   AVAudioSession.RouteChangeReason(rawValue: raw) == .oldDeviceUnavailable { capture.leave() }
            }
        }
    }
    private func save() {
        do {
            if pending == nil {
                let id = try capture.finish(keepAudio: keepAudio)
                pending = SpeechLabAttempt(area: area, itemID: itemID, recordingID: id)
            }
            if let pending { saved = store.save(pending) }
        } catch { store.message = "Couldn’t save your practice." }
    }
}
