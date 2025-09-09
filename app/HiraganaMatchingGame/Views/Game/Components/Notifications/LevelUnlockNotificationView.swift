import SwiftUI

struct LevelUnlockNotificationView: View {
    let unlockedLevel: Int
    let showNotification: Bool
    let onDismiss: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
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
                    .scaleEffect(showNotification ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showNotification)
                
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(showNotification ? 1.0 : 0.3)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: showNotification)
            }
            
            VStack(spacing: 8) {
                Text("🎉 新しいレベルが解放！")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .scaleEffect(showNotification ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showNotification)
                
                Text("レベル \(unlockedLevel) がプレイできるようになりました！")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                    .multilineTextAlignment(.center)
                    .opacity(showNotification ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.8).delay(0.4), value: showNotification)
            }
            
            Button(action: {
                withAnimation(.easeOut(duration: 0.5)) {
                    onDismiss()
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
        .scaleEffect(showNotification ? 1.0 : 0.8)
        .opacity(showNotification ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showNotification)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
        
        VStack(spacing: 40) {
            LevelUnlockNotificationView(
                unlockedLevel: 5,
                showNotification: true,
                onDismiss: { print("Dismissed") }
            )
            
            LevelUnlockNotificationView(
                unlockedLevel: 10,
                showNotification: false,
                onDismiss: { print("Dismissed") }
            )
        }
    }
}