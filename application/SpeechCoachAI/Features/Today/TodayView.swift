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
            Text("\(greeting) · \(displayedDate.formatted(.dateTime.weekday(.wide).day().month(.wide)))")
                .font(.subheadline.weight(.medium)).foregroundStyle(Kit.secondary)
                .lineLimit(1).minimumScaleFactor(0.8)
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
            HeroCard(eyebrow: "Rank \(course.rank ?? course.lesson.level) · Course", title: course.lesson.title,
                     detail: position(of: course.lesson), artwork: "CoachTeacher", progress: rankFraction(of: course.lesson)) {
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
                        .buttonStyle(.kitCard)
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
        .buttonStyle(.kitCard).accessibilityIdentifier("today.review-row")
    }

    /// "Good morning" and friends, from the hour of `displayedDate`.
    private var greeting: String {
        switch Calendar.current.component(.hour, from: displayedDate) {
        case 5..<12: "Good morning"
        case 12..<17: "Good afternoon"
        default: "Good evening"
        }
    }

    /// How far into its rank the lesson sits (lesson 1 of 12 → 0), for the hero card's bar.
    private func rankFraction(of lesson: ResolvedLesson) -> Double? {
        let rank = install.lessons(at: lesson.level).filter(\.isReady)
        guard let index = rank.firstIndex(where: { $0.id == lesson.id }), rank.count > 1 else { return nil }
        return Double(index) / Double(rank.count)
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
        if let repository = storage.repository, let log = try? repository.practiceLog() {
            // Practice time, not screen time (ticket #7), with the stretch still open.
            minutesToday = PracticeReport(log: log.including(storage.practice.openStretch())).total(.day, containing: .now) / 60
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
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                }
                VStack(alignment: .leading, spacing: Kit.Space.xs) {
                    Text(entry.coach?.title ?? "Coach").font(Kit.Fonts.caption).foregroundStyle(Kit.accent)
                    Text(entry.lesson.title).font(Kit.Fonts.rowTitle).foregroundStyle(Kit.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(entry.resuming ? "Continue" : "Next lesson").font(Kit.Fonts.detail).foregroundStyle(Kit.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: entry.resuming ? "play.fill" : "arrow.right")
                    .font(.subheadline.weight(.bold)).foregroundStyle(Kit.accent)
                    .frame(width: 36, height: 36).background(Kit.accent.opacity(0.12), in: Circle())
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// One full-width card (Phase 12): level and XP bar on top, then the streak and a number chosen by the screen. Opens badges.
struct PracticeStatsRow: View {
    @Environment(\.kitTheme) private var theme
    var storage: LearnerStorageController
    var ledger: RewardLedger
    var thirdTitle: String
    var thirdValue: String

    var body: some View {
        let level = XPLevel(xp: ledger.xp)
        let streak = ledger.currentStreak(day: RewardPolicy.day(.now))
        NavigationLink { RewardOverview(storage: storage) } label: {
            VStack(alignment: .leading, spacing: Kit.Space.m) {
                HStack(spacing: Kit.Space.m) {
                    LevelMedallion(level: level.level)
                    VStack(alignment: .leading, spacing: Kit.Space.s) {
                        ViewThatFits(in: .horizontal) {
                            HStack(alignment: .firstTextBaseline) { levelTitle(level); Spacer(); toGo(level) }
                            VStack(alignment: .leading, spacing: Kit.Space.xs) { levelTitle(level); toGo(level) }
                        }
                        KitProgressBar(value: level.fraction)
                    }
                }
                Divider().overlay(Kit.ink.opacity(0.04))
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: Kit.Space.xl) { stats(streak: streak) }
                    VStack(alignment: .leading, spacing: Kit.Space.s) { stats(streak: streak) }
                }
            }
            .padding(Kit.Space.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .kitSurface()
        }
        .buttonStyle(.kitCard)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Level \(level.level), \(level.xpToNext) XP to go")
        .accessibilityValue("\(streak) day streak, \(thirdTitle) \(thirdValue)")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("rewards.open")
    }

    private func levelTitle(_ level: XPLevel) -> some View {
        Text("Level \(level.level)").font(Kit.Fonts.title).foregroundStyle(Kit.ink)
    }

    private func toGo(_ level: XPLevel) -> some View {
        Text("\(level.xpToNext) XP to go").font(Kit.Fonts.detail).foregroundStyle(Kit.secondary)
    }

    @ViewBuilder private func stats(streak: Int) -> some View {
        stat(symbol: "flame.fill", value: "\(streak)", title: "day streak", tint: streak > 0 ? Kit.streak : Kit.secondary)
        stat(symbol: "clock.fill", value: thirdValue, title: thirdTitle.lowercased(), tint: theme.accent)
    }

    private func stat(symbol: String, value: String, title: String, tint: Color) -> some View {
        HStack(spacing: Kit.Space.s) {
            Image(systemName: symbol).foregroundStyle(tint).symbolEffect(.bounce, value: value)
            Text(value).font(.headline).monospacedDigit().foregroundStyle(Kit.ink)
            Text(title).font(Kit.Fonts.detail).foregroundStyle(Kit.secondary)
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
                        BadgeTile(title: family.title) { RewardArtwork(family: family, size: 80) }.frame(maxWidth: 200)
                    }
                }
            }
        }
    }
}

/// The level number on a round, gradient-filled medal.
struct LevelMedallion: View {
    @Environment(\.kitTheme) private var theme
    var level: Int
    @ScaledMetric(relativeTo: .title2) private var side = 52.0
    var body: some View {
        Text("\(level)").font(.system(.title2, design: .rounded).weight(.heavy)).monospacedDigit()
            .foregroundStyle(theme.onAccent)
            .minimumScaleFactor(0.6).lineLimit(1)
            .frame(width: min(side, 72), height: min(side, 72))
            .background(theme.accent.gradient, in: Circle())
            .overlay(Circle().strokeBorder(.white.opacity(0.35), lineWidth: 2).padding(3))
            .shadow(color: theme.accent.opacity(0.3), radius: 8, y: 4)
            .accessibilityHidden(true)
    }
}
