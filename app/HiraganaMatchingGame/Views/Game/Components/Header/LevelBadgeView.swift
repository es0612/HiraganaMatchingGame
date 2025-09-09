import SwiftUI

struct LevelBadgeView: View {
    let level: Int
    
    var body: some View {
        Text("レベル \(level)")
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.9), Color.orange.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            )
    }
}

#Preview {
    LevelBadgeView(level: 5)
        .padding()
}