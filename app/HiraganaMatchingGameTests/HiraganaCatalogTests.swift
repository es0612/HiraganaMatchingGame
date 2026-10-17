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

    @Test("文字から行を引ける", arguments: [("あ", "あ行"), ("ぬ", "な行"), ("よ", "や行"), ("ん", "わ行")])
    func rowContainingKnownCharacter(character: String, expectedRow: String) {
        #expect(HiraganaCatalog.row(containing: character)?.name == expectedRow)
    }

    @Test("Catalog にない文字は nil", arguments: ["ゐ", "ア", ""])
    func rowContainingUnknownIsNil(character: String) {
        #expect(HiraganaCatalog.row(containing: character) == nil)
    }

    @Test("HiraganaGameService のレベル別文字が Catalog と一致する", arguments: 1 ... 10)
    func gameServiceMatchesCatalog(level: Int) {
        #expect(HiraganaGameService.shared.getCharactersForLevel(level) == HiraganaCatalog.characters(upToLevel: level))
    }

    @Test("HiraganaGameService は範囲外のレベルで空を返す（クランプしない）", arguments: [0, -1, 11, 99])
    func gameServiceOutOfRangeIsEmpty(level: Int) {
        #expect(HiraganaGameService.shared.getCharactersForLevel(level).isEmpty)
        #expect(HiraganaGameService.shared.isValidLevel(level) == false)
    }

    @Test("CharacterUnlockService の行と解放スターが Catalog と一致する")
    func unlockServiceMatchesCatalog() {
        let service = CharacterUnlockService.shared
        let expectedGroups = Dictionary(uniqueKeysWithValues: HiraganaCatalog.rows.map { ($0.name, $0.characters) })
        let expectedStars = Dictionary(uniqueKeysWithValues: HiraganaCatalog.rows.map { ($0.name, $0.requiredStars) })
        #expect(service.getCharacterGroups() == expectedGroups)
        #expect(service.getGroupUnlockRequirements() == expectedStars)
        #expect(service.getGroupUnlockRequirements()["か行"] == 2)
    }
}
