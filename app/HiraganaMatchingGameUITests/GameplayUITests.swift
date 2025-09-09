import XCTest

final class GameplayUITests: XCTestCase {
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
    
    // MARK: - Basic Game Flow Tests
    
    func testAppLaunchAndLevelSelection() throws {
        // Test app launch and level selection screen
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        // Verify that level buttons exist
        let levelButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS '1'"))
        XCTAssertGreaterThan(levelButtons.count, 0, "レベルボタンが見つかりません")
    }
    
    func testBasicGameNavigation() throws {
        // Test basic navigation between screens
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        // Try to find and tap level 1 button
        let levelButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS '1'"))
        if !levelButtons.isEmpty {
            let firstLevelButton = levelButtons.firstMatch
            if firstLevelButton.exists && firstLevelButton.isEnabled {
                firstLevelButton.tap()
                
                // Verify game screen loads
                XCTAssertTrue(app.staticTexts.element.waitForExistence(timeout: 5))
                
                // Try to go back
                let backButton = app.buttons["戻る"]
                if backButton.exists {
                    backButton.tap()
                    
                    // Verify we're back at level selection
                    XCTAssertTrue(app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 5))
                }
            }
        }
    }
    
    func testSettingsAccess() throws {
        // Test settings button access
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        // Check if settings button exists
        let settingsButton = app.buttons["設定"]
        if settingsButton.exists {
            XCTAssertTrue(settingsButton.isEnabled, "設定ボタンが無効です")
        }
    }
    
    // MARK: - Basic Performance Test
    
    func testAppResponsiveness() throws {
        // Simple performance test
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        measure {
            // Measure basic app responsiveness
            XCTAssertTrue(!app.buttons.isEmpty, "アプリが応答しています")
        }
    }
    
    // MARK: - Basic Accessibility Test
    
    func testBasicAccessibility() throws {
        // Basic accessibility test
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        // Check that some accessible elements exist
        let accessibleElements = app.descendants(matching: .any).allElementsBoundByAccessibilityElement
        XCTAssertGreaterThan(accessibleElements.count, 0, "アクセシブルな要素が見つかりません")
    }
}
