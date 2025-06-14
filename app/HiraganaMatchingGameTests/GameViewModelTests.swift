import Testing
import SwiftData
@testable import HiraganaMatchingGame

@Test("GameViewModel初期化テスト")
func gameViewModelInitialization() {
    let viewModel = GameViewModel()
    
    #expect(viewModel.currentLevel == 1)
    #expect(viewModel.currentQuestion == 1)
    #expect(viewModel.score == 0)
    #expect(viewModel.totalQuestions == 5)
    #expect(viewModel.isGameCompleted == false)
    #expect(viewModel.currentHiragana == "")
    #expect(viewModel.answerChoices.isEmpty)
}

@Test("新しいゲーム開始テスト")
func startNewGame() {
    let viewModel = GameViewModel()
    
    viewModel.startNewGame(level: 1)
    
    #expect(viewModel.currentLevel == 1)
    #expect(viewModel.currentQuestion == 1)
    #expect(viewModel.score == 0)
    #expect(viewModel.isGameCompleted == false)
    #expect(!viewModel.currentHiragana.isEmpty)
    #expect(viewModel.answerChoices.count == 3)
}

@Test("正解選択テスト")
func selectCorrectAnswer() {
    let viewModel = GameViewModel()
    viewModel.startNewGame(level: 1)
    
    let correctAnswer = viewModel.getCorrectAnswer()
    let initialScore = viewModel.score
    
    viewModel.selectAnswer(correctAnswer.imageName)
    
    #expect(viewModel.score == initialScore + 1)
}

@Test("不正解選択テスト")
func selectIncorrectAnswer() {
    let viewModel = GameViewModel()
    viewModel.startNewGame(level: 1)
    
    let correctAnswer = viewModel.getCorrectAnswer()
    let wrongAnswer = viewModel.answerChoices.first { $0.imageName != correctAnswer.imageName }
    let initialScore = viewModel.score
    
    if let wrong = wrongAnswer {
        viewModel.selectAnswer(wrong.imageName)
        #expect(viewModel.score == initialScore)
    }
}

@Test("ゲーム完了判定テスト")
func gameCompletionCheck() {
    let viewModel = GameViewModel()
    viewModel.startNewGame(level: 1)
    
    for _ in 1...5 {
        let correctAnswer = viewModel.getCorrectAnswer()
        viewModel.selectAnswer(correctAnswer.imageName)
    }
    
    #expect(viewModel.isGameCompleted == true)
}

@Test("星獲得計算テスト", arguments: [
    (3, 1),
    (4, 2), 
    (5, 3),
    (2, 0),
    (0, 0)
])
func starCalculation(score: Int, expectedStars: Int) {
    let viewModel = GameViewModel()
    
    let stars = viewModel.calculateStars(for: score)
    
    #expect(stars == expectedStars)
}

@Test("次の問題への進行テスト")
func nextQuestionProgression() {
    let viewModel = GameViewModel()
    viewModel.startNewGame(level: 1)
    
    let initialQuestion = viewModel.currentQuestion
    let correctAnswer = viewModel.getCorrectAnswer()
    
    viewModel.selectAnswer(correctAnswer.imageName)
    
    #expect(viewModel.currentQuestion == initialQuestion + 1)
}