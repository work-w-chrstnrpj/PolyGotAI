import XCTest

/// Ticket #7: Progress switches between Screen time and Practice time, and Today shows practice time.
/// Synthetic data only (SC_PRACTICE_FIXTURE, SC_USAGE_FIXTURE), in an isolated store.
final class ProgressPracticeUITests: XCTestCase {
    @MainActor
    private func launch(practice: Bool, tab: String, largeText: Bool = false, dark: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchEnvironment["SC_USAGE_FIXTURE"] = "1"
        app.launchEnvironment["SC_REWARD_FIXTURE"] = "1"
        if practice { app.launchEnvironment["SC_PRACTICE_FIXTURE"] = "1" }
        if dark { app.launchEnvironment["SC_REWARD_DARK_FIXTURE"] = "1" }
        if largeText { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        app.launch()
        if tab != "Today" {
            let button = app.tabBars.buttons[tab]
            if button.waitForExistence(timeout: 8) { button.tap() }
            else { app.descendants(matching: .any)["navigation.\(tab.lowercased())"].firstMatch.tap() }
        }
        return app
    }

    @MainActor
    private func reach(_ app: XCUIApplication, _ element: XCUIElement) {
        for _ in 0..<12 where !element.exists || !element.isHittable { app.swipeUp() }
        XCTAssertTrue(element.exists, element.identifier)
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }

    @MainActor
    func testIssue7AC1AC2ProgressSwitchesAndShowsBreakdown() {
        continueAfterFailure = false
        let app = launch(practice: true, tab: "Progress")
        let metric = app.segmentedControls["usage.metric"]
        reach(app, metric)
        // Screen time first: 30 minutes today.
        XCTAssertTrue(app.staticTexts["usage.total"].label.contains("min"), app.staticTexts["usage.total"].label)
        XCTAssertFalse(app.staticTexts["usage.total"].label.contains("20 min"))
        metric.buttons["Practice time"].tap()
        // #7 AC1 Practice time is 20 minutes today (12 + 5 + 3), different from screen time.
        XCTAssertTrue(app.staticTexts["usage.total"].label.contains("20 min"), app.staticTexts["usage.total"].label)
        // #7 AC2 Lesson, Lexicon, Lab breakdown.
        for (area, value) in [("lesson", "12 min"), ("lexicon", "5 min"), ("lab", "3 min")] {
            let row = app.descendants(matching: .any)["usage.breakdown.\(area)"].firstMatch
            reach(app, row)
            XCTAssertTrue(row.value as? String ?? "" != "" && (row.value as? String ?? "").contains(value), "\(area): \(row.value ?? "")")
        }
        attach(app, "progress-practice-day")
        // Same Day / Week / Month / Year views.
        for period in ["Week", "Month", "Year"] {
            app.buttons[period].firstMatch.tap()
            XCTAssertTrue(app.descendants(matching: .any)["usage.chart"].firstMatch.waitForExistence(timeout: 5), period)
            XCTAssertTrue(app.staticTexts["usage.total"].label.contains("min"), period)
        }
        // Week holds yesterday's 8 minutes too only when it falls in the same week; month always holds today's 20.
        attach(app, "progress-practice-year")
        metric.buttons["Screen time"].tap()
        XCTAssertTrue(app.staticTexts["usage.total"].exists)
    }

    @MainActor
    func testIssue7AC3TodayShowsPracticeTime() {
        continueAfterFailure = false
        let app = launch(practice: true, tab: "Today")
        let stats = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS 'day streak'")).firstMatch
        XCTAssertTrue(stats.waitForExistence(timeout: 10))
        XCTAssertTrue(stats.label.contains("20 min"), stats.label)
        XCTAssertFalse(stats.label.contains("28 min") || stats.label.contains("30 min"), "screen time is not shown: \(stats.label)")
        attach(app, "today-practice")
    }

    @MainActor
    func testIssue7AC4NoPracticeShowsZeroWithoutCopyAboutIt() {
        continueAfterFailure = false
        let app = launch(practice: false, tab: "Progress")
        let metric = app.segmentedControls["usage.metric"]
        reach(app, metric)
        metric.buttons["Practice time"].tap()
        XCTAssertEqual(app.staticTexts["usage.total"].label, "0 min")
        let lab = app.descendants(matching: .any)["usage.breakdown.lab"].firstMatch
        reach(app, lab)
        XCTAssertTrue((lab.value as? String ?? "").contains("0 min"))
        for word in ["unavailable", "not tracked", "Unavailable", "Not tracked"] {
            XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", word)).firstMatch.exists, word)
        }
        for period in ["Week", "Month", "Year"] {
            app.buttons[period].firstMatch.tap()
            XCTAssertEqual(app.staticTexts["usage.total"].label, "0 min", period)
        }
        attach(app, "progress-practice-empty")
        let today = launch(practice: false, tab: "Today")
        let stats = today.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS 'day streak'")).firstMatch
        XCTAssertTrue(stats.waitForExistence(timeout: 10))
        XCTAssertTrue(stats.label.contains("0 min"), stats.label)
    }

    @MainActor
    func testIssue7LargeTextAndDarkStillShowTheBreakdown() {
        continueAfterFailure = false
        let app = launch(practice: true, tab: "Progress", largeText: true, dark: true)
        let metric = app.segmentedControls["usage.metric"]
        reach(app, metric)
        metric.buttons["Practice time"].tap()
        reach(app, app.descendants(matching: .any)["usage.breakdown.lab"].firstMatch)
        attach(app, "progress-practice-large-dark")
    }
}
