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

    @MainActor
    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "phase3-\(name)"; attachment.lifetime = .keepAlways; add(attachment)
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
        app.buttons["lexicon.add"].tap()
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
        let work = app.switches["lexicon.group.work-office"]
        XCTAssertTrue(work.waitForExistence(timeout: 5))
        XCTAssertEqual(work.value as? String, "0")
        work.tap()
        XCTAssertEqual(work.value as? String, "1")
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
