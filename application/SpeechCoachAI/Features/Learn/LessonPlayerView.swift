import AVFAudio
import SwiftUI

/// Page 1 T04/T05/T06: teach, attempt, compare, continue. One activity owns the screen.
struct LessonPlayerView: View {
    var storage: LearnerStorageController
    var lesson: ResolvedLesson
    var install: CurriculumInstall = CurriculumCatalogLoader.bundled
    var origin: LessonPracticeOrigin? = nil
    var initialConditions: CurriculumPracticeConditions? = nil
    var initialFocus: ObservedDifficulty? = nil
    var onSpeak: (ResolvedLesson, UUID) -> Void = { _, _ in }
    @State private var didApplyInitialFocus = false
    @State private var selectedLesson: ResolvedLesson?
    @State private var savedJourneys: [LessonJourney] = []
    @State private var curriculumPractice: CurriculumPracticeRoute?
    @State private var topicRecordingContext: PracticeSessionContext?
    private var presentedLesson: ResolvedLesson { selectedLesson ?? lesson }
    @State private var session: LessonSession?
    @State private var preserved: LessonJourney?
    @State private var drafts: [String: String] = [:]
    @State private var savedSenseIDs: Set<String> = []
    @State private var reviewSenseIDs: Set<String> = []
    @State private var showIntroduction = true
    @State private var showContents = false
    @State private var showCommunication = false
    @State private var practicePack: IntroPracticePack?
    @State private var showMissed = false
    @State private var checkKind: IntroCheckKind?
    @State private var message: String?
    @State private var clip: AVAudioPlayer?
    @State private var draftSave: Task<Void, Never>?
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var answering: Bool

    private var activity: CurriculumActivity? {
        guard let session else { return nil }
        return session.activities.first { $0.id == session.journey.currentActivityID } ?? session.activities.first
    }
    private var position: Int {
        session?.activities.firstIndex { $0.id == activity?.id } ?? 0
    }
    private var isComplete: Bool { session?.journey.completedAt != nil }
    private var isIntroduction: Bool { presentedLesson.objectiveId == "INTRO-01" }
    /// The current activity when it is an auto-checked exercise shown by the exercise flow.
    private var typedActivity: CurriculumActivity? {
        guard !showIntroduction, !isComplete, !isIntroduction, session != nil,
              let activity, activity.exercise != nil, activity.resolvedExercise.isChecked else { return nil }
        return activity
    }

    var body: some View {
        Group {
        if let typed = typedActivity, let session {
            ExerciseActivityView(
                activity: typed, progress: Double(position) / Double(max(1, session.activities.count)),
                positionText: "\(position + 1) of \(session.activities.count)", isLast: position == session.activities.count - 1,
                storedResponse: session.response(for: typed.id).flatMap { $0.firstResponseText ?? $0.unaidedText ?? $0.assistedText },
                message: message, canGoBack: position > 0, onBack: { move(-1) },
                onPlayClip: { play($0) },
                onSubmit: { stored in submitExercise(typed.id, stored) },
                onContinue: { if position == session.activities.count - 1 { finish() } else { move(1) } })
                .id(typed.id)
        } else {
        ScrollViewReader { scroll in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Color.clear.frame(height: 0).id("top")
                    if session == nil {
                        AvailabilityCard(title: "Lesson unavailable", detail: message ?? "Opening your saved practice…", symbol: "book")
                    } else if isComplete {
                        completion
                    } else if showIntroduction {
                        introduction
                    } else if let activity, let session {
                        progress(session)
                        activityContent(activity, session: session)
                    }
                    if let preserved {
                        Text("Your saved work from version \(preserved.contentVersion) is preserved. Use Saved versions to open it.")
                            .font(.footnote).foregroundStyle(Kit.secondary)
                    }
                    if let message {
                        Text(message).font(.callout).foregroundStyle(Kit.secondary)
                            .accessibilityIdentifier("lesson.message")
                    }
                }
                .frame(maxWidth: 640, alignment: .leading)
                .padding(24)
                .frame(maxWidth: .infinity)
            }
            .onChange(of: activity?.id) { _, _ in scroll.scrollTo("top", anchor: .top) }
            .onChange(of: isComplete) { _, _ in scroll.scrollTo("top", anchor: .top) }
        }
        }
        }
        .background(Kit.canvas(storage.preferences.background))
        .foregroundStyle(Kit.ink)
        .controlSize(.large)
        .navigationTitle(presentedLesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom, spacing: 0) { footer }
        .toolbar {
            if presentedLesson.supplement != nil {
                ToolbarItem(placement: .topBarLeading) {
                    Menu("Extra practice") {
                        Button("Communication practice") { showCommunication = true }
                            .accessibilityIdentifier("lesson.communication")
                        ForEach(CurriculumPracticeKind.allCases) { kind in
                            Button(kind.title) { openCurriculumPractice(kind) }
                                .accessibilityIdentifier("lesson.topic.\(kind.rawValue)")
                        }
                    }.accessibilityIdentifier("lesson.topic.extra")
                }
            }
            if isIntroduction {
                ToolbarItem(placement: .topBarLeading) {
                    Menu("Extra practice") {
                        Button("Communication practice") { showCommunication = true }
                            .accessibilityIdentifier("lesson.communication")
                        ForEach(IntroPracticePack.allCases) { pack in
                            Button(pack.title) { openPractice(pack) }.accessibilityIdentifier("lesson.extra.\(pack.rawValue)")
                        }
                        Divider()
                        Menu("Choose a focus") {
                            Button("Remember a phrase") { focus(.retrieval) }
                            Button("Match subjects and verbs") { focus(.grammar) }
                            Button("Answer follow-up questions") { focus(.followUp) }
                            Button("Listen and replay for clarity") { focus(.clarity) }
                        }
                        Divider()
                        ForEach(IntroCheckKind.allCases) { kind in
                            Button(kind.title) { openCheck(kind) }.accessibilityIdentifier("lesson.check.\(kind.rawValue)")
                        }
                    }.accessibilityIdentifier("lesson.extra")
                }
            }
            if !isIntroduction && presentedLesson.supplement == nil {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Communication practice") { showCommunication = true }
                        .accessibilityIdentifier("lesson.communication")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showContents = true } label: { Image(systemName: "list.bullet") }
                    .accessibilityLabel("Lesson activities and saved versions")
                    .accessibilityIdentifier("lesson.contents")
            }
        }
        .fullScreenCover(item: $topicRecordingContext) { context in RecordingView(storage: storage, context: context) }
        .sheet(item: $curriculumPractice) { route in
            NavigationStack {
                LessonPlayerView(storage: storage, lesson: route.lesson, install: install, origin: route.origin,
                    initialConditions: route.conditions, onSpeak: onSpeak)
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { curriculumPractice = nil } } }
            }
        }
        .sheet(isPresented: $showCommunication) {
            NavigationStack {
                CommunicationPracticeHost(storage: storage, entry: .learn,
                    source: CommunicationSource(lessonID: presentedLesson.id, contentVersion: presentedLesson.contentVersion,
                        objectiveID: presentedLesson.objectiveId, senseID: nil))
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showCommunication = false } } }
            }
        }
        .sheet(isPresented: $showContents) { contents }
        .sheet(isPresented: $showMissed) {
            MissedPracticeView(activities: session?.missedExercises ?? [], onPlayClip: { play($0) })
        }
        .sheet(item: $practicePack) { pack in
            if let journey = session?.journey {
                IntroPracticeView(storage: storage, pack: pack,
                    origin: LessonPracticeOrigin(journeyID: journey.id, lessonID: journey.lessonID,
                        objectiveID: journey.objectiveID, activityID: journey.currentActivityID))
            }
        }
        .sheet(item: $checkKind) { kind in
            if let journey = session?.journey { IntroCheckView(storage: storage, course: journey, kind: kind) }
        }
        .modifier(RewardEngagementModifier(storage: storage, audio: { clip?.isPlaying == true }))
        .onAppear { load(); applyInitialFocus(); applySpeakingCompletion() }
        .onChange(of: showIntroduction) { _, visible in
            if !visible, var updated = session, updated.journey.teachingBeganAt == nil, updated.journey.responses.isEmpty, (updated.journey.drafts ?? [:]).isEmpty {
                updated.journey.teachingBeganAt = .now
                do {
                    guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
                    try repository.saveLessonJourney(updated.journey); session = updated
                } catch { message = "Couldn’t save your progress." }
            }
        }
        .onChange(of: storage.repository != nil) { _, ready in if ready { load(); applyInitialFocus() } }
        .onChange(of: drafts) { _, _ in storage.rewardEngagement.clock.interact(at: ProcessInfo.processInfo.systemUptime) }
        .onChange(of: storage.latestLessonSpeech) { _, _ in applySpeakingCompletion() }
        .onDisappear { draftSave?.cancel(); saveDrafts(); stopAudio() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { draftSave?.cancel(); saveDrafts(); stopAudio() }
        }
    }

    private var introduction: some View {
        Group {
            HStack(alignment: .center, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(presentedLesson.level) · YOUR LESSON").font(.caption.weight(.semibold)).foregroundStyle(Kit.accent)
                    Text(isIntroduction ? "A small introduction. A real connection." : presentedLesson.title)
                        .font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
                }
                CoachArtwork(name: storage.preferences.coach.portrait).frame(width: 90, height: 115)
            }
            Text(isIntroduction ? "Introduce yourself with a name, what you do, and something you enjoy. Invented details are welcome." : "Read and listen, build useful sentences, then make them your own.")
                .font(.title3).foregroundStyle(Kit.secondary)
            if let tip = presentedLesson.tip {
                KitCard {
                    Text("Coach tip").font(.headline)
                    Text(tip).font(.title3).fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("lesson.topic.teaching")
                }
            } else if let supplement = presentedLesson.supplement {
                KitCard {
                    Text("Make the pattern useful").font(.headline)
                    Text(supplement.teaching).accessibilityIdentifier("lesson.topic.teaching")
                }
            }
            if let conditions = session?.journey.practiceConditions {
                KitCard {
                    Text("Separate optional practice").font(.headline)
                    Toggle("I used examples, hints or other support", isOn: practiceChoice(\.supported))
                    Toggle("Keep my written responses on this device", isOn: practiceChoice(\.retainedText))
                        .accessibilityIdentifier("lesson.practice.keep-text")
                }
            }
            if isIntroduction {
                KitCard {
                    Text("Try an optional first check").font(.headline)
                    Button("Introduction baseline") { openCheck(.baseline) }.accessibilityIdentifier("lesson.baseline")
                }
            }
            VStack(spacing: 0) {
                KitContentRow(symbol: "headphones", title: "Read & listen", detail: presentedLesson.hasCheckedExercises ? "Answer quick questions" : "Meet the language in context")
                Divider()
                KitContentRow(symbol: "pencil", title: "Build & recall", detail: presentedLesson.hasCheckedExercises ? "Tap, type and check" : "Try first, then compare with an example")
                Divider()
                KitContentRow(symbol: "waveform", title: "Make it personal", detail: "Write quietly or open speaking practice")
            }.padding(16).background(Kit.surface, in: RoundedRectangle(cornerRadius: 18))
        }
    }

    private func progress(_ session: LessonSession) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(kindTitle(activity?.kind ?? "")) · \(position + 1) of \(session.activities.count)")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(session.activities.filter { session.hasAttempt(for: $0.id) }.count) practiced")
                    .font(.caption).foregroundStyle(Kit.secondary)
            }
            ProgressView(value: Double(position + 1), total: Double(max(1, session.activities.count)))
                .tint(Kit.accent).accessibilityHidden(true) // Position is already spoken by the text above.
        }
    }

    private func activityContent(_ activity: CurriculumActivity, session: LessonSession) -> some View {
        let response = session.response(for: activity.id)
        let attempted = session.hasAttempt(for: activity.id)
        return VStack(alignment: .leading, spacing: 24) {
            Text(activity.prompt ?? "Practice this activity.")
                .font(.title2.weight(.semibold)).fixedSize(horizontal: false, vertical: true)
            if activity.kind == "listening", let path = activity.playbackPath {
                Button { play(path) } label: { Label("Play recording", systemImage: "play.circle.fill") }
                    .buttonStyle(.bordered).controlSize(.large)
                    .accessibilityIdentifier("lesson.play.\(activity.id)")
            }
            if activity.kind == "guidedSpeaking" {
                if presentedLesson.isReady {
                    Button { openSpeaking() } label: {
                        Label("Open speaking practice", systemImage: "mic")
                    }.buttonStyle(.bordered).accessibilityIdentifier("lesson.speak")
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                Text(attempted ? "Your response" : "Your turn").font(.headline)
                if let choices = choices(for: activity) {
                    ForEach(choices, id: \.self) { choice in
                        Button { draft(activity.id).wrappedValue = choice } label: {
                            HStack(spacing: 14) {
                                Image(systemName: drafts[activity.id] == choice ? "largecircle.fill.circle" : "circle")
                                    .foregroundStyle(Kit.accent)
                                Text(choice).font(.title3.weight(.medium)).foregroundStyle(Kit.ink)
                                Spacer()
                            }.padding(18).frame(minHeight: 54)
                                .background(drafts[activity.id] == choice ? Kit.soft : Kit.surface, in: RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(drafts[activity.id] == choice ? Kit.accent : Kit.secondary.opacity(0.25)))
                        }.buttonStyle(.plain).accessibilityAddTraits(drafts[activity.id] == choice ? .isSelected : [])
                            .accessibilityIdentifier("lesson.choice.\(choice)")
                    }
                } else {
                    TextField(activity.kind == "grammar" ? "Complete the sentence" : "Write your answer", text: draft(activity.id), axis: .vertical)
                    .lineLimit(2...6).padding(16)
                    .background(Kit.surface, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Kit.secondary.opacity(0.35)))
                    .focused($answering).disabled(isComplete)
                    .accessibilityIdentifier("lesson.response.\(activity.id)")
                    .dictation(draft(activity.id))
                }
                if !attempted, session.journey.practiceConditions?.retainedText != false, !drafts[activity.id, default: ""].isEmpty {
                    Text(session.journey.drafts?[activity.id] == drafts[activity.id] ? "Draft saved on this device" : "Saving draft…")
                        .font(.caption).foregroundStyle(Kit.secondary).accessibilityIdentifier("lesson.draft.status")
                }
                if let first = response?.unaidedText, first != drafts[activity.id] {
                    Text("First try: \(first)").font(.footnote).foregroundStyle(Kit.secondary)
                }
            }
            if attempted {
                KitCard {
                    Label(feedbackTitle(activity, response: response), systemImage: "checkmark.circle.fill").font(.headline)
                    if activity.kind == "guidedSpeaking" {
                        Text("Saved.").foregroundStyle(Kit.secondary)
                    }
                    if response?.answerRevealed == true, let answer = activity.answer {
                        Divider().padding(.vertical, 4)
                        Text("EXAMPLE").font(.caption.weight(.semibold)).foregroundStyle(Kit.accent)
                        Text(answer).font(.title3.weight(.medium)).textSelection(.enabled)
                            .accessibilityIdentifier("lesson.example")
                        if presentedLesson.id == "intro-01", presentedLesson.contentVersion == "4",
                           let help = RewardAssistanceContent.forActivity(activity.id) {
                            RewardAssistanceView(storage: storage, context: "\(presentedLesson.id)/\(presentedLesson.contentVersion)/\(activity.id)", hint: help.hint, example: help.example)
                        }
                        if let guide = IntroductionReviewGuide.bundled,
                           let review = guide.review(activityID: activity.id, lessonID: presentedLesson.id,
                               contentVersion: presentedLesson.contentVersion, revealed: response?.answerRevealed == true) {
                            IntroductionActivityReview(guide: guide, review: review)
                        }
                        if let explanation = activity.explanation {
                            Text(explanation).accessibilityIdentifier("lesson.explanation")
                        } else {
                            if activity.id == "grammar-be-am" { Text("With “I”, use “am”: I am a student.") }
                            if activity.id == "grammar-be-is" { Text("With “she” or “he”, use “is”.") }
                        }
                    } else if activity.answer != nil {
                        Button("Compare with an example") { reveal(activity.id) }
                            .accessibilityIdentifier("lesson.reveal.\(activity.id)")
                    }
                    if response?.answerRevealed == true || response?.recordedPracticeID != nil {
                        RewardSummary(storage: storage, sourcePrefix: "lesson/\(session.journey.id)/\(activity.id)", sourceTitle: "This activity")
                    }
                    Button("Save a retry") { record(activity.id, assisted: true) }.buttonStyle(.bordered)
                }
            }
        }
    }

    private var completion: some View {
        VStack(alignment: .leading, spacing: 24) {
            CoachArtwork(name: "TeacherGreeting").frame(height: 130).frame(maxWidth: .infinity)
            Text("A little more you, in English.").font(.title.bold()).lineLimit(1).minimumScaleFactor(0.6).accessibilityIdentifier("lesson.completed")
            Text("Lesson complete. Keep the words you want to revisit.")
                .font(.title3).foregroundStyle(Kit.secondary)
            if let session, let accuracy = session.exerciseAccuracy {
                KitCard {
                    Text("\(Int((accuracy * 100).rounded()))% right on the first try").font(.headline)
                        .accessibilityIdentifier("lesson.accuracy")
                    if !session.missedExercises.isEmpty {
                        Button("Try the \(session.missedExercises.count) you missed") { showMissed = true }
                            .buttonStyle(.bordered).accessibilityIdentifier("lesson.missed")
                    }
                }
            }
            RewardSummary(storage: storage, sourcePrefix: session.map { "lesson/\($0.journey.id)/" })
            vocabularyCard
            if presentedLesson.practiceActivities.contains(where: { $0.kind == "guidedSpeaking" }) {
                Button("Practice by speaking") { openSpeaking() }.buttonStyle(KitPrimaryButtonStyle())
                    .accessibilityIdentifier("lesson.speak")
            }
            Button("Practice this lesson again") { restart() }.buttonStyle(.bordered)
                .accessibilityIdentifier("lesson.repeat")
        }
    }

    private var vocabularyCard: some View {
        KitCard {
            Text("Keep the words").font(.title3.bold())
            ForEach(presentedLesson.senses) { sense in
                VStack(alignment: .leading, spacing: 8) {
                    Text(sense.lemma).font(.headline)
                    if let meaning = sense.meaning { Text(meaning).font(.callout).foregroundStyle(Kit.secondary) }
                    ViewThatFits(in: .horizontal) {
                        HStack { vocabularyActions(sense) }
                        VStack(alignment: .leading) { vocabularyActions(sense) }
                    }
                }.padding(.vertical, 8)
            }
        }
    }

    @ViewBuilder private func vocabularyActions(_ sense: CurriculumSense) -> some View {
        Button(savedSenseIDs.contains(sense.id) ? "In collection" : "Keep word") { enroll(sense, inReview: false) }
            .buttonStyle(.bordered).disabled(savedSenseIDs.contains(sense.id))
            .accessibilityIdentifier("lesson.collect.\(sense.senseId)")
        Button(reviewSenseIDs.contains(sense.id) ? "In review" : "Add to review") { enroll(sense, inReview: true) }
            .buttonStyle(.bordered).disabled(reviewSenseIDs.contains(sense.id))
            .accessibilityIdentifier("lesson.enroll.\(sense.senseId)")
    }

    @ViewBuilder private var footer: some View {
        if session != nil && !isComplete && typedActivity == nil {
            VStack(spacing: 12) {
                if showIntroduction {
                    Button("Let’s begin") { showIntroduction = false; message = nil }
                        .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("lesson.begin")
                } else if let activity, let session {
                    HStack(spacing: 16) {
                        Button { move(-1) } label: { Image(systemName: "arrow.left").frame(minWidth: 44, minHeight: 44) }
                            .buttonStyle(.bordered).disabled(position == 0).accessibilityLabel("Previous activity")
                        if !session.hasAttempt(for: activity.id) {
                            Button(choices(for: activity) == nil ? "Save my answer" : "Check answer") { record(activity.id, assisted: false) }
                                .buttonStyle(KitPrimaryButtonStyle())
                                .disabled(drafts[activity.id, default: ""].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                .accessibilityIdentifier("lesson.save.\(activity.id)")
                        } else if session.needsComparison(activity.id) {
                            Button("Compare the example") { reveal(activity.id) }
                                .buttonStyle(KitPrimaryButtonStyle())
                                .accessibilityIdentifier("lesson.review-required")
                        } else {
                            Button(position == session.activities.count - 1 ? "Finish lesson" : "Continue") {
                                if position == session.activities.count - 1 { finish() } else { move(1) }
                            }.buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier(position == session.activities.count - 1 ? "lesson.finish" : "lesson.next")
                        }
                    }
                }
            }
            .frame(maxWidth: 640).padding(.horizontal, 24).padding(.vertical, 14).frame(maxWidth: .infinity)
            .background(Kit.canvas(storage.preferences.background))
        }
    }

    private var contents: some View {
        NavigationStack {
            List {
                if origin == nil && !savedJourneys.isEmpty {
                    Section("Saved versions") {
                        ForEach(savedJourneys) { journey in
                            Button("Version \(journey.contentVersion) · \(journey.completedAt == nil ? "In progress" : "Completed")") {
                                openSaved(journey); showContents = false
                            }.accessibilityIdentifier("lesson.version.\(journey.contentVersion)")
                        }
                        Button("Start current version") { startCurrentVersion(); showContents = false }
                            .accessibilityIdentifier("lesson.version.current")
                    }
                }
                if let session {
                    ForEach(Array(session.activities.enumerated()), id: \.element.id) { index, item in
                        Button {
                            navigate(to: item.id); showIntroduction = false; showContents = false
                        } label: {
                            Label("\(index + 1). \(kindTitle(item.kind))", systemImage: session.hasAttempt(for: item.id) ? "checkmark.circle.fill" : "circle")
                        }.foregroundStyle(Kit.ink)
                            .accessibilityIdentifier("lesson.jump.\(item.id)")
                    }
                }
            }.navigationTitle("Your lesson")
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showContents = false } } }
        }.tint(Kit.accent)
    }

    private func kindTitle(_ kind: String) -> String {
        switch kind {
        case "reading": "Read & notice"
        case "listening": "Listen closely"
        case "grammar": "Build a sentence"
        case "recall": "Find the words"
        case "guidedSpeaking": "Make it personal"
        case "selfReview": "Reflect & improve"
        case "quietText": "Write it your way"
        default: "Practice"
        }
    }

    private func draft(_ id: String) -> Binding<String> {
        Binding(get: { drafts[id, default: ""] }, set: { value in
            drafts[id] = value
            draftSave?.cancel()
            draftSave = Task {
                do { try await Task.sleep(for: .milliseconds(400)) } catch { return }
                saveDrafts()
            }
        })
    }

    private func load() {
        guard session == nil else { return }
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let saved = try repository.lessonJourneys(lessonID: lesson.id).filter { $0.practiceOrigin?.journeyID == origin?.journeyID }
            savedJourneys = saved
            let opening = try install.opening(lesson, saved: saved)
            try open(opening.lesson, existing: opening.journey)
        } catch { message = "This saved content version could not be opened. Your work is preserved. Use Saved versions to retry or explicitly start the current version." }
    }

    private func open(_ exact: ResolvedLesson, existing: LessonJourney?) throws {
        guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
        var opened = try LessonSession.begin(lesson: exact, presenter: storage.preferences.coach.rawValue, now: .now, existing: existing)
        if existing == nil {
            opened.journey.practiceOrigin = origin
            opened.journey.practiceConditions = initialConditions
            try repository.saveLessonJourney(opened.journey)
        }
        savedJourneys = try repository.lessonJourneys(lessonID: lesson.id).filter { $0.practiceOrigin?.journeyID == origin?.journeyID }
        selectedLesson = exact; session = opened; drafts = opened.journey.drafts ?? [:]
        for response in opened.journey.responses where drafts[response.activityID] == nil {
            drafts[response.activityID] = response.assistedText ?? response.unaidedText
        }
        preserved = savedJourneys.last { $0.contentVersion != exact.contentVersion }
        showIntroduction = existing == nil
        message = nil; refreshWords(repository)
    }

    private func openSaved(_ journey: LessonJourney) {
        draftSave?.cancel(); guard saveDrafts() else { return }; stopAudio()
        guard let exact = install.lesson(id: journey.lessonID, version: journey.contentVersion), exact.objectiveId == journey.objectiveID else {
            message = "This exact content version is unavailable. Its saved work is preserved."; return
        }
        do { try open(exact, existing: journey) }
        catch { message = "Your saved work could not be opened. Try again after unlocking your device." }
    }

    private func startCurrentVersion() {
        draftSave?.cancel(); guard saveDrafts() else { return }; stopAudio()
        do { try open(lesson, existing: nil) }
        catch { message = "The current version could not be started. Your earlier work is kept." }
    }

    private func practiceChoice(_ keyPath: WritableKeyPath<CurriculumPracticeConditions, Bool>) -> Binding<Bool> {
        Binding(get: { session?.journey.practiceConditions?[keyPath: keyPath] ?? false }, set: { value in
            guard var updated = session, updated.journey.responses.isEmpty else { return }
            updated.journey.practiceConditions?[keyPath: keyPath] = value
            if keyPath == \.retainedText && !value { updated.journey.drafts = nil }
            do {
                guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
                try repository.saveLessonJourney(updated.journey); session = updated
            } catch { message = "Practice choices could not be saved. Try again." }
        })
    }

    private func openSpeaking() {
        guard saveDrafts(), let journey = session?.journey else { return }
        stopAudio(); answering = false
        if origin != nil {
            do { topicRecordingContext = try LessonSpeakingLink.context(lesson: presentedLesson, journey: journey, defaults: storage.preferences) }
            catch { message = "This speaking prompt could not be opened. Your practice is kept." }
        } else { onSpeak(presentedLesson, journey.id) }
    }

    private func openCurriculumPractice(_ kind: CurriculumPracticeKind) {
        guard let course = session?.journey, let practice = kind.lesson(from: presentedLesson) else { return }
        guard saveDrafts() else { return }; stopAudio()
        curriculumPractice = CurriculumPracticeRoute(lesson: practice,
            origin: LessonPracticeOrigin(journeyID: course.id, lessonID: course.lessonID, objectiveID: course.objectiveID),
            conditions: CurriculumPracticeConditions(purpose: kind.rawValue, sourceContentVersion: course.contentVersion,
                startedAt: .now, teachingBeganAt: course.teachingBeganAt, supported: false, retainedText: false,
                teachingMayHaveBeenSeen: true, rubricVersion: "\(course.objectiveID)-draft-1"))
    }

    private func applySpeakingCompletion() {
        guard let completion = storage.latestLessonSpeech, completion.lessonID == presentedLesson.id,
              let activity, activity.kind == "guidedSpeaking", var updated = session,
              completion.journeyID == updated.journey.id, completion.activityID == activity.id, !isComplete else { return }
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            try updated.recordSpeakingPractice(activityID: activity.id, completionID: completion.attemptID)
            try repository.saveLessonJourney(updated.journey)
            session = updated
            storage.latestLessonSpeech = nil
            message = "Speaking self-review completed. No acoustic assessment was made."
        } catch { message = "Your recording finished, but the lesson link could not be saved. Return here and try again." }
    }

    @discardableResult private func saveDrafts() -> Bool {
        guard var updated = session, !isComplete else { return true }
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            for (id, text) in drafts { try updated.saveDraft(text, for: id) }
            try repository.saveLessonJourney(updated.journey)
            session = updated
            return true
        } catch {
            message = "Your latest changes could not be saved. Keep this lesson open and try again after unlocking your device."
            return false
        }
    }

    private func applyInitialFocus() {
        guard !didApplyInitialFocus, let initialFocus, session != nil else { return }
        didApplyInitialFocus = true
        focus(initialFocus)
    }

    private func focus(_ difficulty: ObservedDifficulty) {
        switch difficulty {
        case .grammar:
            openPractice(.grammarian)
            message = "You chose grammar: compare and repair subject–verb patterns in separate practice."
        case .followUp:
            openPractice(.journalist)
            message = "You chose follow-ups: practise connected questions and source facts."
        case .retrieval, .clarity:
            guard let course = session?.journey,
                  let target = session?.activities.first(where: {
                      difficulty == .retrieval ? ($0.kind == "recall" || $0.kind == "vocabularyRecall") : $0.kind == "listening"
                  }) else { message = "This focus is unavailable in the saved content version. Your work is preserved."; return }
            // A separate journal keeps the original course, first answers and completion intact.
            let focused = ResolvedLesson(id: "\(presentedLesson.id)-focus-\(difficulty.rawValue)", level: presentedLesson.level,
                title: difficulty.title, objectiveId: "\(presentedLesson.objectiveId)/focus-\(difficulty.rawValue)",
                contentVersion: presentedLesson.contentVersion, availability: .ready, practiceActivities: [target], senses: presentedLesson.senses)
            curriculumPractice = CurriculumPracticeRoute(lesson: focused,
                origin: LessonPracticeOrigin(journeyID: course.id, lessonID: course.lessonID, objectiveID: course.objectiveID, activityID: target.id),
                conditions: CurriculumPracticeConditions(purpose: "focus-\(difficulty.rawValue)", sourceContentVersion: course.contentVersion,
                    startedAt: .now, teachingBeganAt: course.teachingBeganAt, supported: true, retainedText: false,
                    teachingMayHaveBeenSeen: true))

        }
    }

    private func openCheck(_ kind: IntroCheckKind) {
        guard var updated = session else { return }
        answering = false; stopAudio(); draftSave?.cancel()
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            for (id, text) in drafts { try updated.saveDraft(text, for: id) }
            try repository.saveLessonJourney(updated.journey)
            session = updated; message = nil; checkKind = kind
        } catch { message = "Your course place could not be saved. Keep this lesson open and retry." }
    }

    private func openPractice(_ pack: IntroPracticePack) {
        guard var updated = session else { return }
        answering = false; stopAudio(); draftSave?.cancel()
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            for (id, text) in drafts { try updated.saveDraft(text, for: id) }
            try repository.saveLessonJourney(updated.journey)
            session = updated; message = nil; practicePack = pack
        } catch { message = "Your course place could not be saved. Keep this lesson open and retry." }
    }

    private func navigate(to id: String) {
        guard var updated = session else { return }
        answering = false; stopAudio(); draftSave?.cancel()
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            for (id, text) in drafts { try updated.saveDraft(text, for: id) }
            try updated.move(to: id)
            try repository.saveLessonJourney(updated.journey)
            session = updated; message = nil
        } catch { message = "The next activity could not be saved. Your current answer is still here." }
    }

    private func move(_ offset: Int) {
        guard let session, session.activities.indices.contains(position + offset) else { return }
        navigate(to: session.activities[position + offset].id)
    }

    private func record(_ id: String, assisted: Bool) {
        guard var updated = session else { return }
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            try updated.record(activityID: id, text: drafts[id, default: ""], assisted: assisted)
            try updated.saveDraft(drafts[id, default: ""], for: id)
            try repository.saveLessonJourney(updated.journey)
            session = updated; answering = false; message = nil
            if let item = updated.activities.first(where: { $0.id == id }), choices(for: item) != nil { reveal(id) }
        } catch { message = "Your answer could not be saved. Keep it here and try again." }
    }

    /// Saves an auto-checked answer as the activity's response. The result is recomputed from it when needed.
    private func submitExercise(_ id: String, _ stored: String) -> Bool {
        guard session != nil else { return false }
        drafts[id] = stored
        record(id, assisted: false)
        return message == nil
    }

    private func reveal(_ id: String) {
        guard var updated = session else { return }
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            _ = try updated.revealAnswer(activityID: id)
            try repository.saveLessonJourney(updated.journey)
            session = updated; answering = false; message = nil
        } catch { message = "The example could not be opened. Save an answer first, then try again." }
    }

    private func enroll(_ sense: CurriculumSense, inReview: Bool) {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            _ = try repository.enrollVocabulary(sense, lesson: presentedLesson, inReview: inReview)
            refreshWords(repository)
            message = inReview ? "Added to review. No rating has been made." : "Kept in your collection. Add it to review whenever you like."
        } catch { message = "The word could not be saved. Try again after unlocking your device." }
    }

    private func refreshWords(_ repository: LearnerRepository) {
        let saved = (try? repository.vocabularyEnrollments()) ?? []
        savedSenseIDs = Set(saved.map(\.id)); reviewSenseIDs = Set(saved.filter(\.inReview).map(\.id))
    }

    private func finish() {
        guard var updated = session else { return }
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            try updated.finish(now: .now)
            try repository.saveLessonJourney(updated.journey)
            session = updated; message = nil; stopAudio()
        } catch LessonProgressError.unfinished {
            message = "There are still activities to try. Open the activity list to find them."
        } catch { message = "Completion could not be saved. Your earlier answers are kept." }
    }

    private func restart() {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let fresh = try LessonSession.begin(lesson: presentedLesson, presenter: storage.preferences.coach.rawValue, now: .now)
            try repository.saveLessonJourney(fresh.journey)
            session = fresh; drafts = [:]; showIntroduction = true; message = nil
        } catch { message = "A new practice could not be started. Your completed attempt is kept." }
    }

    private func play(_ path: String) {
        do {
            stopAudio()
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
            clip = try AVAudioPlayer(contentsOf: Bundle.main.bundleURL.appendingPathComponent(path))
            guard clip?.play() == true else { throw LearnerStorageError.unavailable }
        } catch { message = "This recording could not be played. You can retry or continue with text practice." }
    }

    private func stopAudio() {
        guard clip != nil else { return }
        clip?.stop(); clip = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func choices(for activity: CurriculumActivity) -> [String]? {
        if let choices = activity.choiceSet { return choices }
        guard isIntroduction else { return nil }
        switch activity.id {
        case "grammar-be-am", "grammar-be-is": return ["am", "is", "are"]
        case "grammar-study": return ["study", "studies", "studying"]
        case "grammar-works": return ["work", "works", "working"]
        case "grammar-do": return ["Do", "Does", "Is"]
        default: return nil
        }
    }

    private func feedbackTitle(_ activity: CurriculumActivity, response: LessonResponse?) -> String {
        guard choices(for: activity) != nil else { return "Your practice is saved" }
        let answer = response?.assistedText ?? response?.unaidedText
        return answer?.lowercased() == activity.answer?.lowercased() ? "That fits the sentence" : "Let’s look at the pattern"
    }
}
