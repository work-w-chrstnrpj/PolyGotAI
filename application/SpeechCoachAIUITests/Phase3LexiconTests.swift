import XCTest

final class Phase3LexiconTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    private func launch(largeText: Bool = false) -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        if largeText { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        app.launch()
        return app
    }

    @MainActor
    private func openLexicon(_ app: XCUIApplication) {
        let tab = app.tabBars.buttons["Lexicon"]
        if tab.waitForExistence(timeout: 3) { tab.tap() }
        else {
            let button = app.buttons["navigation.vocabulary"].firstMatch
            XCTAssertTrue(button.waitForExistence(timeout: 8)); button.tap()
        }
        XCTAssertTrue(app.buttons["lexicon.train"].waitForExistence(timeout: 8))
    }

    @MainActor @discardableResult
    private func reach(_ app: XCUIApplication, _ element: XCUIElement) -> XCUIElement {
        for _ in 0..<12 where !(element.exists && element.isHittable) { app.swipeUp() }
        XCTAssertTrue(element.isHittable, element.identifier)
        return element
    }
    @MainActor
    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "phase3-\(name)"; attachment.lifetime = .keepAlways; add(attachment)
    }

    @MainActor
    func testLargestTextNavigationAndFieldPacks() {
        let app = launch(largeText: true)
        openLexicon(app)
        let navigation = app.buttons["navigation.vocabulary"].firstMatch
        if navigation.exists {
            XCTAssertEqual(navigation.label, "Lexicon")
            XCTAssertTrue(navigation.isHittable)
        }
        // Phase 8: packs are chosen in Training settings.
        reach(app, app.buttons["lexicon.settings"]).tap()
        XCTAssertTrue(app.buttons["lexicon.settings.done"].waitForExistence(timeout: 5))
        for _ in 0..<40 where !app.staticTexts["Field packs"].isHittable { app.swipeUp() }
        XCTAssertTrue(app.staticTexts["Field packs"].isHittable)
        // Every field label remains reachable at the largest accessibility size.
        let business = app.staticTexts["Business and finance"].firstMatch
        XCTAssertTrue(business.exists)
        for _ in 0..<4 where !business.isHittable { app.swipeUp() }
        XCTAssertTrue(business.isHittable)
        for _ in 0..<4 where business.frame.midY > app.frame.midY { app.swipeUp() }
        capture(app, "largest-text-field-packs")
        app.buttons["lexicon.settings.done"].tap()
        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        let landscape = expectation(for: NSPredicate { _, _ in app.frame.width > app.frame.height }, evaluatedWith: app)
        wait(for: [landscape], timeout: 8)
        let tab = app.tabBars.buttons["Lexicon"]
        if tab.exists {
            XCTAssertTrue(tab.isHittable)
            XCTAssertEqual(tab.label, "Lexicon")
        } else {
            XCTAssertTrue(app.buttons["navigation.vocabulary"].firstMatch.waitForExistence(timeout: 5))
            XCTAssertEqual(app.buttons["navigation.vocabulary"].firstMatch.label, "Lexicon")
            let sidebar = app.buttons["navigation.vocabulary"].firstMatch
            let sidebarReady = expectation(for: NSPredicate { _, _ in sidebar.frame.width > 200 && sidebar.frame.maxX < 320 }, evaluatedWith: sidebar)
            wait(for: [sidebarReady], timeout: 8)
            sidebar.tap()
        }
        capture(app, "largest-text-sidebar")
    }

    @MainActor
    func testTodayShowsOneWordOfTheDay() {
        let app = launch()
        XCTAssertTrue(app.descendants(matching: .any)["daily.lexicon"].firstMatch.waitForExistence(timeout: 8))
        XCTAssertEqual(app.staticTexts["daily.lexicon.lemma"].label, "happy")
        capture(app, "today-word")
    }

    @MainActor
    func testTrainingARatedEasyWordOpensLexiconInAction() {
        let app = launch()
        openLexicon(app)
        XCTAssertFalse(app.buttons["lexicon.action"].exists, "Lexicon in Action stays hidden until a word is Easy.")
        capture(app, "home")
        app.buttons["lexicon.train"].tap()
        XCTAssertTrue(app.buttons["lexicon.show"].waitForExistence(timeout: 5))
        app.buttons["lexicon.show"].tap()
        XCTAssertTrue(app.staticTexts["lexicon.meaning"].waitForExistence(timeout: 5))
        capture(app, "training-revealed")
        app.buttons["lexicon.rate.easy"].tap()
        XCTAssertTrue(app.buttons["lexicon.show"].waitForExistence(timeout: 5), "The next word follows.")
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.buttons["lexicon.action"].waitForExistence(timeout: 5))
        app.buttons["lexicon.action"].tap()
        XCTAssertTrue(app.staticTexts["exercise.prompt"].waitForExistence(timeout: 5))
        capture(app, "action-question")
    }

    @MainActor
    func testAWordAlreadyInTheLexiconIsNotAddedTwice() {
        let app = launch()
        openLexicon(app)
        reach(app, app.buttons["lexicon.add"]).tap()
        let word = app.textFields["lexicon.add.word"]
        XCTAssertTrue(word.waitForExistence(timeout: 5))
        word.tap(); word.typeText("  Happy ")
        let meaning = app.textFields["lexicon.add.meaning"]
        meaning.tap(); meaning.typeText("Feeling good")
        app.buttons["lexicon.add.save"].tap()
        XCTAssertTrue(app.staticTexts["lexicon.add.duplicate"].waitForExistence(timeout: 5))
        capture(app, "duplicate")
        // A new word is added.
        word.tap(); word.clearAndType("Zebra")
        app.buttons["lexicon.add.save"].tap()
        XCTAssertTrue(app.staticTexts["lexicon.add.saved"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testGroupSwitchesAndLargeText() {
        let app = launch(largeText: true)
        openLexicon(app)
        reach(app, app.buttons["lexicon.settings"]).tap()
        XCTAssertTrue(app.buttons["lexicon.settings.done"].waitForExistence(timeout: 5))
        // Form rows are created as they scroll into view.
        let people = app.switches["lexicon.settings.pack.a1-people-places"]
        for _ in 0..<20 where !(people.exists && people.isHittable) { app.swipeUp() }
        XCTAssertTrue(people.waitForExistence(timeout: 5))
        XCTAssertEqual(people.value as? String, "0")
        // Press the switch itself; iOS 26 switches ignore zero-length synthetic taps (a finger works).
        let control = people.switches.firstMatch.exists ? people.switches.firstMatch : people
        control.press(forDuration: 0.2)
        let on = expectation(for: NSPredicate { _, _ in (people.value as? String) == "1" }, evaluatedWith: nil)
        wait(for: [on], timeout: 5)
        capture(app, "large-text")
    }
}

private extension XCUIElement {
    func clearAndType(_ text: String) {
        guard let current = value as? String else { typeText(text); return }
        typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
        typeText(text)
    }
}
