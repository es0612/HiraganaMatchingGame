import Foundation
import SwiftData

@Observable
class GameViewModel {
    var currentLevel: Int = 1
    var currentQuestion: Int = 1
    var score: Int = 0
    var totalQuestions: Int = 5
    var isGameCompleted: Bool = false
    var currentHiragana: String = ""
    var answerChoices: [HiraganaItem] = []
    var gameStartTime: Date = Date()
    var showFeedback: Bool = false
    var lastAnswerCorrect: Bool = false
    var earnedStars: Int = 0
    
    private let gameLogicService: GameLogicService
    private let audioService: AudioService
    private let starUnlockService: StarUnlockService
    private var currentQuestions: [GameQuestion] = []
    private var currentQuestionIndex: Int = 0
    
    init(gameLogicService: GameLogicService = GameLogicService(), 
         audioService: AudioService = AudioService(),
         starUnlockService: StarUnlockService = StarUnlockService()) {
        self.gameLogicService = gameLogicService
        self.audioService = audioService
        self.starUnlockService = starUnlockService
    }
    
    func startNewGame(level: Int) {
        currentLevel = level
        currentQuestion = 1
        score = 0
        isGameCompleted = false
        showFeedback = false
        gameStartTime = Date()
        currentQuestionIndex = 0
        
        // GameLogicServiceを使って問題を生成
        currentQuestions = gameLogicService.generateQuestionsForLevel(level, questionCount: totalQuestions)
        
        if !currentQuestions.isEmpty {
            loadCurrentQuestion()
            
            // 音声を事前読み込み
            Task {
                await audioService.preloadAudioForLevel(level)
            }
        }
    }
    
    func selectAnswer(_ imageName: String) {
        guard currentQuestionIndex < currentQuestions.count else { return }
        
        let currentGameQuestion = currentQuestions[currentQuestionIndex]
        let isCorrect = gameLogicService.isCorrectAnswer(hiragana: currentGameQuestion.hiragana, imageName: imageName)
        
        // 正解判定
        if isCorrect {
            score += 1
            lastAnswerCorrect = true
            
            // 正解時の音声再生
            Task {
                await audioService.playAudio(for: currentGameQuestion.hiragana)
            }
        } else {
            lastAnswerCorrect = false
        }
        
        // フィードバック表示
        showFeedback = true
        
        // 次の問題への進行
        currentQuestion += 1
        currentQuestionIndex += 1
        
        if currentQuestion > totalQuestions {
            completeGame()
        } else {
            // 短い遅延後に次の問題を表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showFeedback = false
                self.loadCurrentQuestion()
            }
        }
    }
    
    func getCorrectAnswer() -> HiraganaItem {
        guard currentQuestionIndex < currentQuestions.count else {
            return HiraganaItem(character: "", imageName: "", category: "")
        }
        return currentQuestions[currentQuestionIndex].correctAnswer
    }
    
    func calculateStars(for score: Int) -> Int {
        return gameLogicService.calculateStars(correctAnswers: score, totalQuestions: totalQuestions)
    }
    
    func resetGame() {
        currentLevel = 1
        currentQuestion = 1
        score = 0
        isGameCompleted = false
        currentHiragana = ""
        answerChoices = []
        showFeedback = false
        earnedStars = 0
        currentQuestions = []
        currentQuestionIndex = 0
    }
    
    func playHiraganaSound() {
        guard !currentHiragana.isEmpty else { return }
        
        Task {
            await audioService.playAudio(for: currentHiragana)
        }
    }
    
    func getGameStats() -> GameStats {
        let timeTaken = Date().timeIntervalSince(gameStartTime)
        return gameLogicService.calculateGameStats(
            correctAnswers: score,
            totalQuestions: totalQuestions,
            timeTaken: timeTaken
        )
    }
    
    func getHint() -> String {
        return gameLogicService.generateHint(for: currentHiragana)
    }
    
    func canUnlockNextLevel(withTotalStars totalStars: Int) -> Bool {
        let nextLevel = currentLevel + 1
        return gameLogicService.canUnlockLevel(nextLevel, withStars: totalStars)
    }
    
    private func loadCurrentQuestion() {
        guard currentQuestionIndex < currentQuestions.count else { return }
        
        let question = currentQuestions[currentQuestionIndex]
        currentHiragana = question.hiragana
        answerChoices = question.choices
    }
    
    private func completeGame() {
        isGameCompleted = true
        let timeTaken = Date().timeIntervalSince(gameStartTime)
        let accuracy = Double(score) / Double(totalQuestions)
        
        // スター獲得計算
        earnedStars = starUnlockService.calculateStars(
            correctAnswers: score,
            totalQuestions: totalQuestions,
            timeTaken: timeTaken
        )
        
        // レベル完了記録
        starUnlockService.recordLevelCompletion(
            level: currentLevel,
            stars: earnedStars,
            accuracy: accuracy,
            time: timeTaken
        )
        
        // ゲーム完了時の音声停止
        audioService.stopAllAudio()
    }
    
    func getCurrentProgress() -> Double {
        return Double(currentQuestion - 1) / Double(totalQuestions)
    }
    
    func getScorePercentage() -> Double {
        return Double(score) / Double(totalQuestions)
    }
    
    func getTimeElapsed() -> TimeInterval {
        return Date().timeIntervalSince(gameStartTime)
    }
    
    func skipQuestion() {
        // ヒント機能として、問題をスキップ
        currentQuestion += 1
        currentQuestionIndex += 1
        
        if currentQuestion > totalQuestions {
            completeGame()
        } else {
            loadCurrentQuestion()
        }
    }
}