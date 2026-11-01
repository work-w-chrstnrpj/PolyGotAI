import Charts
import SwiftUI

/// Screen time in the app: one day in detail, and totals by week, month and year. Tapping the date picks another one.
struct UsageAnalyticsView: View {
    var storage: LearnerStorageController
    @State private var period = UsagePeriod.day
    @State private var anchor = Date.now
    @State private var choosing = false
    @State private var report: UsageReport?
    @Environment(\.scenePhase) private var scene
    private var calendar: Calendar { .current }

    var body: some View {
        KitCard {
            Text("Time in the app").font(Kit.Fonts.section)
            Picker("Period", selection: $period) {
                ForEach(UsagePeriod.allCases) { Text($0.title).tag($0) }
            }.pickerStyle(.segmented).accessibilityIdentifier("usage.period")
            header
            if let report {
                Text(UsageFormat.duration(report.total(period, containing: anchor))).font(.system(.largeTitle, design: .rounded).bold())
                    .accessibilityIdentifier("usage.total")
                Text(subtitle(report)).font(.subheadline).foregroundStyle(Kit.secondary).accessibilityIdentifier("usage.subtitle")
                if period == .day { dayView(report) } else { chart(report) }
            } else {
                Text("One moment.").foregroundStyle(Kit.secondary)
            }
        }
        .onAppear(perform: load)
        .onChange(of: scene) { _, phase in if phase == .active { load() } }
        .onReceive(NotificationCenter.default.publisher(for: .usageLogChanged)) { _ in load() }
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
                hourChart(report.buckets(.day, containing: anchor), dayStart: dayStart, visits: segments.count)
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

    private func hourChart(_ hours: [UsageBucket], dayStart: Date, visits: Int) -> some View {
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
        .accessibilityLabel("Time by hour")
        .accessibilityValue(hours.filter { $0.seconds > 0 }.map {
            "\($0.start.formatted(date: .omitted, time: .shortened)): \(UsageFormat.duration($0.seconds))"
        }.joined(separator: ", "))
        .accessibilityIdentifier("usage.timeline")
    }

    // MARK: Week, month, year: totals

    private func chart(_ report: UsageReport) -> some View {
        let buckets = report.buckets(period, containing: anchor)
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
        .accessibilityLabel("Time per \(monthly ? "month" : "day")")
        .accessibilityValue(buckets.filter { $0.seconds > 0 }.map {
            "\($0.start.formatted(.dateTime.month(.abbreviated).day())): \(UsageFormat.duration($0.seconds))"
        }.joined(separator: ", "))
        .accessibilityIdentifier("usage.chart")
    }

    private func load() {
        guard let repository = storage.repository, var log = try? repository.usageLog() else { return }
        if let open = storage.usage.openStretch() { log.record(start: open.start, end: open.end) }
        report = UsageReport(log: log, calendar: calendar)
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
