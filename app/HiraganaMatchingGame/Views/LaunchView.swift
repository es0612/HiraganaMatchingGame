import SwiftUI
import Foundation

struct LaunchView: View {
    @State private var scale = 0.5
    @State private var opacity = 0.0
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // 背景のグラデーション
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.4, blue: 0.6), // ピンク
                    Color(red: 1.0, green: 0.6, blue: 0.2), // オレンジ
                    Color(red: 0.9, green: 0.3, blue: 0.9)  // 薄紫
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // メインアイコン
                ZStack {
                    // アイコンの背景円
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 200, height: 200)
                        .scaleEffect(scale)
                        .animation(.spring(response: 1.0, dampingFraction: 0.6), value: scale)
                    
                    // メインの「あ」文字
                    Text("あ")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                        .scaleEffect(scale)
                        .animation(.spring(response: 1.2, dampingFraction: 0.5).delay(0.2), value: scale)
                }
                
                // アプリ名
                VStack(spacing: 10) {
                    Text("ひらがな")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 0.6).delay(0.8), value: opacity)
                    
                    Text("マッチングゲーム")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 0.6).delay(1.0), value: opacity)
                }
                
                Spacer()
                
                // 楽しいメッセージ
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        Text("🎮")
                            .font(.title)
                        Text("🌟")
                            .font(.title)
                        Text("🎯")
                            .font(.title)
                    }
                    .opacity(opacity)
                    .animation(.easeInOut(duration: 0.6).delay(1.4), value: opacity)
                    
                    Text("楽しくひらがなを覚えよう！")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 0.6).delay(1.6), value: opacity)
                }
                .padding(.bottom, 50)
            }
            .padding()
        }
        .onAppear {
            startAnimations()
            
            // 3秒後に完了
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    onComplete()
                }
            }
        }
    }
    
    private func startAnimations() {
        // メインアイコンのスケールアニメーション
        withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
            scale = 1.0
        }
        
        // テキスト表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            opacity = 1.0
        }
    }
}

#Preview {
    LaunchView {
        print("Launch completed")
    }
}