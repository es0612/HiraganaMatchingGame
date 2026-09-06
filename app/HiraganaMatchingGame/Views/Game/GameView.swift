import SwiftUI

struct GameView: View {
    let selectedLevel: Int
    let levelProgressionService: LevelProgressionService
    let onGameComplete: (Int, Int) -> Void
    let onBackToLevelSelection: () -> Void
    let onRestart: () -> Void
    let onNextLevel: () -> Void
    @State var userSettings: UserSettings?
    
    @State private var gameViewModel: GameViewModel
    @State private var showHint = false
    @State private var hintText = ""
    @State private var showLevelUnlockNotification = false
    @State private var unlockedLevel = 0
    @State private var nextLevelWasUnlockedBeforeGame = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme
    
    init(selectedLevel: Int = 1,
         levelProgressionService: LevelProgressionService = LevelProgressionService(),
         userSettings: UserSettings? = nil,
         onGameComplete: @escaping (Int, Int) -> Void = { _, _ in },
         onBackToLevelSelection: @escaping () -> Void = {},
         onRestart: @escaping () -> Void = {},
         onNextLevel: @escaping () -> Void = {}) {
        self.selectedLevel = selectedLevel
        self.levelProgressionService = levelProgressionService
        self.userSettings = userSettings
        self.onGameComplete = onGameComplete
        self.onBackToLevelSelection = onBackToLevelSelection
        self.onRestart = onRestart
        self.onNextLevel = onNextLevel
        
        if let settings = userSettings {
            let audioService = AudioService.createWithSettings(settings, startBGM: false)
            let gameLogicService = GameLogicService(userSettings: settings)
            let viewModel = GameViewModel(
                gameLogicService: gameLogicService,
                audioService: audioService,
                starUnlockService: StarUnlockService(),
                levelProgressionService: levelProgressionService
            )
            viewModel.updateUserSettings(settings)
            _gameViewModel = State(initialValue: viewModel)
        } else {
            _gameViewModel = State(initialValue: GameViewModel(
                levelProgressionService: levelProgressionService
            ))
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: colorScheme == .dark ? [
                        Color.pink.opacity(0.03),
                        Color.orange.opacity(0.02),
                        Color.blue.opacity(0.02)
                    ] : [
                        Color.pink.opacity(0.08),
                        Color.orange.opacity(0.06),
                        Color.blue.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            headerView
                                .accessibilityIdentifier("ゲームヘッダー")
                            
                            if gameViewModel.showFeedback {
                                FeedbackView(
                                    lastAnswerCorrect: gameViewModel.lastAnswerCorrect,
                                    isGameCompleted: gameViewModel.isGameCompleted,
                                    gameResultView: AnyView(
                                        GameResultView(
                                            score: gameViewModel.score,
                                            totalQuestions: gameViewModel.totalQuestions,
                                            earnedStars: gameViewModel.earnedStars,
                                            accuracy: gameViewModel.getGameStats().accuracy
                                        )
                                    )
                                )
                            } else {
                                VStack(spacing: 20) {
                                    InstructionTextView()
                                    
                                    HiraganaCardView(
                                        currentHiragana: gameViewModel.currentHiragana,
                                        showFeedback: gameViewModel.showFeedback,
                                        score: gameViewModel.score,
                                        onSoundButtonTapped: { gameViewModel.playHiraganaSound() }
                                    )
                                    
                                    // ヒント表示
                                    if showHint {
                                        HintView(
                                            hintText: hintText,
                                            onClose: {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    showHint = false
                                                }
                                            }
                                        )
                                    }
                                    
                                    AnswerChoicesView(
                                        answerChoices: gameViewModel.answerChoices,
                                        showFeedback: gameViewModel.showFeedback,
                                        isProcessingAnswer: gameViewModel.isProcessingAnswer,
                                        currentHiragana: gameViewModel.currentHiragana,
                                        isLandscape: isLandscape,
                                        onAnswerSelected: { selectedAnswer in
                                            gameViewModel.selectAnswer(selectedAnswer)
                                        }
                                    )
                                }
                                .accessibilityIdentifier("ゲームエリア")
                            }
                        }
                        .padding()
                    }
                    
                    BottomControlsView(
                        currentQuestion: gameViewModel.currentQuestion,
                        totalQuestions: gameViewModel.totalQuestions,
                        score: gameViewModel.score,
                        isGameCompleted: gameViewModel.isGameCompleted,
                        showHints: userSettings?.showHints == true,
                        onBackToLevelSelection: onBackToLevelSelection,
                        onRestart: onRestart,
                        onShowHint: showHintAlert,
                        completedGameButtonsView: AnyView(
                            CompletedGameButtonsView(
                                selectedLevel: selectedLevel,
                                earnedStars: gameViewModel.earnedStars,
                                levelProgressionService: levelProgressionService,
                                onBackToLevelSelection: onBackToLevelSelection,
                                onRestart: onRestart,
                                onNextLevel: onNextLevel
                            )
                        )
                    )
                    .padding()
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 10))
                    .background(
                        colorScheme == .dark ?
                            Color(.systemBackground).opacity(0.9) :
                            Color.white.opacity(0.9)
                    )
                }
                .accessibilityIdentifier("ゲーム画面")
            }
            
            // パーティクルエフェクト
            if gameViewModel.showFeedback {
                ParticleEffectView(isCorrect: gameViewModel.score > 0)
                    .allowsHitTesting(false)
                    .zIndex(50)
            }
            
            // ゲーム完了時の紙吹雪
            if gameViewModel.isGameCompleted && gameViewModel.earnedStars > 0 {
                ConfettiView()
                    .allowsHitTesting(false)
                    .zIndex(60)
            }
            
            // レベル解放通知オーバーレイ
            if showLevelUnlockNotification {
                LevelUnlockNotificationView(
                    unlockedLevel: unlockedLevel,
                    showNotification: showLevelUnlockNotification,
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showLevelUnlockNotification = false
                        }
                    }
                )
                .zIndex(100)
            }
        }
        .onAppear {
            // ゲーム開始前の次レベル解放状態を記録
            let nextLevel = selectedLevel + 1
            nextLevelWasUnlockedBeforeGame = levelProgressionService.isLevelUnlocked(nextLevel)
            
            gameViewModel.startNewGame(level: selectedLevel)
        }
        .onChange(of: gameViewModel.isGameCompleted) {
            if gameViewModel.isGameCompleted {
                // ゲーム完了をContentViewに通知
                onGameComplete(selectedLevel, gameViewModel.earnedStars)
                
                // ゲーム終了後に新しいレベルが解放されたかチェック
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    checkForLevelUnlock()
                }
            }
        }
        .onDisappear {
            // ゲーム画面を離れる時にメニューBGMに切り替え
            gameViewModel.audioService.switchToMenuBGM()
        }
        .onChange(of: userSettings) {
            if let settings = userSettings {
                gameViewModel.updateUserSettings(settings)
            }
        }
    }
    
    func updateUserSettings(_ newSettings: UserSettings) {
        userSettings = newSettings
        gameViewModel.updateUserSettings(newSettings)
    }
    
    // MARK: - Private Views
    
    private var headerView: some View {
        HStack {
            LevelBadgeView(level: gameViewModel.currentLevel)
            
            Spacer()
            
            VStack(spacing: 4) {
                ProgressBarView(progress: gameViewModel.getCurrentProgress())
                
                // 時間制限表示
                if gameViewModel.isTimeLimitEnabled() {
                    TimeDisplayView(timeRemaining: gameViewModel.getTimeRemaining())
                }
            }
            
            Spacer()
            
            StarsView(earnedStars: getCurrentPotentialStars())
        }
    }
    
    // MARK: - Helper Functions
    
    private func getCurrentPotentialStars() -> Int {
        if gameViewModel.isGameCompleted {
            return gameViewModel.earnedStars
        } else {
            // 現在の進行状況から予想される星数を計算
            let currentAccuracy = Double(gameViewModel.score) / Double(gameViewModel.currentQuestion - 1)
            if currentAccuracy >= 1.0 {
                return 3
            } else if currentAccuracy >= 0.8 {
                return 2
            } else if currentAccuracy >= 0.6 {
                return 1
            } else {
                return 0
            }
        }
    }
    
    private func showHintAlert() {
        // ヒント設定が無効な場合は表示しない
        guard userSettings?.showHints == true else {
            print("💡 Hint disabled in settings")
            return
        }
        
        hintText = gameViewModel.getHint()
        withAnimation(.easeInOut(duration: 0.3)) {
            showHint = true
        }
        
        // 一定時間後に自動的にヒントを非表示にする
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Timing.hintAutoHide) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showHint = false
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
    
    // MARK: - レベル解放通知
    
    private func checkForLevelUnlock() {
        let nextLevel = selectedLevel + 1
        guard nextLevel <= levelProgressionService.getTotalLevels() else { return }
        
        // ゲーム完了後にチェック
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let isNowUnlocked = levelProgressionService.isLevelUnlocked(nextLevel)
            
            // 新規解放の場合のみ通知を表示
            if !nextLevelWasUnlockedBeforeGame && isNowUnlocked {
                unlockedLevel = nextLevel
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showLevelUnlockNotification = true
                }
                
                // 一定時間後に自動で閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Timing.levelUnlockAutoHide) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLevelUnlockNotification = false
                    }
                }
            }
        }
    }
}

#Preview {
    GameView()
}
