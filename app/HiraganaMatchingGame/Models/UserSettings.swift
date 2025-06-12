import Foundation
import SwiftData

@Model
final class UserSettings {
    var soundEnabled: Bool
    var musicEnabled: Bool
    var playtimeLimit: Int
    var voiceSpeed: Double
    
    init() {
        self.soundEnabled = true
        self.musicEnabled = true
        self.playtimeLimit = 0
        self.voiceSpeed = 1.0
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
    }
    
    func toggleMusic() {
        musicEnabled.toggle()
    }
}