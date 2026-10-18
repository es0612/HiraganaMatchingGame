@testable import HiraganaMatchingGame
import Testing

@Suite("VoiceOver の読み上げ文 (#34)")
struct AccessibilityTextTests {
    @Test("スターは獲得数と最大数を読む")
    func stars() {
        #expect(AccessibilityText.stars(0) == "スター 0こ（3こ中）")
        #expect(AccessibilityText.stars(2) == "スター 2こ（3こ中）")
        #expect(AccessibilityText.stars(3) == "スター 3こ（3こ中）")
    }

    @Test("解放済みのレベルは番号・見出し・スターを 1 つの文で読む")
    func unlockedLevel() {
        let label = AccessibilityText.levelButton(
            level: 1, title: "はじめのいっぽ", stars: 2, isUnlocked: true, isRecommended: false
        )
        #expect(label == "レベル 1、はじめのいっぽ、スター 2こ（3こ中）")
    }

    @Test("おすすめのレベルは末尾に「おすすめ」を付ける")
    func recommendedLevel() {
        let label = AccessibilityText.levelButton(
            level: 3, title: "さ行", stars: 0, isUnlocked: true, isRecommended: true
        )
        #expect(label == "レベル 3、さ行、スター 0こ（3こ中）、おすすめ")
    }

    @Test("ロック中のレベルはスターの代わりに「ロック中」と読み、おすすめは付けない")
    func lockedLevel() {
        let label = AccessibilityText.levelButton(
            level: 4, title: "た行", stars: 0, isUnlocked: false, isRecommended: true
        )
        #expect(label == "レベル 4、た行、ロック中")
    }

    @Test("答えの選択肢は絵の読みで読む")
    func answerChoice() {
        #expect(AccessibilityText.answerChoice(reading: "あり") == "ありの絵")
    }
}
