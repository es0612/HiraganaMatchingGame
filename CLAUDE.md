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
- シミュレータに UserDefaults を仕込むときは **アプリコンテナ内の plist** に直接書く。`xcrun simctl spawn <UDID> defaults write <bundle id>` はシミュレータ全体の Preferences に書かれ、アプリからは見えない。
- pbxproj の `INFOPLIST_KEY_*` は生成 Info.plist に**出力されないキーがある**（`UIBackgroundModes` / `CFBundleLocalizations` / `NSAppTransportSecurity` は出ない。#20）。Info.plist の設定を前提にするときは、ビルド済み `.app` の `Info.plist` を `plutil -p` で確認する。

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
- #18（旧キー削除で実績が消える）は #35 で方針 1 対応済み。残る二重管理の判断は #36。DataMigrationService を触るときは先に #36 を読む。

## テストクラッシュ調査の手がかり
- xcresult が名指しするテストは「巻き添えの被害者」であることがある。複数テストが同じ `UserDefaults.standard` キーを共有すると、片方が完了フラグを立てた瞬間に他方が `.first!` で落ち、並走中の全テストを巻き込む。クラッシュのメッセージ本文は xcresult に入っておらず、`~/Library/Logs/DiagnosticReports/<App>-*.ips`（JSON、`faultingThread` の frames）を読む。
- 共有状態が原因かは `@Suite("...", .serialized)` を一時的に付けて 2 回連続実行し「毎回同じ結果」になるかで切り分ける。確定したら `.serialized` は外し、根本対処（UserDefaults 注入など）だけ残す。
- 閾値アサーション（例: `> 400`）を書く/直すときは、実データ件数（例: 185 件）に対して一度も満たされたことのない無意味な閾値になっていないか確認する。

## トークンを扱うコマンド
- `gh secret set` のようにトークンを標準入力から読むコマンドは、記録に残る Bash 経由で実行・案内せず「通常のターミナルで実行してください」と明示する。

## 実装の注意
- closure を `[weak self]` にすると deinit が実際に起きるようになり、deinit は最後の参照を手放したスレッド（`Task` の完了先など）で走る。メイン RunLoop に登録した `Timer` の `invalidate()` は別スレッドから呼ばない（#31 でヒープ破壊 → 全テスト巻き添えクラッシュになった）。
