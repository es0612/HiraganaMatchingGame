import SwiftUI

struct BottomControlsView: View {
    let currentQuestion: Int
    let totalQuestions: Int
    let score: Int
    let isGameCompleted: Bool
    let showHints: Bool
    let onBackToLevelSelection: () -> Void
    let onRestart: () -> Void
    let onShowHint: () -> Void
    let completedGameButtonsView: AnyView
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Text("問題: \(currentQuestion)/\(totalQuestions)　正解: \(score)")
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.8) : Color.gray)
            
            Spacer()
            
            if isGameCompleted {
                completedGameButtonsView
            } else {
                HStack(spacing: 15) {
                    SettingsButtonView(onBackToLevelSelection: onBackToLevelSelection)
                    
                    NextButtonView(
                        isGameCompleted: isGameCompleted,
                        showHints: showHints,
                        onRestart: onRestart,
                        onShowHint: onShowHint
                    )
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // During gameplay
        BottomControlsView(
            currentQuestion: 5,
            totalQuestions: 10,
            score: 3,
            isGameCompleted: false,
            showHints: true,
            onBackToLevelSelection: { print("Back") },
            onRestart: { print("Restart") },
            onShowHint: { print("Hint") },
            completedGameButtonsView: AnyView(EmptyView())
        )
        
        // Game completed
        BottomControlsView(
            currentQuestion: 10,
            totalQuestions: 10,
            score: 8,
            isGameCompleted: true,
            showHints: true,
            onBackToLevelSelection: { print("Back") },
            onRestart: { print("Restart") },
            onShowHint: { print("Hint") },
            completedGameButtonsView: AnyView(
                Text("Completed Buttons Placeholder")
                    .foregroundColor(.blue)
            )
        )
    }
    .padding()
}
