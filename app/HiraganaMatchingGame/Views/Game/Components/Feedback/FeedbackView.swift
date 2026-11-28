import SwiftUI

/// FeedbackView に出す文言。View から切り離してテストで確かめる (#129)
struct FeedbackTexts: Equatable {
    let title: String
    let subtitle: String?
    /// true ならほめる表示（緑の ✓ か星）、false ならまちがいの表示（赤い ✖）
    let isPositive: Bool
}

struct FeedbackView: View {
    let lastAnswerCorrect: Bool
    let isGameCompleted: Bool
    let earnedStars: Int
    let gameResultView: AnyView
    @Environment(\.colorScheme) var colorScheme
    
    /// ゲームが終わったら、最後の 1 問の正誤ではなく星の数で見出しを決める（PO 判断 2026-11-28、#129）
    static func texts(lastAnswerCorrect: Bool, isGameCompleted: Bool, earnedStars: Int) -> FeedbackTexts {
        if isGameCompleted {
            if earnedStars >= 3 {
                return FeedbackTexts(title: "すごい！ ぜんぶ せいかい！", subtitle: nil, isPositive: true)
            }
            if earnedStars >= 1 {
                return FeedbackTexts(title: "よく できたね！", subtitle: nil, isPositive: true)
            }
            return FeedbackTexts(title: "さいごまで がんばったね！", subtitle: nil, isPositive: true)
        }
        if lastAnswerCorrect {
            return FeedbackTexts(title: "正解！", subtitle: "よくできました！", isPositive: true)
        }
        return FeedbackTexts(title: "残念...", subtitle: "次は頑張ろう！", isPositive: false)
    }
    
    private var texts: FeedbackTexts {
        Self.texts(lastAnswerCorrect: lastAnswerCorrect, isGameCompleted: isGameCompleted, earnedStars: earnedStars)
    }
    
    private var iconName: String {
        if !texts.isPositive {
            return "xmark.circle.fill"
        }
        return isGameCompleted ? "star.circle.fill" : "checkmark.circle.fill"
    }
    
    private var iconColor: Color {
        if !texts.isPositive {
            return .red
        }
        return isGameCompleted ? .yellow : .green
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.system(size: 60))
                    .foregroundColor(iconColor)
                
                Text(texts.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(texts.isPositive ? .green : .red)
                    .multilineTextAlignment(.center)
                
                if let subtitle = texts.subtitle {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            
            if isGameCompleted {
                gameResultView
            }
        }
        .animation(.easeInOut(duration: 0.5), value: lastAnswerCorrect)
    }
}

#Preview {
    VStack(spacing: 40) {
        // Correct answer
        FeedbackView(
            lastAnswerCorrect: true,
            isGameCompleted: false,
            earnedStars: 0,
            gameResultView: AnyView(EmptyView())
        )
        
        // Incorrect answer
        FeedbackView(
            lastAnswerCorrect: false,
            isGameCompleted: false,
            earnedStars: 0,
            gameResultView: AnyView(EmptyView())
        )
        
        // Game completed（星の数で見出しが変わる。#129）
        FeedbackView(
            lastAnswerCorrect: false,
            isGameCompleted: true,
            earnedStars: 2,
            gameResultView: AnyView(
                Text("Game Result Placeholder")
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            )
        )
    }
    .padding()
}
