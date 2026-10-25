import SwiftUI

/// Course gating is evaluated on every render, including after returning from a jump test.
struct CourseCatalogView: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    var onSpeak: (ResolvedLesson, UUID) -> Void
    @Binding var level: String
    @State private var journeys: [LessonJourney] = []
    @State private var showTest = false
    @State private var testTarget = "A2"
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        let gate = storage.levelGate(install: install)
        VStack(alignment: .leading, spacing: 16) {
            if textSize.isAccessibilitySize {
                levelPicker(gate).pickerStyle(.menu)
            } else {
                levelPicker(gate).pickerStyle(.segmented)
            }
            if gate.isUnlocked(level) {
                LazyVStack(spacing: 12) {
                    ForEach(install.lessons(at: level).filter(\.isReady)) { lesson in
                        NavigationLink {
                            LessonPlayerView(storage: storage, lesson: lesson, install: install, onSpeak: onSpeak)
                        } label: {
                            KitCard { CourseLessonRow(lesson: lesson, journeys: journeys) }
                        }
                        .buttonStyle(.plain).accessibilityIdentifier("learn.open.\(lesson.id)")
                    }
                }.accessibilityIdentifier("learn.availability")
            } else {
                KitCard {
                    Label(level, systemImage: "lock.fill").font(.title2.bold())
                        .accessibilityLabel("\(level), locked")
                    if gate.canTakeJumpTest(to: level) {
                        Button("Take the \(level) test") {
                            testTarget = level
                            showTest = true
                        }
                        .buttonStyle(KitPrimaryButtonStyle())
                        .accessibilityIdentifier("level.test.\(level)")
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("level.locked.\(level)")
            }
            NavigationLink { ResourceLibraryView(storage: storage) } label: {
                KitCard { KitContentRow(symbol: "bookmark", title: "Learning resources", detail: "Links and notes", showsChevron: true) }
            }.buttonStyle(.plain).accessibilityIdentifier("learn.resources")
        }
        // Keep the destination registered when a pass replaces the locked card with lesson rows.
        .navigationDestination(isPresented: $showTest) {
            JumpTestView(storage: storage, install: install, target: testTarget)
        }
        .onAppear { journeys = (try? storage.repository?.allLessonJourneys()) ?? [] }
    }

    private func levelPicker(_ gate: LevelGate) -> some View {
        Picker("English level", selection: $level) {
            ForEach(LevelGate.levels, id: \.self) { value in
                Text(gate.isUnlocked(value) ? value : "\(value) 🔒")
                    .accessibilityLabel(gate.isUnlocked(value) ? value : "\(value), locked")
                    .tag(value)
            }
        }.accessibilityIdentifier("learn.level")
    }
}

struct CourseLessonRow: View {
    var lesson: ResolvedLesson
    var journeys: [LessonJourney]
    private var progress: LessonProgress { .of(lesson, journeys: journeys) }
    private var stateTitle: String {
        switch progress.state { case .new: "New"; case .inProgress: "In progress"; case .done: "Done" }
    }
    private var symbol: String {
        switch progress.state { case .new: "book"; case .inProgress: "play.circle"; case .done: "checkmark.circle.fill" }
    }
    var body: some View {
        KitContentRow(symbol: symbol, title: lesson.title,
                      detail: progress.accuracy.map { "\(stateTitle) · \(Int(($0 * 100).rounded()))% accuracy" } ?? stateTitle,
                      showsChevron: true)
    }
}
