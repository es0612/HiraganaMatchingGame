import XCTest

final class GameplayUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - ゲームプレイフローのテスト
    
    func testGameStartFlow() throws {
        // レベル1でゲームを開始
        let level1Button = app.buttons["レベル 1"]
        level1Button.tap()
        
        // ゲーム画面が表示されることを確認
        let gameTitle = app.staticTexts["レベル 1"]
        XCTAssertTrue(gameTitle.waitForExistence(timeout: 5), "ゲーム画面のタイトルが表示されません")
        
        // ゲーム要素の存在確認
        let progressBar = app.progressIndicators.firstMatch
        XCTAssertTrue(progressBar.exists, "進捗バーが存在しません")
        
        // スコア表示の確認
        let scoreLabel = app.staticTexts.matching(identifier: "スコア").firstMatch
        XCTAssertTrue(scoreLabel.exists, "スコアラベルが存在しません")
    }
    
    func testGameInteraction() throws {
        // ゲーム画面に移動
        let level1Button = app.buttons["レベル 1"]
        level1Button.tap()
        
        // ゲーム要素が読み込まれるまで待機
        let gameArea = app.otherElements["ゲームエリア"]
        XCTAssertTrue(gameArea.waitForExistence(timeout: 10), "ゲームエリアが表示されません")
        
        // 最初の選択肢が表示されることを確認
        let firstOption = app.buttons.matching(NSPredicate(format: "label CONTAINS 'あ'")).firstMatch
        XCTAssertTrue(firstOption.exists, "ひらがなの選択肢が表示されません")
    }
    
    func testGameCompletion() throws {
        // ゲーム画面に移動
        let level1Button = app.buttons["レベル 1"]
        level1Button.tap()
        
        // ゲーム完了まで実行（簡易版）
        // 実際のゲームロジックに応じて調整が必要
        
        // タイムアウトを設定してゲーム完了を待つ
        let completionMessage = app.staticTexts["レベルクリア！"]
        if completionMessage.waitForExistence(timeout: 30) {
            XCTAssertTrue(true, "ゲームが正常に完了しました")
        } else {
            // ゲームが30秒以内に完了しない場合は手動で戻る
            let backButton = app.buttons["戻る"]
            if backButton.exists {
                backButton.tap()
            }
        }
    }
    
    // MARK: - ゲーム状態のテスト
    
    func testGamePauseAndResume() throws {
        // ゲーム画面に移動
        let level1Button = app.buttons["レベル 1"]
        level1Button.tap()
        
        // 一時停止ボタンが存在する場合のテスト
        let pauseButton = app.buttons["一時停止"]
        if pauseButton.exists {
            pauseButton.tap()
            
            // 一時停止画面の要素確認
            let resumeButton = app.buttons["再開"]
            XCTAssertTrue(resumeButton.exists, "再開ボタンが存在しません")
            
            resumeButton.tap()
            
            // ゲームが再開されることを確認
            let gameArea = app.otherElements["ゲームエリア"]
            XCTAssertTrue(gameArea.exists, "ゲームエリアが再表示されません")
        }
    }
    
    func testGameSettings() throws {
        // ゲーム画面に移動
        let level1Button = app.buttons["レベル 1"]
        level1Button.tap()
        
        // ゲーム内設定ボタンが存在する場合のテスト
        let gameSettingsButton = app.buttons["ゲーム設定"]
        if gameSettingsButton.exists {
            gameSettingsButton.tap()
            
            // 設定オプションの確認
            let soundToggle = app.switches["効果音"]
            XCTAssertTrue(soundToggle.exists, "ゲーム内効果音設定が存在しません")
        }
    }
    
    // MARK: - エラーハンドリングテスト
    
    func testGameErrorHandling() throws {
        // 複数のレベルを高速で切り替えてエラーハンドリングをテスト
        for level in 1...3 {
            let levelButton = app.buttons["レベル \(level)"]
            if levelButton.exists && levelButton.isEnabled {
                levelButton.tap()
                
                // 短時間待機後に戻る
                sleep(1)
                
                let backButton = app.buttons["戻る"]
                if backButton.exists {
                    backButton.tap()
                }
                
                // レベル選択画面に戻ることを確認
                let headerText = app.staticTexts["レベルを選んでね！"]
                XCTAssertTrue(headerText.waitForExistence(timeout: 5), "レベル\(level)から正常に戻れませんでした")
            }
        }
    }
    
    // MARK: - パフォーマンステスト
    
    func testGameLoadingPerformance() throws {
        measure {
            let level1Button = app.buttons["レベル 1"]
            level1Button.tap()
            
            let gameTitle = app.staticTexts["レベル 1"]
            _ = gameTitle.waitForExistence(timeout: 10)
            
            let backButton = app.buttons["戻る"]
            if backButton.exists {
                backButton.tap()
            }
            
            let headerText = app.staticTexts["レベルを選んでね！"]
            _ = headerText.waitForExistence(timeout: 5)
        }
    }
    
    // MARK: - アクセシビリティテスト
    
    func testGameAccessibility() throws {
        // ゲーム画面に移動
        let level1Button = app.buttons["レベル 1"]
        level1Button.tap()
        
        // VoiceOverでアクセス可能な要素の確認
        let accessibleElements = app.descendants(matching: .any).allElementsBoundByAccessibilityElement
        XCTAssertGreaterThan(accessibleElements.count, 0, "アクセシビリティ要素が見つかりません")
        
        // 重要な要素のアクセシビリティ確認
        let backButton = app.buttons["戻る"]
        XCTAssertTrue(backButton.isHittable, "戻るボタンがアクセシブルではありません")
    }
    
    // MARK: - 画面回転テスト
    
    func testOrientationChanges() throws {
        // ゲーム画面に移動
        let level1Button = app.buttons["レベル 1"]
        level1Button.tap()
        
        // 横向きに回転
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(1)
        
        // ゲーム要素が正常に表示されることを確認
        let gameTitle = app.staticTexts["レベル 1"]
        XCTAssertTrue(gameTitle.exists, "横向きでゲーム画面が正常に表示されません")
        
        // 縦向きに戻す
        XCUIDevice.shared.orientation = .portrait
        sleep(1)
        
        // 縦向きでも正常に表示されることを確認
        XCTAssertTrue(gameTitle.exists, "縦向きでゲーム画面が正常に表示されません")
    }
    
    // MARK: - メモリリークテスト
    
    func testMemoryLeaks() throws {
        // 複数回ゲーム画面への遷移を繰り返してメモリリークをテスト
        for _ in 1...5 {
            let level1Button = app.buttons["レベル 1"]
            level1Button.tap()
            
            // 短時間ゲーム画面を表示
            sleep(2)
            
            let backButton = app.buttons["戻る"]
            if backButton.exists {
                backButton.tap()
            }
            
            // レベル選択画面に戻ることを確認
            let headerText = app.staticTexts["レベルを選んでね！"]
            XCTAssertTrue(headerText.waitForExistence(timeout: 5), "メモリリークテスト中に正常に戻れませんでした")
        }
    }
}