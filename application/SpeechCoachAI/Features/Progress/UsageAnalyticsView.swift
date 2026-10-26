import Charts
import SwiftUI

/// Screen time in the app: a timeline for one day, and totals by day, week, month and year.
struct UsageAnalyticsView: View {
    var storage: LearnerStorageController
    @State private var period = UsagePeriod.day
    @State private var anchor = Date.now
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
                let total = report.total(period, containing: anchor)
                Text(UsageFormat.duration(total)).font(.system(.largeTitle, design: .rounded).bold())
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
    }

    // MARK: Header with previous and next

    private var header: some View {
        HStack {
            Button { move(-1) } label: { Image(systemName: "chevron.left") }
                .frame(minWidth: 44, minHeight: 44).accessibilityLabel("Previous").accessibilityIdentifier("usage.previous")
            Spacer()
            Text(title).font(.headline).accessibilityIdentifier("usage.title")
            Spacer()
            Button { move(1) } label: { Image(systemName: "chevron.right") }
                .frame(minWidth: 44, minHeight: 44).disabled(isLatest).accessibilityLabel("Next").accessibilityIdentifier("usage.next")
        }
    }

    private var title: String {
        switch period {
        case .day: calendar.isDateInToday(anchor) ? "Today" : anchor.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
        case .week:
            if let interval = calendar.dateInterval(of: .weekOfYear, for: anchor), let last = calendar.date(byAdding: .day, value: 6, to: interval.start) {
                "\(interval.start.formatted(.dateTime.month(.abbreviated).day())) – \(last.formatted(.dateTime.month(.abbreviated).day()))"
            } else { "This week" }
        case .month: anchor.formatted(.dateTime.month(.wide).year())
        case .year: anchor.formatted(.dateTime.year())
        }
    }

    private var isLatest: Bool {
        switch period {
        case .day: calendar.isDateInToday(anchor) || anchor > .now
        case .week: calendar.isDate(anchor, equalTo: .now, toGranularity: .weekOfYear)
        case .month: calendar.isDate(anchor, equalTo: .now, toGranularity: .month)
        case .year: calendar.isDate(anchor, equalTo: .now, toGranularity: .year)
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

    // MARK: Day: timeline and visits

    private func dayView(_ report: UsageReport) -> some View {
        let segments = report.segments(on: anchor)
        let dayStart = calendar.startOfDay(for: anchor)
        return VStack(alignment: .leading, spacing: 10) {
            DayTimeline(segments: segments, dayStart: dayStart)
                .frame(height: 44).accessibilityElement(children: .ignore)
                .accessibilityLabel("Timeline of the day").accessibilityValue(segments.isEmpty ? "No time recorded" : "\(segments.count) visits")
                .accessibilityIdentifier("usage.timeline")
        }
    }

    // MARK: Week, month, year: totals

    private func chart(_ report: UsageReport) -> some View {
        let buckets = report.buckets(period, containing: anchor)
        let unit: Calendar.Component = period == .year ? .month : .day
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
        .accessibilityLabel("Time per \(period == .year ? "month" : "day")")
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

/// A 24-hour strip with a block for each visit.
private struct DayTimeline: View {
    var segments: [UsageSegment]
    var dayStart: Date

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 6).fill(Kit.soft).frame(height: 28)
                ForEach(segments) { segment in
                    let from = segment.start.timeIntervalSince(dayStart) / 86_400
                    let length = segment.end.timeIntervalSince(segment.start) / 86_400
                    RoundedRectangle(cornerRadius: 4).fill(Kit.accent)
                        .frame(width: max(3, width * length), height: 28)
                        .offset(x: width * from)
                }
                ForEach([0, 6, 12, 18, 24], id: \.self) { hour in
                    Text(hour == 24 ? "" : String(format: "%02d", hour)).font(.caption2).foregroundStyle(Kit.secondary)
                        .offset(x: max(0, min(width - 16, width * Double(hour) / 24 - 8)), y: 30)
                }
            }
        }
    }
}
