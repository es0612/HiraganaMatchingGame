# ひらがなマッチングゲーム (Hiragana Matching Game)

> 4〜7歳の子供向けひらがな学習アプリ

![iOS](https://img.shields.io/badge/iOS-17.0+-blue)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green)
![License](https://img.shields.io/badge/License-MIT-blue)

## 📱 アプリ概要

ひらがなマッチングゲームは、4歳から7歳の子供を対象とした教育的なひらがな学習アプリです。段階的な学習システムと楽しいゲーム要素を組み合わせて、子供たちが自然にひらがなを覚えられるよう設計されています。

### 🎯 主な特徴

- **10段階のレベル進行システム** - あ行から始まり、段階的に文字を追加
- **音声学習サポート** - 各文字の正しい発音を音声で学習
- **スター評価システム** - 正解率に基づく3段階評価
- **キャラクター解放機能** - スター獲得によるコレクション要素
- **実績・バッジシステム** - 学習継続の動機付け
- **完全オフライン動作** - インターネット接続不要

## 🏗️ 技術仕様

### 開発環境
- **プラットフォーム**: iOS 17.0+
- **開発言語**: Swift 6.0
- **UIフレームワーク**: SwiftUI
- **データ永続化**: SwiftData + UserDefaults
- **音声処理**: AVFoundation
- **テストフレームワーク**: Swift Testing

### アーキテクチャ
```
┌─────────────────┐
│   SwiftUI Views │  ← プレゼンテーション層
├─────────────────┤
│   ViewModels    │  ← ビジネスロジック
├─────────────────┤
│    Services     │  ← コアサービス
├─────────────────┤
│  SwiftData      │  ← データ永続化
└─────────────────┘
```

## 🎮 ゲーム仕様

### レベル構成
| レベル | 文字範囲 | 必要スター数 | 問題数 |
|--------|----------|--------------|--------|
| 1 | あ行 (5文字) | 0 | 8問 |
| 2 | あ〜か行 (10文字) | 2 | 10問 |
| 3 | あ〜さ行 (15文字) | 4 | 12問 |
| 4 | あ〜た行 (20文字) | 6 | 14問 |
| 5 | あ〜な行 (25文字) | 8 | 16問 |
| 6 | あ〜は行 (30文字) | 10 | 16問 |
| 7 | あ〜ま行 (35文字) | 12 | 18問 |
| 8 | あ〜や行 (38文字) | 14 | 18問 |
| 9 | あ〜ら行 (43文字) | 16 | 20問 |
| 10 | 全ひらがな (46文字) | 18 | 22問 |

### スター評価基準
- **3スター**: 正解率 100%
- **2スター**: 正解率 80-99%
- **1スター**: 正解率 60-79%
- **0スター**: 正解率 60%未満

### 難易度設定
- **簡単**: 2択問題、厳しめスター条件
- **普通**: 3択問題、標準スター条件
- **難しい**: 4択問題、甘めスター条件

## 🗂️ コード構造

### 主要コンポーネント

#### Models (SwiftData)
```swift
Character.swift          // キャラクター情報
GameLevel.swift         // レベル設定
GameProgress.swift      // 進行状況
UserSettings.swift      // ユーザー設定
HiraganaData.swift      // ひらがなデータ管理
```

#### Services
```swift
LevelProgressionService.swift  // レベル進行管理
GameLogicService.swift        // ゲームロジック
AudioService.swift           // 音声機能
StarUnlockService.swift      // キャラクター解放
```

#### ViewModels
```swift
LevelSelectionViewModel.swift // レベル選択画面
GameViewModel.swift          // ゲーム画面
SettingsViewModel.swift      // 設定画面
```

#### Views
```swift
LevelSelectionView.swift     // メインハブ画面
GameView.swift              // ゲームプレイ画面
CharacterCollectionView.swift // コレクション画面
AchievementsView.swift       // 実績画面
SettingsView.swift          // 設定画面
```

### 音声システム
```swift
Audio/
├── AudioManager.swift      // 音声管理
├── AudioPlayer.swift       // 音声再生
├── BGMGenerator.swift      // BGM生成
├── EffectPlayer.swift      // 効果音
└── SpeechSynthesizer.swift // 音声合成
```

## 🧪 テスト戦略

### テストカバレッジ
- **ユニットテスト**: サービス層とビジネスロジック
- **統合テスト**: データフローと永続化
- **UIテスト**: 完全なユーザーフロー（現在無効化）

### テスト実行
```bash
# 基本テスト実行
xcodebuild test -scheme HiraganaMatchingGame -destination 'platform=iOS Simulator,name=iPad (A16)'

# 特定テストクラス実行
xcodebuild test -scheme HiraganaMatchingGame -only-testing:HiraganaMatchingGameTests/GameLogicServiceTests
```

## 🛠️ 開発セットアップ

### 必要要件
- Xcode 15.0+
- iOS 17.0+ Simulator
- macOS 14.0+

### プロジェクトセットアップ
1. リポジトリをクローン
```bash
git clone [repository-url]
cd HiraganaMatchingGame
```

2. Xcodeでプロジェクトを開く
```bash
open app/HiraganaMatchingGame.xcodeproj
```

3. シミュレータでビルド・実行
- ターゲット: iPad (A16) 推奨
- iOS 18.5 Simulator

## 🎵 カスタム音声の追加

### BGM差し替え方法
BGMは`bgm.mp3`ファイルで自動的に読み込まれます:
1. `bgm.mp3`ファイルをプロジェクトルートに配置
2. Xcodeでプロジェクトに追加（Build Phasesで自動的にバンドルに含まれます）
3. アプリ起動時に自動的に読み込まれます

**フォールバック機能**: `bgm.mp3`が見つからない場合は、動的に生成された子供向けメロディーが使用されます。

### ひらがな音声ファイル
音声ファイルは `{ひらがな}.mp3` の命名規則で配置:
```
Resources/Audio/
├── あ.mp3
├── い.mp3
├── う.mp3
└── ...
```

## 📊 データ管理

### 永続化戦略
- **プライマリ**: SwiftData (複雑なリレーショナルデータ)
- **バックアップ**: UserDefaults (重要な進行データ)

### データモデル関係
```
GameProgress (1) ←→ (N) GameLevel
UserSettings (1) ←→ (1) User
Character (N) ←→ (1) UnlockRequirement
```

## 🔧 設定オプション

### 音声設定
- 効果音・BGMの有効/無効
- 音量調整 (0.0 - 1.0)

### ゲーム設定
- 難易度選択 (簡単/普通/難しい)
- ヒント表示の有効/無効
- プレイ時間制限 (0-120分)

### アクセシビリティ
- 大きな文字表示
- アニメーション軽減
- VoiceOver対応

## 🐛 トラブルシューティング

### よくある問題

#### テスト実行時のタイムアウト
```bash
# 延長タイムアウトでテスト実行
xcodebuild test -scheme HiraganaMatchingGame -destination 'platform=iOS Simulator' -testTimeouts 900
```

#### SwiftDataエラー
- シミュレータをリセット: Device → Erase All Content and Settings
- アプリを削除して再インストール

#### 音声再生問題
- シミュレータの音量設定を確認
- Mac本体の音量設定を確認

## 📈 パフォーマンス最適化

### メモリ管理
- 遅延ローディング: レベル別データの必要時読み込み
- 音声プリロード: レベル開始時の戦略的プリロード
- ビューリサイクル: LazyVGridによる効率的描画

### バッテリー最適化
- タイマー管理: 適切なライフサイクル管理
- アニメーション効率化: animatableプロパティの使用
- 音声セッション: 適切な非アクティブ化

## 🔒 プライバシー・セキュリティ

### データ保護
- **ローカルストレージのみ**: 外部データ送信なし
- **個人情報なし**: ゲーム進行データのみ保存
- **アプリサンドボックス**: 全データをアプリコンテナ内に格納
- **子供の安全**: COPPA準拠設計

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 🤝 コントリビューション

1. フォークしてブランチを作成
2. 機能を実装
3. テストを追加
4. プルリクエストを作成

### 開発ガイドライン
- Swift公式スタイルガイドに従う
- 新機能には必ずテストを追加
- アクセシビリティ対応を忘れずに
- 子供向けアプリとしての安全性を考慮

## 📞 サポート

問題や質問がある場合は、GitHubのIssuesで報告してください。

---

**バージョン**: 1.0.0