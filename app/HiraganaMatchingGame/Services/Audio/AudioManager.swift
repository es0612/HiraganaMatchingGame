//
//  AudioManager.swift
//  HiraganaMatchingGame
//
//

import Foundation
import Combine

class AudioManager: ObservableObject {
    // Published properties for UI binding
    @Published var isSoundEnabled: Bool = true
    @Published var isMusicEnabled: Bool = true
    @Published var currentVolume: Float = 1.0
    @Published var playbackSpeed: Float = 1.0
    
    // Audio components
    private let audioPlayer: AudioPlayer
    private let bgmGenerator: BGMGenerator
    private let speechSynthesizer: SpeechSynthesizer
    private let effectPlayer: EffectPlayer
    
    private var userSettings: UserSettings?
    private var cancellables = Set<AnyCancellable>()
    
    init(isTestMode: Bool = false) {
        self.audioPlayer = AudioPlayer(isTestMode: isTestMode)
        self.bgmGenerator = BGMGenerator(isTestMode: isTestMode)
        self.speechSynthesizer = SpeechSynthesizer(isTestMode: isTestMode)
        self.effectPlayer = EffectPlayer(isTestMode: isTestMode)
        
        setupBindings()
    }
    
    convenience init(userSettings: UserSettings, isTestMode: Bool = false) {
        self.init(isTestMode: isTestMode)
        self.userSettings = userSettings
        syncWithUserSettings()
    }
    
    private func setupBindings() {
        // Sync settings across all audio components
        $isSoundEnabled
            .sink { [weak self] enabled in
                self?.audioPlayer.setEnabled(enabled)
                self?.speechSynthesizer.setEnabled(enabled)
                self?.effectPlayer.setEnabled(enabled)
            }
            .store(in: &cancellables)
        
        $currentVolume
            .sink { [weak self] volume in
                self?.audioPlayer.setVolume(volume)
                self?.speechSynthesizer.setVolume(volume)
                self?.effectPlayer.setVolume(volume)
                self?.bgmGenerator.setBGMVolume(volume * 0.3) // BGM at 30% of main volume
            }
            .store(in: &cancellables)
        
        $playbackSpeed
            .sink { [weak self] speed in
                self?.audioPlayer.setPlaybackSpeed(speed)
                self?.speechSynthesizer.setSpeechRate(speed)
            }
            .store(in: &cancellables)
    }
    
    private func syncWithUserSettings() {
        guard let settings = userSettings else { return }
        
        isSoundEnabled = settings.soundEnabled
        isMusicEnabled = settings.musicEnabled
        currentVolume = Float(settings.soundVolume)
        playbackSpeed = Float(settings.voiceSpeed)
    }
    
    // MARK: - Public Interface
    
    // Audio file playback
    func hasAudioFile(for character: String) -> Bool {
        return audioPlayer.hasAudioFile(for: character)
    }
    
    func preloadAudioForLevel(_ level: Int) async {
        // Get characters for level and preload their audio
        let levelConfig = getLevelConfiguration(level)
        
        for character in levelConfig {
            do {
                try await audioPlayer.prepareAudio(for: character)
            } catch {
                print("Failed to preload audio for \(character): \(error)")
            }
        }
    }
    
    func playAudio(for character: String) async {
        await audioPlayer.playAudio(for: character)
    }
    
    func isAudioReady(for character: String) -> Bool {
        return audioPlayer.isAudioReady(for: character)
    }
    
    // Speech synthesis
    func speakText(_ text: String, slowly: Bool = false) async {
        await speechSynthesizer.speakText(text, slowly: slowly)
    }
    
    func speakCharacter(_ character: String, slowly: Bool = false) async {
        await speechSynthesizer.speakCharacter(character, slowly: slowly)
    }
    
    // Effect sounds
    func playCorrectSound() {
        effectPlayer.playCorrectSound()
    }
    
    func playIncorrectSound() {
        effectPlayer.playIncorrectSound()
    }
    
    func playLevelUpSound() {
        effectPlayer.playLevelUpSound()
    }
    
    func playButtonSound() {
        effectPlayer.playButtonSound()
    }
    
    func playAchievementSound() {
        effectPlayer.playAchievementSound()
    }
    
    // Background music
    func startBackgroundMusic() {
        guard isMusicEnabled else { return }
        bgmGenerator.startBackgroundMusic(filename: "bgm", volume: currentVolume * 0.3)
    }
    
    func stopBackgroundMusic() {
        bgmGenerator.stopBackgroundMusic()
    }
    
    func isBGMPlaying() -> Bool {
        return bgmGenerator.isBGMPlaying()
    }

    // MARK: - BGM switching
    func switchToMenuBGM() {
        guard isMusicEnabled else { return }
        bgmGenerator.startBackgroundMusic(filename: "bgm", volume: currentVolume * 0.3)
    }

    func switchToGameplayBGM() {
        guard isMusicEnabled else { return }
        bgmGenerator.startBackgroundMusic(filename: "playingBgm", volume: currentVolume * 0.3)
    }
    
    // Control methods
    func stopAllAudio() {
        audioPlayer.stopAllAudio()
        speechSynthesizer.stopSpeaking()
        effectPlayer.stopEffect()
        bgmGenerator.stopBackgroundMusic()
    }
    
    func pauseAllAudio() {
        speechSynthesizer.pauseSpeaking()
        // Note: AudioPlayer and others don't have pause functionality
        // This could be extended if needed
    }
    
    func resumeAllAudio() {
        speechSynthesizer.continueSpeaking()
    }
    
    // Settings
    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
        userSettings?.soundEnabled = enabled
    }
    
    func setMusicEnabled(_ enabled: Bool) {
        isMusicEnabled = enabled
        userSettings?.musicEnabled = enabled
        
        if enabled && !bgmGenerator.isBGMPlaying() {
            startBackgroundMusic()
        } else if !enabled {
            stopBackgroundMusic()
        }
    }
    
    func setVolume(_ volume: Float) {
        currentVolume = max(0.0, min(1.0, volume))
        userSettings?.soundVolume = Double(currentVolume)
    }
    
    func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = max(0.5, min(2.0, speed))
        userSettings?.voiceSpeed = Double(playbackSpeed)
    }
    
    // MARK: - Helper Methods
    
    private func getLevelConfiguration(_ level: Int) -> [String] {
        // This is a simplified version - in real implementation,
        // this would use LevelProgressionService
        let allCharacters = [
            ["あ", "い", "う", "え", "お"],
            ["か", "き", "く", "け", "こ"],
            ["さ", "し", "す", "せ", "そ"],
            ["た", "ち", "つ", "て", "と"],
            ["な", "に", "ぬ", "ね", "の"]
        ]
        
        let levelIndex = max(0, min(level - 1, allCharacters.count - 1))
        return Array(allCharacters[0...levelIndex].flatMap { $0 })
    }
}
