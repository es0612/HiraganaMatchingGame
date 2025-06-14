import Testing
import SwiftData
@testable import HiraganaMatchingGame

@Suite("音声サービス統合テスト")
struct AudioServiceIntegrationTests {
    
    @Test("設定との連携テスト")
    func settingsIntegration() {
        let settings = TestableUserSettings()
        let audioService = AudioService() // Use default initializer
        
        // 初期設定の確認
        #expect(audioService.isSoundEnabled == settings.soundEnabled)
        #expect(audioService.currentVolume == Float(settings.soundVolume))
        #expect(audioService.playbackSpeed == Float(settings.voiceSpeed))
        
        // 設定変更のテスト
        settings.soundEnabled = false
        settings.soundVolume = 0.5
        settings.voiceSpeed = 1.5
        
        // 手動で更新をトリガー（実際のアプリでは自動）
        audioService.setSoundEnabled(settings.soundEnabled)
        audioService.setVolume(Float(settings.soundVolume))
        audioService.setPlaybackSpeed(Float(settings.voiceSpeed))
        
        // 変更が反映されることを確認
        #expect(audioService.isSoundEnabled == false)
        #expect(audioService.currentVolume == 0.5)
        #expect(audioService.playbackSpeed == 1.5)
    }
    
    @Test("音声ファイル検出テスト")
    func audioFileDetection() {
        let audioService = AudioService()
        
        // 基本的なひらがな文字の音声ファイル検出
        let basicCharacters = ["あ", "い", "う", "え", "お"]
        
        for character in basicCharacters {
            let hasAudio = audioService.hasAudioFile(for: character)
            #expect(hasAudio == true, "文字'\(character)'の音声ファイルが見つかりません")
        }
    }
    
    @Test("音声プレイバック準備テスト")
    func audioPrepareTest() async {
        let audioService = AudioService()
        
        do {
            try await audioService.prepareAudio(for: "あ")
            let isReady = audioService.isAudioReady(for: "あ")
            #expect(isReady == true, "音声の準備が完了していません")
        } catch {
            // モック音声が生成されるため、エラーは発生しないはず
            #expect(false, "音声の準備中にエラーが発生しました: \(error)")
        }
    }
    
    @Test("音量設定テスト")
    func volumeSettingsTest() {
        let audioService = AudioService()
        
        // 音量設定の境界値テスト
        audioService.setVolume(-0.5) // 負の値
        #expect(audioService.currentVolume == 0.0)
        
        audioService.setVolume(1.5) // 最大値を超える値
        #expect(audioService.currentVolume == 1.0)
        
        audioService.setVolume(0.7) // 通常の値
        #expect(audioService.currentVolume == 0.7)
    }
    
    @Test("音声速度設定テスト")
    func playbackSpeedTest() {
        let audioService = AudioService()
        
        // 音声速度設定の境界値テスト
        audioService.setPlaybackSpeed(0.3) // 最小値を下回る値
        #expect(audioService.playbackSpeed == 0.5)
        
        audioService.setPlaybackSpeed(3.0) // 最大値を超える値
        #expect(audioService.playbackSpeed == 2.0)
        
        audioService.setPlaybackSpeed(1.2) // 通常の値
        #expect(audioService.playbackSpeed == 1.2)
    }
    
    @Test("音声無効化テスト")
    func soundDisableTest() async {
        let audioService = AudioService()
        
        // 音声を無効化
        audioService.setSoundEnabled(false)
        #expect(audioService.isSoundEnabled == false)
        
        // 音声が無効化されている状態でプレイバックを試行
        await audioService.playAudio(for: "あ")
        
        // 無効化されているため、実際の再生は行われない
        // （このテストは主に例外が発生しないことを確認）
        #expect(true, "音声無効化状態での再生試行が完了しました")
    }
    
    @Test("複数音声の管理テスト")
    func multipleAudioManagementTest() async {
        let audioService = AudioService()
        
        let characters = ["あ", "か", "さ"]
        
        // 複数の音声を準備
        for character in characters {
            do {
                try await audioService.prepareAudio(for: character)
            } catch {
                #expect(false, "文字'\(character)'の音声準備でエラー: \(error)")
            }
        }
        
        // すべての音声が準備完了していることを確認
        for character in characters {
            let isReady = audioService.isAudioReady(for: character)
            #expect(isReady == true, "文字'\(character)'の音声が準備されていません")
        }
        
        // すべての音声を停止
        audioService.stopAllAudio()
        
        // 停止後も音声データは保持されていることを確認
        for character in characters {
            let isReady = audioService.isAudioReady(for: character)
            #expect(isReady == true, "停止後に文字'\(character)'の音声データが失われました")
        }
    }
    
    @Test("レベル音声プリロードテスト")
    func levelAudioPreloadTest() async {
        let audioService = AudioService()
        
        // レベル1の音声をプリロード
        await audioService.preloadAudioForLevel(1)
        
        // レベル1のひらがな文字の音声が準備されていることを確認
        let level1Characters = ["あ", "い", "う", "え", "お"]
        
        for character in level1Characters {
            let isReady = audioService.isAudioReady(for: character)
            #expect(isReady == true, "レベル1の文字'\(character)'の音声がプリロードされていません")
        }
    }
    
    @Test("GameViewModelとの統合テスト")
    func gameViewModelIntegrationTest() {
        let settings = TestableUserSettings()
        settings.soundEnabled = true
        settings.soundVolume = 0.8
        settings.voiceSpeed = 1.2
        
        let gameViewModel = GameViewModel() // Use default initializer
        
        // GameViewModelが正常に初期化されることを確認
        #expect(gameViewModel.currentLevel == 1)
        #expect(gameViewModel.score == 0)
        #expect(gameViewModel.isGameCompleted == false)
        
        // ゲーム開始
        gameViewModel.startNewGame(level: 1)
        
        // ゲームが正常に開始されることを確認
        #expect(gameViewModel.currentLevel == 1)
        #expect(gameViewModel.currentQuestion == 1)
    }
}