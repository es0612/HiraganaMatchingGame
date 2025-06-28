//
//  GameFeedbackView.swift
//  HiraganaMatchingGame
//
//

import SwiftUI

// GameStats is imported from GameViewModel module

struct GameFeedbackView: View {
    let lastAnswerCorrect: Bool
    let isGameCompleted: Bool
    let score: Int
    let totalQuestions: Int
    let earnedStars: Int
    let gameStats: GameStats
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            feedbackSection
            
            if isGameCompleted {
                gameResultView
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isGameCompleted)
    }
    
    private var feedbackSection: some View {
        VStack(spacing: 10) {
            if lastAnswerCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: lastAnswerCorrect)
                
                Text("正解！")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: lastAnswerCorrect)
                
                Text("よくできました！")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .opacity(1.0)
                    .animation(.easeInOut(duration: 0.5).delay(0.3), value: lastAnswerCorrect)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: lastAnswerCorrect)
                
                Text("残念...")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: lastAnswerCorrect)
                
                Text("次は頑張ろう！")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .opacity(1.0)
                    .animation(.easeInOut(duration: 0.5).delay(0.3), value: lastAnswerCorrect)
            }
        }
        .onAppear {
            // 正解/不正解時の触覚フィードバック
            if lastAnswerCorrect {
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
            } else {
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
            }
        }
    }
    
    private var gameResultView: some View {
        VStack(spacing: 15) {
            Text("ゲーム終了！")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            Text("スコア: \(score)/\(totalQuestions)")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .foregroundColor(index < earnedStars ? .yellow : .gray.opacity(0.3))
                        .font(.title2)
                        .scaleEffect(index < earnedStars ? 1.3 : 1.0)
                        .rotationEffect(.degrees(index < earnedStars ? 360 : 0))
                        .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(Double(index) * 0.15), value: earnedStars)
                        .shadow(color: index < earnedStars ? .yellow.opacity(0.6) : .clear, radius: 4, x: 0, y: 2)
                }
            }
            
            Text("正解率: \(Int(gameStats.accuracy * 100))%")
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .gray : .gray)
            
            if gameStats.timeElapsed > 0 {
                Text("時間: \(formatTime(gameStats.timeElapsed))")
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
            }
            
            // 星条件の説明
            VStack(spacing: 4) {
                if earnedStars >= 2 {
                    Text("🎉 次のレベルに進めます！")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                } else if earnedStars == 1 {
                    Text("もう少し！星2つで次のレベルへ")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text("頑張ろう！星2つを目指そう")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.top, 5)
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
        .scaleEffect(isGameCompleted ? 1.0 : 0.8)
        .opacity(isGameCompleted ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: isGameCompleted)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


#Preview {
    VStack(spacing: 30) {
        // 正解フィードバック
        GameFeedbackView(
            lastAnswerCorrect: true,
            isGameCompleted: false,
            score: 3,
            totalQuestions: 5,
            earnedStars: 0,
            gameStats: GameStats(accuracy: 0.8, timeElapsed: 120, averageResponseTime: 3.5)
        )
        
        // ゲーム完了
        GameFeedbackView(
            lastAnswerCorrect: true,
            isGameCompleted: true,
            score: 4,
            totalQuestions: 5,
            earnedStars: 2,
            gameStats: GameStats(accuracy: 0.8, timeElapsed: 180, averageResponseTime: 4.2)
        )
    }
    .padding()
}