//
//  QuickTestRunner.swift
//  HiraganaMatchingGame
//
//

import Foundation

/// 簡易テストランナー - 基本的なテストを実行
struct QuickTestRunner {
    
    static func runBasicTests() {
        print("=== Running Basic Tests ===")
        
        var passedTests = 0
        var totalTests = 0
        
        // Test 1: TestUtils動作確認
        totalTests += 1
        if testTestUtils() {
            print("✅ TestUtils test passed")
            passedTests += 1
        } else {
            print("❌ TestUtils test failed")
        }
        
        // Test 2: GameLogicService基本テスト
        totalTests += 1
        if testGameLogicServiceBasics() {
            print("✅ GameLogicService basic test passed")
            passedTests += 1
        } else {
            print("❌ GameLogicService basic test failed")
        }
        
        // Test 3: AudioService基本テスト（テストモード）
        totalTests += 1
        if testAudioServiceTestMode() {
            print("✅ AudioService test mode passed")
            passedTests += 1
        } else {
            print("❌ AudioService test mode failed")
        }
        
        // Test 4: GameViewModel基本テスト
        totalTests += 1
        if testGameViewModelBasics() {
            print("✅ GameViewModel basic test passed")
            passedTests += 1
        } else {
            print("❌ GameViewModel basic test failed")
        }
        
        // 結果表示
        print("\n=== Test Results ===")
        print("Passed: \(passedTests)/\(totalTests)")
        if passedTests == totalTests {
            print("🎉 All basic tests passed!")
        } else {
            print("⚠️  Some tests failed")
        }
    }
    
    private static func testTestUtils() -> Bool {
        // TestUtils.isTestEnvironmentの動作確認
        let originalTestState = TestUtils.isTestEnvironment
        print("Test environment detected: \(originalTestState)")
        return true // TestUtilsは正常にコンパイルされていれば成功
    }
    
    private static func testGameLogicServiceBasics() -> Bool {
        let gameLogic = GameLogicService()
        
        // 正解判定テスト
        let correctResult = gameLogic.isCorrectAnswer(hiragana: "あ", imageName: "ant")
        if !correctResult {
            print("   Failed: 'あ' should match 'ant'")
            return false
        }
        
        let incorrectResult = gameLogic.isCorrectAnswer(hiragana: "あ", imageName: "bear")
        if incorrectResult {
            print("   Failed: 'あ' should not match 'bear'")
            return false
        }
        
        // スター計算テスト
        let stars = gameLogic.calculateStars(correctAnswers: 5, totalQuestions: 5)
        if stars != 3 {
            print("   Failed: Perfect score should give 3 stars, got \(stars)")
            return false
        }
        
        return true
    }
    
    private static func testAudioServiceTestMode() -> Bool {
        let audioService = AudioService.createForTesting()
        
        // テストモードでオーディオファイルチェック
        let hasAudio = audioService.hasAudioFile(for: "あ")
        if !hasAudio {
            print("   Failed: Test mode should always return true for hasAudioFile")
            return false
        }
        
        // テストモードでサウンド再生（即座に完了するはず）
        audioService.playCorrectSound()
        audioService.playIncorrectSound()
        
        return true
    }
    
    private static func testGameViewModelBasics() -> Bool {
        let viewModel = GameViewModel(isTestMode: true)
        
        // 初期状態チェック
        if viewModel.currentLevel != 1 {
            print("   Failed: Initial level should be 1, got \(viewModel.currentLevel)")
            return false
        }
        
        if viewModel.score != 0 {
            print("   Failed: Initial score should be 0, got \(viewModel.score)")
            return false
        }
        
        if viewModel.isGameCompleted {
            print("   Failed: Game should not be completed initially")
            return false
        }
        
        // レベル1開始
        viewModel.startNewGame(level: 1)
        
        if viewModel.currentLevel != 1 {
            print("   Failed: Level should be 1 after starting level 1")
            return false
        }
        
        if viewModel.currentQuestion != 1 {
            print("   Failed: Should start at question 1")
            return false
        }
        
        return true
    }
}