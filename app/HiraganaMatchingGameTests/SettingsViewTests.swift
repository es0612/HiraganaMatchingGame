import Testing
import SwiftData
@testable import HiraganaMatchingGame

@Suite("設定画面テスト")
struct SettingsViewTests {
    
    @Test("設定項目の初期値確認")
    func initialSettingsValues() {
        let settings = TestableUserSettings()
        
        // 音声設定の初期値
        #expect(settings.soundEnabled == true)
        #expect(settings.soundVolume == 0.8)
        
        // ゲーム設定の初期値
        #expect(settings.gameSpeed == .normal)
        #expect(settings.difficulty == .normal)
        #expect(settings.autoAdvance == false)
        
        // 表示設定の初期値
        #expect(settings.showHints == true)
        #expect(settings.largeText == false)
        #expect(settings.reduceAnimations == false)
    }
    
    @Test("音声設定の更新")
    func soundSettingsUpdate() {
        let settings = TestableUserSettings()
        
        // 音声無効化
        settings.toggleSound()
        #expect(settings.soundEnabled == false)
        
        // 音量調整
        settings.setSoundVolume(0.5)
        #expect(settings.soundVolume == 0.5)
        
        // 無効値のクランプ確認
        settings.setSoundVolume(1.5)
        #expect(settings.soundVolume == 1.0)
        
        settings.setSoundVolume(-0.1)
        #expect(settings.soundVolume == 0.0)
    }
    
    @Test("ゲーム設定の更新")
    func gameSettingsUpdate() {
        let settings = TestableUserSettings()
        
        // ゲーム速度変更
        settings.setGameSpeed(.slow)
        #expect(settings.gameSpeed == .slow)
        
        settings.setGameSpeed(.fast)
        #expect(settings.gameSpeed == .fast)
        
        // 難易度変更
        settings.setDifficulty(.easy)
        #expect(settings.difficulty == .easy)
        
        settings.setDifficulty(.hard)
        #expect(settings.difficulty == .hard)
        
        // 自動進行設定
        settings.setAutoAdvance(true)
        #expect(settings.autoAdvance == true)
    }
    
    @Test("アクセシビリティ設定の更新")
    func accessibilitySettingsUpdate() {
        let settings = TestableUserSettings()
        
        // ヒント表示設定
        settings.setShowHints(false)
        #expect(settings.showHints == false)
        
        // 大きな文字設定
        settings.setLargeText(true)
        #expect(settings.largeText == true)
        
        // アニメーション軽減設定
        settings.setReduceAnimations(true)
        #expect(settings.reduceAnimations == true)
    }
    
    @Test("設定のリセット")
    func settingsReset() {
        let settings = TestableUserSettings()
        
        // 設定を変更
        settings.soundEnabled = false
        settings.soundVolume = 0.3
        settings.gameSpeed = .fast
        settings.difficulty = .hard
        settings.showHints = false
        settings.largeText = true
        
        // リセット実行
        settings.resetToDefaults()
        
        // デフォルト値に戻ることを確認
        #expect(settings.soundEnabled == true)
        #expect(settings.soundVolume == 0.8)
        #expect(settings.gameSpeed == .normal)
        #expect(settings.difficulty == .normal)
        #expect(settings.showHints == true)
        #expect(settings.largeText == false)
    }
    
    @Test("設定の永続化")
    func settingsPersistence() {
        let settings = TestableUserSettings()
        
        // 設定を変更
        settings.setSoundVolume(0.6)
        settings.setGameSpeed(.slow)
        settings.setDifficulty(.easy)
        
        // 設定の保存
        settings.save()
        
        // 新しいインスタンスで設定を読み込み
        let newSettings = TestableUserSettings()
        newSettings.load()
        
        // 保存された設定が復元されることを確認
        #expect(newSettings.soundVolume == 0.6)
        #expect(newSettings.gameSpeed == .slow)
        #expect(newSettings.difficulty == .easy)
    }
    
    @Test("設定変更通知")
    func settingsChangeNotification() {
        let settings = TestableUserSettings()
        var notificationReceived = false
        var changedSetting = ""
        
        // 通知受信の設定
        settings.onSettingChanged = { settingName in
            notificationReceived = true
            changedSetting = settingName
        }
        
        // 設定変更
        settings.toggleSound()
        
        // 通知の確認
        #expect(notificationReceived == true)
        #expect(changedSetting == "soundEnabled")
    }
    
    @Test("設定の検証とエラーハンドリング")
    func settingsValidationAndErrorHandling() {
        let settings = TestableUserSettings()
        
        // 音量の範囲外値テスト
        settings.setSoundVolume(2.0)
        #expect(settings.soundVolume == 1.0) // 最大値にクランプ
        
        settings.setSoundVolume(-1.0)
        #expect(settings.soundVolume == 0.0) // 最小値にクランプ
        
        // 不正な設定値の処理
        let result = settings.validateSettings()
        #expect(result == true) // 全設定が有効であること
    }
}