import AVFoundation
import Foundation
@testable import HiraganaMatchingGame
import Testing

/// 効果音のデータが AVAudioPlayer で読み込めることを確かめる（#83）。
/// ヘッダーのない波形データは `kAudioFileUnsupportedFileTypeError` で失敗し、効果音がひとつも鳴らなかった。
@Suite("効果音の再生データ (#83)")
struct EffectSoundPlaybackTests {
    /// 生成している波形の長さ（秒）。`SoundEffect.duration` とは別（`.button` は enum が 0.2 秒、生成は 0.1 秒）
    static let generatedDurations: [(SoundEffect, TimeInterval)] = [
        (.correct, 0.5),
        (.incorrect, 0.3),
        (.levelUp, 1.0),
        (.button, 0.1),
        (.achievement, 0.8)
    ]

    @Test("効果音のデータを AVAudioPlayer で読み込め、長さが生成した波形と一致する", arguments: generatedDurations)
    func effectDataIsPlayable(effect: SoundEffect, expectedDuration: TimeInterval) throws {
        let data = EffectPlayer(isTestMode: true).generateEffectSound(effect)

        let player = try AVAudioPlayer(data: data)

        #expect(abs(player.duration - expectedDuration) < 0.01)
    }
}
