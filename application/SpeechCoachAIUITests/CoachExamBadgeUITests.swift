import XCTest

final class CoachExamBadgeUITests: XCTestCase {
    @MainActor
    func testCoachFaceBadgeOpensWithItsEightyPercentRule() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["SC_SPEAKING_FIXTURE"] = UUID().uuidString
        app.launch()
        let badges = app.buttons["rewards.open"]
        XCTAssertTrue(badges.waitForExistence(timeout: 10))
        for _ in 0..<6 where !badges.isHittable { app.swipeUp() }
        XCTAssertTrue(badges.isHittable)
        badges.tap()

        let coach = app.buttons["rewards.family.AW-TK-07"]
        for _ in 0..<16 {
            if coach.exists && coach.isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(coach.isHittable)
        coach.tap()
        XCTAssertTrue(app.staticTexts["Grammarian · 80%"].waitForExistence(timeout: 5))
        let rule = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "at least 80% on each lesson")).firstMatch
        XCTAssertTrue(rule.exists)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "coach-exam-face-badge"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
