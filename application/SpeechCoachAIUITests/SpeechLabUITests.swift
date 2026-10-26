import XCTest

final class SpeechLabUITests: XCTestCase {
    override func setUp() { super.setUp(); continueAfterFailure = false }
    @MainActor private func launch(fixture: Bool = false, large: Bool = false) -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        if fixture { app.launchEnvironment["SC_SPEECHLAB_FIXTURE"] = "1" }
        if large {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
            app.launchEnvironment["SC_REWARD_DARK_FIXTURE"] = "1"
        }
        app.launch(); openLab(app); return app
    }
    @MainActor private func openLab(_ app: XCUIApplication) {
        let tab = app.tabBars.buttons["Speech Lab"]
        if tab.waitForExistence(timeout: 3) { tab.tap() }
        else {
            let button = app.buttons["navigation.speechLab"].firstMatch
            XCTAssertTrue(button.waitForExistence(timeout: 8)); button.tap()
        }
        XCTAssertTrue(app.buttons["speech.dictation"].waitForExistence(timeout: 8))
    }
    @MainActor private func tap(_ app: XCUIApplication, _ element: XCUIElement) {
        for _ in 0..<10 {
            if element.exists && element.isHittable { break }
            if element.exists && element.frame.maxY < app.frame.midY { app.swipeDown() }
            else { app.swipeUp() }
        }
        XCTAssertTrue(element.waitForExistence(timeout: 5)); XCTAssertTrue(element.isHittable); element.tap()
    }
    @MainActor private func capture(_ name: String) {
        let item = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        item.name = "phase5-\(name)"; item.lifetime = .keepAlways; add(item)
    }
    @MainActor func testDictationChecksPersistsMissesAndClearsReviewOnSuccess() {
        let app = launch()
        tap(app, app.buttons["speech.dictation"])
        tap(app, app.buttons["dictation.item.dict-a1-1"])
        let answer = app.descendants(matching: .any)["dictation.answer"].firstMatch
        XCTAssertTrue(answer.waitForExistence(timeout: 5)); answer.tap(); answer.typeText("the cat is by the gate")
        tap(app, app.buttons["dictation.check"])
        XCTAssertEqual(app.staticTexts["dictation.result"].label, "5 of 6 words")
        capture("dictation-diff")
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.buttons["dictation.missed"].waitForExistence(timeout: 5))
        app.terminate(); app.launch(); openLab(app)
        tap(app, app.buttons["speech.dictation"])
        tap(app, app.buttons["dictation.missed"])
        tap(app, app.buttons["dictation.item.dict-a1-1"])
        let again = app.descendants(matching: .any)["dictation.answer"].firstMatch
        XCTAssertTrue(again.waitForExistence(timeout: 5)); again.tap(); again.typeText("the cat is by the door")
        tap(app, app.buttons["dictation.check"])
        XCTAssertEqual(app.staticTexts["dictation.result"].label, "6 of 6 words")
        app.navigationBars.buttons.firstMatch.tap(); app.navigationBars.buttons.firstMatch.tap()
        XCTAssertFalse(app.buttons["dictation.missed"].exists)
        tap(app, app.buttons["speechlab.history"])
        XCTAssertTrue(app.staticTexts["6 of 6 words"].exists)
    }
    @MainActor func testPhoneticsChartListenChooseSayAndSave() {
        let app = launch(fixture: true)
        tap(app, app.buttons["speech.pronunciation"]); tap(app, app.buttons["pronunciation.sounds"])
        tap(app, app.buttons["phonetics.sound.sound-i"])
        XCTAssertTrue(app.buttons["phonetics.hear"].waitForExistence(timeout: 5))
        capture("phonetics-sound")
        tap(app, app.buttons["phonetics.practice"])
        XCTAssertTrue(app.buttons["exercise.choice.sheep"].waitForExistence(timeout: 5))
        app.buttons["exercise.choice.sheep"].tap(); app.buttons["exercise.check"].tap()
        XCTAssertTrue(app.staticTexts["Correct!"].waitForExistence(timeout: 5))
        app.buttons["exercise.continue"].tap()
        tap(app, app.buttons["speechlab.record"]); tap(app, app.buttons["speechlab.stop"])
        XCTAssertTrue(app.staticTexts["speechlab.heard"].waitForExistence(timeout: 5))
        tap(app, app.buttons["speechlab.save"])
        XCTAssertTrue(app.staticTexts["speechlab.saved"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()
        tap(app, app.buttons["phonetics.prosody.stress-photograph"])
        app.buttons["exercise.choice.PHO"].tap(); app.buttons["exercise.check"].tap()
        XCTAssertTrue(app.staticTexts["Correct!"].waitForExistence(timeout: 5))
    }

    @MainActor func testArticulationListenRecordReplaySaveAndRetry() {
        let app = launch(fixture: true)
        tap(app, app.buttons["speech.pronunciation"]); tap(app, app.buttons["pronunciation.clear"])
        tap(app, app.buttons["articulation.item.art-pair-1"])
        tap(app, app.buttons["articulation.practice"])
        XCTAssertTrue(app.buttons["exercise.choice.ship"].waitForExistence(timeout: 5))
        app.buttons["exercise.choice.ship"].tap(); app.buttons["exercise.check"].tap()
        XCTAssertTrue(app.staticTexts["Correct!"].waitForExistence(timeout: 5))
        app.buttons["exercise.continue"].tap()
        tap(app, app.buttons["speechlab.record"]); tap(app, app.buttons["speechlab.stop"])
        XCTAssertTrue(app.staticTexts["speechlab.heard"].waitForExistence(timeout: 5))
        capture("articulation-compare")
        tap(app, app.buttons["speechlab.replay"])
        tap(app, app.buttons["speechlab.save"])
        XCTAssertTrue(app.staticTexts["speechlab.saved"].waitForExistence(timeout: 5))
        tap(app, app.buttons["speechlab.retry"]); tap(app, app.buttons["speechlab.stop"])
        tap(app, app.buttons["speechlab.save"])
        XCTAssertTrue(app.staticTexts["speechlab.saved"].waitForExistence(timeout: 5))
    }

    @MainActor func testVoiceRecordsMeasuresSavesAndCompletesWarmup() {
        let app = launch(fixture: true)
        tap(app, app.buttons["speech.speaking"])
        tap(app, app.buttons["voice.free"])
        tap(app, app.buttons["speechlab.record"])
        XCTAssertTrue(app.progressIndicators["voice.meter"].exists || app.descendants(matching: .any)["voice.meter"].firstMatch.exists)
        tap(app, app.buttons["speechlab.stop"])
        XCTAssertTrue(app.staticTexts["voice.wpm"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["voice.metrics"].exists)
        capture("voice-result")
        tap(app, app.buttons["speechlab.save"])
        XCTAssertTrue(app.staticTexts["speechlab.saved"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()
        tap(app, app.buttons["voice.warmup.warmup-hum"])
        tap(app, app.buttons["voice.warmup.start"])
        XCTAssertTrue(app.staticTexts["voice.warmup.complete"].waitForExistence(timeout: 5))
    }

    @MainActor func testRetainedSpeechAudioCanBeDeletedFromHistory() {
        let app = launch(fixture: true)
        tap(app, app.buttons["speech.speaking"]); tap(app, app.buttons["voice.free"])
        tap(app, app.buttons["speechlab.record"]); tap(app, app.buttons["speechlab.stop"])
        tap(app, app.switches["speechlab.keep"])
        tap(app, app.buttons["speechlab.save"])
        XCTAssertTrue(app.staticTexts["speechlab.saved"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()
        tap(app, app.buttons["speechlab.history"])
        XCTAssertTrue(app.buttons["speechlab.history.play"].waitForExistence(timeout: 5))
        app.buttons["Delete"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Delete this result and its saved audio?"].waitForExistence(timeout: 5))
        let deletes = app.buttons.matching(NSPredicate(format: "label == %@", "Delete")).allElementsBoundByIndex
        XCTAssertTrue(deletes.count >= 1)
        (deletes.last(where: { $0.isHittable }) ?? deletes.last!).tap()

        XCTAssertTrue(app.buttons["speechlab.history.play"].waitForNonExistence(timeout: 8))
    }

    @MainActor func testLargeTextDarkModeAndRotationLayouts() {
        let app = launch(fixture: true, large: true)
        defer { XCUIDevice.shared.orientation = .portrait }
        tap(app, app.buttons["speech.dictation"])
        XCTAssertTrue(app.descendants(matching: .any)["dictation.level"].firstMatch.waitForExistence(timeout: 5))
        capture("dictation-large-portrait")
        XCUIDevice.shared.orientation = .landscapeLeft
        let landscape = expectation(for: NSPredicate { _, _ in app.frame.width > app.frame.height }, evaluatedWith: app)
        wait(for: [landscape], timeout: 10)
        XCTAssertTrue(app.descendants(matching: .any)["dictation.level"].firstMatch.exists)
        capture("dictation-large-landscape")
        XCUIDevice.shared.orientation = .portrait
        let portrait = expectation(for: NSPredicate { _, _ in app.frame.height > app.frame.width }, evaluatedWith: app)
        wait(for: [portrait], timeout: 10)
        app.navigationBars.buttons.firstMatch.tap()
        // Each mode can be entered with the largest Dynamic Type size.
        for (id, title) in [("pronunciation", "Pronunciation"), ("speaking", "Speaking")] {
            tap(app, app.buttons["speech." + id])
            XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5))
            app.navigationBars.buttons.firstMatch.tap()
        }
    }

    @MainActor func testPhoneticsAccessibility() throws {
        let app = launch(fixture: true, large: true)
        tap(app, app.buttons["speech.pronunciation"]); tap(app, app.buttons["pronunciation.sounds"])
        try app.performAccessibilityAudit(for: [.dynamicType, .hitRegion, .sufficientElementDescription])
    }

    @MainActor func testMissingOnDeviceRecognitionHidesCapture() {
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchEnvironment["SC_SPEECHLAB_NO_RECOGNITION"] = "1"
        app.launch(); openLab(app)
        tap(app, app.buttons["speech.speaking"])
        XCTAssertFalse(app.buttons["voice.free"].exists)
        tap(app, app.buttons["voice.passage.voice-passage-1"])
        XCTAssertFalse(app.buttons["speechlab.record"].exists)
        XCTAssertTrue(app.buttons["speechlab.listen"].exists)
    }

}
