import SwiftUI

struct CompletedGameButtonsView: View {
    let selectedLevel: Int
    let earnedStars: Int
    let levelProgressionService: LevelProgressionService
    let onBackToLevelSelection: () -> Void
    let onRestart: () -> Void
    let onNextLevel: () -> Void
    
    var body: some View {
        let hasEarnedTwoOrMoreStars = earnedStars >= 2
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
}

#Preview {
    VStack(spacing: 20) {
        // With next level available (2+ stars)
        CompletedGameButtonsView(
            selectedLevel: 3,
            earnedStars: 3,
            levelProgressionService: LevelProgressionService(),
            onBackToLevelSelection: { print("Back") },
            onRestart: { print("Restart") },
            onNextLevel: { print("Next Level") }
        )
        
        // Without next level (< 2 stars)
        CompletedGameButtonsView(
            selectedLevel: 3,
            earnedStars: 1,
            levelProgressionService: LevelProgressionService(),
            onBackToLevelSelection: { print("Back") },
            onRestart: { print("Restart") },
            onNextLevel: { print("Next Level") }
        )
    }
    .padding()
}
