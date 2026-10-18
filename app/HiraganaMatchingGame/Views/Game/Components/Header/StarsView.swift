import SwiftUI

struct StarsView: View {
    let earnedStars: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0 ..< 3, id: \.self) { index in
                Image(systemName: "star.fill")
                    .foregroundColor(index < earnedStars ? .yellow : .gray.opacity(0.3))
                    .font(.title2)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AccessibilityText.stars(earnedStars))
    }
}

#Preview {
    VStack(spacing: 20) {
        StarsView(earnedStars: 0)
        StarsView(earnedStars: 1)
        StarsView(earnedStars: 2)
        StarsView(earnedStars: 3)
    }
    .padding()
}
