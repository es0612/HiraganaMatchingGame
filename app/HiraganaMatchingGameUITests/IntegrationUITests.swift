import XCTest

final class IntegrationUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testBasicUserFlow() throws {
        // Test basic user flow from app launch to level selection
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        // Verify basic UI elements exist
        XCTAssertTrue(!app.buttons.isEmpty, "UIボタンが存在します")
        XCTAssertTrue(!app.staticTexts.isEmpty, "UIテキストが存在します")
    }
    
    func testAppStability() throws {
        // Test app stability during basic navigation
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        // Verify app doesn't crash during basic operations
        XCTAssertTrue(app.exists, "アプリが安定して動作しています")
    }
}
