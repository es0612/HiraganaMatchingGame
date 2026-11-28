import AVFoundation
@testable import HiraganaMatchingGame
import Testing

/// 読み上げの速さと「効果音」の設定 (#127)
/// 実音声はテストで聞けないため、読み上げに使う値（speechRate・isEnabled）を確かめる
@Suite("読み上げの速さと効果音の設定 (#127)")
struct SpeechSettingsTests {
    @Test("倍率 1.0（既定）のとき、読み上げは Apple の既定の速さになる")
    func defaultMultiplierUsesSystemDefaultRate() {
        let speech = SpeechSynthesizer(isTestMode: true)
        let manager = AudioManager(isTestMode: true, speech: speech)

        #expect(manager.playbackSpeed == 1.0)
        #expect(speech.speechRate == AVSpeechUtteranceDefaultSpeechRate)
    }

    @Test("倍率は既定の速さにかけ、最大の速さを超えない")
    func multiplierScalesSystemDefaultRate() {
        let speech = SpeechSynthesizer(isTestMode: true)
        let manager = AudioManager(isTestMode: true, speech: speech)

        manager.setPlaybackSpeed(0.5)
        #expect(speech.speechRate == AVSpeechUtteranceDefaultSpeechRate * 0.5)

        manager.setPlaybackSpeed(2.0)
        #expect(speech.speechRate == min(AVSpeechUtteranceDefaultSpeechRate * 2.0, AVSpeechUtteranceMaximumSpeechRate))
    }

    @Test("読み上げに渡す速さは、ふつう 0.5・ゆっくり 0.35（既定の倍率のとき）")
    func utteranceRateForNormalAndSlow() {
        let speech = SpeechSynthesizer(isTestMode: true)
        _ = AudioManager(isTestMode: true, speech: speech)

        #expect(abs(speech.utteranceRate(slowly: false) - 0.5) < 0.0001)
        #expect(abs(speech.utteranceRate(slowly: true) - 0.35) < 0.0001)
    }

    @Test("効果音を OFF にしても、読み上げは止まらない")
    func soundOffKeepsSpeechEnabled() {
        let speech = SpeechSynthesizer(isTestMode: true)
        let manager = AudioManager(isTestMode: true, speech: speech)

        manager.setSoundEnabled(false)

        #expect(manager.isSoundEnabled == false)
        #expect(speech.isEnabled == true)
    }
}
