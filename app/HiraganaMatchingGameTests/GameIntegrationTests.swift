import Testing
import SwiftData
@testable import HiraganaMatchingGame

@Test("ゲーム統合テスト - フルゲームフロー")
func fullGameFlow() async {
    let viewModel = GameViewModel()
    
    // ゲーム開始
    viewModel.startNewGame(level: 1)
    
    #expect(viewModel.currentLevel == 1)
    #expect(viewModel.currentQuestion == 1)
    #expect(viewModel.score == 0)
    #expect(!viewModel.currentHiragana.isEmpty)
    #expect(viewModel.answerChoices.count == 3)
    
    // 5問プレイ
    for questionNumber in 1...5 {
        #expect(viewModel.currentQuestion == questionNumber)
        #expect(!viewModel.isGameCompleted)
        
        let correctAnswer = viewModel.getCorrectAnswer()
        viewModel.selectAnswer(correctAnswer.imageName)
    }
    
    // ゲーム完了確認
    #expect(viewModel.isGameCompleted == true)
    #expect(viewModel.score == 5)
    #expect(viewModel.calculateStars(for: 5) == 3)
}

@Test("ゲーム統合テスト - 混合正解パターン")
func mixedAnswerPattern() async {
    let viewModel = GameViewModel()
    viewModel.startNewGame(level: 1)
    
    var correctCount = 0
    
    // 1問目：正解
    let correctAnswer1 = viewModel.getCorrectAnswer()
    viewModel.selectAnswer(correctAnswer1.imageName)
    correctCount += 1
    #expect(viewModel.score == correctCount)
    
    // 2問目：不正解
    let wrongAnswer = viewModel.answerChoices.first { $0.imageName != viewModel.getCorrectAnswer().imageName }
    if let wrong = wrongAnswer {
        viewModel.selectAnswer(wrong.imageName)
        #expect(viewModel.score == correctCount)
    }
    
    // 3問目：正解
    let correctAnswer3 = viewModel.getCorrectAnswer()
    viewModel.selectAnswer(correctAnswer3.imageName)
    correctCount += 1
    #expect(viewModel.score == correctCount)
    
    // 4問目：正解
    let correctAnswer4 = viewModel.getCorrectAnswer()
    viewModel.selectAnswer(correctAnswer4.imageName)
    correctCount += 1
    #expect(viewModel.score == correctCount)
    
    // 5問目：正解
    let correctAnswer5 = viewModel.getCorrectAnswer()
    viewModel.selectAnswer(correctAnswer5.imageName)
    correctCount += 1
    #expect(viewModel.score == correctCount)
    
    #expect(viewModel.isGameCompleted == true)
    #expect(viewModel.score == 4)
    #expect(viewModel.calculateStars(for: 4) == 2)
}

@Test("ゲーム統合テスト - サービス統合確認")
func serviceIntegration() async {
    let viewModel = GameViewModel()
    let gameLogic = GameLogicService()
    let audioService = AudioService()
    
    viewModel.startNewGame(level: 1)
    
    let hiragana = viewModel.currentHiragana
    let _ = viewModel.answerChoices
    
    // GameLogicServiceとの統合確認
    let correctAnswer = viewModel.getCorrectAnswer()
    let isCorrect = gameLogic.isCorrectAnswer(hiragana: hiragana, imageName: correctAnswer.imageName)
    #expect(isCorrect == true)
    
    // AudioServiceとの統合確認
    #expect(audioService.isSoundEnabled == true)
    
    // 統計計算の統合確認
    viewModel.selectAnswer(correctAnswer.imageName)
    let progress = viewModel.getCurrentProgress()
    #expect(progress > 0.0)
}

@Test("ゲーム統合テスト - レベル別問題生成")
func levelSpecificQuestions() async {
    let viewModel = GameViewModel()
    let gameLogic = GameLogicService()
    
    // レベル1テスト（あ行のみ）
    viewModel.startNewGame(level: 1)
    let level1Characters = ["あ", "い", "う", "え", "お"]
    #expect(level1Characters.contains(viewModel.currentHiragana))
    
    // レベル2テスト（あ行＋か行）
    viewModel.startNewGame(level: 2)
    let level2Characters = ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ"]
    #expect(level2Characters.contains(viewModel.currentHiragana))
    
    // GameLogicServiceでの問題生成確認
    let questions = gameLogic.generateQuestionsForLevel(1, questionCount: 5)
    #expect(questions.count == 5)
    
    for question in questions {
        #expect(level1Characters.contains(question.hiragana))
        #expect(question.choices.count == 3)
    }
}

@Test("ゲーム統合テスト - エラーハンドリング")
func errorHandling() async {
    let viewModel = GameViewModel()
    
    // 不正なレベルでのゲーム開始
    viewModel.startNewGame(level: 0)
    #expect(viewModel.currentLevel == 0)
    #expect(viewModel.answerChoices.isEmpty)
    
    viewModel.startNewGame(level: 100)
    #expect(viewModel.currentLevel == 100)
    #expect(viewModel.answerChoices.isEmpty)
    
    // 正常なレベルに戻す
    viewModel.startNewGame(level: 1)
    #expect(!viewModel.answerChoices.isEmpty)
}

@Test("ゲーム統合テスト - 進行状況計算")
func progressCalculation() async {
    let viewModel = GameViewModel()
    viewModel.startNewGame(level: 1)
    
    // 初期状態
    #expect(viewModel.getCurrentProgress() == 0.0)
    
    // 1問回答後
    let correctAnswer = viewModel.getCorrectAnswer()
    viewModel.selectAnswer(correctAnswer.imageName)
    let progress1 = viewModel.getCurrentProgress()
    #expect(progress1 > 0.0, "進行状況が更新されていません")
    
    // 最終的なゲーム完了まで進める
    for _ in 2...5 {
        let correct = viewModel.getCorrectAnswer()
        viewModel.selectAnswer(correct.imageName)
    }
    #expect(viewModel.isGameCompleted == true)
}