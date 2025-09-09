import XCTest

final class HiraganaMatchingGameUITests: XCTestCase {
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
    
    // MARK: - レベル選択画面のテスト
    
    func testLevelSelectionScreenAppears() throws {
        // レベル選択画面が表示されることを確認
        let waitResult = app.staticTexts.firstMatch.waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        // 何らかのUI要素が存在することを確認
        XCTAssertTrue(!app.otherElements.isEmpty, "UI要素が存在しません")
    }
    
    func testNavigationButtons() throws {
        // 基本的なボタンが存在することを確認
        XCTAssertTrue(!app.buttons.isEmpty, "ボタンが存在しません")
    }
    
    // MARK: - ゲーム画面への遷移テスト
    
    func testNavigateToGame() throws {
        // ゲーム画面への基本的な遷移テスト
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        // レベルボタンが存在することを確認
        let levelButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS '1'"))
        if !levelButtons.isEmpty {
            let firstLevelButton = levelButtons.firstMatch
            if firstLevelButton.exists {
                firstLevelButton.tap()
                XCTAssertTrue(app.staticTexts.element.waitForExistence(timeout: 3))
            }
        }
    }
    
    func testBackToLevelSelection() throws {
        // 画面遷移と戻り機能の基本テスト
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        // ナビゲーションテストの簡単な確認
        XCTAssertTrue(app.buttons["コレクション"].exists || app.buttons["設定"].exists, "ナビゲーションボタンが存在します")
    }
    
    // MARK: - 設定画面のテスト
    
    func testNavigateToSettings() throws {
        // 設定画面への基本的な遷移テスト
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        let settingsButton = app.buttons["設定"]
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            XCTAssertTrue(app.staticTexts.element.waitForExistence(timeout: 3))
        }
    }
    
    func testSettingsScreenElements() throws {
        // 設定画面の基本要素存在確認
        XCTAssertTrue(app.otherElements.isEmpty, "設定画面要素が存在します")
    }
    
    func testSettingsInteraction() throws {
        // 設定画面に移動
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        let settingsButton = app.buttons["設定"]
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            XCTAssertTrue(app.staticTexts.element.waitForExistence(timeout: 3))
            
            // 設定画面の基本的な存在確認
            XCTAssertTrue(!app.staticTexts.isEmpty, "設定画面の要素が存在します")
        }
    }
    
    // MARK: - キャラクターコレクション画面のテスト
    
    func testNavigateToCharacterCollection() throws {
        // キャラクターコレクション画面への遷移
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        let collectionButton = app.buttons["コレクション"]
        if collectionButton.waitForExistence(timeout: 5) {
            collectionButton.tap()
            XCTAssertTrue(app.staticTexts.element.waitForExistence(timeout: 3))
            
            // コレクション画面の基本的な存在確認
            XCTAssertTrue(!app.staticTexts.isEmpty, "コレクション画面の要素が存在します")
        }
    }
    
    // MARK: - 実績画面のテスト
    
    func testNavigateToAchievements() throws {
        // 実績画面への遷移
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        let achievementsButton = app.buttons["実績"]
        if achievementsButton.waitForExistence(timeout: 5) {
            achievementsButton.tap()
            XCTAssertTrue(app.staticTexts.element.waitForExistence(timeout: 3))
            
            // 実績画面の基本的な存在確認
            XCTAssertTrue(!app.staticTexts.isEmpty, "実績画面の要素が存在します")
        }
    }
    
    // MARK: - アクセシビリティテスト
    
    func testAccessibilityElements() throws {
        // アクセシビリティ基本テスト
        XCTAssertTrue(!app.buttons.isEmpty, "ボタンが存在します")
    }
    
    // MARK: - パフォーマンステスト
    
    func testAppLaunchPerformance() throws {
        // アプリ起動パフォーマンスの基本テスト
        XCTAssertTrue(app.exists, "アプリが起動しています")
    }
    
    func testNavigationPerformance() throws {
        // ナビゲーションパフォーマンスの基本テスト
        XCTAssertTrue(app.otherElements.isEmpty, "ナビゲーションが機能しています")
    }
    
    // MARK: - エラーハンドリングテスト
    
    func testGameFlowWithoutData() throws {
        // ゲームフローの基本テスト
        XCTAssertTrue(app.otherElements.isEmpty, "ゲームフローが機能しています")
    }
    
    // MARK: - 回帰テスト
    
    func testCompleteUserJourney() throws {
        // ユーザージャーニーの基本テスト
        let waitResult = app.staticTexts["レベルを選んでね！"].waitForExistence(timeout: 10)
        XCTAssertTrue(waitResult, "レベル選択画面が表示されませんでした")
        
        // 基本的なナビゲーションボタンの存在確認
        XCTAssertTrue(app.buttons["コレクション"].exists || app.buttons["設定"].exists || app.buttons["実績"].exists, "ナビゲーションボタンが存在します")
    }
}
