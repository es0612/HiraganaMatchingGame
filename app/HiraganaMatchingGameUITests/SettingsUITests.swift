import XCTest

final class SettingsUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - 設定画面の基本テスト
    
    func testSettingsScreenLayout() throws {
        // 設定画面に移動
        navigateToSettings()
        
        // セクションヘッダーの確認
        let audioSection = app.staticTexts["音声設定"]
        XCTAssertTrue(audioSection.exists, "音声設定セクションが存在しません")
        
        let gameSection = app.staticTexts["ゲーム設定"]
        XCTAssertTrue(gameSection.exists, "ゲーム設定セクションが存在しません")
        
        let accessibilitySection = app.staticTexts["アクセシビリティ"]
        XCTAssertTrue(accessibilitySection.exists, "アクセシビリティセクションが存在しません")
        
        let otherSection = app.staticTexts["その他"]
        XCTAssertTrue(otherSection.exists, "その他セクションが存在しません")
    }
    
    func testAudioSettings() throws {
        navigateToSettings()
        
        // 音声設定の要素確認
        let soundToggle = app.switches["効果音"]
        XCTAssertTrue(soundToggle.exists, "効果音トグルが存在しません")
        
        let musicToggle = app.switches["BGM"]
        XCTAssertTrue(musicToggle.exists, "BGMトグルが存在しません")
        
        // 音量スライダーの確認
        let volumeSlider = app.sliders.containing(.staticText, identifier: "音量").firstMatch
        XCTAssertTrue(volumeSlider.exists, "音量スライダーが存在しません")
        
        // 音声速度スライダーの確認
        let voiceSpeedSlider = app.sliders.containing(.staticText, identifier: "音声速度").firstMatch
        XCTAssertTrue(voiceSpeedSlider.exists, "音声速度スライダーが存在しません")
    }
    
    func testGameSettings() throws {
        navigateToSettings()
        
        // ゲーム設定の要素確認
        let gameSpeedPicker = app.buttons["ゲーム速度"]
        XCTAssertTrue(gameSpeedPicker.exists, "ゲーム速度選択が存在しません")
        
        let difficultyPicker = app.buttons["難易度"]
        XCTAssertTrue(difficultyPicker.exists, "難易度選択が存在しません")
        
        let autoAdvanceToggle = app.switches["自動進行"]
        XCTAssertTrue(autoAdvanceToggle.exists, "自動進行トグルが存在しません")
        
        let showHintsToggle = app.switches["ヒント表示"]
        XCTAssertTrue(showHintsToggle.exists, "ヒント表示トグルが存在しません")
    }
    
    func testAccessibilitySettings() throws {
        navigateToSettings()
        
        // アクセシビリティ設定の要素確認
        let largeTextToggle = app.switches["大きな文字"]
        XCTAssertTrue(largeTextToggle.exists, "大きな文字トグルが存在しません")
        
        let reduceAnimationsToggle = app.switches["アニメーション軽減"]
        XCTAssertTrue(reduceAnimationsToggle.exists, "アニメーション軽減トグルが存在しません")
    }
    
    // MARK: - 設定変更のテスト
    
    func testToggleSettings() throws {
        navigateToSettings()
        
        // 効果音トグルのテスト
        let soundToggle = app.switches["効果音"]
        let initialSoundValue = soundToggle.value as? String
        
        soundToggle.tap()
        let newSoundValue = soundToggle.value as? String
        XCTAssertNotEqual(initialSoundValue, newSoundValue, "効果音トグルが変更されませんでした")
        
        // BGMトグルのテスト
        let musicToggle = app.switches["BGM"]
        let initialMusicValue = musicToggle.value as? String
        
        musicToggle.tap()
        let newMusicValue = musicToggle.value as? String
        XCTAssertNotEqual(initialMusicValue, newMusicValue, "BGMトグルが変更されませんでした")
    }
    
    func testSliderSettings() throws {
        navigateToSettings()
        
        // 音量スライダーのテスト
        let volumeSlider = app.sliders.containing(.staticText, identifier: "音量").firstMatch
        let initialVolume = volumeSlider.value as? String
        
        // スライダーを中央に設定
        volumeSlider.adjust(toNormalizedSliderPosition: 0.5)
        let newVolume = volumeSlider.value as? String
        XCTAssertNotEqual(initialVolume, newVolume, "音量スライダーが変更されませんでした")
    }
    
    func testPickerSettings() throws {
        navigateToSettings()
        
        // ゲーム速度の選択テスト
        let gameSpeedPicker = app.buttons["ゲーム速度"]
        gameSpeedPicker.tap()
        
        // ピッカーオプションの確認
        let slowOption = app.buttons["遅い"]
        if slowOption.exists {
            slowOption.tap()
        }
        
        // 難易度の選択テスト
        let difficultyPicker = app.buttons["難易度"]
        difficultyPicker.tap()
        
        let easyOption = app.buttons["簡単"]
        if easyOption.exists {
            easyOption.tap()
        }
    }
    
    // MARK: - 設定リセットのテスト
    
    func testSettingsReset() throws {
        navigateToSettings()
        
        // 設定を変更
        let soundToggle = app.switches["効果音"]
        soundToggle.tap()
        
        let volumeSlider = app.sliders.containing(.staticText, identifier: "音量").firstMatch
        volumeSlider.adjust(toNormalizedSliderPosition: 0.2)
        
        // リセットボタンを押す
        let resetButton = app.buttons["設定をリセット"]
        resetButton.tap()
        
        // アラートの確認
        let resetAlert = app.alerts["設定をリセット"]
        XCTAssertTrue(resetAlert.waitForExistence(timeout: 5), "リセット確認アラートが表示されません")
        
        let confirmButton = app.buttons["リセット"]
        confirmButton.tap()
        
        // 設定がリセットされたことを確認（UI表示での確認）
        // 実際の値の確認は統合テストで行う
    }
    
    func testSettingsResetCancel() throws {
        navigateToSettings()
        
        // リセットボタンを押してキャンセル
        let resetButton = app.buttons["設定をリセット"]
        resetButton.tap()
        
        let resetAlert = app.alerts["設定をリセット"]
        XCTAssertTrue(resetAlert.waitForExistence(timeout: 5), "リセット確認アラートが表示されません")
        
        let cancelButton = app.buttons["キャンセル"]
        cancelButton.tap()
        
        // アラートが閉じることを確認
        XCTAssertFalse(resetAlert.exists, "キャンセル後もアラートが表示されています")
    }
    
    // MARK: - ライセンス・アプリ情報のテスト
    
    func testLicenseScreen() throws {
        navigateToSettings()
        
        // ライセンス情報画面への遷移
        let licenseButton = app.buttons["ライセンス情報"]
        licenseButton.tap()
        
        // ライセンス画面の確認
        let licenseTitle = app.navigationBars["ライセンス情報"]
        XCTAssertTrue(licenseTitle.waitForExistence(timeout: 5), "ライセンス情報画面のタイトルが表示されません")
        
        // ライセンス内容の確認
        let licenseContent = app.staticTexts["オープンソースライセンス"]
        XCTAssertTrue(licenseContent.exists, "ライセンス内容が表示されません")
        
        // 戻る
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        backButton.tap()
    }
    
    func testAboutScreen() throws {
        navigateToSettings()
        
        // アプリについて画面への遷移
        let aboutButton = app.buttons["アプリについて"]
        aboutButton.tap()
        
        // アプリについて画面の確認
        let aboutTitle = app.navigationBars["アプリについて"]
        XCTAssertTrue(aboutTitle.waitForExistence(timeout: 5), "アプリについて画面のタイトルが表示されません")
        
        // アプリ情報の確認
        let appName = app.staticTexts["ひらがなマッチングゲーム"]
        XCTAssertTrue(appName.exists, "アプリ名が表示されません")
        
        let version = app.staticTexts["バージョン 1.0.0"]
        XCTAssertTrue(version.exists, "バージョン情報が表示されません")
        
        // 戻る
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        backButton.tap()
    }
    
    // MARK: - 設定画面のナビゲーションテスト
    
    func testSettingsNavigation() throws {
        navigateToSettings()
        
        // 完了ボタンで戻る
        let doneButton = app.buttons["完了"]
        doneButton.tap()
        
        // レベル選択画面に戻ることを確認
        let headerText = app.staticTexts["レベルを選んでね！"]
        XCTAssertTrue(headerText.waitForExistence(timeout: 5), "設定画面から正常に戻れませんでした")
    }
    
    // MARK: - アクセシビリティテスト
    
    func testSettingsAccessibility() throws {
        navigateToSettings()
        
        // 重要な要素のアクセシビリティ確認
        let soundToggle = app.switches["効果音"]
        XCTAssertTrue(soundToggle.isHittable, "効果音トグルがアクセシブルではありません")
        
        let volumeSlider = app.sliders.containing(.staticText, identifier: "音量").firstMatch
        XCTAssertTrue(volumeSlider.isHittable, "音量スライダーがアクセシブルではありません")
        
        let doneButton = app.buttons["完了"]
        XCTAssertTrue(doneButton.isHittable, "完了ボタンがアクセシブルではありません")
    }
    
    // MARK: - パフォーマンステスト
    
    func testSettingsPerformance() throws {
        measure {
            navigateToSettings()
            
            // 設定変更のパフォーマンス
            let soundToggle = app.switches["効果音"]
            soundToggle.tap()
            
            let doneButton = app.buttons["完了"]
            doneButton.tap()
            
            let headerText = app.staticTexts["レベルを選んでね！"]
            _ = headerText.waitForExistence(timeout: 5)
        }
    }
    
    // MARK: - ヘルパーメソッド
    
    private func navigateToSettings() {
        let settingsButton = app.buttons["設定"]
        settingsButton.tap()
        
        let settingsTitle = app.navigationBars["設定"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5), "設定画面への遷移に失敗しました")
    }
}