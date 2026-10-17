# #21 PR2: 残り 4 ファイルを HiraganaCatalog から導出する Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 行・レベル定義の宣言を `HiraganaCatalog` の 1 箇所にし、残る 4 ファイルはそこから導出する。あわせて `LevelProgressionService` の強制アンラップと、誰も読んでいない `questionsCount` を消し、README / SPECIFICATION のレベル表を実装に合わせる。

**Architecture:** PR1 で作った `Models/HiraganaCatalog.swift`（行名・文字・解放スター）を正とする。各サービスは、公開 API（戻り値の型・範囲外の扱い）を変えずに、内部のリテラルだけを Catalog からの導出に置き換える。手順は「今の値を固定する特性テストを先に書く（移行前に緑）→ 置き換える → 同じテストがまだ緑」。新しい API は `HiraganaCatalog.row(containing:)` の 1 つだけで、これだけは RED から始める。

**Tech Stack:** Swift 5 / SwiftUI、Swift Testing（`@Test` / `#expect`）、xcodebuild。Xcode プロジェクトは file-system synchronized group なので、新しいファイルを置いても pbxproj の編集は不要。

**Spec:** Issue #21 の本文と 2026-10-10 のコメント（PO 判断）。`gh issue view 21 --comments`

## Global Constraints

- ひらがなは現代仮名 46 文字。旧仮名「ゐ」「ゑ」は扱わない（#22）
- 行の構成と解放スター：あ0・か2・さ4・た6・な8・は10・ま12・や14（や/ゆ/よ）・ら16・わ18（わ/を/ん）
- 各サービスの**公開 API と範囲外の扱いは変えない**。`HiraganaGameService.getCharactersForLevel` は範囲外で `[]`（Catalog のようにクランプしない）。`LevelProgressionService.getLevelConfiguration` は範囲外でレベル 1 の設定
- `GameLevel`（@Model）と SwiftData のスキーマには触れない（#33）
- 文字ごとの対応表（`HiraganaItemRepository`、`GameLogicService` のヒント、`SpeechSynthesizer`、`CharacterCollectionView` の単語マップと行ごとの色）は対象外
- テスト用の `HiraganaMatchingGameTests/TestableStarUnlockService.swift` は、解放スターがわざと違う値（か行 1 など）のテストダブルなので触れない
- `questionsCount` は削除する。問題数は設定画面の 5 / 10 / 15 問（`QuestionsPerSession`）で決まる
- pbxproj の `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` は触れない（1.0.2 のまま。`app/` の変更なので、マージすると Xcode Cloud が 1.0.2 をビルドする）
- swiftlint / swiftformat はリポジトリルートから実行する（`--strict` + baseline）
- PR 本文の最後は `Closes #21`（PR2 で受け入れ条件がすべて揃う）。#57 / #33 は `Refs` だけにする
- ログと xcresult は scratchpad に出す：`S=/private/tmp/claude-501/-Users-shinya-workspace-claude-HiraganaMatchingGame/d860c48c-c83e-4648-a8d2-e9e5d7f5bfa6/scratchpad`
- シミュレータは iPhone 17：`UDID=0C3FB418-AAE9-4F7E-94DE-7FCB3E145D9F`

## Review Focus

1. **範囲外のレベル（0、-1、11、100）で `getLevelConfiguration` を呼んでも落ちず、レベル 1 の設定が返る**（`!` を消したあとも、範囲外の扱いは今と同じ）→ Task 4 のテスト `invalidLevelsFallBackToLevelOne`
2. **`HiraganaGameService.getCharactersForLevel` は範囲外で `[]` を返し続ける**（Catalog のクランプに引きずられない）→ Task 2 のテスト `gameServiceOutOfRangeIsEmpty`
3. **レベルの見出しが変わらない**（レベル 10 は「わ行をおぼえよう」ではなく「すべてのひらがな」）→ Task 4 のテスト `titlesUnchanged`。説明文はテストでは「空でない」ことだけを見る。文言はそのまま移すので、PR の差分で目視確認する
4. **Catalog にない文字（「ゐ」「ア」「」）では `row(containing:)` が nil を返す** → Task 1 のテスト `rowContainingUnknownIsNil`。View 側の `?? "その他"` は private な 1 行なので、PR の差分で確認する
5. **全レベルで `config.level == level` になる**（見出しの配列が 1 つ足りないと、最後のレベルの設定が黙って消える）→ Task 4 のテスト `everyLevelDerivesFromCatalog`
6. **文字の解放に必要なスターが今と同じ**（か行は 2 スター）→ Task 3 のテスト `unlockServiceMatchesCatalog`

---

### Task 1: `HiraganaCatalog.row(containing:)` を追加し、`CharacterCollectionView` を Catalog から読む

**Files:**
- Modify: `app/HiraganaMatchingGame/Models/HiraganaCatalog.swift`
- Modify: `app/HiraganaMatchingGame/Views/Characters/CharacterCollectionView.swift:301-337`（`getAllHiraganaCharacters` と `getCharacterGroup`）
- Test: `app/HiraganaMatchingGameTests/HiraganaCatalogTests.swift`

**Interfaces:**
- Produces: `static func row(containing character: String) -> HiraganaCatalog.Row?`

- [ ] **Step 1: 失敗するテストを書く**

`HiraganaCatalogTests` の末尾（`outOfRangeLevelsClamp` の後）に追加する。

```swift
    @Test("文字から行を引ける", arguments: [("あ", "あ行"), ("ぬ", "な行"), ("よ", "や行"), ("ん", "わ行")])
    func rowContainingKnownCharacter(character: String, expectedRow: String) {
        #expect(HiraganaCatalog.row(containing: character)?.name == expectedRow)
    }

    @Test("Catalog にない文字は nil", arguments: ["ゐ", "ア", ""])
    func rowContainingUnknownIsNil(character: String) {
        #expect(HiraganaCatalog.row(containing: character) == nil)
    }
```

- [ ] **Step 2: 失敗を確認する**

```bash
cd "$(git rev-parse --show-toplevel)/app"
xcodebuild test -project HiraganaMatchingGame.xcodeproj -scheme HiraganaMatchingGame \
  -destination "platform=iOS Simulator,id=$UDID" \
  -only-testing:HiraganaMatchingGameTests/HiraganaCatalogTests > "$S/t1-red.log" 2>&1; echo "exit=$?"
grep -m3 "row(containing" "$S/t1-red.log"
```

期待：`exit=65`。`type 'HiraganaCatalog' has no member 'row'` でコンパイルに失敗する。

- [ ] **Step 3: 最小の実装**

`HiraganaCatalog.swift`：`characters(upToLevel:)` の後に追加する。

```swift
    /// 文字が属する行。Catalog にない文字は nil。
    static func row(containing character: String) -> Row? {
        rows.first { $0.characters.contains(character) }
    }
```

`CharacterCollectionView.swift`：2 つの関数の本体を置き換える。

```swift
    private func getAllHiraganaCharacters() -> [String] {
        HiraganaCatalog.allCharacters
    }

    private func getCharacterGroup(_ character: String) -> String {
        HiraganaCatalog.row(containing: character)?.name ?? "その他"
    }
```

- [ ] **Step 4: 通ることを確認する**

```bash
xcodebuild test -project HiraganaMatchingGame.xcodeproj -scheme HiraganaMatchingGame \
  -destination "platform=iOS Simulator,id=$UDID" \
  -only-testing:HiraganaMatchingGameTests/HiraganaCatalogTests \
  -resultBundlePath "$S/t1-green.xcresult" > "$S/t1-green.log" 2>&1; echo "exit=$?"
xcrun xcresulttool get test-results summary --path "$S/t1-green.xcresult"
```

期待：`exit=0`、失敗 0。passed が 0 でない（`-only-testing` が 0 件で通る偽の緑を防ぐ）。

- [ ] **Step 5: コミット**

```bash
cd "$(git rev-parse --show-toplevel)"
git add app/HiraganaMatchingGame/Models/HiraganaCatalog.swift app/HiraganaMatchingGame/Views/Characters/CharacterCollectionView.swift app/HiraganaMatchingGameTests/HiraganaCatalogTests.swift
git commit -m "refactor: コレクション画面の行定義を HiraganaCatalog から読む (#21)"
```

---

### Task 2: `HiraganaGameService` のレベル別文字を Catalog から導出する

**Files:**
- Modify: `app/HiraganaMatchingGame/Data/Services/HiraganaGameService.swift:13-50`（`levelConfiguration`）
- Test: `app/HiraganaMatchingGameTests/HiraganaCatalogTests.swift`

**Interfaces:**
- Consumes: `HiraganaCatalog.characters(upToLevel:)`, `HiraganaCatalog.totalLevels`
- Produces: なし（`getLevelConfiguration()` / `getCharactersForLevel(_:)` / `isValidLevel(_:)` / `getMaxLevel()` の挙動は不変）

- [ ] **Step 1: 今の値を固定する特性テストを書く**

`HiraganaCatalogTests` の末尾に追加する。

```swift
    @Test("HiraganaGameService のレベル別文字が Catalog と一致する", arguments: 1 ... 10)
    func gameServiceMatchesCatalog(level: Int) {
        #expect(HiraganaGameService.shared.getCharactersForLevel(level) == HiraganaCatalog.characters(upToLevel: level))
    }

    @Test("HiraganaGameService は範囲外のレベルで空を返す（クランプしない）", arguments: [0, -1, 11, 99])
    func gameServiceOutOfRangeIsEmpty(level: Int) {
        #expect(HiraganaGameService.shared.getCharactersForLevel(level).isEmpty)
        #expect(HiraganaGameService.shared.isValidLevel(level) == false)
    }
```

- [ ] **Step 2: 移行前に緑であることを確認する**

Task 1 Step 4 と同じコマンド（`-resultBundlePath "$S/t2-before.xcresult"`）。期待：`exit=0`、失敗 0。**ここで赤なら、今の値が Catalog とずれている。移行せずに止まって報告する。**

- [ ] **Step 3: 置き換える**

`levelConfiguration` の辞書リテラル全体（`[` から対応する `]` まで、レベル 1〜10）を次に置き換える。コメント行も合わせて直す。

```swift
    /// Level configuration derived from HiraganaCatalog (#21)
    private let levelConfiguration: [Int: [String]] = Dictionary(
        uniqueKeysWithValues: (1 ... HiraganaCatalog.totalLevels).map { ($0, HiraganaCatalog.characters(upToLevel: $0)) }
    )
```

- [ ] **Step 4: 同じテストと既存のテストが緑であることを確認する**

```bash
xcodebuild test -project HiraganaMatchingGame.xcodeproj -scheme HiraganaMatchingGame \
  -destination "platform=iOS Simulator,id=$UDID" \
  -only-testing:HiraganaMatchingGameTests/HiraganaCatalogTests \
  -only-testing:HiraganaMatchingGameTests/HiraganaGameServiceTests \
  -resultBundlePath "$S/t2-green.xcresult" > "$S/t2-green.log" 2>&1; echo "exit=$?"
xcrun xcresulttool get test-results summary --path "$S/t2-green.xcresult"
```

期待：`exit=0`、失敗 0、passed が 0 でない。`HiraganaGameServiceTests` はファイル直下の `@Test` 関数なので、0 件になる場合は `-only-testing:HiraganaMatchingGameTests/hiraganaGameServiceLevelManagement()` のように関数名で指定し直す（`xcodebuild-swift-testing` スキル）。

- [ ] **Step 5: コミット**

```bash
cd "$(git rev-parse --show-toplevel)"
git add app/HiraganaMatchingGame/Data/Services/HiraganaGameService.swift app/HiraganaMatchingGameTests/HiraganaCatalogTests.swift
git commit -m "refactor: HiraganaGameService のレベル別文字を HiraganaCatalog から導出する (#21)"
```

---

### Task 3: `CharacterUnlockService` の行と解放スターを Catalog から導出する

**Files:**
- Modify: `app/HiraganaMatchingGame/Data/Services/StarUnlock/CharacterUnlockService.swift:28`（`unlockedCharacters` の初期値）、`:44-70`（`characterGroups` / `groupUnlockRequirements`）
- Test: `app/HiraganaMatchingGameTests/HiraganaCatalogTests.swift`

**Interfaces:**
- Consumes: `HiraganaCatalog.rows`
- Produces: なし（`getCharacterGroups()` / `getGroupUnlockRequirements()` の戻り値は不変）

- [ ] **Step 1: 今の値を固定する特性テストを書く**

```swift
    @Test("CharacterUnlockService の行と解放スターが Catalog と一致する")
    func unlockServiceMatchesCatalog() {
        let service = CharacterUnlockService.shared
        let expectedGroups = Dictionary(uniqueKeysWithValues: HiraganaCatalog.rows.map { ($0.name, $0.characters) })
        let expectedStars = Dictionary(uniqueKeysWithValues: HiraganaCatalog.rows.map { ($0.name, $0.requiredStars) })
        #expect(service.getCharacterGroups() == expectedGroups)
        #expect(service.getGroupUnlockRequirements() == expectedStars)
        #expect(service.getGroupUnlockRequirements()["か行"] == 2)
    }
```

（`shared` の初期化は UserDefaults を読むだけで、このテストは書き込まない）

- [ ] **Step 2: 移行前に緑であることを確認する**

Task 1 Step 4 と同じコマンド（`-resultBundlePath "$S/t3-before.xcresult"`）。期待：`exit=0`、失敗 0。赤なら止まって報告する。

- [ ] **Step 3: 置き換える**

```swift
    private var unlockedCharacters: Set<String> = Set(HiraganaCatalog.characters(upToLevel: 1))
```

```swift
    /// Hiragana character groups with their unlock order (derived from HiraganaCatalog, #21)
    private let characterGroups: [String: [String]] = Dictionary(
        uniqueKeysWithValues: HiraganaCatalog.rows.map { ($0.name, $0.characters) }
    )

    /// Star requirements for unlocking each character group (derived from HiraganaCatalog, #21)
    private let groupUnlockRequirements: [String: Int] = Dictionary(
        uniqueKeysWithValues: HiraganaCatalog.rows.map { ($0.name, $0.requiredStars) }
    )
```

- [ ] **Step 4: 同じテストと、解放まわりの既存テストが緑であることを確認する**

```bash
grep -rln "CharacterUnlockService" app/HiraganaMatchingGameTests
```

で出たスイートを `-only-testing` に足して、Task 2 Step 4 と同じ形で実行する（`-resultBundlePath "$S/t3-green.xcresult"`）。期待：`exit=0`、失敗 0、passed が 0 でない。

- [ ] **Step 5: コミット**

```bash
cd "$(git rev-parse --show-toplevel)"
git add app/HiraganaMatchingGame/Data/Services/StarUnlock/CharacterUnlockService.swift app/HiraganaMatchingGameTests/HiraganaCatalogTests.swift
git commit -m "refactor: CharacterUnlockService の行と解放スターを HiraganaCatalog から導出する (#21)"
```

---

### Task 4: `LevelProgressionService` を Catalog から導出し、`!` と `questionsCount` を消す

**Files:**
- Modify: `app/HiraganaMatchingGame/Services/LevelProgressionService.swift:4-11`（`LevelConfiguration`）、`:25`（`totalLevels`）、`:157-284`（`levelConfigurations` と `getLevelConfiguration`）
- Modify: `app/HiraganaMatchingGameTests/LevelProgressionServiceTests.swift:131,137,143`（`questionsCount` の 3 行を削除）
- Modify: `app/HiraganaMatchingGameTests/LevelProgressionIntegrationTests.swift:103,111`（`questionsCount` の 2 行を削除）
- Test: `app/HiraganaMatchingGameTests/LevelProgressionServiceTests.swift`

**Interfaces:**
- Consumes: `HiraganaCatalog.rows`, `HiraganaCatalog.characters(upToLevel:)`, `HiraganaCatalog.totalLevels`
- Produces: `LevelConfiguration` から `questionsCount` がなくなる（他に参照なし。`grep -rn questionsCount app` で確認済み）

- [ ] **Step 1: 今の値を固定する特性テストを書く**

`LevelProgressionServiceTests` の `levelConfiguration()` の後に追加する。

```swift
    @Test("全レベルの設定が HiraganaCatalog から導出される", arguments: 1 ... 10)
    func everyLevelDerivesFromCatalog(level: Int) {
        let config = LevelProgressionService(forTesting: true).getLevelConfiguration(level)
        #expect(config.level == level)
        #expect(config.characters == HiraganaCatalog.characters(upToLevel: level))
        #expect(config.requiredStars == HiraganaCatalog.rows[level - 1].requiredStars)
        #expect(!config.description.isEmpty)
    }

    @Test("レベルの見出しは変わらない")
    func titlesUnchanged() {
        let service = LevelProgressionService(forTesting: true)
        let titles = (1 ... service.getTotalLevels()).map { service.getLevelConfiguration($0).title }
        #expect(titles == [
            "あ行をおぼえよう", "か行をおぼえよう", "さ行をおぼえよう", "た行をおぼえよう", "な行をおぼえよう",
            "は行をおぼえよう", "ま行をおぼえよう", "や行をおぼえよう", "ら行をおぼえよう", "すべてのひらがな"
        ])
        #expect(service.getTotalLevels() == HiraganaCatalog.totalLevels)
    }

    @Test("範囲外のレベルはレベル 1 の設定になる", arguments: [0, -1, 11, 100])
    func invalidLevelsFallBackToLevelOne(level: Int) {
        let config = LevelProgressionService(forTesting: true).getLevelConfiguration(level)
        #expect(config.level == 1)
        #expect(config.title == "あ行をおぼえよう")
        #expect(config.characters == ["あ", "い", "う", "え", "お"])
        #expect(config.requiredStars == 0)
    }
```

- [ ] **Step 2: 移行前に緑であることを確認する**

```bash
xcodebuild test -project HiraganaMatchingGame.xcodeproj -scheme HiraganaMatchingGame \
  -destination "platform=iOS Simulator,id=$UDID" \
  -only-testing:HiraganaMatchingGameTests/LevelProgressionServiceTests \
  -only-testing:HiraganaMatchingGameTests/LevelProgressionIntegrationTests \
  -resultBundlePath "$S/t4-before.xcresult" > "$S/t4-before.log" 2>&1; echo "exit=$?"
xcrun xcresulttool get test-results summary --path "$S/t4-before.xcresult"
```

期待：`exit=0`、失敗 0。赤なら止まって報告する。

- [ ] **Step 3: 置き換える**

`LevelConfiguration` から `let questionsCount: Int` を削除する。

`private let totalLevels: Int = 10` を次にする。

```swift
    private let totalLevels: Int = HiraganaCatalog.totalLevels
```

`levelConfigurations`（`/// レベル定義テーブル` のコメントから辞書の閉じ括弧まで）と `getLevelConfiguration` を次に置き換える。

```swift
    /// レベルごとの見出しと説明文。文字と必要スターは HiraganaCatalog から導出する（#21）
    private static let levelTexts: [(title: String, description: String)] = [
        ("あ行をおぼえよう", "ひらがなの基本、あ行をマスターしよう！"),
        ("か行をおぼえよう", "か行を覚えて、ひらがなの世界を広げよう！"),
        ("さ行をおぼえよう", "さ行をマスターして、更にレベルアップ！"),
        ("た行をおぼえよう", "た行も仲間に加えて、どんどん上達！"),
        ("な行をおぼえよう", "な行を覚えて、ひらがなマスターに近づこう！"),
        ("は行をおぼえよう", "は行をマスターして、さらなる高みを目指そう！"),
        ("ま行をおぼえよう", "ま行も覚えて、ひらがなの達人に！"),
        ("や行をおぼえよう", "や行をマスターして、ゴールが見えてきた！"),
        ("ら行をおぼえよう", "ら行をクリアして、最終ステージへ！"),
        ("すべてのひらがな", "全てのひらがなをマスターして、真のひらがな博士になろう！")
    ]

    private static let levelConfigurations: [LevelConfiguration] = zip(HiraganaCatalog.rows.indices, levelTexts).map { index, text in
        LevelConfiguration(
            level: index + 1,
            title: text.title,
            characters: HiraganaCatalog.characters(upToLevel: index + 1),
            requiredStars: HiraganaCatalog.rows[index].requiredStars,
            description: text.description
        )
    }

    /// 範囲外のレベルはレベル 1 の設定を返す
    func getLevelConfiguration(_ level: Int) -> LevelConfiguration {
        guard level >= 1 && level <= totalLevels else {
            return Self.levelConfigurations[0]
        }
        return Self.levelConfigurations[level - 1]
    }
```

テストから `questionsCount` の 5 行（`LevelProgressionServiceTests.swift:131,137,143`、`LevelProgressionIntegrationTests.swift:103,111`）を削除する。

- [ ] **Step 4: 同じテストが緑で、`!` と `questionsCount` が消えたことを確認する**

Step 2 と同じコマンド（`-resultBundlePath "$S/t4-green.xcresult"`）。期待：`exit=0`、失敗 0、passed が 0 でない。

```bash
cd "$(git rev-parse --show-toplevel)"
grep -n 'levelConfigurations\[level\]!' app/HiraganaMatchingGame/Services/LevelProgressionService.swift; echo "bang=$?"
grep -rn "questionsCount" app; echo "qc=$?"
```

期待：`bang=1`、`qc=1`（どちらもヒットなし）。

- [ ] **Step 5: コミット**

```bash
git add app/HiraganaMatchingGame/Services/LevelProgressionService.swift app/HiraganaMatchingGameTests/LevelProgressionServiceTests.swift app/HiraganaMatchingGameTests/LevelProgressionIntegrationTests.swift
git commit -m "refactor: LevelProgressionService を HiraganaCatalog から導出し、強制アンラップと questionsCount を消す (#21)"
```

---

### Task 5: README / SPECIFICATION のレベル表を実装に合わせ、全体を確認して PR を出す

**Files:**
- Modify: `README.md:48-60`（レベル構成の表）
- Modify: `docs/SPECIFICATION.md:57-69`（レベル構成の表）

- [ ] **Step 1: README の表から「問題数」列を消す**

```markdown
### レベル構成
| レベル | 文字範囲 | 必要スター数 |
|--------|----------|--------------|
| 1 | あ行 (5文字) | 0 |
| 2 | あ〜か行 (10文字) | 2 |
| 3 | あ〜さ行 (15文字) | 4 |
| 4 | あ〜た行 (20文字) | 6 |
| 5 | あ〜な行 (25文字) | 8 |
| 6 | あ〜は行 (30文字) | 10 |
| 7 | あ〜ま行 (35文字) | 12 |
| 8 | あ〜や行 (38文字) | 14 |
| 9 | あ〜ら行 (43文字) | 16 |
| 10 | 全ひらがな (46文字) | 18 |

必要スター数は全レベルの合計スターで判定します。1 回の問題数はレベルによらず、設定画面で 5 / 10 / 15 問から選びます。
```

- [ ] **Step 2: SPECIFICATION の表を直す**（「問題数」列を削除、レベル 10 を 46 文字に、レベル 2 の解放条件を実装どおり「累計2スター」に）

```markdown
### レベル構成
| レベル | 文字範囲 | 文字数 | 必要スター | 解放条件 |
|--------|----------|--------|------------|----------|
| 1 | あ行 | 5 | 0 | 初期解放 |
| 2 | あ〜か行 | 10 | 2 | 累計2スター |
| 3 | あ〜さ行 | 15 | 4 | 累計4スター |
| 4 | あ〜た行 | 20 | 6 | 累計6スター |
| 5 | あ〜な行 | 25 | 8 | 累計8スター |
| 6 | あ〜は行 | 30 | 10 | 累計10スター |
| 7 | あ〜ま行 | 35 | 12 | 累計12スター |
| 8 | あ〜や行 | 38 | 14 | 累計14スター |
| 9 | あ〜ら行 | 43 | 16 | 累計16スター |
| 10 | 全ひらがな | 46 | 18 | 累計18スター |

1 回の問題数はレベルによらず、設定画面で 5 / 10 / 15 問から選ぶ（`QuestionsPerSession`）。
```

（根拠：`LevelProgressionService.isLevelUnlocked` は `totalStars >= requiredStars` で判定している）

- [ ] **Step 3: 重複が消えたことを確認する**

```bash
grep -rln '"け", "こ"' app/HiraganaMatchingGame
```

期待：`app/HiraganaMatchingGame/Models/HiraganaCatalog.swift` だけ。

- [ ] **Step 4: ユニットテスト全体を実行する**（CI の `test` ジョブと同じ範囲）

```bash
cd "$(git rev-parse --show-toplevel)/app"
xcodebuild test -project HiraganaMatchingGame.xcodeproj -scheme HiraganaMatchingGame \
  -destination "platform=iOS Simulator,id=$UDID" \
  -only-testing:HiraganaMatchingGameTests \
  -resultBundlePath "$S/all.xcresult" > "$S/all.log" 2>&1; echo "exit=$?"
xcrun xcresulttool get test-results summary --path "$S/all.xcresult"
```

期待：`exit=0`、失敗 0。passed 件数を記録する（main の 153 件より、追加した引数付きテストの分だけ増える）。

- [ ] **Step 5: lint**

```bash
cd "$(git rev-parse --show-toplevel)"
brew upgrade swiftformat swiftlint
swiftformat . && swiftlint lint --strict --quiet; echo "lint=$?"
git status --short
```

期待：`lint=0`。swiftformat の差分が出たら、該当ファイルだけをパスで指定して stage する（`.vscode/settings.json` は触らない）。

- [ ] **Step 6: コミット・push・PR**

```bash
git add README.md docs/SPECIFICATION.md docs/superpowers/plans/2026-10-17-issue-21-pr2-catalog-migration.md
git commit -m "docs: レベル表を実装に合わせ、問題数列を削除しレベル 10 を 46 文字にする (#21)"
git show --stat HEAD
git push -u origin feature/issue-21-pr2-catalog-migration
```

PR 本文：概要（4 ファイルの移行、`!` と `questionsCount` の削除、docs の修正）、受け入れ条件 4 つの対応表（受け入れ条件 2「レベル 6〜10 のプリロードのテスト」は PR1 #58 で対応済みと書く）、SPEC のレベル 2 の解放条件を「レベル1で2スター」から実装どおり「累計2スター」に揃えたこと（PO 判断の範囲外の文言修正なので明記する）、テスト件数（Step 4 の実測値）、対象外にしたもの（文字ごとの対応表、`TestableStarUnlockService`、`GameLevel` は #33、スター計算の重複は #57）。末尾は `Closes #21` と `Refs #57`、`Refs #33`。
