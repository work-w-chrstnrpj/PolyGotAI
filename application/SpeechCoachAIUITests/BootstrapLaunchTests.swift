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
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        XCTAssertTrue(app.buttons["settings.open"].firstMatch.waitForExistence(timeout: 10))
        screenshot(app, "today")
        for (title, id) in [("Lesson", "learn"), ("Lexicon", "vocabulary"), ("Lab", "speechLab"), ("Progress", "progress"), ("Today", "today")] {
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
        app.segmentedControls["learn.mode"].buttons["Course"].tap()
        let weather = app.buttons["learn.open.a1-weather"]
        for _ in 0..<16 where !weather.exists { app.swipeUp() }
        tapReachable(app, weather)
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
        field.tap(); field.typeText("The weather is cold today.")
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
    func testProviderSettingsShowsMaskedEntryAndNoLiveAction() {
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        XCTAssertTrue(app.buttons["settings.open"].firstMatch.waitForExistence(timeout: 10))
        app.buttons["settings.open"].firstMatch.tap()
        let entry = app.buttons["settings.provider"]
        for _ in 0..<4 where !entry.isHittable { app.swipeUp() }
        XCTAssertTrue(entry.isHittable); entry.tap()
        XCTAssertTrue(app.secureTextFields["provider.key"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.secureTextFields["provider.workspace"].exists)
        XCTAssertFalse(app.buttons["Check connection"].exists)
        screenshot(app, "provider-settings-local-only")
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
            // iOS 27 also scans rows scrolled up behind the navigation bar. A row that ends at or above the bar's
            // lower edge shows no pixel to the learner; a row that reaches below the bar is still audited.
            let bar = app.navigationBars.firstMatch
            if issue.auditType == .contrast, bar.exists, element.frame.maxY <= bar.frame.maxY {
                print("AUDIT_ABOVE_SCREEN_ROW", element.label)
                return true
            }
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











    /// Lexicon › Settings › Review options. The settings rows are created as they scroll into view.
    @MainActor private func openReviewOptions(_ app: XCUIApplication) {
        tapReachable(app, app.buttons["lexicon.settings"])
        XCTAssertTrue(app.buttons["lexicon.settings.done"].waitForExistence(timeout: 5))
        let link = app.buttons["vocabulary.options.open"]
        for _ in 0..<25 where !(link.exists && link.isHittable) { app.swipeUp() }
        link.tap()
    }

    /// Phase 8: review options live in Lexicon › Training settings.
    @MainActor
    func testReviewOptionsPersistAndLimitOneSession() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        openDestination(app, title: "Lexicon", id: "vocabulary")
        openReviewOptions(app)
        let retention = app.textFields["vocabulary.options.retention"]
        XCTAssertTrue(retention.waitForExistence(timeout: 5))
        XCTAssertEqual(retention.value as? String, "90")
        retention.tap(); retention.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 2) + "95")
        let limit = app.textFields["vocabulary.options.limit"]
        limit.tap(); limit.typeText("0")
        app.buttons["vocabulary.options.keyboard.done"].tap()
        tapReachable(app, app.buttons["vocabulary.options.save"])
        XCTAssertTrue(app.staticTexts["vocabulary.options.message"].label.contains("positive whole number"))
        limit.tap(); limit.typeText(XCUIKeyboardKey.delete.rawValue + "1")
        app.buttons["vocabulary.options.keyboard.done"].tap()
        tapReachable(app, app.buttons["vocabulary.options.save"])
        XCTAssertTrue(app.staticTexts["vocabulary.options.message"].label.contains("Review options saved"))
        // Back to the top so no row sits half under the sheet's translucent bar during the audit.
        for _ in 0..<3 { app.swipeDown(velocity: .slow) }
        screenshot(app, "review-options-saved")
        try auditVisibleContent(app, types: [.contrast, .sufficientElementDescription])
        app.terminate(); app.launch()
        openDestination(app, title: "Lexicon", id: "vocabulary")
        openReviewOptions(app)
        XCTAssertEqual(app.textFields["vocabulary.options.limit"].value as? String, "1")
        XCTAssertEqual(app.textFields["vocabulary.options.retention"].value as? String, "95")
    }

    @MainActor
    private func createReviewWords(_ app: XCUIApplication) {
        openDestination(app, title: "Lexicon", id: "vocabulary")
        openSavedWords(app)
        tapReachable(app, app.buttons["vocabulary.topic.new"])
        let title = app.textFields["vocabulary.topic.title"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        title.tap(); title.typeText("Kitchen")
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
        let back = app.navigationBars.buttons["My words"].firstMatch
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
        XCTAssertTrue(app.buttons["today.lesson"].waitForExistence(timeout: 10))
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
    private func openSavedVersions(_ app: XCUIApplication) {
        let contents = app.buttons["lesson.contents"]
        XCTAssertTrue(contents.waitForExistence(timeout: 5)); contents.tap()
    }

    @MainActor
    func testRemainingFreeTextFieldsExposeDictation() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchEnvironment["SC_DICTATION_FIXTURE"] = "1"
        app.launch()
        openResourceLibrary(app)
        tapReachable(app, app.buttons["resources.add"])
        let microphones = app.buttons.matching(identifier: "dictation.button")
        XCTAssertEqual(microphones.count, 3, "Title, topic and notes each have a microphone; the URL does not.")
        microphones.element(boundBy: 0).tap()
        XCTAssertEqual(app.textFields["resources.editor.title"].value as? String, "Synthetic dictated text")
        screenshot(app, "round4-resource-dictation")
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


    private func screenshot(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
    @MainActor
    func testLevelAndBadgesShowXPOnlyAndSurviveRestart() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchEnvironment["SC_REWARD_FIXTURE"] = "1"
        app.launch()
        tapReachable(app, app.buttons["rewards.open"])
        let balance = app.staticTexts["rewards.balance"]
        XCTAssertTrue(balance.waitForExistence(timeout: 10))
        XCTAssertTrue(balance.label.contains("XP"), balance.label)
        XCTAssertFalse(balance.label.localizedCaseInsensitiveContains("gold"))
        XCTAssertTrue(app.staticTexts["rewards.level"].exists)
        XCTAssertFalse(app.buttons["rewards.buy-freeze"].exists)
        let image = XCTAttachment(screenshot: app.screenshot()); image.name = "level-and-badges"; image.lifetime = .keepAlways; add(image)
        app.terminate(); app.launch()
        tapReachable(app, app.buttons["rewards.open"])
        XCTAssertTrue(app.staticTexts["rewards.balance"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["rewards.balance"].label.contains("XP"))
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
        let back = app.navigationBars["Reward preferences"].buttons.matching(NSPredicate(format: "identifier == 'BackButton' OR label == 'Level and badges'")).firstMatch
        XCTAssertTrue(back.exists); back.tap()
        for _ in 0..<18 {
            if app.buttons["rewards.category"].exists { break }
            app.swipeUp()
        }
        tapReachable(app, app.buttons["rewards.category"])
        app.buttons["Completion"].firstMatch.tap()
        // v2: badges nothing can earn are hidden; a new coach badge shows instead.
        XCTAssertFalse(app.buttons["rewards.family.AW-LE-01"].exists)
        let coach = app.buttons["rewards.family.AW-TK-01"]
        for _ in 0..<12 where !coach.exists { app.swipeUp() }   // the badge list is lazy
        tapReachable(app, coach)
        XCTAssertTrue(app.staticTexts["Not earned yet"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["rewards.purchase.confirm"].exists)
        let detail = XCTAttachment(screenshot: app.screenshot()); detail.name = "SC-D005-unavailable-learning-detail"; detail.lifetime = .keepAlways; add(detail)
    }


    /// The Lexicon tab opens on Daily Training; saved words and topics are one step in.
    @MainActor
    private func openSavedWords(_ app: XCUIApplication) {
        let link = app.buttons["lexicon.mywords"]
        XCTAssertTrue(link.waitForExistence(timeout: 8))
        link.tap()
    }
}
