//
//  GameControlsView.swift
//  HiraganaMatchingGame
//
//

import SwiftUI

struct GameControlsView: View {
    let currentQuestion: Int
    let totalQuestions: Int
    let score: Int
    let isGameCompleted: Bool
    let earnedStars: Int
    let showHint: Bool
    let hintText: String
    let selectedLevel: Int
    let levelProgressionService: LevelProgressionService
    let onBackPressed: () -> Void
    let onNextPressed: () -> Void
    let onRestart: () -> Void
    let onHintDismissed: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 15) {
            if showHint {
                hintView
            }
            
            bottomControlsView
        }
    }
    
    private var bottomControlsView: some View {
        HStack {
            Text("問題: \(currentQuestion)/\(totalQuestions)　正解: \(score)")
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.8) : Color.gray)
            
            Spacer()
            
            HStack(spacing: 15) {
                settingsButton
                nextButton
            }
        }
    }
    
    private var settingsButton: some View {
        Button(action: {
            // 触覚フィードバック
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            onBackPressed()
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
            // 触覚フィードバック
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            if isGameCompleted {
                onRestart()
            } else {
                onNextPressed()
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
                        onHintDismissed()
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
    
    // MARK: - Helper Functions
    
    private func getButtonText() -> String {
        if isGameCompleted {
            return "再挑戦"
        } else {
            return "ヒント"
        }
    }
    
    private func getButtonColor() -> Color {
        if isGameCompleted {
            return Color.blue.opacity(0.8) // 再挑戦の場合は青
        } else {
            return Color.pink.opacity(0.8) // ヒントは通常のピンク
        }
    }
}

#Preview {
    VStack {
        GameControlsView(
            currentQuestion: 3,
            totalQuestions: 5,
            score: 2,
            isGameCompleted: false,
            earnedStars: 0,
            showHint: true,
            hintText: "「あ」から始まる動物を探してみてね！",
            selectedLevel: 1,
            levelProgressionService: LevelProgressionService(),
            onBackPressed: { print("Back pressed") },
            onNextPressed: { print("Next pressed") },
            onRestart: { print("Restart pressed") },
            onHintDismissed: { print("Hint dismissed") }
        )
        .padding()
        
        Spacer()
        
        GameControlsView(
            currentQuestion: 5,
            totalQuestions: 5,
            score: 4,
            isGameCompleted: true,
            earnedStars: 3,
            showHint: false,
            hintText: "",
            selectedLevel: 1,
            levelProgressionService: LevelProgressionService(),
            onBackPressed: { print("Back pressed") },
            onNextPressed: { print("Next pressed") },
            onRestart: { print("Restart pressed") },
            onHintDismissed: { print("Hint dismissed") }
        )
        .padding()
    }
}
