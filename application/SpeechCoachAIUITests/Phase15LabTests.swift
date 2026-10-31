import XCTest

/// Phase 15: Lab Videos (watched list) and Timed tests with synthetic AI replies.
final class Phase15LabTests: XCTestCase {
    override func setUp() { super.setUp(); continueAfterFailure = false }

    @MainActor private func launch(fixture: Bool, seconds: Int? = nil) -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        if fixture { app.launchEnvironment["SC_TIMED_FIXTURE"] = "1" }
        if let seconds { app.launchEnvironment["SC_TIMED_SECONDS"] = String(seconds) }
        app.launch()
        let tab = app.tabBars.buttons["Lab"]
        if tab.waitForExistence(timeout: 3) { tab.tap() }
        else {
            let button = app.buttons["navigation.speechLab"].firstMatch
            XCTAssertTrue(button.waitForExistence(timeout: 8)); button.tap()
        }
        return app
    }

    @MainActor private func tap(_ app: XCUIApplication, _ element: XCUIElement) {
        for _ in 0..<10 {
            if element.exists && element.isHittable { break }
            if element.exists && element.frame.maxY < app.frame.midY { app.swipeDown() } else { app.swipeUp() }
        }
        XCTAssertTrue(element.waitForExistence(timeout: 5)); XCTAssertTrue(element.isHittable); element.tap()
    }

    @MainActor private func capture(_ name: String) {
        let item = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        item.name = "phase15-\(name)"; item.lifetime = .keepAlways; add(item)
    }

    @MainActor func testVideosByTopicCanBeMarkedWatchedAndChannelsFavorited() {
        let app = launch(fixture: false)
        tap(app, app.buttons["speech.videos"])
        XCTAssertTrue(app.staticTexts["videos.count"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["videos.count"].label.hasPrefix("0 of "))
        XCTAssertTrue(app.buttons["videos.open.tw25CM1MXlU"].exists, "Pronunciation is the first topic")
        tap(app, app.buttons["videos.topic"])
        tap(app, app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Speaking ('")).firstMatch)
        XCTAssertTrue(app.buttons["videos.watched.Rj5W40LjspA"].waitForExistence(timeout: 5))
        let toggle = app.buttons["videos.watched.Rj5W40LjspA"]
        tap(app, toggle)
        XCTAssertEqual(toggle.label, "Watched")
        capture("videos")
        tap(app, app.buttons["videos.channels"])
        let channel = app.switches["videos.channel.Alexander Lyon Communication Coach"]
        XCTAssertTrue(channel.waitForExistence(timeout: 5))
        // Tap the switch itself; the row's centre is its label.
        channel.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        XCTAssertEqual(channel.value as? String, "1")
        tap(app, app.buttons["videos.channels.done"])
        app.navigationBars.buttons.firstMatch.tap()
        tap(app, app.buttons["speech.videos"])
        XCTAssertTrue(app.staticTexts["videos.count"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["videos.count"].label.hasPrefix("1 of "))
        // The topic is remembered and the favorite channel's first unwatched video now leads it.
        let first = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'videos.open.'")).firstMatch
        XCTAssertEqual(first.identifier, "videos.open.r1i0a8zQnP0")
    }

    @MainActor func testStartWithoutAKeyOpensSetup() {
        let app = launch(fixture: false)
        tap(app, app.buttons["speech.timedTests"])
        tap(app, app.buttons["timed.writing"])
        tap(app, app.buttons["timed.start"])
        XCTAssertTrue(app.navigationBars["Provider setup"].waitForExistence(timeout: 5))
    }

    @MainActor func testWritingSendsItselfWhenTimeRunsOut() {
        let app = launch(fixture: true, seconds: 12)
        tap(app, app.buttons["speech.timedTests"])
        tap(app, app.buttons["timed.writing"])
        tap(app, app.buttons["timed.start"])
        XCTAssertTrue(app.staticTexts["timed.topic"].waitForExistence(timeout: 8))
        let editor = app.textViews["timed.text"]
        tap(app, editor); editor.typeText("Every morning I make coffee first.")
        capture("writing")
        XCTAssertTrue(app.staticTexts["ai.summary"].waitForExistence(timeout: 25), "feedback arrives after the timer ends")
        capture("writing-feedback")
    }

    @MainActor func testReadingAndAnalogiesScoreTheAnswers() {
        let app = launch(fixture: true)
        tap(app, app.buttons["speech.timedTests"])
        tap(app, app.buttons["timed.reading"])
        tap(app, app.buttons["timed.start"])
        XCTAssertTrue(app.staticTexts["timed.passage"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["timed.clock"].exists || app.otherElements["timed.clock"].exists)
        capture("reading")
        tap(app, app.buttons["timed.finish"])
        XCTAssertTrue(app.staticTexts["0 of 5 correct"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()
        tap(app, app.buttons["timed.analogies"])
        tap(app, app.buttons["timed.start"])
        XCTAssertTrue(app.buttons["timed.item.0.0"].waitForExistence(timeout: 8))
        capture("analogies")
        tap(app, app.buttons["timed.finish"])
        XCTAssertTrue(app.staticTexts["0 of 10 correct"].waitForExistence(timeout: 5))
    }
}
