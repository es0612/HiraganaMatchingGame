import XCTest

final class HiraganaMatchingGameUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - レベル選択画面のテスト
    
    func testLevelSelectionScreenAppears() throws {
        // レベル選択画面が表示されることを確認
        let headerText = app.staticTexts["レベルを選んでね！"]
        XCTAssertTrue(headerText.exists, "レベル選択画面のヘッダーが表示されていません")
        
        let subtitleText = app.staticTexts["ひらがなをマスターしよう"]
        XCTAssertTrue(subtitleText.exists, "サブタイトルが表示されていません")
    }
    
    func testLevelButtonsExist() throws {
        // レベルボタンが存在することを確認
        let level1Button = app.buttons["レベル 1"]
        XCTAssertTrue(level1Button.exists, "レベル1ボタンが存在しません")
        
        // レベル1は常に利用可能であることを確認
        XCTAssertTrue(level1Button.isEnabled, "レベル1ボタンが有効になっていません")
    }
    
    func testNavigationButtons() throws {
        // ナビゲーションボタンの存在確認
        let collectionButton = app.buttons["コレクション"]
        XCTAssertTrue(collectionButton.exists, "コレクションボタンが存在しません")
        
        let achievementsButton = app.buttons["実績"]
        XCTAssertTrue(achievementsButton.exists, "実績ボタンが存在しません")
        
        let settingsButton = app.buttons["設定"]
        XCTAssertTrue(settingsButton.exists, "設定ボタンが存在しません")
    }
    
    // MARK: - ゲーム画面への遷移テスト
    
    func testNavigateToGame() throws {
        // レベル1をタップしてゲーム画面に遷移
        let level1Button = app.buttons["レベル 1"]
        level1Button.tap()
        
        // ゲーム画面の要素が表示されることを確認
        let gameTitle = app.staticTexts["レベル 1"]
        XCTAssertTrue(gameTitle.waitForExistence(timeout: 5), "ゲーム画面のタイトルが表示されません")
        
        // 戻るボタンの存在確認
        let backButton = app.buttons["戻る"]
        XCTAssertTrue(backButton.exists, "戻るボタンが存在しません")
    }
    
    func testBackToLevelSelection() throws {
        // ゲーム画面に移動して戻る
        let level1Button = app.buttons["レベル 1"]
        level1Button.tap()
        
        let backButton = app.buttons["戻る"]
        backButton.tap()
        
        // レベル選択画面に戻ることを確認
        let headerText = app.staticTexts["レベルを選んでね！"]
        XCTAssertTrue(headerText.waitForExistence(timeout: 5), "レベル選択画面に戻れませんでした")
    }
    
    // MARK: - 設定画面のテスト
    
    func testNavigateToSettings() throws {
        // 設定画面への遷移
        let settingsButton = app.buttons["設定"]
        settingsButton.tap()
        
        // 設定画面のタイトルが表示されることを確認
        let settingsTitle = app.navigationBars["設定"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5), "設定画面のタイトルが表示されません")
        
        // 完了ボタンの存在確認
        let doneButton = app.buttons["完了"]
        XCTAssertTrue(doneButton.exists, "完了ボタンが存在しません")
    }
    
    func testSettingsScreenElements() throws {
        // 設定画面に移動
        let settingsButton = app.buttons["設定"]
        settingsButton.tap()
        
        // 設定項目の存在確認
        let soundToggle = app.switches["効果音"]
        XCTAssertTrue(soundToggle.waitForExistence(timeout: 5), "効果音トグルが存在しません")
        
        let musicToggle = app.switches["BGM"]
        XCTAssertTrue(musicToggle.exists, "BGMトグルが存在しません")
        
        let volumeSlider = app.sliders.element
        XCTAssertTrue(volumeSlider.exists, "音量スライダーが存在しません")
    }
    
    func testSettingsInteraction() throws {
        // 設定画面に移動
        let settingsButton = app.buttons["設定"]
        settingsButton.tap()
        
        // 効果音トグルを操作
        let soundToggle = app.switches["効果音"]
        let initialValue = soundToggle.value as? String
        
        soundToggle.tap()
        
        let newValue = soundToggle.value as? String
        XCTAssertNotEqual(initialValue, newValue, "効果音トグルが変更されませんでした")
        
        // 完了ボタンで戻る
        let doneButton = app.buttons["完了"]
        doneButton.tap()
        
        // レベル選択画面に戻ることを確認
        let headerText = app.staticTexts["レベルを選んでね！"]
        XCTAssertTrue(headerText.waitForExistence(timeout: 5), "設定画面から戻れませんでした")
    }
    
    // MARK: - キャラクターコレクション画面のテスト
    
    func testNavigateToCharacterCollection() throws {
        // キャラクターコレクション画面への遷移
        let collectionButton = app.buttons["コレクション"]
        collectionButton.tap()
        
        // キャラクターコレクション画面のタイトルが表示されることを確認
        let collectionTitle = app.navigationBars["キャラクターコレクション"]
        XCTAssertTrue(collectionTitle.waitForExistence(timeout: 5), "キャラクターコレクション画面のタイトルが表示されません")
        
        // 戻るボタンの存在確認
        let backButton = app.buttons["戻る"]
        XCTAssertTrue(backButton.exists, "戻るボタンが存在しません")
    }
    
    // MARK: - 実績画面のテスト
    
    func testNavigateToAchievements() throws {
        // 実績画面への遷移
        let achievementsButton = app.buttons["実績"]
        achievementsButton.tap()
        
        // 実績画面のタイトルが表示されることを確認
        let achievementsTitle = app.navigationBars["実績・バッジ"]
        XCTAssertTrue(achievementsTitle.waitForExistence(timeout: 5), "実績画面のタイトルが表示されません")
        
        // 戻るボタンの存在確認
        let backButton = app.buttons["戻る"]
        XCTAssertTrue(backButton.exists, "戻るボタンが存在しません")
    }
    
    // MARK: - アクセシビリティテスト
    
    func testAccessibilityElements() throws {
        // 主要な要素にアクセシビリティラベルが設定されていることを確認
        let level1Button = app.buttons["レベル 1"]
        XCTAssertTrue(level1Button.isHittable, "レベル1ボタンがアクセシブルではありません")
        
        let settingsButton = app.buttons["設定"]
        XCTAssertTrue(settingsButton.isHittable, "設定ボタンがアクセシブルではありません")
        
        let collectionButton = app.buttons["コレクション"]
        XCTAssertTrue(collectionButton.isHittable, "コレクションボタンがアクセシブルではありません")
    }
    
    // MARK: - パフォーマンステスト
    
    func testAppLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testNavigationPerformance() throws {
        // 画面遷移のパフォーマンステスト
        measure {
            let settingsButton = app.buttons["設定"]
            settingsButton.tap()
            
            let doneButton = app.buttons["完了"]
            doneButton.tap()
            
            let headerText = app.staticTexts["レベルを選んでね！"]
            _ = headerText.waitForExistence(timeout: 5)
        }
    }
    
    // MARK: - エラーハンドリングテスト
    
    func testGameFlowWithoutData() throws {
        // データが存在しない状態でのゲームフロー
        let level1Button = app.buttons["レベル 1"]
        level1Button.tap()
        
        // ゲーム画面が正常に表示されることを確認
        let gameElements = app.otherElements["ゲーム画面"]
        XCTAssertTrue(gameElements.waitForExistence(timeout: 10), "ゲーム画面が表示されませんでした")
    }
    
    // MARK: - 回帰テスト
    
    func testCompleteUserJourney() throws {
        // 完全なユーザージャーニーのテスト
        
        // 1. レベル選択画面の確認
        let headerText = app.staticTexts["レベルを選んでね！"]
        XCTAssertTrue(headerText.exists)
        
        // 2. 設定画面への遷移と戻り
        let settingsButton = app.buttons["設定"]
        settingsButton.tap()
        
        let doneButton = app.buttons["完了"]
        doneButton.tap()
        
        XCTAssertTrue(headerText.waitForExistence(timeout: 5))
        
        // 3. キャラクターコレクション画面への遷移と戻り
        let collectionButton = app.buttons["コレクション"]
        collectionButton.tap()
        
        let backFromCollection = app.buttons["戻る"]
        backFromCollection.tap()
        
        XCTAssertTrue(headerText.waitForExistence(timeout: 5))
        
        // 4. 実績画面への遷移と戻り
        let achievementsButton = app.buttons["実績"]
        achievementsButton.tap()
        
        let backFromAchievements = app.buttons["戻る"]
        backFromAchievements.tap()
        
        XCTAssertTrue(headerText.waitForExistence(timeout: 5))
        
        // 5. ゲーム画面への遷移と戻り
        let level1Button = app.buttons["レベル 1"]
        level1Button.tap()
        
        let backFromGame = app.buttons["戻る"]
        backFromGame.tap()
        
        XCTAssertTrue(headerText.waitForExistence(timeout: 5))
    }
}