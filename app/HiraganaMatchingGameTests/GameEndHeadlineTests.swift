@testable import HiraganaMatchingGame
import Testing

/// ゲームの終わりの見出しは、最後の 1 問の正誤ではなく星の数で決める (#129)
@Suite("終わりの画面の見出し (#129)")
struct GameEndHeadlineTests {
    @Test("終わりの見出しは星の数で 3 段階に分ける")
    func completedHeadlineByStars() {
        #expect(FeedbackView.texts(lastAnswerCorrect: true, isGameCompleted: true, earnedStars: 3)
            == FeedbackTexts(title: "すごい！ ぜんぶ せいかい！", subtitle: nil, isPositive: true))
        for stars in [1, 2] {
            #expect(FeedbackView.texts(lastAnswerCorrect: true, isGameCompleted: true, earnedStars: stars)
                == FeedbackTexts(title: "よく できたね！", subtitle: nil, isPositive: true))
        }
        #expect(FeedbackView.texts(lastAnswerCorrect: true, isGameCompleted: true, earnedStars: 0)
            == FeedbackTexts(title: "さいごまで がんばったね！", subtitle: nil, isPositive: true))
    }

    @Test("最後の 1 問をまちがえて終わっても、見出しは星の数で決まり、まちがいの表示にならない")
    func completedIgnoresLastAnswer() {
        let texts = FeedbackView.texts(lastAnswerCorrect: false, isGameCompleted: true, earnedStars: 2)
        #expect(texts.title == "よく できたね！")
        #expect(texts.isPositive)
    }

    @Test("星が 0〜3 の外でも、いちばん近い段階の見出しになる")
    func outOfRangeStarsClamp() {
        #expect(FeedbackView.texts(lastAnswerCorrect: true, isGameCompleted: true, earnedStars: -1).title == "さいごまで がんばったね！")
        #expect(FeedbackView.texts(lastAnswerCorrect: true, isGameCompleted: true, earnedStars: 4).title == "すごい！ ぜんぶ せいかい！")
    }

    @Test("途中で正解したときの表示は変えない")
    func midGameCorrectUnchanged() {
        #expect(FeedbackView.texts(lastAnswerCorrect: true, isGameCompleted: false, earnedStars: 0)
            == FeedbackTexts(title: "正解！", subtitle: "よくできました！", isPositive: true))
    }
}
