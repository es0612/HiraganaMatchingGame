import SwiftUI

struct FeedbackView: View {
    let lastAnswerCorrect: Bool
    let isGameCompleted: Bool
    let gameResultView: AnyView
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            if lastAnswerCorrect {
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
            gameResultView: AnyView(EmptyView())
        )
        
        // Incorrect answer
        FeedbackView(
            lastAnswerCorrect: false,
            isGameCompleted: false,
            gameResultView: AnyView(EmptyView())
        )
        
        // Game completed
        FeedbackView(
            lastAnswerCorrect: true,
            isGameCompleted: true,
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