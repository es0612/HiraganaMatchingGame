import AVFoundation
import Foundation

enum AudioServiceError: Error {
    case fileNotFound
    case playbackFailed
    case audioSessionSetupFailed
}

class AudioService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AudioService()
    
    // Private initializer to prevent multiple instances
    private var isSharedInstance = false
    @Published var isSoundEnabled: Bool = true
    @Published var isMusicEnabled: Bool = true
    @Published var currentVolume: Float = 1.0
    @Published var playbackSpeed: Float = 1.0
    
    private var userSettings: UserSettings?
    private let isTestMode: Bool
    // Unified audio system - now required, not optional
    private let audioManager: AudioManager
    
    private init(isTestMode: Bool = false) {
        self.isTestMode = isTestMode
        audioManager = AudioManager(isTestMode: isTestMode)
        isSharedInstance = true
        setupAudioManagerBindings()
    }
    
    // Factory method for creating AudioService with settings
    static func createWithSettings(_ userSettings: UserSettings, isTestMode: Bool = false, startBGM: Bool = false) -> AudioService {
        let instance = AudioService.shared
        instance.userSettings = userSettings
        // Update existing AudioManager with new settings
        instance.audioManager.updateUserSettings(userSettings)
        if !isTestMode {
            instance.syncWithUserSettings(startBGM: startBGM)
        }
        return instance
    }
    
    // Factory method for testing
    static func createForTesting() -> AudioService {
        AudioService(isTestMode: true)
    }
    
    private func setupAudioManagerBindings() {
        // Sync AudioService published properties with AudioManager
        audioManager.$isSoundEnabled
            .assign(to: &$isSoundEnabled)
        audioManager.$isMusicEnabled
            .assign(to: &$isMusicEnabled)
        audioManager.$currentVolume
            .assign(to: &$currentVolume)
        audioManager.$playbackSpeed
            .assign(to: &$playbackSpeed)
    }
    
    func hasAudioFile(for character: String) -> Bool {
        audioManager.hasAudioFile(for: character)
    }
    
    private func syncWithUserSettings(startBGM: Bool = false) {
        guard let settings = userSettings else { return }
        
        isSoundEnabled = settings.soundEnabled
        isMusicEnabled = settings.musicEnabled
        currentVolume = Float(settings.soundVolume)
        playbackSpeed = Float(settings.voiceSpeed)
        
        // BGMを開始（スプラッシュスクリーン時のみ）
        if isMusicEnabled && startBGM {
            startBackgroundMusic()
        }
        
        // 設定変更の監視
        settings.onSettingChanged = { [weak self] settingName in
            DispatchQueue.main.async {
                self?.updateFromSettings(settingName)
            }
        }
    }
    
    private func updateFromSettings(_ settingName: String) {
        guard let settings = userSettings else { return }
        
        switch settingName {
        case "soundEnabled":
            setSoundEnabled(settings.soundEnabled)
        case "musicEnabled":
            let newMusicEnabled = settings.musicEnabled
            if newMusicEnabled != isMusicEnabled {
                setMusicEnabled(newMusicEnabled)
                if newMusicEnabled {
                    startBackgroundMusic()
                } else {
                    stopBackgroundMusic()
                }
            }
        case "soundVolume":
            setVolume(Float(settings.soundVolume))
        // BGM volume update is handled by AudioManager
        case "voiceSpeed":
            setPlaybackSpeed(Float(settings.voiceSpeed))
        default:
            break
        }
    }
    
    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
        audioManager.setSoundEnabled(enabled)
        if !enabled {
            stopAllAudio()
        }
    }
    
    func setMusicEnabled(_ enabled: Bool) {
        isMusicEnabled = enabled
        audioManager.setMusicEnabled(enabled)
        if enabled {
            startBackgroundMusic()
        } else {
            stopBackgroundMusic()
        }
    }
    
    func setVolume(_ volume: Float) {
        currentVolume = max(0.0, min(1.0, volume))
        audioManager.setVolume(currentVolume)
    }
    
    func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = max(0.5, min(2.0, speed))
        audioManager.setPlaybackSpeed(playbackSpeed)
    }
    
    func playAudio(for character: String) async {
        await audioManager.playAudio(for: character)
    }
    
    func speakText(_ text: String, slowly: Bool = false) async {
        await audioManager.speakText(text, slowly: slowly)
    }
    
    func isAudioReady(for character: String) -> Bool {
        audioManager.isAudioReady(for: character)
    }
    
    func stopAllAudio() {
        audioManager.stopAllAudio()
        // BGM continues playing
    }
    
    // MARK: - BGM機能
    
    func startBackgroundMusic(filename: String = "bgm") {
        guard isMusicEnabled, !isTestMode else {
            print("🎵 Music disabled or test mode, not starting BGM")
            return
        }
        
        if filename == "bgm" {
            audioManager.startBackgroundMusic()
        } else if filename == "playingBgm" {
            audioManager.switchToGameplayBGM()
        } else {
            audioManager.startBackgroundMusic()
        }
    }
    
    func stopBackgroundMusic() {
        audioManager.stopBackgroundMusic()
        print("🎵 Background music stopped")
    }
    
    func isBGMPlaying() -> Bool {
        audioManager.isBGMPlaying()
    }
    
    func switchToGameplayBGM() {
        guard isMusicEnabled, !isTestMode else { return }
        audioManager.switchToGameplayBGM()
    }
    
    func switchToMenuBGM() {
        guard isMusicEnabled, !isTestMode else { return }
        audioManager.switchToMenuBGM()
    }
    
    func preloadAudioForLevel(_ level: Int) async {
        await audioManager.preloadAudioForLevel(level)
    }
    
    // MARK: - 効果音
    
    func playCorrectSound() {
        audioManager.playCorrectSound()
    }
    
    func playIncorrectSound() {
        audioManager.playIncorrectSound()
    }
    
    deinit {
        stopAllAudio()
        stopBackgroundMusic()
    }
}
