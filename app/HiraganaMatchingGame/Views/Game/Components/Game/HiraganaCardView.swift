import SwiftUI

struct HiraganaCardView: View {
    let currentHiragana: String
    let showFeedback: Bool
    let score: Int
    let onSoundButtonTapped: () -> Void
    
    var body: some View {
        ZStack {
            // 背景カード
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color.pink.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .stroke(
                    LinearGradient(
                        colors: [Color.pink.opacity(0.6), Color.orange.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 220, height: 220)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            // ひらがな文字を完全に中央配置
            Text(currentHiragana)
                .font(.system(size: 90, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(width: 220, height: 220)
                .scaleEffect(showFeedback ? 1.2 : 1.0)
                .rotationEffect(.degrees(showFeedback && score > 0 ? 10 : 0))
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showFeedback)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentHiragana)
            
            // サウンドボタンを右上に配置
            VStack {
                HStack {
                    Spacer()
                    SoundButtonView(
                        currentHiragana: currentHiragana,
                        onSoundButtonTapped: onSoundButtonTapped
                    )
                    .offset(x: -15, y: 15)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HiraganaCardView(
            currentHiragana: "あ",
            showFeedback: false,
            score: 0
        ) {
            print("Sound button tapped")
        }
        
        HiraganaCardView(
            currentHiragana: "き",
            showFeedback: true,
            score: 1
        ) {
            print("Sound button tapped")
        }
    }
    .padding()
}
