# #129 終わりの画面の見出しと粒 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** ゲームの終わりの見出しを最後の 1 問の正誤ではなく星の数で決め、まちがえたときの ❌💔😢 の粒を出さない。

**Architecture:** 見出しと表示の文言を決める純粋な関数（`FeedbackView.texts`）と、粒を出す条件の関数（`ParticleEffectView.shouldShow`）を作ってユニットテストで守り、View はそれを呼ぶだけにする。

**Tech Stack:** SwiftUI、Swift Testing（`@Test` / `#expect`）、xcodebuild

**Spec:** `docs/superpowers/specs/2026-11-28-129-end-screen-design.md`

## Global Constraints
- 見出し（ゲーム終了時のみ）: ★3「すごい！ ぜんぶ せいかい！」／★1〜2「よく できたね！」／★0「さいごまで がんばったね！」（全角の「！」、単語の間は半角スペース）
- 途中で正解したときの表示「正解！」「よくできました！」は変えない
- まちがいの粒は出さない。ゲームが終わったら回答ごとの粒も出さない。「視差効果を減らす」が ON なら今どおり出さない
- 星の計算（`GameLogicService.calculateStars`）・紙吹雪（`GameView.swift:126`）・`GameResultView` は変えない
- 空行のインデントはそのファイルの書き方に合わせる（git hook が検査。CLAUDE.md「Lint」）
- テストは UDID 指定、結果は xcresult で読む（CLAUDE.md「ビルド・テスト」）

## Review Focus
- 星が 0〜3 の外（負の数・4 以上）: ★0 未満は ★0 の見出し、★3 超は ★3 の見出しになる → Task 1 のテスト `outOfRangeStarsClamp`
- 最後の 1 問をまちがえて ★2 で終わった回: 「よく できたね！」で、赤い ✖・「残念...」は出ない → Task 1 のテスト `completedIgnoresLastAnswer`
- 途中の正解（ゲーム未終了）: 今どおり「正解！」「よくできました！」→ Task 1 のテスト `midGameCorrectUnchanged`
- 最後に正解して終わった回: 終わりの画面では回答ごとの粒も止まる（紙吹雪だけ）→ Task 2 のテスト `noParticlesAfterCompletion`
- 時間切れ・スキップで、回答直後でないときに終わった回: `showFeedback` が false なので見出し（`FeedbackView`）はもともと出ない。今回は変えない（範囲外。PR 本文に書く）

---

### Task 1: 見出しを星の数で決める

**Files:**
- Modify: `app/HiraganaMatchingGame/Views/Game/Components/Feedback/FeedbackView.swift`（全体）
- Modify: `app/HiraganaMatchingGame/Views/Game/GameView.swift:189-201`（`earnedStars` を渡す）
- Test: `app/HiraganaMatchingGameTests/GameEndHeadlineTests.swift`（新規）

**Interfaces:**
- Produces:
  - `struct FeedbackTexts: Equatable { let title: String; let subtitle: String?; let isPositive: Bool }`（`FeedbackView.swift` 内）
  - `static func FeedbackView.texts(lastAnswerCorrect: Bool, isGameCompleted: Bool, earnedStars: Int) -> FeedbackTexts`
  - `FeedbackView` に `let earnedStars: Int` を追加（引数順: `lastAnswerCorrect, isGameCompleted, earnedStars, gameResultView`）

- [ ] **Step 1: Write the failing test**（`@Suite("終わりの画面の見出し (#129)")`）

```swift
@Test func completedHeadlineByStars() {
    #expect(FeedbackView.texts(lastAnswerCorrect: true, isGameCompleted: true, earnedStars: 3)
        == FeedbackTexts(title: "すごい！ ぜんぶ せいかい！", subtitle: nil, isPositive: true))
    for stars in [1, 2] {
        #expect(FeedbackView.texts(lastAnswerCorrect: true, isGameCompleted: true, earnedStars: stars)
            == FeedbackTexts(title: "よく できたね！", subtitle: nil, isPositive: true))
    }
    #expect(FeedbackView.texts(lastAnswerCorrect: true, isGameCompleted: true, earnedStars: 0)
        == FeedbackTexts(title: "さいごまで がんばったね！", subtitle: nil, isPositive: true))
}
@Test func completedIgnoresLastAnswer() {
    #expect(FeedbackView.texts(lastAnswerCorrect: false, isGameCompleted: true, earnedStars: 2).title == "よく できたね！")
    #expect(FeedbackView.texts(lastAnswerCorrect: false, isGameCompleted: true, earnedStars: 2).isPositive)
}
@Test func outOfRangeStarsClamp() {
    #expect(FeedbackView.texts(lastAnswerCorrect: true, isGameCompleted: true, earnedStars: -1).title == "さいごまで がんばったね！")
    #expect(FeedbackView.texts(lastAnswerCorrect: true, isGameCompleted: true, earnedStars: 4).title == "すごい！ ぜんぶ せいかい！")
}
@Test func midGameCorrectUnchanged() {
    #expect(FeedbackView.texts(lastAnswerCorrect: true, isGameCompleted: false, earnedStars: 0)
        == FeedbackTexts(title: "正解！", subtitle: "よくできました！", isPositive: true))
}
```

- [ ] **Step 2: Run test to verify it fails**
Run: `xcodebuild test ... -only-testing:HiraganaMatchingGameTests/GameEndHeadlineTests`（UDID 指定）
Expected: ビルドエラー「type 'FeedbackView' has no member 'texts'」

- [ ] **Step 3: Implement `FeedbackView.texts(...)` と表示の切り替え**
- `isGameCompleted` が true なら星の数で見出し（subtitle なし、`isPositive: true`）。false なら今の 2 通り（まちがいは「残念...」「次は頑張ろう！」`isPositive: false` のまま。#82 の画面があるので通常は出ないが、挙動は変えない）
- body は `texts` を使い、`isPositive` が true のときアイコン: ゲーム終了時は `star.circle.fill`（`.yellow`）、途中の正解は今の `checkmark.circle.fill`（`.green`）。false は今の `xmark.circle.fill`（`.red`）
- `GameView` から `earnedStars: gameViewModel.earnedStars` を渡す。`#Preview` も新しい引数に合わせ、終了時の例を ★0・★2・★3 にする

- [ ] **Step 4: Run test to verify it passes**
Expected: `GameEndHeadlineTests` 4 件 PASS

- [ ] **Step 5: Commit**（パス指定で stage、`git diff | cat -e` で空行を確認）

---

### Task 2: まちがいの粒と、終了後の粒を出さない

**Files:**
- Modify: `app/HiraganaMatchingGame/Views/Components/ParticleEffectView.swift`（static 関数を追加）
- Modify: `app/HiraganaMatchingGame/Views/Game/GameView.swift:117-123`
- Test: `app/HiraganaMatchingGameTests/GameEndHeadlineTests.swift`（同じファイルに Suite を追加）

**Interfaces:**
- Produces: `static func ParticleEffectView.shouldShow(showFeedback: Bool, lastAnswerCorrect: Bool, isGameCompleted: Bool, reduceMotion: Bool) -> Bool`

- [ ] **Step 1: Write the failing test**（`@Suite("回答ごとの粒 (#129)")`）

```swift
@Test func onlyCorrectMidGame() {
    #expect(ParticleEffectView.shouldShow(showFeedback: true, lastAnswerCorrect: true, isGameCompleted: false, reduceMotion: false))
    #expect(!ParticleEffectView.shouldShow(showFeedback: true, lastAnswerCorrect: false, isGameCompleted: false, reduceMotion: false))
}
@Test func noParticlesAfterCompletion() {
    #expect(!ParticleEffectView.shouldShow(showFeedback: true, lastAnswerCorrect: true, isGameCompleted: true, reduceMotion: false))
}
@Test func respectsReduceMotionAndFeedback() {
    #expect(!ParticleEffectView.shouldShow(showFeedback: true, lastAnswerCorrect: true, isGameCompleted: false, reduceMotion: true))
    #expect(!ParticleEffectView.shouldShow(showFeedback: false, lastAnswerCorrect: true, isGameCompleted: false, reduceMotion: false))
}
```

- [ ] **Step 2: Run test to verify it fails**
Expected: ビルドエラー「type 'ParticleEffectView' has no member 'shouldShow'」

- [ ] **Step 3: Implement `shouldShow` and use it in `GameView`**
- 条件は `showFeedback && lastAnswerCorrect && !isGameCompleted && !reduceMotion`
- `GameView.swift:119` の `if` をこの関数に置き換える。`ParticleEffectView(isCorrect:)` の呼び出しと中身は変えない（まちがいの絵文字の分岐は呼ばれなくなる。整理は #74 か #110 で）。コメントの #90 の説明は残し、#129 を足す

- [ ] **Step 4: Run all unit tests**
Run: `-only-testing:HiraganaMatchingGameTests` で全件
Expected: 215 + 7 = 222 件 PASS（`Test run with 222 tests`）

- [ ] **Step 5: Lint・commit**
ルートから `swiftformat --lint` と `swiftlint lint --strict --quiet`（変更ファイル）で 0 件 → パス指定で commit

---

### Task 3: 見た目を確かめて PR を出す

- [ ] **Step 1:** 使い捨てのテストで `FeedbackView`（終了時 ★0・★2・★3、`GameResultView` 付き）を `ImageRenderer` で PNG にし、シミュレータの一時ディレクトリに書き出して読む。見出しが 1 行に収まるか、赤い ✖ が出ないかを見る。確かめたらテストは消す（コミットしない）
- [ ] **Step 2:** 設計の「時間切れで終わったときも星の数で見出しを決める」を「見出しが出る場合（回答直後に終わった場合）は星の数で決める。回答直後でないときは見出しはもともと出ない」に直してコミット
- [ ] **Step 3:** push → PR（`Refs #129`。実機・シミュレータでの通しの確認は未実施と書く）。CI の全コミットの `Test run with N tests` を確かめる
