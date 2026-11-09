import XCTest

/// #4: practice screens hide the bottom tab bar (iPad floating bar and iPhone system bar); lists keep it.
final class PracticeTabBarUITests: XCTestCase {
    override func setUp() { super.setUp(); continueAfterFailure = false }

    @MainActor private func launch() -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        return app
    }

    /// The bar is the iPad floating bar (`navigation.*` buttons) or the iPhone tab bar.
    @MainActor private func barVisible(_ app: XCUIApplication) -> Bool {
        app.tabBars.firstMatch.exists || app.buttons["navigation.learn"].exists
    }

    @MainActor private func openTab(_ app: XCUIApplication, _ id: String, _ title: String) {
        let pad = app.buttons["navigation.\(id)"].firstMatch
        if pad.waitForExistence(timeout: 8) { pad.tap() } else { app.tabBars.buttons[title].tap() }
    }

    @MainActor private func back(_ app: XCUIApplication) {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    @MainActor private func gone(_ app: XCUIApplication) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let e = expectation(for: predicate, evaluatedWith: app.buttons["navigation.learn"].exists ? app.buttons["navigation.learn"] : app.tabBars.firstMatch)
        return XCTWaiter().wait(for: [e], timeout: 5) == .completed
    }

    @MainActor func testAC1LessonHidesBarAndBackShowsIt() {
        let app = launch()
        openTab(app, "learn", "Lesson")
        XCTAssertTrue(app.segmentedControls["learn.mode"].waitForExistence(timeout: 8))
        app.segmentedControls["learn.mode"].buttons["Course"].tap()
        XCTAssertTrue(barVisible(app), "AC3: lesson list keeps the bar")
        let open = app.buttons["learn.open.a1-greetings"]
        XCTAssertTrue(open.waitForExistence(timeout: 8)); open.tap()
        XCTAssertTrue(gone(app), "AC1: bar hidden in a lesson")
        XCTAssertFalse(barVisible(app))
        back(app)
        XCTAssertTrue(app.segmentedControls["learn.mode"].waitForExistence(timeout: 8))
        XCTAssertTrue(barVisible(app), "AC1: bar returns")
    }

    @MainActor func testAC2LexiconTrainingHidesBar() {
        let app = launch()
        openTab(app, "vocabulary", "Lexicon")
        XCTAssertTrue(barVisible(app), "AC3: Lexicon home keeps the bar")
        let train = app.buttons["lexicon.train"]
        XCTAssertTrue(train.waitForExistence(timeout: 8)); train.tap()
        XCTAssertTrue(gone(app), "AC2: Lexicon training hides the bar")
        back(app)
        XCTAssertTrue(app.buttons["lexicon.train"].waitForExistence(timeout: 8))
        XCTAssertTrue(barVisible(app))
    }

    @MainActor func testAC2LabVideosHidesBar() {
        let app = launch()
        openTab(app, "speechLab", "Lab")
        XCTAssertTrue(barVisible(app), "AC3: Lab home keeps the bar")
        let videos = app.buttons["speech.videos"]
        XCTAssertTrue(videos.waitForExistence(timeout: 8)); videos.tap()
        XCTAssertTrue(gone(app), "AC2: Lab videos hides the bar")
        back(app)
        XCTAssertTrue(app.buttons["speech.videos"].waitForExistence(timeout: 8))
        XCTAssertTrue(barVisible(app))
    }

    @MainActor func testAC3ProgressAndSettingsKeepBar() {
        let app = launch()
        openTab(app, "progress", "Progress")
        XCTAssertTrue(app.staticTexts["progress.level"].waitForExistence(timeout: 8))
        XCTAssertTrue(barVisible(app))
    }

    @MainActor func testAC4RotationKeepsPracticeScreenOpenAndBarHidden() {
        let app = launch()
        openTab(app, "speechLab", "Lab")
        let videos = app.buttons["speech.videos"]
        XCTAssertTrue(videos.waitForExistence(timeout: 8)); videos.tap()
        XCTAssertTrue(gone(app))
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(app.navigationBars["Videos"].waitForExistence(timeout: 5), "AC4: screen stays open")
        XCTAssertFalse(barVisible(app), "AC4: bar stays hidden")
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(app.navigationBars["Videos"].waitForExistence(timeout: 5))
        XCTAssertFalse(barVisible(app))
    }
}
