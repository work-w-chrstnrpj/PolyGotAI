import XCTest

final class Phase9LabTests: XCTestCase {
    override func setUp() { super.setUp(); continueAfterFailure = false }
    @MainActor private func launch(online: Bool = true, dark: Bool = false, large: Bool = false) -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchEnvironment["SC_SPEECHLAB_FIXTURE"] = "1"
        if online { app.launchEnvironment["SC_TALK_FIXTURE"] = "1" }
        if dark { app.launchEnvironment["SC_REWARD_DARK_FIXTURE"] = "1" }
        if large { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        app.launch(); openLab(app); return app
    }
    @MainActor private func openLab(_ app: XCUIApplication) {
        let tab = app.tabBars.buttons["Lab"]
        if tab.waitForExistence(timeout: 5) { tab.tap() }
        else { app.buttons["navigation.speechLab"].firstMatch.tap() }
        XCTAssertTrue(app.buttons["speech.talk"].waitForExistence(timeout: 8))
    }
    @MainActor private func tap(_ app: XCUIApplication, _ element: XCUIElement) {
        for _ in 0..<8 {
            if element.exists && element.isHittable { element.tap(); return }
            app.swipeUp()
        }
        XCTFail("Cannot tap \(element)")
    }
    @MainActor private func capture(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot); attachment.name = "phase9-" + name; attachment.lifetime = .keepAlways; add(attachment)
        let folder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("Phase9Evidence")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try? screenshot.pngRepresentation.write(to: folder.appendingPathComponent(name + ".png"))
    }
    /// Phase 12: without a key, Talk still shows and opens the key setup. Speaking and Spelling left the Lab on 2026-10-30.
    @MainActor func testOfflineLabTalkOpensSetup() {
        let app = launch(online: false)
        tap(app, app.buttons["speech.talk"])
        tap(app, app.buttons["ai.setup.done"])
        XCTAssertFalse(app.buttons["speech.speaking"].exists)
        XCTAssertFalse(app.buttons["speech.spelling"].exists)
        capture("lab-offline-light")
    }
    @MainActor func testTalkModesStopClearAndVoice() {
        let app = launch()
        capture("lab-online-light")
        tap(app, app.buttons["speech.talk"])
        for mode in ["Free talk", "Interview", "Scenario"] {
            if mode != "Free talk" {
                tap(app, app.buttons["talk.mode"]); app.buttons[mode].tap()
            }
            let toggle = app.switches["talk.handsFree"]
            if toggle.value as? String == "1" { tap(app, toggle) }
            tap(app, app.buttons["talk.mic"])
            XCTAssertTrue(app.buttons["talk.stop"].waitForExistence(timeout: 5))
            tap(app, app.buttons["talk.mic"])
            let reply = app.descendants(matching: .any)["talk.turn.assistant"].firstMatch
            XCTAssertTrue(reply.waitForExistence(timeout: 8))
            let ready = NSPredicate(format: "label == %@", "Ready")
            expectation(for: ready, evaluatedWith: app.staticTexts["talk.state"])
            waitForExpectations(timeout: 8)
            XCTAssertEqual(app.staticTexts["talk.currentMode"].label, mode)
            capture("talk-\(mode.replacingOccurrences(of: " ", with: "-"))-light")
            tap(app, app.buttons["talk.mic"]); tap(app, app.buttons["talk.stop"])
            tap(app, app.buttons["talk.clear"])
            XCTAssertFalse(app.descendants(matching: .any)["talk.turn.user"].firstMatch.exists)
        }
        app.navigationBars.buttons.firstMatch.tap()
        tap(app, app.buttons["speech.voice"])
        XCTAssertTrue(app.sliders["voice.rate"].waitForExistence(timeout: 5))
        app.sliders["voice.rate"].adjust(toNormalizedSliderPosition: 0.75)
        let savedRate = app.staticTexts["voice.rateValue"].label
        XCTAssertNotEqual(savedRate, "100%")
        capture("voice-light")
        app.terminate(); app.launch(); openLab(app); tap(app, app.buttons["speech.voice"])
        XCTAssertTrue(app.staticTexts["voice.rateValue"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["voice.rateValue"].label, savedRate)
    }
    @MainActor func testLargestTextAndRotation() {
        let app = launch(large: true)
        capture("lab-largest-text")
        tap(app, app.buttons["speech.timedTests"])
        XCTAssertTrue(app.buttons["timed.writing"].waitForExistence(timeout: 5))
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(app.buttons["timed.writing"].exists)
        capture("timed-largest-landscape")
        XCUIDevice.shared.orientation = .portrait
        app.navigationBars.buttons.firstMatch.tap()
        tap(app, app.buttons["speech.talk"])
        XCTAssertTrue(app.buttons["talk.mic"].waitForExistence(timeout: 5))
        capture("talk-largest-text")
    }
    @MainActor func testDarkModeLabAndTalk() throws {
        let app = launch(dark: true)
        capture("lab-dark")
        tap(app, app.buttons["speech.talk"])
        try app.performAccessibilityAudit(for: [.hitRegion, .sufficientElementDescription])
        for mode in ["Free talk", "Interview", "Scenario"] {
            if mode != "Free talk" { tap(app, app.buttons["talk.mode"]); app.buttons[mode].tap() }
            let toggle = app.switches["talk.handsFree"]
            if toggle.value as? String == "1" { tap(app, toggle) }
            tap(app, app.buttons["talk.mic"])
            XCTAssertTrue(app.buttons["talk.stop"].waitForExistence(timeout: 5))
            tap(app, app.buttons["talk.mic"])
            XCTAssertTrue(app.descendants(matching: .any)["talk.turn.assistant"].firstMatch.waitForExistence(timeout: 8))
            expectation(for: NSPredicate(format: "label == %@", "Ready"), evaluatedWith: app.staticTexts["talk.state"])
            waitForExpectations(timeout: 8)
            capture("talk-\(mode.replacingOccurrences(of: " ", with: "-"))-dark")
            tap(app, app.buttons["talk.clear"])
        }
        app.navigationBars.buttons.firstMatch.tap()
        tap(app, app.buttons["speech.voice"]); capture("voice-dark")
        app.navigationBars.buttons.firstMatch.tap()
        tap(app, app.buttons["speech.videos"]); capture("videos-dark")
        XCUIDevice.shared.orientation = .landscapeLeft
        capture("videos-landscape")
        XCUIDevice.shared.orientation = .portrait
    }
}
