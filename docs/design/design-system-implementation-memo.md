# デザインシステム導入メモ（実装計画・非破壊）

最終更新: 2025-09-09
対象: Hiragana Matching Game（SwiftUI）
備考: 実装は行わず、方針のみを整理。

**目的**
- UIの一貫性・可読性・保守性を高める。
- 既存表現（色/角丸/影/余白/モーション/触覚）をトークン化して再利用可能にする。
- 子ども向けUX（明確・やさしい・ほめる）を崩さずに改善余地を可視化。

**関連ドキュメント**
- デザインシステム本編: `docs/design-system.md`
- 代表的な参照箇所: 
  - グラデ背景: `app/HiraganaMatchingGame/Views/LaunchView.swift:15`
  - レベルバッジ: `app/HiraganaMatchingGame/Views/Game/Components/GameHeaderView.swift:38`
  - レベル選択背景: `app/HiraganaMatchingGame/Views/LevelSelection/LevelSelectionView.swift:21`
  - タイミング定数: `app/HiraganaMatchingGame/Utils/AppConstants.swift:3`

**到達状態（定義）**
- 直書きスタイルを設計トークン経由へ置換（段階的）。
- ボタン/カード/バッジ/タグ/進捗の基本コンポーネントを定義（コード統合は別スプリント）。
- アクセシビリティ（Dynamic Type/Reduce Motion/コントラスト）の指針を遵守。

**構成案（実装時の置き場所）**
- `app/HiraganaMatchingGame/DesignSystem/DesignTokens.swift`（色/余白/角丸/影/モーション/触覚）
- `app/HiraganaMatchingGame/DesignSystem/Styles.swift`（ボタン/カード/バッジ等のStyle）
- `app/HiraganaMatchingGame/DesignSystem/Gradients.swift`（背景/アクセントの定義）
- 既存 `AppConstants` は時間系のみを保持し、視覚系はDesignTokensへ移譲。

**方針**
- 非破壊・段階移行: 既存見た目の差異は最小（±1–2%）に保つ。
- 置換優先度: 色/グラデ > 角丸/影 > 余白 > フォント > モーション/触覚。
- 可観測性: 画面ごとの手動チェックリスト＋プレビュー比較で回帰を抑制。

**トークン（命名ガイド）**
- Colors: `Brand.primaryGradient`, `Accent.secondaryGradient`, `Feedback.success/error/warning`, `Reward.star`, `Surface.card/background`。
- Type: `Display/Title/Body/Meta`。
- Spacing: `Space.xs/s/m/l/xl/xxl`。
- Radius: `Radius.s/m/l/xl/pill`。
- Shadow: `Shadow.soft/card`（Darkは白影へ差し替え）。
- Motion: `Motion.duration.fast/base/slow/hero`, `Motion.spring.default`。
- Haptics: `Haptic.tap/success/error`。

**置換規約**
- 直書き `LinearGradient(Color(...))` は `Brand.primaryGradient`/`Accent.secondaryGradient` 経由に。
- 角丸値は `Radius.*` を使用し、任意値は追加禁止（必要時はトークン追加で対応）。
- シャドウは `Shadow.soft/card` のみを使用。環境（Light/Dark）で色を分岐。
- ボタン背景・テキスト色・角丸は `Styles.Button.primary/secondary/destructive` へ集約。
- 進捗バー、スター表示はスタイル化（色・アニメ曲線を統一）。

**段階的進め方（3スプリント想定）**
- Sprint 0（準備）
  - デザイントークン雛形の草案（本メモ準拠、実装は次スプリント）。
  - 画面一覧と検証チェックリスト作成（Light/Dark・標準/大きな文字）。
- Sprint 1（基盤）
  - グラデ/色/角丸/影をトークン化。`LaunchView`/`GameHeader`/`LevelSelection` の3画面で適用試行。
  - 差分の視覚確認（プレビュー/実機）と補正。
- Sprint 2（横展開）
  - ボタン/カード/バッジ/タグ/進捗のStyle適用を `Game/*`、`Characters/*`、`Achievements/*`、`Settings`へ展開。
  - モーション/触覚のイベントマップを `Haptic`/`Motion` に統合。
- Sprint 3（品質）
  - Dynamic Type/Reduce Motion 対応の明文化と反映。
  - 文字列の `Localizable.strings` 収束（国際化準備）。

**検証チェックリスト**
- 視覚: 主要画面（Launch/LevelSelection/Game/Characters/Achievements/Settings）で見た目が現行±1–2%以内。
- 操作: タップ領域44pt以上、誤タップなし、ヒット領域が欠けない。
- コントラスト: 背景グラデ上の白文字は可読（必要に応じて文字シャドウ/暗幕を併用）。
- アニメ: Reduce Motion時は紙吹雪/パーティクルを簡略化/無効化。
- 文字: Dynamic Type特大で崩れない（改行・折返し・レイアウトの再計算）。

**既知の改善余地（優先度順）**
- コントラスト強化（グラデ上の白テキスト）。
- トークン未統合の生値（角丸/影/余白/色）の散在解消。
- 結果画面/レベル選択での条件可視化（星2つ=解放）を明示。
- 設定→保護者ゲート/リセット文言の強化。

**リスクと対策**
- デグレ: 小さな見た目差異の積み上げ → スクリーンプレビューで差分確認を運用。
- 可読性: 明色×白文字の視認性低下 → 影/暗幕をトークンで標準化。
- パフォーマンス: 重いアニメ/エフェクト → Reduce Motion/端末条件で簡略化。

**受け入れ基準（Doneの定義）**
- 主要画面がトークンで表現され、直書きスタイルが原則撤廃。
- Light/Dark/文字大で見た目破綻なし。
- デザインシステム文書（`docs/design-system.md`）と実装の差異がない。

**次アクション（提案）**
- デザイントークン雛形のPRドラフト化（コードは空スタブ可）。
- 先行適用画面: `LaunchView`/`GameHeaderView`/`LevelSelectionView` の3点から開始。

