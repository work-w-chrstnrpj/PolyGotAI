import SwiftUI
import UIKit

enum AppDestination: String, CaseIterable, Identifiable {
    case today, vocabulary, learn, speechLab, progress
    var id: String { rawValue }
    var title: String {
        switch self { case .today: "Today"; case .vocabulary: "Lexicon"; case .learn: "Lesson"; case .speechLab: "Speech Lab"; case .progress: "Progress" }
    }
    var symbol: String {
        switch self { case .today: "sun.max"; case .vocabulary: "square.stack"; case .learn: "book"; case .speechLab: "waveform"; case .progress: "chart.bar" }
    }
}

private struct RecordingPresentation: Identifiable {
    var context: PracticeSessionContext
    var id: UUID { context.id }
}

struct AppShell: View {
    @Environment(\.scenePhase) private var rewardScene
    @Bindable var storage: LearnerStorageController
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var destination: AppDestination = .today
    @State private var showSettings = false
    @State private var recordingPresentation: RecordingPresentation?
    @State private var practiceContext: PracticeSessionContext?

    var body: some View {
        ZStack {
            // Sheets stay on this unchanging anchor. Attaching them to the
            // tab/sidebar switch dismisses an active take when rotation
            // changes the horizontal size class.
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .sheet(item: $recordingPresentation, onDismiss: {
                    practiceContext = PracticeSessionContext(defaults: storage.preferences)
                }) { presentation in
                    RecordingView(storage: storage, context: presentation.context)
                        .presentationDetents([.large])
                }
                .sheet(isPresented: $showSettings) {
                    NavigationStack { SettingsView(storage: storage) }
                        .tint(Kit.accent)
                        .preferredColorScheme(storage.preferences.appearance.colorScheme)
                        .presentationDetents([.large])
                }

            adaptiveNavigation
                .tint(Kit.accent)
                .preferredColorScheme(storage.preferences.appearance.colorScheme)
        }.onChange(of: rewardScene) { _, phase in storage.rewardEngagement.setActive(phase == .active) }
    }

    /// iPhone: the system tab bar. iPad: one bottom bar in portrait and a sidebar in landscape. Both iPad chromes
    /// wrap the same TabView, so rotating keeps the selected tab and every open screen.
    private var usesCustomChrome: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    private var adaptiveNavigation: some View {
        GeometryReader { proxy in
            let showsSidebar = usesCustomChrome && sizeClass == .regular && proxy.size.width > proxy.size.height
            HStack(spacing: 0) {
                if showsSidebar {
                    sidebar
                    Divider()
                }
                VStack(spacing: 0) {
                    TabView(selection: $destination) {
                        ForEach(AppDestination.allCases) { item in
                            navigationContent(item)
                                .tabItem { Label(item.title, systemImage: item.symbol) }
                                .tag(item)
                        }
                    }
                    if usesCustomChrome && !showsSidebar { bottomBar }
                }
            }
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SpeechCoachAI").font(.title2.bold()).padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 12)
            ForEach(AppDestination.allCases) { item in
                Button { destination = item } label: {
                    Label(item.title, systemImage: item.symbol)
                        .font(.body)
                        .foregroundStyle(destination == item ? Color("OnAccent") : Kit.ink)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            destination == item ? Kit.accent : Color.clear,
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
                .accessibilityIdentifier("navigation.\(item.rawValue)")
                .accessibilityAddTraits(destination == item ? .isSelected : [])
            }
            Spacer()
        }
        .frame(width: 280)
        .background(Kit.canvas(storage.preferences.background))
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                ForEach(AppDestination.allCases) { item in
                    Button { destination = item } label: {
                        VStack(spacing: 4) {
                            Image(systemName: item.symbol).font(.title3).frame(height: 26)
                            Text(item.title).font(.caption2.weight(.medium))
                        }
                        .foregroundStyle(destination == item ? Kit.accent : Kit.secondary)
                        .frame(maxWidth: .infinity, minHeight: 49)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item.title)
                    .accessibilityIdentifier("navigation.\(item.rawValue)")
                    .accessibilityAddTraits(destination == item ? [.isButton, .isSelected] : .isButton)
                }
            }
            .padding(.top, 6)
        }
        .background(Kit.canvas(storage.preferences.background).ignoresSafeArea(edges: .bottom))
    }

    private func navigationContent(_ item: AppDestination) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if storage.hasStorageFailure {
                        AvailabilityCard(title: "Local data unavailable", detail: "Unlock your device and try again. Your existing data has been kept.", symbol: "exclamationmark.triangle")
                            .accessibilityIdentifier("storage.unavailable")
                        Button("Try Again") { storage.open() }.buttonStyle(.borderedProminent)
                    }
                    switch item {
                    case .today: TodayContent(storage: storage, install: CurriculumCatalogLoader.bundled, openSpeech: { destination = .speechLab }, openSpeaking: openLessonSpeaking)
                    case .learn: LearnContent(storage: storage, install: CurriculumCatalogLoader.bundled, openSpeaking: openLessonSpeaking)
                    case .vocabulary: CustomTopicList(storage: storage)
                    case .speechLab: SpeechLabContent(storage: storage, context: $practiceContext, openRecording: {
                        recordingPresentation = RecordingPresentation(context: practiceContext ?? PracticeSessionContext(defaults: storage.preferences))
                    })
                    case .progress:
                        ProgressOverview(storage: storage, install: CurriculumCatalogLoader.bundled)
                        PracticeHistoryContent(storage: storage)
                    }
                }
                .frame(maxWidth: 700, alignment: .leading)
                .padding(20)
                .frame(maxWidth: .infinity)
            }
            .background(Kit.canvas(storage.preferences.background))
            .foregroundStyle(Kit.ink)
            .navigationTitle(item.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(usesCustomChrome ? .hidden : .visible, for: .tabBar)
            .toolbarBackground(Kit.canvas(storage.preferences.background), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: { Image(systemName: "person.crop.circle") }
                        .accessibilityLabel("Profile and settings")
                        .accessibilityIdentifier("settings.open")
                }
            }
            .accessibilityIdentifier("screen.\(item.rawValue)")
        }
    }

    private func openLessonSpeaking(_ lesson: ResolvedLesson, journeyID: UUID) {
        guard let journey = try? storage.repository?.lessonJourneys(lessonID: lesson.id).first(where: { $0.id == journeyID }),
              let context = try? LessonSpeakingLink.context(lesson: lesson, journey: journey, defaults: storage.preferences)
        else { return }
        practiceContext = context
        recordingPresentation = RecordingPresentation(context: context)
    }

}

private struct TodayContent: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    var openSpeech: () -> Void
    var openSpeaking: (ResolvedLesson, UUID) -> Void
    @Environment(\.dynamicTypeSize) private var textSize
    @State private var journeys: [LessonJourney] = []
    @State private var suggestion: PracticeSuggestion?
    @State private var dueCount = 0
    @State private var displayedDate = Date.now
    @Environment(\.scenePhase) private var scenePhase

    private var resuming: Bool {
        PracticeRecommendation.selectLesson(journeys: journeys, lessons: install.lessons, archivedLessons: install.archivedLessons).resuming
    }

    var body: some View {
        Text(displayedDate.formatted(.dateTime.weekday(.wide).day().month(.wide)))
            .font(.caption.weight(.medium)).foregroundStyle(Kit.secondary)
        if textSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 12) { artwork; greeting }
        } else { HStack(spacing: 14) { artwork; greeting } }
        KitCard {
            if let suggestion {
                Text("UP NEXT").font(.caption.weight(.semibold)).foregroundStyle(Kit.accent)
                Text(install.lessons.first(where: { $0.id == suggestion.lessonID })?.title ?? suggestion.title)
                    .font(.title2.bold()).padding(.bottom, 8)
                    .accessibilityIdentifier("today.focus")
                primaryAction(suggestion)
            } else {
                Text("Your practice didn't load.").font(.headline)
                Button("Try again", action: reload).buttonStyle(.bordered)
            }
        }
        if dueCount > 0, suggestion?.action != .reviewWords {
            NavigationLink { VocabularyRecallSession(storage: storage) } label: {
                KitCard { KitContentRow(symbol: "square.stack", title: "Review words", detail: "\(dueCount) due", showsChevron: true) }
            }.buttonStyle(.plain).accessibilityIdentifier("today.review-row")
        }
        RewardSummary(storage: storage)
            .onAppear(perform: reload)
            .onChange(of: storage.repository != nil) { _, _ in reload() }
            .onChange(of: scenePhase) { _, phase in if phase == .active { reload() } }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in reload() }
            .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in reload() }
    }

    @ViewBuilder private func primaryAction(_ suggestion: PracticeSuggestion) -> some View {
        switch suggestion.action {
        case .openLesson:
            if let lesson = install.lessons.first(where: { $0.isReady && $0.id == suggestion.lessonID }) {
                NavigationLink {
                    LessonPlayerView(storage: storage, lesson: lesson, install: install, initialFocus: suggestion.focus, onSpeak: openSpeaking)
                } label: { Text(resuming ? "Continue" : "Start") }
                    .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("today.lesson")
            }
        case .reviewWords:
            NavigationLink { VocabularyRecallSession(storage: storage) } label: { Text("Review") }
                .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("today.recall")
        case .speechLab:
            Button("Open Speech Lab", action: openSpeech)
                .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("today.primary.speechLab")
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("A little practice. A little braver.").font(.title3.bold()).lineLimit(1).minimumScaleFactor(0.7)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    private var artwork: some View {
        CoachArtwork(name: storage.preferences.coach == .elephantTeacher ? "TeacherGreeting" : storage.preferences.coach.portrait)
            .frame(width: 64, height: 76)
    }
    private func reload() {
        displayedDate = .now
        journeys = (try? storage.repository?.allLessonJourneys()) ?? []
        guard let repository = storage.repository else {
            suggestion = nil
            return
        }
        dueCount = (try? repository.reviewQueue().due.count) ?? 0
        suggestion = try? repository.practiceSuggestion(install: install)
    }
}

private struct LearnContent: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    var openSpeaking: (ResolvedLesson, UUID) -> Void
    @State private var level = "A1"
    @State private var journeys: [LessonJourney] = []
    private static let levels = ["A1", "A2", "B1", "B2", "C1", "C2"]
    private var lessons: [ResolvedLesson] { install.lessons(at: level).filter(\.isReady) }

    var body: some View {
        Text("Pick a level and start anywhere.").foregroundStyle(Kit.secondary)
        Picker("English level", selection: $level) {
            ForEach(Self.levels, id: \.self) { Text($0).tag($0) }
        }.pickerStyle(.segmented).accessibilityIdentifier("learn.level")
        LazyVStack(spacing: 12) {
            ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                NavigationLink {
                    LessonPlayerView(storage: storage, lesson: lesson, install: install, onSpeak: openSpeaking)
                } label: {
                    KitCard {
                        KitContentRow(symbol: statusSymbol(lesson), title: lesson.title,
                                      detail: "\(index + 1). \(status(lesson))", showsChevron: true)
                    }
                }.buttonStyle(.plain).accessibilityIdentifier("learn.open.\(lesson.id)")
            }
        }
        .accessibilityIdentifier("learn.availability")
        NavigationLink { ResourceLibraryView(storage: storage) } label: {
            KitCard { KitContentRow(symbol: "bookmark", title: "Learning resources", detail: "Links and notes", showsChevron: true) }
        }.buttonStyle(.plain).accessibilityIdentifier("learn.resources")
            .onAppear { journeys = (try? storage.repository?.allLessonJourneys()) ?? [] }
    }
    private func latest(_ lesson: ResolvedLesson) -> LessonJourney? {
        journeys.last { $0.lessonID == lesson.id && $0.completedAt == nil } ?? journeys.last { $0.lessonID == lesson.id && $0.contentVersion == lesson.contentVersion }
    }
    private func status(_ lesson: ResolvedLesson) -> String {
        guard let current = latest(lesson) else { return "New" }
        return current.completedAt == nil ? "In progress" : "Completed"
    }
    private func statusSymbol(_ lesson: ResolvedLesson) -> String {
        guard let current = latest(lesson) else { return "book" }
        return current.completedAt == nil ? "play.circle" : "checkmark.circle.fill"
    }
}

struct SpeechLabContent: View {
    var storage: LearnerStorageController
    @Binding var context: PracticeSessionContext?
    @Environment(\.dynamicTypeSize) private var textSize
    var openRecording: () -> Void
    var body: some View {
        if textSize.isAccessibilitySize {
            VStack(alignment: .leading) { CoachArtwork(name: "SpeakerWelcome").frame(height: 88); heading }
        } else {
            HStack(spacing: 14) { CoachArtwork(name: "SpeakerWelcome").frame(width: 64, height: 68); heading }
        }
        Button(action: openRecording) {
            KitCard { KitContentRow(symbol: "mic", title: "Record an introduction", detail: "Record, replay, review", showsChevron: true) }
        }.buttonStyle(.plain).accessibilityIdentifier("speech.record")
        NavigationLink {
            ConversationPracticeView(storage: storage, presenterID: (context?.effectiveCoach ?? storage.preferences.coach).rawValue)
        } label: {
            KitCard { KitContentRow(symbol: "bubble.left.and.bubble.right", title: "Conversation", detail: "Talk through a scenario", showsChevron: true) }
        }.buttonStyle(.plain).accessibilityIdentifier("speech.conversation")
        NavigationLink {
            InterviewPracticeView(storage: storage, presenterID: (context?.effectiveCoach ?? storage.preferences.coach).rawValue)
        } label: {
            KitCard { KitContentRow(symbol: "person.2", title: "Interview", detail: "Answer common questions", showsChevron: true) }
        }.buttonStyle(.plain).accessibilityIdentifier("speech.interview")
        NavigationLink {
            CommunicationPracticeLauncher(storage: storage)
        } label: {
            KitCard { KitContentRow(symbol: "text.bubble", title: "Communication", detail: "Structure what you say", showsChevron: true) }
        }.buttonStyle(.plain).accessibilityIdentifier("speech.communication")
        NavigationLink("Saved practice") {
            ScrollView { PracticeHistoryContent(storage: storage).padding(20) }.navigationTitle("Your practice")
        }
        .onAppear { if context == nil { context = PracticeSessionContext(defaults: storage.preferences) } }
    }
    private var heading: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Speak a little. Grow a lot.").font(.title3.bold()).lineLimit(1).minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
