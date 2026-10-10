@testable import HiraganaMatchingGame
import Testing

@Suite("音声プリロード対象 (#21)")
struct AudioPreloadTests {
    @Test("レベル 6〜10 で、その行までの全文字がプリロード対象になる", arguments: 6 ... 10)
    func levelsSixToTenIncludeAllRows(level: Int) {
        let manager = AudioManager(isTestMode: true)
        let expected = LevelProgressionService(forTesting: true).getLevelConfiguration(level).characters
        #expect(manager.preloadCharacters(forLevel: level) == expected)
    }

    @Test("レベル 10 は 46 文字すべて（ん まで）")
    func levelTenCoversAllHiragana() {
        let manager = AudioManager(isTestMode: true)
        let characters = manager.preloadCharacters(forLevel: 10)
        #expect(characters.count == 46)
        #expect(characters.contains("ん"))
    }
}
