import SwiftUI

struct AnswerChoicesView: View {
    let answerChoices: [HiraganaItem]
    let showFeedback: Bool
    let isProcessingAnswer: Bool
    let currentHiragana: String
    let isLandscape: Bool
    let onAnswerSelected: (String) -> Void
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private var choiceButtonSize: CGFloat {
        isLandscape ? 90 : 110
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("正しい絵をタップしてください")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary.opacity(0.7))
            
            if isLandscape {
                HStack(spacing: 20) {
                    ForEach(answerChoices, id: \.id) { choice in
                        answerChoiceButton(choice)
                    }
                }
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(answerChoices, id: \.id) { choice in
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
                onAnswerSelected(choice.imageName)
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
                        .scaleEffect(showFeedback ? 1.2 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showFeedback)
                }
                
                Text(getReadingForImageName(choice.imageName))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(showFeedback || isProcessingAnswer)
        .opacity((showFeedback || isProcessingAnswer) ? 0.5 : 1.0)
        .scaleEffect(1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0 ... 0.3)), value: currentHiragana)
        .onAppear {
            // 選択肢ボタンが表示される時の楽しいアニメーション
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(Double.random(in: 0 ... 0.5))) {
                // 小さな跳ねるアニメーション
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func getEmojiForImageName(_ imageName: String) -> String {
        HiraganaDataManager.shared.getEmojiForImageName(imageName)
    }
    
    private func getReadingForImageName(_ imageName: String) -> String {
        HiraganaDataManager.shared.getJapaneseWord(for: imageName) ?? imageName
    }
}

#Preview {
    let sampleChoices = [
        HiraganaItem(character: "あ", imageName: "ant", category: "animals"),
        HiraganaItem(character: "い", imageName: "dog", category: "animals"),
        HiraganaItem(character: "う", imageName: "rabbit", category: "animals"),
        HiraganaItem(character: "え", imageName: "shrimp", category: "animals")
    ]
    
    AnswerChoicesView(
        answerChoices: sampleChoices,
        showFeedback: false,
        isProcessingAnswer: false,
        currentHiragana: "あ",
        isLandscape: false
    ) { selectedAnswer in
        print("Selected: \(selectedAnswer)")
    }
    .padding()
}
