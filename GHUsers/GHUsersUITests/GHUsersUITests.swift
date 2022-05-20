import XCTest

class GHUsersUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOpenUserProfile() throws {
        let app = launchApp()

        let userListCollection = app.tables.firstMatch
        XCTContext.runActivity(named: "Wait for users list to appear") { _ in
            XCTAssertTrue(userListCollection.waitForExistence(timeout: 10))
        }

        let fistCell = userListCollection.cells.firstMatch
        XCTContext.runActivity(named: "Check first value in list") { _ in
            XCTAssertEqual(fistCell.staticTexts.firstMatch.label, "userone")
        }

        XCTContext.runActivity(named: "Open profile details") { _ in
            fistCell.tap()
            XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 1))
            XCTAssertEqual(app.navigationBars.firstMatch.staticTexts.firstMatch.label, "userone")
        }
    }

    func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("TEST_RUN_KEY")
        app.launch()
        return app
    }
}
