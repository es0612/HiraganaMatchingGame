import SwiftUI

struct GameView: View {
    @State private var gameViewModel = GameViewModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [Color.pink.opacity(0.1), Color.orange.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    headerView
                    
                    Spacer()
                    
                    instructionText
                    
                    hiraganaCardView
                    
                    Spacer()
                    
                    answerChoicesView
                    
                    Spacer()
                    
                    bottomControlsView
                }
                .padding()
            }
        }
        .onAppear {
            gameViewModel.startNewGame(level: 1)
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
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.pink.opacity(0.8))
            )
    }
    
    private var progressBarView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.pink.opacity(0.8))
                    .frame(width: geometry.size.width * gameViewModel.getCurrentProgress(), height: 8)
            }
        }
        .frame(height: 8)
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
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
    }
    
    private var hiraganaCardView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .stroke(Color.pink.opacity(0.5), lineWidth: 3)
                .frame(width: 200, height: 200)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            VStack {
                HStack {
                    Spacer()
                    soundButton
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
                
                Spacer()
                
                Text(gameViewModel.currentHiragana)
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
            }
        }
    }
    
    private var soundButton: some View {
        Button(action: {
            // 音声再生処理
        }) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.pink.opacity(0.8))
                )
        }
    }
    
    private var answerChoicesView: some View {
        VStack(spacing: 10) {
            Text("正しい絵をタップしてください")
                .font(.headline)
                .foregroundColor(.gray)
            
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
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .frame(width: choiceButtonSize, height: choiceButtonSize)
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                    
                    // 実際のアプリでは画像を表示
                    Text(getEmojiForImageName(choice.imageName))
                        .font(.system(size: choiceButtonSize * 0.6))
                }
                
                Text(getReadingForCharacter(choice.character))
                    .font(.caption)
                    .foregroundColor(.black)
            }
        }
        .buttonStyle(PlainButtonStyle())
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
            // 設定画面を開く
        }) {
            Text("設定")
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
            // 次の問題へ進む処理
        }) {
            Text("次へ")
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
    
    // MARK: - Computed Properties
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
    
    private var choiceButtonSize: CGFloat {
        isLandscape ? 80 : 100
    }
    
    // MARK: - Helper Functions
    
    private func getEmojiForImageName(_ imageName: String) -> String {
        switch imageName {
        case "cat": return "🐱"
        case "dog": return "🐶"
        case "rabbit": return "🐰"
        case "bear": return "🐻"
        case "ant": return "🐜"
        case "shrimp": return "🦐"
        case "demon": return "👹"
        case "crab": return "🦀"
        case "giraffe": return "🦒"
        case "cake": return "🍰"
        case "top": return "🌀"
        case "monkey": return "🐵"
        case "deer": return "🦌"
        case "watermelon": return "🍉"
        case "cicada": return "🦗"
        case "sky": return "🌌"
        default: return "❓"
        }
    }
    
    private func getReadingForCharacter(_ character: String) -> String {
        let readings: [String: String] = [
            "あ": "あり", "い": "いぬ", "う": "うさぎ", "え": "えび", "お": "おに",
            "か": "かに", "き": "きりん", "く": "くま", "け": "けーき", "こ": "こま",
            "さ": "さる", "し": "しか", "す": "すいか", "せ": "せみ", "そ": "そら",
            "た": "たこ", "ち": "ちょう", "つ": "つる", "て": "て", "と": "とけい",
            "な": "なす", "に": "にんじん", "ぬ": "ぬいぐるみ", "ね": "ねこ", "の": "のはら"
        ]
        return readings[character] ?? character
    }
}

#Preview {
    GameView()
}