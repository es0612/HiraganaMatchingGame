//
//  RefactoredAudioService.swift
//  HiraganaMatchingGame
//
//

import Foundation

// Bridge class to maintain compatibility with existing code
// while using the new modular audio system
class RefactoredAudioService: ObservableObject {
    @Published var isSoundEnabled: Bool = true
    @Published var isMusicEnabled: Bool = true
    @Published var currentVolume: Float = 1.0
    @Published var playbackSpeed: Float = 1.0
    
    private let audioManager: AudioManager
    
    init(isTestMode: Bool = false) {
        self.audioManager = AudioManager(isTestMode: isTestMode)
        setupBindings()
    }
    
    init(userSettings: UserSettings, isTestMode: Bool = false) {
        self.audioManager = AudioManager(userSettings: userSettings, isTestMode: isTestMode)
        setupBindings()
    }
    
    private func setupBindings() {
        // Mirror AudioManager's published properties
        audioManager.$isSoundEnabled.assign(to: &$isSoundEnabled)
        audioManager.$isMusicEnabled.assign(to: &$isMusicEnabled)
        audioManager.$currentVolume.assign(to: &$currentVolume)
        audioManager.$playbackSpeed.assign(to: &$playbackSpeed)
    }
    
    // MARK: - Public Interface (maintains compatibility)
    
    func hasAudioFile(for character: String) -> Bool {
        return audioManager.hasAudioFile(for: character)
    }
    
    func preloadAudioForLevel(_ level: Int) async {
        await audioManager.preloadAudioForLevel(level)
    }
    
    func playAudio(for character: String) async {
        await audioManager.playAudio(for: character)
    }
    
    func speakText(_ text: String, slowly: Bool = false) async {
        await audioManager.speakText(text, slowly: slowly)
    }
    
    func playCorrectSound() {
        audioManager.playCorrectSound()
    }
    
    func playIncorrectSound() {
        audioManager.playIncorrectSound()
    }
    
    func startBackgroundMusic() {
        audioManager.startBackgroundMusic()
    }
    
    func stopBackgroundMusic() {
        audioManager.stopBackgroundMusic()
    }
    
    func stopAllAudio() {
        audioManager.stopAllAudio()
    }
    
    func isAudioReady(for character: String) -> Bool {
        return audioManager.isAudioReady(for: character)
    }
    
    func setSoundEnabled(_ enabled: Bool) {
        audioManager.setSoundEnabled(enabled)
    }
    
    func setMusicEnabled(_ enabled: Bool) {
        audioManager.setMusicEnabled(enabled)
    }
    
    func setVolume(_ volume: Float) {
        audioManager.setVolume(volume)
    }
    
    func setPlaybackSpeed(_ speed: Float) {
        audioManager.setPlaybackSpeed(speed)
    }
}