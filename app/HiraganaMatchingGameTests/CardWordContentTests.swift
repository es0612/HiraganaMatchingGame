@testable import HiraganaMatchingGame
import Testing

@Suite("カードの単語と問題の文字 (#72)")
struct CardWordContentTests {
    private let items = HiraganaItemRepository.shared.getAllHiraganaData()

    @Test("どのカードも、ラベルの単語に問題の文字が入っている")
    func everyCardWordContainsItsCharacter() {
        let mismatches = items.compactMap { item -> String? in
            let word = WordMappingRepository.shared.getJapaneseWord(for: item.imageName) ?? ""
            return word.contains(item.character) ? nil : "\(item.character):\(item.imageName)=\(word)"
        }
        #expect(mismatches.isEmpty, "\(mismatches)")
    }

    @Test("「を」は助詞として、今の書き方の文で出す")
    func woCardsUseParticlePhrases() {
        let words = items
            .filter { $0.character == "を" }
            .compactMap { WordMappingRepository.shared.getJapaneseWord(for: $0.imageName) }
        #expect(words == ["ほんを よむ", "えを かく"])
    }

    @Test("「を」のカードには絵文字がある")
    func woCardsHaveEmoji() {
        let emojis = items
            .filter { $0.character == "を" }
            .map { EmojiRepository.shared.getEmojiForImageName($0.imageName) }
        #expect(emojis == ["📖", "🎨"])
    }

    @Test("「を」のヒントは、助詞の文を例に出す")
    func woHintUsesParticlePhrase() {
        let hint = GameLogicService().generateHint(for: "を")
        #expect(hint.contains("ほんを よむ"))
        #expect(!hint.contains("をとこ"))
        #expect(!hint.contains("つなぐ"))
    }
}
