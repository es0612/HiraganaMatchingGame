import SwiftUI

struct TimeDisplayView: View {
    let timeRemaining: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.caption)
                .foregroundColor(.orange)
            Text(formatTime(timeRemaining))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    VStack(spacing: 20) {
        TimeDisplayView(timeRemaining: 300)
        TimeDisplayView(timeRemaining: 60)
        TimeDisplayView(timeRemaining: 5)
    }
    .padding()
}