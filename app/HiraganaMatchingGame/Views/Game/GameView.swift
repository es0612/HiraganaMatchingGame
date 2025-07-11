import SwiftUI

struct GameView: View {
    let selectedLevel: Int
    let levelProgressionService: LevelProgressionService
    let onGameComplete: (Int, Int) -> Void
    let onBackToLevelSelection: () -> Void
    let onRestart: () -> Void
    let onNextLevel: () -> Void
    let userSettings: UserSettings?
    
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
            self._gameViewModel = State(initialValue: GameViewModel(
                gameLogicService: gameLogicService,
                audioService: audioService,
                starUnlockService: StarUnlockService(),
                levelProgressionService: levelProgressionService
            ))
        } else {
            self._gameViewModel = State(initialValue: GameViewModel(
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
                                feedbackView
                            } else {
                                VStack(spacing: 20) {
                                    instructionText
                                    
                                    hiraganaCardView
                                    
                                    // ヒント表示
                                    if showHint {
                                        hintView
                                    }
                                    
                                    answerChoicesView
                                }
                                .accessibilityIdentifier("ゲームエリア")
                            }
                        }
                        .padding()
                    }
                    
                    bottomControlsView
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
                levelUnlockNotificationView
                    .zIndex(100)
            }
        }
        .onAppear {
            // ゲーム開始前の次レベル解放状態を記録
            let nextLevel = selectedLevel + 1
            nextLevelWasUnlockedBeforeGame = levelProgressionService.isLevelUnlocked(nextLevel)
            
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
        .onDisappear {
            // ゲーム画面を離れる時にメニューBGMに切り替え
            gameViewModel.audioService.switchToMenuBGM()
        }
    }
    
    private var headerView: some View {
        HStack {
            levelBadgeView
            
            Spacer()
            
            VStack(spacing: 4) {
                progressBarView
                
                // 時間制限表示
                if gameViewModel.isTimeLimitEnabled() {
                    timeDisplayView
                }
            }
            
            Spacer()
            
            starsView
        }
    }
    
    private var levelBadgeView: some View {
        Text("レベル \(gameViewModel.currentLevel)")
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.9), Color.orange.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            )
    }
    
    private var progressBarView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 10)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.8), Color.blue.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * gameViewModel.getCurrentProgress(), height: 10)
                    .animation(.easeInOut(duration: 0.3), value: gameViewModel.getCurrentProgress())
            }
        }
        .frame(height: 10)
        .frame(maxWidth: 200)
    }
    
    private var starsView: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: "star.fill")
                    .foregroundColor(index < getCurrentPotentialStars() ? .yellow : .gray.opacity(0.3))
                    .font(.title2)
            }
        }
    }
    
    private var timeDisplayView: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.caption)
                .foregroundColor(.orange)
            Text(formatTime(gameViewModel.getTimeRemaining()))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
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
    
    private var instructionText: some View {
        Text("この文字に合う絵を選んでね！")
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(.primary.opacity(0.8))
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    private var hiraganaCardView: some View {
        ZStack {
            // 背景カード
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color.pink.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .stroke(
                    LinearGradient(
                        colors: [Color.pink.opacity(0.6), Color.orange.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 220, height: 220)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            // ひらがな文字を完全に中央配置
            Text(gameViewModel.currentHiragana)
                .font(.system(size: 90, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(width: 220, height: 220)
                .scaleEffect(gameViewModel.showFeedback ? 1.2 : 1.0)
                .rotationEffect(.degrees(gameViewModel.showFeedback && gameViewModel.score > 0 ? 10 : 0))
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: gameViewModel.showFeedback)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: gameViewModel.currentHiragana)
            
            // サウンドボタンを右上に配置
            VStack {
                HStack {
                    Spacer()
                    soundButton
                        .offset(x: -15, y: 15)
                }
                Spacer()
            }
        }
    }
    
    private var soundButton: some View {
        Button(action: {
            print("🎯 Sound button tapped for: \(gameViewModel.currentHiragana)")
            gameViewModel.playHiraganaSound()
        }) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                )
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: gameViewModel.currentHiragana)
        .accessibilityLabel("ひらがなの音を聞く")
        .accessibilityHint("\(gameViewModel.currentHiragana)の音声を再生します")
    }
    
    private var answerChoicesView: some View {
        VStack(spacing: 15) {
            Text("正しい絵をタップしてください")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary.opacity(0.7))
            
            if isLandscape {
                HStack(spacing: 20) {
                    ForEach(gameViewModel.answerChoices, id: \.id) { choice in
                        answerChoiceButton(choice)
                    }
                }
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(gameViewModel.answerChoices, id: \.id) { choice in
                        answerChoiceButton(choice)
                    }
                }
            }
        }
    }
    
    private func answerChoiceButton(_ choice: HiraganaItem) -> some View {
        Button(action: {
            // タップ時のハプティクスフィードバック
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                gameViewModel.selectAnswer(choice.imageName)
            }
        }) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color.blue.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: choiceButtonSize, height: choiceButtonSize)
                        .shadow(
                            color: colorScheme == .dark ? 
                                Color.white.opacity(0.05) : 
                                Color.black.opacity(0.1), 
                            radius: colorScheme == .dark ? 2 : 4, 
                            x: 0, 
                            y: 2
                        )
                    
                    // 絵文字を中央に配置
                    Text(getEmojiForImageName(choice.imageName))
                        .font(.system(size: choiceButtonSize * 0.55))
                        .frame(width: choiceButtonSize, height: choiceButtonSize)
                        .scaleEffect(gameViewModel.showFeedback ? 1.2 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: gameViewModel.showFeedback)
                }
                
                Text(getReadingForImageName(choice.imageName))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.3)), value: gameViewModel.currentHiragana)
        .onAppear {
            // 選択肢ボタンが表示される時の楽しいアニメーション
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(Double.random(in: 0...0.5))) {
                // 小さな跳ねるアニメーション
            }
        }
    }
    
    private var bottomControlsView: some View {
        HStack {
            Text("問題: \(gameViewModel.currentQuestion)/\(gameViewModel.totalQuestions)　正解: \(gameViewModel.score)")
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.8) : Color.gray)
            
            Spacer()
            
            if gameViewModel.isGameCompleted {
                completedGameButtonsView
            } else {
                HStack(spacing: 15) {
                    settingsButton
                    nextButton
                }
            }
        }
    }
    
    private var settingsButton: some View {
        Button(action: {
            onBackToLevelSelection()
        }) {
            Text("戻る")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray.opacity(0.6))
                )
        }
    }
    
    @ViewBuilder
    private var nextButton: some View {
        // ゲーム進行中でヒント設定がオフの場合はボタンを非表示
        if !gameViewModel.isGameCompleted && userSettings?.showHints == false {
            EmptyView()
        } else {
            Button(action: {
                if gameViewModel.isGameCompleted {
                    // 再挑戦：同じレベルをもう一度開始
                    onRestart()
                } else {
                    // ヒント表示
                    showHintAlert()
                }
            }) {
                Text(getButtonText())
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(getButtonColor())
                    )
            }
        }
    }
    
    private func getButtonText() -> String {
        if gameViewModel.isGameCompleted {
            return "再挑戦"
        } else {
            return "ヒント"
        }
    }
    
    private func getButtonColor() -> Color {
        if gameViewModel.isGameCompleted {
            return Color.blue.opacity(0.8) // 再挑戦の場合は青
        } else {
            return Color.pink.opacity(0.8) // ヒントボタンはピンク
        }
    }
    
    private var completedGameButtonsView: some View {
        let hasEarnedTwoOrMoreStars = gameViewModel.earnedStars >= 2
        let nextLevel = selectedLevel + 1
        let isNextLevelAvailable = nextLevel <= levelProgressionService.getTotalLevels()
        
        return HStack(spacing: 10) {
            // 戻るボタン
            Button(action: {
                onBackToLevelSelection()
            }) {
                Text("戻る")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.6))
                    )
            }
            
            // 再挑戦ボタン
            Button(action: {
                onRestart()
            }) {
                Text("再挑戦")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.opacity(0.8))
                    )
            }
            
            // 次のレベルボタン（2つ星以上かつ次のレベルが存在する場合のみ表示）
            if hasEarnedTwoOrMoreStars && isNextLevelAvailable {
                Button(action: {
                    onNextLevel()
                }) {
                    Text("次のレベルへ")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(
                                    colors: [Color.green.opacity(0.8), Color.blue.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                }
            }
        }
    }
    
    private var hintView: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                Text("ヒント")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Button("×") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showHint = false
                    }
                }
                .foregroundColor(.gray)
                .font(.title2)
            }
            
            Text(hintText)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
        .transition(.opacity.combined(with: .move(edge: .top)))
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
    
    private var feedbackView: some View {
        VStack(spacing: 20) {
            if gameViewModel.lastAnswerCorrect {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("正解！")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("よくできました！")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("残念...")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    Text("次は頑張ろう！")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            
            if gameViewModel.isGameCompleted {
                gameResultView
            }
        }
        .animation(.easeInOut(duration: 0.5), value: gameViewModel.showFeedback)
    }
    
    private var gameResultView: some View {
        VStack(spacing: 15) {
            Text("ゲーム終了！")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            Text("スコア: \(gameViewModel.score)/\(gameViewModel.totalQuestions)")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .foregroundColor(index < gameViewModel.earnedStars ? .yellow : .gray.opacity(0.3))
                        .font(.title2)
                }
            }
            
            let stats = gameViewModel.getGameStats()
            Text("正解率: \(Int(stats.accuracy * 100))%")
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .gray : .gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(.systemGray6).opacity(0.8) : Color.white.opacity(0.9))
                .shadow(
                    color: colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.1),
                    radius: 5
                )
        )
    }
    
    // MARK: - Computed Properties
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
    
    private var choiceButtonSize: CGFloat {
        isLandscape ? 90 : 110
    }
    
    // MARK: - Helper Functions
    
    private func getEmojiForImageName(_ imageName: String) -> String {
        return HiraganaDataManager.shared.getEmojiForImageName(imageName)
    }
    
    private func getReadingForImageName(_ imageName: String) -> String {
        return HiraganaDataManager.shared.getJapaneseWord(for: imageName) ?? imageName
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
                
                // 3秒後に自動で閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLevelUnlockNotification = false
                    }
                }
            }
        }
    }
    
    private var levelUnlockNotificationView: some View {
        VStack(spacing: 20) {
            // アニメーション付き鍵アイコン
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(showLevelUnlockNotification ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showLevelUnlockNotification)
                
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(showLevelUnlockNotification ? 1.0 : 0.3)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: showLevelUnlockNotification)
            }
            
            VStack(spacing: 8) {
                Text("🎉 新しいレベルが解放！")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .scaleEffect(showLevelUnlockNotification ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showLevelUnlockNotification)
                
                Text("レベル \(unlockedLevel) がプレイできるようになりました！")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                    .multilineTextAlignment(.center)
                    .opacity(showLevelUnlockNotification ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.8).delay(0.4), value: showLevelUnlockNotification)
            }
            
            Button(action: {
                withAnimation(.easeOut(duration: 0.5)) {
                    showLevelUnlockNotification = false
                }
            }) {
                Text("続行")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(22)
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(
                    color: colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.2),
                    radius: 10,
                    x: 0,
                    y: 5
                )
        )
        .scaleEffect(showLevelUnlockNotification ? 1.0 : 0.8)
        .opacity(showLevelUnlockNotification ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showLevelUnlockNotification)
    }
}

#Preview {
    GameView()
}