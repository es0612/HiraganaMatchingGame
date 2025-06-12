import Testing
@testable import HiraganaMatchingGame

@Test("GameLogicService正解判定テスト", arguments: [
    ("ね", "cat", true),
    ("ね", "dog", false),
    ("か", "crab", true),
    ("か", "rabbit", false),
    ("あ", "ant", true),
    ("あ", "bear", false)
])
func answerValidation(hiragana: String, imageName: String, expected: Bool) {
    let gameLogic = GameLogicService()
    let result = gameLogic.isCorrectAnswer(hiragana: hiragana, imageName: imageName)
    
    #expect(result == expected)
}

@Test("ランダム選択肢生成テスト")
func randomChoicesGeneration() {
    let gameLogic = GameLogicService()
    let choices = gameLogic.generateChoices(for: "ね", count: 4)
    
    #expect(choices.count == 4)
    #expect(choices.contains { $0.character == "ね" })
    
    let uniqueChoices = Set(choices.map { $0.imageName })
    #expect(uniqueChoices.count == 4)
}

@Test("レベル問題生成テスト")
func levelQuestionGeneration() {
    let gameLogic = GameLogicService()
    let questions = gameLogic.generateQuestionsForLevel(1, questionCount: 5)
    
    #expect(questions.count == 5)
    
    let level1Characters = ["あ", "い", "う", "え", "お"]
    for question in questions {
        #expect(level1Characters.contains(question.hiragana))
        #expect(question.choices.count == 3)
    }
}

@Test("スコア計算テスト", arguments: [
    (5, 5, 3),
    (4, 5, 2),
    (3, 5, 1),
    (2, 5, 0),
    (0, 5, 0)
])
func scoreCalculation(correctAnswers: Int, totalQuestions: Int, expectedStars: Int) {
    let gameLogic = GameLogicService()
    let stars = gameLogic.calculateStars(correctAnswers: correctAnswers, totalQuestions: totalQuestions)
    
    #expect(stars == expectedStars)
}

@Test("レベル解放判定テスト")
func levelUnlockCheck() {
    let gameLogic = GameLogicService()
    
    #expect(gameLogic.canUnlockLevel(2, withStars: 0) == false)
    #expect(gameLogic.canUnlockLevel(2, withStars: 1) == true)
    #expect(gameLogic.canUnlockLevel(5, withStars: 10) == true)
    #expect(gameLogic.canUnlockLevel(11, withStars: 30) == false)
}

@Test("ゲーム統計計算テスト")
func gameStatsCalculation() {
    let gameLogic = GameLogicService()
    let stats = gameLogic.calculateGameStats(correctAnswers: 4, totalQuestions: 5, timeTaken: 120)
    
    #expect(stats.accuracy == 0.8)
    #expect(stats.stars == 2)
    #expect(stats.timeTaken == 120)
    #expect(stats.averageTimePerQuestion == 24.0)
}