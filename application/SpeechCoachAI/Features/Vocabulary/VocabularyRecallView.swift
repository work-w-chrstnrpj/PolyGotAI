import SwiftUI

struct VocabularyRecallSession: View {
    var storage: LearnerStorageController
    @Environment(\.dynamicTypeSize) private var textSize
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var writing: Bool
    @State private var cards: [VocabularyEnrollment] = []
    @State private var index = 0
    @State private var draft = RecallDraft()
    @State private var meaning: String?
    @State private var rated = 0
    @State private var lastRewardSource: String?
    @State private var waiting = 0
    @State private var nextDue: Date?
    @State private var blocked = 0
    @State private var message: String?
    @State private var loaded = false
    @State private var draftSaved = false
    @State private var deferred = 0
    @State private var epoch: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let lastRewardSource { RewardSummary(storage: storage, sourcePrefix: lastRewardSource, sourceTitle: "Last rated review") }
                if !loaded {
                    AvailabilityCard(title: "Opening your review", detail: "One moment.", symbol: "square.stack")
                } else if cards.isEmpty && waiting == 0 && blocked == 0 {
                    AvailabilityCard(title: "No saved words yet",
                                     detail: "Add a word to review from a lesson or topic. Then you can practice it here without a connection.",
                                     symbol: "square.stack")
                } else if cards.isEmpty {
                    AvailabilityCard(title: "Nothing is due right now",
                                     detail: waitingDetail,
                                     symbol: "clock")
                } else if index >= cards.count {
                    KitCard {
                        Text("Practice saved").font(.title2.bold())
                        Text("You rated \(rated) \(rated == 1 ? "word" : "words"). Again means a miss. Hard, Good, and Easy mean you knew it.")
                            .foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                        if waiting > 0 {
                            Text(waitingDetail).font(.footnote).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    Button("Practice again") { restart() }
                        .buttonStyle(.borderedProminent).foregroundStyle(Color("OnAccent"))
                        .accessibilityIdentifier("vocabulary.recall.again")
                } else {
                    card(cards[index])
                    if waiting > 0 {
                        Text(waitingDetail).font(.footnote).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("vocabulary.recall.waiting")
                    }
                }
                if deferred > 0 {
                    Text("\(deferred) more due \(deferred == 1 ? "word remains" : "words remain") for another session. Your session-size choice does not change their due dates.")
                        .font(.footnote).foregroundStyle(Kit.secondary)
                        .accessibilityIdentifier("vocabulary.recall.deferred")
                }
                if let message {
                    Text(message).foregroundStyle(Kit.secondary).accessibilityIdentifier("vocabulary.recall.message")
                }
            }
            .padding(20)
            .frame(maxWidth: 700, alignment: .leading)
        }
        .background(Kit.canvas(storage.preferences.background))
        .foregroundStyle(Kit.ink)
        .controlSize(.large)
        .navigationTitle("Practice")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(RewardEngagementModifier(storage: storage, audio: { false }))
        .onAppear(perform: load)
        .task(id: draft) {
            // Coalesce typing; leaving or backgrounding flushes immediately.
            do { try await Task.sleep(for: .milliseconds(300)) } catch { return }
            saveDraft()
        }
        .onChange(of: draft.typed) { _, _ in draftSaved = false; storage.rewardEngagement.clock.interact(at: ProcessInfo.processInfo.systemUptime) }
        .onDisappear { saveDraft() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { saveDraft() }
        }
    }

    private func card(_ card: VocabularyEnrollment) -> some View {
        KitCard {
            Text("Word \(index + 1) of \(cards.count)").font(.caption).foregroundStyle(Kit.secondary)
            Text(card.lemma).font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("vocabulary.recall.lemma")
            Text("Recall the meaning before you show it. Choose the way that works for you.")
                .font(.footnote).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
            if !draft.revealed {
                recallMode
                if draft.mode == .write {
                    Text("Your meaning, in your own words (optional)").font(.callout)
                    TextField("Write the meaning if you want", text: $draft.typed, axis: .vertical)
                        .lineLimit(2...4)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .focused($writing)
                        .accessibilityIdentifier("vocabulary.recall.typed")
                        .dictation($draft.typed)
                } else {
                    Text(draft.mode == .say
                         ? "Say your answer aloud, then show the meaning. This is an unrecorded self-check; the app does not listen or assess your speech."
                         : "Think of your answer, then show the meaning. You can review without typing or speaking.")
                        .font(.callout).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                }
                Text(draftSaved ? "Draft saved on this device" : "Saving your draft…")
                    .font(.caption).foregroundStyle(Kit.secondary)
                    .accessibilityIdentifier("vocabulary.recall.draftStatus")
                Button("Show meaning") { showMeaning(card) }
                    .buttonStyle(.borderedProminent).foregroundStyle(Color("OnAccent"))
                    .accessibilityIdentifier("vocabulary.recall.reveal")
            } else {
                if draft.mode == .say {
                    Text("Spoken self-check · No recording or speech assessment")
                        .font(.callout).foregroundStyle(Kit.secondary)
                        .accessibilityIdentifier("vocabulary.recall.spoken")
                }
                if let first = draft.firstResponse {
                    Text("You wrote: \(first)").font(.callout).fixedSize(horizontal: false, vertical: true)
                }
                Text(meaning ?? "No meaning note was saved with this word.")
                    .font(.title3).fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("vocabulary.recall.meaning")
                if meaning != nil {
                    Text("How well did you know it?").font(.headline)
                    Text("If you missed it, choose Again. Hard means you recalled it successfully with effort.")
                        .font(.footnote).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                    ratings
                } else {
                    Text("Add a meaning in your topic before rating this word. No review will be recorded.")
                        .font(.callout).foregroundStyle(Kit.secondary)
                    Button("Skip for now") { skip() }
                        .buttonStyle(.bordered)
                }
            }
        }
    }

    @ViewBuilder private var ratings: some View {
        if textSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) { ratingButtons }
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) { ratingButtons }
        }
    }

    @ViewBuilder private var ratingButtons: some View {
        ForEach(RecallRating.allCases, id: \.self) { rating in
            Button("\(rating.title). \(rating.detail)") { rate(rating) }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, minHeight: 44)
                .accessibilityIdentifier("vocabulary.recall.rate.\(rating.rawValue)")
        }
    }

    private var waitingDetail: String {
        var parts: [String] = []
        if waiting > 0 {
            let word = waiting == 1 ? "word is" : "words are"
            if let nextDue {
                parts.append("\(waiting) \(word) waiting. The next one comes back in \(ReviewSchedule.returnPhrase(due: nextDue, now: .now)).")
            } else {
                parts.append("\(waiting) \(word) waiting for a later review.")
            }
        }
        if blocked > 0 {
            parts.append("A saved word has review history this version will not change. It was left unchanged.")
        }
        return parts.joined(separator: " ")
    }

    private var modeBinding: Binding<RecallMode> {
        Binding(get: { draft.mode }, set: { mode in
            writing = false
            draft.mode = mode
            draftSaved = false
        })
    }

    @ViewBuilder private var recallMode: some View {
        if textSize.isAccessibilitySize {
            Picker("Recall method", selection: modeBinding) { modeOptions }.pickerStyle(.menu)
                .accessibilityIdentifier("vocabulary.recall.mode")
        } else {
            Picker("Recall method", selection: modeBinding) { modeOptions }.pickerStyle(.segmented)
                .accessibilityIdentifier("vocabulary.recall.mode")
        }
    }

    private var modeOptions: some View {
        ForEach(RecallMode.allCases, id: \.self) { mode in
            Text(mode.title).tag(mode)
        }
    }

    private func load() {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let plan = try repository.reviewQueue()
            epoch = try repository.learningDataEpoch()
            let open = try repository.openRecall()
            let session = try ReviewSessionPlan(queue: plan, settings: repository.reviewSettings(), open: open)
            cards = session.cards
            deferred = session.deferred
            waiting = plan.waiting
            nextDue = plan.nextDue
            blocked = plan.blocked
            index = 0
            draft = RecallDraft()
            meaning = nil
            if let open,
               let match = cards.firstIndex(where: { $0.itemId == open.itemId && $0.senseId == open.senseId }) {
                // The session plan already prioritizes the interrupted card before applying its limit.
                cards.insert(cards.remove(at: match), at: 0)
                draft = RecallDraft(open)
                if open.revealed {
                    meaning = try repository.meaningNote(itemId: open.itemId, senseId: open.senseId)
                }
            }
            loaded = true
            draftSaved = false
            saveDraft()
        } catch {
            loaded = false
            message = "Your review could not be opened. Unlock your device and try opening Practice again. Your earlier ratings are unchanged."
        }
    }

    private func saveDraft() {
        guard loaded, index < cards.count, !draft.revealed else { return }
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            try repository.stageOpenRecall(card: cards[index], draft: draft, expectedEpoch: epoch)
            draftSaved = true
        } catch {
            draftSaved = false
            message = "Your draft could not be saved. Keep this screen open and try again after unlocking your device."
        }
    }

    private func showMeaning(_ card: VocabularyEnrollment) {
        writing = false
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            var revealed = draft
            revealed.reveal()
            let note = try repository.meaningNote(itemId: card.itemId, senseId: card.senseId)
            // Commit the exposure before displaying it, so a restart cannot turn it into unaided recall.
            try repository.stageOpenRecall(card: card, draft: revealed, expectedEpoch: epoch)
            draft = revealed
            meaning = note
            message = nil
        } catch {
            message = "The reveal could not be saved. Your answer is still here. Try Show meaning again after unlocking your device."
        }
    }

    private func skip() {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            try repository.clearOpenRecall(sourceEventID: draft.sourceEventID, expectedEpoch: epoch)
            index += 1
            draft = RecallDraft()
            draftSaved = false
            meaning = nil
        } catch {
            message = "This word could not be skipped. Your review is still here."
        }
    }

    private func rate(_ rating: RecallRating) {
        guard index < cards.count else { return }
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let attempt = try repository.recordVocabularyRecall(card: cards[index], rating: rating, draft: draft, expectedEpoch: epoch)
            let card = cards[index]
            lastRewardSource = "review/\(attempt.sourceEventID ?? attempt.id)"
            rated += 1
            index += 1
            draft = RecallDraft()
            draftSaved = false
            meaning = nil
            if let plan = try? repository.reviewQueue() {
                waiting = plan.waiting
                nextDue = plan.nextDue
                blocked = plan.blocked
            }
            if let schedule = try? repository.recognitionSchedule(itemId: card.itemId, senseId: card.senseId) {
                message = "Next review in \(ReviewSchedule.returnPhrase(due: schedule.due, now: attempt.createdAt))."
            } else {
                message = nil
            }
        } catch VocabularyRecallError.stillHidden {
            message = "Show the meaning before you rate the word."
        } catch {
            message = "The rating could not be saved. Your earlier ratings are unchanged."
        }
    }

    private func restart() {
        index = 0
        rated = 0
        draft = RecallDraft()
        meaning = nil
        load()
    }
}
