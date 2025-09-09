import SwiftUI

struct InstructionTextView: View {
    var body: some View {
        Text("この文字に合う絵を選んでね！")
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(.primary.opacity(0.8))
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

#Preview {
    InstructionTextView()
        .padding()
}
