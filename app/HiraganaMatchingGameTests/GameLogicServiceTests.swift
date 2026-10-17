@testable import HiraganaMatchingGame
import Testing

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

@Test("難易度別のスター基準：閾値ちょうどと、閾値の間の正解率 (#57)", arguments: [
    // 普通 100 / 80 / 60
    (GameDifficulty.normal, 199, 200, 2), // 99.5%
    (.normal, 160, 200, 2), // 80%
    (.normal, 159, 200, 1), // 79.5%
    (.normal, 120, 200, 1), // 60%
    (.normal, 119, 200, 0), // 59.5%
    // 簡単 100 / 90 / 80
    (.easy, 199, 200, 2),
    (.easy, 180, 200, 2), // 90%
    (.easy, 179, 200, 1), // 89.5%
    (.easy, 160, 200, 1), // 80%
    (.easy, 159, 200, 0),
    // 難しい 100 / 75 / 50
    (.hard, 199, 200, 2),
    (.hard, 150, 200, 2), // 75%
    (.hard, 149, 200, 1), // 74.5%
    (.hard, 100, 200, 1), // 50%
    (.hard, 99, 200, 0)
])
func starThresholdsByDifficulty(difficulty: GameDifficulty, correctAnswers: Int, totalQuestions: Int, expectedStars: Int) {
    let settings = UserSettings()
    settings.difficulty = difficulty
    let gameLogic = GameLogicService(userSettings: settings)

    #expect(gameLogic.calculateStars(correctAnswers: correctAnswers, totalQuestions: totalQuestions) == expectedStars)
}

// レベル解放判定テストは削除：LevelProgressionServiceに統一されました

@Test("ゲーム統計計算テスト")
func gameStatsCalculation() {
    let gameLogic = GameLogicService()
    let stats = gameLogic.calculateGameStats(correctAnswers: 4, totalQuestions: 5, timeTaken: 120)
    
    #expect(stats.accuracy == 0.8)
    #expect(stats.timeElapsed == 120)
    #expect(stats.averageResponseTime == 24.0)
}
