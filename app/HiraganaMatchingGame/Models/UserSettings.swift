import Foundation
import SwiftData

enum GameSpeed: String, CaseIterable {
    case slow = "遅い"
    case normal = "普通"
    case fast = "速い"
}

enum GameDifficulty: String, CaseIterable {
    case easy = "簡単"
    case normal = "普通"
    case hard = "難しい"
}

@Model
final class UserSettings {
    var soundEnabled: Bool
    var musicEnabled: Bool
    var playtimeLimit: Int
    var voiceSpeed: Double
    
    // 新しい設定項目
    var soundVolume: Double
    private var gameSpeedRaw: String
    private var difficultyRaw: String
    var autoAdvance: Bool
    var showHints: Bool
    var largeText: Bool
    var reduceAnimations: Bool
    
    // 設定変更通知（@Modelからは除外）
    @Transient
    var onSettingChanged: ((String) -> Void)?
    
    // Computed properties for enum access
    var gameSpeed: GameSpeed {
        get { GameSpeed(rawValue: gameSpeedRaw) ?? .normal }
        set { 
            gameSpeedRaw = newValue.rawValue
            onSettingChanged?("gameSpeed")
        }
    }
    
    var difficulty: GameDifficulty {
        get { GameDifficulty(rawValue: difficultyRaw) ?? .normal }
        set { 
            difficultyRaw = newValue.rawValue
            onSettingChanged?("difficulty")
        }
    }
    
    init() {
        self.soundEnabled = true
        self.musicEnabled = true
        self.playtimeLimit = 0
        self.voiceSpeed = 1.0
        
        // 新しい設定項目の初期値
        self.soundVolume = 0.8
        self.gameSpeedRaw = GameSpeed.normal.rawValue
        self.difficultyRaw = GameDifficulty.normal.rawValue
        self.autoAdvance = false
        self.showHints = true
        self.largeText = false
        self.reduceAnimations = false
    }
    
    func updateSettings(
        soundEnabled: Bool,
        musicEnabled: Bool,
        playtimeLimit: Int,
        voiceSpeed: Double
    ) {
        self.soundEnabled = soundEnabled
        self.musicEnabled = musicEnabled
        self.playtimeLimit = playtimeLimit
        self.voiceSpeed = max(0.5, min(2.0, voiceSpeed))
    }
    
    func setVoiceSpeed(_ speed: Double) {
        voiceSpeed = max(0.5, min(2.0, speed))
    }
    
    func toggleSound() {
        soundEnabled.toggle()
        onSettingChanged?("soundEnabled")
    }
    
    func toggleMusic() {
        musicEnabled.toggle()
        onSettingChanged?("musicEnabled")
    }
    
    // 音量設定（0.0-1.0の範囲でクランプ）
    func setSoundVolume(_ volume: Double) {
        soundVolume = max(0.0, min(1.0, volume))
        onSettingChanged?("soundVolume")
    }
    
    // ゲーム速度設定
    func setGameSpeed(_ speed: GameSpeed) {
        gameSpeedRaw = speed.rawValue
        onSettingChanged?("gameSpeed")
    }
    
    // 難易度設定
    func setDifficulty(_ newDifficulty: GameDifficulty) {
        difficultyRaw = newDifficulty.rawValue
        onSettingChanged?("difficulty")
    }
    
    // 自動進行設定
    func setAutoAdvance(_ enabled: Bool) {
        autoAdvance = enabled
        onSettingChanged?("autoAdvance")
    }
    
    // ヒント表示設定
    func setShowHints(_ enabled: Bool) {
        showHints = enabled
        onSettingChanged?("showHints")
    }
    
    // 大きな文字設定
    func setLargeText(_ enabled: Bool) {
        largeText = enabled
        onSettingChanged?("largeText")
    }
    
    // アニメーション軽減設定
    func setReduceAnimations(_ enabled: Bool) {
        reduceAnimations = enabled
        onSettingChanged?("reduceAnimations")
    }
    
    // 設定をデフォルトに戻す
    func resetToDefaults() {
        soundEnabled = true
        musicEnabled = true
        playtimeLimit = 0
        voiceSpeed = 1.0
        soundVolume = 0.8
        gameSpeedRaw = GameSpeed.normal.rawValue
        difficultyRaw = GameDifficulty.normal.rawValue
        autoAdvance = false
        showHints = true
        largeText = false
        reduceAnimations = false
        onSettingChanged?("reset")
    }
    
    // 設定の保存（UserDefaultsを使用）
    func save() {
        UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        UserDefaults.standard.set(musicEnabled, forKey: "musicEnabled")
        UserDefaults.standard.set(playtimeLimit, forKey: "playtimeLimit")
        UserDefaults.standard.set(voiceSpeed, forKey: "voiceSpeed")
        UserDefaults.standard.set(soundVolume, forKey: "soundVolume")
        UserDefaults.standard.set(gameSpeedRaw, forKey: "gameSpeed")
        UserDefaults.standard.set(difficultyRaw, forKey: "difficulty")
        UserDefaults.standard.set(autoAdvance, forKey: "autoAdvance")
        UserDefaults.standard.set(showHints, forKey: "showHints")
        UserDefaults.standard.set(largeText, forKey: "largeText")
        UserDefaults.standard.set(reduceAnimations, forKey: "reduceAnimations")
    }
    
    // 設定の読み込み（UserDefaultsから）
    func load() {
        soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        musicEnabled = UserDefaults.standard.bool(forKey: "musicEnabled")
        playtimeLimit = UserDefaults.standard.integer(forKey: "playtimeLimit")
        voiceSpeed = UserDefaults.standard.double(forKey: "voiceSpeed")
        soundVolume = UserDefaults.standard.double(forKey: "soundVolume")
        
        if let speedString = UserDefaults.standard.string(forKey: "gameSpeed") {
            gameSpeedRaw = speedString
        }
        
        if let difficultyString = UserDefaults.standard.string(forKey: "difficulty") {
            difficultyRaw = difficultyString
        }
        
        autoAdvance = UserDefaults.standard.bool(forKey: "autoAdvance")
        showHints = UserDefaults.standard.bool(forKey: "showHints")
        largeText = UserDefaults.standard.bool(forKey: "largeText")
        reduceAnimations = UserDefaults.standard.bool(forKey: "reduceAnimations")
    }
    
    // 設定の検証
    func validateSettings() -> Bool {
        return soundVolume >= 0.0 && soundVolume <= 1.0 &&
               voiceSpeed >= 0.5 && voiceSpeed <= 2.0 &&
               playtimeLimit >= 0
    }
    
    // 設定変更の通知を設定
    private func setupNotifications() {
        // 設定変更時の通知設定をここで行う
    }
}