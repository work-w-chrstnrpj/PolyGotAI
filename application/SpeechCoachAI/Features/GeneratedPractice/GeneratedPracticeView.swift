import SwiftUI

/// T05 Activity (`2:38252`) and Kit/Status (`41:1155`) for an optional generated variation.
/// Online generation stays off until the caller supplies an approved policy and a transport.
struct GeneratedPracticeView: View {
    @Binding var session: GeneratedPracticeSession
    var policy: GenerationPolicy?
    var epoch: UUID?
    var background: LearnerPreferences.Background = .creativeAcademy
    var persist: ((GeneratedPracticeRecord) -> Bool)?
    var performRequest: ((GeneratedPracticeSession, GenerationPolicy) async -> GeneratedPracticeSession)?
    @Environment(\.scenePhase) private var scenePhase
    @State private var run: UUID?
    @State private var task: Task<Void, Never>?
    @State private var reporting = false
    @State private var confirmRemoval = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                status
                if session.personalPreviewBlocked {
                    AvailabilityCard(title: "Personal-use preview", detail: "This preview is not educator-reviewed fallback practice.", symbol: "exclamationmark.circle")
                        .accessibilityIdentifier("generated.preview")
                }
                if let attempt = session.protectedAttempt {
                    KitCard {
                        Text("Current practice").font(.headline)
                        Text(attempt.prompt).fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("generated.current")
                        Text("This attempt, its objective, and its review time stay in place.")
                            .font(.footnote).foregroundStyle(Kit.secondary)
                    }
                }
                if let fallback = session.qualifiedFallback, let record = fallback.qualifiedRecord {
                    KitCard {
                        Text("Educator-reviewed fallback").font(.headline)
                        Text(fallback.prompt).fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("generated.fallback")
                        Text("Reviewed record \(record). This is separate from a generated variation.")
                            .font(.footnote).foregroundStyle(Kit.secondary)
                    }
                }
                generatedCard
                choices.disabled(task != nil || session.phase == .awaiting)
                actions
                AvailabilityCard(title: "Practice works offline", detail: "Lessons stay available without a generated variation. A new variation is optional and is not sent automatically.", symbol: "wifi.slash")
            }
            .padding(20)
            .frame(maxWidth: 640, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .background(Kit.canvas(background))
        .foregroundStyle(Kit.ink)
        .navigationTitle("Generated practice")
        .sheet(isPresented: $reporting) {
            ActivityReportView(session: $session, policy: policy, epoch: epoch, background: background, persist: persist)
        }
        .alert("Remove saved wording?", isPresented: $confirmRemoval) {
            Button("Remove wording", role: .destructive) {
                if let id = session.presented?.variantID {
                    session.deletePrivateVariant(variantID: id)
                    _ = session.persistChanges(expectedEpoch: epoch, using: persist)
                }
            }.accessibilityIdentifier("generated.remove.confirm")
            Button("Cancel", role: .cancel) { }
        } message: { Text("This removes the saved wording for this variation. Your lesson progress stays as it was.") }
        .onDisappear(perform: cancel)
        .onChange(of: epoch) { _, value in cancel(); confirmRemoval = false; session.bindEpoch(value) }
        .onChange(of: scenePhase) { _, phase in if phase != .active { cancel() } }
    }

    @ViewBuilder private var status: some View {
        if session.commitFailed {
            AvailabilityCard(title: "Save failed", detail: GenerationRefusal.storageFailure.message, symbol: "exclamationmark.circle")
        } else if policy?.accepted != true {
            AvailabilityCard(title: "Generated variations are unavailable", detail: GenerationRefusal.missingPolicy.message, symbol: "exclamationmark.circle")
                .accessibilityIdentifier("generated.unavailable")
        } else if session.phase == .awaiting || task != nil {
            AvailabilityCard(title: "Waiting", detail: "Nothing new will be sent automatically. You can stop waiting.", symbol: "clock")
        } else if let refusal = session.lastRefusal {
            AvailabilityCard(title: "Check this step", detail: refusal.message, symbol: "exclamationmark.circle")
                .accessibilityIdentifier("generated.notice")
        }
    }

    @ViewBuilder private var generatedCard: some View {
        if let presented = session.presented {
            KitCard {
                Text("Generated variation").font(.headline)
                Text("Not educator-reviewed. A structural check is not a content review.")
                    .font(.footnote).foregroundStyle(Kit.secondary)
                if presented.textUnavailableAfterDeletion {
                    Text("The saved wording was removed from this device and was not restored.")
                        .accessibilityIdentifier("generated.deleted")
                } else if let prompt = presented.prompt {
                    Text(prompt).fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("generated.variant")
                }
                if let choices = presented.choices {
                    ForEach(Array(choices.enumerated()), id: \.offset) { _, choice in
                        Text(choice).fixedSize(horizontal: false, vertical: true)
                    }
                }
                if presented.answerRevealed, let answer = presented.revealedAnswer {
                    Text("Answer: \(answer)").font(.headline).accessibilityIdentifier("generated.answer")
                }
                if presented.answerRevealed, let explanation = presented.explanation {
                    Text(explanation).font(.subheadline).foregroundStyle(Kit.secondary)
                } else if presented.kind == .recallCloze || presented.kind == .recognitionChoice {
                    Text("The answer stays hidden until you reveal it.")
                        .font(.footnote).foregroundStyle(Kit.secondary)
                        .accessibilityIdentifier("generated.answer.hidden")
                }
                if presented.kind == .vocabularyCandidate {
                    Text("A suggestion is not added to your words.").font(.footnote).foregroundStyle(Kit.secondary)
                }
            }
            if !presented.answerRevealed && !presented.textUnavailableAfterDeletion && presented.kind != .guidedProduction && presented.kind != .situationExample {
                Button("Reveal answer", action: { _ = session.reveal() })
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("generated.reveal")
                    .disabled(task != nil)
            }
        }
    }

    private var choices: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Practice preference", selection: familiarity) {
                Text("Not chosen").tag(FamiliarityPick.unset)
                Text("Familiar").tag(FamiliarityPick.familiar)
                Text("Fresh").tag(FamiliarityPick.fresh)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("generated.preference")
            Picker("Activity", selection: kind) {
                Text("Not chosen").tag(Optional<GeneratedActivityKind>.none)
                ForEach(GeneratedActivityKind.allCases) { item in
                    Text(item.title).tag(Optional(item))
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("generated.kind")
            Picker("Keep this wording on this device", selection: $session.retention) {
                Text("Not chosen").tag(PrivateRetentionChoice.notChosen)
                Text("Don't keep").tag(PrivateRetentionChoice.declined)
                Text("Keep").tag(PrivateRetentionChoice.optedIn)
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("generated.retention")
        }
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: 12) {
            if session.commitFailed {
                Button("Retry saving changes") { _ = session.persistChanges(expectedEpoch: epoch, using: persist) }
                    .buttonStyle(.bordered).accessibilityIdentifier("generated.save.retry")
            }
            Button(primaryTitle, action: primaryAction)
                .buttonStyle(KitPrimaryButtonStyle())
                .disabled(primaryDisabled)
                .accessibilityIdentifier("generated.request")
            if session.familiarity == .fresh && performRequest == nil {
                Text("This screen cannot send a request. Nothing leaves the device.")
                    .font(.footnote).foregroundStyle(Kit.secondary)
            }
            if session.phase == .awaiting || task != nil {
                Button("Stop waiting", action: cancel)
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("generated.cancel")
                if performRequest != nil {
                    Text("If a request already left the device, remote processing or charges may continue. Nothing will be retried automatically.")
                        .font(.footnote).foregroundStyle(Kit.secondary)
                }
            }
            if session.presented != nil && session.retention != .notChosen {
                Button("Save on this device", action: saveRetention)
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("generated.save")
                    .disabled(task != nil || session.phase == .awaiting || policy?.accepted != true)
            }
            if session.presented?.variantID != nil {
                Button("Remove saved wording", role: .destructive, action: { confirmRemoval = true })
                    .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("generated.remove")
                    .disabled(task != nil || session.phase == .awaiting)
            }
            Button("Report an activity") { reporting = true }
                .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                .accessibilityIdentifier("generated.report")
                .disabled(task != nil || session.phase == .awaiting || session.reportSubject == nil)
        }
    }

    private var primaryTitle: String {
        switch session.familiarity {
        case .fresh: "Request a variation"
        case .familiar: "Use a saved variation"
        case nil: "Choose fresh or familiar"
        }
    }

    private var primaryDisabled: Bool {
        policy?.accepted != true || session.source == nil || session.familiarity == nil
            || session.phase == .awaiting || task != nil
            || (session.familiarity == .fresh && performRequest == nil)
    }

    private func primaryAction() {
        if session.familiarity == .familiar {
            _ = session.presentFamiliar(policy: policy, now: .now)
            return
        }
        guard session.familiarity == .fresh else { return }
        guard let policy, let performRequest else {
            _ = session.beginFresh(policy: policy, connected: false, now: .now)
            return
        }
        let token = UUID()
        run = token
        let current = session
        task = Task {
            let updated = await performRequest(current, policy)
            guard !Task.isCancelled, run == token, epoch == current.epoch else { return }
            task = nil; run = nil
            session = updated
            _ = session.persistChanges(expectedEpoch: epoch, using: persist)
        }
    }

    private func cancel() {
        task?.cancel()
        task = nil
        run = nil
        if session.phase == .awaiting { _ = session.cancelRequest() }
    }

    private func saveRetention() {
        guard session.applyRetention(session.retention, policy: policy, now: .now) == nil else { return }
        _ = session.persistChanges(expectedEpoch: epoch, using: persist)
    }

    private var familiarity: Binding<FamiliarityPick> {
        Binding(
            get: {
                switch session.familiarity {
                case .fresh: .fresh
                case .familiar: .familiar
                case nil: .unset
                }
            },
            set: { session.familiarity = $0.choice }
        )
    }

    private var kind: Binding<GeneratedActivityKind?> {
        Binding(get: { session.requestedKind }, set: { session.requestedKind = $0 })
    }
}

private enum FamiliarityPick: Hashable {
    case unset, fresh, familiar
    var choice: FamiliarityChoice? {
        switch self {
        case .unset: nil
        case .fresh: .fresh
        case .familiar: .familiar
        }
    }
}

struct GeneratedPracticeLauncher: View {
    var epoch: UUID?
    var policy: GenerationPolicy?
    var background: LearnerPreferences.Background = .creativeAcademy
    var persist: ((GeneratedPracticeRecord) -> Bool)?
    var performRequest: ((GeneratedPracticeSession, GenerationPolicy) async -> GeneratedPracticeSession)?
    @State private var session = GeneratedPracticeSession.unavailable

    var body: some View {
        GeneratedPracticeView(session: $session, policy: policy, epoch: epoch, background: background, persist: persist, performRequest: performRequest)
            .onAppear { session.bindEpoch(epoch) }
    }
}

/// Real-target host: the existing learner document owns durability; no live policy/adapter is bundled.
struct GeneratedPracticeHost: View {
    var storage: LearnerStorageController
    @Environment(\.scenePhase) private var scenePhase
    @State private var session = GeneratedPracticeSession.unavailable
    @State private var baseline: GeneratedPracticeRecord?
    @State private var epoch: UUID?
    @State private var message: String?

    private var policy: GenerationPolicy? {
        #if DEBUG
        if SpeakingEnvironment.fixtureID != nil,
           ProcessInfo.processInfo.environment["SC_GENERATED_FIXTURE"] == "1" {
            return GeneratedPracticeUIFixture.policy
        }
        #endif
        return nil
    }

    var body: some View {
        VStack(spacing: 0) {
            if let message {
                Text(message).font(.callout).foregroundStyle(Kit.error).padding()
                    .accessibilityIdentifier("generated.storage.error")
                Button("Try loading again", action: load).frame(minHeight: 44)
            }
            GeneratedPracticeView(session: $session, policy: policy, epoch: epoch,
                background: storage.preferences.background, persist: persist)
        }
        .onAppear(perform: load)
        .onChange(of: scenePhase) { _, phase in if phase == .active { load() } }
    }

    private func load() {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let current = try repository.learningDataEpoch()
            if epoch != current {
                session.bindEpoch(current); epoch = current; baseline = nil
            } else if session.hasUnsavedChanges { return }
            let saved = try repository.generatedPracticeRecord()
            baseline = saved
            if let saved {
                session = GeneratedPracticeSession.recover(saved, epoch: current)
                if session.hasUnsavedChanges {
                    if !session.persistChanges(expectedEpoch: current, using: persist) { return }
                }
            }
            message = nil
        } catch { message = "Local practice could not be loaded. Existing saved data has been kept. Try again after unlocking your device." }
    }

    private func persist(_ record: GeneratedPracticeRecord) -> Bool {
        do {
            guard let repository = storage.repository, let epoch else { throw LearnerStorageError.unavailable }
            try repository.saveGeneratedPracticeRecord(record, expectedEpoch: epoch, replacing: baseline)
            baseline = record; message = nil; return true
        } catch LearnerStorageError.staleVersion {
            if let current = try? storage.repository?.learningDataEpoch(), current != epoch {
                epoch = current; baseline = nil
            }
            message = "Practice changed or was reset. Reopen this screen before saving again."
        } catch { message = "The save failed. Your last saved copy is unchanged. Try again after unlocking your device." }
        return false
    }
}
