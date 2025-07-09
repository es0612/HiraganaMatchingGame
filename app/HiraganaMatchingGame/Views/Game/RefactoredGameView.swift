//
//  RefactoredGameView.swift
//  HiraganaMatchingGame
//
//

import SwiftUI

struct RefactoredGameView: View {
    let selectedLevel: Int
    let levelProgressionService: LevelProgressionService
    let onGameComplete: (Int, Int) -> Void
    let onBackToLevelSelection: () -> Void
    let onRestart: () -> Void
    let userSettings: UserSettings?
    
    @State private var gameViewModel: GameViewModel
    @State private var showHint = false
    @State private var hintText = ""
    @State private var showLevelUnlockNotification = false
    @State private var unlockedLevel = 0
    @Environment(\.colorScheme) var colorScheme
    
    init(selectedLevel: Int = 1, 
         levelProgressionService: LevelProgressionService = LevelProgressionService(),
         userSettings: UserSettings? = nil,
         onGameComplete: @escaping (Int, Int) -> Void = { _, _ in },
         onBackToLevelSelection: @escaping () -> Void = {},
         onRestart: @escaping () -> Void = {}) {
        self.selectedLevel = selectedLevel
        self.levelProgressionService = levelProgressionService
        self.userSettings = userSettings
        self.onGameComplete = onGameComplete
        self.onBackToLevelSelection = onBackToLevelSelection
        self.onRestart = onRestart
        
        if let settings = userSettings {
            self._gameViewModel = State(initialValue: GameViewModel(userSettings: settings))
        } else {
            self._gameViewModel = State(initialValue: GameViewModel())
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            gameHeaderView
                                .accessibilityIdentifier("ゲームヘッダー")
                            
                            if gameViewModel.showFeedback {
                                gameFeedbackView
                            } else {
                                gameContentView
                                    .accessibilityIdentifier("ゲームエリア")
                            }
                        }
                        .padding()
                    }
                    
                    gameControlsView
                        .padding()
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 10))
                        .background(
                            colorScheme == .dark ? 
                                Color(.systemBackground).opacity(0.9) : 
                                Color.white.opacity(0.9)
                        )
                }
                .accessibilityIdentifier("ゲーム画面")
                
                // オーバーレイ要素
                gameOverlayView
            }
        }
        .onAppear {
            gameViewModel.startNewGame(level: selectedLevel)
        }
        .onChange(of: gameViewModel.isGameCompleted) { completed in
            if completed {
                // ゲーム終了後に新しいレベルが解放されたかチェック
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    checkForLevelUnlock()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var backgroundGradient: some View {
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
    }
    
    private var gameHeaderView: some View {
        GameHeaderView(
            currentLevel: gameViewModel.currentLevel,
            currentProgress: gameViewModel.getCurrentProgress(),
            currentPotentialStars: getCurrentPotentialStars(),
            timeRemaining: gameViewModel.getTimeRemaining(),
            isTimeLimitEnabled: gameViewModel.isTimeLimitEnabled()
        )
    }
    
    private var gameContentView: some View {
        GameContentView(
            currentHiragana: gameViewModel.currentHiragana,
            answerChoices: gameViewModel.answerChoices,
            showFeedback: gameViewModel.showFeedback,
            onSoundButtonTap: {
                print("🎯 Sound button tapped for: \(gameViewModel.currentHiragana)")
                gameViewModel.playHiraganaSound()
            },
            onAnswerSelected: { imageName in
                gameViewModel.selectAnswer(imageName)
            }
        )
    }
    
    private var gameFeedbackView: some View {
        GameFeedbackView(
            lastAnswerCorrect: gameViewModel.lastAnswerCorrect,
            isGameCompleted: gameViewModel.isGameCompleted,
            score: gameViewModel.score,
            totalQuestions: gameViewModel.totalQuestions,
            earnedStars: gameViewModel.earnedStars,
            gameStats: gameViewModel.getGameStats()
        )
    }
    
    private var gameControlsView: some View {
        GameControlsView(
            currentQuestion: gameViewModel.currentQuestion,
            totalQuestions: gameViewModel.totalQuestions,
            score: gameViewModel.score,
            isGameCompleted: gameViewModel.isGameCompleted,
            earnedStars: gameViewModel.earnedStars,
            showHint: showHint,
            hintText: hintText,
            selectedLevel: selectedLevel,
            levelProgressionService: levelProgressionService,
            onBackPressed: onBackToLevelSelection,
            onNextPressed: {
                if gameViewModel.isGameCompleted {
                    // レベル完了をサービスに通知してレベル選択画面に戻る
                    onGameComplete(selectedLevel, gameViewModel.earnedStars)
                } else {
                    // ヒント表示
                    showHintAlert()
                }
            },
            onRestart: onRestart,
            onHintDismissed: {
                showHint = false
            }
        )
    }
    
    private var gameOverlayView: some View {
        GameOverlayView(
            showFeedback: gameViewModel.showFeedback,
            lastAnswerCorrect: gameViewModel.lastAnswerCorrect,
            isGameCompleted: gameViewModel.isGameCompleted,
            earnedStars: gameViewModel.earnedStars,
            showLevelUnlockNotification: showLevelUnlockNotification,
            unlockedLevel: unlockedLevel,
            onNotificationDismissed: {
                showLevelUnlockNotification = false
            }
        )
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
        
        // 5秒後に自動的にヒントを非表示にする
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showHint = false
            }
        }
    }
    
    private func checkForLevelUnlock() {
        let nextLevel = selectedLevel + 1
        guard nextLevel <= levelProgressionService.getTotalLevels() else { return }
        
        // ゲーム完了後にチェック
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if levelProgressionService.isLevelUnlocked(nextLevel) {
                unlockedLevel = nextLevel
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showLevelUnlockNotification = true
                }
                
                // 3秒後に自動で閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLevelUnlockNotification = false
                    }
                }
            }
        }
    }
}

#Preview {
    RefactoredGameView()
}