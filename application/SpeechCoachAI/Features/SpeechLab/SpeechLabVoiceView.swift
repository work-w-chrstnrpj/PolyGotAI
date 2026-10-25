import AVFAudio
import SwiftUI

struct SpeechLabVoiceView: View {
    var storage: LearnerStorageController
    @State private var store: SpeechLabStore
    private let catalog = SpeechLabCatalog.bundled
    init(storage: LearnerStorageController) { self.storage = storage; _store = State(initialValue: SpeechLabStore(storage.repository)) }
    var body: some View {
        SpeechLabPage(storage: storage, title: "Speaking") {
            Text("Find a steady rhythm.").foregroundStyle(Kit.secondary).lineLimit(1)
            SpeechLabHistory(store: store, area: .voice)
            if SpeechLabRecognizer.supported {
                NavigationLink {
                    SpeechLabVoiceRecording(storage: storage, store: store, passage: nil)
                } label: { KitCard { KitContentRow(symbol: "mic", title: "Free talk", detail: "Speak for 30–60 seconds", showsChevron: true) } }
                    .buttonStyle(.plain).accessibilityIdentifier("voice.free")
            }
            Text("Warm-ups").font(.title3.bold())
            ForEach(catalog.warmups) { warmup in
                NavigationLink {
                    SpeechLabWarmupView(storage: storage, store: store, warmup: warmup)
                } label: { KitCard { KitContentRow(symbol: "timer", title: warmup.title, detail: "\(warmup.seconds) seconds", showsChevron: true) } }
                    .buttonStyle(.plain).accessibilityIdentifier("voice.warmup.\(warmup.id)")
            }
            Text("Read aloud").font(.title3.bold())
            ForEach(catalog.passages) { passage in
                NavigationLink {
                    SpeechLabVoiceRecording(storage: storage, store: store, passage: passage)
                } label: { KitCard { KitContentRow(symbol: "text.alignleft", title: passage.title, detail: passage.level, showsChevron: true) } }
                    .buttonStyle(.plain).accessibilityIdentifier("voice.passage.\(passage.id)")
            }
        }.onAppear { store.reload() }
    }
}

private struct SpeechLabVoiceRecording: View {
    var storage: LearnerStorageController
    var store: SpeechLabStore
    var passage: SpeechLabPassage?
    @State private var capture: SpeechLabCapture
    @State private var keepAudio = false
    @State private var saved = false
    @State private var pending: SpeechLabAttempt?
    @Environment(\.scenePhase) private var scenePhase
    init(storage: LearnerStorageController, store: SpeechLabStore, passage: SpeechLabPassage?) {
        self.storage = storage; self.store = store; self.passage = passage
        _capture = State(initialValue: SpeechLabCapture(repository: storage.repository, preferences: storage.preferences,
            itemID: passage?.id ?? "voice-free", text: passage?.text ?? "Talk about a small discovery you made this week and explain why it interested you."))
    }
    private var metrics: SpeechLabVoiceMetrics? {
        guard let transcript = capture.transcript else { return nil }
        return SpeechLabVoiceMetrics.measure(transcript.words, duration: capture.elapsed)
    }
    var body: some View {
        SpeechLabPage(storage: storage, title: passage?.title ?? "Free talk") {
            if let passage { KitCard { Text(passage.text).font(.title3); SpeechLabModelAudio(text: passage.text) } }
            else { KitCard { Text("Talk about a small discovery you made this week and explain why it interested you.").font(.title3) } }
            if SpeechLabRecognizer.supported {
                recordingControls
                if let message = capture.message { Text(message).foregroundStyle(Kit.error) }
            }
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
    @ViewBuilder private var recordingControls: some View {
        if capture.isRecording {
            KitCard {
                Text("\(Int(capture.elapsed)) of 60 seconds").monospacedDigit().accessibilityIdentifier("voice.timer")
                ProgressView(value: Double(capture.level)).tint(Kit.accent)
                    .accessibilityLabel("Loudness").accessibilityValue(SpeechLabVoiceMetrics.loudness(capture.level).rawValue)
                    .accessibilityIdentifier("voice.meter")
                Text(SpeechLabVoiceMetrics.loudness(capture.level).rawValue).font(.headline)
            }
            Button("Stop") { capture.stop() }.buttonStyle(KitPrimaryButtonStyle())
                .disabled(capture.elapsed < 30).accessibilityIdentifier("speechlab.stop")
        } else if capture.recognizing { ProgressView("Listening…") }
        else if let metrics, capture.elapsed >= 30 {
            KitCard {
                Text("\(Int(metrics.wordsPerMinute.rounded())) words per minute").font(.title2.bold()).accessibilityIdentifier("voice.wpm")
                Text("\(metrics.pauses) pauses over 1 second · \(metrics.fillers) filler words").accessibilityIdentifier("voice.metrics")
                Text("\(metrics.pace) · aim for about 120–160 wpm.").foregroundStyle(Kit.secondary)
                if let transcript = capture.transcript { Text("We heard: \(transcript.text)").accessibilityIdentifier("speechlab.heard") }
                if !saved || keepAudio {
                    Button("Play yours") { capture.replay() }.buttonStyle(.bordered).accessibilityIdentifier("speechlab.replay")
                }
            }
            if !saved {
                Toggle("Keep recording", isOn: $keepAudio).disabled(pending != nil).accessibilityIdentifier("speechlab.keep")
                Button(pending == nil ? "Save" : "Save again", action: save)
                    .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("speechlab.save")
            } else { Text("Saved").accessibilityIdentifier("speechlab.saved") }
            Button("Retry") { capture.leave(); capture.start(); saved = false; pending = nil }.buttonStyle(.bordered).accessibilityIdentifier("speechlab.retry")
        } else {
            Button("Record") { capture.start() }.buttonStyle(KitPrimaryButtonStyle())
                .disabled(capture.busy).accessibilityIdentifier("speechlab.record")
            Text("30–60 seconds").font(.caption).foregroundStyle(Kit.secondary)
        }
    }
    private func save() {
        guard let metrics else { return }
        do {
            if pending == nil {
                let id = try capture.finish(keepAudio: keepAudio)
                pending = SpeechLabAttempt(area: .voice, itemID: passage?.id ?? "voice-free", wordsPerMinute: metrics.wordsPerMinute,
                    pauses: metrics.pauses, fillers: metrics.fillers, recordingID: id)
            }
            if let pending { saved = store.save(pending) }
        } catch { store.message = "Couldn’t save your practice." }
    }
}

private struct SpeechLabWarmupView: View {
    var storage: LearnerStorageController
    var store: SpeechLabStore
    var warmup: SpeechLabWarmup
    @State private var remaining: Int
    @State private var running = false
    @State private var pending: SpeechLabAttempt?
    @State private var saved = false
    @Environment(\.scenePhase) private var scenePhase
    init(storage: LearnerStorageController, store: SpeechLabStore, warmup: SpeechLabWarmup) {
        self.storage = storage; self.store = store; self.warmup = warmup; _remaining = State(initialValue: warmup.seconds)
    }
    var body: some View {
        SpeechLabPage(storage: storage, title: warmup.title) {
            KitCard { Text(warmup.text).font(.title3) }
            Text("\(remaining) seconds").font(.largeTitle.monospacedDigit()).accessibilityIdentifier("voice.warmup.timer")
            if remaining == 0 {
                Text("Warm-up complete").font(.headline).accessibilityIdentifier("voice.warmup.complete")
                if !saved {
                    Button("Save again") { if let pending { saved = store.save(pending) } }.buttonStyle(.bordered)
                }
                Button("Again") { remaining = warmup.seconds; saved = false; pending = nil }
            } else {
                Button(running ? "Pause" : "Start") { running.toggle() }.buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("voice.warmup.start")
            }
            if let message = store.message { Text(message).foregroundStyle(Kit.error) }
        }
        .task(id: running) {
            guard running else { return }
            // Tests use the same timer loop with an explicit isolated fixture clock.
            while remaining > 0, !Task.isCancelled {
                do { try await Task.sleep(for: SpeechLabRecognizer.fixture ? .milliseconds(30) : .seconds(1)) } catch { return }
                guard !Task.isCancelled, running else { return }
                remaining -= 1
            }
            if remaining == 0 {
                running = false
                let attempt = SpeechLabAttempt(area: .voice, itemID: warmup.id)
                pending = attempt; saved = store.save(attempt)
            }
        }
        .onDisappear { running = false }
        .onChange(of: scenePhase) { _, phase in if phase != .active { running = false } }
    }
}
