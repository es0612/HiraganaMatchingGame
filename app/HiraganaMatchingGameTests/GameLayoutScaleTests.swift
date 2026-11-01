import CoreGraphics
@testable import HiraganaMatchingGame
import Testing

/// ゲーム画面の大きさの段階（#80）。画面に収まる最初の段階を GameView が選ぶ
struct GameLayoutScaleTests {
    @Test("いちばん大きい段階は、今までの大きさのまま（広い画面の見た目を変えない）")
    func regularKeepsCurrentSizes() {
        let regular = GameLayoutScale.regular
        #expect(regular.hiraganaCardSize == 220)
        #expect(regular.hiraganaFontSize == 90)
        #expect(regular.choiceSize == 110)
        #expect(regular.spacing == 20)
    }

    @Test("段階は大きい順に並び、次の段階はどの寸法も小さい")
    func scalesShrinkInOrder() {
        let scales = GameLayoutScale.allCases
        #expect(scales.first == .regular)
        for (larger, smaller) in zip(scales, scales.dropFirst()) {
            #expect(smaller.hiraganaCardSize < larger.hiraganaCardSize)
            #expect(smaller.hiraganaFontSize < larger.hiraganaFontSize)
            #expect(smaller.choiceSize < larger.choiceSize)
            #expect(smaller.spacing <= larger.spacing)
        }
    }

    @Test("いちばん小さい段階でも、選択肢は子どもの指で押せる大きさを保つ")
    func smallestChoiceStaysTappable() {
        let smallest = GameLayoutScale.allCases.last
        #expect((smallest?.choiceSize ?? 0) >= 72)
    }
}
