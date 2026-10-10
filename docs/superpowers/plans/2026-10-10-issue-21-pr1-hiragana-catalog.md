# #21 PR1: ひらがな行の単一定義と AudioManager プリロード修正 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** ひらがなの行・レベル構成の正を 1 つ（`HiraganaCatalog`）作り、な行で止まっている `AudioManager` のプリロードをそこから読むように直す。

**Architecture:** `Models/HiraganaCatalog.swift` に、値だけを持つ `enum` を置く（行名・文字・解放スター）。レベル n は「先頭から n 行分の文字の累積」と定義する。PR1 で移行するのは `AudioManager` だけ。残る 4 ファイル（`LevelProgressionService` / `CharacterUnlockService` / `CharacterCollectionView` / `HiraganaGameService`）は PR2 で移す。PR1 では、Catalog と `LevelProgressionService` の値がレベル 1〜10 で一致することをテストで固定し、PR2 の移行が安全であることを保証する。

**Tech Stack:** Swift 5 / SwiftUI、Swift Testing（`@Test` / `#expect`）、xcodebuild。Xcode プロジェクトは file-system synchronized group なので、`app/HiraganaMatchingGame/` と `app/HiraganaMatchingGameTests/` に置いたファイルは pbxproj を編集しなくてもターゲットに入る。

**Spec:** Issue #21 の本文と、2026-10-10 のコメント（前提の変化と PO 判断）。`gh issue view 21 --comments`

## Global Constraints

- ひらがなは現代仮名 46 文字。旧仮名「ゐ」「ゑ」は扱わない（#22）
- 行の構成と解放スター：あ0・か2・さ4・た6・な8・は10・ま12・や14（や/ゆ/よ）・ら16・わ18（わ/を/ん）
- `GameLevel`（@Model）と SwiftData のスキーマには触れない（#33 に回した）
- 文字ごとの対応表（`HiraganaItemRepository` / `GameLogicService` のヒント / `SpeechSynthesizer`）は対象外
- `questionsCount` の削除と docs の修正は PR2。PR1 では触れない
- pbxproj の `CURRENT_PROJECT_VERSION` / `MARKETING_VERSION` は触れない（1.0.2 のまま。`app/` の変更なので、マージすると Xcode Cloud が 1.0.2 をビルドする）
- swiftlint はリポジトリルートから実行する（`--strict` + baseline）。`swiftformat .` もルートから実行する
- テストで `GameViewModel` を作るときは `isTestMode: true`。`AudioManager` は `AudioManager(isTestMode: true)`
- PR 本文は `Refs #21` だけにする（PR2 が残っているので close しない）

## Review Focus

1. **レベル 6〜10 で、は行以降の文字がプリロード対象に入る**（これが今回のバグ。今は な行までで止まる）→ Task 2 のテスト `levelsSixToTenIncludeAllRows`
2. **範囲外のレベル（0、-1、11、99）でもクラッシュしない**：1 未満はあ行の 5 文字、10 を超えたら 46 文字すべて（今の `AudioManager` のクランプと同じ）→ Task 1 のテスト `outOfRangeLevelsClamp`
3. **Catalog とゲーム本体（`LevelProgressionService`）がレベル 1〜10 で同じ文字列を返す**：順序も含めて一致する。ずれると、プリロードと出題がずれる → Task 1 のテスト `matchesLevelProgressionService`
4. **46 文字で、重複がなく、ゐ/ゑ を含まない** → Task 1 のテスト `allCharactersAreModern46`
5. **レベル n は累積**（レベル 3 は あ・か・さ行の 15 文字。さ行の 5 文字だけではない）→ Task 1 のテスト `matchesLevelProgressionService` が、件数と順序の一致で固定する

---

## Task 0: ブランチ作成と UDID の確認

- [ ] **Step 1: main を最新にしてブランチを切る**

```bash
cd /Users/shinya/workspace/claude/HiraganaMatchingGame
git checkout main && git pull --ff-only
git checkout -b feature/issue-21-pr1-hiragana-catalog
```

`.vscode/settings.json` にユーザーの未コミット変更がある。**`git add -A` / `git commit -a` は使わず、必ずパスを指定して stage する。**

- [ ] **Step 2: テスト用シミュレータの UDID を控える**

```bash
xcrun simctl list devices available | grep -E 'iPhone 1[5-7]' | head -3
```

以降の `<UDID>` は、ここで選んだ 1 台の UDID に置き換える。

---

### Task 1: `HiraganaCatalog`（行・レベルの単一定義）

**Files:**
- Create: `app/HiraganaMatchingGame/Models/HiraganaCatalog.swift`
- Test: `app/HiraganaMatchingGameTests/HiraganaCatalogTests.swift`

**Interfaces:**
- Consumes: `LevelProgressionService(forTesting: true).getLevelConfiguration(_:) -> LevelConfiguration`（既存。`.characters: [String]`）
- Produces:
  - `enum HiraganaCatalog`
  - `struct HiraganaCatalog.Row { let name: String; let characters: [String]; let requiredStars: Int }`
  - `static let rows: [Row]`（10 行）
  - `static var totalLevels: Int`（= `rows.count`）
  - `static var allCharacters: [String]`（46 文字、あ→ん の順）
  - `static func characters(upToLevel level: Int) -> [String]`（1 未満は 1、`totalLevels` を超えたら `totalLevels` にクランプ）

- [ ] **Step 1: 失敗するテストを書く**

`app/HiraganaMatchingGameTests/HiraganaCatalogTests.swift`

```swift
@testable import HiraganaMatchingGame
import Testing

@Suite("ひらがな行・レベルの単一定義 (#21)")
struct HiraganaCatalogTests {
    @Test("10 行で、解放スターは 0 から 2 刻み")
    func rowsAndStars() {
        #expect(HiraganaCatalog.rows.map(\.name) == ["あ行", "か行", "さ行", "た行", "な行", "は行", "ま行", "や行", "ら行", "わ行"])
        #expect(HiraganaCatalog.rows.map(\.requiredStars) == [0, 2, 4, 6, 8, 10, 12, 14, 16, 18])
        #expect(HiraganaCatalog.totalLevels == 10)
    }

    @Test("現代仮名 46 文字・重複なし・ゐ/ゑ を含まない")
    func allCharactersAreModern46() {
        let all = HiraganaCatalog.allCharacters
        #expect(all.count == 46)
        #expect(Set(all).count == 46)
        #expect(!all.contains("ゐ"))
        #expect(!all.contains("ゑ"))
        #expect(all.first == "あ")
        #expect(all.last == "ん")
    }

    @Test("レベル 1〜10 の文字が LevelProgressionService と順序まで一致する", arguments: 1 ... 10)
    func matchesLevelProgressionService(level: Int) {
        let expected = LevelProgressionService(forTesting: true).getLevelConfiguration(level).characters
        #expect(HiraganaCatalog.characters(upToLevel: level) == expected)
    }

    @Test("範囲外のレベルはクランプする", arguments: [(0, 5), (-1, 5), (11, 46), (99, 46)])
    func outOfRangeLevelsClamp(level: Int, expectedCount: Int) {
        #expect(HiraganaCatalog.characters(upToLevel: level).count == expectedCount)
    }
}
```

- [ ] **Step 2: 失敗を確認する**

```bash
cd /Users/shinya/workspace/claude/HiraganaMatchingGame/app
xcodebuild test -project HiraganaMatchingGame.xcodeproj -scheme HiraganaMatchingGame \
  -destination 'platform=iOS Simulator,id=<UDID>' \
  -only-testing:HiraganaMatchingGameTests/HiraganaCatalogTests > /tmp/t1-red.log 2>&1; echo "exit=$?"
grep -m3 "cannot find 'HiraganaCatalog'" /tmp/t1-red.log
```

期待：`exit=65`。`cannot find 'HiraganaCatalog' in scope` でコンパイルに失敗する。

- [ ] **Step 3: 最小の実装を書く**

`app/HiraganaMatchingGame/Models/HiraganaCatalog.swift`

```swift
import Foundation

/// ひらがなの行・レベル構成の唯一の定義（#21）。
/// レベル n は rows の先頭 n 行の文字を累積したもの。
enum HiraganaCatalog {
    struct Row {
        let name: String
        let characters: [String]
        let requiredStars: Int
    }

    static let rows: [Row] = [
        Row(name: "あ行", characters: ["あ", "い", "う", "え", "お"], requiredStars: 0),
        Row(name: "か行", characters: ["か", "き", "く", "け", "こ"], requiredStars: 2),
        Row(name: "さ行", characters: ["さ", "し", "す", "せ", "そ"], requiredStars: 4),
        Row(name: "た行", characters: ["た", "ち", "つ", "て", "と"], requiredStars: 6),
        Row(name: "な行", characters: ["な", "に", "ぬ", "ね", "の"], requiredStars: 8),
        Row(name: "は行", characters: ["は", "ひ", "ふ", "へ", "ほ"], requiredStars: 10),
        Row(name: "ま行", characters: ["ま", "み", "む", "め", "も"], requiredStars: 12),
        Row(name: "や行", characters: ["や", "ゆ", "よ"], requiredStars: 14),
        Row(name: "ら行", characters: ["ら", "り", "る", "れ", "ろ"], requiredStars: 16),
        Row(name: "わ行", characters: ["わ", "を", "ん"], requiredStars: 18)
    ]

    static var totalLevels: Int {
        rows.count
    }

    static var allCharacters: [String] {
        rows.flatMap(\.characters)
    }

    /// 1 未満は 1、totalLevels を超えたら totalLevels として扱う。
    static func characters(upToLevel level: Int) -> [String] {
        let clamped = min(max(level, 1), totalLevels)
        return rows.prefix(clamped).flatMap(\.characters)
    }
}
```

- [ ] **Step 4: パスを確認する**

```bash
xcodebuild test -project HiraganaMatchingGame.xcodeproj -scheme HiraganaMatchingGame \
  -destination 'platform=iOS Simulator,id=<UDID>' \
  -only-testing:HiraganaMatchingGameTests/HiraganaCatalogTests \
  -resultBundlePath /tmp/t1-green.xcresult > /tmp/t1-green.log 2>&1; echo "exit=$?"
xcrun xcresulttool get test-results summary --path /tmp/t1-green.xcresult
```

期待：`exit=0`。summary の passed 件数が **0 でないこと**（`-only-testing` が 0 件で通る偽の緑を防ぐ。引数付きテストも含めて 16 件前後）。

- [ ] **Step 5: コミットする**

```bash
cd /Users/shinya/workspace/claude/HiraganaMatchingGame
git add app/HiraganaMatchingGame/Models/HiraganaCatalog.swift app/HiraganaMatchingGameTests/HiraganaCatalogTests.swift
git commit -m "feat: ひらがな行・レベルの単一定義 HiraganaCatalog を追加する (#21)"
```

---

### Task 2: `AudioManager` のプリロードを Catalog から読む

**Files:**
- Modify: `app/HiraganaMatchingGame/Services/Audio/AudioManager.swift:97-108`（`preloadAudioForLevel`）と `:281-294`（`getLevelConfiguration`）
- Test: `app/HiraganaMatchingGameTests/AudioPreloadTests.swift`

**Interfaces:**
- Consumes: `HiraganaCatalog.characters(upToLevel:)`（Task 1）
- Produces: `AudioManager.preloadCharacters(forLevel level: Int) -> [String]`（internal。`private func getLevelConfiguration(_:)` を置き換える）

- [ ] **Step 1: 振る舞いのまま関数を internal にして名前を変える（RED の準備）**

`AudioManager.swift` の `private func getLevelConfiguration(_ level: Int) -> [String]` を、**中身は変えずに** `func preloadCharacters(forLevel level: Int) -> [String]` にする。102 行目の呼び出し `let levelConfig = getLevelConfiguration(level)` も `let levelConfig = preloadCharacters(forLevel: level)` に変える。これで、テストが「コンパイルエラー」ではなく「値の違い」で落ちる。

- [ ] **Step 2: 失敗するテストを書く**

`app/HiraganaMatchingGameTests/AudioPreloadTests.swift`

```swift
@testable import HiraganaMatchingGame
import Testing

@Suite("音声プリロード対象 (#21)")
struct AudioPreloadTests {
    @Test("レベル 6〜10 で、その行までの全文字がプリロード対象になる", arguments: 6 ... 10)
    func levelsSixToTenIncludeAllRows(level: Int) {
        let manager = AudioManager(isTestMode: true)
        let expected = LevelProgressionService(forTesting: true).getLevelConfiguration(level).characters
        #expect(manager.preloadCharacters(forLevel: level) == expected)
    }

    @Test("レベル 10 は 46 文字すべて（ん まで）")
    func levelTenCoversAllHiragana() {
        let manager = AudioManager(isTestMode: true)
        let characters = manager.preloadCharacters(forLevel: 10)
        #expect(characters.count == 46)
        #expect(characters.contains("ん"))
    }
}
```

- [ ] **Step 3: 失敗を確認する**

```bash
cd /Users/shinya/workspace/claude/HiraganaMatchingGame/app
xcodebuild test -project HiraganaMatchingGame.xcodeproj -scheme HiraganaMatchingGame \
  -destination 'platform=iOS Simulator,id=<UDID>' \
  -only-testing:HiraganaMatchingGameTests/AudioPreloadTests \
  -resultBundlePath /tmp/t2-red.xcresult > /tmp/t2-red.log 2>&1; echo "exit=$?"
xcrun xcresulttool get test-results summary --path /tmp/t2-red.xcresult
```

期待：`exit=65`。`levelsSixToTenIncludeAllRows` の 5 ケースと `levelTenCoversAllHiragana` が失敗する（今は 25 文字で止まるため）。

- [ ] **Step 4: Catalog を使うように直す**

`AudioManager.swift` の `preloadCharacters(forLevel:)` の中身（「This is a simplified version」のコメントと `allCharacters` の配列を含めて全部）を、次のように置き換える。

```swift
    func preloadCharacters(forLevel level: Int) -> [String] {
        HiraganaCatalog.characters(upToLevel: level)
    }
```

- [ ] **Step 5: パスを確認する（Task 1 も含めて）**

```bash
xcodebuild test -project HiraganaMatchingGame.xcodeproj -scheme HiraganaMatchingGame \
  -destination 'platform=iOS Simulator,id=<UDID>' \
  -only-testing:HiraganaMatchingGameTests/AudioPreloadTests \
  -only-testing:HiraganaMatchingGameTests/HiraganaCatalogTests \
  -resultBundlePath /tmp/t2-green.xcresult > /tmp/t2-green.log 2>&1; echo "exit=$?"
xcrun xcresulttool get test-results summary --path /tmp/t2-green.xcresult
```

期待：`exit=0`。失敗 0 件で、passed が 0 件でないこと。

- [ ] **Step 6: コミットする**

```bash
cd /Users/shinya/workspace/claude/HiraganaMatchingGame
git add app/HiraganaMatchingGame/Services/Audio/AudioManager.swift app/HiraganaMatchingGameTests/AudioPreloadTests.swift
git commit -m "fix: 音声プリロードがな行で止まり、レベル 6 以降の文字を読み込まない問題を直す (#21)"
```

---

### Task 3: 全体の検証と PR

- [ ] **Step 1: ユニットテストを全部流す**（CI の `test` ジョブと同じ範囲。UI テストは #43 のため対象外）

```bash
cd /Users/shinya/workspace/claude/HiraganaMatchingGame/app
xcodebuild test -project HiraganaMatchingGame.xcodeproj -scheme HiraganaMatchingGame \
  -destination 'platform=iOS Simulator,id=<UDID>' \
  -only-testing:HiraganaMatchingGameTests \
  -resultBundlePath /tmp/all.xcresult > /tmp/all.log 2>&1; echo "exit=$?"
xcrun xcresulttool get test-results summary --path /tmp/all.xcresult
```

期待：失敗 0 件。失敗したら、結果をそのまま報告し、`xcodebuild-swift-testing` スキルで切り分ける（xcresult が名指しするテストが巻き添えのことがある）。

- [ ] **Step 2: Lint（ルートから）**

```bash
cd /Users/shinya/workspace/claude/HiraganaMatchingGame
brew upgrade swiftformat swiftlint 2>/dev/null
swiftformat app/HiraganaMatchingGame/Models/HiraganaCatalog.swift app/HiraganaMatchingGame/Services/Audio/AudioManager.swift app/HiraganaMatchingGameTests/HiraganaCatalogTests.swift app/HiraganaMatchingGameTests/AudioPreloadTests.swift
swiftlint lint --strict --quiet; echo "lint exit=$?"
git status --short
```

期待：`lint exit=0`。整形で差分が出たら、パスを指定して add し、`style:` コミットにする。

- [ ] **Step 3: push して PR を作る**

```bash
git push -u origin feature/issue-21-pr1-hiragana-catalog
gh pr create --title "fix: ひらがな行の単一定義を追加し、音声プリロードがな行で止まる問題を直す (#21 PR1)" --body "..."
```

PR 本文に書くこと：何が直ったか（レベル 6〜10 で、は行以降の音声がプリロードされていなかった）、`HiraganaCatalog` を追加したこと、PR2 で移す残り 4 ファイル、テストの結果（件数）。末尾は `Refs #21` だけにし、`Closes` は書かない。

- [ ] **Step 4: CI の `lint`・`test` が緑になったことを、ログの行で確認する**（`pass` の表示だけで判断しない）

```bash
gh pr checks --watch
gh run view --log | grep -E "Test Suite .*(passed|failed)|Executed" | tail -5
```
