import SwiftUI

struct SoundButtonView: View {
    let currentHiragana: String
    let onSoundButtonTapped: () -> Void
    
    var body: some View {
        Button(action: {
            print("🎯 Sound button tapped for: \(currentHiragana)")
            onSoundButtonTapped()
        }) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                )
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: currentHiragana)
        .accessibilityLabel("ひらがなの音を聞く")
        .accessibilityHint("\(currentHiragana)の音声を再生します")
    }
}

#Preview {
    SoundButtonView(currentHiragana: "あ") {
        print("Sound button tapped")
    }
    .padding()
}