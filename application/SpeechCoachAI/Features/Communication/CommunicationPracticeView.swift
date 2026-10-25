import SwiftUI

/// Offline communication and articulation practice. Online sound feedback stays off.
struct CommunicationPracticeView: View {
    var storage: LearnerStorageController?
    @State private var recordingContext: PracticeSessionContext?
    @Binding var session: CommunicationPractice
    var publishedItems: [CommunicationItem]
    var onRecord: ((UUID) -> Void)?
    @Binding var recording: PracticeRecordingAttachment?

    @State private var focus: CommunicationFocus
    @State private var purpose: String
    @State private var framework: String
    @State private var scaffold: String
    @State private var sourceExchange: String
    @State private var answer: String
    @State private var purposeClear = false
    @State private var organization = ""
    @State private var wordUse = ""
    @State private var delivery = ""
    @State private var eyeContact = ""
    @State private var routine: Set<RoutineItem> = []
    @State private var notice: String?

    init(
        storage: LearnerStorageController? = nil,
        session: Binding<CommunicationPractice>,
        publishedItems: [CommunicationItem] = [],
        onRecord: ((UUID) -> Void)? = nil,
        recording: Binding<PracticeRecordingAttachment?>
    ) {
        self.storage = storage
        _session = session
        self.publishedItems = publishedItems
        self.onRecord = onRecord
        _recording = recording
        let task = session.wrappedValue.draftTask
        _focus = State(initialValue: task.focus)
        _purpose = State(initialValue: task.purpose)
        _framework = State(initialValue: task.frameworkID ?? "")
        _scaffold = State(initialValue: task.scaffold ?? "")
        _sourceExchange = State(initialValue: task.sourceExchange ?? "")
        _answer = State(initialValue: "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let storage {
                    SpeakingPracticePersistence(storage: storage, archive: archive, restore: restore, freshArchive: freshArchive)
                }
                if let source = session.draftTask.source {
                    Text("Linked lesson: \(CurriculumCatalogLoader.bundled.lesson(id: source.lessonID, version: source.contentVersion)?.title ?? source.lessonID) · version \(source.contentVersion)")
                        .font(.footnote).foregroundStyle(Kit.secondary)
                        .accessibilityIdentifier("communication.lesson.source")
                }
                if let notice {
                    AvailabilityCard(title: "Check this step", detail: notice, symbol: "exclamationmark.circle")
                        .accessibilityIdentifier("communication.notice")
                }
                switch session.phase {
                case .preparing: setup
                case .practicing: practice
                case .stopped, .ended: review
                }
            }
            .padding(20)
            .frame(maxWidth: 720, alignment: .leading)
        }
        .fullScreenCover(item: $recordingContext) { context in
            if let storage { RecordingView(storage: storage, context: context) }
        }
        .onChange(of: storage?.latestPracticeRecording) { _, result in
            guard let result, result.sessionID == session.id else { return }
            show(session.receiveRecording(turnID: result.slotID, reference: result.attemptID.uuidString))
            storage?.latestPracticeRecording = nil
        }
        .background(Kit.canvas(storage?.preferences.background ?? .creativeAcademy))
        .foregroundStyle(Kit.ink)
        .navigationTitle("Communication practice")
        .onChange(of: recording) { _, value in
            guard let value else { return }
            show(session.receiveRecording(turnID: value.turnID, reference: value.reference))
            recording = nil
        }
    }

    private var setup: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Practice one communication skill. A framework name is optional, and this does not finish a lesson.")
                .foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
            Picker("Skill", selection: $focus) {
                ForEach(CommunicationFocus.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.menu).accessibilityIdentifier("communication.focus")
            labeledField("Purpose", text: $purpose, identifier: "communication.purpose")
            labeledField("Framework name, optional", text: $framework, identifier: "communication.framework")
            labeledField("Scaffold, optional", text: $scaffold, identifier: "communication.scaffold")
            Toggle("This is a fictional situation", isOn: $session.draftTask.fictional)
            Toggle("Quiet practice", isOn: $session.quietPractice)
                .accessibilityHint("Keeps this practice on the device. Online feedback stays off either way.")
            if focus == .listenAndRespond {
                labeledField("Source you heard or read", text: $sourceExchange, identifier: "communication.source")
            }
            Button("Start practice", action: start)
                .buttonStyle(KitPrimaryButtonStyle())
                .accessibilityIdentifier("communication.start")
        }
    }

    private var practice: some View {
        VStack(alignment: .leading, spacing: 16) {
            KitCard {
                Text(focus.title).font(.headline)
                Text(focus.offlinePrompt).fixedSize(horizontal: false, vertical: true)
                Text("Personal practice prompt. Published teaching and assessment material is not available yet.")
                    .font(.footnote).foregroundStyle(Kit.secondary)
            }
            Text(session.activeAttempt?.task.purpose ?? "").fixedSize(horizontal: false, vertical: true)
            DisclosureGroup("Change task or support") {
                Picker("Skill", selection: $focus) {
                    ForEach(CommunicationFocus.allCases) { Text($0.title).tag($0) }
                }.pickerStyle(.menu)
                labeledField("Purpose", text: $purpose, identifier: "communication.task.purpose")
                labeledField("Framework name, optional", text: $framework, identifier: "communication.task.framework")
                labeledField("Scaffold, optional", text: $scaffold, identifier: "communication.task.scaffold")
                Text("Apply changes to start a separate attempt once work or recording has begun.").font(.footnote)
            }
            referenceCard
            if focus == .listenAndRespond {
                labeledField("Source you heard or read", text: $sourceExchange, identifier: "communication.source")
            }
            if let response = session.activeAttempt?.currentResponse {
                KitCard {
                    Text(response.retryOf == nil ? "First response" : "Latest retry").font(.headline)
                    if let text = response.text { Text(text).accessibilityIdentifier("communication.saved.answer") }
                    Text(response.modality == .recorded ? "Recording participation" : "Written participation")
                        .font(.footnote).foregroundStyle(Kit.secondary)
                }
            }
            labeledField("Your response", text: $answer, identifier: "communication.answer")
            recordControl
            Button("Save response", action: saveResponse)
                .buttonStyle(KitPrimaryButtonStyle())
                .disabled(session.retention.applied)
                .accessibilityIdentifier("communication.save")
            if session.activeAttempt?.currentResponse != nil {
                Button("Retry this response", action: retry)
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("communication.retry")
            }
            Button("Use this task", action: applyTask)
                .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                .accessibilityIdentifier("communication.task")
            selfReviewFields
            routineFields
            DeliveryFeedbackView(feedback: session.activeAttempt?.feedback, review: session.activeAttempt?.review ?? CommunicationSelfReview())
            Button("Stop", action: { show(session.stop(now: .now)) })
                .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                .accessibilityIdentifier("communication.stop")
        }
    }

    private var review: some View {
        VStack(alignment: .leading, spacing: 16) {
            DeliveryFeedbackView(feedback: session.activeAttempt?.feedback, review: session.activeAttempt?.review ?? CommunicationSelfReview())
            CommunicationRetentionForm(retention: session.retention, apply: retain)
            if session.phase == .stopped {
                Button("Continue this practice", action: { show(session.restart()) })
                    .buttonStyle(KitPrimaryButtonStyle())
                    .disabled(session.retention.applied)
                    .accessibilityIdentifier("communication.continue")
                Button("End", action: { show(session.end()) })
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("communication.end")
            }
        }
    }

    private var referenceCard: some View {
        Group {
            if let reference = session.activeAttempt?.task.referenceAudioID {
                AvailabilityCard(
                    title: "Reference linked",
                    detail: "Reference \(reference) is linked. Playback has not been connected for this reference. This screen does not score it.",
                    symbol: "waveform")
            } else {
                AvailabilityCard(
                    title: "No reference audio",
                    detail: "You can still write, record, and self-review. No audio is synthesized.",
                    symbol: "speaker.slash")
            }
        }
    }

    @ViewBuilder private var recordControl: some View {
        if onRecord == nil && storage == nil {
            AvailabilityCard(
                title: "Recording is not connected",
                detail: "Written practice still works. Nothing is uploaded.",
                symbol: "mic.slash")
        } else {
            Button("Record", action: record)
                .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                .disabled(session.retention.applied)
                .accessibilityIdentifier("communication.record")
            if session.activeRecordingSlot?.reference != nil {
                Text("Completed take attached to this response.").font(.footnote)
                    .accessibilityIdentifier("communication.recording.attached")
            }
        }
    }

    private var selfReviewFields: some View {
        KitCard {
            Text("Self-review").font(.headline)
            Text("Delivery and eye contact are your notes. They are not scores.")
                .font(.footnote).foregroundStyle(Kit.secondary)
            Toggle("The purpose was clear", isOn: $purposeClear)
                .disabled(session.retention.applied)
            labeledField("Organization", text: $organization, identifier: "communication.organization")
            labeledField("Word use", text: $wordUse, identifier: "communication.words")
            labeledField("Delivery note, optional", text: $delivery, identifier: "communication.delivery")
            labeledField("Eye contact note, optional", text: $eyeContact, identifier: "communication.eyes")
            Button("Save self-review", action: saveReview)
                .buttonStyle(KitPrimaryButtonStyle())
                .disabled(session.retention.applied)
                .accessibilityIdentifier("communication.review")
        }
    }

    private var routineFields: some View {
        KitCard {
            Text("Optional practice").font(.headline)
            Text("Choose any items you want. This does not finish a lesson or award mastery.")
                .font(.footnote).foregroundStyle(Kit.secondary)
            ForEach(RoutineItem.allCases) { item in
                Toggle(item.title, isOn: Binding(
                    get: { routine.contains(item) },
                    set: { selected in
                        if selected { routine.insert(item) } else { routine.remove(item) }
                    }))
                .disabled(session.retention.applied)
            }
            Button("Record selected practice", action: saveRoutine)
                .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                .disabled(routine.isEmpty || session.retention.applied)
        }
    }

    private func labeledField(_ title: String, text: Binding<String>, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline.weight(.semibold))
            TextField(title, text: text, axis: .vertical)
                .lineLimit(2...6)
                .textFieldStyle(.roundedBorder)
                .disabled(session.retention.applied)
                .accessibilityIdentifier(identifier)
                .dictation(text)
        }
    }

    private func start() {
        commitDraft()
        show(session.begin(published: publishedItems, now: .now))
    }

    private func applyTask() {
        let before = session.activeAttemptID
        let savedAnswer = answer
        let savedReview = (organization, wordUse, delivery, eyeContact, purposeClear)
        let action = session.reviseTask(proposedTask(), published: publishedItems, now: .now)
        if action.accepted, session.activeAttemptID != before {
            clearResponseDrafts()
        } else if !action.accepted {
            answer = savedAnswer
            organization = savedReview.0
            wordUse = savedReview.1
            delivery = savedReview.2
            eyeContact = savedReview.3
            purposeClear = savedReview.4
            restoreTaskFields()
        }
        show(action)
    }

    private func saveResponse() {
        guard taskMatches else { notice = "Apply task changes before saving a response."; return }
        show(session.submit(questionID: Self.questionID, text: answer, now: .now))
    }

    private func retry() {
        guard taskMatches else { notice = "Apply task changes before saving a retry."; return }
        guard let previous = session.activeAttempt?.currentResponse?.id else { return }
        show(session.retry(previousID: previous, questionID: Self.questionID, text: answer, now: .now))
    }

    private func record() {
        guard taskMatches else { notice = "Apply task changes before recording."; return }
        let action = session.openRecordingSlot(questionID: Self.questionID)
        guard action.accepted, let slot = session.activeRecordingSlot?.id else { show(action); return }
        if let storage, let task = session.activeAttempt?.task {
            recordingContext = communicationRecordingContext(slotID: slot, sessionID: session.id,
                task: task, defaults: storage.preferences)
        } else { onRecord?(slot) }
    }

    private func saveReview() {
        show(session.saveSelfReview(
            purposeClear: purposeClear, organization: organization, wordUse: wordUse,
            delivery: delivery, eyeContact: eyeContact, now: .now))
    }

    private func saveRoutine() {
        show(session.completeRoutine(routine, now: .now))
    }

    private func retain(audio: Bool, text: Bool) {
        if !audio, let repository = storage?.repository {
            do {
                try repository.discardSpeakingPracticeAudio(session.audioReferences, sessionID: session.id,
                    expectedEpoch: repository.learningDataEpoch())
            } catch { notice = "The recording could not be removed. Keep this screen open and try again."; return }
        }
        if !text, let repository = storage?.repository {
            do {
                try repository.clearSpeakingPracticePrivatePrompts(sessionID: session.id, expectedEpoch: repository.learningDataEpoch())
            } catch { notice = "The private task text could not be removed. Keep this screen open and try again."; return }
        }
        let action = session.applyRetention(keepAudio: audio, keepText: text)
        guard action.accepted else { show(action); return }
        if !text { clearTextDrafts() }
        if !audio { recording = nil }
        show(action)
    }

    private func proposedTask() -> CommunicationTask {
        var task = session.activeAttempt?.task ?? session.draftTask
        task.focus = focus
        task.purpose = purpose
        task.frameworkID = framework
        task.scaffold = scaffold
        task.sourceExchange = sourceExchange
        return task
    }

    private func commitDraft() {
        session.draftTask = proposedTask()
    }

    private func restoreTaskFields() {
        let task = session.activeAttempt?.task ?? session.draftTask
        focus = task.focus
        purpose = task.purpose
        framework = task.frameworkID ?? ""
        scaffold = task.scaffold ?? ""
        sourceExchange = task.sourceExchange ?? ""
    }

    private func clearResponseDrafts() {
        answer = ""
        organization = ""
        wordUse = ""
        delivery = ""
        eyeContact = ""
        purposeClear = false
    }

    private func clearTextDrafts() {
        clearResponseDrafts()
        purpose = ""
        framework = ""
        scaffold = ""
        sourceExchange = ""
    }

    private func show(_ action: CommunicationAction) {
        switch action {
        case .accepted(let notice): self.notice = notice
        case .refused(let reason): self.notice = reason.notice
        }
    }

    private var taskMatches: Bool {
        proposedTask().normalized().fingerprint == session.activeAttempt?.task.fingerprint
    }
    private var archive: SpeakingPracticeArchive {
        let drafts: [String: String] = session.retention.applied ? [:] : [
            "focus": focus.rawValue, "purpose": purpose, "framework": framework, "scaffold": scaffold,
            "sourceExchange": sourceExchange, "answer": answer, "organization": organization, "wordUse": wordUse,
            "delivery": delivery, "eyeContact": eyeContact, "purposeClear": String(purposeClear),
            "routine": RoutineItem.allCases.filter { routine.contains($0) }.map(\.rawValue).joined(separator: ",")]
        return SpeakingPracticeArchive(kind: session.archiveKind, drafts: drafts, expiresAt: nil,
            communication: session, updatedAt: .now)
    }
    private func freshArchive() -> SpeakingPracticeArchive {
        let fresh = CommunicationPractice.blank(entry: session.entry, source: session.draftTask.source)
        return SpeakingPracticeArchive(kind: fresh.archiveKind, drafts: [:], expiresAt: nil, communication: fresh, updatedAt: .now)
    }
    private func restore(_ saved: SpeakingPracticeArchive) {
        guard var restored = saved.communication, restored.archiveKind == session.archiveKind else { return }
        _ = restored.setEntry(session.entry)
        session = restored; recording = nil
        restoreTaskFields()
        focus = CommunicationFocus(rawValue: saved.drafts["focus"] ?? "") ?? focus
        purpose = saved.drafts["purpose"] ?? purpose
        framework = saved.drafts["framework"] ?? framework
        scaffold = saved.drafts["scaffold"] ?? scaffold
        sourceExchange = saved.drafts["sourceExchange"] ?? sourceExchange
        answer = saved.drafts["answer"] ?? ""
        let review = restored.activeAttempt?.review ?? CommunicationSelfReview()
        organization = saved.drafts["organization"] ?? review.organizationNote
        wordUse = saved.drafts["wordUse"] ?? review.wordUseNote
        delivery = saved.drafts["delivery"] ?? review.deliveryNote
        eyeContact = saved.drafts["eyeContact"] ?? review.eyeContactNote
        purposeClear = saved.drafts["purposeClear"].map { $0 == "true" } ?? (review.purposeClear == true)
        routine = Set((saved.drafts["routine"] ?? "").split(separator: ",").compactMap { RoutineItem(rawValue: String($0)) })
        notice = nil
    }

    private static let questionID = "response"
}

private struct CommunicationRetentionForm: View {
    var retention: CommunicationRetention
    var apply: (Bool, Bool) -> Void
    @State private var keepAudio: Bool?
    @State private var keepText: Bool?

    var body: some View {
        KitCard {
            Text("Choose what to keep").font(.headline)
            choice("Keep this recording", selection: $keepAudio)
            choice("Keep the text", selection: $keepText)
            Button("Save selected") {
                if let keepAudio, let keepText { apply(keepAudio, keepText) }
            }
            .buttonStyle(KitPrimaryButtonStyle())
            .disabled(keepAudio == nil || keepText == nil || retention.applied)
            Button("Don't save anything") {
                keepAudio = false
                keepText = false
                apply(false, false)
            }
            .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
            .disabled(retention.applied)
            .accessibilityIdentifier("communication.discard")
        }
    }

    private func choice(_ title: String, selection: Binding<Bool?>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline.weight(.semibold))
            HStack {
                Button(selection.wrappedValue == true ? "Keep selected" : "Keep") { selection.wrappedValue = true }
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                Button(selection.wrappedValue == false ? "Decline selected" : "Don't keep") { selection.wrappedValue = false }
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
            }
        }
    }
}

private extension CommunicationRefusal {
    var notice: String {
        switch self {
        case .invalidSetup: "Add a purpose. A framework name is optional."
        case .unavailableItem: "That practice item is not available."
        case .sessionClosed: "This practice is closed."
        case .emptyResponse: "Add a response or a recording before saving."
        case .duplicateResponse: "Save a retry instead of replacing the first response."
        case .unsupportedSound: "Sound cannot be assessed from this practice."
        case .missingSource: "Add the source before a listen-and-respond response."
        case .ungroundedEvidence, .invalidFeedback: "Your take is safe. Review it locally or choose to retry."
        case .onlineDisabled: "Online feedback is off."
        case .capabilityUnavailable: "Precise sound feedback is not available."
        case .quietPractice: "Quiet practice keeps this on the device."
        case .requestInFlight: "Wait for the current request to finish."
        case .lateResult: "That result did not match this response."
        case .unknownOutcome: "Check the provider before trying again."
        case .retentionIncomplete: "Stop the practice before choosing what to keep."
        }
    }
}

private extension RoutineItem {
    var title: String {
        switch self {
        case .organizedAnswer: "Organized answer"
        case .simpleExplanation: "Simple explanation"
        case .conciseSummary: "Concise summary"
        case .paraphrase: "Paraphrase"
        case .pausePractice: "Pause practice"
        case .constructiveDisagreement: "Constructive disagreement"
        }
    }
}


struct CommunicationPracticeHost: View {
    var storage: LearnerStorageController
    @State private var session: CommunicationPractice
    @State private var recording: PracticeRecordingAttachment?
    init(storage: LearnerStorageController, entry: CommunicationEntry, source: CommunicationSource? = nil) {
        self.storage = storage
        _session = State(initialValue: CommunicationPractice.blank(entry: entry, source: source))
    }
    var body: some View {
        CommunicationPracticeView(storage: storage, session: $session, recording: $recording)
    }
}

struct CommunicationPracticeLauncher: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall = CurriculumCatalogLoader.bundled
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                NavigationLink {
                    CommunicationPracticeHost(storage: storage, entry: .speechLab)
                } label: {
                    KitContentRow(symbol: "text.bubble", title: "Your own task", detail: "Local practice without a lesson link.", showsChevron: true)
                }.accessibilityIdentifier("communication.open.standalone")
                Text("Practice linked to a lesson").font(.headline)
                Text("Opening the same lesson version from Learn or Speech Lab resumes the same saved communication practice. Course progress stays separate.")
                    .foregroundStyle(Kit.secondary)
                ForEach(Array((install.lessons + install.archivedLessons).filter(\.isReady).enumerated()), id: \.offset) { _, lesson in
                    NavigationLink {
                        CommunicationPracticeHost(storage: storage, entry: .speechLab,
                            source: CommunicationSource(lessonID: lesson.id, contentVersion: lesson.contentVersion,
                                objectiveID: lesson.objectiveId, senseID: nil))
                    } label: {
                        KitContentRow(symbol: "book", title: lesson.title, detail: "\(lesson.level) · version \(lesson.contentVersion)", showsChevron: true)
                    }.accessibilityIdentifier("communication.open.\(lesson.id).\(lesson.contentVersion)")
                }
            }.padding(20).frame(maxWidth: 720)
        }
        .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
        .navigationTitle("Communication practice")
    }
}


func communicationRecordingContext(slotID: UUID, sessionID: UUID, task: CommunicationTask,
                                   defaults: LearnerPreferences) -> PracticeSessionContext {
    var context = practiceRecordingContext(slotID: slotID, sessionID: sessionID,
        prompt: task.purpose + "\n" + task.focus.offlinePrompt,
        objective: task.source?.objectiveID ?? "COMMUNICATION-LOCAL",
        presenter: defaults.coach.rawValue, purpose: "communicationTurn", defaults: defaults)
    context.promptOverride?.selectedLevel = task.source.flatMap {
        CurriculumCatalogLoader.bundled.lesson(id: $0.lessonID, version: $0.contentVersion)?.level
    } ?? "Unassessed"
    context.provenance?.communicationSource = task.source
    context.provenance?.sourceCourseLessonID = task.source?.lessonID ?? "communication-standalone"
    context.provenance?.packID = task.itemID ?? task.focus.rawValue
    context.provenance?.packVersion = task.itemVersion ?? CommunicationFocus.offlinePromptVersion
    context.provenance?.supported = task.frameworkID != nil || task.scaffold != nil
    return context
}
