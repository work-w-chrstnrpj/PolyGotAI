import XCTest

final class BootstrapLaunchTests: XCTestCase {
    override func setUp() {
        super.setUp()
        addUIInterruptionMonitor(withDescription: "System permission") { alert in
            let allow = alert.buttons["Allow"]
            if allow.exists {
                allow.tap()
                return true
            }
            return false
        }
    }

    @MainActor
    func testLaunchRelaunchAndAllDestinations() {
        continueAfterFailure = false
        let app = XCUIApplication(); app.launch()
        XCTAssertTrue(app.buttons["settings.open"].firstMatch.waitForExistence(timeout: 10))
        screenshot(app, "today")
        for (title, id) in [("Lesson", "learn"), ("Lexicon", "vocabulary"), ("Speech Lab", "speechLab"), ("Progress", "progress"), ("Today", "today")] {
            openDestination(app, title: title, id: id)
            XCTAssertTrue(app.descendants(matching: .any)["screen.\(id)"].firstMatch.waitForExistence(timeout: 5))
        }
        app.terminate(); app.launch()
        XCTAssertTrue(app.buttons["settings.open"].firstMatch.waitForExistence(timeout: 10))
        XCTAssertFalse(app.descendants(matching: .any)["storage.unavailable"].exists)
    }

    @MainActor
    func testBackgroundPreviewApplyAndRestart() {
        continueAfterFailure = false
        let app = XCUIApplication(); app.launch()
        openAppearance(app)
        let original = savedBackground(app).label
        let originalID: String
        if original.contains("Adventure Atlas") { originalID = "adventureAtlas" }
        else if original.contains("Mixed-Media Studio") { originalID = "mixedMediaStudio" }
        else { originalID = "creativeAcademy" }
        let targetID = originalID == "adventureAtlas" ? "creativeAcademy" : "adventureAtlas"
        let targetName = targetID == "adventureAtlas" ? "Adventure Atlas" : "Creative Academy"
        tapStyle(app, targetID)
        XCTAssertEqual(savedBackground(app).label, original, "Preview must not save defaults.")
        let apply = app.descendants(matching: .any)["background.apply"].firstMatch
        for _ in 0..<6 where !apply.isHittable { app.swipeUp() }
        apply.tap()
        XCTAssertTrue(savedBackground(app).label.contains(targetName))
        screenshot(app, "appearance")
        app.terminate(); app.launch(); openAppearance(app)
        XCTAssertTrue(savedBackground(app).label.contains(targetName))
        tapStyle(app, originalID)
        let restore = app.descendants(matching: .any)["background.apply"].firstMatch
        for _ in 0..<6 where !restore.isHittable { app.swipeUp() }
        restore.tap() // restore the learner's initial choice
    }

    @MainActor
    func testLargerTextAndAccessibility() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["settings.open"].firstMatch.waitForExistence(timeout: 10))
        // Audit the stable viewport, then exercise very large, scrollable content separately.
        // Collapse the native large title before the scan so its transition is not audited.
        app.swipeUp()
        try auditVisibleContent(app, types: [.dynamicType, .hitRegion, .sufficientElementDescription])
        app.terminate()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.buttons["settings.open"].firstMatch.waitForExistence(timeout: 10))
        screenshot(app, "today-largest-type")
        let speech = app.buttons["today.lesson"]
        for _ in 0..<6 where !speech.isHittable { app.swipeUp() }
        XCTAssertTrue(speech.isHittable, "Enlarged text must retain a reachable next action.")
        screenshot(app, "today-largest-type-scrolled")
        app.buttons["settings.open"].firstMatch.tap()
        XCTAssertTrue(app.buttons["settings.done"].waitForExistence(timeout: 5))
        screenshot(app, "settings-largest-type")
    }

    @MainActor
    func testTypedExercisesGiveInstantFeedbackAndAccuracy() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString   // a fresh, isolated store
        app.launch()
        openDestination(app, title: "Lesson", id: "learn")
        tapReachable(app, app.buttons["learn.open.a1-weather"])
        XCTAssertTrue(app.staticTexts["lesson.topic.teaching"].waitForExistence(timeout: 8), "The coach tip shows before the exercises.")
        tapFrontmostButton(app, "lesson.begin")
        // Reading: a right answer.
        app.buttons["exercise.choice.Hot and sunny."].firstMatch.tap()
        app.buttons["exercise.check"].tap()
        XCTAssertTrue(app.staticTexts["Correct!"].waitForExistence(timeout: 5))
        app.buttons["exercise.continue"].tap()
        // Listening: a wrong answer shows the right one.
        let wrong = app.buttons["exercise.choice.Water."].firstMatch
        XCTAssertTrue(wrong.waitForExistence(timeout: 5))
        wrong.tap()
        app.buttons["exercise.check"].tap()
        XCTAssertTrue(app.staticTexts["Not quite"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["exercise.answer"].exists)
        screenshot(app, "typed-exercise-wrong")
        app.buttons["exercise.continue"].tap()
        // True or false.
        app.buttons["exercise.choice.False"].firstMatch.tap()
        app.buttons["exercise.check"].tap()
        XCTAssertTrue(app.staticTexts["Correct!"].waitForExistence(timeout: 5))
        app.buttons["exercise.continue"].tap()
        // Listen and write.
        let field = app.descendants(matching: .any)["exercise.field"].firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap(); field.typeText("It is hot and sunny.")
        app.buttons["exercise.check"].tap()
        XCTAssertTrue(app.staticTexts["Correct!"].waitForExistence(timeout: 5))
        app.buttons["exercise.continue"].tap()
        // Grammar: fill the blank, then build a sentence from tiles.
        app.buttons["exercise.choice.is"].firstMatch.tap()
        app.buttons["exercise.check"].tap()
        XCTAssertTrue(app.staticTexts["Correct!"].waitForExistence(timeout: 5))
        app.buttons["exercise.continue"].tap()
        for tile in ["It", "is", "raining."] {
            let button = app.buttons["exercise.tile.\(tile)"].firstMatch
            XCTAssertTrue(button.waitForExistence(timeout: 5)); button.tap()
        }
        screenshot(app, "typed-exercise-tiles")
        app.buttons["exercise.check"].tap()
        XCTAssertTrue(app.staticTexts["Correct!"].waitForExistence(timeout: 5))
    }

    // Kept separate so a contrast finding cannot prevent the large-text walkthrough.
    @MainActor
    func testTodayContrast() throws {
        let app = XCUIApplication(); app.launch()
        XCTAssertTrue(app.buttons["settings.open"].firstMatch.waitForExistence(timeout: 10))
        app.swipeUp()
        try auditVisibleContent(app, types: [.contrast])
    }

    @MainActor
    func testDarkAppearance() throws {
        let app = XCUIApplication(); app.launch(); openAppearance(app)
        let theme = app.buttons["appearance.theme"]
        for _ in 0..<4 where !theme.isHittable { app.swipeUp() }
        let original = theme.label + " " + (theme.value as? String ?? "")
        theme.tap(); app.buttons["Dark"].tap()
        screenshot(app, "appearance-dark")
        try auditVisibleContent(app, types: [.contrast, .hitRegion, .sufficientElementDescription])
        theme.tap()
        app.buttons[original.contains("Dark") ? "Dark" : original.contains("Light") ? "Light" : "System"].tap()
    }

    @MainActor
    func testOfflineRecordingEntryRequiresDeliberateStart() {
        let app = XCUIApplication(); app.launch()
        openDestination(app, title: "Speech Lab", id: "speechLab")
        let entry = app.buttons["speech.record"]
        for _ in 0..<4 where !entry.isHittable { app.swipeUp() }
        XCTAssertTrue(entry.isHittable); entry.tap()
        XCTAssertTrue(app.buttons["recording.start"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["recording.stop"].exists)
        screenshot(app, "offline-recording-ready")
        app.buttons["Close"].firstMatch.tap()
        XCTAssertTrue(entry.waitForExistence(timeout: 5))
    }

    @MainActor
    func testProviderSettingsShowsMaskedEntryAndNoLiveAction() {
        let app = XCUIApplication(); app.launch()
        XCTAssertTrue(app.buttons["settings.open"].firstMatch.waitForExistence(timeout: 10))
        app.buttons["settings.open"].firstMatch.tap()
        let entry = app.buttons["settings.provider"]
        for _ in 0..<4 where !entry.isHittable { app.swipeUp() }
        XCTAssertTrue(entry.isHittable); entry.tap()
        XCTAssertTrue(app.secureTextFields["provider.key"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["provider.workspace"].exists)
        XCTAssertFalse(app.buttons["Check connection"].exists)
        screenshot(app, "provider-settings-local-only")
    }

    @MainActor
    func testRecordingStopsOnBackgroundAndFinishesWithoutSaving() {
        continueAfterFailure = false
        let app = XCUIApplication(); app.launch()
        openDestination(app, title: "Speech Lab", id: "speechLab")
        let entry = app.buttons["speech.record"]
        for _ in 0..<4 where !entry.isHittable { app.swipeUp() }
        entry.tap()
        app.buttons["recording.start"].tap()
        if !app.buttons["recording.stop"].waitForExistence(timeout: 3) {
            // The first start can be covered by the microphone prompt. Interact so the monitor can allow it, then start again.
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15)).tap()
            let start = app.buttons["recording.start"]
            if start.waitForExistence(timeout: 3) { start.tap() }
        }
        XCTAssertTrue(app.buttons["recording.stop"].waitForExistence(timeout: 10))
        let elapsed = app.staticTexts["recording.elapsed"]
        let captured = NSPredicate { _, _ in Int(elapsed.value as? String ?? "0") ?? 0 >= 2 }
        expectation(for: captured, evaluatedWith: nil)
        waitForExpectations(timeout: 8)
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(app.buttons["recording.replay"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["recording.stop"].exists, "Backgrounding must stop and never silently resume.")
        let accept = app.buttons["recording.accept"]
        for _ in 0..<4 where !accept.isHittable { app.swipeUp() }
        accept.tap()
        let finish = app.buttons["recording.finish"]
        for _ in 0..<6 where !finish.isHittable { app.swipeUp() }
        finish.tap() // Save voice stays off: no test recording is retained intentionally.
        XCTAssertTrue(app.staticTexts["recording.message"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["recording.message"].label.contains("not saved"))
        app.buttons["Done"].firstMatch.tap()
    }

    @MainActor
    func testIntegratedSpeakingLoopFixtureAndHistory() {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        defer { XCUIDevice.shared.orientation = .portrait }
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        openDestination(app, title: "Speech Lab", id: "speechLab")
        tapReachable(app, app.buttons["speech.record"])
        XCTAssertTrue(app.staticTexts["fixture.banner"].waitForExistence(timeout: 5))
        tapReachable(app, app.buttons["recording.recover"].firstMatch)
        tapReachable(app, app.buttons["recording.accept"])
        turnOn(app, app.switches["recording.keepAudio"])
        tapReachable(app, app.buttons["online.transcribe"])
        tapReachable(app, app.buttons["online.send"])
        XCTAssertTrue(app.textViews["online.transcript"].waitForExistence(timeout: 10))
        tapReachable(app, app.buttons["online.confirm"])
        turnOn(app, app.switches["recording.keepText"])
        tapReachable(app, app.buttons["online.coach"])
        tapReachable(app, app.buttons["online.send"])
        let message = app.staticTexts["online.message"]
        let ready = NSPredicate { _, _ in message.exists && message.label.contains("Text coaching is ready") }
        expectation(for: ready, evaluatedWith: nil); waitForExpectations(timeout: 10)
        screenshot(app, "integrated-fixture-feedback")
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(app.buttons["recording.finish"].waitForExistence(timeout: 5), "Review survives compact/regular layout changes.")
        XCTAssertEqual(app.switches["recording.keepAudio"].value as? String, "1")
        XCTAssertEqual(app.switches["recording.keepText"].value as? String, "1")
        tapReachable(app, app.buttons["recording.finish"])
        let finished = app.staticTexts["recording.message"]
        XCTAssertTrue(finished.waitForExistence(timeout: 5))
        XCTAssertTrue(finished.label.contains("Voice saved"))
        XCTAssertTrue(finished.label.contains("transcript and feedback saved"))
        app.buttons["Done"].firstMatch.tap()
        XCUIDevice.shared.orientation = .portrait
        app.terminate(); app.launch()
        openDestination(app, title: "Progress", id: "progress")
        XCTAssertTrue(app.staticTexts["progress.completions"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["progress.completions"].label.contains("1 self-reviews"))
        let row = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "history.")).allElementsBoundByIndex.first { $0.identifier != "history.trash" }
        XCTAssertNotNil(row)
        guard let row else { return }
        tapReachable(app, row)
        XCTAssertTrue(app.buttons["history.replay"].waitForExistence(timeout: 5))
        screenshot(app, "integrated-fixture-history")
        tapReachable(app, app.buttons["history.delete"])
        app.buttons["Delete all saved components"].tap()
        XCTAssertTrue(app.staticTexts["history.message"].waitForExistence(timeout: 5))
        let back = app.navigationBars.buttons["Progress"]
        XCTAssertTrue(back.waitForExistence(timeout: 5), "Detail must offer a way back without hiding the iPad sidebar.")
        back.tap()
        tapReachable(app, app.buttons["history.trash"])
        let deleted = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "history.")).firstMatch
        tapReachable(app, deleted)
        tapReachable(app, app.buttons["Restore voice"])
        tapReachable(app, app.buttons["Restore text and feedback"])
        XCTAssertTrue(app.buttons["history.replay"].exists)
    }

    @MainActor
    private func turnOn(_ app: XCUIApplication, _ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10))
        for _ in 0..<8 where !element.isHittable {
            if element.frame.midY < app.frame.minY + 120 { app.swipeDown() }
            else { app.swipeUp() }
        }
        XCTAssertTrue(element.isHittable)
        if (element.value as? String) == "1" { return }
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        let enabled = NSPredicate { _, _ in (element.value as? String) == "1" }
        expectation(for: enabled, evaluatedWith: nil)
        waitForExpectations(timeout: 3)
    }

    @MainActor
    private func tapReachable(_ app: XCUIApplication, _ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10))
        for _ in 0..<24 {
            if isClearOfReviewBar(app, element) {
                element.tap()
                return
            }
            if element.frame.midY < app.frame.minY + 140 { app.swipeDown() }
            else { app.swipeUp() }
        }
        XCTFail("\(element.identifier) stayed under the review bar or offscreen")
    }

    /// The save/finish bar is pinned over the review scroll. A control counts as
    /// reachable only when its full frame sits above that bar, so a tap hits the
    /// control rather than the bar covering its center.
    @MainActor
    private func isClearOfReviewBar(_ app: XCUIApplication, _ element: XCUIElement) -> Bool {
        guard element.exists, element.isHittable else { return false }
        let frame = element.frame
        guard frame.width > 1, frame.height > 1 else { return false }
        if ["recording.finish", "recording.keepAudio", "recording.keepText"].contains(element.identifier) { return true }
        // A disclosure sheet covers the review bar. Its buttons stay tappable
        // even when their screen position overlaps the bar behind the sheet.
        if app.navigationBars["Before you send"].exists { return true }
        let tabs = app.tabBars.firstMatch
        if tabs.exists, tabs.isHittable, frame.maxY >= tabs.frame.minY { return false }
        let bar = app.switches["recording.keepAudio"]
        if bar.exists, bar.isHittable {
            let center = CGPoint(x: frame.midX, y: frame.midY)
            return center.y < bar.frame.minY - 4 && frame.minY >= app.frame.minY + 20
        }
        return app.frame.insetBy(dx: 0, dy: 8).contains(CGPoint(x: frame.midX, y: frame.midY))
    }

    @MainActor
    private func auditVisibleContent(_ app: XCUIApplication, types: XCUIAccessibilityAuditType) throws {
        try app.performAccessibilityAudit(for: types) { issue in
            guard let element = issue.element else { return false }
            // The Learn scroll includes prefetched lesson labels wholly behind the system floating
            // tab bar. The audit screenshot confirms "Use numbers" is occluded there. Audit its
            // contrast when it is actually visible; never exclude tab-bar labels or partial rows.
            let tabBar = app.tabBars.firstMatch
            if issue.auditType == .contrast, app.navigationBars["Lesson"].exists,
               element.elementType == .staticText, tabBar.exists, element.frame.minY >= tabBar.frame.minY,
               !tabBar.descendants(matching: .any).matching(NSPredicate(format: "label == %@", element.label)).firstMatch.exists {
                print("AUDIT_OCCLUDED_LESSON_LABEL", element.frame)
                return true
            }
            let isBackgroundRow = ["Creative Academy", "Adventure Atlas", "Mixed-Media Studio", "Preview background", "Preview selected"].contains(element.label)
            let appearanceBar = app.navigationBars["Appearance"]
            // iOS 27 contrast scanning includes stale, offscreen background-preview rows.
            // Exclude only those exact row labels when clipped by or above the opaque Appearance bar.
            let occluded = issue.auditType == .contrast && isBackgroundRow && appearanceBar.exists
                && element.frame.minY < appearanceBar.frame.maxY
            if occluded { print("AUDIT_OCCLUDED_BACKGROUND_ROW", element.label) }
            return occluded
        }
    }

    @MainActor
    private func tapStyle(_ app: XCUIApplication, _ id: String) {
        let button = app.descendants(matching: .any)["background.\(id)"].firstMatch
        for _ in 0..<8 where !button.exists || !button.isHittable { app.swipeDown() }
        for _ in 0..<8 where !button.exists || !button.isHittable { app.swipeUp() }
        XCTAssertTrue(button.waitForExistence(timeout: 3) && button.isHittable, id)
        button.tap()
    }

    /// The saved-background caption sits below the preview. On iPad it is outside the first viewport, and iPadOS 27 may not publish its identifier until it is on screen.
    @MainActor
    private func savedBackground(_ app: XCUIApplication) -> XCUIElement {
        let query = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH %@", "Saved background:"))
        var element = query.firstMatch
        for _ in 0..<8 where !element.exists {
            app.swipeUp()
            element = query.firstMatch
        }
        XCTAssertTrue(element.waitForExistence(timeout: 3), "Saved background")
        return element
    }

    @MainActor
    private func openAppearance(_ app: XCUIApplication) {
        XCTAssertTrue(app.buttons["settings.open"].firstMatch.waitForExistence(timeout: 10))
        app.buttons["settings.open"].firstMatch.tap()
        let row = app.buttons["settings.appearance"]
        XCTAssertTrue(row.waitForExistence(timeout: 5)); row.tap()
        XCTAssertTrue(app.buttons["background.creativeAcademy"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testOptionalIntroPracticeResumesAndReturnsToCourseDraft() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        XCTAssertTrue(app.buttons["today.lesson"].waitForExistence(timeout: 10))
        app.buttons["today.lesson"].tap()
        app.buttons["lesson.begin"].tap()
        let courseAnswer = app.descendants(matching: .any)["lesson.response.read-mina"].firstMatch
        tapReachable(app, courseAnswer); courseAnswer.typeText("Keep this course draft")
        app.buttons["lesson.extra"].tap()
        app.buttons["English foundations"].tap()
        let answer = app.textFields["intro.practice.answer"].exists ? app.textFields["intro.practice.answer"] : app.textViews["intro.practice.answer"]
        tapReachable(app, answer); answer.typeText("Mina")
        XCTAssertFalse(app.staticTexts["intro.practice.example"].exists)
        tapReachable(app, app.buttons["intro.practice.save"])
        tapReachable(app, app.buttons["intro.practice.reveal"])
        XCTAssertTrue(app.staticTexts["intro.practice.example"].exists)
        tapReachable(app, app.buttons["intro.practice.return"])
        XCTAssertEqual(courseAnswer.value as? String, "Keep this course draft")
        app.terminate(); app.launch()
        app.buttons["today.lesson"].tap()
        app.buttons["lesson.extra"].tap()
        app.buttons["English foundations"].tap()
        XCTAssertTrue(app.staticTexts["intro.practice.example"].waitForExistence(timeout: 5))
        screenshot(app, "intro-foundation-resumed")
        tapReachable(app, app.buttons["intro.practice.return"])
        for title in ["Teacher practice", "Grammarian practice", "Journalist practice"] {
            app.buttons["lesson.extra"].tap(); app.buttons[title].tap()
            XCTAssertTrue(app.staticTexts["intro.practice.prompt"].waitForExistence(timeout: 5))
            if title == "Journalist practice" {
                tapReachable(app, app.buttons["intro.practice.speak"])
                XCTAssertTrue(app.staticTexts["recording.prompt"].waitForExistence(timeout: 5))
                let correctTask = expectation(for: NSPredicate(format: "label CONTAINS %@", "List only the facts"), evaluatedWith: app.staticTexts["recording.prompt"])
                wait(for: [correctTask], timeout: 5)
                app.buttons["Close"].tap()
            }
            tapReachable(app, app.buttons["intro.practice.return"])
        }
        XCTAssertEqual(courseAnswer.value as? String, "Keep this course draft")
    }

    @MainActor
    func testPersonalCheckKeepsFollowUpHiddenAndReturnsWithoutCourseCompletion() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        XCTAssertTrue(app.buttons["today.lesson"].waitForExistence(timeout: 10))
        app.buttons["today.lesson"].tap()
        tapReachable(app, app.buttons["lesson.baseline"])
        XCTAssertFalse(app.staticTexts["intro.check.prompt"].exists)
        app.buttons["intro.check.begin"].tap()
        let prompt = app.staticTexts["intro.check.prompt"]
        XCTAssertTrue(prompt.waitForExistence(timeout: 5))
        XCTAssertFalse(prompt.label.contains("free time"))
        let input = app.descendants(matching: .any)["intro.check.answer"].firstMatch
        tapReachable(app, input); input.typeText("I am Lee. I study art. I like walking.")
        tapReachable(app, app.buttons["intro.check.save"])
        XCTAssertTrue(prompt.label.contains("free time"))
        app.terminate(); app.launch()
        app.buttons["today.lesson"].tap()
        app.buttons["lesson.extra"].tap()
        app.buttons["Introduction baseline"].tap()
        XCTAssertTrue(prompt.waitForExistence(timeout: 5))
        XCTAssertTrue(prompt.label.contains("free time"))
        tapReachable(app, input); input.typeText("I like walking.")
        tapReachable(app, app.buttons["intro.check.save"])
        tapReachable(app, app.buttons["intro.check.finish"])
        XCTAssertTrue(app.staticTexts["intro.check.complete"].waitForExistence(timeout: 5))
        screenshot(app, "personal-check-complete")
        tapReachable(app, app.buttons["intro.check.return"])
        XCTAssertFalse(app.staticTexts["lesson.completed"].exists)
    }

    @MainActor
    private func openIntroductionCourse(_ app: XCUIApplication) {
        openDestination(app, title: "Lesson", id: "learn")
        let lesson = app.buttons["learn.open.intro-01"]
        for _ in 0..<12 where !lesson.exists { app.swipeUp() }
        tapReachable(app, lesson)
    }

    @MainActor
    func testIntroductionReviewOnlyAppearsAfterRevealAndCannotFinishSkippedCore() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        openIntroductionCourse(app)
        app.buttons["lesson.begin"].tap()
        let input = app.descendants(matching: .any)["lesson.response.read-mina"].firstMatch
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        XCTAssertFalse(app.descendants(matching: .any)["intro.review.read-mina"].firstMatch.exists)
        tapReachable(app, input); input.typeText("English")
        tapReachable(app, app.buttons["lesson.save.read-mina"])
        XCTAssertFalse(app.descendants(matching: .any)["intro.review.read-mina"].firstMatch.exists)
        tapReachable(app, app.buttons["lesson.reveal.read-mina"])
        XCTAssertTrue(app.descendants(matching: .any)["intro.review.read-mina"].firstMatch.waitForExistence(timeout: 5))
        screenshot(app, "intro-v4-revealed-review")
        app.buttons["lesson.contents"].tap()
        let review = app.buttons["lesson.jump.self-review"]
        for _ in 0..<12 where !review.exists { app.swipeUp() }
        tapReachable(app, review)
        let reflection = app.descendants(matching: .any)["lesson.response.self-review"].firstMatch
        XCTAssertTrue(reflection.waitForExistence(timeout: 5))
        tapReachable(app, reflection); reflection.typeText("Synthetic reflection about a name, role, interest and follow-up.")
        tapReachable(app, app.buttons["lesson.save.self-review"])
        tapReachable(app, app.buttons["lesson.reveal.self-review"])
        let rubric = app.buttons["intro.review.rubric"].firstMatch
        tapReachable(app, rubric)
        let audioBoundary = app.staticTexts["Intelligibility from actual audio"]
        for _ in 0..<16 where !audioBoundary.exists || !audioBoundary.isHittable { app.swipeUp() }
        XCTAssertTrue(audioBoundary.exists)
        screenshot(app, "intro-v4-rubric")
        tapReachable(app, app.buttons["lesson.finish"])
        XCTAssertFalse(app.staticTexts["lesson.completed"].exists)
        XCTAssertTrue(app.staticTexts["lesson.message"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testConnectedLessonDraftResumeQuietCompletionAndVocabularyReview() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        openIntroductionCourse(app)
        app.buttons["lesson.begin"].tap()
        let first = app.descendants(matching: .any)["lesson.response.read-mina"].firstMatch
        first.tap(); first.typeText("Mina is a designer.")
        let saved = app.staticTexts["lesson.draft.status"]
        let stored = NSPredicate(format: "label == %@", "Draft saved on this device")
        expectation(for: stored, evaluatedWith: saved)
        waitForExpectations(timeout: 8)
        app.terminate(); app.launch()
        openIntroductionCourse(app)
        let resumed = app.descendants(matching: .any)["lesson.response.read-mina"].firstMatch
        XCTAssertTrue(resumed.waitForExistence(timeout: 5))
        XCTAssertEqual(resumed.value as? String, "Mina is a designer.")
        app.buttons["lesson.save.read-mina"].tap()
        if app.buttons["lesson.review-required"].exists { app.buttons["lesson.review-required"].tap() }
        app.buttons["lesson.next"].tap()
        let steps: [(String, String?)] = [
            ("read-mina-name", nil), ("read-mina-like", nil), ("listen-alex-name", nil),
            ("listen-alex", nil), ("listen-alex-like", nil), ("grammar-be-am", "am"), ("grammar-be-is", "is"),
            ("grammar-study", "study"), ("grammar-works", "works"), ("grammar-do", "Do"),
            ("recall-name", nil), ("recall-from", nil), ("recall-study", nil),
            ("recall-like", nil), ("recall-meet", nil), ("guided-intro", nil),
            ("self-review", nil)
        ]
        for (id, choice) in steps {
            if let choice {
                app.buttons["lesson.choice.\(choice)"].tap()
            } else {
                let input = app.descendants(matching: .any)["lesson.response.\(id)"].firstMatch
                XCTAssertTrue(input.waitForExistence(timeout: 5))
                input.tap(); input.typeText("My practice response.")
            }
            app.buttons["lesson.save.\(id)"].tap()
            if id == "grammar-be-am" { screenshot(app, "recovery-activity-feedback") }
            if app.buttons["lesson.review-required"].exists { app.buttons["lesson.review-required"].tap() }
            if id == "self-review" { app.buttons["lesson.finish"].tap() }
            else { app.buttons["lesson.next"].tap() }
        }
        XCTAssertTrue(app.staticTexts["lesson.completed"].waitForExistence(timeout: 5))
        screenshot(app, "recovery-completion")
        let enroll = app.buttons["lesson.enroll.called"]
        for _ in 0..<6 where !enroll.isHittable { app.swipeUp() }
        enroll.tap()
        let back = app.navigationBars.buttons["Lesson"].firstMatch
        XCTAssertTrue(back.waitForExistence(timeout: 5))
        back.tap()
        openDestination(app, title: "Lexicon", id: "vocabulary")
        app.buttons["vocabulary.practice"].tap()
        XCTAssertFalse(app.staticTexts["vocabulary.recall.meaning"].exists)
        app.buttons["vocabulary.recall.reveal"].tap()
        XCTAssertEqual(app.staticTexts["vocabulary.recall.meaning"].label, "Used to tell someone your name.")
        screenshot(app, "recovery-vocabulary-review")
        app.buttons["vocabulary.recall.rate.good"].tap()
        XCTAssertTrue(app.staticTexts["vocabulary.recall.message"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLessonSpeakingSelfReviewReturnsWithoutTypingOrRetention() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        XCTAssertTrue(app.buttons["today.lesson"].waitForExistence(timeout: 10))
        app.buttons["today.lesson"].tap()
        app.buttons["lesson.contents"].tap()
        let guided = app.buttons["lesson.jump.guided-intro"]
        for _ in 0..<6 where !guided.isHittable { app.swipeUp() }
        guided.tap()
        app.buttons["lesson.speak"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["recording.lessonContext"].firstMatch.waitForExistence(timeout: 5))
        app.buttons["recording.start"].tap()
        XCTAssertTrue(app.buttons["recording.stop"].waitForExistence(timeout: 10))
        let elapsed = app.staticTexts["recording.elapsed"]
        expectation(for: NSPredicate { _, _ in Int(elapsed.value as? String ?? "0") ?? 0 >= 2 }, evaluatedWith: nil)
        waitForExpectations(timeout: 8)
        app.buttons["recording.stop"].tap()
        tapReachable(app, app.buttons["recording.accept"])
        tapReachable(app, app.buttons["recording.finish"])
        app.buttons["Done"].firstMatch.tap()
        XCTAssertTrue(app.buttons["lesson.next"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Recording and self-review completed. Speech has not been assessed."].exists)
        screenshot(app, "recovery-lesson-speaking-return")
    }

    @MainActor
    func testFocusedLessonAndLibraryAccessibility() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        openDestination(app, title: "Lesson", id: "learn")
        screenshot(app, "recovery-learn")
        try auditVisibleContent(app, types: [.contrast, .hitRegion, .sufficientElementDescription])
        tapReachable(app, app.buttons["learn.open.intro-01"])
        app.buttons["lesson.contents"].tap()
        app.buttons["lesson.jump.grammar-be-am"].tap()
        screenshot(app, "recovery-activity-choices")
        try auditVisibleContent(app, types: [.contrast, .hitRegion, .sufficientElementDescription])
        let back = app.navigationBars.buttons["Lesson"].firstMatch
        XCTAssertTrue(back.waitForExistence(timeout: 5)); back.tap()
        openDestination(app, title: "Lexicon", id: "vocabulary")
        screenshot(app, "recovery-vocabulary")
        try auditVisibleContent(app, types: [.contrast, .hitRegion, .sufficientElementDescription])
    }

    @MainActor
    func testOfflineRecallDraftRevealAndRatingRecovery() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        createReviewWords(app)
        app.buttons["vocabulary.practice"].tap()
        XCTAssertFalse(app.staticTexts["vocabulary.recall.meaning"].exists)
        screenshot(app, "recall-hidden")
        let typed = app.descendants(matching: .any)["vocabulary.recall.typed"].firstMatch
        typed.tap(); typed.typeText("a list of dishes")
        let status = app.staticTexts["vocabulary.recall.draftStatus"]
        expectation(for: NSPredicate(format: "label == %@", "Draft saved on this device"), evaluatedWith: status)
        waitForExpectations(timeout: 8)
        app.terminate(); app.launch()
        openDestination(app, title: "Lexicon", id: "vocabulary")
        XCTAssertEqual(app.buttons["vocabulary.practice"].label, "Resume review")
        app.buttons["vocabulary.practice"].tap()
        XCTAssertEqual(app.descendants(matching: .any)["vocabulary.recall.typed"].firstMatch.value as? String, "a list of dishes")
        XCTAssertFalse(app.staticTexts["vocabulary.recall.meaning"].exists)
        tapReachable(app, app.buttons["vocabulary.recall.reveal"])
        XCTAssertEqual(app.staticTexts["vocabulary.recall.meaning"].label, "a list of dishes")
        try auditVisibleContent(app, types: [.contrast, .hitRegion, .sufficientElementDescription])
        screenshot(app, "recall-written-reveal")
        app.terminate(); app.launch()
        openDestination(app, title: "Lexicon", id: "vocabulary")
        app.buttons["vocabulary.practice"].tap()
        XCTAssertTrue(app.staticTexts["vocabulary.recall.meaning"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["You wrote: a list of dishes"].exists)
        XCTAssertFalse(app.buttons["vocabulary.recall.reveal"].exists)
        tapReachable(app, app.buttons["vocabulary.recall.rate.hard"])
        XCTAssertEqual(app.staticTexts["vocabulary.recall.lemma"].label, "water")
        app.segmentedControls.buttons["Say"].tap()
        XCTAssertFalse(app.descendants(matching: .any)["vocabulary.recall.typed"].firstMatch.exists)
        tapReachable(app, app.buttons["vocabulary.recall.reveal"])
        XCTAssertTrue(app.staticTexts["vocabulary.recall.spoken"].exists)
        screenshot(app, "recall-spoken-self-check")
        tapReachable(app, app.buttons["vocabulary.recall.rate.again"])
        XCTAssertTrue(app.staticTexts["Practice saved"].waitForExistence(timeout: 5))
        screenshot(app, "recall-finished")
    }

    @MainActor
    func testRecallLargerTextThinkMode() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        createReviewWords(app)
        app.buttons["vocabulary.practice"].tap()
        tapReachable(app, app.buttons["vocabulary.recall.mode"])
        app.buttons["Think"].tap()
        XCTAssertFalse(app.descendants(matching: .any)["vocabulary.recall.typed"].firstMatch.exists)
        tapReachable(app, app.buttons["vocabulary.recall.reveal"])
        tapReachable(app, app.buttons["vocabulary.recall.rate.good"])
        XCTAssertEqual(app.staticTexts["vocabulary.recall.lemma"].label, "water")
        screenshot(app, "recall-larger-text")
    }

    @MainActor
    func testPersonalVocabularySearchAndUnsavedTopicDetails() {
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        createReviewWords(app)
        let topicLink = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "vocabulary.topic.open.")).firstMatch
        tapReachable(app, topicLink)
        let title = app.textFields["vocabulary.topic.edit.title"]
        tapReachable(app, title)
        title.typeText(" updated\n")
        let draftTitle = title.value as? String
        let lemma = app.textFields["vocabulary.sense.lemma"]
        tapReachable(app, lemma); lemma.typeText("cafe")
        let note = app.textFields["vocabulary.sense.note"]
        tapReachable(app, note); note.typeText("a place for coffee\n")
        tapReachable(app, app.buttons["vocabulary.sense.save"])
        tapReachable(app, title)
        XCTAssertEqual(title.value as? String, draftTitle)
        title.typeText("\n")
        tapReachable(app, app.buttons["vocabulary.topic.rename"])
        let vocabularyBack = app.navigationBars.buttons["Lexicon"].firstMatch
        XCTAssertTrue(vocabularyBack.waitForExistence(timeout: 5))
        vocabularyBack.tap()
        let search = app.textFields["vocabulary.search"]
        tapReachable(app, search); search.typeText("coffee\n")
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "vocabulary.topic.open.")).firstMatch.waitForExistence(timeout: 5))
        tapReachable(app, app.buttons["vocabulary.search.clear"])
        tapReachable(app, search); search.typeText("zznomatchzz\n")
        XCTAssertTrue(app.otherElements["vocabulary.search.empty"].exists || app.staticTexts["No matching words or topics"].exists)
        tapReachable(app, app.buttons["vocabulary.search.clear"])
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "vocabulary.topic.open.")).firstMatch.exists)
        screenshot(app, "personal-vocabulary-search")
    }

    @MainActor
    func testReviewOptionsPersistAndLimitOneSession() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        createReviewWords(app)
        tapReachable(app, app.buttons["vocabulary.options.open"])
        let retention = app.textFields["vocabulary.options.retention"]
        XCTAssertTrue(retention.waitForExistence(timeout: 5))
        XCTAssertEqual(retention.value as? String, "90")
        retention.tap(); retention.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 2) + "95")
        let limit = app.textFields["vocabulary.options.limit"]
        limit.tap(); limit.typeText("0")
        tapReachable(app, app.buttons["vocabulary.options.save"])
        XCTAssertTrue(app.staticTexts["vocabulary.options.message"].label.contains("positive whole number"))
        limit.tap(); limit.typeText(XCUIKeyboardKey.delete.rawValue + "1")
        tapReachable(app, app.buttons["vocabulary.options.save"])
        XCTAssertTrue(app.staticTexts["vocabulary.options.message"].label.contains("Review options saved"))
        // Fully reveal the history paragraph before auditing it; the floating system
        // tab bar otherwise covers the middle of this partially visible row.
        app.swipeUp()
        screenshot(app, "review-options-saved")
        try auditVisibleContent(app, types: [.contrast, .sufficientElementDescription])
        app.terminate(); app.launch()
        openDestination(app, title: "Lexicon", id: "vocabulary")
        tapReachable(app, app.buttons["vocabulary.options.open"])
        XCTAssertEqual(app.textFields["vocabulary.options.limit"].value as? String, "1")
        XCTAssertEqual(app.textFields["vocabulary.options.retention"].value as? String, "95")
        app.navigationBars.buttons["Lexicon"].firstMatch.tap()
        tapReachable(app, app.buttons["vocabulary.practice"])
        XCTAssertTrue(app.staticTexts["Word 1 of 1"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["vocabulary.recall.deferred"].label.contains("1 more due word"))
        tapReachable(app, app.buttons["vocabulary.recall.reveal"])
        tapReachable(app, app.buttons["vocabulary.recall.rate.easy"])
        XCTAssertTrue(app.staticTexts["Practice saved"].waitForExistence(timeout: 5))
        screenshot(app, "review-limited-session")
        tapReachable(app, app.buttons["vocabulary.recall.again"])
        XCTAssertEqual(app.staticTexts["vocabulary.recall.lemma"].label, "water")
        XCTAssertTrue(app.staticTexts["Word 1 of 1"].exists)
    }

    @MainActor
    private func createReviewWords(_ app: XCUIApplication) {
        openDestination(app, title: "Lexicon", id: "vocabulary")
        tapReachable(app, app.buttons["vocabulary.topic.new"])
        let title = app.textFields["vocabulary.topic.title"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        title.tap(); title.typeText("Kitchen\n")
        XCTAssertEqual(title.value as? String, "Kitchen")
        let create = app.buttons["vocabulary.topic.save"]
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: create)
        waitForExpectations(timeout: 5)
        create.tap()
        XCTAssertTrue(app.navigationBars["New topic"].waitForNonExistence(timeout: 8), "Creation must finish before opening the topic.")
        let topic = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "vocabulary.topic.open.")).firstMatch
        tapReachable(app, topic)
        for (word, meaning) in [("menu", "a list of dishes"), ("water", "a drink")] {
            let lemma = app.textFields["vocabulary.sense.lemma"]
            tapReachable(app, lemma); lemma.typeText(word)
            let note = app.textFields["vocabulary.sense.note"]
            tapReachable(app, note); note.typeText(meaning)
            tapReachable(app, app.buttons["vocabulary.sense.save"])
        }
        let collect = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "vocabulary.sense.collect.")).allElementsBoundByIndex
        for button in collect { tapReachable(app, button) }
        let enroll = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "vocabulary.sense.enroll.")).allElementsBoundByIndex
        for button in enroll { tapReachable(app, button) }
        let back = app.navigationBars.buttons["Lexicon"].firstMatch
        XCTAssertTrue(back.waitForExistence(timeout: 5))
        back.tap()
        for _ in 0..<6 where !app.buttons["vocabulary.practice"].isHittable { app.swipeDown() }
        XCTAssertTrue(app.buttons["vocabulary.practice"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func openDestination(_ app: XCUIApplication, title: String, id: String) {
        let tab = app.tabBars.buttons[title]
        if tab.waitForExistence(timeout: 5) { tab.tap() }
        else { app.descendants(matching: .any)["navigation.\(id)"].firstMatch.tap() }
    }

    @MainActor
    func testA1PreviewResumesV2AndExplicitlyStartsV3() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchEnvironment["SC_A1_V2_FIXTURE"] = "1"
        app.launch()
        XCTAssertTrue(app.buttons["today.lesson"].waitForExistence(timeout: 10))
        app.buttons["today.lesson"].tap()
        let draft = app.descendants(matching: .any)["lesson.response.a1-home-read"].firstMatch
        XCTAssertTrue(draft.waitForExistence(timeout: 8))
        XCTAssertEqual(draft.value as? String, "Synthetic v2 home draft")
        XCTAssertFalse(app.staticTexts["lesson.topic.teaching"].exists)
        screenshot(app, "a1-exact-v2-resume")
        app.terminate(); app.launch()
        app.buttons["today.lesson"].tap()
        XCTAssertTrue(draft.waitForExistence(timeout: 8))
        XCTAssertEqual(draft.value as? String, "Synthetic v2 home draft")
        openSavedVersions(app)
        app.buttons["lesson.version.current"].tap()
        XCTAssertTrue(app.staticTexts["lesson.topic.teaching"].waitForExistence(timeout: 8))
        screenshot(app, "a1-v3-personal-preview")
        app.buttons["lesson.topic.extra"].tap()
        app.buttons["lesson.topic.day7"].tap()
        XCTAssertTrue(app.switches["lesson.practice.keep-text"].waitForExistence(timeout: 8))
        XCTAssertEqual(app.switches["lesson.practice.keep-text"].value as? String, "0")
        screenshot(app, "a1-separate-optional-check")
        tapFrontmostButton(app, "lesson.begin")
        tapFrontmostButton(app, "lesson.speak")
        XCTAssertTrue(app.descendants(matching: .any)["recording.lessonContext"].firstMatch.waitForExistence(timeout: 5))
        app.buttons["recording.start"].tap()
        XCTAssertTrue(app.buttons["recording.stop"].waitForExistence(timeout: 10))
        let elapsed = app.staticTexts["recording.elapsed"]
        expectation(for: NSPredicate { _, _ in Int(elapsed.value as? String ?? "0") ?? 0 >= 2 }, evaluatedWith: nil)
        waitForExpectations(timeout: 8)
        app.buttons["recording.stop"].tap()
        tapReachable(app, app.buttons["recording.accept"])
        tapReachable(app, app.buttons["recording.finish"])
        tapFrontmostButton(app, "Done")
        XCTAssertTrue(app.buttons["lesson.next"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.staticTexts["lesson.completed"].exists)
        screenshot(app, "a1-optional-speaking-return")
        tapFrontmostButton(app, "Done")
        openSavedVersions(app)
        app.buttons["lesson.version.2"].tap()
        XCTAssertTrue(draft.waitForExistence(timeout: 8))
        XCTAssertEqual(draft.value as? String, "Synthetic v2 home draft")
    }

    private func tapFrontmostButton(_ app: XCUIApplication, _ identifier: String) {
        for _ in 0..<8 {
            if let target = app.buttons.matching(identifier: identifier).allElementsBoundByIndex.reversed().first(where: { $0.isHittable }) {
                target.tap(); return
            }
            app.swipeUp()
        }
        XCTFail("No visible frontmost button: \(identifier)")
    }

    @MainActor
    func testConnectedConversationDraftRecoveryAndDiscard() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        openDestination(app, title: "Speech Lab", id: "speechLab")
        tapReachable(app, app.buttons["speech.conversation"])
        let situation = app.descendants(matching: .any)["conversation.situation"].firstMatch
        tapReachable(app, situation); situation.typeText("A fictional lunch order")
        tapReachable(app, app.buttons["conversation.start"])
        let draft = app.descendants(matching: .any)["conversation.draft"].firstMatch
        tapReachable(app, draft); draft.typeText("Synthetic unfinished turn")
        tapReachable(app, app.buttons["practice.draft.keep"])
        XCTAssertTrue(app.staticTexts["practice.storage.message"].waitForExistence(timeout: 5))
        app.terminate(); app.launch()
        openDestination(app, title: "Speech Lab", id: "speechLab")
        tapReachable(app, app.buttons["speech.conversation"])
        XCTAssertTrue(draft.waitForExistence(timeout: 8))
        XCTAssertEqual(draft.value as? String, "Synthetic unfinished turn")
        tapReachable(app, app.buttons["conversation.send"])
        XCTAssertFalse(app.buttons["conversation.partner"].isEnabled)
        tapReachable(app, app.buttons["conversation.end"])
        tapReachable(app, app.buttons["conversation.discard"])
        screenshot(app, "connected-conversation-discard")
        app.terminate(); app.launch()
        openDestination(app, title: "Speech Lab", id: "speechLab")
        tapReachable(app, app.buttons["speech.conversation"])
        XCTAssertFalse(app.staticTexts["Synthetic unfinished turn"].exists)
        XCTAssertTrue(app.buttons["practice.new"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testConnectedInterviewRecordsAndReturnsToExactAnswer() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        openDestination(app, title: "Speech Lab", id: "speechLab")
        tapReachable(app, app.buttons["speech.interview"])
        let role = app.descendants(matching: .any)["interview.role"].firstMatch
        for _ in 0..<5 {
            if role.exists { break }
            app.swipeUp()
        }
        screenshot(app, "connected-interview-setup")
        tapReachable(app, role)
        app.descendants(matching: .any)["interview.role"].firstMatch.typeText("Fictional librarian")
        tapReachable(app, app.buttons["interview.start"])
        tapReachable(app, app.buttons["interview.record"])
        XCTAssertTrue(app.staticTexts["recording.prompt"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["recording.prompt"].label.contains("role you named"))
        app.buttons["recording.start"].tap()
        XCTAssertTrue(app.buttons["recording.stop"].waitForExistence(timeout: 10))
        let elapsed = app.staticTexts["recording.elapsed"]
        expectation(for: NSPredicate { _, _ in Int(elapsed.value as? String ?? "0") ?? 0 >= 2 }, evaluatedWith: nil)
        waitForExpectations(timeout: 8)
        app.buttons["recording.stop"].tap()
        tapReachable(app, app.buttons["recording.accept"])
        tapReachable(app, app.buttons["recording.finish"])
        app.buttons["Done"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["interview.recording.attached"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["interview.recording.attached"].label.contains("opening answer"))
        tapReachable(app, app.descendants(matching: .any)["interview.opening"].firstMatch)
        app.descendants(matching: .any)["interview.opening"].firstMatch.typeText("I organize fictional books.")
        tapReachable(app, app.buttons["interview.opening.submit"])
        XCTAssertTrue(app.staticTexts["interview.followup"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["interview.followup"].label.contains("I organize fictional books."))
        XCTAssertFalse(app.buttons["interview.online"].isEnabled)
        tapReachable(app, app.buttons["interview.end"])
        tapReachable(app, app.buttons["interview.discard"])
        screenshot(app, "connected-interview-discard")
    }

    @MainActor
    func testCommunicationDraftSharesExactSourceAcrossLearnAndSpeechLab() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        openDestination(app, title: "Lesson", id: "learn")
        tapReachable(app, app.buttons["learn.open.a1-greetings"])
        tapReachable(app, app.buttons["lesson.topic.extra"])
        app.buttons["lesson.communication"].tap()
        XCTAssertTrue(app.staticTexts["communication.lesson.source"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["communication.lesson.source"].label.contains("version 4"))
        let purpose = app.descendants(matching: .any)["communication.purpose"].firstMatch
        tapReachable(app, purpose); purpose.typeText("Synthetic communication purpose")
        tapReachable(app, app.buttons["communication.start"])
        let answer = app.descendants(matching: .any)["communication.answer"].firstMatch
        tapReachable(app, answer); answer.typeText("Synthetic communication draft")
        tapReachable(app, app.buttons["practice.draft.keep"])
        XCTAssertTrue(app.staticTexts["practice.storage.message"].waitForExistence(timeout: 5))
        app.terminate(); app.launch()
        openDestination(app, title: "Speech Lab", id: "speechLab")
        tapReachable(app, app.buttons["speech.communication"])
        tapReachable(app, app.buttons["communication.open.a1-greetings.3"])
        XCTAssertTrue(answer.waitForExistence(timeout: 5))
        XCTAssertEqual(answer.value as? String, "Synthetic communication draft")
        tapReachable(app, app.buttons["communication.save"])
        XCTAssertEqual(app.staticTexts["communication.saved.answer"].label, "Synthetic communication draft")
        tapReachable(app, answer); answer.typeText(" Revised.")
        tapReachable(app, app.buttons["communication.retry"])
        XCTAssertTrue(app.staticTexts["communication.saved.answer"].label.contains("Revised."))
        tapReachable(app, app.buttons["communication.stop"])
        tapReachable(app, app.buttons["communication.end"])
        tapReachable(app, app.buttons["communication.discard"])
        screenshot(app, "communication-linked-discard")
        app.terminate(); app.launch()
        openDestination(app, title: "Speech Lab", id: "speechLab")
        tapReachable(app, app.buttons["speech.communication"])
        tapReachable(app, app.buttons["communication.open.a1-greetings.3"])
        XCTAssertTrue(app.buttons["practice.new"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Synthetic communication draft"].exists)
        tapReachable(app, app.buttons["practice.new"])
        XCTAssertTrue(app.buttons["communication.start"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testCommunicationRecordingReturnsToItsOwnResponse() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        openDestination(app, title: "Speech Lab", id: "speechLab")
        tapReachable(app, app.buttons["speech.communication"])
        tapReachable(app, app.buttons["communication.open.standalone"])
        let purpose = app.descendants(matching: .any)["communication.purpose"].firstMatch
        tapReachable(app, purpose); purpose.typeText("Synthetic recorded purpose")
        tapReachable(app, app.buttons["communication.start"])
        tapReachable(app, app.buttons["communication.record"])
        XCTAssertTrue(app.staticTexts["recording.prompt"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["recording.prompt"].label.contains("Synthetic recorded purpose"))
        app.buttons["recording.start"].tap()
        XCTAssertTrue(app.buttons["recording.stop"].waitForExistence(timeout: 10))
        let elapsed = app.staticTexts["recording.elapsed"]
        expectation(for: NSPredicate { _, _ in Int(elapsed.value as? String ?? "0") ?? 0 >= 2 }, evaluatedWith: nil)
        waitForExpectations(timeout: 8)
        app.buttons["recording.stop"].tap()
        tapReachable(app, app.buttons["recording.accept"])
        tapReachable(app, app.buttons["recording.finish"])
        app.buttons["Done"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["communication.recording.attached"].waitForExistence(timeout: 5))
        tapReachable(app, app.buttons["communication.save"])
        tapReachable(app, app.buttons["communication.stop"])
        tapReachable(app, app.buttons["communication.discard"])
        screenshot(app, "communication-recording-discard")
        XCTAssertTrue(app.buttons["practice.new"].exists)
    }

    private func openSavedVersions(_ app: XCUIApplication) {
        let contents = app.buttons["lesson.contents"]
        XCTAssertTrue(contents.waitForExistence(timeout: 5))
        contents.tap()
    }

    @MainActor
    func testResourceBookmarkSaveEditRestartAndExternalFailure() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchEnvironment["SC_RESOURCE_OPEN_FAILURE"] = "1"
        app.launch()
        openResourceLibrary(app)
        tapReachable(app, app.buttons["resources.add"])
        let title = app.descendants(matching: .any)["resources.editor.title"].firstMatch
        let url = app.descendants(matching: .any)["resources.editor.url"].firstMatch
        let notes = app.textViews["resources.editor.notes"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        tapReachable(app, title); title.typeText("Synthetic speaking bookmark")
        tapReachable(app, url); url.typeText("https://youtu.be/abcdefghijk?si=synthetic")
        tapReachable(app, notes); notes.typeText("Synthetic notes stay local.")
        app.buttons["resources.editor.save"].tap()
        XCTAssertTrue(app.buttons["resources.add"].waitForExistence(timeout: 5))
        screenshot(app, "resources-saved")
        app.terminate(); app.launch(); openResourceLibrary(app)
        XCTAssertTrue(app.staticTexts["Synthetic notes stay local."].waitForExistence(timeout: 5))
        let edit = resourceAction(app, prefix: "resources.edit.")
        tapReachable(app, edit)
        XCTAssertTrue(notes.waitForExistence(timeout: 5))
        tapReachable(app, notes); notes.typeText(" Updated.")
        app.buttons["resources.editor.save"].tap()
        let editedNotes = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@ AND label CONTAINS %@", "Synthetic notes stay local.", "Updated.")).firstMatch
        XCTAssertTrue(editedNotes.waitForExistence(timeout: 5))
        let search = app.textFields["resources.search"]
        tapReachable(app, search); search.typeText("Updated\n")
        let open = resourceAction(app, prefix: "resources.open.")
        tapReachable(app, open)
        XCTAssertTrue(app.alerts["Open external website?"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.alerts.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "https://www.youtube.com/watch?v=abcdefghijk")).firstMatch.exists)
        app.alerts.buttons["Cancel"].tap()
        XCTAssertFalse(app.alerts["Open external website?"].exists)
        tapReachable(app, open); app.alerts.buttons["resources.open.confirm"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["resources.message"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["resources.message"].label.contains("could not be opened"))
        screenshot(app, "resources-external-open-failed")
        let remove = resourceAction(app, prefix: "resources.remove.")
        tapReachable(app, remove); app.buttons["Remove bookmark"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["resources.empty"].firstMatch.waitForExistence(timeout: 5))
        app.terminate(); app.launch(); openResourceLibrary(app)
        XCTAssertFalse(app.staticTexts["Synthetic notes stay local. Updated."].exists)
    }

    @MainActor
    func testResourceOfflineSourceSaveAndUnsavedDiscard() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchEnvironment["SC_RESOURCE_OFFLINE"] = "1"
        app.launch()
        openResourceLibrary(app)
        XCTAssertTrue(app.descendants(matching: .any)["resources.offline"].firstMatch.waitForExistence(timeout: 5))
        let sourceOpen = app.buttons["resources.source.open.voa-youtube"]
        tapReachable(app, app.buttons["resources.source.save.voa-youtube"])
        let title = app.descendants(matching: .any)["resources.editor.title"].firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        XCTAssertEqual(title.value as? String, "VOA Learning English on YouTube")
        app.buttons["resources.editor.save"].tap()
        let edit = resourceAction(app, prefix: "resources.edit.")
        tapReachable(app, edit)
        let notes = app.textViews["resources.editor.notes"]
        tapReachable(app, notes); notes.typeText("Unsaved synthetic note")
        app.buttons["resources.editor.cancel"].tap()
        app.buttons["Keep editing"].tap()
        XCTAssertEqual(notes.value as? String, "Unsaved synthetic note")
        app.buttons["resources.editor.cancel"].tap(); app.buttons["Discard changes"].tap()
        XCTAssertTrue(app.buttons["resources.add"].waitForExistence(timeout: 5))
        app.terminate(); app.launch(); openResourceLibrary(app)
        XCTAssertFalse(app.staticTexts["Unsaved synthetic note"].exists)
        let open = resourceAction(app, prefix: "resources.open.")
        XCTAssertFalse(open.isEnabled)
        for _ in 0..<6 where !sourceOpen.isHittable { app.swipeUp() }
        XCTAssertFalse(sourceOpen.isEnabled)
        screenshot(app, "resources-offline-source")
        try auditVisibleContent(app, types: [.hitRegion, .sufficientElementDescription])
    }

    @MainActor
    func testResourceRealSystemHandoffAndReturnPreservesNotes() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch() // No offline/refused-open override: exercise the real system URL handler.
        openResourceLibrary(app)
        tapReachable(app, app.buttons["resources.source.save.voa-learning-english"])
        let notes = app.textViews["resources.editor.notes"]
        XCTAssertTrue(notes.waitForExistence(timeout: 5))
        tapReachable(app, notes); notes.typeText("Synthetic note for external handoff.")
        app.buttons["resources.editor.save"].tap()
        XCTAssertTrue(app.buttons["resources.add"].waitForExistence(timeout: 5))
        tapReachable(app, resourceAction(app, prefix: "resources.open."))
        XCTAssertTrue(app.alerts["Open external website?"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.alerts.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "https://learningenglish.voanews.com/")).firstMatch.exists)
        app.alerts.buttons["resources.open.confirm"].firstMatch.tap()
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        XCTAssertTrue(safari.wait(for: .runningForeground, timeout: 20), "System handoff must actually foreground Safari")
        app.activate()
        XCTAssertTrue(app.buttons["resources.add"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Synthetic note for external handoff."].exists)
        XCTAssertFalse(app.alerts["Open external website?"].exists)
        screenshot(app, "resources-real-handoff-return")
        // Safari foreground proves handoff only, not page loading, redirects or teaching quality.
    }

    @MainActor
    private func openResourceLibrary(_ app: XCUIApplication) {
        openDestination(app, title: "Lesson", id: "learn")
        tapReachable(app, app.buttons["learn.resources"])
        XCTAssertTrue(app.buttons["resources.add"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func resourceAction(_ app: XCUIApplication, prefix: String) -> XCUIElement {
        let button = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix)).firstMatch
        // Lazy bookmark rows expose offscreen actions only after scrolling into the viewport.
        for _ in 0..<8 where !button.exists { app.swipeUp() }
        return button
    }

    @MainActor
    private func openGeneratedPractice(_ app: XCUIApplication) {
        openDestination(app, title: "Speech Lab", id: "speechLab")
        tapReachable(app, app.buttons["speech.generated"])
        XCTAssertTrue(app.buttons["generated.request"].waitForExistence(timeout: 5))
    }

    private func screenshot(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
    @MainActor
    func testRewardWalletCancellationPurchaseAndRestart() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchEnvironment["SC_REWARD_FIXTURE"] = "1"
        app.launch()
        tapReachable(app, app.buttons["rewards.open"])
        let balance = app.staticTexts["rewards.balance"]
        XCTAssertTrue(balance.waitForExistence(timeout: 10))
        XCTAssertTrue(balance.label.contains("34 gold"), balance.label)
        tapReachable(app, app.buttons["rewards.buy-freeze"])
        XCTAssertTrue(app.alerts["Confirm gold purchase"].waitForExistence(timeout: 3))
        app.alerts.buttons["Cancel"].tap()
        XCTAssertTrue(balance.label.contains("34 gold"))
        tapReachable(app, app.buttons["rewards.buy-freeze"])
        app.alerts.buttons["rewards.purchase.confirm"].firstMatch.tap()
        XCTAssertTrue(balance.label.contains("14 gold"), balance.label)
        let image = XCTAttachment(screenshot: app.screenshot()); image.name = "SC-D005-wallet-after-one-confirmed-purchase"; image.lifetime = .keepAlways; add(image)
        app.terminate(); app.launch()
        tapReachable(app, app.buttons["rewards.open"])
        XCTAssertTrue(app.staticTexts["rewards.balance"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["rewards.balance"].label.contains("14 gold"))
    }

    @MainActor
    func testRewardLargeTextDarkPreferencesAndUnavailableLearning() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchEnvironment["SC_REWARD_FIXTURE"] = "1"
        app.launchEnvironment["SC_REWARD_DARK_FIXTURE"] = "1"
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        tapReachable(app, app.buttons["rewards.open"])
        XCTAssertTrue(app.staticTexts["rewards.balance"].waitForExistence(timeout: 10))
        tapReachable(app, app.buttons["rewards.settings"])
        XCTAssertTrue(app.navigationBars["Reward preferences"].waitForExistence(timeout: 5))
        let screenshot = XCTAttachment(screenshot: app.screenshot()); screenshot.name = "SC-D005-dark-large-text-preferences"; screenshot.lifetime = .keepAlways; add(screenshot)
        let back = app.navigationBars["Reward preferences"].buttons.matching(NSPredicate(format: "identifier == 'BackButton' OR label == 'Rewards & achievements'")).firstMatch
        XCTAssertTrue(back.exists); back.tap()
        for _ in 0..<18 {
            if app.buttons["rewards.category"].exists { break }
            app.swipeUp()
        }
        tapReachable(app, app.buttons["rewards.category"])
        app.buttons["Learning"].firstMatch.tap()
        tapReachable(app, app.buttons["rewards.family.AW-LE-01"])
        XCTAssertTrue(app.staticTexts["Assessment or content not yet available"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["rewards.purchase.confirm"].exists)
        let detail = XCTAttachment(screenshot: app.screenshot()); detail.name = "SC-D005-unavailable-learning-detail"; detail.lifetime = .keepAlways; add(detail)
    }

}
