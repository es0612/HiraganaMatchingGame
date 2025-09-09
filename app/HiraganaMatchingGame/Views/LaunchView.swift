import Foundation
import SwiftUI

struct LaunchView: View {
    @State private var scale = 0.5
    @State private var opacity = 0.0
    @Environment(\.colorScheme) var colorScheme
    
    let onComplete: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
            // 背景のグラデーション
            LinearGradient(
                colors: colorScheme == .dark ? [
                    Color(red: 0.4, green: 0.2, blue: 0.3), // ダークピンク
                    Color(red: 0.5, green: 0.3, blue: 0.1), // ダークオレンジ
                    Color(red: 0.4, green: 0.1, blue: 0.4)  // ダーク紫
                ] : [
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
                        .fill(Color.primary.opacity(0.1))
                        .frame(width: min(geometry.size.width * 0.4, 200), height: min(geometry.size.width * 0.4, 200))
                        .scaleEffect(scale)
                        .animation(.spring(response: 1.0, dampingFraction: 0.6), value: scale)
                    
                    // メインの「あ」文字
                    Text("あ")
                        .font(.system(size: min(geometry.size.width * 0.25, 120), weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.white)
                        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                        .scaleEffect(scale)
                        .animation(.spring(response: 1.2, dampingFraction: 0.5).delay(0.2), value: scale)
                }
                
                // アプリ名
                VStack(spacing: 10) {
                    Text("ひらがな")
                        .font(.system(size: min(geometry.size.width * 0.08, 36), weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.white)
                        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 0.6).delay(0.8), value: opacity)
                    
                    Text("マッチングゲーム")
                        .font(.system(size: min(geometry.size.width * 0.055, 24), weight: .semibold, design: .rounded))
                        .foregroundColor((colorScheme == .dark ? Color.white : Color.white).opacity(0.9))
                        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
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
                        .font(.system(size: min(geometry.size.width * 0.04, 18), weight: .medium, design: .rounded))
                        .foregroundColor((colorScheme == .dark ? Color.white : Color.white).opacity(0.8))
                        .multilineTextAlignment(.center)
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 0.6).delay(1.6), value: opacity)
                }
                .padding(.bottom, 50)
            }
            .padding()
        }
        }
        .onAppear {
            startAnimations()
            
            // 一定時間後に完了
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Timing.launchDuration) {
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
