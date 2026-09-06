import SwiftUI

struct GameResultView: View {
    let score: Int
    let totalQuestions: Int
    let earnedStars: Int
    let accuracy: Double
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 15) {
            Text("ゲーム終了！")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            Text("スコア: \(score)/\(totalQuestions)")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            HStack(spacing: 5) {
                ForEach(0 ..< 3, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .foregroundColor(index < earnedStars ? .yellow : .gray.opacity(0.3))
                        .font(.title2)
                }
            }
            
            Text("正解率: \(Int(accuracy * 100))%")
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .gray : .gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(.systemGray6).opacity(0.8) : Color.white.opacity(0.9))
                .shadow(
                    color: colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.1),
                    radius: 5
                )
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        GameResultView(
            score: 8,
            totalQuestions: 10,
            earnedStars: 3,
            accuracy: 0.8
        )
        
        GameResultView(
            score: 5,
            totalQuestions: 8,
            earnedStars: 1,
            accuracy: 0.625
        )
    }
    .padding()
}
