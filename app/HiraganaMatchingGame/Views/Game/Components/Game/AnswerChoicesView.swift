import SwiftUI

struct AnswerChoicesView: View {
    let answerChoices: [HiraganaItem]
    let showFeedback: Bool
    let isProcessingAnswer: Bool
    let currentHiragana: String
    let isLandscape: Bool
    var scale: GameLayoutScale = .regular
    /// 間違えたときに正解を見せている間は true（#82）
    var isRevealingAnswer: Bool = false
    var revealedAnswer: String?
    var selectedAnswer: String?
    let onAnswerSelected: (String) -> Void
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private var choiceButtonSize: CGFloat {
        isLandscape ? min(90, scale.choiceSize) : scale.choiceSize
    }
    
    var body: some View {
        // 説明文は InstructionTextView の 1 つだけにした（PO 判断 2026-11-01、#80）
        VStack(spacing: 15) {
            if isLandscape {
                HStack(spacing: 20) {
                    ForEach(answerChoices, id: \.id) { choice in
                        markedChoiceButton(choice)
                    }
                }
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: scale.spacing) {
                    ForEach(answerChoices, id: \.id) { choice in
                        markedChoiceButton(choice)
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
        .opacity(choiceOpacity(for: choice))
        .scaleEffect(1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0 ... 0.3)), value: currentHiragana)
        .onAppear {
            // 選択肢ボタンが表示される時の楽しいアニメーション
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(Double.random(in: 0 ... 0.5))) {
                // 小さな跳ねるアニメーション
            }
        }
    }
    
    // MARK: - 間違えたときの印（#82）
    
    private func markedChoiceButton(_ choice: HiraganaItem) -> some View {
        answerChoiceButton(choice)
            .overlay { markOverlay(for: choice) }
            .accessibilityLabel(AccessibilityText.answerChoice(reading: getReadingForImageName(choice.imageName), mark: mark(for: choice)))
    }
    
    private func mark(for choice: HiraganaItem) -> AnswerChoiceMark {
        AnswerChoiceMark.mark(
            for: choice.imageName,
            isRevealing: isRevealingAnswer,
            revealedAnswer: revealedAnswer,
            selectedAnswer: selectedAnswer
        )
    }
    
    private func choiceOpacity(for choice: HiraganaItem) -> Double {
        switch mark(for: choice) {
        case .correct, .wrongSelection:
            1.0
        case .dimmed:
            0.3
        case .none:
            (showFeedback || isProcessingAnswer) ? 0.5 : 1.0
        }
    }
    
    @ViewBuilder
    private func markOverlay(for choice: HiraganaItem) -> some View {
        switch mark(for: choice) {
        case .correct:
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.green, lineWidth: 5)
                .padding(-6)
                .overlay(alignment: .topTrailing) { markBadge(systemName: "circle", color: .green) }
        case .wrongSelection:
            markBadge(systemName: "xmark", color: .red)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        case .none, .dimmed:
            EmptyView()
        }
    }
    
    private func markBadge(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 22, weight: .heavy))
            .foregroundColor(color)
            .padding(6)
            .background(Circle().fill(Color.white))
            .offset(x: 10, y: -10)
            .accessibilityHidden(true)
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
