//
//  GameOverlayView.swift
//  HiraganaMatchingGame
//
//

import SwiftUI

struct GameOverlayView: View {
    let showFeedback: Bool
    let lastAnswerCorrect: Bool
    let isGameCompleted: Bool
    let earnedStars: Int
    let showLevelUnlockNotification: Bool
    let unlockedLevel: Int
    let onNotificationDismissed: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // パーティクルエフェクト
            if showFeedback {
                ParticleEffectView(isCorrect: lastAnswerCorrect)
                    .allowsHitTesting(false)
                    .zIndex(50)
            }
            
            // ゲーム完了時の紙吹雪
            if isGameCompleted && earnedStars > 0 {
                ConfettiView()
                    .allowsHitTesting(false)
                    .zIndex(60)
            }
            
            // レベル解放通知オーバーレイ
            if showLevelUnlockNotification {
                levelUnlockNotificationView
                    .zIndex(100)
            }
        }
    }
    
    private var levelUnlockNotificationView: some View {
        VStack(spacing: 20) {
            // アニメーション付き鍵アイコン
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(showLevelUnlockNotification ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showLevelUnlockNotification)
                
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(showLevelUnlockNotification ? 1.0 : 0.3)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: showLevelUnlockNotification)
            }
            
            VStack(spacing: 8) {
                Text("🎉 新しいレベルが解放！")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .scaleEffect(showLevelUnlockNotification ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showLevelUnlockNotification)
                
                Text("レベル \(unlockedLevel) がプレイできるようになりました！")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                    .multilineTextAlignment(.center)
                    .opacity(showLevelUnlockNotification ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.8).delay(0.4), value: showLevelUnlockNotification)
            }
            
            Button(action: {
                withAnimation(.easeOut(duration: 0.5)) {
                    onNotificationDismissed()
                }
            }) {
                Text("続行")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(22)
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(
                    color: colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.2),
                    radius: 10,
                    x: 0,
                    y: 5
                )
        )
        .scaleEffect(showLevelUnlockNotification ? 1.0 : 0.8)
        .opacity(showLevelUnlockNotification ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showLevelUnlockNotification)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()
        
        VStack(spacing: 50) {
            // パーティクルエフェクトのプレビュー
            GameOverlayView(
                showFeedback: true,
                lastAnswerCorrect: true,
                isGameCompleted: false,
                earnedStars: 0,
                showLevelUnlockNotification: false,
                unlockedLevel: 0,
                onNotificationDismissed: {}
            )
            
            // レベル解放通知のプレビュー
            GameOverlayView(
                showFeedback: false,
                lastAnswerCorrect: false,
                isGameCompleted: false,
                earnedStars: 0,
                showLevelUnlockNotification: true,
                unlockedLevel: 3,
                onNotificationDismissed: { print("Notification dismissed") }
            )
        }
    }
}