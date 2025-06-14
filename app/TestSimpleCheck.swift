import Foundation
@testable import HiraganaMatchingGame

// 基本的なクラス初期化テスト
func testBasicInitialization() {
    print("=== 基本初期化テスト開始 ===")
    
    // UserSettings初期化テスト
    do {
        let userSettings = UserSettings()
        print("✓ UserSettings初期化成功")
        print("  soundEnabled: \(userSettings.soundEnabled)")
        print("  soundVolume: \(userSettings.soundVolume)")
    } catch {
        print("✗ UserSettings初期化失敗: \(error)")
    }
    
    // LevelProgressionService初期化テスト
    do {
        let levelService = LevelProgressionService()
        print("✓ LevelProgressionService初期化成功")
        print("  totalLevels: \(levelService.totalLevels)")
        print("  currentLevel: \(levelService.getCurrentLevel())")
    } catch {
        print("✗ LevelProgressionService初期化失敗: \(error)")
    }
    
    // StarUnlockService初期化テスト
    do {
        let starService = StarUnlockService()
        print("✓ StarUnlockService初期化成功")
        print("  unlockedCharacters: \(starService.getUnlockedCharacters().count)")
    } catch {
        print("✗ StarUnlockService初期化失敗: \(error)")
    }
    
    // AudioService初期化テスト
    do {
        let audioService = AudioService()
        print("✓ AudioService初期化成功")
        print("  isSoundEnabled: \(audioService.isSoundEnabled)")
    } catch {
        print("✗ AudioService初期化失敗: \(error)")
    }
    
    print("=== 基本初期化テスト完了 ===")
}

// メイン実行
testBasicInitialization()