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
    var gameStartTime = Date()
    var showFeedback: Bool = false
    var lastAnswerCorrect: Bool = false
    var earnedStars: Int = 0
    var isProcessingAnswer: Bool = false
    /// 間違えたときに見せる正解の絵（imageName）。次の回答で消える（#82）
    var revealedAnswer: String?
    /// 間違えたときに選んだ絵（imageName）
    var selectedAnswer: String?
    
    private let gameLogicService: GameLogicService
    let audioService: AudioService
    private let starUnlockService: StarUnlockService
    private let levelProgressionService: LevelProgressionService
    private var currentQuestions: [GameQuestion] = []
    private var currentQuestionIndex: Int = 0
    private var gameTimer: Timer?
    private var timeRemaining: Int = 0
    private var userSettings: UserSettings?
    private let isTestMode: Bool
    /// 間違えたときの「正解を読み上げてから次へ」。画面を離れたら止める
    private var feedbackTask: Task<Void, Never>?
    
    init(gameLogicService: GameLogicService = GameLogicService(),
         audioService: AudioService = AudioService.createForTesting(),
         starUnlockService: StarUnlockService? = nil,
         levelProgressionService: LevelProgressionService = LevelProgressionService(),
         isTestMode: Bool = false) {
        self.gameLogicService = gameLogicService
        self.audioService = audioService
        // 合計スターの供給元を LevelProgressionService に固定する (#19)
        self.starUnlockService = starUnlockService ?? StarUnlockService(levelProgressionService: levelProgressionService)
        self.levelProgressionService = levelProgressionService
        self.isTestMode = isTestMode
    }
    
    convenience init(userSettings: UserSettings) {
        let audioService = AudioService.createWithSettings(userSettings, startBGM: false)
        let gameLogicService = GameLogicService(userSettings: userSettings)
        self.init(
            gameLogicService: gameLogicService,
            audioService: audioService,
            levelProgressionService: LevelProgressionService()
        )
        self.userSettings = userSettings
    }
    
    func startNewGame(level: Int, customQuestionCount: Int? = nil) {
        currentLevel = level
        currentQuestion = 1
        score = 0
        isGameCompleted = false
        showFeedback = false
        gameStartTime = Date()
        currentQuestionIndex = 0
        cancelFeedbackTask()
        revealedAnswer = nil
        selectedAnswer = nil
        
        // 設定から問題数を取得（カスタム値がある場合はそちらを優先）
        if let customCount = customQuestionCount {
            totalQuestions = customCount
        } else if let settings = userSettings {
            totalQuestions = settings.questionsPerSession
        } else {
            totalQuestions = 5 // デフォルト値
        }
        
        // 時間制限の設定（テストモードでは残り時間だけ設定し、実 Timer は起動しない）
        if let settings = userSettings, settings.playtimeLimit > 0 {
            timeRemaining = settings.playtimeLimit // 既に秒単位
            if !isTestMode {
                startGameTimer()
            }
        }
        
        // GameLogicServiceを使って問題を生成
        currentQuestions = gameLogicService.generateQuestionsForLevel(level, questionCount: totalQuestions)
        
        if !currentQuestions.isEmpty {
            loadCurrentQuestion()
            
            // ゲームプレイ用BGMに切り替え
            audioService.switchToGameplayBGM()
            
            // 音声を事前読み込み
            Task {
                await audioService.preloadAudioForLevel(level)
            }
        }
    }
    
    func selectAnswer(_ imageName: String) {
        guard currentQuestionIndex < currentQuestions.count else { return }
        guard !isProcessingAnswer else { return } // Prevent rapid clicking
        
        isProcessingAnswer = true
        revealedAnswer = nil
        selectedAnswer = nil
        
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
                    // 正解音の再生時間分待機
                    try? await Task.sleep(nanoseconds: AppConstants.Timing.correctSoundDelay)
                    
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
            // 正解の絵と選んだ絵を覚えて、選択肢に印を付ける（#82）
            revealedAnswer = currentGameQuestion.correctAnswer.imageName
            selectedAnswer = imageName
            
            // 不正解音を再生
            audioService.playIncorrectSound()
        }
        
        // フィードバック表示
        showFeedback = true
        
        // 次の問題インデックスを増加
        currentQuestionIndex += 1
        let isLastQuestion = currentQuestionIndex >= currentQuestions.count
        if !isLastQuestion {
            currentQuestion += 1
        }
        
        scheduleNextStep(afterCorrectAnswer: isCorrect, isLastQuestion: isLastQuestion)
    }
    
    func getCorrectAnswer() -> HiraganaItem {
        guard currentQuestionIndex < currentQuestions.count else {
            return HiraganaItem(character: "", imageName: "", category: "")
        }
        return currentQuestions[currentQuestionIndex].correctAnswer
    }
    
    func calculateStars(for score: Int) -> Int {
        gameLogicService.calculateStars(correctAnswers: score, totalQuestions: totalQuestions)
    }
    
    func updateUserSettings(_ newSettings: UserSettings) {
        userSettings = newSettings
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
        isProcessingAnswer = false
        cancelFeedbackTask()
        revealedAnswer = nil
        selectedAnswer = nil
    }
    
    func playHiraganaSound() {
        guard !currentHiragana.isEmpty else {
            print("⚠️ playHiraganaSound: currentHiragana is empty")
            return
        }
        
        print("🔊 Playing sound for: \(currentHiragana)")
        
        Task {
            await speakCurrentHiragana()
        }
    }

    /// 音のボタンで鳴らす中身。テストから完了を待てるように分けている（#73）
    func speakCurrentHiragana() async {
        await audioService.speakCharacter(currentHiragana)
    }
    
    func getHint() -> String {
        gameLogicService.generateHint(for: currentHiragana)
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
        
        // ゲーム完了時の音声停止とメニューBGMに切り替え
        audioService.stopAllAudio()
        audioService.switchToMenuBGM()
    }
    
    /// プレイ中のヘッダーに出すスター。回答済みの問題を分母に、ゲーム終了時と同じ難易度別の閾値で計算する（#67）
    var currentPotentialStars: Int {
        if isGameCompleted {
            return earnedStars
        }
        guard currentQuestionIndex > 0 else { return 0 }
        return gameLogicService.calculateStars(correctAnswers: score, totalQuestions: currentQuestionIndex)
    }

    func getCurrentProgress() -> Double {
        Double(currentQuestionIndex) / Double(totalQuestions)
    }
    
    func getScorePercentage() -> Double {
        Double(score) / Double(totalQuestions)
    }
    
    func getTimeElapsed() -> TimeInterval {
        Date().timeIntervalSince(gameStartTime)
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
        // Timer は RunLoop に保持されるため、self を強参照すると画面破棄後も ViewModel が生き残り、
        // 画面がない状態で completeGame() が走って統計に書き込まれる (#31)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.handleTimerTick()
        }
    }
    
    /// 1 秒ごとの tick。残り時間を減らし、0 のまま tick されたら時間切れでゲームを終了する
    func handleTimerTick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            completeGame()
        }
    }
    
    func getTimeRemaining() -> Int {
        timeRemaining
    }
    
    func isTimeLimitEnabled() -> Bool {
        userSettings?.playtimeLimit ?? 0 > 0
    }
    
    /// 時間制限タイマーを止める。画面を離れるとき（GameView.onDisappear）と deinit から呼ばれる
    func cleanup() {
        // 間違えたときの「正解を読み上げてから次へ」も止める（#82）
        cancelFeedbackTask()
        guard let timer = gameTimer else { return }
        gameTimer = nil
        // Timer の invalidate は登録した RunLoop のスレッド（メイン）で行う必要がある。
        // deinit は音声プリロード Task の完了先など別スレッドで走ることがあるため、メインへ送る
        if Thread.isMainThread {
            timer.invalidate()
        } else {
            DispatchQueue.main.async { timer.invalidate() }
        }
    }
    
    deinit {
        cleanup()
    }
}

// MARK: - 回答のあとの流れ（#82）

extension GameViewModel {
    /// 回答のあと、次の問題（最後なら結果画面）へ進む。間違えたときは正解を読み上げてから進む（#82）
    private func scheduleNextStep(afterCorrectAnswer isCorrect: Bool, isLastQuestion: Bool) {
        // テストモードでは即座に進む
        if isTestMode {
            finishFeedback(isLastQuestion: isLastQuestion)
            return
        }
        if !isCorrect {
            // 設定と正解の単語は、ここ（メインスレッド）で読んでから渡す。Task の中はメイン以外で動く
            let minimum = feedbackDelay
            let word = revealedWord()
            // self は強く握る（最長 5 秒ほど ViewModel が生き延びる）。[weak self] にすると deinit が別スレッドで走る（#31）
            feedbackTask = Task {
                await self.revealCorrectAnswerThenContinue(word: word, minimum: minimum, isLastQuestion: isLastQuestion)
            }
            return
        }
        if isLastQuestion {
            finishFeedback(isLastQuestion: true)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + feedbackDelay) {
            self.finishFeedback(isLastQuestion: false)
        }
    }
    
    /// 自動進行設定に基づく、次の問題へ進むまでの最低の待ち時間
    private var feedbackDelay: TimeInterval {
        userSettings?.autoAdvance == true ? AppConstants.Timing.autoAdvanceDelayEnabled : AppConstants.Timing.autoAdvanceDelayDisabled
    }
    
    /// 回答の表示を終えて、次の問題（最後なら結果画面）へ進む。テストから呼べるよう internal
    func finishFeedback(isLastQuestion: Bool) {
        // 正解を見せている間に時間切れでゲームが終わっていたら、何もしない（二重に完了させない）
        guard !isGameCompleted else { return }
        if isLastQuestion {
            isProcessingAnswer = false
            completeGame()
        } else {
            showFeedback = false
            loadCurrentQuestion()
            isProcessingAnswer = false
        }
    }
    
    /// 不正解音のあとに正解の単語を読み上げ、読み終わったら次へ進む。
    /// 声が出ない・終わらないときも最長 FeedbackTiming.maxRevealDuration で進み、今より早くは進まない
    private func revealCorrectAnswerThenContinue(word: String?, minimum: TimeInterval, isLastQuestion: Bool) async {
        let start = Date()
        try? await Task.sleep(nanoseconds: AppConstants.Timing.correctSoundDelay)
        let limit = FeedbackTiming.maxRevealDuration - Date().timeIntervalSince(start)
        if let word {
            await FeedbackTiming.wait(atMost: limit) {
                await self.audioService.speakText(word, slowly: true)
            }
        }
        let remaining = FeedbackTiming.remainingWait(elapsed: Date().timeIntervalSince(start), minimum: minimum)
        if remaining > 0 {
            try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
        }
        // 「戻る」で画面を離れたあとは進めない（離れたあとに completeGame が走ると途中結果が記録される。#31）
        guard !Task.isCancelled else { return }
        await MainActor.run {
            self.finishFeedback(isLastQuestion: isLastQuestion)
        }
    }
    
    /// 間違えたときに、正解の単語をゆっくり読み上げる（#82）
    func speakRevealedAnswer() async {
        guard let word = revealedWord() else { return }
        await audioService.speakText(word, slowly: true)
    }
    
    /// 間違えたときに読み上げる、正解の単語
    private func revealedWord() -> String? {
        revealedAnswer.flatMap { HiraganaDataManager.shared.getJapaneseWord(for: $0) }
    }
    
    private func cancelFeedbackTask() {
        feedbackTask?.cancel()
        feedbackTask = nil
    }
}
