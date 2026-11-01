import SwiftUI

struct InstructionTextView: View {
    /// 間違えたときに正解を見せている間は、説明文の代わりに出す（#82）
    var isRevealingAnswer = false
    
    var body: some View {
        Text(isRevealingAnswer ? "ざんねん！ こたえは これだよ" : "この文字に合う絵を選んでね！")
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(isRevealingAnswer ? .orange : .primary.opacity(0.8))
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

#Preview {
    InstructionTextView()
        .padding()
}
