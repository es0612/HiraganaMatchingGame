import AVFoundation
import Foundation
@testable import HiraganaMatchingGame
import Testing

/// BGM の呼び出しを記録するだけの fake（実音声はテストで検証できないため）
final class RecordingBGMPlayer: BGMPlaying {
    private(set) var calls: [String] = []
    private var playing = false

    func startBackgroundMusic(filename: String, volume: Float) {
        calls.append("start:\(filename)")
        playing = true
    }

    func stopBackgroundMusic() {
        calls.append("stop")
        playing = false
    }

    func pauseBackgroundMusic() {
        calls.append("pause")
        playing = false
    }

    func resumeBackgroundMusic() {
        calls.append("resume")
        playing = true
    }

    func setBGMVolume(_ volume: Float) {}

    func isBGMPlaying() -> Bool {
        playing
    }
}

@Suite("音声ライフサイクル (#20)")
struct AudioLifecycleTests {
    private func makeManager() -> (AudioManager, RecordingBGMPlayer) {
        let bgm = RecordingBGMPlayer()
        let manager = AudioManager(isTestMode: true, bgmPlayer: bgm)
        return (manager, bgm)
    }

    @Test("バックグラウンドに入ると再生中の BGM を一時停止する")
    func pausesBGMOnEnterBackground() {
        let (manager, bgm) = makeManager()
        manager.switchToMenuBGM()

        manager.handleEnterBackground()

        #expect(bgm.calls == ["start:bgm", "pause"])
        #expect(bgm.isBGMPlaying() == false)
    }

    @Test("バックグラウンドから復帰すると一時停止した BGM を再開する")
    func resumesBGMOnBecomeActive() {
        let (manager, bgm) = makeManager()
        manager.switchToGameplayBGM()
        manager.handleEnterBackground()

        manager.handleBecomeActive()

        #expect(bgm.calls == ["start:playingBgm", "pause", "resume"])
    }

    @Test("BGM を鳴らしていなければ復帰しても鳴らし始めない")
    func doesNotStartBGMOnBecomeActiveWhenNothingWasPlaying() {
        let (manager, bgm) = makeManager()

        manager.handleEnterBackground()
        manager.handleBecomeActive()

        #expect(bgm.calls.isEmpty)
    }

    @Test("バックグラウンド中に BGM がオフになったら復帰しても再開しない")
    func doesNotResumeWhenMusicDisabledWhileInBackground() {
        let (manager, bgm) = makeManager()
        manager.switchToMenuBGM()
        manager.handleEnterBackground()

        manager.setMusicEnabled(false)
        manager.handleBecomeActive()

        #expect(!bgm.calls.contains("resume"))
        #expect(bgm.isBGMPlaying() == false)
    }

    @Test("割り込み（通話など）開始で一時停止し、終了で再開する")
    func pausesAndResumesAroundInterruption() {
        let (manager, bgm) = makeManager()
        manager.switchToMenuBGM()

        manager.handleInterruptionBegan()
        manager.handleInterruptionEnded(shouldResume: true)

        #expect(bgm.calls == ["start:bgm", "pause", "resume"])
    }

    @Test("割り込み終了で再開不可なら、次のアクティブ化で再開する")
    func resumesOnNextActivationWhenInterruptionSaysNotToResume() {
        let (manager, bgm) = makeManager()
        manager.switchToMenuBGM()
        manager.handleInterruptionBegan()

        manager.handleInterruptionEnded(shouldResume: false)
        #expect(bgm.calls == ["start:bgm", "pause"])

        manager.handleBecomeActive()
        #expect(bgm.calls == ["start:bgm", "pause", "resume"])
    }

    @Test("オーディオセッションは .ambient（消音スイッチに従う）")
    func audioSessionCategoryIsAmbient() {
        #expect(AudioPlayer.sessionCategory == .ambient)
    }
}
