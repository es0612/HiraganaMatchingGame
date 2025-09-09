import SwiftUI

struct SettingsButtonView: View {
    let onBackToLevelSelection: () -> Void
    
    var body: some View {
        Button(action: {
            onBackToLevelSelection()
        }) {
            Text("戻る")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray.opacity(0.6))
                )
        }
    }
}

#Preview {
    SettingsButtonView {
        print("Back button tapped")
    }
    .padding()
}