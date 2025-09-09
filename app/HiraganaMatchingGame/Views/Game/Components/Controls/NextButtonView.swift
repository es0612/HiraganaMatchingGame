import SwiftUI

struct NextButtonView: View {
    let isGameCompleted: Bool
    let showHints: Bool
    let onRestart: () -> Void
    let onShowHint: () -> Void
    
    @ViewBuilder
    var body: some View {
        // ゲーム進行中でヒント設定がオフの場合はボタンを非表示
        if !isGameCompleted && !showHints {
            EmptyView()
        } else {
            Button(action: {
                if isGameCompleted {
                    // 再挑戦：同じレベルをもう一度開始
                    onRestart()
                } else {
                    // ヒント表示
                    onShowHint()
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
    }
    
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
            return Color.pink.opacity(0.8) // ヒントボタンはピンク
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        NextButtonView(
            isGameCompleted: false,
            showHints: true,
            onRestart: { print("Restart") },
            onShowHint: { print("Show hint") }
        )
        
        NextButtonView(
            isGameCompleted: true,
            showHints: true,
            onRestart: { print("Restart") },
            onShowHint: { print("Show hint") }
        )
        
        NextButtonView(
            isGameCompleted: false,
            showHints: false,
            onRestart: { print("Restart") },
            onShowHint: { print("Show hint") }
        )
    }
    .padding()
}
