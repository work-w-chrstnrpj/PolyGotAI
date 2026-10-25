import AVFAudio
import SwiftUI
import UIKit

struct RecordingView: View {
    var storage: LearnerStorageController
    var context: PracticeSessionContext?
    @State private var recording = RecordingController()
    @State private var keepAudio = false
    @State private var keepText = false
    @State private var online = OnlinePracticeController()
    @State private var showLeave = false
    @State private var showDiscard = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    private let clock = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var isIndependentTurn: Bool {
        ["conversationTurn", "interviewTurn", "communicationTurn"].contains(recording.activeProvenance?.purpose ?? context?.provenance?.purpose ?? "")
    }
    @ViewBuilder private var finishedReceipt: some View {
        Label("Self-review finished", systemImage: "checkmark.circle").font(.title2)
        if let selected = recording.candidate ?? recording.accepted {
            let source = recording.activeProvenance.map { "lesson/\($0.journeyID)/\($0.activityID)" } ?? "speaking/\(selected.completionID ?? selected.id)"
            RewardSummary(storage: storage, sourcePrefix: source)
        }
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if SpeakingEnvironment.fixtureID != nil {
                        Text("TEST FIXTURE · Synthetic audio and responses · No network or charges")
                            .font(.headline).foregroundStyle(Kit.error).accessibilityIdentifier("fixture.banner")
                    }
                    Text(isIndependentTurn ? "Your practice turn" : recording.activeProvenance?.purpose == "specialistPractice" ? "\(recording.activeProvenance?.role.capitalized ?? "Specialist") practice" : recording.activeProvenance?.purpose == "coursePractice" || recording.activeProvenance == nil ? "Your introduction" : "Personal check")
                        .font(.title2.bold())
                    if context?.sourceLessonID != nil {
                        Label("Speaking practice for your lesson", systemImage: "book")
                            .font(.subheadline).foregroundStyle(Kit.accent).accessibilityIdentifier("recording.lessonContext")
                    }
                    Text(recording.activePrompt.text ?? "").fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("recording.prompt")
                    Text("Up to 2 minutes")
                        .font(.callout).foregroundStyle(Kit.secondary)
                    if recording.phase == .finished {
                        finishedReceipt
                    } else {
                        controls
                    }
                    if let message = recording.message {
                        Text(message).foregroundStyle(Kit.secondary).accessibilityIdentifier("recording.message")
                    }
                    if recording.permissionDenied {
                        Button("Open App Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                        }.buttonStyle(.bordered)
                    }
                    if recording.phase == .ready, !recording.recoverable.isEmpty {
                        KitCard {
                            Text("Recover a previous take").font(.headline)
                            ForEach(recording.recoverable, id: \.id) { take in
                                Button("Review take from \(take.createdAt.formatted(date: .abbreviated, time: .shortened))") { recording.recover(take) }
                                    .buttonStyle(.bordered).accessibilityIdentifier("recording.recover")
                            }
                        }
                    }
                }.padding(20).frame(maxWidth: 700).frame(maxWidth: .infinity)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { reviewDecisionBar }
            .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
            .navigationTitle("Record & review").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button(recording.phase == .finished ? "Done" : "Close") {
                    if recording.phase == .finished || (recording.candidate == nil && recording.accepted == nil && recording.phase == .ready) { dismiss() }
                    else { online.cancel(); recording.stop(interrupted: true); showLeave = true }
                }
            } }
            .confirmationDialog("Leave this practice?", isPresented: $showLeave, titleVisibility: .visible) {
                Button("Keep drafts for later") { if recording.keepForLater() { dismiss() } }
                Button("Discard session drafts", role: .destructive) { if recording.discardSession() { dismiss() } }
                Button("Continue reviewing", role: .cancel) { }
            } message: { Text("Temporary drafts expire 24 hours after your last explicit recovery interaction. Recording will not resume automatically.") }
            .confirmationDialog("Discard this take?", isPresented: $showDiscard, titleVisibility: .visible) {
                Button("Discard take", role: .destructive) { recording.discardCandidate() }
                Button("Keep take", role: .cancel) { }
            }
        }
        .tint(Kit.accent).preferredColorScheme(storage.preferences.appearance.colorScheme)
        .interactiveDismissDisabled(recording.phase != .finished)
        .modifier(RewardEngagementModifier(storage: storage, audio: { recording.phase == .recording || recording.isPlaying }))
        .onAppear { recording.load(storage.repository, context: context) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { online.cancel(); recording.stop(interrupted: true) }
            if phase == .active { recording.load(storage.repository, context: context) }
        }
        .onChange(of: recording.accepted?.id) { _, id in
            keepAudio = false; keepText = false
            if let id { online.load(storage.repository, attemptID: id) } else { online.cancel() }
        }
        .onReceive(clock) { _ in recording.tick() }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { _ in recording.stop(interrupted: true) }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)) { notification in
            if let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
               reason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue { recording.stop(interrupted: true) }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.protectedDataWillBecomeUnavailableNotification)) { _ in online.cancel(); recording.stop(interrupted: true) }
        .onDisappear { online.cancel(); recording.stop(interrupted: true); recording.stopPlayback() }
    }

    @ViewBuilder private var reviewDecisionBar: some View {
        if recording.phase == .review, recording.accepted != nil {
            VStack(alignment: .leading, spacing: 10) {
                Toggle("Save selected voice recording", isOn: $keepAudio)
                    .accessibilityIdentifier("recording.keepAudio")
                Toggle("Save transcript and feedback", isOn: $keepText)
                    .disabled(online.attempt?.transcripts.isEmpty != false)
                    .accessibilityIdentifier("recording.keepText")
                Button("Finish self-review") {
                    let selected = recording.accepted
                    online.cancel(); recording.finish(keepAudio: keepAudio, keepText: keepText)
                    if recording.phase == .finished, let selected, let source = selected.speakingProvenance,
                       ["baseline", "repeatedBaseline", "transfer", "delayedRecall"].contains(source.purpose) {
                        storage.latestCheckSpeech = LessonSpeechCompletion(lessonID: source.packID, journeyID: source.journeyID,
                            attemptID: selected.id, activityID: source.activityID)
                    }
                    if recording.phase == .finished, let selected, let source = selected.speakingProvenance,
                       ["conversationTurn", "interviewTurn", "communicationTurn"].contains(source.purpose), let slotID = UUID(uuidString: source.activityID) {
                        storage.latestPracticeRecording = IndependentPracticeRecording(sessionID: source.journeyID, slotID: slotID, attemptID: selected.id)
                    }
                    if recording.phase == .finished, let selected, let lessonID = selected.sourceLessonID,
                       let journeyID = selected.sourceLessonJourneyID, ["coursePractice", "topicPractice"].contains(selected.speakingProvenance?.purpose ?? "") {
                        storage.latestLessonSpeech = LessonSpeechCompletion(lessonID: lessonID, journeyID: journeyID, attemptID: selected.id, activityID: selected.speakingProvenance?.activityID)
                    }
                }
                    .buttonStyle(.borderedProminent).foregroundStyle(Color("OnAccent"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityIdentifier("recording.finish")
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Kit.surface)
            .overlay(alignment: .top) { Rectangle().fill(Kit.secondary.opacity(0.25)).frame(height: 1) }
        }
    }

    @ViewBuilder private var controls: some View {
        switch recording.phase {
        case .ready, .review:
            if recording.phase == .review {
                KitCard {
                    Text("Review before choosing a take").font(.headline)
                    if let candidate = recording.candidate, let audio = candidate.recording {
                        Text("\(Double(audio.durationMilliseconds) / 1000, specifier: "%.1f") seconds · Take \(candidate.id.uuidString.prefix(4))")
                        Button(recording.isPlaying ? "Stop replay" : "Replay take") { recording.replayAcceptedOrCandidate() }
                            .buttonStyle(.bordered).accessibilityIdentifier("recording.replay")
                        Button("Use this take") { recording.accept() }.buttonStyle(.bordered)
                            .accessibilityIdentifier("recording.accept")
                    }
                    Button("Discard this take", role: .destructive) { showDiscard = true }
                    if let accepted = recording.accepted {
                        Text("Selected take: \(accepted.id.uuidString.prefix(4)). A new recording will not replace it until you choose Use this take.")
                        Text(isIndependentTurn ? "Self-review: Did you communicate your intended message? What would you change next time?" : "Self-review: Did you communicate all three facts? What would you change next time?")
                        if let purpose = recording.activeProvenance?.purpose,
                           ["baseline", "repeatedBaseline", "transfer", "delayedRecall"].contains(purpose) {
                        } else {
                            if !isIndependentTurn {
                                OnlineReviewSection(online: online, background: storage.preferences.background)
                            } else {
                            }
                        }
                    }
                }
            }
            Button(recording.phase == .ready ? "Start recording" : "Record a new take") {
                online.cancel()
                recording.load(storage.repository, context: context)
                recording.start(countdownEnabled: storage.preferences.countdownEnabled)
            }.buttonStyle(.borderedProminent).foregroundStyle(Color("OnAccent")).controlSize(.large)
                .accessibilityIdentifier("recording.start")
        case .requestingPermission:
            ProgressView("Waiting for microphone permission")
        case .preparing:
            ProgressView("Preparing your microphone")
            Button("Cancel") { recording.stop(interrupted: false) }
        case .countdown:
            Text("Starting in \(recording.countdown)").font(.largeTitle).accessibilityAddTraits(.updatesFrequently)
            Button("Cancel countdown") { recording.stop(interrupted: false) }
        case .recording, .paused:
            Text(recording.phase == .paused ? "Paused" : "Recording").font(.title2.bold())
            Text(Duration.seconds(recording.elapsed).formatted(.time(pattern: .minuteSecond))).font(.largeTitle.monospacedDigit())
                .accessibilityLabel("Elapsed recording time")
                .accessibilityValue(String(Int(recording.elapsed)))
                .accessibilityIdentifier("recording.elapsed")
            ProgressView(value: Double(recording.level)).accessibilityLabel("Microphone level")
            Button(recording.phase == .paused ? "Resume recording" : "Pause recording") { recording.pauseOrResume() }.buttonStyle(.bordered)
            Button("Stop recording") { recording.stop(interrupted: false) }.buttonStyle(.borderedProminent)
                .foregroundStyle(Color("OnAccent")).accessibilityIdentifier("recording.stop")
        case .finished: EmptyView()
        }
    }
}
