import SwiftUI

struct GameView: View {
    let selectedLevel: Int
    let levelProgressionService: LevelProgressionService
    let onGameComplete: (Int, Int) -> Void
    let onBackToLevelSelection: () -> Void
    let userSettings: UserSettings?
    
    @State private var gameViewModel: GameViewModel
    @State private var showHint = false
    @State private var hintText = ""
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    init(selectedLevel: Int = 1, 
         levelProgressionService: LevelProgressionService = LevelProgressionService(),
         userSettings: UserSettings? = nil,
         onGameComplete: @escaping (Int, Int) -> Void = { _, _ in },
         onBackToLevelSelection: @escaping () -> Void = {}) {
        self.selectedLevel = selectedLevel
        self.levelProgressionService = levelProgressionService
        self.userSettings = userSettings
        self.onGameComplete = onGameComplete
        self.onBackToLevelSelection = onBackToLevelSelection
        
        if let settings = userSettings {
            self._gameViewModel = State(initialValue: GameViewModel(userSettings: settings))
        } else {
            self._gameViewModel = State(initialValue: GameViewModel())
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [
                        Color.pink.opacity(0.08),
                        Color.orange.opacity(0.06),
                        Color.blue.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    headerView
                        .accessibilityIdentifier("ゲームヘッダー")
                    
                    Spacer()
                    
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
                            
                            Spacer()
                            
                            answerChoicesView
                        }
                        .accessibilityIdentifier("ゲームエリア")
                    }
                    
                    Spacer()
                    
                    bottomControlsView
                }
                .padding()
                .accessibilityIdentifier("ゲーム画面")
            }
        }
        .onAppear {
            gameViewModel.startNewGame(level: selectedLevel)
        }
    }
    
    private var headerView: some View {
        HStack {
            levelBadgeView
            
            Spacer()
            
            progressBarView
            
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
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: "star.fill")
                    .foregroundColor(index < 3 ? .yellow : .gray.opacity(0.3))
                    .font(.title2)
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
            gameViewModel.playHiraganaSound()
        }) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.pink.opacity(0.9), Color.orange.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                )
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: gameViewModel.currentHiragana)
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
            gameViewModel.selectAnswer(choice.imageName)
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
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // 絵文字を中央に配置
                    Text(getEmojiForImageName(choice.imageName))
                        .font(.system(size: choiceButtonSize * 0.55))
                        .frame(width: choiceButtonSize, height: choiceButtonSize)
                }
                
                Text(getReadingForCharacter(choice.character))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: gameViewModel.currentHiragana)
    }
    
    private var bottomControlsView: some View {
        HStack {
            Text("問題: \(gameViewModel.currentQuestion)/\(gameViewModel.totalQuestions)　正解: \(gameViewModel.score)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            HStack(spacing: 15) {
                settingsButton
                nextButton
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
    
    private var nextButton: some View {
        Button(action: {
            if gameViewModel.isGameCompleted {
                // レベル完了をサービスに通知してレベル選択画面に戻る
                onGameComplete(selectedLevel, gameViewModel.earnedStars)
            } else {
                // ヒント表示
                showHintAlert()
            }
        }) {
            Text(gameViewModel.isGameCompleted ? "次のレベル" : "ヒント")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.pink.opacity(0.8))
                )
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
            
            Text("スコア: \(gameViewModel.score)/\(gameViewModel.totalQuestions)")
                .font(.headline)
            
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
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 5)
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
        switch imageName {
        // あ行
        case "ant": return "🐜"
        case "dog": return "🐶"
        case "rabbit": return "🐰"
        case "shrimp": return "🦐"
        case "demon": return "👹"
        
        // か行
        case "crab": return "🦀"
        case "giraffe": return "🦒"
        case "bear": return "🐻"
        case "cake": return "🍰"
        case "top": return "🌀"
        
        // さ行
        case "monkey": return "🐵"
        case "deer": return "🦌"
        case "watermelon": return "🍉"
        case "cicada": return "🦗"
        case "sky": return "🌌"
        
        // た行
        case "octopus": return "🐙"
        case "butterfly": return "🦋"
        case "crane": return "🕊️"
        case "hand": return "✋"
        case "clock": return "⏰"
        
        // な行
        case "eggplant": return "🍆"
        case "carrot": return "🥕"
        case "doll": return "🪆"
        case "cat": return "🐱"
        case "field": return "🌾"
        
        // は行
        case "flower": return "🌸"
        case "chick": return "🐤"
        case "boat": return "⛵"
        case "snake": return "🐍"
        case "bone": return "🦴"
        
        // ま行
        case "bean": return "🫘"
        case "ear": return "👂"
        case "bug": return "🐛"
        case "eye": return "👁️"
        case "peach": return "🍑"
        
        // や行
        case "arrow": return "🏹"
        case "hot_water": return "♨️"
        case "night": return "🌙"
        
        // ら行
        case "trumpet": return "🎺"
        case "apple": return "🍎"
        case "loop": return "🔄"
        case "refrigerator": return "🧊"
        case "candle": return "🕯️"
        
        // わ行
        case "ring": return "💍"
        case "man": return "👨"
        case "antenna": return "📡"
        
        default: return "❓"
        }
    }
    
    private func getReadingForCharacter(_ character: String) -> String {
        let readings: [String: String] = [
            // あ行
            "あ": "あり", "い": "いぬ", "う": "うさぎ", "え": "えび", "お": "おに",
            
            // か行
            "か": "かに", "き": "きりん", "く": "くま", "け": "けーき", "こ": "こま",
            
            // さ行
            "さ": "さる", "し": "しか", "す": "すいか", "せ": "せみ", "そ": "そら",
            
            // た行
            "た": "たこ", "ち": "ちょう", "つ": "つる", "て": "て", "と": "とけい",
            
            // な行
            "な": "なす", "に": "にんじん", "ぬ": "ぬいぐるみ", "ね": "ねこ", "の": "のはら",
            
            // は行
            "は": "はな", "ひ": "ひよこ", "ふ": "ふね", "へ": "へび", "ほ": "ほね",
            
            // ま行
            "ま": "まめ", "み": "みみ", "む": "むし", "め": "め", "も": "もも",
            
            // や行
            "や": "やじるし", "ゆ": "ゆ", "よ": "よる",
            
            // ら行
            "ら": "らっぱ", "り": "りんご", "る": "るーぷ", "れ": "れいぞうこ", "ろ": "ろうそく",
            
            // わ行
            "わ": "わ", "を": "をとこ", "ん": "あんてな"
        ]
        return readings[character] ?? character
    }
}

#Preview {
    GameView()
}