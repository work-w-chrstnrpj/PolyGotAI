import SwiftUI
import UIKit

/// Today (Phase 7): level and streak at a glance, where you are in the course and with your coaches,
/// words due, the word of the day and the latest badges.
struct TodayView: View {
    var storage: LearnerStorageController
    var install: CurriculumInstall
    var openSpeaking: (ResolvedLesson, UUID) -> Void
    @Environment(\.scenePhase) private var scenePhase
    @State private var lessons = CurrentLessons(course: nil, coaches: [], dueWords: 0)
    @State private var ledger: RewardLedger?
    @State private var minutesToday = 0
    @State private var displayedDate = Date.now

    var body: some View {
        VStack(alignment: .leading, spacing: Kit.Space.xl) {
            Text(displayedDate.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                .font(.subheadline.weight(.medium)).foregroundStyle(Kit.secondary)
                .padding(.top, -Kit.Space.m)
            if let ledger { PracticeStatsRow(storage: storage, ledger: ledger, thirdTitle: "Today", thirdValue: UsageFormat.duration(minutesToday * 60)) }
            courseCard
            coachSection
            if lessons.dueWords > 0 { reviewRow }
            DailyLexiconCard(storage: storage)
            if let ledger { RecentBadges(storage: storage, ledger: ledger) }
        }
        .onAppear(perform: reload)
        .onChange(of: storage.repository != nil) { _, _ in reload() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { reload() } }
        .onReceive(NotificationCenter.default.publisher(for: .rewardLedgerChanged)) { _ in reload() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in reload() }
    }

    @ViewBuilder private var courseCard: some View {
        if let course = lessons.course {
            HeroCard(eyebrow: "Rank \(course.rank ?? course.lesson.level) · Course", title: course.lesson.title, detail: position(of: course.lesson)) {
                NavigationLink {
                    LessonPlayerView(storage: storage, lesson: course.lesson, install: install, onSpeak: openSpeaking)
                } label: { Text(course.resuming ? "Continue" : "Start") }
                    .buttonStyle(KitPrimaryButtonStyle())
                    .accessibilityIdentifier("today.lesson")
            }
        }
    }

    @ViewBuilder private var coachSection: some View {
        if !lessons.coaches.isEmpty {
            VStack(alignment: .leading, spacing: Kit.Space.m) {
                SectionHeader(title: "Your coaches")
                ForEach(lessons.coaches) { entry in
                    NavigationLink {
                        LessonPlayerView(storage: storage, lesson: entry.lesson, install: install, onSpeak: openSpeaking)
                    } label: { CoachLessonRow(entry: entry) }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("today.coach.\(entry.lesson.id)")
                }
            }
        }
    }

    private var reviewRow: some View {
        NavigationLink { LexiconTrainingView(storage: storage, bank: LexiconBankLoader.bundled) } label: {
            KitCard {
                KitContentRow(symbol: "square.stack", title: "Review words",
                              detail: "\(lessons.dueWords) due", showsChevron: true)
            }
        }
        .buttonStyle(.plain).accessibilityIdentifier("today.review-row")
    }

    /// "Lesson 3 of 12" within the lesson's rank.
    private func position(of lesson: ResolvedLesson) -> String? {
        let rank = install.lessons(at: lesson.level).filter(\.isReady)
        guard let index = rank.firstIndex(where: { $0.id == lesson.id }) else { return nil }
        return "Lesson \(index + 1) of \(rank.count)"
    }

    private func reload() {
        displayedDate = .now
        lessons = CurrentLessons(storage: storage, install: install)
        ledger = try? storage.repository?.rewardLedger()
        if let repository = storage.repository, var log = try? repository.usageLog() {
            if let open = storage.usage.openStretch() { log.record(start: open.start, end: open.end) }
            minutesToday = UsageReport(log: log).seconds(on: .now) / 60
        }
    }
}

/// One coach lesson: the coach's art, name and the lesson to open.
private struct CoachLessonRow: View {
    var entry: CurrentLessons.Entry
    var body: some View {
        KitCard {
            HStack(spacing: Kit.Space.l) {
                if let coach = entry.coach {
                    TrackArtwork(coach: coach).frame(width: 64, height: 64)
                }
                VStack(alignment: .leading, spacing: Kit.Space.xs) {
                    Text(entry.coach?.title ?? "Coach").font(Kit.Fonts.caption).foregroundStyle(Kit.accent)
                    Text(entry.lesson.title).font(Kit.Fonts.rowTitle).foregroundStyle(Kit.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(entry.resuming ? "Continue" : "Next lesson").font(Kit.Fonts.detail).foregroundStyle(Kit.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(Kit.secondary)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// Level ring (opens badges), streak, and a third number chosen by the screen. Shared by Today and Progress.
struct PracticeStatsRow: View {
    var storage: LearnerStorageController
    var ledger: RewardLedger
    var thirdTitle: String
    var thirdValue: String

    var body: some View {
        let level = XPLevel(xp: ledger.xp)
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: Kit.Space.l) { ring(level); tiles }
            VStack(alignment: .leading, spacing: Kit.Space.l) { ring(level).frame(maxWidth: .infinity); tiles }
        }
    }

    private func ring(_ level: XPLevel) -> some View {
        NavigationLink { RewardOverview(storage: storage) } label: {
            ProgressRing(progress: level.fraction, title: "Level \(level.level)", detail: "\(level.xpToNext) XP to go")
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("rewards.open")
    }

    private var tiles: some View {
        VStack(spacing: Kit.Space.m) {
            StatTile(title: "Day streak", value: "\(ledger.currentStreak(day: RewardPolicy.day(.now)))", symbol: "flame")
            StatTile(title: thirdTitle, value: thirdValue, symbol: "clock")
        }
    }
}

/// The three most recent badges, with a link to all of them. Hidden until one is earned.
struct RecentBadges: View {
    var storage: LearnerStorageController
    var ledger: RewardLedger
    var limit = 3

    var body: some View {
        let recent = ledger.awards.sorted { $0.earnedAt > $1.earnedAt }
            .compactMap { award in AwardFamily.catalog.first { $0.id == award.family } }
        let unique = recent.reduce(into: [AwardFamily]()) { list, family in if !list.contains(family) { list.append(family) } }
        if !unique.isEmpty {
            VStack(alignment: .leading, spacing: Kit.Space.m) {
                SectionHeader(title: "Recent badges") {
                    NavigationLink("See all") { RewardOverview(storage: storage) }
                        .accessibilityIdentifier("today.badges.all")
                }
                HStack(alignment: .top, spacing: Kit.Space.m) {
                    ForEach(unique.prefix(limit)) { family in
                        BadgeTile(title: family.title) { RewardArtwork(family: family, size: 56) }
                    }
                }
            }
        }
    }
}
