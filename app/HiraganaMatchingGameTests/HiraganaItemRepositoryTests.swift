@testable import HiraganaMatchingGame
import Testing

@Test("HiraganaItemRepository基本データ取得テスト")
func hiraganaItemRepositoryBasicDataRetrieval() {
    let repository = HiraganaItemRepository.shared
    
    // 全ひらがなデータ取得テスト
    let allData = repository.getAllHiraganaData()
    #expect(allData.count > 150) // 大量のアイテムがあることを確認（2026-09 時点で 180 件強）
    
    // 全文字取得テスト
    let characters = repository.getAllCharacters()
    #expect(characters.contains("あ"))
    #expect(characters.contains("か"))
    #expect(characters.contains("ん"))
}

@Test("HiraganaItemRepositoryレベル別取得テスト")
func hiraganaItemRepositoryLevelBasedRetrieval() {
    let repository = HiraganaItemRepository.shared
    
    // レベル1: あいうえお
    let level1Items = repository.getHiraganaForLevel(1)
    #expect(!level1Items.isEmpty)
    #expect(level1Items.allSatisfy { ["あ", "い", "う", "え", "お"].contains($0.character) })
    
    // レベル2: あいうえお + かきくけこ
    let level2Items = repository.getHiraganaForLevel(2)
    let level2Characters = Set(level2Items.map { $0.character })
    #expect(level2Characters.contains("あ"))
    #expect(level2Characters.contains("か"))
    #expect(level2Items.count > level1Items.count)
    
    // レベル10: 全文字
    let level10Items = repository.getHiraganaForLevel(10)
    let level10Characters = Set(level10Items.map { $0.character })
    #expect(level10Characters.contains("わ"))
    #expect(level10Characters.contains("ん"))
    #expect(level10Items.count > level2Items.count)
    
    // 無効なレベル
    let invalidLevel = repository.getHiraganaForLevel(0)
    #expect(invalidLevel.isEmpty)
    
    let invalidLevel2 = repository.getHiraganaForLevel(11)
    #expect(invalidLevel2.isEmpty)
}

@Test("HiraganaItemRepository特定文字取得テスト")
func hiraganaItemRepositorySpecificCharacterRetrieval() {
    let repository = HiraganaItemRepository.shared
    
    // 特定文字のアイテム取得
    let aItem = repository.getItem(for: "あ")
    #expect(aItem != nil)
    #expect(aItem?.character == "あ")
    
    let dogItem = repository.getItem(for: "い")
    #expect(dogItem != nil)
    #expect(dogItem?.character == "い")
    
    // 存在しない文字
    let nonExistentItem = repository.getItem(for: "ぁ")
    #expect(nonExistentItem == nil)
}

@Test("HiraganaItemRepository質問バリエーション取得テスト")
func hiraganaItemRepositoryQuestionVariations() {
    let repository = HiraganaItemRepository.shared
    
    // 「あ」の質問バリエーション
    let aVariations = repository.getQuestionVariations(for: "あ")
    #expect(aVariations.count >= 3) // 複数のバリエーションがあることを確認
    #expect(aVariations.allSatisfy { $0.character == "あ" })
    
    // 異なる画像名とカテゴリを持つことを確認
    let imageNames = Set(aVariations.map { $0.imageName })
    #expect(imageNames.count > 1)
}

@Test("HiraganaItemRepositoryランダム選択肢生成テスト")
func hiraganaItemRepositoryRandomChoices() {
    let repository = HiraganaItemRepository.shared
    
    // 基本的なランダム選択肢生成
    let choices = repository.getRandomChoices(for: "あ", count: 3)
    #expect(choices.count == 3)
    
    // 正解が含まれていることを確認
    let correctAnswers = choices.filter { $0.character == "あ" }
    #expect(correctAnswers.count == 1)
    
    // 不正解が含まれていることを確認
    let wrongAnswers = choices.filter { $0.character != "あ" }
    #expect(wrongAnswers.count == 2)
    
    // 特定の正解アイテムでのテスト
    let specificItem = repository.getItem(for: "い")!
    let specificChoices = repository.getRandomChoicesWithCorrectAnswer(specificItem, count: 4)
    #expect(specificChoices.count == 4)
    #expect(specificChoices.contains(specificItem))
}

@Test("HiraganaItemRepository読み取得テスト")
func hiraganaItemRepositoryReadingRetrieval() {
    let repository = HiraganaItemRepository.shared
    
    // 基本的な読み取得
    #expect(repository.getReadingForCharacter("あ") == "あり")
    #expect(repository.getReadingForCharacter("い") == "いぬ")
    #expect(repository.getReadingForCharacter("ね") == "ねこ")
    #expect(repository.getReadingForCharacter("り") == "りんご")
    
    // 存在しない文字（デフォルト値を返す）
    #expect(repository.getReadingForCharacter("ぁ") == "ぁ")
}

@Test("HiraganaItemRepositoryシングルトンテスト")
func hiraganaItemRepositorySingleton() {
    let repository1 = HiraganaItemRepository.shared
    let repository2 = HiraganaItemRepository.shared
    
    // 同じインスタンスであることを確認
    #expect(repository1 === repository2)
}

@Test("HiraganaItemRepositoryアイテム構造テスト")
func hiraganaItemRepositoryItemStructure() {
    let repository = HiraganaItemRepository.shared
    let item = repository.getItem(for: "あ")!
    
    // HiraganaItemの基本構造テスト
    #expect(!item.id.uuidString.isEmpty)
    #expect(item.character == "あ")
    #expect(!item.imageName.isEmpty)
    #expect(!item.category.isEmpty)
    #expect(item.soundFileName.hasSuffix(".mp3"))
    #expect(item.soundFileName.hasPrefix("あ"))
}
