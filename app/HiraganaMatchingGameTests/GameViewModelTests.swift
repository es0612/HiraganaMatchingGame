@testable import HiraganaMatchingGame
import SwiftData
import Testing

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
    let viewModel = GameViewModel(isTestMode: true) // 実 Audio / asyncAfter をテスト後に残さない
    viewModel.startNewGame(level: 1)
    
    let correctAnswer = viewModel.getCorrectAnswer()
    let initialScore = viewModel.score
    
    viewModel.selectAnswer(correctAnswer.imageName)
    
    #expect(viewModel.score == initialScore + 1)
}

@Test("不正解選択テスト")
func selectIncorrectAnswer() {
    let viewModel = GameViewModel(isTestMode: true) // 実 Audio / asyncAfter をテスト後に残さない
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
    let viewModel = GameViewModel(isTestMode: true)
    viewModel.startNewGame(level: 1)
    
    for _ in 1 ... 5 {
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
    let viewModel = GameViewModel(isTestMode: true) // 実 Audio / asyncAfter をテスト後に残さない
    
    let stars = viewModel.calculateStars(for: score)
    
    #expect(stars == expectedStars)
}

@Test("進捗バーがゲーム完了時に100%になるテスト")
func progressReachesFullOnGameCompletion() {
    let viewModel = GameViewModel(isTestMode: true)
    viewModel.startNewGame(level: 1)

    #expect(viewModel.getCurrentProgress() == 0.0)

    for answered in 1 ... 5 {
        let correctAnswer = viewModel.getCorrectAnswer()
        viewModel.selectAnswer(correctAnswer.imageName)
        #expect(viewModel.getCurrentProgress() == Double(answered) / 5.0)
    }

    #expect(viewModel.isGameCompleted == true)
    #expect(viewModel.getCurrentProgress() == 1.0)
}

@Test("次の問題への進行テスト")
func nextQuestionProgression() {
    let viewModel = GameViewModel(isTestMode: true) // 実 Audio / asyncAfter をテスト後に残さない
    viewModel.startNewGame(level: 1)
    
    let initialQuestion = viewModel.currentQuestion
    let correctAnswer = viewModel.getCorrectAnswer()
    
    viewModel.selectAnswer(correctAnswer.imageName)
    
    #expect(viewModel.currentQuestion == initialQuestion + 1)
}

// MARK: - プレイ時間制限タイマー (#31)

@Test("時間制限タイマー起動中でも、参照を手放した GameViewModel は解放される (#31)")
@MainActor
func gameViewModelDeallocatesWhileTimerIsRunning() async throws {
    let settings = UserSettings()
    settings.playtimeLimit = 600 // テスト中に満了しない長さ

    weak var weakViewModel: GameViewModel?
    do {
        let viewModel = GameViewModel(levelProgressionService: LevelProgressionService(forTesting: true))
        viewModel.updateUserSettings(settings)
        viewModel.startNewGame(level: 1)
        #expect(viewModel.isTimeLimitEnabled())
        weakViewModel = viewModel
    }

    // startNewGame 内の音声プリロード Task が self を短時間保持するため、解放を最大 2 秒待つ
    for _ in 0 ..< 40 where weakViewModel != nil {
        try await Task.sleep(nanoseconds: 50_000_000)
    }
    #expect(weakViewModel == nil, "Timer が GameViewModel を強参照しており、画面破棄後も生き残っている")
}

@Test("時間制限タイマーの tick は残り時間を減らし、0 になった次の tick でゲームを完了する")
func timerTickCountsDownAndCompletesGame() {
    let settings = UserSettings()
    settings.playtimeLimit = 2
    let viewModel = GameViewModel(
        levelProgressionService: LevelProgressionService(forTesting: true),
        isTestMode: true // 実 Timer は起動せず、tick を手で進める
    )
    viewModel.updateUserSettings(settings)
    viewModel.startNewGame(level: 1)

    #expect(viewModel.getTimeRemaining() == 2)
    viewModel.handleTimerTick()
    #expect(viewModel.getTimeRemaining() == 1)
    viewModel.handleTimerTick()
    #expect(viewModel.getTimeRemaining() == 0)
    #expect(viewModel.isGameCompleted == false)
    viewModel.handleTimerTick()
    #expect(viewModel.isGameCompleted == true)
}

/// プレイ中のヘッダーのスターも、ゲーム終了時と同じ難易度別の閾値で出す（#67）
@Test("プレイ中のスターは回答済みの問題で難易度別に計算する", arguments: [
    // 回答 0 問は 0 除算にせず 0
    (GameDifficulty.normal, 0, 0, 0),
    // 簡単 100 / 90 / 80：80% は 1 つ星（普通の基準だと 2 つ星になる）
    (.easy, 4, 5, 1),
    (.easy, 5, 5, 3),
    // 普通 100 / 80 / 60
    (.normal, 4, 5, 2),
    (.normal, 2, 4, 0),
    // 難しい 100 / 75 / 50：50% は 1 つ星（普通の基準だと 0 個になる）
    (.hard, 1, 2, 1),
    (.hard, 3, 4, 2)
])
func currentPotentialStarsUsesDifficulty(difficulty: GameDifficulty, correct: Int, answered: Int, expectedStars: Int) throws {
    let settings = UserSettings()
    settings.difficulty = difficulty
    let viewModel = GameViewModel(
        gameLogicService: GameLogicService(userSettings: settings),
        levelProgressionService: LevelProgressionService(forTesting: true),
        isTestMode: true // 実 Audio / asyncAfter をテスト後に残さない
    )
    // 完了させると進行サービスに記録が残るので、10 問のうち途中まで答える
    viewModel.startNewGame(level: 1, customQuestionCount: 10)

    for index in 0 ..< answered {
        let correctAnswer = viewModel.getCorrectAnswer()
        if index < correct {
            viewModel.selectAnswer(correctAnswer.imageName)
        } else {
            let wrong = try #require(viewModel.answerChoices.first { $0.imageName != correctAnswer.imageName })
            viewModel.selectAnswer(wrong.imageName)
        }
    }

    try #require(viewModel.isGameCompleted == false)
    try #require(viewModel.score == correct)
    #expect(viewModel.currentPotentialStars == expectedStars)
}
