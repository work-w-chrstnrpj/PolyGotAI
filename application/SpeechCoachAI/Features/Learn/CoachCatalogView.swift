import SwiftUI

struct CoachCatalogView: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    var onSpeak: (ResolvedLesson, UUID) -> Void
    @State private var journeys: [LessonJourney] = []
    @Environment(\.horizontalSizeClass) private var widthClass
    @Environment(\.dynamicTypeSize) private var textSize
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: textSize.isAccessibilitySize ? 1 : widthClass == .regular ? 3 : 2)
    }

    var body: some View {
        Group {
            if let next = install.tracks.continueLesson(journeys: journeys) {
                NavigationLink {
                    LessonPlayerView(storage: storage, lesson: next.lesson, install: install, onSpeak: onSpeak)
                } label: {
                    KitCard { KitContentRow(symbol: "play.circle.fill", title: "Continue", detail: next.lesson.title, showsChevron: true) }
                }.buttonStyle(.kitCard).accessibilityIdentifier("coach.continue")
            }
            LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                ForEach(install.tracks.tracks) { track in
                    NavigationLink {
                        CoachTrackView(storage: storage, install: install, track: track, onSpeak: onSpeak)
                    } label: {
                        KitCard {
                            TrackArtwork(coach: track.coach).frame(height: 112).frame(maxWidth: .infinity)
                            HStack(alignment: .top) {
                                Text(track.title).font(.headline).foregroundStyle(Kit.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer(minLength: 0)
                                TrackProgressRing(fraction: track.completedFraction(journeys: journeys))
                            }
                            Text(CoachTrackPresentation.progress(track.lessons, journeys: journeys)).font(.caption.weight(.semibold))
                                .foregroundStyle(Kit.secondary)
                            Text(track.tagline).font(.caption).foregroundStyle(Kit.secondary)
                                .lineLimit(1).minimumScaleFactor(0.65)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityValue(CoachTrackPresentation.progress(track.lessons, journeys: journeys))
                    }.buttonStyle(.kitCard).accessibilityIdentifier("coach.card.\(track.id)")
                }
            }
        }.onAppear { journeys = (try? storage.repository?.allLessonJourneys()) ?? [] }
    }
}

struct TrackArtwork: View {
    var coach: TrackCoach
    var body: some View {
        Group {
            if let artwork = coach.artwork {
                CoachArtwork(name: artwork)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Kit.soft.opacity(0.55), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                // Coaches without a portrait get a gradient tile in the theme colour with their symbol.
                GeometryReader { proxy in
                    let side = min(proxy.size.width, proxy.size.height)
                    ZStack {
                        LinearGradient(colors: [Kit.accent, Kit.accent.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        Circle().fill(Kit.onAccent.opacity(0.10)).frame(width: side * 1.1)
                            .offset(x: proxy.size.width * 0.38, y: -proxy.size.height * 0.42)
                        Circle().fill(Kit.onAccent.opacity(0.07)).frame(width: side * 0.8)
                            .offset(x: -proxy.size.width * 0.42, y: proxy.size.height * 0.45)
                        Image(systemName: coach.symbol).resizable().scaledToFit()
                            .fontWeight(.semibold)
                            .foregroundStyle(Kit.onAccent)
                            .frame(width: side * 0.46, height: side * 0.46)
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }.accessibilityHidden(true)
    }
}

private struct TrackProgressRing: View {
    var fraction: Double
    var body: some View {
        ZStack {
            Circle().stroke(Kit.accent.opacity(0.16), lineWidth: 3.5)
            Circle().trim(from: 0, to: fraction).stroke(fraction >= 1 ? Kit.success : Kit.accent, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if fraction >= 1 {
                Image(systemName: "checkmark").font(.system(size: 10, weight: .heavy)).foregroundStyle(Kit.success)
            }
        }.frame(width: 26, height: 26).accessibilityHidden(true)
    }
}

struct CoachTrackView: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    var track: Track
    var onSpeak: (ResolvedLesson, UUID) -> Void
    @State private var selectedStage: String?
    @State private var journeys: [LessonJourney] = []
    private var stage: TrackStage? { CoachTrackPresentation.stage(in: track, selected: selectedStage) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TrackArtwork(coach: track.coach).frame(height: 140).frame(maxWidth: .infinity)
                Text(track.tagline).foregroundStyle(Kit.secondary).lineLimit(1).minimumScaleFactor(0.65)
                Text(CoachTrackPresentation.progress(track.lessons, journeys: journeys))
                    .font(.subheadline.weight(.semibold)).accessibilityIdentifier("track.progress")
                stageMenu
                if !earlierLessons.isEmpty {
                    NavigationLink("Earlier lessons") {
                        CoachUnitView(storage: storage, install: install,
                                      unit: TrackUnit(id: "archived", title: "Earlier lessons", lessons: earlierLessons), onSpeak: onSpeak)
                    }.accessibilityIdentifier("track.archived")
                }
                if let stage {
                    ForEach(stage.units) { unit in
                        NavigationLink {
                            CoachUnitView(storage: storage, install: install, unit: unit, onSpeak: onSpeak)
                        } label: { unitCard(unit) }
                        .buttonStyle(.kitCard).accessibilityIdentifier("track.unit.\(unit.id)")
                    }
                }
            }.padding(20).frame(maxWidth: 700).frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
        .navigationTitle(track.title).navigationBarTitleDisplayMode(.inline)
        .onAppear { journeys = (try? storage.repository?.allLessonJourneys()) ?? [] }
    }

    private var earlierLessons: [ResolvedLesson] {
        install.tracks.archivedLessons.filter { lesson in
            lesson.trackId == track.id && journeys.contains { $0.lessonID == lesson.id && $0.contentVersion == lesson.contentVersion }
        }
    }

    /// Stages as one dropdown (owner, 2026-10-31), each with its progress.
    private var stageMenu: some View {
        KitDropdown(caption: "Stage", value: stage.map { stageLine($0) } ?? "", identifier: "track.stage") {
            Picker("Stage", selection: Binding(get: { stage?.id ?? "" }, set: { selectedStage = $0 })) {
                ForEach(track.stages) { item in Text(stageLine(item)).tag(item.id) }
            }
        }
    }

    private func stageLine(_ item: TrackStage) -> String {
        let done = item.lessons.filter { LessonProgress.of($0, journeys: journeys).state == .done }.count
        return "\(item.title) · \(done) of \(item.lessons.count)"
    }

    private func unitCard(_ unit: TrackUnit) -> some View {
        let completed = unit.lessons.filter { LessonProgress.of($0, journeys: journeys).state == .done }.count
        return KitCard {
            KitContentRow(symbol: "books.vertical", title: unit.title, detail: CoachTrackPresentation.progress(unit.lessons, journeys: journeys), showsChevron: true)
            KitProgressBar(value: Double(completed) / Double(max(1, unit.lessons.count)))
        }
    }
}

struct CoachUnitView: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    var unit: TrackUnit
    var onSpeak: (ResolvedLesson, UUID) -> Void
    @State private var journeys: [LessonJourney] = []
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(unit.lessons.enumerated()), id: \.element.id) { index, lesson in
                    NavigationLink {
                        LessonPlayerView(storage: storage, lesson: lesson, install: install, onSpeak: onSpeak)
                    } label: { KitCard { CourseLessonRow(lesson: lesson, journeys: journeys, number: index + 1) } }
                    .buttonStyle(.kitCard).accessibilityIdentifier("track.lesson.\(lesson.id)")
                }
            }.padding(20).frame(maxWidth: 700).frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
        .navigationTitle(unit.title).navigationBarTitleDisplayMode(.inline)
        .onAppear { journeys = (try? storage.repository?.allLessonJourneys()) ?? [] }
    }
}

/// Presentation rules share the same exact-version completion policy as lesson rows.
enum CoachTrackPresentation {
    static func stage(in track: Track, selected: String?) -> TrackStage? {
        track.stages.first { $0.id == selected } ?? track.stages.first
    }
    static func progress(_ lessons: [ResolvedLesson], journeys: [LessonJourney]) -> String {
        let completed = lessons.filter { LessonProgress.of($0, journeys: journeys).state == .done }.count
        return "\(completed) of \(lessons.count) lessons done"
    }
}
