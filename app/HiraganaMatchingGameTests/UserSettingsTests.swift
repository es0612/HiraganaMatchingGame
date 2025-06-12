import Testing
import SwiftData
@testable import HiraganaMatchingGame

@Test("UserSettingsモデル初期化テスト")
func userSettingsInitialization() {
    let settings = UserSettings()
    
    #expect(settings.soundEnabled == true)
    #expect(settings.musicEnabled == true)
    #expect(settings.playtimeLimit == 0)
    #expect(settings.voiceSpeed == 1.0)
}

@Test("設定値更新テスト")
func settingsUpdate() {
    let settings = UserSettings()
    
    settings.updateSettings(
        soundEnabled: false,
        musicEnabled: false,
        playtimeLimit: 30,
        voiceSpeed: 0.8
    )
    
    #expect(settings.soundEnabled == false)
    #expect(settings.musicEnabled == false)
    #expect(settings.playtimeLimit == 30)
    #expect(settings.voiceSpeed == 0.8)
}

@Test("音声速度の範囲制限テスト")
func voiceSpeedRange() {
    let settings = UserSettings()
    
    settings.setVoiceSpeed(2.5)
    #expect(settings.voiceSpeed == 2.0)
    
    settings.setVoiceSpeed(0.3)
    #expect(settings.voiceSpeed == 0.5)
    
    settings.setVoiceSpeed(1.2)
    #expect(settings.voiceSpeed == 1.2)
}