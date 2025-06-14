import Foundation
@testable import HiraganaMatchingGame

// テスト専用のUserSettings（@Modelなし）
class TestableUserSettings {
    var soundEnabled: Bool = true
    var musicEnabled: Bool = true
    var playtimeLimit: Int = 0
    var voiceSpeed: Double = 1.0
    var soundVolume: Double = 0.8
    private var gameSpeedRaw: String = GameSpeed.normal.rawValue
    private var difficultyRaw: String = GameDifficulty.normal.rawValue
    var autoAdvance: Bool = false
    var showHints: Bool = true
    var largeText: Bool = false
    var reduceAnimations: Bool = false
    
    var onSettingChanged: ((String) -> Void)?
    
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
    
    func toggleSound() {
        soundEnabled.toggle()
        onSettingChanged?("soundEnabled")
    }
    
    func toggleMusic() {
        musicEnabled.toggle()
        onSettingChanged?("musicEnabled")
    }
    
    func setSoundVolume(_ volume: Double) {
        soundVolume = max(0.0, min(1.0, volume))
        onSettingChanged?("soundVolume")
    }
    
    func setGameSpeed(_ speed: GameSpeed) {
        gameSpeedRaw = speed.rawValue
        onSettingChanged?("gameSpeed")
    }
    
    func setDifficulty(_ newDifficulty: GameDifficulty) {
        difficultyRaw = newDifficulty.rawValue
        onSettingChanged?("difficulty")
    }
    
    func setAutoAdvance(_ enabled: Bool) {
        autoAdvance = enabled
        onSettingChanged?("autoAdvance")
    }
    
    func setShowHints(_ enabled: Bool) {
        showHints = enabled
        onSettingChanged?("showHints")
    }
    
    func setLargeText(_ enabled: Bool) {
        largeText = enabled
        onSettingChanged?("largeText")
    }
    
    func setReduceAnimations(_ enabled: Bool) {
        reduceAnimations = enabled
        onSettingChanged?("reduceAnimations")
    }
    
    func setVoiceSpeed(_ speed: Double) {
        voiceSpeed = max(0.5, min(2.0, speed))
        onSettingChanged?("voiceSpeed")
    }
    
    func updateSettings(soundEnabled: Bool, musicEnabled: Bool, playtimeLimit: Int, voiceSpeed: Double) {
        self.soundEnabled = soundEnabled
        self.musicEnabled = musicEnabled
        self.playtimeLimit = playtimeLimit
        self.voiceSpeed = max(0.5, min(2.0, voiceSpeed))
        onSettingChanged?("updateSettings")
    }
    
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
    
    func validateSettings() -> Bool {
        return soundVolume >= 0.0 && soundVolume <= 1.0 &&
               voiceSpeed >= 0.5 && voiceSpeed <= 2.0 &&
               playtimeLimit >= 0
    }
}