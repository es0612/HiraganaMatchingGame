@testable import HiraganaMatchingGame
import Testing

/// まちがいの選択肢（ダミー）に、正解と見分けられないカードを出さない (#119)。
///
/// `count` を全カードより大きくして呼ぶと、ダミーの候補が全部返る。乱数に依存せず総当たりで確かめられる。
@Suite("正解と見分けられないダミーを出さない (#119)")
struct ConfusableDistractorTests {
    private let repository = HiraganaItemRepository.shared
    private let allCount = 1_000

    private func word(_ item: HiraganaItem) -> String {
        WordMappingRepository.shared.getJapaneseWord(for: item.imageName) ?? ""
    }

    private func emoji(_ item: HiraganaItem) -> String {
        EmojiRepository.shared.getEmojiForImageName(item.imageName)
    }

    /// 方式 (a)（PO 判断 2026-11-22）: 始まる音／「ん」「を」は含む／同じ絵文字
    private func confusableReason(_ candidate: HiraganaItem, for correct: HiraganaItem) -> String? {
        let character = correct.character
        let candidateWord = word(candidate)
        if candidateWord.hasPrefix(character) {
            return "「\(candidateWord)」は「\(character)」で始まる"
        }
        if ["ん", "を"].contains(character), candidateWord.contains(character) {
            return "「\(candidateWord)」は「\(character)」を含む"
        }
        if emoji(candidate) == emoji(correct) {
            return "「\(candidateWord)」は正解と同じ絵文字 \(emoji(correct))"
        }
        return nil
    }

    /// 正解を指定したときに出うるダミーを全部返す
    private func allDistractors(withCorrect correct: HiraganaItem) -> [HiraganaItem] {
        repository.getRandomChoicesWithCorrectAnswer(correct, count: allCount)
            .filter { $0.id != correct.id }
    }

    private func correctItem(_ character: String) throws -> HiraganaItem {
        try #require(repository.getItem(for: character))
    }

    private func imageNames(_ items: [HiraganaItem]) -> Set<String> {
        Set(items.map(\.imageName))
    }

    @Test("どのカードにも絵文字がある（未登録どうしは ❓ で一致し、ダミーから黙って外れるため）")
    func everyCardHasEmoji() {
        let missing = repository.getAllHiraganaData()
            .filter { !EmojiRepository.shared.hasEmojiMapping(for: $0.imageName) }
            .map(\.imageName)
        #expect(missing.isEmpty, "\(missing)")
    }

    @Test("「ん」の問題に、「ん」を含む単語（きりん・りんご）を出さない")
    func nQuestionExcludesWordsContainingN() throws {
        let names = try imageNames(allDistractors(withCorrect: correctItem("ん")))
        #expect(!names.contains("giraffe"))
        #expect(!names.contains("apple"))
        #expect(names.contains("dog"))
    }

    @Test("問題の文字で始まる、ほかの文字のカードを出さない（あ→あんてな、え→えんじん・えを かく、ほ→ほんを よむ）")
    func excludesWordsStartingWithQuestionCharacter() throws {
        #expect(try !imageNames(allDistractors(withCorrect: correctItem("あ"))).contains("antenna"))
        let eNames = try imageNames(allDistractors(withCorrect: correctItem("え")))
        #expect(!eNames.contains("engine"))
        #expect(!eNames.contains("draw_picture"))
        #expect(try !imageNames(allDistractors(withCorrect: correctItem("ほ"))).contains("read_book"))
    }

    @Test("正解と同じ絵文字のカードを出さない（よる/つき 🌙、れいぞうこ/こおり 🧊、ほんを よむ/ほん 📖）")
    func excludesSameEmoji() throws {
        #expect(try !imageNames(allDistractors(withCorrect: correctItem("よ"))).contains("moon"))
        #expect(try !imageNames(allDistractors(withCorrect: correctItem("れ"))).contains("ice"))
        #expect(try !imageNames(allDistractors(withCorrect: correctItem("を"))).contains("book"))
    }

    @Test("「ん」「を」以外では、途中に問題の文字を含むだけのカードは除かない（か→おかあさん）")
    func keepsWordsContainingCharacterInTheMiddle() throws {
        #expect(try imageNames(allDistractors(withCorrect: correctItem("か"))).contains("mother"))
    }

    @Test("46 文字すべてで、正解を指定したダミーに紛らわしいカードがなく、難しい（3 枚）に足りる")
    func everyCharacterWithCorrectAnswer() throws {
        #expect(repository.getAllCharacters().count == 46)
        for character in repository.getAllCharacters() {
            let correct = try correctItem(character)
            let distractors = allDistractors(withCorrect: correct)
            let violations = distractors.compactMap { confusableReason($0, for: correct) }
            #expect(violations.isEmpty, "\(character): \(violations)")
            #expect(distractors.count >= 3, "\(character): \(distractors.count) 枚")
        }
    }

    @Test("46 文字すべてで、文字だけを指定したダミーにも紛らわしいカードがない")
    func everyCharacterWithCharacterOnly() throws {
        #expect(repository.getAllCharacters().count == 46)
        for character in repository.getAllCharacters() {
            let choices = repository.getRandomChoices(for: character, count: allCount)
            let correct = try correctItem(character)
            #expect(choices.filter { $0.character == character }.count == 1, "\(character)")
            let violations = choices
                .filter { $0.character != character }
                .compactMap { confusableReason($0, for: correct) }
            #expect(violations.isEmpty, "\(character): \(violations)")
        }
    }
}
