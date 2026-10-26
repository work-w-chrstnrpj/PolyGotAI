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
                        .environment(\.kitTheme, KitTheme(storage.preferences.background))
                        .tint(KitTheme(storage.preferences.background).accent)
                        .preferredColorScheme(storage.preferences.appearance.colorScheme)
                        .presentationDetents([.large])
                }

            // Rebuilt when the theme changes so every `Kit` colour resolves against the new theme.
            adaptiveNavigation
                .id(storage.preferences.background)
                .environment(\.kitTheme, KitTheme(storage.preferences.background))
                .tint(KitTheme(storage.preferences.background).accent)
                .preferredColorScheme(storage.preferences.appearance.colorScheme)
        }
        // Every sheet and cover below inherits the theme, including the recording sheet on the anchor.
        .environment(\.kitTheme, KitTheme(storage.preferences.background))
        .onChange(of: rewardScene) { _, phase in storage.rewardEngagement.setActive(phase == .active) }
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
            Text("SpeechCoachAI").font(.title2.bold())
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge).lineLimit(1).minimumScaleFactor(0.8)
                .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 12)
            ForEach(AppDestination.allCases) { item in
                Button { destination = item } label: {
                    Label(item.title, systemImage: item.symbol)
                        .font(.body)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundStyle(destination == item ? Kit.onAccent : Kit.ink)
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
                            Image(systemName: item.symbol).font(.title3)
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge).frame(height: 26)
                            Text(item.title).font(.caption2.weight(.medium))
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                .lineLimit(1).minimumScaleFactor(0.8)
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
                    case .today: TodayView(storage: storage, install: CurriculumCatalogLoader.bundled, openSpeaking: openLessonSpeaking)
                    case .learn: LearnContent(storage: storage, install: CurriculumCatalogLoader.bundled, openSpeaking: openLessonSpeaking)
                    case .vocabulary: LexiconHome(storage: storage)
                    case .speechLab: SpeechLabContent(storage: storage, context: $practiceContext)
                    case .progress:
                        ProgressOverview(storage: storage, install: CurriculumCatalogLoader.bundled)
                    }
                }
                .frame(maxWidth: 700, alignment: .leading)
                .padding(20)
                .frame(maxWidth: .infinity)
            }
            .background(Kit.canvas(storage.preferences.background))
            .foregroundStyle(Kit.ink)
            .navigationTitle(item.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar(usesCustomChrome ? .hidden : .visible, for: .tabBar)
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

private struct LearnContent: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    var openSpeaking: (ResolvedLesson, UUID) -> Void
    @SceneStorage("learn.mode") private var mode = "course"
    @State private var level = "A1"

    var body: some View {
        Text("Build your English.").foregroundStyle(Kit.secondary).lineLimit(1).minimumScaleFactor(0.7)
        Picker("Lesson mode", selection: $mode) {
            Text("Course").tag("course")
            Text("Coaches").tag("coaches")
        }.pickerStyle(.segmented).accessibilityIdentifier("learn.mode")
        if mode == "coaches" {
            CoachCatalogView(storage: storage, install: install, onSpeak: openSpeaking)
        } else {
            CourseCatalogView(storage: storage, install: install, onSpeak: openSpeaking, level: $level)
        }
    }
}

struct SpeechLabContent: View {
    var storage: LearnerStorageController
    @Binding var context: PracticeSessionContext?
    @Environment(\.dynamicTypeSize) private var textSize
    var body: some View {
        if textSize.isAccessibilitySize {
            VStack(alignment: .leading) { CoachArtwork(name: "SpeakerWelcome").frame(height: 88); heading }
        } else {
            HStack(spacing: 14) { CoachArtwork(name: "SpeakerWelcome").frame(width: 64, height: 68); heading }
        }
        NavigationLink {
            SpeechLabDictationView(storage: storage)
        } label: {
            KitCard { KitContentRow(symbol: "headphones", title: "Dictation", detail: "Listen and write", showsChevron: true) }
        }.buttonStyle(.plain).accessibilityIdentifier("speech.dictation")
        NavigationLink {
            SpeechLabPronunciationView(storage: storage)
        } label: {
            KitCard { KitContentRow(symbol: "character.phonetic", title: "Pronunciation", detail: "Sounds and clear speech", showsChevron: true) }
        }.buttonStyle(.plain).accessibilityIdentifier("speech.pronunciation")
        NavigationLink {
            SpeechLabVoiceView(storage: storage)
        } label: {
            KitCard { KitContentRow(symbol: "waveform.path", title: "Speaking", detail: "Pace, pauses and volume", showsChevron: true) }
        }.buttonStyle(.plain).accessibilityIdentifier("speech.speaking")
        if !SpeechLabCatalog.bundled.interview.isEmpty {
            NavigationLink {
                HandsFreeInterviewView(storage: storage)
            } label: {
                KitCard { KitContentRow(symbol: "person.2", title: "Interview", detail: "Answer common questions", showsChevron: true) }
            }.buttonStyle(.plain).accessibilityIdentifier("speech.interview")
        }
        NavigationLink {
            ConversationPracticeView(storage: storage, presenterID: (context?.effectiveCoach ?? storage.preferences.coach).rawValue)
        } label: {
            KitCard { KitContentRow(symbol: "bubble.left.and.bubble.right", title: "Conversation", detail: "Talk through a scenario", showsChevron: true) }
        }.buttonStyle(.plain).accessibilityIdentifier("speech.conversation")
        if ((try? storage.repository?.labFeedbackHistory()) ?? []).isEmpty == false {
            NavigationLink("Feedback history") { LabFeedbackHistoryView(storage: storage) }.accessibilityIdentifier("speech.feedbackHistory")
        }
        NavigationLink("Saved practice") {
            ScrollView { PracticeHistoryContent(storage: storage).padding(20) }.navigationTitle("Your practice")
        }
        .onAppear { if context == nil { context = PracticeSessionContext(defaults: storage.preferences) } }
        SpeechLabInfoButton()
    }
    private var heading: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Speak a little. Grow a lot.").font(.title3.bold()).lineLimit(1).minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
