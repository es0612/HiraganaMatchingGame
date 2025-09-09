@testable import HiraganaMatchingGame
import Testing

@Test("HiraganaGameServiceレベル管理テスト")
func hiraganaGameServiceLevelManagement() {
    let service = HiraganaGameService.shared
    
    // レベル設定取得テスト
    let configuration = service.getLevelConfiguration()
    #expect(configuration.count == 10)
    #expect(configuration[1]?.count == 5) // あいうえお
    #expect(configuration[2]?.count == 10) // あいうえお + かきくけこ
    #expect(configuration[10]?.count == 47) // 全ひらがな
    
    // レベル別文字取得テスト
    let level1Characters = service.getCharactersForLevel(1)
    #expect(level1Characters == ["あ", "い", "う", "え", "お"])
    
    let level2Characters = service.getCharactersForLevel(2)
    #expect(level2Characters.count == 10)
    #expect(level2Characters.contains("あ"))
    #expect(level2Characters.contains("か"))
    
    // 無効なレベルテスト
    let invalidLevel = service.getCharactersForLevel(0)
    #expect(invalidLevel.isEmpty)
    
    let invalidLevel2 = service.getCharactersForLevel(11)
    #expect(invalidLevel2.isEmpty)
}

@Test("HiraganaGameServiceレベル検証テスト")
func hiraganaGameServiceLevelValidation() {
    let service = HiraganaGameService.shared
    
    // 有効なレベル
    #expect(service.isValidLevel(1) == true)
    #expect(service.isValidLevel(5) == true)
    #expect(service.isValidLevel(10) == true)
    
    // 無効なレベル
    #expect(service.isValidLevel(0) == false)
    #expect(service.isValidLevel(11) == false)
    #expect(service.isValidLevel(-1) == false)
    
    // 最大レベル取得
    #expect(service.getMaxLevel() == 10)
}

@Test("HiraganaGameService質問生成テスト")
func hiraganaGameServiceQuestionGeneration() {
    let service = HiraganaGameService.shared
    
    // ランダム選択肢生成テスト
    let choices = service.getRandomChoices(for: "あ", count: 3)
    #expect(choices.count == 3)
    
    // 正解が含まれていることを確認
    let correctAnswers = choices.filter { $0.character == "あ" }
    #expect(correctAnswers.count == 1)
    
    // 質問バリエーション取得テスト
    let variations = service.getQuestionVariations(for: "あ")
    #expect(variations.count >= 3)
    #expect(variations.allSatisfy { $0.character == "あ" })
}

@Test("HiraganaGameServiceゲーム進行ロジックテスト")
func hiraganaGameServiceGameProgressionLogic() {
    let service = HiraganaGameService.shared
    
    // 次レベル解放判定テスト
    #expect(service.shouldUnlockNextLevel(currentLevel: 1, score: 8, totalQuestions: 10) == true) // 80%
    #expect(service.shouldUnlockNextLevel(currentLevel: 1, score: 6, totalQuestions: 10) == false) // 60%
    #expect(service.shouldUnlockNextLevel(currentLevel: 10, score: 10, totalQuestions: 10) == false) // 最終レベル
    
    // 星の計算テスト
    #expect(service.calculateStarsEarned(score: 9, totalQuestions: 10) == 3) // 90%
    #expect(service.calculateStarsEarned(score: 8, totalQuestions: 10) == 2) // 80%
    #expect(service.calculateStarsEarned(score: 6, totalQuestions: 10) == 2) // 60%
    #expect(service.calculateStarsEarned(score: 5, totalQuestions: 10) == 1) // 50%
    #expect(service.calculateStarsEarned(score: 4, totalQuestions: 10) == 0) // 40%
    
    // 優秀なパフォーマンス判定テスト
    #expect(service.isExcellentPerformance(score: 9, totalQuestions: 10) == true) // 90%
    #expect(service.isExcellentPerformance(score: 8, totalQuestions: 10) == false) // 80%
}

@Test("HiraganaGameServiceデータアクセステスト")
func hiraganaGameServiceDataAccess() {
    let service = HiraganaGameService.shared
    
    // 全データ取得テスト
    let allData = service.getAllHiraganaData()
    #expect(allData.count > 400)
    
    // 特定アイテム取得テスト
    let aItem = service.getItem(for: "あ")
    #expect(aItem?.character == "あ")
    
    // 全文字取得テスト
    let characters = service.getAllCharacters()
    #expect(characters.contains("あ"))
    #expect(characters.contains("ん"))
    
    // 読み取得テスト
    #expect(service.getReadingForCharacter("あ") == "あり")
    #expect(service.getReadingForCharacter("い") == "いぬ")
}

@Test("HiraganaGameService単語・絵文字マッピングテスト")
func hiraganaGameServiceWordEmojiMapping() {
    let service = HiraganaGameService.shared
    
    // 日本語単語取得テスト
    #expect(service.getJapaneseWord(for: "ant") == "ありさん")
    #expect(service.getJapaneseWord(for: "dog") == "いぬ")
    #expect(service.getJapaneseWord(for: "cat") == "ねこ")
    #expect(service.getJapaneseWord(for: "nonexistent") == nil)
    
    // 絵文字取得テスト
    #expect(service.getEmojiForImageName("ant") == "🐜")
    #expect(service.getEmojiForImageName("dog") == "🐶")
    #expect(service.getEmojiForImageName("cat") == "🐱")
    #expect(service.getEmojiForImageName("nonexistent") == "❓")
}

@Test("HiraganaGameService難易度評価テスト")
func hiraganaGameServiceDifficultyRating() {
    let service = HiraganaGameService.shared
    
    // レベル別難易度テスト
    #expect(service.getDifficultyRating(for: 1) == 1) // Very Easy
    #expect(service.getDifficultyRating(for: 2) == 1) // Very Easy
    #expect(service.getDifficultyRating(for: 3) == 2) // Easy
    #expect(service.getDifficultyRating(for: 4) == 2) // Easy
    #expect(service.getDifficultyRating(for: 5) == 3) // Medium
    #expect(service.getDifficultyRating(for: 6) == 3) // Medium
    #expect(service.getDifficultyRating(for: 7) == 4) // Hard
    #expect(service.getDifficultyRating(for: 8) == 4) // Hard
    #expect(service.getDifficultyRating(for: 9) == 5) // Very Hard
    #expect(service.getDifficultyRating(for: 10) == 5) // Very Hard
    
    // 無効なレベルは1を返す
    #expect(service.getDifficultyRating(for: 0) == 1)
    #expect(service.getDifficultyRating(for: 11) == 1)
}

@Test("HiraganaGameServiceランダム文字取得テスト")
func hiraganaGameServiceRandomCharacterRetrieval() {
    let service = HiraganaGameService.shared
    
    // レベル1のランダム文字
    let level1Char = service.getRandomCharacterForLevel(1)
    #expect(level1Char != nil)
    #expect(["あ", "い", "う", "え", "お"].contains(level1Char!))
    
    // レベル2のランダム文字
    let level2Char = service.getRandomCharacterForLevel(2)
    #expect(level2Char != nil)
    let level2Characters = service.getCharactersForLevel(2)
    #expect(level2Characters.contains(level2Char!))
    
    // 無効なレベル
    let invalidChar = service.getRandomCharacterForLevel(0)
    #expect(invalidChar == nil)
}

@Test("HiraganaGameServiceシングルトンテスト")
func hiraganaGameServiceSingleton() {
    let service1 = HiraganaGameService.shared
    let service2 = HiraganaGameService.shared
    
    // 同じインスタンスであることを確認
    #expect(service1 === service2)
}

@Test("HiraganaGameService特定正解アイテム選択肢生成テスト")
func hiraganaGameServiceSpecificCorrectAnswerChoices() {
    let service = HiraganaGameService.shared
    
    // 特定のアイテムを正解とする選択肢生成
    let specificItem = service.getItem(for: "あ")!
    let choices = service.getRandomChoicesWithCorrectAnswer(specificItem, count: 4)
    
    #expect(choices.count == 4)
    #expect(choices.contains(specificItem))
    
    // 正解以外のアイテム数確認
    let wrongAnswers = choices.filter { $0.character != "あ" }
    #expect(wrongAnswers.count == 3)
}
