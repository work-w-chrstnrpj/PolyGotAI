import AVFAudio
import Combine
import SwiftUI

struct TalkView: View {
    var storage: LearnerStorageController
    @State private var session: TalkSession
    /// One ID per conversation, so a conversation counts once toward the Talk badges.
    @State private var conversationID = UUID()
    @Environment(\.scenePhase) private var scene
    private let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    init(storage: LearnerStorageController, client: any TalkStreaming) {
        self.storage = storage
        #if DEBUG
        if TalkFixtureClient.enabled {
            _session = State(initialValue: TalkSession(client: client, recognition: TalkFixtureRecognition(), speaker: TalkFixtureSpeaker()))
            return
        }
        #endif
        _session = State(initialValue: TalkSession(client: client))
    }
    var body: some View {
        @Bindable var session = session
        SpeechLabPage(storage: storage, title: "Talk") {
            if session.turns.isEmpty && !session.busy {
                Picker("Mode", selection: $session.mode) {
                    ForEach(TalkMode.allCases) { Text($0.title).tag($0) }
                }.pickerStyle(.menu).accessibilityIdentifier("talk.mode")
                if session.mode == .scenario {
                    Menu("Choose scenario") {
                        ForEach(CurriculumCatalogLoader.bundled.lessons.filter { $0.isReady && $0.supplement != nil }) { lesson in
                            Button(lesson.title) { session.scenario = lesson.supplement?.workplace ?? "" }
                        }
                    }.accessibilityIdentifier("talk.scenarios")
                    TextField("Situation", text: $session.scenario, axis: .vertical)
                        .lineLimit(2...4).textFieldStyle(KitFieldStyle()).dictation($session.scenario)
                        .accessibilityIdentifier("talk.scenario")
                        .onChange(of: session.scenario) { _, text in if text.count > 1000 { session.scenario = String(text.prefix(1000)) } }
                }
            }
            if !session.turns.isEmpty {
                Text(session.mode.title).font(.subheadline.weight(.semibold)).foregroundStyle(Kit.secondary)
                    .accessibilityIdentifier("talk.currentMode")
            }
            if !session.busy {
                Toggle("Hands-free turns", isOn: $session.handsFree).accessibilityIdentifier("talk.handsFree")
                if session.handsFree {
                    Slider(value: $session.silence, in: 0.6...3, step: 0.2) { Text("Pause before sending") }
                        .accessibilityValue("\(session.silence.formatted(.number.precision(.fractionLength(1)))) seconds")
                    Text("Pause: \(session.silence.formatted(.number.precision(.fractionLength(1)))) s").font(.caption).foregroundStyle(Kit.secondary)
                }
            }
            ForEach(session.turns) { turn in
                VStack(alignment: .leading, spacing: 6) {
                    Text(turn.role == .user ? "You" : "Partner").font(.caption.bold()).foregroundStyle(Kit.secondary)
                    Text(turn.text.isEmpty ? "…" : turn.text).fixedSize(horizontal: false, vertical: true)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(16)
                    .background(turn.role == .user ? Kit.soft : Kit.surface, in: RoundedRectangle(cornerRadius: Kit.Radius.card))
                    .accessibilityElement(children: .combine).accessibilityIdentifier("talk.turn.\(turn.role.rawValue)")
            }
            if !session.caption.isEmpty { Text(session.caption).italic().accessibilityIdentifier("talk.caption") }
            Label(session.starting ? "Starting microphone" : stateLabel, systemImage: stateSymbol)
                .font(.headline).accessibilityIdentifier("talk.state")
            if let message = session.message { Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("talk.error") }
            if !session.busy {
                Text("Your words go to Alibaba Cloud with your key; your account may be charged.")
                    .font(.footnote).foregroundStyle(Kit.secondary).accessibilityIdentifier("talk.disclosure")
            }
            Button {
                if session.state == .listening { session.send() } else { session.voice = storage.preferences.voiceSettings ?? VoiceSettings(); session.listen() }
            } label: {
                Label(session.state == .listening ? "Send turn" : "Start talking", systemImage: session.state == .listening ? "arrow.up" : "mic.fill")
                    .font(.title2.bold()).frame(maxWidth: .infinity, minHeight: 64)
            }.buttonStyle(KitPrimaryButtonStyle()).disabled(session.starting || session.state == .thinking || session.state == .speaking)
                .accessibilityIdentifier("talk.mic")
            if session.busy {
                Button("Stop") { session.stop() }.buttonStyle(KitSecondaryButtonStyle()).accessibilityIdentifier("talk.stop")
            }
            if !session.busy, !session.turns.isEmpty {
                AIFeedbackSection(request: LabFeedbackRequest(mode: session.mode == .interview ? .interview : .conversation,
                    transcript: session.feedbackText, task: session.mode == .scenario ? session.scenario : session.mode.title, level: storage.feedbackLevel),
                    title: "Talk · \(session.mode.title)", storage: storage)
            }
        }
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Clear") { session.clear() }.accessibilityIdentifier("talk.clear") } }
        .onReceive(timer) { now in session.tick(now: now) }
        .onChange(of: session.turns.filter { $0.role == .assistant && !$0.text.isEmpty }.count) { _, replies in
            // Two answered turns make a conversation; Clear starts a new one.
            if replies == 0 { conversationID = UUID() }
            if replies >= 2 { try? storage.repository?.recordLabActivity("talk." + session.mode.rawValue, id: conversationID) }
        }
        .onAppear { SoundCenter.shared.hold("talk") }
        .onDisappear { session.stop(); SoundCenter.shared.release("talk") }
        .onChange(of: scene) { _, phase in if phase != .active { session.stop() } }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { _ in session.stop() }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)) { note in
            if let reason = note.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
               reason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue { session.stop() }
        }
    }
    private var stateLabel: String {
        switch session.state { case .idle: "Ready"; case .listening: "Listening"; case .thinking: "Thinking"; case .speaking: "Speaking"; case .error: "Try again" }
    }
    private var stateSymbol: String {
        switch session.state { case .idle: "mic"; case .listening: "waveform"; case .thinking: "ellipsis.bubble"; case .speaking: "speaker.wave.2"; case .error: "exclamationmark.circle" }
    }
}

#if DEBUG
@MainActor private final class TalkFixtureRecognition: TalkRecognizing {
    var transcript = ""
    func start() async throws { transcript = "I enjoy learning English and meeting new people." }
    func finish() async throws -> String { transcript }
    func cancel() { transcript = "" }
}
@MainActor private final class TalkFixtureSpeaker: TalkSpeaking {
    var onDrained: (() -> Void)?
    var onFirstAudio: (() -> Void)?
    private var work: Task<Void, Never>?
    func enqueue(_ text: String, settings: VoiceSettings) {
        onFirstAudio?(); work?.cancel()
        work = Task { [weak self] in
            do { try await Task.sleep(for: .milliseconds(200)) } catch { return }
            self?.onDrained?()
        }
    }
    func stop() { work?.cancel(); work = nil }
}
#endif
