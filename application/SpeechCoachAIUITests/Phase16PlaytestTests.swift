import XCTest

/// Phase 16 play-test fixes, round 3 (2026-10-30): celebration overlay, Vocabulary Enricher, IPA, Daily Training repeats
/// and the sound settings.
final class Phase16PlaytestTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    private func launch(_ environment: [String: String] = [:]) -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        for (key, value) in environment { app.launchEnvironment[key] = value }
        app.launch()
        return app
    }

    @MainActor
    private func tab(_ app: XCUIApplication, _ name: String, fallback: String) {
        let button = app.tabBars.buttons[name]
        if button.waitForExistence(timeout: 5) { button.tap() } else { app.buttons[fallback].firstMatch.tap() }
    }

    @MainActor
    private func capture(_ name: String) {
        let item = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        item.name = "phase16-\(name)"; item.lifetime = .keepAlways; add(item)
    }

    @MainActor func testEarnedBadgesAreCelebratedOnce() {
        let app = launch(["SC_REWARD_FIXTURE": "1", "SC_CELEBRATION_FIXTURE": "1"])
        let card = app.descendants(matching: .any)["celebration"].firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["celebration.title"].label.contains("earned"), app.staticTexts["celebration.title"].label)
        capture("celebration")
        app.buttons["celebration.continue"].tap()
        XCTAssertFalse(card.waitForExistence(timeout: 3), "dismissed")
        // Relaunching does not celebrate the same badges again.
        app.terminate(); app.launch()
        XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 10) || app.buttons["navigation.today"].exists)
        XCTAssertFalse(card.waitForExistence(timeout: 4))
    }

    @MainActor func testVocabularyEnricherAsksAboutAnyPackWord() {
        let app = launch()
        tab(app, "Lexicon", fallback: "navigation.vocabulary")
        let enricher = app.buttons["lexicon.enricher"]
        XCTAssertTrue(enricher.waitForExistence(timeout: 8))
        for _ in 0..<6 where !enricher.isHittable { app.swipeUp() }
        enricher.tap()
        XCTAssertTrue(app.navigationBars["Vocabulary Enricher"].waitForExistence(timeout: 5))
        let choice = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'exercise.choice.'")).firstMatch
        XCTAssertTrue(choice.waitForExistence(timeout: 5))
        capture("enricher")
        choice.tap()
        app.buttons["exercise.check"].tap()
        XCTAssertTrue(app.buttons["exercise.continue"].waitForExistence(timeout: 5))
    }

    @MainActor func testTrainingShowsIPAAndAgainKeepsTheWordInThePile() {
        let app = launch()
        tab(app, "Lexicon", fallback: "navigation.vocabulary")
        XCTAssertTrue(app.buttons["lexicon.train"].waitForExistence(timeout: 8))
        app.buttons["lexicon.train"].tap()
        XCTAssertTrue(app.buttons["lexicon.show"].waitForExistence(timeout: 5))
        let ipa = app.staticTexts["lexicon.ipa"]
        XCTAssertTrue(ipa.exists)
        XCTAssertTrue("\(ipa.value ?? "")\(ipa.label)".contains("/"), "\(String(describing: ipa.value)) \(ipa.label)")
        let left = app.staticTexts["lexicon.left"].label
        let lemma = app.staticTexts["lexicon.lemma"].label
        app.buttons["lexicon.show"].tap()
        capture("training-ipa")
        app.buttons["lexicon.rate.again"].tap()
        // The same number of cards is left: the word went back into the pile.
        XCTAssertTrue(app.buttons["lexicon.show"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["lexicon.left"].label, left)
        XCTAssertNotEqual(app.staticTexts["lexicon.lemma"].label, lemma, "a new word comes first while the repeat waits")
    }

    @MainActor func testSoundAndHapticsSettings() {
        let app = launch()
        let open = app.buttons["settings.open"].firstMatch
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        open.tap()
        for id in ["settings.music", "settings.effects", "settings.haptics"] {
            XCTAssertTrue(app.switches[id].waitForExistence(timeout: 5), id)
        }
        capture("sound-settings")
    }
}
