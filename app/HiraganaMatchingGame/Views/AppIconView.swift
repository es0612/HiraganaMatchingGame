import SwiftUI

/// アプリアイコン生成用のビュー（開発・デザイン用）
struct AppIconView: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // ベースのグラデーション背景
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.4, blue: 0.6), // ピンク
                    Color(red: 1.0, green: 0.6, blue: 0.2)  // オレンジ
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 柔らかい円形の装飾
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: size * 0.8, height: size * 0.8)
                .offset(x: -size * 0.1, y: -size * 0.1)
            
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: size * 0.6, height: size * 0.6)
                .offset(x: size * 0.15, y: size * 0.15)
            
            // メインのひらがな文字「あ」
            VStack(spacing: size * 0.02) {
                Text("あ")
                    .font(.system(size: size * 0.45, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: size * 0.01, x: 0, y: size * 0.005)
                
                // 小さな装飾要素
                HStack(spacing: size * 0.02) {
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: size * 0.04, height: size * 0.04)
                    
                    RoundedRectangle(cornerRadius: size * 0.01)
                        .fill(Color.white.opacity(0.6))
                        .frame(width: size * 0.06, height: size * 0.02)
                    
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: size * 0.04, height: size * 0.04)
                }
            }
            
            // コーナーの小さなハート
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .font(.system(size: size * 0.08))
                        .foregroundColor(.white.opacity(0.7))
                        .offset(x: -size * 0.08, y: size * 0.08)
                }
                Spacer()
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2237)) // iOS標準の角丸比率
    }
}

/// ダークモード対応アプリアイコン
struct AppIconDarkView: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // ダークモード用のグラデーション背景
            LinearGradient(
                colors: [
                    Color(red: 0.3, green: 0.2, blue: 0.8), // 深い紫
                    Color(red: 0.8, green: 0.3, blue: 0.6)  // ピンク
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 柔らかい円形の装飾
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: size * 0.8, height: size * 0.8)
                .offset(x: -size * 0.1, y: -size * 0.1)
            
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: size * 0.6, height: size * 0.6)
                .offset(x: size * 0.15, y: size * 0.15)
            
            // メインのひらがな文字「あ」
            VStack(spacing: size * 0.02) {
                Text("あ")
                    .font(.system(size: size * 0.45, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: size * 0.01, x: 0, y: size * 0.005)
                
                // 小さな装飾要素
                HStack(spacing: size * 0.02) {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: size * 0.04, height: size * 0.04)
                    
                    RoundedRectangle(cornerRadius: size * 0.01)
                        .fill(Color.white.opacity(0.7))
                        .frame(width: size * 0.06, height: size * 0.02)
                    
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: size * 0.04, height: size * 0.04)
                }
            }
            
            // コーナーの小さなハート
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .font(.system(size: size * 0.08))
                        .foregroundColor(.white.opacity(0.8))
                        .offset(x: -size * 0.08, y: size * 0.08)
                }
                Spacer()
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2237)) // iOS標準の角丸比率
    }
}

/// Tinted対応アプリアイコン
struct AppIconTintedView: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // ベースカラー（システムがtintを適用）
            Color.primary
            
            // シンプルな文字のみ
            Text("あ")
                .font(.system(size: size * 0.5, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2237))
    }
}

#Preview("App Icon Light") {
    AppIconView(size: 200)
}

#Preview("App Icon Dark") {
    AppIconDarkView(size: 200)
}

#Preview("App Icon Tinted") {
    AppIconTintedView(size: 200)
        .background(Color.blue) // システムtintカラーのシミュレーション
}