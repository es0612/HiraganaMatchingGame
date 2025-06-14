import Testing
import AVFoundation
@testable import HiraganaMatchingGame

@Test("AudioService初期化テスト")
func audioServiceInitialization() {
    let audioService = AudioService()
    
    #expect(audioService.isSoundEnabled == true)
    #expect(audioService.currentVolume == 1.0)
}

@Test("音声ファイル存在確認テスト")
func audioFileExistenceCheck() {
    let audioService = AudioService()
    
    let hiraganaCharacters = ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ"]
    
    for character in hiraganaCharacters {
        let hasFile = audioService.hasAudioFile(for: character)
        // 実際のアプリでは音声ファイルが存在する想定でテスト
        // 開発中はモックとして true を期待
        #expect(hasFile == true)
    }
}

@Test("音声再生設定テスト")
func audioPlaybackSettings() {
    let audioService = AudioService()
    
    audioService.setSoundEnabled(false)
    #expect(audioService.isSoundEnabled == false)
    
    audioService.setSoundEnabled(true)
    #expect(audioService.isSoundEnabled == true)
}

@Test("音量調整テスト")
func volumeControl() {
    let audioService = AudioService()
    
    audioService.setVolume(0.5)
    #expect(audioService.currentVolume == 0.5)
    
    audioService.setVolume(0.0)
    #expect(audioService.currentVolume == 0.0)
    
    audioService.setVolume(1.0)
    #expect(audioService.currentVolume == 1.0)
}

@Test("音声再生速度設定テスト")
func playbackSpeedSetting() {
    let audioService = AudioService()
    
    audioService.setPlaybackSpeed(0.8)
    #expect(audioService.playbackSpeed == 0.8)
    
    audioService.setPlaybackSpeed(1.5)
    #expect(audioService.playbackSpeed == 1.5)
    
    // 範囲外の値は制限される
    audioService.setPlaybackSpeed(0.3)
    #expect(audioService.playbackSpeed == 0.5)
    
    audioService.setPlaybackSpeed(2.5)
    #expect(audioService.playbackSpeed == 2.0)
}

// 音声準備テストは AudioServiceIntegrationTests でカバーされているため削除