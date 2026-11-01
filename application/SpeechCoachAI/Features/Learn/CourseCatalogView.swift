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
                let lessons = install.lessons(at: level).filter(\.isReady)
                RankSummaryCard(level: level, lessons: lessons, journeys: journeys)
                LazyVStack(spacing: 12) {
                    ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                        NavigationLink {
                            LessonPlayerView(storage: storage, lesson: lesson, install: install, onSpeak: onSpeak)
                        } label: {
                            KitCard { CourseLessonRow(lesson: lesson, journeys: journeys, number: index + 1) }
                        }
                        .buttonStyle(.kitCard).accessibilityIdentifier("learn.open.\(lesson.id)")
                    }
                }.accessibilityIdentifier("learn.availability")
            } else {
                KitCard {
                    HStack(spacing: 14) {
                        IconBadge(symbol: "lock.fill", tint: Kit.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(level).font(.title2.bold())
                            Text(RankSummaryCard.name(level)).font(.subheadline).foregroundStyle(Kit.secondary)
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(level), locked")
                    if let previous = JumpTest.checkedLevel(for: level), let progress = gate.progressToward(level) {
                        // Natural unlock: every lesson of the level before, at 50% or more on the first try.
                        Text("\(progress.done) of \(progress.total) \(previous) lessons done at 50%+")
                            .font(.subheadline).foregroundStyle(Kit.secondary)
                            .accessibilityIdentifier("level.progress.\(level)")
                        KitProgressBar(value: Double(progress.done) / Double(max(progress.total, 1)))
                    }
                    if gate.canTakeJumpTest(to: level), let checked = JumpTest.checkedLevel(for: level) {
                        Text("Or skip ahead: a test on \(checked)").font(.subheadline).foregroundStyle(Kit.secondary)
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
            }.buttonStyle(.kitCard).accessibilityIdentifier("learn.resources")
        }
        // Keep the destination registered when a pass replaces the locked card with lesson rows.
        .navigationDestination(isPresented: $showTest) {
            JumpTestView(storage: storage, install: install, target: testTarget)
        }
        .onAppear { journeys = (try? storage.repository?.allLessonJourneys()) ?? [] }
    }

    private func levelPicker(_ gate: LevelGate) -> some View {
        Picker("Rank", selection: $level) {
            ForEach(LevelGate.levels, id: \.self) { value in
                Text(gate.isUnlocked(value) ? value : "\(value) 🔒")
                    .accessibilityLabel(gate.isUnlocked(value) ? value : "\(value), locked")
                    .tag(value)
            }
        }.accessibilityIdentifier("learn.level")
    }
}

/// The rank's name and how many of its lessons are done, above the lesson list.
struct RankSummaryCard: View {
    var level: String
    var lessons: [ResolvedLesson]
    var journeys: [LessonJourney]

    static func name(_ level: String) -> String {
        switch level {
        case "A1": "Beginner"
        case "A2": "Elementary"
        case "B1": "Intermediate"
        case "B2": "Upper intermediate"
        case "C1": "Advanced"
        case "C2": "Proficient"
        default: ""
        }
    }

    var body: some View {
        let done = lessons.filter { LessonProgress.of($0, journeys: journeys).state == .done }.count
        HStack(spacing: Kit.Space.l) {
            Text(level).font(.system(.title2, design: .rounded).weight(.heavy))
                .foregroundStyle(Kit.onAccent)
                .frame(width: 56, height: 56)
                .background(Kit.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            VStack(alignment: .leading, spacing: 6) {
                Text(Self.name(level)).font(.headline).foregroundStyle(Kit.ink)
                Text("\(done) of \(lessons.count) lessons done").font(.subheadline).foregroundStyle(Kit.secondary)
                KitProgressBar(value: Double(done) / Double(max(lessons.count, 1)))
            }
        }
        .padding(Kit.Space.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kitSurface()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(level), \(Self.name(level))")
        .accessibilityValue("\(done) of \(lessons.count) lessons done")
        .accessibilityIdentifier("learn.rank.summary")
    }
}

struct CourseLessonRow: View {
    var lesson: ResolvedLesson
    var journeys: [LessonJourney]
    /// Position in its list; shown on the node of a lesson not started yet.
    var number: Int? = nil
    private var progress: LessonProgress { .of(lesson, journeys: journeys) }
    private var stateTitle: String {
        switch progress.state { case .new: "New"; case .inProgress: "In progress"; case .done: "Done" }
    }
    private var symbol: String {
        switch progress.state { case .new: "book"; case .inProgress: "play.circle"; case .done: "checkmark.circle.fill" }
    }
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            LessonNode(state: progress.state, number: number, fallbackSymbol: symbol)
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title).font(.headline).foregroundStyle(Kit.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(progress.accuracy.map { "\(stateTitle) · \(Int(($0 * 100).rounded()))% accuracy" } ?? stateTitle)
                    .font(.subheadline).foregroundStyle(progress.state == .done ? Kit.success : Kit.secondary)
            }.frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(Kit.secondary)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge).accessibilityHidden(true)
        }
        .padding(.vertical, 4).frame(minHeight: 44)
    }
}

/// A lesson's state as a round node: its number when new, a play ring when started, a check when done.
struct LessonNode: View {
    var state: LessonProgress.State
    var number: Int?
    var fallbackSymbol: String
    @ScaledMetric(relativeTo: .headline) private var side = 40.0

    var body: some View {
        let size = min(side, 56)
        ZStack {
            switch state {
            case .done:
                Circle().fill(Kit.success.gradient)
                Image(systemName: "checkmark").font(.system(size: size * 0.4, weight: .bold)).foregroundStyle(Kit.surface)
            case .inProgress:
                Circle().fill(Kit.accent.opacity(0.12))
                Circle().strokeBorder(Kit.accent, lineWidth: 2.5)
                Image(systemName: "play.fill").font(.system(size: size * 0.34, weight: .bold)).foregroundStyle(Kit.accent)
            case .new:
                Circle().fill(Kit.soft)
                if let number {
                    Text("\(number)").font(.system(size: size * 0.42, weight: .bold, design: .rounded)).monospacedDigit()
                        .foregroundStyle(Kit.accent)
                } else {
                    Image(systemName: fallbackSymbol).font(.system(size: size * 0.4, weight: .semibold)).foregroundStyle(Kit.accent)
                }
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
