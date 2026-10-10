@testable import HiraganaMatchingGame
import Testing

@Suite("ひらがな行・レベルの単一定義 (#21)")
struct HiraganaCatalogTests {
    @Test("10 行で、解放スターは 0 から 2 刻み")
    func rowsAndStars() {
        #expect(HiraganaCatalog.rows.map(\.name) == ["あ行", "か行", "さ行", "た行", "な行", "は行", "ま行", "や行", "ら行", "わ行"])
        #expect(HiraganaCatalog.rows.map(\.requiredStars) == [0, 2, 4, 6, 8, 10, 12, 14, 16, 18])
        #expect(HiraganaCatalog.totalLevels == 10)
    }

    @Test("現代仮名 46 文字・重複なし・ゐ/ゑ を含まない")
    func allCharactersAreModern46() {
        let all = HiraganaCatalog.allCharacters
        #expect(all.count == 46)
        #expect(Set(all).count == 46)
        #expect(!all.contains("ゐ"))
        #expect(!all.contains("ゑ"))
        #expect(all.first == "あ")
        #expect(all.last == "ん")
    }

    @Test("レベル 1〜10 の文字が LevelProgressionService と順序まで一致する", arguments: 1 ... 10)
    func matchesLevelProgressionService(level: Int) {
        let expected = LevelProgressionService(forTesting: true).getLevelConfiguration(level).characters
        #expect(HiraganaCatalog.characters(upToLevel: level) == expected)
    }

    @Test("範囲外のレベルはクランプする", arguments: [(0, 5), (-1, 5), (11, 46), (99, 46)])
    func outOfRangeLevelsClamp(level: Int, expectedCount: Int) {
        #expect(HiraganaCatalog.characters(upToLevel: level).count == expectedCount)
    }
}
