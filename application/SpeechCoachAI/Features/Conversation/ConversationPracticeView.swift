import SwiftUI

/// Text or recorded-turn conversation. Live voice stays unavailable, and partner replies are not requested from this screen.
struct ConversationPracticeView: View {
    var storage: LearnerStorageController? = nil
    @State private var recordingContext: PracticeSessionContext?
    @Environment(\.dynamicTypeSize) private var textSize
    @State private var session: ConversationSession
    @State private var draft = ""
    @State private var notice: String?
    @Binding private var recordingAttachment: PracticeRecordingAttachment?
    private let reviewedScenarios: [WorkplaceScenarioReference]
    private let onRecordTurn: ((UUID) -> Void)?

    init(
        storage: LearnerStorageController? = nil,
        presenterID: String,
        reviewedScenarios: [WorkplaceScenarioReference] = [],
        onRecordTurn: ((UUID) -> Void)? = nil,
        recordingAttachment: Binding<PracticeRecordingAttachment?> = .constant(nil)
    ) {
        self.storage = storage
        _session = State(initialValue: ConversationSession(presenterID: presenterID))
        self.reviewedScenarios = ScenarioAvailability.published(reviewedScenarios)
        self.onRecordTurn = onRecordTurn
        _recordingAttachment = recordingAttachment
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: textSize.isAccessibilitySize ? 20 : 16) {
                header
                if let storage {
                    SpeakingPracticePersistence(storage: storage, archive: archive, restore: restore)
                }
                AvailabilityCard(title: TurnModality.realtimeTitle, detail: TurnModality.realtimeDetail, symbol: "waveform.slash")
                if session.phase == .preparing { setup } else { practice }
                if let notice {
                    AvailabilityCard(title: "Check this step", detail: notice, symbol: "exclamationmark.triangle")
                        .accessibilityIdentifier("conversation.notice")
                }
            }
            .padding(20)
        }
        .fullScreenCover(item: $recordingContext) { context in
            if let storage { RecordingView(storage: storage, context: context) }
        }
        .onChange(of: storage?.latestPracticeRecording) { _, result in
            guard let result, result.sessionID == session.id else { return }
            apply(session.attachRecording(turnID: result.slotID, reference: result.attemptID.uuidString))
            storage?.latestPracticeRecording = nil
        }
        .background(Kit.canvas(storage?.preferences.background ?? .creativeAcademy))
        .foregroundStyle(Kit.ink)
        .navigationTitle("Conversation")
        .onChange(of: recordingAttachment) { _, attachment in
            guard let attachment else { return }
            apply(session.attachRecording(turnID: attachment.turnID, reference: attachment.reference))
            recordingAttachment = nil
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Talk it through").font(.title2.bold())
        }
    }

    @ViewBuilder private var setup: some View {
        KitCard {
            Text("Before you start").font(.headline)
            Text("Say what you want to practice. This does not change your course.").foregroundStyle(Kit.secondary)
            Picker("Conversation", selection: kindBinding) {
                ForEach(ConversationKind.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.menu).frame(minHeight: 44).accessibilityIdentifier("conversation.kind")
            Picker("Turn", selection: modalityBinding) {
                ForEach(TurnModality.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.menu).frame(minHeight: 44).accessibilityIdentifier("conversation.modality")
            Toggle("Quiet practice", isOn: quietBinding)
                .frame(minHeight: 44).accessibilityIdentifier("conversation.quiet")
            labeledField("What do you want to talk about?", text: situationBinding, identifier: "conversation.situation")
            labeledField("Support you want", text: supportBinding, identifier: "conversation.support")
            labeledField("Feedback focus", text: focusBinding, identifier: "conversation.focus")
            if session.setup.kind == .everydayScenario {
                if reviewedScenarios.isEmpty {
                    AvailabilityCard(
                        title: "Reviewed scenarios are not published",
                        detail: "Everyday scenarios stay hidden until a qualified review publishes them. Free discussion is still available.",
                        symbol: "text.book.closed")
                } else {
                    Picker("Scenario", selection: scenarioBinding) {
                        Text("Choose a scenario").tag(nil as String?)
                        ForEach(reviewedScenarios) { Text($0.purpose).tag(Optional($0.id)) }
                    }
                    .pickerStyle(.menu).frame(minHeight: 44).accessibilityIdentifier("conversation.scenario")
                }
            }
            Button("Start conversation", action: start).buttonStyle(KitPrimaryButtonStyle())
                .accessibilityIdentifier("conversation.start")
        }
    }

    @ViewBuilder private var practice: some View {
        KitCard {
            Text("Turns").font(.headline)
            Text(session.setup.kind == .freeDiscussion ? session.setup.situation : "Everyday scenario")
                .foregroundStyle(Kit.secondary)
            if session.turns.isEmpty {
                AvailabilityCard(title: "Your practice starts here", detail: "Send a turn in your own words. A partner reply appears only after an explicit online request.", symbol: "bubble.left")
            }
            ForEach(session.turns) { turn in
                VStack(alignment: .leading, spacing: 4) {
                    Text(turn.speaker == .learner ? "You" : "Partner reply").font(.headline)
                    Text(turnLabel(turn)).fixedSize(horizontal: false, vertical: true)
                    Text(turn.modality == .recordedTurn ? "Recorded turn" : "Text turn")
                        .font(.footnote).foregroundStyle(Kit.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .accessibilityIdentifier("conversation.turn.\(turn.id.uuidString)")
            }
        }
        .accessibilityIdentifier("conversation.history")
        if session.phase == .practicing { composer }
        if session.phase == .stopped {
            Button("Continue practice") { apply(session.restart()) }
                .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                .accessibilityIdentifier("conversation.restart")
            Button("End practice") { apply(session.end(now: .now)) }
                .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                .accessibilityIdentifier("conversation.end.stopped")
        }
        PracticeSelfReviewForm(review: session.selfReview, identifierPrefix: "conversation") { purpose, facts, step in
            apply(session.saveSelfReview(purposeClear: purpose, factsNamed: facts, nextStep: step, now: .now))
        }
        .disabled(session.retention.applied)
        .id(session.retention.applied)
        if session.phase == .stopped || session.phase == .ended {
            PracticeRetentionForm(retention: session.retention, identifierPrefix: "conversation") { audio, text in
                guard discardAudioIfNeeded(keepAudio: audio) else { return }
                let action = session.applyRetention(keepAudio: audio, keepText: text)
                apply(action)
                if action.accepted { draft = ""; recordingAttachment = nil }
            }
        }
        if session.qualifiesAsConversation {
            Text("This practice has a visible back-and-forth. It does not change your course or award an English level.")
                .font(.footnote).foregroundStyle(Kit.secondary).accessibilityIdentifier("conversation.qualified")
        }
    }

    private var composer: some View {
        KitCard {
            Text("Your turn").font(.headline)
            Text("Nothing is uploaded from this step.").foregroundStyle(Kit.secondary)
            labeledField("Write this turn", text: $draft, identifier: "conversation.draft")
            Button("Send this turn", action: send).buttonStyle(KitPrimaryButtonStyle())
                .accessibilityIdentifier("conversation.send")
            if let latest = session.turns.last(where: { $0.speaker == .learner && $0.disposition == .submitted }) {
                Button("Try this turn again") {
                    apply(session.retryLearnerTurn(previousID: latest.id, now: .now))
                }
                .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                .accessibilityIdentifier("conversation.retry")
            }
            if session.setup.modality == .recordedTurn {
                if storage != nil || onRecordTurn != nil {
                    Button("Record this turn") {
                        _ = session.openLearnerTurn(now: .now)
                        if let id = session.currentLearnerTurnID {
                            if let storage {
                                recordingContext = practiceRecordingContext(slotID: id, sessionID: session.id,
                                    prompt: session.setup.situation, objective: "CONVERSATION-LOCAL", presenter: session.setup.presenterID,
                                    purpose: "conversationTurn", defaults: storage.preferences)
                            } else { onRecordTurn?(id) }
                        }
                    }
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("conversation.record")
                } else {
                    AvailabilityCard(
                        title: "The recorder is not connected",
                        detail: "Use the existing Speech Lab recording practice for audio. This screen can still keep a written turn. Nothing is uploaded.",
                        symbol: "mic.slash")
                }
            }
            Button("Ask for a partner reply") {}
                .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                .disabled(true)
                .accessibilityIdentifier("conversation.partner")
                .accessibilityHint("Online turns stay off until a turn contract is approved. Nothing is sent.")
            HStack(spacing: 12) {
                Button("Stop") { apply(session.stop(now: .now)) }
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("conversation.stop")
                Button("End practice") { apply(session.end(now: .now)) }
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("conversation.end")
            }
        }
    }

    private var archive: SpeakingPracticeArchive {
        SpeakingPracticeArchive(kind: "conversation", conversation: session, drafts: session.retention.applied ? [:] : ["draft": draft], expiresAt: nil, updatedAt: session.startedAt)
    }
    private func restore(_ saved: SpeakingPracticeArchive) {
        guard let value = saved.conversation else { return }
        session = value; draft = saved.drafts["draft"] ?? ""
    }
    private func discardAudioIfNeeded(keepAudio: Bool) -> Bool {
        guard !keepAudio, let repository = storage?.repository else { return true }
        do {
            let epoch = try repository.learningDataEpoch()
            try repository.discardSpeakingPracticeAudio(archive.audioReferences, sessionID: session.id, expectedEpoch: epoch)
            return true
        } catch { notice = "The recording could not be removed. Keep this screen open and try again."; return false }
    }

    private func start() {
        apply(session.begin(publishedScenarios: reviewedScenarios, now: .now))
    }

    private var kindBinding: Binding<ConversationKind> {
        Binding(get: { session.setup.kind }, set: { session.setup.kind = $0 })
    }
    private var modalityBinding: Binding<TurnModality> {
        Binding(get: { session.setup.modality }, set: { session.setup.modality = $0 })
    }
    private var quietBinding: Binding<Bool> {
        Binding(get: { session.setup.quietPractice }, set: { session.setup.quietPractice = $0 })
    }
    private var situationBinding: Binding<String> {
        Binding(get: { session.setup.situation }, set: { session.setup.situation = $0 })
    }
    private var supportBinding: Binding<String> {
        Binding(get: { session.setup.supportNote }, set: { session.setup.supportNote = $0 })
    }
    private var focusBinding: Binding<String> {
        Binding(get: { session.setup.feedbackFocus }, set: { session.setup.feedbackFocus = $0 })
    }
    private var scenarioBinding: Binding<String?> {
        Binding(get: { session.setup.scenarioID }, set: { session.setup.scenarioID = $0 })
    }

    private func send() {
        _ = session.openLearnerTurn(now: .now)
        guard let id = session.currentLearnerTurnID else { return }
        apply(session.submitLearnerTurn(id: id, text: draft, now: .now))
        if notice == nil { draft = "" }
    }

    private func apply(_ action: ConversationAction) {
        notice = action.refusal.map(conversationNotice)
    }

    private func turnLabel(_ turn: ConversationTurn) -> String {
        if let text = turn.text, !text.isEmpty { return text }
        if turn.recordingReference != nil { return "A recording is attached. Its words are not stored as text." }
        return "Text not kept."
    }

    private func labeledField(_ title: String, text: Binding<String>, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline.weight(.semibold))
            TextField(title, text: text, axis: .vertical)
                .lineLimit(1...6)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier(identifier)
                .dictation(text)
        }
    }
}

struct PracticeSelfReviewForm: View {
    var review: PracticeSelfReview
    var identifierPrefix: String
    var save: (Bool, String, String) -> Void
    @State private var purpose = false
    @State private var facts = ""
    @State private var nextStep = ""

    var body: some View {
        KitCard {
            Text("Self-review").font(.headline)
            Toggle("A listener could tell the purpose", isOn: $purpose)
                .frame(minHeight: 44).accessibilityIdentifier("\(identifierPrefix).purpose")
            TextField("Facts you chose to share", text: $facts, axis: .vertical)
                .lineLimit(1...4).textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("\(identifierPrefix).facts")
                .dictation($facts)
            TextField("Next step", text: $nextStep, axis: .vertical)
                .lineLimit(1...4).textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("\(identifierPrefix).next")
                .dictation($nextStep)
            Button("Save self-review") { save(purpose, facts, nextStep) }
                .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                .accessibilityIdentifier("\(identifierPrefix).review")
            if review.isComplete {
                Text("Self-review saved on this screen. It does not assess pronunciation or award course credit.")
                    .font(.footnote).foregroundStyle(Kit.secondary)
                    .accessibilityIdentifier("\(identifierPrefix).review.saved")
            }
        }
    }
}

struct PracticeRetentionForm: View {
    var retention: RetentionSelection
    var identifierPrefix: String
    var apply: (Bool, Bool) -> Void
    @State private var keepAudio: Bool?
    @State private var keepText: Bool?

    var body: some View {
        KitCard {
            Text("Choose what to keep").font(.headline)
            choice("Keep this recording", selection: $keepAudio, identifier: "\(identifierPrefix).audio")
            choice("Keep the text", selection: $keepText, identifier: "\(identifierPrefix).text")
            Button("Save selected") {
                if let keepAudio, let keepText { apply(keepAudio, keepText) }
            }
            .buttonStyle(KitPrimaryButtonStyle())
            .disabled(keepAudio == nil || keepText == nil)
            .accessibilityIdentifier("\(identifierPrefix).save")
            Button("Don't save anything") {
                keepAudio = false
                keepText = false
                apply(false, false)
            }
            .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
            .accessibilityIdentifier("\(identifierPrefix).discard")
            if retention.applied {
            }
        }
    }

    private func choice(_ title: String, selection: Binding<Bool?>, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline.weight(.semibold))
            HStack {
                Button(selection.wrappedValue == true ? "Keep selected" : "Keep") { selection.wrappedValue = true }
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("\(identifier).keep")
                Button(selection.wrappedValue == false ? "Don't keep selected" : "Don't keep") { selection.wrappedValue = false }
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("\(identifier).discard")
            }
        }
    }
}

func conversationNotice(_ refusal: ConversationRefusal) -> String {
    switch refusal {
    case .invalidSetup: "Add the missing choice before starting. A reviewed scenario is required for everyday practice."
    case .emptyTurn: "Write the turn before sending it. A recording is not uploaded in its place."
    case .unknownTurn: "That turn is no longer available."
    case .notCurrentTurn: "Finish the open turn before starting another one."
    case .turnNotSubmitted: "Send the turn before asking for a reply."
    case .requestInFlight: "A reply is still unresolved. Stop it before trying again."
    case .onlineDisabled: "Online replies are not available. Your turn stays on this device."
    case .quietPractice: "Quiet practice stays on this device."
    case .missingConsent: "A partner reply needs an explicit consent for this turn."
    case .contractMismatch: "This turn does not match an approved conversation contract."
    case .duplicateRequest: "That request was already used. Start a new explicit request if you want another reply."
    case .lateResult: "A late reply was ignored. Your earlier turn is unchanged."
    case .invalidReply: "The reply was empty, so it was not added."
    case .sessionClosed: "This practice is closed. Start again if you want another one."
    case .realtimeUnavailable: TurnModality.realtimeDetail
    case .retentionIncomplete: "Stop or end practice before choosing what to keep."
    }
}

/// Explicit draft retention uses the existing protected learner document and delete-all epoch.
struct SpeakingPracticePersistence: View {
    var storage: LearnerStorageController
    var archive: SpeakingPracticeArchive
    var restore: (SpeakingPracticeArchive) -> Void
    var freshArchive: (() -> SpeakingPracticeArchive)? = nil
    @State private var epoch: UUID?
    @State private var expiresAt: Date?
    @State private var enabled = false
    @State private var loaded = false
    @State private var message: String?
    @Environment(\.scenePhase) private var scenePhase

    private var finalized: Bool { archive.conversation?.retention.applied == true || archive.interview?.retention.applied == true || archive.communication?.retention.applied == true }
    var body: some View {
        KitCard {
            Text("Local practice preview").font(.headline)
            Text("Without a saved draft, written work stays in memory until you leave. A saved draft expires 24 hours after you explicitly save or resume it.").font(.footnote)
            if !finalized {
                Button(enabled ? "Extend draft recovery for 24 hours" : "Keep draft for 24 hours") {
                    expiresAt = Date.now.addingTimeInterval(24 * 3600); enabled = true; save()
                }.buttonStyle(.bordered).disabled(!loaded).accessibilityIdentifier("practice.draft.keep")
            }
            if finalized {
                Button("Start a new practice") { startNew() }
                    .buttonStyle(.bordered).accessibilityIdentifier("practice.new")
            }
            if let message {
                Text(message).font(.footnote).accessibilityIdentifier("practice.storage.message")
                if !loaded {
                    Button("Retry opening") { load() }
                } else {
                    Button("Retry saving") { save() }.disabled(!enabled && !finalized)
                }
            }
        }
        .task { if !loaded { load() } }
        .onChange(of: archive) { _, _ in if loaded && (enabled || finalized) { save() } }
        .onChange(of: scenePhase) { _, phase in if loaded && phase != .active && (enabled || finalized) { save() } }
        .onDisappear { if loaded && (enabled || finalized) { save() } }
    }

    private func load() {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let currentEpoch = try repository.learningDataEpoch()
            epoch = currentEpoch
            if var saved = try repository.speakingPractice(archive.kind) {
                if saved.expiresAt != nil {
                    saved.expiresAt = Date.now.addingTimeInterval(24 * 3600)
                }
                try repository.saveSpeakingPractice(saved, expectedEpoch: currentEpoch)
                expiresAt = saved.expiresAt; enabled = true
                restore(saved)
                message = "Saved practice restored on this device."
            } else { message = nil }
            loaded = true
        } catch {
            loaded = false
            message = "Saved practice could not be opened. Unlock your device and retry."
        }
    }

    private func startNew() {
        do {
            guard let repository = storage.repository, let epoch else { throw LearnerStorageError.unavailable }
            try repository.removeSpeakingPractice(archive.kind, expectedEpoch: epoch)
            enabled = false; expiresAt = nil; message = nil
            let fresh = freshArchive?() ?? SpeakingPracticeArchive(kind: archive.kind,
                conversation: archive.kind == "conversation" ? ConversationSession(presenterID: storage.preferences.coach.rawValue) : nil,
                interview: archive.kind == "interview" ? InterviewSession(presenterID: storage.preferences.coach.rawValue) : nil,
                drafts: [:], expiresAt: nil, updatedAt: .now)
            restore(fresh)
        } catch { message = "A new practice could not be opened. Your saved practice is kept." }
    }

    private func save() {
        do {
            guard let repository = storage.repository, let epoch else { throw LearnerStorageError.unavailable }
            guard try repository.learningDataEpoch() == epoch else {
                enabled = false; message = "This practice belongs to deleted learning data. Leave and start a new practice."; return
            }
            var saved = archive; saved.updatedAt = .now
            saved.expiresAt = finalized ? nil : expiresAt
            try repository.saveSpeakingPractice(saved, expectedEpoch: epoch)
            message = finalized ? "Retention choices saved on this device." : "Draft saved on this device."
        } catch { message = "Practice could not be saved. Keep this screen open and retry after unlocking your device." }
    }
}

func practiceRecordingContext(slotID: UUID, sessionID: UUID, prompt: String, objective: String,
                              presenter: String, purpose: String, defaults: LearnerPreferences) -> PracticeSessionContext {
    var context = PracticeSessionContext(id: slotID, defaults: defaults, objectiveID: objective)
    context.coachOverride = LearnerPreferences.Coach(rawValue: presenter)
    context.promptOverride = PromptSnapshot(id: slotID.uuidString, version: "local-practice-1", objectiveID: objective,
        text: prompt, isPrivate: true, selectedLevel: "A1")
    context.provenance = SpeakingProvenance(journeyID: sessionID, activityID: slotID.uuidString,
        sourceCourseJourneyID: sessionID, sourceCourseLessonID: purpose,
        primaryObjectiveID: objective, specialtyObjectiveID: nil, role: presenter, method: "Independent local solo practice",
        packID: purpose, packVersion: "local-practice-1", purpose: purpose, supported: true)
    return context
}
