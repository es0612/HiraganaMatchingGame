import Foundation

/// 間違えたときに選択肢に付ける印（#82）
enum AnswerChoiceMark: Equatable {
    /// 答えを見せていない
    case none
    /// 正解の絵（緑の枠と ○）
    case correct
    /// 選んだ絵（×）
    case wrongSelection
    /// それ以外（薄くする）
    case dimmed

    static func mark(for imageName: String, isRevealing: Bool, revealedAnswer: String?, selectedAnswer: String?) -> AnswerChoiceMark {
        guard isRevealing else { return .none }
        if imageName == revealedAnswer {
            return .correct
        }
        if imageName == selectedAnswer {
            return .wrongSelection
        }
        return .dimmed
    }
}
