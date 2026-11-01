import Foundation
@testable import HiraganaMatchingGame
import Testing

/// 間違えたときに正解を見せる（#82）
@Suite("間違えたら正解を見せる (#82)")
struct WrongAnswerRevealTests {
    // MARK: - 選択肢の印

    @Test("答えを見せていない間は、どの選択肢にも印を付けない")
    func noMarksWhileNotRevealing() {
        let mark = AnswerChoiceMark.mark(for: "dog", isRevealing: false, revealedAnswer: "dog", selectedAnswer: "fish")
        #expect(mark == .none)
    }

    @Test("答えを見せている間は、正解に ○、選んだ絵に ×、ほかは薄くする")
    func marksWhileRevealing() {
        func mark(_ name: String) -> AnswerChoiceMark {
            AnswerChoiceMark.mark(for: name, isRevealing: true, revealedAnswer: "dog", selectedAnswer: "fish")
        }
        #expect(mark("dog") == .correct)
        #expect(mark("fish") == .wrongSelection)
        #expect(mark("boat") == .dimmed)
    }

    @Test("VoiceOver は、正解を「こたえ」、選んだ絵を「えらんだ絵」と読む")
    func accessibilityLabelsForMarks() {
        #expect(AccessibilityText.answerChoice(reading: "いぬ", mark: .correct) == "いぬの絵、こたえ")
        #expect(AccessibilityText.answerChoice(reading: "さかな", mark: .wrongSelection) == "さかなの絵、えらんだ絵")
        #expect(AccessibilityText.answerChoice(reading: "ふね", mark: .dimmed) == "ふねの絵")
        #expect(AccessibilityText.answerChoice(reading: "ふね", mark: .none) == "ふねの絵")
    }

    // MARK: - ViewModel

    @Test("間違えたら、正解の絵と選んだ絵を覚えておく")
    func wrongAnswerRemembersCorrectAndSelected() throws {
        let viewModel = GameViewModel(isTestMode: true)
        viewModel.startNewGame(level: 1)
        let correct = viewModel.getCorrectAnswer().imageName
        let wrong = try #require(viewModel.answerChoices.map(\.imageName).first { $0 != correct })

        viewModel.selectAnswer(wrong)

        #expect(viewModel.lastAnswerCorrect == false)
        #expect(viewModel.revealedAnswer == correct)
        #expect(viewModel.selectedAnswer == wrong)
    }

    @Test("正解したら、見せる答えは残らない")
    func correctAnswerClearsReveal() throws {
        let viewModel = GameViewModel(isTestMode: true)
        viewModel.startNewGame(level: 1)
        let firstCorrect = viewModel.getCorrectAnswer().imageName
        let wrong = try #require(viewModel.answerChoices.map(\.imageName).first { $0 != firstCorrect })
        viewModel.selectAnswer(wrong)

        viewModel.selectAnswer(viewModel.getCorrectAnswer().imageName)

        #expect(viewModel.lastAnswerCorrect == true)
        #expect(viewModel.revealedAnswer == nil)
        #expect(viewModel.selectedAnswer == nil)
    }

    @Test("間違えたら、正解の単語を読み上げる")
    func wrongAnswerSpeaksCorrectWord() async throws {
        let speech = RecordingSpeech()
        let manager = AudioManager(isTestMode: true, speech: speech)
        let viewModel = GameViewModel(
            audioService: AudioService.createForTesting(audioManager: manager),
            isTestMode: true
        )
        viewModel.startNewGame(level: 1)
        let correct = viewModel.getCorrectAnswer().imageName
        let word = try #require(HiraganaDataManager.shared.getJapaneseWord(for: correct))
        let wrong = try #require(viewModel.answerChoices.map(\.imageName).first { $0 != correct })
        viewModel.selectAnswer(wrong)

        await viewModel.speakRevealedAnswer()

        #expect(speech.calls == ["text:\(word)"])
    }

    // MARK: - 待ち方
    //
    // 時間で判定するテストは、判定のしきい値（30 秒）と、壊れたときにかかる時間（60 秒以上）の差を大きく取る。
    // CI では全テストが並列で走り、Task が動き出すまで 1 秒以上かかることがある
    // （2026-11-01: 「1.0 秒未満」の判定が CI で 1.47 秒になって落ちた）

    @Test("終わらない処理でも、最長の時間で待つのをやめる")
    func waitStopsAtLimit() async {
        let start = Date()
        await FeedbackTiming.wait(atMost: 0.3) {
            try? await Task.sleep(nanoseconds: 120_000_000_000)
        }
        let elapsed = Date().timeIntervalSince(start)
        #expect(elapsed >= 0.25)
        #expect(elapsed < 30)
    }

    @Test("すぐ終わる処理なら、最長の時間まで待たない")
    func waitReturnsWhenDone() async {
        let start = Date()
        await FeedbackTiming.wait(atMost: 60) {}
        #expect(Date().timeIntervalSince(start) < 30)
    }

    @Test("待っている途中でキャンセルされたら、最長の時間を待たずにすぐやめる（画面を離れたとき）")
    func waitStopsWhenCancelled() async {
        let start = Date()
        let task = Task {
            await FeedbackTiming.wait(atMost: 60) {
                try? await Task.sleep(nanoseconds: 120_000_000_000)
            }
        }
        try? await Task.sleep(nanoseconds: 200_000_000)
        task.cancel()
        await task.value
        #expect(Date().timeIntervalSince(start) < 30)
    }

    @Test("ゲームが終わったあと（時間切れなど）に次へ進む処理が走っても、何もしない")
    func finishFeedbackAfterGameCompletedDoesNothing() {
        let viewModel = GameViewModel(isTestMode: true)
        viewModel.startNewGame(level: 1)
        viewModel.handleTimerTick() // 残り時間 0 のまま tick → 時間切れで終了
        #expect(viewModel.isGameCompleted)
        viewModel.showFeedback = true
        let hiragana = viewModel.currentHiragana

        viewModel.finishFeedback(isLastQuestion: false)

        #expect(viewModel.showFeedback == true)
        #expect(viewModel.currentHiragana == hiragana)
    }

    @Test("今より早く次の問題へ進まないよう、最低の待ち時間の残りを返す")
    func remainingWaitKeepsMinimum() {
        #expect(FeedbackTiming.remainingWait(elapsed: 0.5, minimum: 1.5) == 1.0)
        #expect(FeedbackTiming.remainingWait(elapsed: 3.0, minimum: 1.5) == 0)
    }
}
