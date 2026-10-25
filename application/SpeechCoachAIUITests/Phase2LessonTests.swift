import XCTest

final class Phase2LessonTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    private func launch(largeText: Bool = false, dark: Bool = false) -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        if largeText { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        if dark { app.launchEnvironment["SC_REWARD_DARK_FIXTURE"] = "1" }
        app.launch()
        openLesson(app)
        app.segmentedControls["learn.mode"].buttons["Course"].tap()
        return app
    }

    @MainActor
    private func openLesson(_ app: XCUIApplication) {
        let tab = app.tabBars.buttons["Lesson"]
        if tab.waitForExistence(timeout: 3) { tab.tap() }
        else {
            let button = app.buttons["navigation.learn"].firstMatch
            XCTAssertTrue(button.waitForExistence(timeout: 8)); button.tap()
        }
        XCTAssertTrue(app.segmentedControls["learn.mode"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func selectLevel(_ name: String, in app: XCUIApplication) {
        let picker = app.segmentedControls["learn.level"]
        let button = picker.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", name)).firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 5)); button.tap()
    }

    @MainActor
    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "phase2-\(name)"; attachment.lifetime = .keepAlways; add(attachment)
    }

    @MainActor
    func testFreshLearnerCannotOpenLockedCourseLevels() {
        let app = launch()
        XCTAssertTrue(app.buttons["learn.open.a1-greetings"].waitForExistence(timeout: 5))
        selectLevel("C2", in: app)
        XCTAssertTrue(app.descendants(matching: .any)["level.locked.C2"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "learn.open.")).firstMatch.exists)
        XCTAssertFalse(app.buttons["level.test.C2"].exists)
        capture(app, "course-locked")
        selectLevel("A2", in: app)
        XCTAssertTrue(app.buttons["level.test.A2"].waitForExistence(timeout: 5))
        selectLevel("A1", in: app)
        XCTAssertTrue(app.buttons["learn.open.a1-greetings"].exists)
    }

    @MainActor
    func testFailedJumpTestRetakesWithoutUnlockingA2() {
        let app = launch()
        selectLevel("A2", in: app)
        app.buttons["level.test.A2"].tap()
        XCTAssertTrue(app.navigationBars["A2 test"].waitForExistence(timeout: 5))
        capture(app, "jump-question")
        for _ in 0..<20 {
            XCTAssertTrue(app.buttons["exercise.check"].waitForExistence(timeout: 5))
            answerArbitrarily(app)
            app.buttons["exercise.check"].tap()
            XCTAssertTrue(app.buttons["exercise.continue"].waitForExistence(timeout: 5))
            app.buttons["exercise.continue"].tap()
        }
        XCTAssertTrue(app.staticTexts["jumptest.result"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["jumptest.result"].label.contains("Try again."))
        capture(app, "jump-failed")
        app.buttons["jumptest.retry"].tap()
        XCTAssertTrue(app.buttons["exercise.check"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["1 of 20"].exists)
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.buttons["level.test.A2"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "learn.open.a2")).firstMatch.exists)
        // Verify the failed test did not persist an unlock on relaunch either.
        app.terminate(); app.launch(); openLesson(app)
        app.segmentedControls["learn.mode"].buttons["Course"].tap()
        selectLevel("A2", in: app)
        XCTAssertTrue(app.buttons["level.test.A2"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func answerArbitrarily(_ app: XCUIApplication) {
        let choice = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "exercise.choice.")).firstMatch
        if choice.exists { choice.tap(); return }
        let field = app.textFields["exercise.field"].firstMatch
        let area = app.textViews["exercise.field"].firstMatch
        if field.exists { field.tap(); field.typeText("zzzz"); return }
        if area.exists { area.tap(); area.typeText("zzzz"); return }
        let tiles = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "exercise.tile."))
        if tiles.firstMatch.exists {
            for tile in tiles.allElementsBoundByIndex where tile.isEnabled { tile.tap() }
            return
        }
        XCTFail("Unexpected exercise type in the A2 jump test")
    }

    @MainActor
    func testCoachStageUnitLessonAndContinue() {
        let app = launch()
        app.segmentedControls["learn.mode"].buttons["Coaches"].tap()
        XCTAssertTrue(app.buttons["coach.card.grammarian"].waitForExistence(timeout: 5))
        capture(app, "coach-grid")
        app.buttons["coach.card.grammarian"].tap()
        app.buttons["track.stage.starter"].tap()
        XCTAssertTrue(app.buttons["track.unit.be-have-do"].exists)
        capture(app, "coach-units")
        app.buttons["track.unit.sentences"].tap()
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "track.lesson.")).count, 4)
        app.buttons["track.lesson.gram-sent-subject"].tap()
        XCTAssertTrue(app.buttons["lesson.begin"].waitForExistence(timeout: 5))
        app.buttons["lesson.begin"].tap()
        XCTAssertTrue(app.buttons["exercise.choice.Maria runs."].waitForExistence(timeout: 5))
        app.buttons["exercise.choice.Maria runs."].tap(); app.buttons["exercise.check"].tap()
        XCTAssertTrue(app.staticTexts["Correct!"].waitForExistence(timeout: 5))
        // Return through unit and track. The catalog should refresh from saved journeys.
        for _ in 0..<3 { app.navigationBars.buttons.firstMatch.tap() }
        XCTAssertTrue(app.buttons["coach.continue"].waitForExistence(timeout: 5))
        app.buttons["coach.continue"].tap()
        XCTAssertTrue(app.navigationBars["Subject and verb"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testModePersistsAcrossTabsAndRotation() {
        let app = launch()
        defer { XCUIDevice.shared.orientation = .portrait }
        app.segmentedControls["learn.mode"].buttons["Coaches"].tap()
        XCUIDevice.shared.orientation = .landscapeLeft
        let landscape = expectation(for: NSPredicate { _, _ in app.frame.width > app.frame.height }, evaluatedWith: app)
        wait(for: [landscape], timeout: 8)
        XCTAssertTrue(app.buttons["coach.card.grammarian"].waitForExistence(timeout: 5))
        capture(app, "coaches-landscape")
        let today = app.tabBars.buttons["Today"]
        if today.exists { today.tap() } else { app.buttons["navigation.today"].firstMatch.tap() }
        openLesson(app)
        XCTAssertTrue(app.segmentedControls["learn.mode"].buttons["Coaches"].isSelected)
        XCUIDevice.shared.orientation = .portrait
        let portrait = expectation(for: NSPredicate { _, _ in app.frame.height > app.frame.width }, evaluatedWith: app)
        wait(for: [portrait], timeout: 8)
        XCTAssertTrue(app.buttons["coach.card.grammarian"].waitForExistence(timeout: 5))
        app.segmentedControls["learn.mode"].buttons["Course"].tap()
        XCTAssertTrue(app.buttons["learn.open.a1-greetings"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testCoachesWithAccessibilityTextAndDarkAppearance() throws {
        let app = launch(largeText: true, dark: true)
        app.segmentedControls["learn.mode"].buttons["Coaches"].tap()
        XCTAssertTrue(app.buttons["coach.card.grammarian"].waitForExistence(timeout: 5))
        capture(app, "coaches-accessibility-dark")
        try app.performAccessibilityAudit(for: [.dynamicType, .hitRegion, .sufficientElementDescription])
        app.buttons["coach.card.grammarian"].tap()
        let unit = app.buttons["track.unit.sentences"]
        XCTAssertTrue(unit.waitForExistence(timeout: 8))
        // Let the push animation finish before judging whether the card needs a scroll.
        let settled = expectation(for: NSPredicate(format: "isHittable == true"), evaluatedWith: unit)
        if XCTWaiter().wait(for: [settled], timeout: 3) != .completed {
            for _ in 0..<4 where !unit.isHittable { app.swipeUp() }
        }
        XCTAssertTrue(unit.isHittable); unit.tap()
        XCTAssertTrue(app.buttons["track.lesson.gram-sent-subject"].waitForExistence(timeout: 5))
    }
}
