import Foundation
import SwiftData

struct GameStats {
    let accuracy: Double
    let timeElapsed: TimeInterval
    let averageResponseTime: TimeInterval
}

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
    private let levelProgressionService: LevelProgressionService
    private var currentQuestions: [GameQuestion] = []
    private var currentQuestionIndex: Int = 0
    private var gameTimer: Timer?
    private var timeRemaining: Int = 0
    private var userSettings: UserSettings?
    private let isTestMode: Bool
    
    init(gameLogicService: GameLogicService = GameLogicService(), 
         audioService: AudioService = AudioService(),
         starUnlockService: StarUnlockService = StarUnlockService(),
         levelProgressionService: LevelProgressionService = LevelProgressionService(),
         isTestMode: Bool = false) {
        self.gameLogicService = gameLogicService
        self.audioService = audioService
        self.starUnlockService = starUnlockService
        self.levelProgressionService = levelProgressionService
        self.isTestMode = isTestMode
    }
    
    convenience init(userSettings: UserSettings) {
        let audioService = AudioService(userSettings: userSettings)
        let gameLogicService = GameLogicService(userSettings: userSettings)
        self.init(
            gameLogicService: gameLogicService,
            audioService: audioService,
            starUnlockService: StarUnlockService(),
            levelProgressionService: LevelProgressionService()
        )
        self.userSettings = userSettings
    }
    
    func startNewGame(level: Int) {
        currentLevel = level
        currentQuestion = 1
        score = 0
        isGameCompleted = false
        showFeedback = false
        gameStartTime = Date()
        currentQuestionIndex = 0
        
        // 時間制限の設定（テストモードでは無効）
        if !isTestMode, let settings = userSettings, settings.playtimeLimit > 0 {
            timeRemaining = settings.playtimeLimit * 60 // 分を秒に変換
            startGameTimer()
        }
        
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
            
            // 正解音を再生してから、ひらがな音声を再生
            audioService.playCorrectSound()
            
            // 正解音の再生完了後に選んだ単語をゆっくり読み上げる（テストモードでは無効）
            if !isTestMode {
                Task {
                    // 正解音の再生時間分待機（約0.5秒）
                    try? await Task.sleep(nanoseconds: 600_000_000) // 0.6秒待機
                    
                    // 選んだ画像に対応する日本語の単語を取得
                    if let japaneseWord = HiraganaDataManager.shared.getJapaneseWord(for: imageName) {
                        await audioService.speakText(japaneseWord, slowly: true)
                    } else {
                        // フォールバックとしてひらがな文字を再生
                        await audioService.playAudio(for: currentGameQuestion.hiragana)
                    }
                }
            }
        } else {
            lastAnswerCorrect = false
            
            // 不正解音を再生
            audioService.playIncorrectSound()
        }
        
        // フィードバック表示
        showFeedback = true
        
        // 次の問題インデックスを増加
        currentQuestionIndex += 1
        
        // ゲーム完了判定
        if currentQuestionIndex >= currentQuestions.count {
            completeGame()
        } else {
            // 次の問題に進む
            currentQuestion += 1
            
            // 自動進行設定に基づいて次の問題を表示（テストモードでは即座に実行）
            if isTestMode {
                self.showFeedback = false
                self.loadCurrentQuestion()
            } else {
                let delay = userSettings?.autoAdvance == true ? 2.0 : 1.5
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.showFeedback = false
                    self.loadCurrentQuestion()
                }
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
        guard !currentHiragana.isEmpty else { 
            print("⚠️ playHiraganaSound: currentHiragana is empty")
            return 
        }
        
        print("🔊 Playing sound for: \(currentHiragana)")
        
        Task {
            await audioService.playAudio(for: currentHiragana)
        }
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
        gameTimer?.invalidate()
        gameTimer = nil
        
        let timeTaken = Date().timeIntervalSince(gameStartTime)
        let accuracy = Double(score) / Double(totalQuestions)
        
        // スター獲得計算（GameLogicServiceを使用）
        earnedStars = gameLogicService.calculateStars(
            correctAnswers: score,
            totalQuestions: totalQuestions
        )
        
        print("🎮 Game completed: Level \(currentLevel), Score: \(score)/\(totalQuestions), Stars: \(earnedStars)")
        
        // メインのレベル進行サービスに記録
        levelProgressionService.completeLevel(currentLevel, earnedStars: earnedStars)
        
        // 実績とキャラクター解放用の記録
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
    
    func getGameStats() -> GameStats {
        let accuracy = Double(score) / Double(totalQuestions)
        let timeElapsed = getTimeElapsed()
        let averageResponseTime = timeElapsed / Double(max(currentQuestion - 1, 1))
        
        return GameStats(
            accuracy: accuracy,
            timeElapsed: timeElapsed,
            averageResponseTime: averageResponseTime
        )
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
    
    private func startGameTimer() {
        // テスト環境ではTimerを無効化
        if TestUtils.isTestEnvironment {
            TestUtils.debugPrint("Game timer disabled in test environment")
            return
        }
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                // 時間切れでゲーム終了
                self.completeGame()
            }
        }
    }
    
    func getTimeRemaining() -> Int {
        return timeRemaining
    }
    
    func isTimeLimitEnabled() -> Bool {
        return userSettings?.playtimeLimit ?? 0 > 0
    }
    
    // テスト用：リソースのクリーンアップ
    func cleanup() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    deinit {
        cleanup()
    }
}