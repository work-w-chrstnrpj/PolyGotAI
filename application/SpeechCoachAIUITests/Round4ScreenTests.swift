import XCTest

final class Round4ScreenTests: XCTestCase {
    override func setUp() { super.setUp(); continueAfterFailure = false }
    @MainActor private func launch(enabled: Bool = false, failure: Bool = false, large: Bool = false) -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchEnvironment["SC_LAB_FEEDBACK_FIXTURE"] = "1"
        app.launchEnvironment["SC_LAB_FEEDBACK_ENABLED"] = enabled ? "1" : "0"
        if failure { app.launchEnvironment["SC_LAB_FEEDBACK_FAILURE"] = "1" }
        if large {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
            app.launchEnvironment["SC_REWARD_DARK_FIXTURE"] = "1"
        }
        app.launch()
        tap(app, app.buttons["settings.open"].firstMatch)
        return app
    }
    @MainActor private func tap(_ app: XCUIApplication, _ element: XCUIElement) {
        for _ in 0..<16 {
            if element.exists && element.isHittable { element.tap(); return }
            if element.exists && element.frame.midY < app.frame.midY { app.swipeDown() } else { app.swipeUp() }
        }
        XCTAssertTrue(element.waitForExistence(timeout: 5)); element.tap()
    }
    @MainActor func testFeedbackStaysHiddenWithoutVerification() {
        let app = launch()
        tap(app, app.buttons["settings.ui-fixture"])
        XCTAssertTrue(app.staticTexts["fixture.requests"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["fixture.requests"].label, "Requests: 0")
        XCTAssertFalse(app.buttons["ai.send"].exists)
        XCTAssertFalse(app.staticTexts["ai.disclosure"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["ai.result"].firstMatch.exists)
    }
    @MainActor func testFeedbackRequiresTapAndShowsValidatedResult() {
        let app = launch(enabled: true)
        tap(app, app.buttons["settings.ui-fixture"])
        XCTAssertTrue(app.staticTexts["ai.disclosure"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["fixture.requests"].label, "Requests: 0")
        tap(app, app.buttons["ai.privacy"])
        XCTAssertTrue(app.navigationBars["Cost and privacy"].waitForExistence(timeout: 5))
        app.buttons["Done"].firstMatch.tap()
        XCTAssertEqual(app.staticTexts["fixture.requests"].label, "Requests: 0")
        tap(app, app.buttons["ai.send"])
        XCTAssertTrue(app.staticTexts["ai.summary"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts["ai.summary"].label, "Your meaning is clear.")
        XCTAssertEqual(app.staticTexts["fixture.requests"].label, "Requests: 1")
        XCTAssertTrue(app.staticTexts["Yesterday I go"].exists)
        capture("feedback-result")
    }
    @MainActor func testSavedFeedbackAppearsInHistoryAndCanBeDeleted() {
        let app = launch(enabled: true)
        tap(app, app.buttons["settings.ui-fixture"])
        tap(app, app.buttons["ai.send"])
        XCTAssertTrue(app.staticTexts["ai.summary"].waitForExistence(timeout: 10))
        tap(app, app.buttons["fixture.history"])
        XCTAssertTrue(app.staticTexts["feedback.summary"].waitForExistence(timeout: 5))
        tap(app, app.buttons["feedback.record"])
        XCTAssertTrue(app.staticTexts["feedback.transcript"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["feedback.transcript"].label, "Yesterday I go to the market.")
        capture("feedback-history-record")
        tap(app, app.buttons["feedback.delete"])
        XCTAssertTrue(app.navigationBars["Feedback history"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["feedback.record"].exists)
    }
    @MainActor func testSpecializedWordsAreReviewedBeforeSaving() {
        let app = launch(enabled: true)
        tap(app, app.buttons["settings.ui-fixture"])
        tap(app, app.buttons["fixture.specialized"])
        let topic = app.textFields["specialized.topic"]
        XCTAssertTrue(topic.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["specialized.generate"].isEnabled)
        topic.tap(); topic.typeText("Courtroom")
        tap(app, app.buttons["specialized.generate"])
        let gavel = app.descendants(matching: .any)["specialized.word.gavel"].firstMatch
        if !gavel.waitForExistence(timeout: 10) { XCTFail(app.debugDescription) }
        XCTAssertFalse(app.buttons["specialized.save"].isEnabled)
        tap(app, gavel)
        tap(app, app.buttons["specialized.save"])
        XCTAssertTrue(app.staticTexts["specialized.saved"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["specialized.saved"].label, "Added 1 word.")
        capture("specialized-words")
    }
    @MainActor func testProviderErrorDoesNotRetryOrShowAResult() {
        let app = launch(enabled: true, failure: true)
        tap(app, app.buttons["settings.ui-fixture"])
        tap(app, app.buttons["ai.send"])
        XCTAssertTrue(app.staticTexts["ai.error"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts["ai.error"].label, "Provider quota is unavailable.")
        XCTAssertEqual(app.staticTexts["fixture.requests"].label, "Requests: 1")
        XCTAssertFalse(app.descendants(matching: .any)["ai.result"].firstMatch.exists)
    }
    @MainActor func testProviderValuesStayMaskedAndTestIsLocal() {
        let app = launch()
        tap(app, app.buttons["settings.provider"])
        tap(app, app.buttons["provider.test"])
        XCTAssertEqual(app.staticTexts["provider.message"].label, "Add your provider key in Settings.")
        let workspace = app.secureTextFields["provider.workspace"]
        workspace.tap(); workspace.typeText("synthetic-workspace")
        let key = app.secureTextFields["provider.key"]
        key.tap(); key.typeText("synthetic-key")
        tap(app, app.buttons["provider.save"])
        XCTAssertTrue(app.descendants(matching: .any)["provider.saved"].firstMatch.waitForExistence(timeout: 5))
        tap(app, app.buttons["provider.test"])
        XCTAssertEqual(app.staticTexts["provider.message"].label, "Saved values found.")
        XCTAssertFalse(app.staticTexts["synthetic-workspace"].exists)
        XCTAssertFalse(app.staticTexts["synthetic-key"].exists)
        XCTAssertFalse(app.buttons["provider.privacy"].exists)
        capture("masked-settings")
    }
    @MainActor func testThreeSyntheticStagesAtLargestTextInDarkMode() {
        let app = launch(large: true)
        tap(app, app.buttons["settings.ui-fixture"])
        tap(app, app.buttons["fixture.track"])
        for id in ["foundation", "intermediate", "advanced"] {
            tap(app, app.buttons["track.stage.\(id)"])
            XCTAssertTrue(app.buttons["track.unit.\(id)"].exists)
        }
        XCTAssertEqual(app.staticTexts["track.progress"].label, "0 of 3 lessons done")
        tap(app, app.buttons["track.unit.advanced"])
        XCTAssertTrue(app.buttons["track.lesson.synthetic-advanced"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()
        app.swipeUp()
        capture("three-stages-large-dark")
    }
    @MainActor func testRealGrammarianShowsAllFourStages() {
        let app = launch(large: true)
        app.buttons["settings.done"].tap()
        let tab = app.tabBars.buttons["Lesson"]
        if tab.exists { tab.tap() } else { tap(app, app.buttons["navigation.learn"].firstMatch) }
        tap(app, app.segmentedControls["learn.mode"].buttons["Coaches"])
        tap(app, app.buttons["coach.card.grammarian"])
        // The topic syllabus keeps its four stages (46 lessons since 2026-10-30).
        for (id, units) in [("starter", 3), ("foundation", 4), ("intermediate", 4), ("advanced", 4)] {
            tap(app, app.buttons["track.stage.\(id)"])
            XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "track.unit.")).count, units)
        }
        XCTAssertEqual(app.staticTexts["track.progress"].label, "0 of 46 lessons done")
        app.swipeUp()
        capture("real-four-stages-large-dark")
    }

    @MainActor private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "round4-\(name)"; attachment.lifetime = .keepAlways; add(attachment)
    }
}
