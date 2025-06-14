import SwiftUI

struct AppIconGenerator: View {
    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.6, blue: 1.0),  // 明るい青
                    Color(red: 0.8, green: 0.4, blue: 0.9)   // 薄紫
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // メインのひらがな文字
            VStack(spacing: -10) {
                Text("あ")
                    .font(.system(size: 180, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                
                // 装飾的なキラキラ効果
                HStack(spacing: 30) {
                    Circle()
                        .fill(.yellow)
                        .frame(width: 25, height: 25)
                        .shadow(color: .yellow.opacity(0.6), radius: 6)
                    
                    Circle()
                        .fill(.white)
                        .frame(width: 20, height: 20)
                        .shadow(color: .white.opacity(0.8), radius: 4)
                    
                    Circle()
                        .fill(.yellow)
                        .frame(width: 25, height: 25)
                        .shadow(color: .yellow.opacity(0.6), radius: 6)
                }
                .offset(y: -20)
            }
            
            // 角の装飾
            VStack {
                HStack {
                    Circle()
                        .fill(.white.opacity(0.7))
                        .frame(width: 35, height: 35)
                    Spacer()
                }
                Spacer()
            }
            .padding(25)
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 180)) // iOS風の角丸
    }
}

#Preview {
    AppIconGenerator()
        .background(Color.gray.opacity(0.1))
}