import XCTest

/// Progress shows the level, time in the app (day timeline and day/week/month/year totals) and milestones.
final class ProgressUsageUITests: XCTestCase {
    @MainActor
    private func launch(largeText: Bool = false, dark: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchEnvironment["SC_USAGE_FIXTURE"] = "1"
        app.launchEnvironment["SC_REWARD_FIXTURE"] = "1"
        if dark { app.launchEnvironment["SC_REWARD_DARK_FIXTURE"] = "1" }
        if largeText { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        app.launch()
        let tab = app.tabBars.buttons["Progress"]
        if tab.waitForExistence(timeout: 8) { tab.tap() } else { app.descendants(matching: .any)["navigation.progress"].firstMatch.tap() }
        return app
    }

    @MainActor
    private func reach(_ app: XCUIApplication, _ element: XCUIElement) {
        for _ in 0..<12 where !element.exists || !element.isHittable { app.swipeUp() }
        XCTAssertTrue(element.exists, element.identifier)
    }

    @MainActor
    func testProgressShowsLevelTimeAndMilestones() {
        continueAfterFailure = false
        let app = launch()
        XCTAssertTrue(app.staticTexts["progress.level"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["progress.level"].label.hasPrefix("Level"))

        // Today: 30 minutes in one visit, with a timeline.
        let total = app.staticTexts["usage.total"]
        reach(app, total)
        XCTAssertTrue(total.label.contains("min"), total.label)
        XCTAssertEqual(app.buttons["usage.title"].label, "Today")
        XCTAssertTrue(app.descendants(matching: .any)["usage.timeline"].firstMatch.exists)
        XCTAssertTrue(app.descendants(matching: .any)["usage.average"].firstMatch.exists)
        XCTAssertFalse(app.buttons["usage.next"].isEnabled, "cannot go past today")
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = "progress-usage-day"; shot.lifetime = .keepAlways; add(shot)

        // Yesterday is 20 minutes.
        app.buttons["usage.previous"].tap()
        XCTAssertTrue(app.staticTexts["usage.total"].label.contains("20 min"), app.staticTexts["usage.total"].label)
        XCTAssertTrue(app.buttons["usage.next"].isEnabled)
        app.buttons["usage.next"].tap()

        // Week, month and year show a chart and a larger or equal total.
        for period in ["Week", "Month", "Year"] {
            app.buttons[period].firstMatch.tap()
            XCTAssertTrue(app.otherElements["usage.chart"].waitForExistence(timeout: 5) || app.descendants(matching: .any)["usage.chart"].firstMatch.exists, period)
            XCTAssertTrue(app.staticTexts["usage.total"].label.contains("min") || app.staticTexts["usage.total"].label.contains("h"), period)
        }
        let year = XCTAttachment(screenshot: app.screenshot()); year.name = "progress-usage-year"; year.lifetime = .keepAlways; add(year)

        // Milestones.
        let count = app.staticTexts["milestones.count"]
        reach(app, count)
        XCTAssertTrue(count.label.contains("reached"), count.label)
        let milestones = XCTAttachment(screenshot: app.screenshot()); milestones.name = "progress-milestones"; milestones.lifetime = .keepAlways; add(milestones)
    }

    @MainActor
    func testTheDateOpensADatePicker() {
        continueAfterFailure = false
        let app = launch()
        let title = app.buttons["usage.title"]
        reach(app, title)
        title.tap()
        XCTAssertTrue(app.datePickers["usage.pick.date"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.segmentedControls["usage.pick.mode"].exists, "only one date, no range")
        let sheet = XCTAttachment(screenshot: app.screenshot()); sheet.name = "progress-usage-date-sheet"; sheet.lifetime = .keepAlways; add(sheet)
        app.buttons["usage.pick.cancel"].tap()
        XCTAssertEqual(title.label, "Today")
    }

    @MainActor
    func testLevelCardOpensBadgesWithoutGold() {
        continueAfterFailure = false
        let app = launch()
        let card = app.buttons["progress.levelCard"].firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 10))
        card.tap()
        let balance = app.staticTexts["rewards.balance"]
        XCTAssertTrue(balance.waitForExistence(timeout: 10))
        XCTAssertFalse(balance.label.localizedCaseInsensitiveContains("gold"))
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'gold'")).firstMatch.exists)
    }

    @MainActor
    func testUsageFitsAtLargestTextAndInDarkMode() {
        continueAfterFailure = false
        let app = launch(largeText: true, dark: true)
        let total = app.staticTexts["usage.total"]
        reach(app, total)
        XCTAssertTrue(total.exists)
        app.buttons["Week"].firstMatch.tap()
        XCTAssertTrue(app.buttons["usage.title"].exists)
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = "progress-usage-large-dark"; shot.lifetime = .keepAlways; add(shot)
    }
}
