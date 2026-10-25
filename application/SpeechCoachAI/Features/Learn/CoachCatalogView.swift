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
                }.buttonStyle(.plain).accessibilityIdentifier("coach.continue")
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
                            Text(track.tagline).font(.caption).foregroundStyle(Kit.secondary)
                                .lineLimit(1).minimumScaleFactor(0.65)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityValue("\(Int(track.completedFraction(journeys: journeys) * 100)) percent complete")
                    }.buttonStyle(.plain).accessibilityIdentifier("coach.card.\(track.id)")
                }
            }
        }.onAppear { journeys = (try? storage.repository?.allLessonJourneys()) ?? [] }
    }
}

struct TrackArtwork: View {
    var coach: TrackCoach
    var body: some View {
        Group {
            if let artwork = coach.artwork { CoachArtwork(name: artwork) }
            else { Image(systemName: coach.symbol).resizable().scaledToFit().padding(20).foregroundStyle(Kit.accent) }
        }.accessibilityHidden(true)
    }
}

private struct TrackProgressRing: View {
    var fraction: Double
    var body: some View {
        ZStack {
            Circle().stroke(Kit.secondary.opacity(0.18), lineWidth: 3)
            Circle().trim(from: 0, to: fraction).stroke(Kit.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }.frame(width: 24, height: 24).accessibilityHidden(true)
    }
}

struct CoachTrackView: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    var track: Track
    var onSpeak: (ResolvedLesson, UUID) -> Void
    @State private var selectedStage: String?
    @State private var journeys: [LessonJourney] = []
    private var stage: TrackStage? { track.stages.first { $0.id == selectedStage } ?? track.stages.first }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TrackArtwork(coach: track.coach).frame(height: 140).frame(maxWidth: .infinity)
                Text(track.tagline).foregroundStyle(Kit.secondary).lineLimit(1).minimumScaleFactor(0.65)
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(track.stages) { item in
                            Button { selectedStage = item.id } label: {
                                Text(item.title).font(.headline).padding(.horizontal, 16).frame(minHeight: 44)
                                    .foregroundStyle(Kit.ink)
                                    .background(stage?.id == item.id ? Kit.soft : Kit.surface, in: Capsule())
                                    .overlay(Capsule().stroke(stage?.id == item.id ? Kit.accent : .clear))
                            }.buttonStyle(.plain)
                                .accessibilityAddTraits(stage?.id == item.id ? .isSelected : [])
                                .accessibilityIdentifier("track.stage.\(item.id)")
                        }
                    }
                }.scrollIndicators(.hidden)
                if let stage {
                    ForEach(stage.units) { unit in
                        NavigationLink {
                            CoachUnitView(storage: storage, install: install, unit: unit, onSpeak: onSpeak)
                        } label: { unitCard(unit) }
                        .buttonStyle(.plain).accessibilityIdentifier("track.unit.\(unit.id)")
                    }
                }
            }.padding(20).frame(maxWidth: 700).frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
        .navigationTitle(track.title).navigationBarTitleDisplayMode(.inline)
        .onAppear { journeys = (try? storage.repository?.allLessonJourneys()) ?? [] }
    }

    private func unitCard(_ unit: TrackUnit) -> some View {
        let completed = unit.lessons.filter { LessonProgress.of($0, journeys: journeys).state == .done }.count
        return KitCard {
            KitContentRow(symbol: "books.vertical", title: unit.title, detail: "\(unit.lessons.count) lessons · \(completed) done", showsChevron: true)
            ProgressView(value: Double(completed), total: Double(max(1, unit.lessons.count))).tint(Kit.accent)
                .accessibilityLabel("\(unit.title) progress").accessibilityValue("\(completed) of \(unit.lessons.count) lessons")
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
                ForEach(unit.lessons) { lesson in
                    NavigationLink {
                        LessonPlayerView(storage: storage, lesson: lesson, install: install, onSpeak: onSpeak)
                    } label: { KitCard { CourseLessonRow(lesson: lesson, journeys: journeys) } }
                    .buttonStyle(.plain).accessibilityIdentifier("track.lesson.\(lesson.id)")
                }
            }.padding(20).frame(maxWidth: 700).frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
        .navigationTitle(unit.title).navigationBarTitleDisplayMode(.inline)
        .onAppear { journeys = (try? storage.repository?.allLessonJourneys()) ?? [] }
    }
}
