import Foundation
@testable import HiraganaMatchingGame
import Testing

/// 読み上げの呼び出しを記録するだけの fake（実音声はテストで検証できないため）
final class RecordingSpeech: SpeechSpeaking {
    private(set) var calls: [String] = []

    func speakText(_ text: String, slowly: Bool) async {
        calls.append("text:\(text)")
    }

    func speakCharacter(_ character: String, slowly: Bool) async {
        calls.append("character:\(character)")
    }

    func stopSpeaking() {}
    func pauseSpeaking() {}
    func continueSpeaking() {}
    func setEnabled(_ enabled: Bool) {}
    func setSpeechRate(_ rate: Float) {}
    func setVolume(_ newVolume: Float) {}
}

@Suite("音のボタン (#73)")
struct SoundButtonSpeechTests {
    @Test("音のボタンは今のひらがなを読み上げる")
    func soundButtonSpeaksCurrentCharacter() async {
        let speech = RecordingSpeech()
        let manager = AudioManager(isTestMode: true, speech: speech)
        let viewModel = GameViewModel(
            audioService: AudioService.createForTesting(audioManager: manager),
            isTestMode: true
        )
        viewModel.currentHiragana = "か"

        await viewModel.speakCurrentHiragana()

        #expect(speech.calls == ["character:か"])
    }
}
