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

/// まちがえたときの ❌💔😢 と、ゲームが終わったあとの回答ごとの粒は出さない (#129)
@Suite("回答ごとの粒 (#129)")
struct AnswerParticlesTests {
    @Test("粒は、途中で正解したときだけ出す")
    func onlyCorrectMidGame() {
        #expect(ParticleEffectView.shouldShow(showFeedback: true, lastAnswerCorrect: true, isGameCompleted: false, reduceMotion: false))
        #expect(!ParticleEffectView.shouldShow(showFeedback: true, lastAnswerCorrect: false, isGameCompleted: false, reduceMotion: false))
    }

    @Test("ゲームが終わったら、最後に正解していても回答ごとの粒は出さない（お祝いは紙吹雪）")
    func noParticlesAfterCompletion() {
        #expect(!ParticleEffectView.shouldShow(showFeedback: true, lastAnswerCorrect: true, isGameCompleted: true, reduceMotion: false))
    }

    @Test("「視差効果を減らす」が ON のときと、答えを見せていないときは出さない")
    func respectsReduceMotionAndFeedback() {
        #expect(!ParticleEffectView.shouldShow(showFeedback: true, lastAnswerCorrect: true, isGameCompleted: false, reduceMotion: true))
        #expect(!ParticleEffectView.shouldShow(showFeedback: false, lastAnswerCorrect: true, isGameCompleted: false, reduceMotion: false))
    }

    @Test("16 通りのうち、粒を出すのは「答えを見せている・正解・終わっていない・視差効果 OFF」の 1 通りだけ")
    func allCombinations() {
        var shown: [[Bool]] = []
        for showFeedback in [false, true] {
            for correct in [false, true] {
                for completed in [false, true] {
                    for reduceMotion in [false, true]
                        where ParticleEffectView.shouldShow(
                            showFeedback: showFeedback,
                            lastAnswerCorrect: correct,
                            isGameCompleted: completed,
                            reduceMotion: reduceMotion
                        ) {
                        shown.append([showFeedback, correct, completed, reduceMotion])
                    }
                }
            }
        }
        #expect(shown == [[true, true, false, false]])
    }
}
