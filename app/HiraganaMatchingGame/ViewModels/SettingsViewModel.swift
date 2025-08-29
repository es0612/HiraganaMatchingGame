import Foundation
import SwiftData

@Observable
class SettingsViewModel {
    private var userSettings: UserSettings
    private let modelContext: ModelContext?
    
    // チュートリアル表示のコールバック
    var onShowTutorial: (() -> Void)?
    
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
            userSettings.onSettingChanged?("musicEnabled")
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
    
    var questionsPerSession: QuestionsPerSession {
        get { userSettings.questionsPerSessionEnum }
        set { 
            userSettings.setQuestionsPerSessionEnum(newValue)
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
    
    func resetPlayData() {
        // レベル進行データをリセット
        let levelProgressionService = LevelProgressionService()
        levelProgressionService.resetProgress()
        
        // スターとキャラクター解放データをリセット
        let starUnlockService = StarUnlockService()
        starUnlockService.resetProgress()
        
        // SwiftDataのGameProgressエンティティをすべて削除
        if let context = modelContext {
            do {
                let descriptor = FetchDescriptor<GameProgress>()
                let gameProgressEntities = try context.fetch(descriptor)
                for entity in gameProgressEntities {
                    context.delete(entity)
                }
                try context.save()
                print("🔄 SwiftData GameProgress entities deleted")
            } catch {
                print("❌ Failed to delete GameProgress entities: \(error)")
            }
        }
        
        print("🔄 プレイデータがリセットされました")
    }
    
    func saveSettings() {
        if let context = modelContext {
            do {
                try context.save()
            } catch {
                print("設定の保存に失敗しました: \(error)")
            }
        }
    }
    
    func loadSettings() { }
    
    // 設定のバリデーション
    func validateAllSettings() -> Bool {
        return userSettings.validateSettings()
    }
    
    // 音量のフォーマット（パーセンテージ表示用）
    func formattedSoundVolume() -> String {
        return "\(Int(soundVolume * 100))%"
    }
    
    // 制限時間のフォーマット（秒単位）
    func formattedPlaytimeLimit() -> String {
        if playtimeLimit == 0 {
            return "制限なし"
        } else if playtimeLimit < 60 {
            return "\(playtimeLimit)秒"
        } else {
            let minutes = playtimeLimit / 60
            let seconds = playtimeLimit % 60
            if seconds == 0 {
                return "\(minutes)分"
            } else {
                return "\(minutes)分\(seconds)秒"
            }
        }
    }
    
    // 音声速度のフォーマット
    func formattedVoiceSpeed() -> String {
        return String(format: "%.1fx", voiceSpeed)
    }
    
    // 問題数のフォーマット
    func formattedQuestionsPerSession() -> String {
        return questionsPerSession.displayName
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
        - 問題数: \(formattedQuestionsPerSession())
        """
    }
    
    // チュートリアル表示を要求
    func showTutorial() {
        onShowTutorial?()
    }
}
