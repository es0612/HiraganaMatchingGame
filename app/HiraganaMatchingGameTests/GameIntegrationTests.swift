@testable import HiraganaMatchingGame
import SwiftData
import Testing

@Test("ゲーム統合テスト - 基本初期化")
func basicGameInitialization() {
    let viewModel = GameViewModel()
    
    // 基本的な初期化確認
    #expect(viewModel.currentLevel == 1)
    #expect(viewModel.currentQuestion == 1)
    #expect(viewModel.score == 0)
    #expect(viewModel.isGameCompleted == false)
}

@Test("ゲーム統合テスト - サービス統合確認")
func serviceIntegration() {
    let viewModel = GameViewModel()
    let gameLogic = GameLogicService()
    let audioService = AudioService.createForTesting()
    
    // サービス統合確認
    #expect(audioService.isSoundEnabled == true)
    
    // 基本的な問題生成確認
    let questions = gameLogic.generateQuestionsForLevel(1, questionCount: 3)
    #expect(questions.count == 3)
    
    for question in questions {
        #expect(!question.hiragana.isEmpty)
        #expect(question.choices.count == 3)
    }
    
    // 正解チェック機能の確認
    if let firstQuestion = questions.first {
        let isCorrect = gameLogic.isCorrectAnswer(
            hiragana: firstQuestion.hiragana,
            imageName: firstQuestion.correctAnswer.imageName
        )
        #expect(isCorrect == true)
    }
}

@Test("ゲーム統合テスト - レベル設定確認")
func levelConfigurationTest() {
    let viewModel = GameViewModel()
    
    // レベル1でゲーム開始
    viewModel.startNewGame(level: 1)
    
    #expect(viewModel.currentLevel == 1)
    #expect(viewModel.currentQuestion == 1)
    #expect(!viewModel.currentHiragana.isEmpty)
    #expect(viewModel.answerChoices.count == 3)
    
    // レベル1のひらがなはあ行のみ
    let level1Characters = ["あ", "い", "う", "え", "お"]
    #expect(level1Characters.contains(viewModel.currentHiragana))
}

@Test("ゲーム統合テスト - エラーハンドリング基本")
func basicErrorHandling() {
    let viewModel = GameViewModel()
    
    // 不正なレベルでのゲーム開始
    viewModel.startNewGame(level: 0)
    #expect(viewModel.currentLevel == 0)
    
    viewModel.startNewGame(level: 100)
    #expect(viewModel.currentLevel == 100)
    
    // 正常なレベルに戻す
    viewModel.startNewGame(level: 1)
    #expect(viewModel.currentLevel == 1)
    #expect(!viewModel.answerChoices.isEmpty)
}
