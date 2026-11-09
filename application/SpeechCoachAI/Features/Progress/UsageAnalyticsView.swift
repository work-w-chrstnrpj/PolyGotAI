import Charts
import SwiftUI

/// What "Time in the app" measures: how long the app was open, or how long the learner practised (ticket #7).
enum TimeMetric: String, CaseIterable, Identifiable {
    case screen = "Screen time", practice = "Practice time"
    var id: String { rawValue }
}

/// Time in the app: screen time or practice time, one day in detail, and totals by week, month and year.
/// Practice time adds a Lesson, Lexicon and Lab breakdown. Tapping the date picks another one.
struct UsageAnalyticsView: View {
    var storage: LearnerStorageController
    @State private var metric = TimeMetric.screen
    @State private var period = UsagePeriod.day
    @State private var anchor = Date.now
    @State private var choosing = false
    @State private var report: UsageReport?
    @State private var practice: PracticeReport?
    @Environment(\.scenePhase) private var scene
    private var calendar: Calendar { .current }

    var body: some View {
        KitCard {
            HStack {
                Text("Time in the app").font(Kit.Fonts.section)
                Spacer(minLength: 8)
                Picker("Measure", selection: $metric) {
                    ForEach(TimeMetric.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu).labelsHidden().tint(Kit.accent)
                .accessibilityLabel("Measure").accessibilityIdentifier("usage.metric")
            }
            Picker("Period", selection: $period) {
                ForEach(UsagePeriod.allCases) { Text($0.title).tag($0) }
            }.pickerStyle(.segmented).accessibilityIdentifier("usage.period")
            header
            if metric == .practice, let practice {
                Text(UsageFormat.duration(practice.total(period, containing: anchor))).font(.system(.largeTitle, design: .rounded).bold())
                    .accessibilityIdentifier("usage.total")
                Text(practiceSubtitle(practice)).font(.subheadline).foregroundStyle(Kit.secondary).accessibilityIdentifier("usage.subtitle")
                areaChart(practice)
                breakdown(practice)
            } else if metric == .screen, let report {
                Text(UsageFormat.duration(report.total(period, containing: anchor))).font(.system(.largeTitle, design: .rounded).bold())
                    .accessibilityIdentifier("usage.total")
                Text(subtitle(report)).font(.subheadline).foregroundStyle(Kit.secondary).accessibilityIdentifier("usage.subtitle")
                if period == .day { dayView(report) } else { chart(report.buckets(period, containing: anchor), label: "Time per") }
            } else {
                Text("One moment.").foregroundStyle(Kit.secondary)
            }
        }
        .onAppear(perform: load)
        .onChange(of: scene) { _, phase in if phase == .active { load() } }
        .onReceive(NotificationCenter.default.publisher(for: .usageLogChanged)) { _ in load() }
        .onReceive(NotificationCenter.default.publisher(for: .practiceLogChanged)) { _ in load() }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                load()
            }
        }
        .sheet(isPresented: $choosing) {
            NavigationStack {
                UsageDateSheet(storage: storage, anchor: anchor) { anchor = $0 }
            }
            .environment(\.kitTheme, KitTheme(storage.preferences.background)).tint(Kit.accent)
        }
    }

    // MARK: Header: previous, the date (tap to choose), next

    private var header: some View {
        HStack {
            Button { move(-1) } label: { Image(systemName: "chevron.left") }
                .frame(minWidth: 44, minHeight: 44).accessibilityLabel("Previous").accessibilityIdentifier("usage.previous")
            Spacer()
            Button { choosing = true } label: {
                HStack(spacing: 6) {
                    Text(title).font(.headline).multilineTextAlignment(.center)
                    Image(systemName: "calendar").font(.subheadline).foregroundStyle(Kit.accent).accessibilityHidden(true)
                }
                .foregroundStyle(Kit.ink).frame(minHeight: 44).contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(title).accessibilityHint("Choose a date")
            .accessibilityIdentifier("usage.title")
            Spacer()
            Button { move(1) } label: { Image(systemName: "chevron.right") }
                .frame(minWidth: 44, minHeight: 44).disabled(isLatest).accessibilityLabel("Next").accessibilityIdentifier("usage.next")
        }
    }

    private var title: String {
        switch period {
        case .day:
            if calendar.isDateInToday(anchor) { return "Today" }
            if calendar.isDateInYesterday(anchor) { return "Yesterday" }
            return anchor.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
        case .week:
            if let interval = calendar.dateInterval(of: .weekOfYear, for: anchor), let last = calendar.date(byAdding: .day, value: 6, to: interval.start) {
                return "\(interval.start.formatted(.dateTime.month(.abbreviated).day())) – \(last.formatted(.dateTime.month(.abbreviated).day()))"
            }
            return "This week"
        case .month: return anchor.formatted(.dateTime.month(.wide).year())
        case .year: return anchor.formatted(.dateTime.year())
        }
    }

    private var isLatest: Bool {
        switch period {
        case .day: return calendar.isDateInToday(anchor) || anchor > .now
        case .week: return calendar.isDate(anchor, equalTo: .now, toGranularity: .weekOfYear)
        case .month: return calendar.isDate(anchor, equalTo: .now, toGranularity: .month)
        case .year: return calendar.isDate(anchor, equalTo: .now, toGranularity: .year)
        }
    }

    private func move(_ direction: Int) {
        let component: Calendar.Component = period == .day ? .day : period == .week ? .weekOfYear : period == .month ? .month : .year
        if let next = calendar.date(byAdding: component, value: direction, to: anchor), direction < 0 || next <= .now { anchor = next }
    }

    private func subtitle(_ report: UsageReport) -> String {
        switch period {
        case .day:
            let count = report.segments(on: anchor).count
            return count == 0 ? "No time recorded" : "\(count) \(count == 1 ? "visit" : "visits")"
        default:
            let used = report.daysUsed(period, containing: anchor)
            return used == 0 ? "No time recorded" : "\(used) \(used == 1 ? "day" : "days") used"
        }
    }

    private func practiceSubtitle(_ practice: PracticeReport) -> String {
        let buckets = practice.buckets(period, containing: anchor)
        let used = buckets.filter { $0.seconds > 0 }.count
        if used == 0 { return "No practice yet" }
        switch period {
        case .day: return calendar.isDateInToday(anchor) ? "Practised today" : "Practised"
        case .year: return "\(used) \(used == 1 ? "month" : "months") practised"
        default: return "\(used) \(used == 1 ? "day" : "days") practised"
        }
    }

    /// Lesson, Lexicon and Lab for the chosen period, each with its time and share.
    private func breakdown(_ practice: PracticeReport) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("By area").font(.headline)
            ForEach(practice.shares(period, containing: anchor)) { share in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Circle().fill(share.area.shade).frame(width: 10, height: 10).accessibilityHidden(true)
                        Text(share.area.title)
                        Spacer()
                        Text(UsageFormat.duration(share.seconds)).foregroundStyle(Kit.secondary).monospacedDigit()
                    }
                    .font(.subheadline)
                    AreaBar(value: share.fraction, shade: share.area.shade)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(share.area.title)
                .accessibilityValue("\(UsageFormat.duration(share.seconds)), \(Int((share.fraction * 100).rounded())) percent")
                .accessibilityIdentifier("usage.breakdown.\(share.area.rawValue)")
            }
        }
    }

    // MARK: Day: key numbers, time by hour, visits

    private func dayView(_ report: UsageReport) -> some View {
        let segments = report.segments(on: anchor)
        let dayStart = calendar.startOfDay(for: anchor)
        let today = report.seconds(on: anchor)
        let average = report.average(before: anchor)
        return VStack(alignment: .leading, spacing: 14) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 12) { dayStats(segments, today: today, average: average) }
                VStack(alignment: .leading, spacing: 10) { dayStats(segments, today: today, average: average) }
            }
            if !segments.isEmpty {
                hourChart(report.buckets(.day, containing: anchor), dayStart: dayStart, label: "Time by hour")
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(segments.reversed()) { segment in
                            HStack {
                                Text("\(segment.start.formatted(date: .omitted, time: .shortened)) – \(segment.end.formatted(date: .omitted, time: .shortened))")
                                Spacer()
                                Text(UsageFormat.duration(segment.seconds)).foregroundStyle(Kit.secondary)
                            }
                            .font(.subheadline)
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .padding(.top, 6)
                } label: {
                    Text("Visits").font(.headline).foregroundStyle(Kit.ink)
                }
                .tint(Kit.accent)
                .accessibilityIdentifier("usage.visits")
            }
        }
    }

    @ViewBuilder
    private func dayStats(_ segments: [UsageSegment], today: Int, average: Int) -> some View {
        stat("Longest visit", segments.map(\.seconds).max().map(UsageFormat.duration) ?? "–", id: "usage.longest")
        stat("First opened", segments.first.map { $0.start.formatted(date: .omitted, time: .shortened) } ?? "–", id: "usage.first")
        stat("7-day average", UsageFormat.duration(average), detail: comparison(today, average), id: "usage.average")
    }

    private func stat(_ label: String, _ value: String, detail: String? = nil, id: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(Kit.secondary)
            Text(value).font(.headline)
            if let detail { Text(detail).font(.caption).foregroundStyle(Kit.accent) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(id)
    }

    /// "5 min more", "3 min less" or "Same as usual" against the 7-day average.
    private func comparison(_ today: Int, _ average: Int) -> String? {
        guard average > 0 else { return nil }
        let difference = (today - average) / 60
        if difference == 0 { return "Same as usual" }
        return "\(abs(difference)) min \(difference > 0 ? "more" : "less")"
    }

    private func hourChart(_ hours: [UsageBucket], dayStart: Date, label: String) -> some View {
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
        return Chart(hours) { hour in
            BarMark(x: .value("Hour", hour.start, unit: .hour), y: .value("Minutes", Double(hour.seconds) / 60))
                .foregroundStyle(Kit.accent).cornerRadius(3)
        }
        .chartXScale(domain: dayStart...dayEnd)
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 6)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.hour())
            }
        }
        .chartYAxisLabel("minutes")
        .frame(height: 130)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(hours.filter { $0.seconds > 0 }.map {
            "\($0.start.formatted(date: .omitted, time: .shortened)): \(UsageFormat.duration($0.seconds))"
        }.joined(separator: ", "))
        .accessibilityIdentifier("usage.timeline")
    }

    // MARK: Practice: one stacked bar per hour or day, split by area

    private func areaChart(_ practice: PracticeReport) -> some View {
        let parts = practice.areaBuckets(period, containing: anchor)
        let starts = practice.buckets(period, containing: anchor).map(\.start)
        let unit: Calendar.Component = period == .day ? .hour : period == .year ? .month : .day
        let first = starts.first ?? anchor
        let end = calendar.date(byAdding: unit, value: 1, to: starts.last ?? anchor) ?? anchor
        let label = period == .day ? "Practice by hour" : period == .year ? "Practice per month" : "Practice per day"
        return Chart(parts) { part in
            BarMark(x: .value("Date", part.start, unit: unit), y: .value("Minutes", Double(part.seconds) / 60))
                .foregroundStyle(by: .value("Area", part.area.title))
        }
        .chartForegroundStyleScale(domain: PracticeArea.allCases.map(\.title), range: PracticeArea.allCases.map(\.shade))
        .chartXScale(domain: first...end)
        .chartXAxis {
            switch period {
            case .day: AxisMarks(values: .stride(by: .hour, count: 6)) { _ in AxisGridLine(); AxisValueLabel(format: .dateTime.hour()) }
            case .week: AxisMarks(values: .stride(by: .day)) { _ in AxisValueLabel(format: .dateTime.weekday(.narrow)) }
            case .month: AxisMarks(values: .stride(by: .day, count: 7)) { _ in AxisValueLabel(format: .dateTime.day()) }
            case .year: AxisMarks(values: .stride(by: .month)) { _ in AxisValueLabel(format: .dateTime.month(.narrow)) }
            }
        }
        .chartYAxisLabel("minutes")
        .chartLegend(position: .bottom, alignment: .leading, spacing: 8)
        .frame(height: 190)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(PracticeArea.allCases.map { area in
            "\(area.title): \(UsageFormat.duration(parts.filter { $0.area == area }.reduce(0) { $0 + $1.seconds }))"
        }.joined(separator: ", "))
        .accessibilityIdentifier(period == .day ? "usage.timeline" : "usage.chart")
    }

    // MARK: Week, month, year: totals

    private func chart(_ buckets: [UsageBucket], label: String) -> some View {
        let monthly = period == .year
        let unit: Calendar.Component = monthly ? .month : .day
        return Chart(buckets) { bucket in
            BarMark(x: .value("Date", bucket.start, unit: unit), y: .value("Minutes", Double(bucket.seconds) / 60))
                .foregroundStyle(Kit.accent)
        }
        .chartXAxis {
            switch period {
            case .week: AxisMarks(values: .stride(by: .day)) { _ in AxisValueLabel(format: .dateTime.weekday(.narrow)) }
            case .month: AxisMarks(values: .stride(by: .day, count: 7)) { _ in AxisValueLabel(format: .dateTime.day()) }
            default: AxisMarks(values: .stride(by: .month)) { _ in AxisValueLabel(format: .dateTime.month(.narrow)) }
            }
        }
        .chartYAxisLabel("minutes")
        .frame(height: 170)
        .accessibilityLabel("\(label) \(monthly ? "month" : "day")")
        .accessibilityValue(buckets.filter { $0.seconds > 0 }.map {
            "\($0.start.formatted(.dateTime.month(.abbreviated).day())): \(UsageFormat.duration($0.seconds))"
        }.joined(separator: ", "))
        .accessibilityIdentifier("usage.chart")
    }

    private func load() {
        guard let repository = storage.repository, var log = try? repository.usageLog() else { return }
        if let open = storage.usage.openStretch() { log.record(start: open.start, end: open.end) }
        report = UsageReport(log: log, calendar: calendar)
        if let practiceLog = try? repository.practiceLog() {
            practice = PracticeReport(log: practiceLog.including(storage.practice.openStretch()), calendar: calendar)
        }
    }
}

/// Choose a date; it opens in the current period (the day, or the week, month or year that holds it).
private struct UsageDateSheet: View {
    var storage: LearnerStorageController
    var apply: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var day: Date

    init(storage: LearnerStorageController, anchor: Date, apply: @escaping (Date) -> Void) {
        self.storage = storage
        self.apply = apply
        _day = State(initialValue: anchor)
    }

    var body: some View {
        Form { KitRows {
            DatePicker("Date", selection: $day, in: ...Date.now, displayedComponents: .date)
                .datePickerStyle(.graphical).accessibilityIdentifier("usage.pick.date")
        }}
        .scrollContentBackground(.hidden)
        .background(Kit.canvas(storage.preferences.background))
        .navigationTitle("Choose a date").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }.accessibilityIdentifier("usage.pick.cancel") }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { apply(day); dismiss() }.accessibilityIdentifier("usage.pick.done")
            }
        }
    }
}

extension PracticeArea {
    /// Three shades of the theme colour, so the areas stack into one family: Lesson full, Lexicon lighter, Lab lightest.
    var shade: Color {
        switch self {
        case .lesson: Kit.accent
        case .lexicon: Kit.accent.opacity(0.62)
        case .lab: Kit.accent.opacity(0.34)
        }
    }
}

/// A bar for one area's share, drawn in that area's shade.
private struct AreaBar: View {
    var value: Double
    var shade: Color
    private var fraction: Double { value.isFinite ? min(max(value, 0), 1) : 0 }
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Kit.accent.opacity(0.12))
                Capsule().fill(shade).frame(width: fraction > 0 ? max(8, proxy.size.width * fraction) : 0)
            }
        }
        .frame(height: 8)
        .accessibilityHidden(true)
    }
}
