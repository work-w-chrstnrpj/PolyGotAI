import XCTest

final class Round4AccessibilityTests: XCTestCase {
    override func setUp() { super.setUp(); continueAfterFailure = false }
    @MainActor func testDarkModeDestinationsAndSpeechLabAccessibility() throws {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launchEnvironment["SC_SPEECHLAB_FIXTURE"] = "1"
        app.launchEnvironment["SC_REWARD_DARK_FIXTURE"] = "1"
        app.launch()
        XCTAssertTrue(app.buttons["settings.open"].firstMatch.waitForExistence(timeout: 10))
        for (title, id) in [("Today", "today"), ("Lexicon", "vocabulary"), ("Lesson", "learn"), ("Speech Lab", "speechLab"), ("Progress", "progress")] {
            destination(app, title: title, id: id)
            try audit(app)
            capture("dark-\(id)")
            if id == "learn" {
                app.segmentedControls["learn.mode"].buttons["Coaches"].tap()
                try audit(app); capture("dark-coaches")
            }
        }
        destination(app, title: "Speech Lab", id: "speechLab")
        for id in ["speech.dictation", "speech.pronunciation", "speech.speaking", "speech.interview", "speech.conversation"] {
            tap(app, app.buttons[id])
            XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 5))
            try audit(app)
            capture("dark-\(id)")
            app.navigationBars.buttons.firstMatch.tap()
        }
        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        XCTAssertTrue(app.buttons["navigation.speechLab"].firstMatch.waitForExistence(timeout: 5) || app.tabBars.buttons["Speech Lab"].exists)
        capture("landscape-speech-lab")
        for (title, id) in [("Today", "today"), ("Lexicon", "vocabulary"), ("Lesson", "learn"), ("Speech Lab", "speechLab"), ("Progress", "progress")] {
            destination(app, title: title, id: id)
            try audit(app)
            capture("landscape-\(id)")
        }
    }
    @MainActor private func destination(_ app: XCUIApplication, title: String, id: String) {
        let tab = app.tabBars.buttons[title]
        if tab.exists { tab.tap() } else { tap(app, app.buttons["navigation.\(id)"].firstMatch) }
        for _ in 0..<3 { app.swipeDown() }
    }
    @MainActor private func tap(_ app: XCUIApplication, _ item: XCUIElement) {
        for _ in 0..<18 {
            if item.exists && item.isHittable { item.tap(); return }
            if item.exists && item.frame.midY < app.frame.midY { app.swipeDown() } else { app.swipeUp() }
        }
        XCTAssertTrue(item.waitForExistence(timeout: 5)); item.tap()
    }
    @MainActor private func audit(_ app: XCUIApplication) throws {
        try app.performAccessibilityAudit(for: [.sufficientElementDescription, .hitRegion])
    }
    @MainActor private func capture(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let folder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("Round4Evidence")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try? screenshot.pngRepresentation.write(to: folder.appendingPathComponent(name + ".png"))
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "round4-\(name)"; attachment.lifetime = .keepAlways; add(attachment)
    }
}
