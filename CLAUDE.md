# HiraganaMatchingGame — Claude Code 作業メモ

## ビルド・テスト
- Xcode プロジェクトは `app/HiraganaMatchingGame.xcodeproj`。`xcodebuild` は `app/` から実行する。
- ビルドだけなら `-destination 'generic/platform=iOS Simulator'`（同名シミュレータが複数あり `name=` は曖昧になる）。
- テストは UDID 指定: `xcrun simctl list devices available` で選び `-destination 'platform=iOS Simulator,id=<UDID>'`。
- 結果判定はコンソールでなく `xcrun xcresulttool get test-results summary --path <latest.xcresult>`（詳細は `xcodebuild-swift-testing` スキル）。
- zsh では `PIPESTATUS` は使えない。パイプせずログファイルへ出力して `$?` を読む。
- `GameViewModel` をテストで生成するときは `GameViewModel(isTestMode: true)`（実 Audio と asyncAfter を残さない）。
- `DataMigrationService` は `init(userDefaults:)` で UserDefaults を注入できる。テストは `UserDefaults(suiteName: UUID)` を渡し、`UserDefaults.standard` を触らない。

## Lint
- `.swiftformat` / `.swiftlint.yml` はリポジトリルート。**swiftlint はルートから実行**（`app/` から実行すると既定ルールになる）。
- CI は brew 最新版を使う。整形前に `brew upgrade swiftformat swiftlint`。
- `swiftlint --fix` の後は `swiftformat .` を再実行し、両方をもう一度走らせて差分ゼロを確認。
- CI の `swiftlint --strict` は一時解除中（#25 で baseline 方式により復活予定）。

## コンテンツ仕様（PO 判断済み）
- ひらがなは現代仮名 46 文字。旧仮名「ゐ」「ゑ」は扱わない（#22）。
- 星: 正答率 90% 以上 = 3、70% 以上 = 2、50% 以上 = 1。
- 行・レベル定義は現在 5 ファイルに重複（#21）。文字集合を変えるときは全部揃える。

## 進め方
- セッション冒頭は `/daily-issue-triage`。仕様判断（実装が正 or テストが正）は AskUserQuestion でまとめて聞く。
- P0 の未対応: #18（マイグレーションが旧キーを削除して実績が消える）。DataMigrationService を触るときは先に #18 を読む。
