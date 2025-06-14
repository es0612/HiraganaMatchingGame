import Foundation
import SwiftData

@Observable
class SettingsViewModel {
    private var userSettings: UserSettings
    private let modelContext: ModelContext?
    
    // 設定項目へのバインディング
    var soundEnabled: Bool {
        get { userSettings.soundEnabled }
        set { 
            userSettings.soundEnabled = newValue
            saveSettings()
        }
    }
    
    var musicEnabled: Bool {
        get { userSettings.musicEnabled }
        set { 
            userSettings.musicEnabled = newValue
            saveSettings()
        }
    }
    
    var soundVolume: Double {
        get { userSettings.soundVolume }
        set { 
            userSettings.setSoundVolume(newValue)
            saveSettings()
        }
    }
    
    var gameSpeed: GameSpeed {
        get { userSettings.gameSpeed }
        set { 
            userSettings.setGameSpeed(newValue)
            saveSettings()
        }
    }
    
    var difficulty: GameDifficulty {
        get { userSettings.difficulty }
        set { 
            userSettings.setDifficulty(newValue)
            saveSettings()
        }
    }
    
    var autoAdvance: Bool {
        get { userSettings.autoAdvance }
        set { 
            userSettings.setAutoAdvance(newValue)
            saveSettings()
        }
    }
    
    var showHints: Bool {
        get { userSettings.showHints }
        set { 
            userSettings.setShowHints(newValue)
            saveSettings()
        }
    }
    
    var largeText: Bool {
        get { userSettings.largeText }
        set { 
            userSettings.setLargeText(newValue)
            saveSettings()
        }
    }
    
    var reduceAnimations: Bool {
        get { userSettings.reduceAnimations }
        set { 
            userSettings.setReduceAnimations(newValue)
            saveSettings()
        }
    }
    
    var voiceSpeed: Double {
        get { userSettings.voiceSpeed }
        set { 
            userSettings.setVoiceSpeed(newValue)
            saveSettings()
        }
    }
    
    var playtimeLimit: Int {
        get { userSettings.playtimeLimit }
        set { 
            userSettings.playtimeLimit = newValue
            saveSettings()
        }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // 既存の設定を検索
        let descriptor = FetchDescriptor<UserSettings>()
        let existingSettings = try? modelContext.fetch(descriptor)
        
        if let settings = existingSettings?.first {
            self.userSettings = settings
        } else {
            // 新しい設定を作成
            self.userSettings = UserSettings()
            modelContext.insert(self.userSettings)
            saveSettings()
        }
        
        // UserDefaultsから設定を読み込み
        self.userSettings.load()
    }
    
    // 便利な初期化（テスト用）
    init(userSettings: UserSettings = UserSettings()) {
        self.userSettings = userSettings
        self.modelContext = nil
    }
    
    func resetToDefaults() {
        userSettings.resetToDefaults()
        saveSettings()
    }
    
    func saveSettings() {
        userSettings.save()
        
        if let context = modelContext {
            do {
                try context.save()
            } catch {
                print("設定の保存に失敗しました: \(error)")
            }
        }
    }
    
    func loadSettings() {
        userSettings.load()
    }
    
    // 設定のバリデーション
    func validateAllSettings() -> Bool {
        return userSettings.validateSettings()
    }
    
    // 音量のフォーマット（パーセンテージ表示用）
    func formattedSoundVolume() -> String {
        return "\(Int(soundVolume * 100))%"
    }
    
    // 制限時間のフォーマット
    func formattedPlaytimeLimit() -> String {
        if playtimeLimit == 0 {
            return "制限なし"
        } else {
            return "\(playtimeLimit)分"
        }
    }
    
    // 音声速度のフォーマット
    func formattedVoiceSpeed() -> String {
        return String(format: "%.1fx", voiceSpeed)
    }
    
    // デバッグ用の設定情報表示
    func debugDescription() -> String {
        return """
        設定情報:
        - 音声: \(soundEnabled ? "有効" : "無効")
        - 音楽: \(musicEnabled ? "有効" : "無効")
        - 音量: \(formattedSoundVolume())
        - ゲーム速度: \(gameSpeed.rawValue)
        - 難易度: \(difficulty.rawValue)
        - 自動進行: \(autoAdvance ? "有効" : "無効")
        - ヒント表示: \(showHints ? "有効" : "無効")
        - 大きな文字: \(largeText ? "有効" : "無効")
        - アニメーション軽減: \(reduceAnimations ? "有効" : "無効")
        - 音声速度: \(formattedVoiceSpeed())
        - プレイ時間制限: \(formattedPlaytimeLimit())
        """
    }
}