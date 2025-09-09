import SwiftUI

struct ProgressBarView: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 10)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.8), Color.blue.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 10)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 10)
        .frame(maxWidth: 200)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBarView(progress: 0.3)
        ProgressBarView(progress: 0.7)
        ProgressBarView(progress: 1.0)
    }
    .padding()
}