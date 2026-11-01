# HiraganaMatchingGame — Claude Code 作業メモ

## ビルド・テスト
- Xcode プロジェクトは `app/HiraganaMatchingGame.xcodeproj`。`xcodebuild` は `app/` から実行する。
- ビルドだけなら `-destination 'generic/platform=iOS Simulator'`（同名シミュレータが複数あり `name=` は曖昧になる）。
- テストは UDID 指定: `xcrun simctl list devices available` で選び `-destination 'platform=iOS Simulator,id=<UDID>'`。
- 結果判定はコンソールでなく `xcrun xcresulttool get test-results summary --path <latest.xcresult>`（詳細は `xcodebuild-swift-testing` スキル）。
- zsh では `PIPESTATUS` は使えない。パイプせずログファイルへ出力して `$?` を読む。
- zsh は `$VAR` を単語分割しない。複数パスは配列 `FILES=(a b)` にして `"${FILES[@]}"` で渡す。`--include=*.swift` のようなグロブは必ずクォートする（`no matches found` で止まり、検証結果が黙って無効になる）。
- `GameViewModel` をテストで生成するときは `GameViewModel(isTestMode: true)`（実 Audio と asyncAfter を残さない）。
- `DataMigrationService` は `init(userDefaults:)` で UserDefaults を注入できる。テストは `UserDefaults(suiteName: UUID)` を渡し、`UserDefaults.standard` を触らない。
- アップグレード経路（旧 `StarUnlock_*` キーが起動後も残るか）は `scripts/verify-upgrade-path.sh <UDID>` で確認できる（#18）。
- シミュレータに UserDefaults を仕込むときは **アプリコンテナ内の plist** に直接書く。`xcrun simctl spawn <UDID> defaults write <bundle id>` はシミュレータ全体の Preferences に書かれ、アプリからは見えない。例外は OS 全体の設定で、「視差効果を減らす」は `xcrun simctl spawn <UDID> defaults write com.apple.Accessibility ReduceMotionEnabled -bool true` で効く（#34）。`xcodebuild test` はテスト後にシミュレータを shutdown するので、書き込む前に `simctl boot` と `simctl bootstatus <UDID> -b` で起動済みにする（起動していないと `device is not booted` で失敗する）。
- pbxproj の `INFOPLIST_KEY_*` は生成 Info.plist に**出力されないキーがある**（`UIBackgroundModes` / `CFBundleLocalizations` / `NSAppTransportSecurity` は出ない。#20）。Info.plist の設定を前提にするときは、ビルド済み `.app` の `Info.plist` を `plutil -p` で確認する。

## Lint
- `.swiftformat` / `.swiftlint.yml` はリポジトリルート。**swiftlint はルートから実行**（`app/` から実行すると既定ルールになる）。
- CI は brew 最新版を使う。整形前に `brew upgrade swiftformat swiftlint`。
- `swiftlint --fix` の後は `swiftformat .` を再実行し、両方をもう一度走らせて差分ゼロを確認。
- CI は `swiftlint --strict`。既存 warning は `.swiftlint-baseline.json` で凍結済みで、**新規違反だけ**が落ちる（#25）。既存 warning を減らしたら `swiftlint lint --quiet --write-baseline .swiftlint-baseline.json` で再生成してコミットする。
- pre-commit も SwiftFormat/SwiftLint を固定せず `language: system`（brew 最新）で呼ぶ（#17）。ただし 2026-11-01 時点で pre-commit はこの Mac に入っておらず、動いていない。入れると `trailing-whitespace` が Swift の空行のインデント（86 ファイル・約 1,750 行）を消すので、そのままは入れない。
- 空行のインデントが消えた Swift の差分は、git hook（`scripts/git-hooks/pre-commit` → `scripts/check-blank-line-indent.py`）が commit 前に止める。Edit ツールで書き換えると近くの空行のインデントが消えやすい。clone ごとに 1 回 `git config core.hooksPath scripts/git-hooks` で有効にする。意図した書き直しなら `git commit --no-verify`。
- baseline は違反の文面ごと照合する。`function_body_length` などの文面には「currently spans 57 lines」のような行数が入るため、凍結済みの関数に 1 行足すだけで新規違反になる。修飾子は呼び出し側に付けるか、プロパティ・関数に切り出して、関数本体の行数を変えない（#34）。

## コンテンツ仕様（PO 判断済み）
- ひらがなは現代仮名 46 文字。旧仮名「ゐ」「ゑ」は扱わない（#22）。
- 「を」で始まる今の言葉はないので、「を」は助詞の文（「ほんを よむ」「えを かく」）で出す。をとこ・をどり・をんなのような昔の書き方は使わない（PO 判断 2026-10-31、#72）。どのカードもラベルの単語に問題の文字が入っていること（濁点違いは不可。「け」に「げーむ」があった）は `CardWordContentTests` が検証する。
- 星: 実行時は `GameLogicService.calculateStars`。難易度別で、普通は正答率 100% = 3、80% 以上 = 2、60% 以上 = 1（簡単 100/90/80、難しい 100/75/50）。PO 判断で実行時の挙動を正とする（2026-10-10）。閾値は「以上」で判定する。スター計算はこの 1 箇所だけ（#57 で 90/70/50% 版と時間ボーナス版の未使用コピーを削除。時間ボーナス案は PO 判断で不採用）。プレイ中のヘッダーも `GameViewModel.currentPotentialStars` 経由で同じ関数を使い、分母は回答済みの問題数（#67 で `GameView` 内の普通モード固定のコピーを削除）。
- 行・レベル・解放スターの定義は `Models/HiraganaCatalog.swift` だけ（#21 で一本化）。レベルの見出し・説明文は `LevelProgressionService.levelTexts`（行数と同じ件数にする。足りないとそのレベルはレベル 1 の設定になる）。件数の一致と行名の重複なしは `HiraganaCatalogTests` が検証する（#62）。行名が重複すると `CharacterUnlockService` の `Dictionary(uniqueKeysWithValues:)` がトラップし、全テストが巻き添えでクラッシュする。そのときは `Fatal error: Duplicate values for key` をログで探す。
- 文字ごとの中身は Catalog とは別にある。文字集合やカードを変えるときは次も揃える: カード（`HiraganaItemRepository` の items）、カードのラベルの単語（`WordMappingRepository`）、絵文字（`EmojiRepository`）、文字ごとの代表の単語（`HiraganaItemRepository` と `CharacterCollectionView` に同じ表が 2 つ）、ヒント文（`GameLogicService`）、文字単体の読み（`SpeechSynthesizer`）。#72 では「を」1 文字で 6 か所を変えた。
- 文字サイズの上限 XXXL（`appTextSizeLimit()`）は暫定ではなく仕様（PO 判断 2026-10-31、#34）。ひらがなのカードや絵文字はもともと大きく、アクセシビリティサイズ（AX1〜AX5）まで追従させても子どもが得るものが小さいため。上限を外してアクセシビリティサイズで縦積みにするレイアウトは作らない。App Store の Accessibility Nutrition Labels の「大きな文字」は対応として申告しない（基準は約 200% と理解しているが未確認）。

## 進め方
- main は Ruleset で保護されている（#32）：**PR 必須・直接 push 不可**、必須チェックは `lint`・`test`。作業は必ずブランチ → PR で行う。
- CI の `test` ジョブ（`.github/workflows/test.yml`）はユニットテストのみ。UI テストは main でも赤いため #43 が解決するまで対象外。
- PR 本文で、close しない issue の番号の前に `Closes` / `Fixes` / `Resolves` を書かない（否定文でも自動 close される）。`Refs #N` のみにする。
- リファクタや issue 解消の PR では、CLAUDE.md の中でその issue 番号や「重複」「未対応」の状態を書いている行を同じ PR で更新する。#21 PR2 では「行・レベル定義は 5 ファイルに重複」の記述が古いまま残り、後から別 PR (#63) で直した。マージ前に `grep -n "#<issue番号>" CLAUDE.md` で確認する。
- セッション冒頭は `/daily-issue-triage`。仕様判断（実装が正 or テストが正）は AskUserQuestion でまとめて聞く。
- リリース後は、配信を iTunes Lookup（`https://itunes.apple.com/lookup?bundleId=com.asapapalab.HiraganaMatchingGame&country=jp`）で確認してから、ASC で紐付けた build のコミットに `vX.Y.Z` の注釈付きタグを付けて push する。1.0 はタグがなく、どのコミットからビルドしたか追えなかった（v1.0.1 から運用）。
- タグを付けたら**同じタイミングで `MARKETING_VERSION` を次のパッチに上げる PR を出す**（グローバルスキル `~/.claude/skills/release-version-bump-check`。リポには入っていない）。Xcode Cloud の `Default` ワークフローは「main の `app/` 配下が変わったら Archive → ASC へアップロード」なので、上げ忘れると承認済みバージョンのビルドが ITMS-90186 / 90062 で弾かれる（#52：docs だけの PR でも build 50〜52 が作られていた。2026-09-29 に開始条件を `app/` に限定）。ビルド番号は Xcode Cloud が振るので pbxproj の `CURRENT_PROJECT_VERSION` は触らない。
- 上げ忘れは CI の `version-check`（`.github/workflows/version-check.yml` → `scripts/check-marketing-version.sh`、#55）が `app/` を変える PR で検出する。比べる相手は最新の `v*` タグと iTunes Lookup の公開中バージョンの大きいほう。ASC で「配信準備完了」のまま公開していない期間はどちらにも出ないので検出できない。必須チェックではない（paths で絞っているため）。リリース後、bump の PR がマージされるまでは `app/` を変える他の PR もすべて赤になるが、これは意図した動き（先に bump をマージして rebase する）。
- ASC のメールや Xcode Cloud のビルド失敗は、原因を推定したまま対処案を出さない。ASC の Xcode Cloud 画面（ワークフローの開始条件・ビルド履歴）を claude-in-chrome で読んで事実を確定してから選択肢を出し、設定の変更は承認を取ってから行う。同じ開発者アカウントの他アプリもビルド履歴を読み取りで横断確認できるが、ITMS 番号まで確認できていないものは「可能性が高い」と書く。
- ASC の警告メールは、Claude に接続された Gmail には届かない（2026-10-10 に過去 60 日分の Apple/ITMS メールが 0 件）。「警告メールが来ていない」は Gmail では判定できないので、ASC の画面で確認する。
- #18（旧キー削除で実績が消える）は #35 で方針 1 対応済み。残る二重管理の判断は #36。DataMigrationService を触るときは先に #36 を読む。

## テストクラッシュ調査の手がかり
- xcresult が名指しするテストは「巻き添えの被害者」であることがある。複数テストが同じ `UserDefaults.standard` キーを共有すると、片方が完了フラグを立てた瞬間に他方が `.first!` で落ち、並走中の全テストを巻き込む。クラッシュのメッセージ本文は xcresult に入っておらず、`~/Library/Logs/DiagnosticReports/<App>-*.ips`（JSON、`faultingThread` の frames）を読む。
- 共有状態が原因かは `@Suite("...", .serialized)` を一時的に付けて 2 回連続実行し「毎回同じ結果」になるかで切り分ける。確定したら `.serialized` は外し、根本対処（UserDefaults 注入など）だけ残す。
- 並列実行時だけランダムに落ち、共有 UserDefaults キーの切り分けで説明できないときは `xcodebuild test -enableThreadSanitizer YES`（`-derivedDataPath` / `-resultBundlePath` は通常実行と分ける）でデータ競合を直接検出する。件数は `grep -c "WARNING: ThreadSanitizer" <log>`、競合箇所は `SUMMARY: ThreadSanitizer` 行で見る。直したら「TSan 0 件」と「CI 3 回連続緑」の両方で確認する（#48）。
- 閾値アサーション（例: `> 400`）を書く/直すときは、実データ件数（例: 185 件）に対して一度も満たされたことのない無意味な閾値になっていないか確認する。
- CI の `test` が途中で一斉クラッシュしても、アプリのコードが main と同じ PR（docs だけの変更など）なら、PR ではなく main に元からある不安定さを疑う。失敗したジョブだけを再実行し、再発は #36 に追記する（失敗 run から自動起票した issue は #36 の重複として close する。#59）。
- CI の緑は「pass」の表示だけで判断しない。ログの `Test run with N tests` で実行件数（2026-10-18 の main で 174 件）を確かめてからマージする。途中でクラッシュした後の再実行は、全件走ったかどうかが表示からは分からない。
- CI にはクラッシュレポート（`.ips`）が残らないので、落ちた場所は特定できない。原因を推定のまま書かず「落ちた場所は未確認」と明記し、#36 には事実だけを残す。

## トークンを扱うコマンド
- `gh secret set` のようにトークンを標準入力から読むコマンドは、記録に残る Bash 経由で実行・案内せず「通常のターミナルで実行してください」と明示する。

## 実装の注意
- VoiceOver の読み上げ文は `Utils/AccessibilityText.swift` に集め、文言はユニットテストで確かめる。ラベルが実際の読み上げ対象に乗っているかは、一時的な XCUITest で `app.buttons.allElementsBoundByIndex.map(\.label)` を書き出して確認する（#34）。要素を数えるアサーションは添字アクセスを避け、`app.staticTexts.matching(NSPredicate(...)).count` を使う（添字アクセスは並行する画面更新で `No matches found for Element at index N` という不安定な失敗になる）。ゲーム画面で実際に使われるのは `GameView` から辿れる部品で、`GameContentView` / `GameControlsView` / `GameOverlayView` / `GameFeedbackView` / `GameHeaderView` は未使用（#24）。
- 文字サイズ（Dynamic Type）は、アプリ全体を `appTextSizeLimit()`（`Utils/AppTextSize.swift`）で XXXL までに制限している。`ContentView` の `NavigationStack` に 1 か所付け、シート（`TutorialView`）は環境を引き継がないことがあるので中身にも付けている。シートを足したら同じ修飾子を付ける。見え方は、一時的な XCUITest で `app.launchArguments` に `-UIPreferredContentSizeCategoryName UICTContentSizeCategoryXXXL`（最大は `UICTContentSizeCategoryAccessibilityXXXL`）を渡し、`XCTAttachment(screenshot:)` を `xcresulttool export attachments` で取り出して確かめる。幅の狭い iPhone SE でも撮る（#34）。
- closure を `[weak self]` にすると deinit が実際に起きるようになり、deinit は最後の参照を手放したスレッド（`Task` の完了先など）で走る。メイン RunLoop に登録した `Timer` の `invalidate()` は別スレッドから呼ばない（#31 でヒープ破壊 → 全テスト巻き添えクラッシュになった）。
- 「音が出ない」不具合は、UI のハンドラから末端の API 呼び出しまで追い、実際に何を鳴らしているかを確かめてから原因を書く。環境や消音スイッチを先に疑わない（#73 では消音モードを原因と推定して、質問をやり直した）。音のボタンは `SpeechSynthesizer` で読み上げる（#78）。`AudioPlayer.generateMockAudio` と `generateBeepSound`（`AudioPlayer` / `EffectPlayer`）が作るのはヘッダーのない生の波形データで、`AVAudioPlayer(data:)` では再生できない（macOS で確認、iOS は未確認。効果音は #83）。
- 読み上げの呼び出しをテストで確かめるときは、`SpeechSpeaking` を実装した記録用クラス（`SoundButtonSpeechTests` の `RecordingSpeech`）を `AudioManager(isTestMode: true, speech:)` に渡す。
- `AudioPlayer.sessionCategory` は `.ambient`（消音スイッチに従う。#20）で、`AudioLifecycleTests` が検証している。PO 判断（2026-11-01、#73）で、音のボタンの読み上げだけは消音中でも鳴らす方針に変わった（BGM は消音に従うまま）。実装は #73 の 2 歩目で、そのときこのテストの扱いも決める。
