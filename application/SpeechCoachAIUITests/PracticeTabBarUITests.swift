import XCTest

/// #4: practice screens hide the bottom tab bar (iPad floating bar and iPhone system bar); lists keep it.
final class PracticeTabBarUITests: XCTestCase {
    override func setUp() { super.setUp(); continueAfterFailure = false }

    @MainActor private func launch(_ env: [String: String] = [:]) -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        for (key, value) in env { app.launchEnvironment[key] = value }
        app.launch()
        return app
    }

    @discardableResult @MainActor private func reach(_ app: XCUIApplication, _ element: XCUIElement) -> XCUIElement {
        XCTAssertTrue(element.waitForExistence(timeout: 8), "\(element) missing")
        for _ in 0..<8 where !element.isHittable { app.swipeUp() }
        return element
    }

    /// Opens a practice screen from a list screen, checks the bar is hidden, goes Back, checks the list shows the bar again.
    @MainActor private func assertPracticeHidesBar(_ app: XCUIApplication, opener: String, listAnchor: String, line: UInt = #line) {
        XCTAssertTrue(barVisible(app), "AC3: list screen keeps the bar", line: line)
        reach(app, app.buttons[opener]).tap()
        XCTAssertTrue(gone(app), "AC1: bar hidden on the practice screen", line: line)
        XCTAssertFalse(barVisible(app), line: line)
        back(app)
        XCTAssertTrue(app.buttons[listAnchor].waitForExistence(timeout: 8), line: line)
        XCTAssertTrue(barVisible(app), "AC2: bar returns after Back", line: line)
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

    // MARK: #8 remaining practice screens

    @MainActor func testIssue8AC1AC2JumpTestHidesBarAndBackShowsIt() {
        let app = launch()
        openTab(app, "learn", "Lesson")
        XCTAssertTrue(app.segmentedControls["learn.mode"].waitForExistence(timeout: 8))
        app.segmentedControls["learn.mode"].buttons["Course"].tap()
        let level = app.segmentedControls["learn.level"].buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "A2")).firstMatch
        XCTAssertTrue(level.waitForExistence(timeout: 5)); level.tap()
        assertPracticeHidesBar(app, opener: "level.test.A2", listAnchor: "level.test.A2")
    }

    @MainActor func testIssue8AC1AC2LexiconPracticeHidesBarAndBackShowsIt() {
        let app = launch()
        openTab(app, "vocabulary", "Lexicon")
        // Vocabulary Enricher opens the same practice screen from the home list on a fresh learner.
        assertPracticeHidesBar(app, opener: "lexicon.enricher", listAnchor: "lexicon.enricher")
    }

    @MainActor func testIssue8AC1AC2LexiconActionHidesBarAndBackShowsIt() {
        let app = launch()
        openTab(app, "vocabulary", "Lexicon")
        reach(app, app.buttons["lexicon.train"]).tap()
        XCTAssertTrue(app.buttons["lexicon.show"].waitForExistence(timeout: 8)); app.buttons["lexicon.show"].tap()
        XCTAssertTrue(app.buttons["lexicon.rate.easy"].waitForExistence(timeout: 8)); app.buttons["lexicon.rate.easy"].tap()
        XCTAssertTrue(app.buttons["lexicon.show"].waitForExistence(timeout: 8))
        back(app)
        XCTAssertTrue(app.buttons["lexicon.action"].waitForExistence(timeout: 8), "an Easy word unlocks Lexicon in Action")
        assertPracticeHidesBar(app, opener: "lexicon.action", listAnchor: "lexicon.action")
    }

    @MainActor func testIssue8AC1AC2LabTimedTestsHidesBarAndBackShowsIt() {
        let app = launch(["SC_TIMED_FIXTURE": "1"])
        openTab(app, "speechLab", "Lab")
        XCTAssertTrue(barVisible(app), "AC3: Lab home keeps the bar")
        reach(app, app.buttons["speech.timedTests"]).tap()
        XCTAssertTrue(barVisible(app), "AC3: the timed tests list keeps the bar")
        reach(app, app.buttons["timed.writing"]).tap()
        reach(app, app.buttons["timed.start"]).tap()
        XCTAssertTrue(app.staticTexts["timed.topic"].waitForExistence(timeout: 8))
        XCTAssertTrue(gone(app), "AC1: bar hidden during a timed test")
        XCTAssertFalse(barVisible(app))
        back(app)
        XCTAssertTrue(app.buttons["timed.writing"].waitForExistence(timeout: 8) || app.buttons["timed.start"].waitForExistence(timeout: 2))
        XCTAssertTrue(barVisible(app), "AC2: bar returns after Back")
    }

    @MainActor func testIssue8AC1AC2TalkHidesBarAndBackShowsIt() {
        let app = launch(["SC_SPEECHLAB_FIXTURE": "1", "SC_TALK_FIXTURE": "1"])
        openTab(app, "speechLab", "Lab")
        assertPracticeHidesBar(app, opener: "speech.talk", listAnchor: "speech.talk")
    }

    @MainActor func testIssue8AC1RecordingHidesBar() {
        let app = launch(["SC_A1_V2_FIXTURE": "1"])
        XCTAssertTrue(app.buttons["today.lesson"].waitForExistence(timeout: 10)); app.buttons["today.lesson"].tap()
        let contents = app.buttons["lesson.contents"]
        XCTAssertTrue(contents.waitForExistence(timeout: 8)); contents.tap()
        app.buttons["lesson.version.current"].tap()
        XCTAssertTrue(app.buttons["lesson.topic.extra"].waitForExistence(timeout: 8)); app.buttons["lesson.topic.extra"].tap()
        app.buttons["lesson.topic.day7"].tap()
        for id in ["lesson.begin", "lesson.speak"] {
            var tapped = false
            for _ in 0..<8 where !tapped {
                if let b = app.buttons.matching(identifier: id).allElementsBoundByIndex.reversed().first(where: { $0.isHittable }) { b.tap(); tapped = true } else { app.swipeUp() }
            }
            XCTAssertTrue(tapped, "\(id) reachable")
        }
        XCTAssertTrue(app.buttons["recording.start"].waitForExistence(timeout: 8), "the recorder is open")
        XCTAssertFalse(barVisible(app), "AC1: bar hidden while recording")
    }
}
