import SwiftUI

/// Interview practice with a grounded follow-up. Reviewed scenarios stay hidden, and online notes are not requested here.
struct InterviewPracticeView: View {
    var storage: LearnerStorageController? = nil
    @State private var recordingContext: PracticeSessionContext?
    @Environment(\.dynamicTypeSize) private var textSize
    @State private var session: InterviewSession
    @State private var role: String
    @State private var interviewType: InterviewType
    @State private var presenter: LearnerPreferences.Coach
    @State private var fictional = false
    @State private var technical = false
    @State private var preparation = ""
    @State private var fact = ""
    @State private var opening = ""
    @State private var followUpDraft = ""
    @State private var technicalNote = ""
    @State private var notice: String?
    @State private var recordingSlot: InterviewRecordingSlot?
    @Binding private var recordingAttachment: PracticeRecordingAttachment?
    private let onRecordTurn: ((UUID) -> Void)?

    init(
        storage: LearnerStorageController? = nil,
        presenterID: String = LearnerPreferences.Coach.tigerBusinessProfessional.rawValue,
        onRecordTurn: ((UUID) -> Void)? = nil,
        recordingAttachment: Binding<PracticeRecordingAttachment?> = .constant(nil)
    ) {
        let coach = LearnerPreferences.Coach(rawValue: presenterID) ?? .tigerBusinessProfessional
        self.storage = storage
        _session = State(initialValue: InterviewSession(presenterID: coach.rawValue))
        _role = State(initialValue: "")
        _interviewType = State(initialValue: .introduction)
        _presenter = State(initialValue: coach)
        _recordingSlot = State(initialValue: nil)
        self.onRecordTurn = onRecordTurn
        _recordingAttachment = recordingAttachment
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: textSize.isAccessibilitySize ? 20 : 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Practice an interview").font(.title2.bold())
                    Text("Suggested presenter: Tiger Business Professional. You can keep the presenter you already chose. This practice does not complete a course.")
                        .foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                }
                if let storage {
                    SpeakingPracticePersistence(storage: storage, archive: archive, restore: restore)
                }
                AvailabilityCard(title: TurnModality.realtimeTitle, detail: TurnModality.realtimeDetail, symbol: "waveform.slash")
                setup.disabled(session.retention.applied)
                preparationCard.disabled(session.retention.applied)
                if session.phase != .preparing { interviewLoop }
                if let notice {
                    AvailabilityCard(title: "Check this step", detail: notice, symbol: "exclamationmark.triangle")
                        .accessibilityIdentifier("interview.notice")
                }
            }
            .padding(20)
        }
        .fullScreenCover(item: $recordingContext) { context in
            if let storage { RecordingView(storage: storage, context: context) }
        }
        .onChange(of: storage?.latestPracticeRecording) { _, result in
            guard let result, result.sessionID == session.id else { return }
            let attachment = PracticeRecordingAttachment(turnID: result.slotID, reference: result.attemptID.uuidString)
            if var slot = recordingSlot, slot.receive(attachment, activeAttemptID: session.activeAttemptID),
               session.phase == .practicing, !session.retention.applied { recordingSlot = slot }
            storage?.latestPracticeRecording = nil
        }
        .background(Kit.canvas(storage?.preferences.background ?? .creativeAcademy))
        .foregroundStyle(Kit.ink)
        .navigationTitle("Interview")
        .onChange(of: recordingAttachment) { _, attachment in
            guard let attachment else { return }
            if var slot = recordingSlot, slot.receive(attachment, activeAttemptID: session.activeAttemptID),
               session.phase == .practicing, !session.retention.applied {
                recordingSlot = slot
            }
            recordingAttachment = nil
        }
    }

    private var setup: some View {
        KitCard {
            Text(session.phase == .preparing ? "Set the task" : "This attempt").font(.headline)
            Text(presenterTitle).font(.subheadline).foregroundStyle(Kit.secondary)
            if session.phase == .preparing {
                labeledField("Role you want to practice", text: $role, identifier: "interview.role")
                Picker("Interview type", selection: $interviewType) {
                    ForEach(InterviewType.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.menu).frame(minHeight: 44).accessibilityIdentifier("interview.type")
                Picker("Presenter", selection: $presenter) {
                    ForEach(LearnerPreferences.Coach.allCases, id: \.self) { Text($0.title).tag($0) }
                }
                .pickerStyle(.menu).frame(minHeight: 44).accessibilityIdentifier("interview.presenter")
                Toggle("This is a fictional persona", isOn: $fictional)
                    .frame(minHeight: 44).accessibilityIdentifier("interview.fictional")
                Toggle("Optional technical note", isOn: $technical)
                    .frame(minHeight: 44).accessibilityIdentifier("interview.technical")
                Text("Technical notes stay separate from English. Framework names are not required.")
                    .font(.footnote).foregroundStyle(Kit.secondary)
                Button("Start interview", action: start).buttonStyle(KitPrimaryButtonStyle())
                    .accessibilityIdentifier("interview.start")
            } else if let attempt = session.activeAttempt {
                Text(attempt.support.roleTitle).font(.title3)
                Text("\(attempt.support.interviewType.title) · \(attempt.support.fictionalPersona ? "Fictional persona" : "Details you choose to share")")
                    .foregroundStyle(Kit.secondary)
                Text(attempt.support.interviewType.offlinePrompt).fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("interview.prompt")
                Text("Changing the role, type, presenter, fiction choice, or technical note starts a new attempt and leaves this one in place.")
                    .font(.footnote).foregroundStyle(Kit.secondary)
                labeledField("New role", text: $role, identifier: "interview.role")
                Picker("New interview type", selection: $interviewType) {
                    ForEach(InterviewType.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.menu).frame(minHeight: 44)
                Picker("Presenter", selection: $presenter) {
                    ForEach(LearnerPreferences.Coach.allCases, id: \.self) { Text($0.title).tag($0) }
                }
                .pickerStyle(.menu).frame(minHeight: 44).accessibilityIdentifier("interview.presenter")
                Toggle("This is a fictional persona", isOn: $fictional).frame(minHeight: 44)
                Toggle("Optional technical note", isOn: $technical).frame(minHeight: 44)
                Button("Start a separate attempt") { revise() }
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("interview.revise")
            }
        }
    }

    private var preparationCard: some View {
        KitCard {
            Text("Preparation").font(.headline)
            Text("Quiet preparation stays available offline. Write only facts you choose. This screen will not invent a job, a result, or a number.")
                .foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
            Toggle("Quiet practice", isOn: quietBinding)
                .frame(minHeight: 44).accessibilityIdentifier("interview.quiet")
            labeledField("Preparation note", text: $preparation, identifier: "interview.preparation")
            Button("Save preparation") {
                apply(session.updatePreparation(note: preparation))
            }
            .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
            .accessibilityIdentifier("interview.preparation.save")
            labeledField("A fact you choose to share", text: $fact, identifier: "interview.fact")
            Button("Add this fact") {
                apply(session.addSuppliedFact(fact))
                if notice == nil { fact = "" }
            }
            .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
            .disabled(session.phase == .preparing)
            .accessibilityIdentifier("interview.fact.add")
            if let facts = session.activeAttempt?.preparation.suppliedFacts, !facts.isEmpty {
                ForEach(Array(facts.enumerated()), id: \.offset) { _, item in
                    Text(item).frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                }
            }
        }
    }

    @ViewBuilder private var interviewLoop: some View {
        if let attempt = session.activeAttempt {
            KitCard {
                Text("Your answer").font(.headline)
                labeledField("Opening answer", text: $opening, identifier: "interview.opening")
                Button("Submit answer", action: submitOpening).buttonStyle(KitPrimaryButtonStyle())
                    .accessibilityIdentifier("interview.opening.submit")
                if let followUp = attempt.activeFollowUp {
                    Text("Follow-up").font(.headline).padding(.top, 8)
                    Text(followUp.composed).fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("interview.followup")
                    labeledField("Answer the follow-up", text: $followUpDraft, identifier: "interview.followup.draft")
                    Button("Submit follow-up answer", action: submitFollowUp)
                        .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("interview.followup.submit")
                }
                if storage != nil || onRecordTurn != nil {
                    Button("Record opening answer") {
                        beginRecording(promptID: attempt.support.interviewType.promptID, record: { onRecordTurn?($0) })
                    }
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("interview.record")
                    if let followUp = attempt.activeFollowUp {
                        Button("Record follow-up answer") {
                            beginRecording(promptID: followUp.id.uuidString, record: { onRecordTurn?($0) })
                        }.buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                            .accessibilityIdentifier("interview.followup.record")
                    }
                    if let slot = recordingSlot, slot.reference != nil {
                        Text(slot.promptID == attempt.support.interviewType.promptID
                             ? "Completed take attached to the opening answer."
                             : "Completed take attached to the follow-up answer.")
                            .font(.footnote).foregroundStyle(Kit.secondary)
                            .accessibilityIdentifier("interview.recording.attached")
                    }
                    Text("The recording stays in the existing Speech Lab recorder. Nothing is uploaded. Submit still needs the words you want the follow-up to use.")
                        .font(.footnote).foregroundStyle(Kit.secondary)
                } else {
                    AvailabilityCard(
                        title: "The recorder is not connected",
                        detail: "Write the answer here. Audio stays in the existing Speech Lab recorder and is not uploaded.",
                        symbol: "mic.slash")
                }
                Button("Ask for an online follow-up") {}
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .disabled(true)
                    .accessibilityIdentifier("interview.online")
                    .accessibilityHint("Online follow-ups stay off until a turn contract is approved. Nothing is sent.")
                if attempt.support.technicalCoaching {
                    labeledField("Optional technical note", text: $technicalNote, identifier: "interview.technical.note")
                    Button("Save technical note") {
                        apply(session.saveTechnicalNote(technicalNote))
                    }
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("interview.technical.save")
                }
                HStack {
                    Button("Stop") { apply(session.stop(now: .now)) }
                        .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                        .accessibilityIdentifier("interview.stop")
                    Button("End practice") { apply(session.end(now: .now)) }
                        .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                        .accessibilityIdentifier("interview.end")
                }
                if let openingAnswer = attempt.answers.last(where: { $0.promptID == attempt.support.interviewType.promptID }) {
                    Button("Try the opening answer again") {
                        followUpDraft = ""
                        let result = session.retryOpening(previousID: openingAnswer.id, text: opening,
                            recordingReference: recordingSlot?.reference(attemptID: attempt.id, promptID: attempt.support.interviewType.promptID), now: .now)
                        apply(result)
                        if result.accepted { recordingSlot = nil; recordingAttachment = nil }
                    }
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("interview.retry")
                }
            }.disabled(session.retention.applied)
            PracticeSelfReviewForm(review: attempt.review, identifierPrefix: "interview") { purpose, facts, step in
                apply(session.saveSelfReview(purposeClear: purpose, factsNamed: facts, nextStep: step, now: .now))
            }
            .disabled(session.retention.applied)
            .id("\(attempt.id)-\(session.retention.applied)")
            if session.phase == .stopped || session.phase == .ended {
                PracticeRetentionForm(retention: session.retention, identifierPrefix: "interview") { audio, text in
                    guard discardAudioIfNeeded(keepAudio: audio) else { return }
                    let result = session.applyRetention(keepAudio: audio, keepText: text)
                    apply(result)
                    if result.accepted {
                        recordingSlot = nil; recordingAttachment = nil
                        opening = ""; followUpDraft = ""; preparation = ""; fact = ""; technicalNote = ""
                        if !text { role = "" }
                    }
                }
                if session.phase == .stopped {
                    Button("Continue practice") { apply(session.restart()) }
                        .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                        .accessibilityIdentifier("interview.restart")
                }
            }
            if attempt.qualifiesAsInteractiveInterview {
            }
        }
    }

    private var archive: SpeakingPracticeArchive {
        SpeakingPracticeArchive(kind: "interview", interview: session,
            drafts: session.retention.applied ? [:] : ["role": role, "opening": opening, "followup": followUpDraft,
                "preparation": preparation, "fact": fact, "technicalNote": technicalNote,
                "type": interviewType.rawValue, "presenter": presenter.rawValue, "fictional": String(fictional), "technical": String(technical)],
            expiresAt: nil, recordingSlot: session.retention.applied ? nil : recordingSlot, updatedAt: session.startedAt)
    }
    private func restore(_ saved: SpeakingPracticeArchive) {
        guard let value = saved.interview else { return }
        session = value
        role = saved.drafts["role"] ?? value.draftSupport.roleTitle
        opening = saved.drafts["opening"] ?? ""; followUpDraft = saved.drafts["followup"] ?? ""
        preparation = saved.drafts["preparation"] ?? ""; fact = saved.drafts["fact"] ?? ""
        technicalNote = saved.drafts["technicalNote"] ?? ""
        interviewType = InterviewType(rawValue: saved.drafts["type"] ?? "") ?? value.draftSupport.interviewType
        presenter = LearnerPreferences.Coach(rawValue: saved.drafts["presenter"] ?? "") ?? .tigerBusinessProfessional
        fictional = saved.drafts["fictional"] == "true"; technical = saved.drafts["technical"] == "true"
        recordingSlot = saved.recordingSlot
    }
    private func discardAudioIfNeeded(keepAudio: Bool) -> Bool {
        guard !keepAudio, let repository = storage?.repository else { return true }
        do {
            try repository.discardSpeakingPracticeAudio(archive.audioReferences, sessionID: session.id,
                expectedEpoch: repository.learningDataEpoch())
            return true
        } catch { notice = "The recording could not be removed. Keep this screen open and try again."; return false }
    }

    private var presenterTitle: String {
        presenter.title
    }

    private var quietBinding: Binding<Bool> {
        Binding {
            session.activeAttempt?.preparation.quietPractice ?? session.draftPreparation.quietPractice
        } set: { quiet in
            apply(session.setQuietPractice(quiet))
        }
    }

    private func start() {
        session.draftSupport.roleTitle = role
        session.draftSupport.interviewType = interviewType
        session.draftSupport.fictionalPersona = fictional
        session.draftSupport.technicalCoaching = technical
        session.draftSupport.presenterID = presenter.rawValue
        _ = session.updatePreparation(note: preparation)
        apply(session.begin(publishedScenarios: [], now: .now))
    }

    private func revise() {
        var support = session.draftSupport
        support.roleTitle = role
        support.interviewType = interviewType
        support.fictionalPersona = fictional
        support.technicalCoaching = technical
        support.presenterID = presenter.rawValue
        let previousID = session.activeAttemptID
        let result = session.reviseSupport(support, publishedScenarios: [], now: .now)
        apply(result)
        if result.accepted, session.activeAttemptID != previousID {
            opening = ""; followUpDraft = ""; technicalNote = ""
            recordingSlot = nil; recordingAttachment = nil
        }
    }

    private func submitOpening() {
        guard let attempt = session.activeAttempt else { return }
        let result = session.submitOpening(text: opening,
            recordingReference: recordingSlot?.reference(attemptID: attempt.id, promptID: attempt.support.interviewType.promptID), now: .now)
        apply(result)
        if result.accepted { recordingSlot = nil; recordingAttachment = nil }
    }

    private func submitFollowUp() {
        guard let attempt = session.activeAttempt, let followUp = attempt.activeFollowUp else { return }
        let result = session.submitFollowUp(text: followUpDraft,
            recordingReference: recordingSlot?.reference(attemptID: attempt.id, promptID: followUp.id.uuidString), now: .now)
        apply(result)
        if result.accepted { recordingSlot = nil; recordingAttachment = nil }
    }

    private func beginRecording(promptID: String, record: (UUID) -> Void) {
        guard session.phase == .practicing, let attemptID = session.activeAttemptID else { return }
        let slot = recordingSlot.flatMap { $0.attemptID == attemptID && $0.promptID == promptID && $0.reference == nil ? $0 : nil }
            ?? InterviewRecordingSlot(attemptID: attemptID, promptID: promptID)
        recordingSlot = slot; recordingAttachment = nil
        if let storage, let attempt = session.activeAttempt {
            let prompt = attempt.activeFollowUp?.id.uuidString == promptID ? attempt.activeFollowUp?.composed : attempt.support.interviewType.offlinePrompt
            recordingContext = practiceRecordingContext(slotID: slot.id, sessionID: session.id,
                prompt: prompt ?? "", objective: "INTERVIEW-LOCAL", presenter: attempt.support.presenterID,
                purpose: "interviewTurn", defaults: storage.preferences)
        } else { record(slot.id) }
    }

    private func apply(_ action: ConversationAction) {
        notice = action.refusal.map(conversationNotice)
    }

    private func labeledField(_ title: String, text: Binding<String>, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline.weight(.semibold))
            TextField(title, text: text, axis: .vertical)
                .lineLimit(1...6).textFieldStyle(.roundedBorder)
                .accessibilityIdentifier(identifier)
                .dictation(text)
        }
    }
}
