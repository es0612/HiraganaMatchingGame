# Hiragana Matching Game デザインシステム（v0.1 ドラフト）

最終更新: 2025-09-09

本ドキュメントは、現行実装からUI/UXのルールを抽出し、再利用可能な「デザインシステム」として言語化したものです。実装は含まず、設計と運用の指針を示します。

---

## 1. ブランド原則（トーン&マナー）
- 楽しい: 明るいグラデーション、アイコン/絵文字、きらめきの演出。
- やさしい: 角丸・ゆるいシャドウ・余白を広めに。
- ほめる: 正解・達成時の祝福モーションとサウンド、スター演出。
- 年少配慮: ひらがな巨大表示、誤タップを避ける十分なタップ領域。

参考：`Views/LaunchView.swift`, `Views/Game/*`, `Views/LevelSelection/*`

---

## 2. Foundations（土台）

### 2.1 カラー（現状の傾向）
- ブランド（Primary）: ピンク→オレンジのグラデーション（例: レベルバッジ、CTA）。
- アクセント（Secondary）: ブルー→パープル（例: サウンドボタン、続行ボタン）。
- 成功/警告/エラー: 成功=グリーン、警告=オレンジ、エラー=レッド。
- 報酬: スター=イエロー。
- サーフェス/背景: `Color(.systemGray6)`/ホワイトのカード＋低めの影。画面背景に淡い多色グラデ。
- ダークモード: 明度と影色（白の弱いシャドウ）を切替。

代表的な使用箇所:
- Launch 背景: ピンク/オレンジ/薄紫の3色グラデ（`Views/LaunchView.swift`）。
- Level 選択 背景: ブルー/パープルの淡いグラデ（`Views/LevelSelection/LevelSelectionView.swift`）。
- ゲーム内CTA/バッジ: ピンク→オレンジ／ブルー→パープル（`Views/Game/Components/*`）。

設計指針（提案）:
- トークン命名例
  - `Brand/PrimaryGradient = [Pink600, Orange500]`
  - `Accent/SecondaryGradient = [Blue500, Purple500]`
  - `Feedback/Success = Green500`, `Warning = Orange500`, `Error = Red500`, `Reward = Yellow500`
  - `Surface/Default = White`, `Surface/Alt = SystemGray6`
  - `Overlay/Backdrop = Black(0.2)`

### 2.2 タイポグラフィ（現状の傾向）
- 見出し: `.largeTitle`/`.title`/`.title2`、太字、Rounded を要所で使用（巨大な「あ」など）。
- 本文: `.body`、補足: `.caption`/`.caption2`。
- 数値/カウント: `.title2` 相当を多用（スター/進捗）。

設計指針（提案）:
- スタイル階層
  - `Display`（ゲームの文字/アイコン）: Size 80–120, Weight Bold, Rounded
  - `Title`（画面タイトル）: Title/Title2, Semibold–Bold
  - `Body`（本文）: Body, Regular–Medium
  - `Meta`（注記）: Caption/Caption2, Regular

### 2.3 スペーシング（現状の傾向）
- 4ptグリッド近傍: 8 / 10 / 12 / 15 / 20 / 24 / 30px を多用。

設計指針（提案）:
- トークン: `Space/2 = 8`, `3 = 12`, `4 = 16`, `5 = 20`, `6 = 24`, `7 = 28`, `8 = 32`。
- 画面余白: サイド 16–20, セクション間 16–24, グリッド間 12–20。

### 2.4 角丸・ボーダー（現状の傾向）
- 角丸: 12 / 15 / 16 / 18 / 20 / 25（カプセルはフル）。
- 枠線: 状態強調（例: おすすめ=オレンジ 3pt発光）。

設計指針（提案）:
- トークン: `Radius/s=8, m=12, l=16, xl=20, pill=∞`。
- 枠線スタイル: `Stroke/Emphasis = Accent(0.5), 2–3pt`。

### 2.5 エレベーション/シャドウ（現状の傾向）
- Light: 黒 10–20% / r=4–8。
- Dark: 白 5–10% / r=1–5。

設計指針（提案）:
- `Shadow/Soft = (black 0.1, r4, y2)`、`Shadow/Card = (black 0.15, r8, y4)`。
- ダークは白影・半径小さめで置換。

### 2.6 モーション（現状の傾向）
- スプリング: `response 0.6–1.2, damping 0.5–0.8`。
- 時間: `0.3 / 0.5 / 0.6 / 0.8s` 付近。ゲーム系は `AppConstants.Timing` で一部管理。
- パーティクル/紙吹雪: 正解・クリア時に再生。

設計指針（提案）:
- トークン: `Motion/fast=0.2, base=0.3, slow=0.6, hero=0.8`。
- 「視差・反復」は `Reduce Motion` を尊重（後述）。

### 2.7 サウンド/ハプティクス（現状の傾向）
- 効果音・BGM（設定でON/OFF/音量）。
- 触覚: 正解/誤答/タップに `UIImpactFeedbackGenerator`/`UINotificationFeedbackGenerator`。

設計指針（提案）:
- イベント→フィードバック表:
  - 正解: Success（音+通知触覚）
  - 誤答: Error（音+通知触覚）
  - レベル解放/達成: Success強（音+紙吹雪）
  - 通常タップ: Light impact

### 2.8 アイコノグラフィ/表現
- SF Symbols: 操作/状態（戻る、続行、ロック、時計、スター等）。
- 絵文字: 学習対象（あり等）、祝祭（🎉/✨）。
- 文字: ひらがな「あ」をブランドモチーフに。

---

## 3. Components（要素設計）

### 3.1 ボタン
- Primary: `RoundedRectangle(25) + グラデ（Primary/Secondary）+ 白文字`。
- Secondary: 枠線のみ/薄色塗り（設定ナビ、スキップ等）。
- Destructive: 赤系（設定内のリセット）。
- 状態: `disabled` は不透明度 0.5 目安。

関連: `Views/LevelSelection/*`, `Views/Game/Components/GameControlsView.swift`, `Views/Settings/SettingsView.swift`

### 3.2 カード
- Surface 白系 + 角丸 12–20 + 弱い影。必要に応じてストローク。
- 例: プログレス要約、キャラクターカード、解放通知。

関連: `Views/Characters/*`, `Views/Achievements/*`, `Views/Game/*`

### 3.3 バッジ/タグ
- レベルバッジ（グラデ＋白文字）。
- 「おすすめ」タグ（オレンジカプセル）。
- 実績バッジ（円背景＋シンボル）。

### 3.4 進捗/評価
- `ProgressView(Linear)` の太さ強調（scale y=2）。
- スター3段階（fill/empty、アニメ付）。

### 3.5 グリッド
- `LazyVGrid` 列数は端末/向きで可変。
- ボタンサイズは `choiceButtonSize` 等で端末状況に応じて算出。

### 3.6 フィードバック/オーバーレイ
- 正解/誤答: パーティクル（絵文字）。
- クリア: 紙吹雪＋スター表示。
- レベル解放: モーダル風オーバーレイ（鍵アイコン＋CTA）。

---

## 4. Patterns（画面パターン）
- Launch: 3色グラデ背景＋巨大「あ」＋短文コピー。
- Level 選択: 見出し→統計→レベルグリッド→補助ナビ（コレクション/実績/設定）。
- Game: ヘッダ（レベル/進捗/時間）→問題領域（文字カード/選択肢）→フッタ（戻る/ヒントor再挑戦）。
- Tutorial: ステップ式（上部バー＋中央円カード＋コピー＋操作）。
- Settings: セクションカード（音/ゲーム/その他）。
- Characters/Achievements: 統計→グリッド/カード群。

---

## 5. アクセシビリティ指針（現状+推奨）
- 現状: 一部 `accessibilityLabel/Hint`、`Identifier`、大きなタップ領域、色以外の情報付与あり。
- 推奨:
  - 文字サイズ: Dynamic Type 対応（最小/特大時の折返し、グリッド再配置）。
  - コントラスト: グラデ＋白文字は最小コントラスト比を確認（必要ならオーバーレイや影強化）。
  - Reduce Motion: iOS設定を検出し、パーティクル/回転/往復アニメを簡略化/無効化。
  - VoiceOver順序: ゲーム画面の読み上げ順（ヘッダ→問題→選択肢→フッタ）。
  - 音量ハード制御: ミュート時のフェイルセーフ文言。

---

## 6. トークン定義（設計案・疑似）
> 実装ではなく命名と粒度の指針です。

```swift
// Color
Brand.primaryGradient = [Pink600, Orange500]
Accent.secondaryGradient = [Blue500, Purple500]
Feedback.success = Green500
Feedback.warning = Orange500
Feedback.error = Red500
Reward.star = Yellow500
Surface.card = { light: White, dark: SystemGray6 }
Surface.background = { light: MulticolorSoftGradient, dark: MulticolorSoftGradientDark }

// Typography
Type.display = { size: 80-120, weight: .bold, design: .rounded }
Type.title = { base: .title2, weight: .semibold }
Type.body = { base: .body }
Type.meta = { base: .caption }

// Spacing
Space.xs=8, s=12, m=16, l=20, xl=24, xxl=30

// Radius
Radius.s=8, m=12, l=16, xl=20, pill=inf

// Shadow
Shadow.soft = { color: black(0.1), radius: 4, y: 2 }
Shadow.card = { color: black(0.15), radius: 8, y: 4 }
Dark.Shadow.soft = { color: white(0.08), radius: 2 }

// Motion
Motion.duration = { fast:0.2, base:0.3, slow:0.6, hero:0.8 }
Motion.spring = { response:0.6, damping:0.7 }

// Haptics
Haptic.tap = .light
Haptic.success = .success
Haptic.error = .error
```

---

## 7. コピー & マイクロUX
- 文体: ひらがな中心・短文・肯定表現（例:「よくできました！」）。
- ヒント: 常に肯定系で行動指示（例:「『あ』からはじめよう」）。
- 条件説明: 次の解放条件は明確に（星2つで次レベル等）。

---

## 8. QA/可観測性（運用のヒント）
- UIスナップショット: 主画面の定点（ライト/ダーク、文字サイズ2段階）。
- アクセスビリティUIテスト: VoiceOverラベル、フォーカス順、ヒット領域。
- テレメトリ（匿名）: チュートリアル完了率、離脱画面、ヒント利用率。

---

## 9. 改善提案（ユーザ価値を高める優先順）
1) トークン一元化（高）
- 目的: 画面ごとの差異（角丸/影/色/余白）を低減し、保守性/一貫性を向上。
- 手段: `Colors/Spacing/Radius/Shadow/Motion` の共通定義を導入し、既存の生値を段階的に置換。

2) コントラスト最適化（高）
- Launch/カード上の白文字×明色グラデは環境により読みにくい場合あり。
- 手段: 文字背後に 8–16px のソフトシャドウ or 半透明スクラップ（黒10–20%）を追加。色弱シミュレーションで検証。

3) Dynamic Type/Reduce Motion 対応（高）
- 手段: 特大文字での折返し検証、グリッド列数のしきい値見直し。`UIAccessibility.isReduceMotionEnabled` で紙吹雪/パーティクルを簡略化。

4) 保護者向けセーフティ（中）
- 設定への導線に保護者ゲート（長押し/簡単な計算）。プレイデータリセットに確認+説明強化。

5) 学習補助の明確化（中）
- 次レベル解放条件を結果画面でも明示（例:「星2つで解放」）。レベル選択にも凡例（スター=評価、錠=未解放）。

6) 音・触覚の個別調整（中）
- 正解時/達成時などイベント別に音量/触覚の強さをプリセット化。サイレントスイッチ時のUIメッセージ提示。

7) 国際化/ローカライズ準備（中）
- 文字列を `Localizable.strings` に集約。英語UI追加時は対象年齢に合わせ語彙を簡素に。

8) iPad/横向き最適化（中）
- 余白/列数/カード幅をブレークポイントで調整。ボトムバーの操作密度を維持。

9) チュートリアルの軽量化（低）
- 1枚目で「音を鳴らす」簡易インタラクションに。スキップ位置を上部バー右に固定。

10) テスト/ガイド整備（低）
- デザイントークンのリグレッションを検知するLint/スナップショットルールを導入。

---

## 10. 参考（実装上の主な参照ファイル）
- 画面構成: `HiraganaMatchingGame/ContentView.swift`, `Views/LaunchView.swift`
- レベル選択: `Views/LevelSelection/LevelSelectionView.swift`
- ゲーム（分割コンポーネント）: `Views/Game/Components/*`
- コレクション: `Views/Characters/CharacterCollectionView.swift`
- 実績: `Views/Achievements/AchievementsView.swift`
- 設定/ライセンス: `Views/Settings/SettingsView.swift`
- モーション/演出: `Views/Components/ParticleEffectView.swift`
- タイミング: `Utils/AppConstants.swift`

---

以上。次の反映ステップでは、上記トークン命名をもとに色/余白/角丸/影/モーションの共通化を進めることを推奨します（実装は本ドキュメントの範囲外）。

