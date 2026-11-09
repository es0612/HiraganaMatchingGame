import AVFoundation
import Foundation
@testable import HiraganaMatchingGame
import Testing

/// 効果音のデータが AVAudioPlayer で読み込めることを確かめる（#83）。
/// ヘッダーのない波形データは `kAudioFileUnsupportedFileTypeError` で失敗し、効果音がひとつも鳴らなかった。
@Suite("効果音の再生データ (#83)")
struct EffectSoundPlaybackTests {
    static let allEffects: [SoundEffect] = [.correct, .incorrect, .levelUp, .button, .achievement]

    @Test("効果音のデータを AVAudioPlayer で読み込める", arguments: allEffects)
    func effectDataIsPlayable(effect: SoundEffect) throws {
        let data = EffectPlayer(isTestMode: true).generateEffectSound(effect)

        let player = try AVAudioPlayer(data: data)

        #expect(player.duration > 0)
    }
}
