import XCTest

final class Phase13TopicLessonTests: XCTestCase {
    override func setUp() { super.setUp(); continueAfterFailure = false }
    @MainActor private func launch(large: Bool = false) -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        if large {
            app.launchEnvironment["SC_REWARD_DARK_FIXTURE"] = "1"
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        }
        app.launch(); coaches(app); return app
    }
    @MainActor private func tap(_ app: XCUIApplication, _ item: XCUIElement) {
        for _ in 0..<12 {
            if item.exists && item.isHittable { item.tap(); return }
            if item.exists && item.frame.midY < app.frame.midY { app.swipeDown() } else { app.swipeUp() }
        }
        XCTFail("Cannot reach \(item)")
    }
    @MainActor private func coaches(_ app: XCUIApplication) {
        let tab = app.tabBars.buttons["Lesson"]
        if tab.waitForExistence(timeout: 4) { tab.tap() }
        else { tap(app, app.buttons["navigation.learn"].firstMatch) }
        tap(app, app.segmentedControls["learn.mode"].buttons["Coaches"])
    }
    @MainActor private func capture(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot); attachment.name = "phase13-" + name; attachment.lifetime = .keepAlways; add(attachment)
        let folder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("Phase13Evidence")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try? screenshot.pngRepresentation.write(to: folder.appendingPathComponent(name + ".png"))
    }
    @MainActor func testReadingCheckpointRelaunchAndRereadPreserveExercisePosition() {
        let app = launch()
        tap(app, app.buttons["coach.card.grammarian"])
        tap(app, app.buttons["track.unit.parts-of-speech"])
        tap(app, app.buttons["track.lesson.grammarian-topic-nouns"])
        XCTAssertTrue(app.staticTexts["lesson.reading.position"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["lesson.reading.position"].label, "Read · 1 of 4")
        XCTAssertFalse(app.buttons["exercise.check"].exists)
        capture("nouns-reading")
        tap(app, app.buttons["lesson.reading.next"]); tap(app, app.buttons["lesson.reading.next"])
        XCTAssertEqual(app.staticTexts["lesson.reading.position"].label, "Read · 3 of 4")
        app.terminate(); app.launch(); coaches(app)
        tap(app, app.buttons["coach.continue"])
        XCTAssertEqual(app.staticTexts["lesson.reading.position"].label, "Read · 3 of 4")
        tap(app, app.buttons["lesson.reading.back"])
        XCTAssertEqual(app.staticTexts["lesson.reading.position"].label, "Read · 2 of 4")
        for _ in 0..<3 { tap(app, app.buttons["lesson.reading.next"]) }
        XCTAssertTrue(app.staticTexts["exercise.prompt"].waitForExistence(timeout: 5))
        capture("nouns-exercise")
        tap(app, app.buttons["exercise.choice.garden"])
        tap(app, app.buttons["exercise.check"])
        XCTAssertTrue(app.staticTexts["Correct!"].waitForExistence(timeout: 5))
        tap(app, app.buttons["exercise.continue"])
        XCTAssertTrue(app.staticTexts["2 of 19"].exists)
        tap(app, app.buttons["lesson.contents"])
        tap(app, app.buttons["lesson.reading.open.0"])
        XCTAssertEqual(app.staticTexts["lesson.reading.position"].label, "Read · 1 of 4")
        tap(app, app.buttons["lesson.contents"])
        tap(app, app.buttons["lesson.reading.exercises"])
        XCTAssertTrue(app.staticTexts["2 of 19"].waitForExistence(timeout: 5))
        // The visible "Lesson" button re-opens the reading; "Back to exercise" returns to the same item.
        tap(app, app.buttons["lesson.reading.reopen"])
        XCTAssertEqual(app.staticTexts["lesson.reading.position"].label, "Read · 1 of 4")
        capture("reread-mid-exercise")
        tap(app, app.buttons["lesson.reading.resume"])
        XCTAssertTrue(app.staticTexts["2 of 19"].waitForExistence(timeout: 5))
        app.terminate(); app.launch(); coaches(app); tap(app, app.buttons["coach.continue"])
        XCTAssertTrue(app.staticTexts["2 of 19"].waitForExistence(timeout: 5))
        capture("resumed-exercise")
    }
    @MainActor func testBusinessReadingAtLargestTextInDarkModeAndRotation() throws {
        let app = launch(large: true)
        tap(app, app.buttons["coach.card.business"])
        tap(app, app.buttons["track.unit.everyday"])
        tap(app, app.buttons["track.lesson.business-topic-introductions-and-meetings"])
        XCTAssertTrue(app.staticTexts["lesson.reading.heading"].waitForExistence(timeout: 5))
        capture("business-largest-dark")
        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        XCTAssertTrue(app.buttons["lesson.reading.next"].exists)
        tap(app, app.buttons["lesson.reading.next"])
        XCTAssertEqual(app.staticTexts["lesson.reading.position"].label, "Read · 2 of 2")
        capture("business-landscape-dark")
        XCUIDevice.shared.orientation = .portrait
        tap(app, app.buttons["lesson.reading.next"])
        XCTAssertTrue(app.buttons["exercise.check"].waitForExistence(timeout: 5))
    }
}
