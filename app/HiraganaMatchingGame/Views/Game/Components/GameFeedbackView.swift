//
//  GameFeedbackView.swift
//  HiraganaMatchingGame
//
//  Created on 2025/06/16
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
                
                Text("正解！")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("よくできました！")
                    .font(.headline)
                    .foregroundColor(.gray)
            } else {
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
                        .scaleEffect(index < earnedStars ? 1.2 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: earnedStars)
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