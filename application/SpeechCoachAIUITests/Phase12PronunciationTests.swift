import XCTest

/// Phase 12: Pronunciation is a coach under Lesson. Read the pages, then say the word (fixture voice) and train the ear.
final class Phase12PronunciationTests: XCTestCase {
    override func setUp() { super.setUp(); continueAfterFailure = false }

    @MainActor private func launch(large: Bool = false) -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        if large {
            app.launchEnvironment["SC_REWARD_DARK_FIXTURE"] = "1"
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        }
        app.launch()
        let tab = app.tabBars.buttons["Lesson"]
        if tab.waitForExistence(timeout: 4) { tab.tap() } else { tap(app, app.buttons["navigation.learn"].firstMatch) }
        tap(app, app.segmentedControls["learn.mode"].buttons["Coaches"])
        return app
    }

    @MainActor private func tap(_ app: XCUIApplication, _ item: XCUIElement) {
        for _ in 0..<12 {
            if item.exists && item.isHittable { item.tap(); return }
            if item.exists && item.frame.midY < app.frame.midY { app.swipeDown() } else { app.swipeUp() }
        }
        XCTFail("Cannot reach \(item)")
    }

    @MainActor private func capture(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot); attachment.name = "phase12-" + name; attachment.lifetime = .keepAlways; add(attachment)
        let folder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("Phase12Evidence")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try? screenshot.pngRepresentation.write(to: folder.appendingPathComponent(name + ".png"))
    }

    @MainActor func testPronunciationCoachReadsThenSaysAndListens() {
        let app = launch()
        tap(app, app.buttons["coach.card.pronunciation"])
        tap(app, app.buttons["track.unit.vowels"])
        tap(app, app.buttons["track.lesson.pronunciation-long-and-short-vowels"])
        XCTAssertTrue(app.staticTexts["lesson.reading.position"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["lesson.reading.position"].label, "Read · 1 of 3")
        capture("vowels-reading")
        for _ in 0..<3 { tap(app, app.buttons["lesson.reading.next"]) }
        // Say it: answered by voice only; there is no text field.
        XCTAssertTrue(app.buttons["exercise.speak"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.textFields["exercise.field"].exists)
        tap(app, app.buttons["exercise.speak"])
        XCTAssertTrue(app.staticTexts["exercise.heard"].waitForExistence(timeout: 5))
        capture("say-it")
        tap(app, app.buttons["exercise.check"])
        XCTAssertTrue(app.staticTexts["Correct!"].waitForExistence(timeout: 5))
        tap(app, app.buttons["exercise.continue"])
        // Skip ahead to the first ear-training item (item 8).
        for _ in 0..<6 {
            tap(app, app.buttons["exercise.speak"]); tap(app, app.buttons["exercise.check"])
            XCTAssertTrue(app.staticTexts["Correct!"].waitForExistence(timeout: 5))
            tap(app, app.buttons["exercise.continue"])
        }
        XCTAssertTrue(app.staticTexts["exercise.prompt"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["exercise.prompt"].label, "Listen. Which word do you hear?")
        tap(app, app.buttons["exercise.choice.beat"])
        tap(app, app.buttons["exercise.check"])
        XCTAssertTrue(app.staticTexts["Correct!"].waitForExistence(timeout: 5))
        capture("listen")
    }

    @MainActor func testPronunciationReadingAtLargestTextInDarkMode() throws {
        let app = launch(large: true)
        tap(app, app.buttons["coach.card.pronunciation"])
        tap(app, app.buttons["track.unit.stress-rhythm"])
        tap(app, app.buttons["track.lesson.pronunciation-word-stress"])
        XCTAssertTrue(app.staticTexts["lesson.reading.heading"].waitForExistence(timeout: 5))
        capture("stress-largest-dark")
        try app.performAccessibilityAudit(for: [.dynamicType, .sufficientElementDescription])
    }
}
