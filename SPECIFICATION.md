# ひらがなマッチングゲーム - 技術仕様書

## アプリケーション概要

### 基本情報
- **アプリ名**: ひらがなマッチングゲーム (Hiragana Matching Game)
- **対象年齢**: 4〜7歳
- **カテゴリ**: 教育アプリ
- **プラットフォーム**: iOS 17.0+
- **開発言語**: Swift 6.0
- **UIフレームワーク**: SwiftUI
- **バージョン**: 1.0.0

### 教育目標
- ひらがな文字の認識能力向上
- 文字と音の関連付け学習
- 段階的な学習による着実な習得
- ゲーミフィケーションによる学習意欲向上

## システムアーキテクチャ

### アーキテクチャパターン
- **MVVM (Model-View-ViewModel)**: UI分離とテスタビリティ
- **Service Layer**: ビジネスロジックの集約
- **Repository Pattern**: データアクセスの抽象化

### レイヤー構成
```
┌──────────────────────────────┐
│         Presentation         │
│    (SwiftUI Views)          │
├──────────────────────────────┤
│         ViewModel           │
│   (Business Logic)          │
├──────────────────────────────┤
│         Service             │
│    (Core Features)          │
├──────────────────────────────┤
│         Repository          │
│   (Data Access)             │
├──────────────────────────────┤
│         Storage             │
│  (SwiftData + UserDefaults) │
└──────────────────────────────┘
```

## データモデル設計

### SwiftDataモデル

#### Character
```swift
@Model
final class Character {
    var name: String                // ひらがな文字
    var imageName: String          // 関連画像名
    var unlockRequirement: Int     // 解放必要スター数
    var isUnlocked: Bool           // 解放状態
    var unlockedDate: Date?        // 解放日時
}
```

#### GameLevel
```swift
@Model
final class GameLevel {
    var levelNumber: Int           // レベル番号 (1-10)
    var hiraganaSet: [String]     // 対象ひらがな文字
    var isCompleted: Bool         // 完了状態
    var bestScore: Int            // 最高スコア
    var completionDate: Date?     // 完了日時
}
```

#### GameProgress
```swift
@Model
final class GameProgress {
    var currentLevel: Int         // 現在のレベル
    var totalStars: Int          // 総獲得スター数
    var unlockedCharacters: [String] // 解放済み文字
    var lastPlayedDate: Date     // 最終プレイ日
    var levelStarsData: Data     // レベル別スター数(JSON)
}
```

#### UserSettings
```swift
@Model
final class UserSettings {
    var soundEnabled: Bool        // 効果音有効
    var musicEnabled: Bool        // BGM有効
    var soundVolume: Double       // 音量 (0.0-1.0)
    var difficulty: GameDifficulty // 難易度
    var showHints: Bool           // ヒント表示
    var playtimeLimit: Int        // プレイ時間制限(分)
    var largeText: Bool           // 大きな文字
    var reduceAnimations: Bool    // アニメーション軽減
}
```

### 列挙型定義

#### GameDifficulty
```swift
enum GameDifficulty: String, CaseIterable {
    case easy = "簡単"     // 2択、厳しめスター条件
    case normal = "普通"   // 3択、標準スター条件
    case hard = "難しい"   // 4択、甘めスター条件
}
```

#### Achievement
```swift
enum Achievement: String, CaseIterable {
    case firstCompletion = "初回クリア"
    case perfectScore = "パーフェクト"
    case speedRun = "スピードマスター"
    case streak = "連続チャンピオン"
    case collector = "コレクター"
    case master = "ひらがなマスター"
}
```

## ゲームロジック仕様

### レベル設計

#### レベル構成表
| レベル | 文字範囲 | 文字数 | 必要スター | 問題数 | 解放条件 |
|--------|----------|--------|------------|--------|----------|
| 1 | あ行 | 5 | 0 | 18 | 初期解放 |
| 2 | あ〜か行 | 10 | 2 | 22 | レベル1で2スター |
| 3 | あ〜さ行 | 15 | 4 | 14 | 累計4スター |
| 4 | あ〜た行 | 20 | 6 | 14 | 累計6スター |
| 5 | あ〜な行 | 25 | 8 | 16 | 累計8スター |
| 6 | あ〜は行 | 30 | 10 | 16 | 累計10スター |
| 7 | あ〜ま行 | 35 | 12 | 18 | 累計12スター |
| 8 | あ〜や行 | 38 | 14 | 18 | 累計14スター |
| 9 | あ〜ら行 | 43 | 16 | 20 | 累計16スター |
| 10 | 全ひらがな | 47 | 18 | 22 | 累計18スター |

### 問題生成アルゴリズム

#### 基本方針
1. **文字の均等出題**: 各文字を最低1回出題
2. **ランダム追加**: 残り問題数をランダムに埋める
3. **最終シャッフル**: 出題順序をランダム化

#### 実装疑似コード
```swift
func generateQuestions(level: Int, count: Int) -> [GameQuestion] {
    let characters = getCharactersForLevel(level)
    var questions: [GameQuestion] = []
    
    // 各文字を最低1回出題
    for character in characters.shuffled() {
        if questions.count < count {
            questions.append(createQuestion(for: character))
        }
    }
    
    // 残り問題数をランダムに埋める
    while questions.count < count {
        let randomCharacter = characters.randomElement()
        questions.append(createQuestion(for: randomCharacter))
    }
    
    return questions.shuffled()
}
```

### スコア計算システム

#### 難易度別スター計算
```swift
func calculateStars(accuracy: Double, difficulty: GameDifficulty) -> Int {
    switch difficulty {
    case .easy:    // 厳しめ
        return accuracy >= 1.0 ? 3 : accuracy >= 0.9 ? 2 : accuracy >= 0.8 ? 1 : 0
    case .normal:  // 標準
        return accuracy >= 1.0 ? 3 : accuracy >= 0.8 ? 2 : accuracy >= 0.6 ? 1 : 0
    case .hard:    // 甘め
        return accuracy >= 1.0 ? 3 : accuracy >= 0.75 ? 2 : accuracy >= 0.5 ? 1 : 0
    }
}
```

## サービス層設計

### LevelProgressionService

#### 責務
- レベル進行の管理
- スター数による解放制御
- 進行状況の永続化

#### 主要メソッド
```swift
class LevelProgressionService {
    func isLevelUnlocked(_ level: Int) -> Bool
    func completeLevel(_ level: Int, earnedStars: Int)
    func getTotalStars() -> Int
    func getRecommendedNextLevel() -> Int
    func getLevelConfiguration(_ level: Int) -> LevelConfiguration
    func resetProgress()
}
```

### GameLogicService

#### 責務
- 問題生成ロジック
- 答え合わせ処理
- スコア計算

#### 主要メソッド
```swift
class GameLogicService {
    func generateQuestionsForLevel(_ level: Int, questionCount: Int) -> [GameQuestion]
    func generateChoices(for hiragana: String, count: Int) -> [HiraganaItem]
    func calculateStars(correctAnswers: Int, totalQuestions: Int) -> Int
    func validateAnswer(_ answer: HiraganaItem, for question: GameQuestion) -> Bool
}
```

### AudioService

#### 責務
- 音声ファイル管理
- BGM制御
- 効果音再生

#### 主要メソッド
```swift
class AudioService {
    func playHiraganaSound(_ hiragana: String)
    func playCorrectSound()
    func playIncorrectSound()
    func startBackgroundMusic()
    func stopBackgroundMusic()
    func setVolume(_ volume: Float)
}
```

### StarUnlockService

#### 責務
- キャラクター解放管理
- 実績トラッキング
- 統計計算

#### 主要メソッド
```swift
class StarUnlockService {
    func updateUnlockedCharacters()
    func getUnlockedCharacters() -> [String]
    func recordLevelCompletion(level: Int, stars: Int, accuracy: Double, time: Double)
    func getStarStatistics() -> StarStatistics
    func getUnlockedAchievements() -> Set<Achievement>
}
```

## 音声システム設計

### アーキテクチャ
```
AudioService (統合管理)
├── SpeechSynthesizer (音声合成)
├── AudioPlayer (ファイル再生)
├── BGMGenerator (BGM生成)
└── EffectPlayer (効果音)
```

### BGM生成アルゴリズム

#### メロディー設計
- **ベース**: きらきら星モチーフ
- **音階**: C5-A5 (523.25Hz - 880.00Hz)
- **構成**: 8小節の繰り返し
- **ハーモニー**: 3度上のハーモニー追加

#### 実装詳細
```swift
private func generateBackgroundMusic() -> Data {
    let melodyNotes: [(frequency: Double, duration: Double)] = [
        (523.25, 0.6), // C5 - Do
        (523.25, 0.6), // C5 - Do
        (783.99, 0.6), // G5 - Sol
        (783.99, 0.6), // G5 - Sol
        (880.00, 0.6), // A5 - La
        (880.00, 0.6), // A5 - La
        (783.99, 1.2), // G5 - Sol
        // ... continues
    ]
    
    // PCM音声データ生成
    // ADSR envelope適用
    // ハーモニー合成
    // トレモロ効果追加
}
```

## UI/UX設計仕様

### ナビゲーション構造
```
LaunchView (3秒スプラッシュ)
├── LevelSelectionView (メインハブ)
    ├── GameView (ゲームプレイ)
    ├── CharacterCollectionView (コレクション)
    ├── AchievementsView (実績・統計)
    └── SettingsView (設定)
```

### デザインシステム

#### カラーパレット
- **プライマリ**: ブルー系グラデーション
- **セカンダリ**: パープル系グラデーション
- **アクセント**: オレンジ（推奨レベル）
- **フィードバック**: 緑（正解）、赤（不正解）

#### タイポグラフィ
- **タイトル**: .largeTitle, bold
- **ヘッドライン**: .headline, semibold
- **ボディ**: .body, regular
- **キャプション**: .caption, light

### アニメーション仕様

#### パーティクルエフェクト
```swift
struct ParticleEffect {
    var type: ParticleType      // correct, incorrect
    var emoji: String           // 🎉, 💫, etc.
    var count: Int              // 10-20個
    var duration: Double        // 2.0秒
    var physics: PhysicsType    // gravity, explosion
}
```

#### トランジション
- **画面遷移**: .spring(response: 0.4, dampingFraction: 0.6)
- **ボタン押下**: .easeInOut(duration: 0.2)
- **スター表示**: .spring(response: 0.6, dampingFraction: 0.8)

## テスト設計

### テスト戦略

#### ユニットテスト
- **対象**: Service層、ViewModel層
- **フレームワーク**: Swift Testing
- **カバレッジ目標**: 80%以上

#### 統合テスト
- **対象**: サービス間連携、データフロー
- **重点領域**: 進行保存、設定同期

#### UIテスト（現在無効化）
- **フレームワーク**: XCUITest
- **対象**: 完全なユーザーフロー

### テスト環境対応

#### TestUtils実装
```swift
struct TestUtils {
    static var isTestEnvironment: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    static func debugPrint(_ message: String) {
        if isTestEnvironment {
            print("[TEST] \(message)")
        }
    }
}
```

#### テストモード対応
- **Timer無効化**: テスト環境でのタイムアウト防止
- **音声無効化**: CI環境での安定実行
- **SwiftData設定**: インメモリDB使用

## データ永続化設計

### 永続化戦略

#### プライマリストレージ: SwiftData
- **用途**: 複雑なリレーショナルデータ
- **対象**: ユーザー設定、進行状況、実績
- **利点**: 型安全、クエリ最適化

#### セカンダリストレージ: UserDefaults
- **用途**: 重要な進行データのバックアップ
- **対象**: 総スター数、レベル進行状況
- **利点**: 軽量、高速アクセス

### データ同期機構

#### 整合性保証
```swift
private func validateDataIntegrity() {
    let swiftDataTotal = gameProgress.totalStars
    let userDefaultsTotal = levelStars.values.reduce(0, +)
    
    if swiftDataTotal != userDefaultsTotal {
        print("⚠️ Data mismatch detected")
        let correctedTotal = max(swiftDataTotal, userDefaultsTotal)
        syncDataStores(correctedValue: correctedTotal)
    }
}
```

## パフォーマンス最適化

### メモリ管理

#### 遅延ローディング
- **レベルデータ**: レベル選択時に読み込み
- **音声ファイル**: 必要時に動的生成
- **画像リソース**: システムEmoji使用でメモリ削減

#### ビューの効率化
```swift
// LazyVGridを使用した効率的レンダリング
LazyVGrid(columns: columns) {
    ForEach(levels, id: \.self) { level in
        LevelButtonView(level: level)
    }
}
```

### バッテリー最適化

#### タイマー管理
```swift
private func startGameTimer() {
    if TestUtils.isTestEnvironment {
        return // テスト環境ではタイマー無効
    }
    
    gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
        updateGameTime()
    }
}
```

#### 音声セッション管理
```swift
deinit {
    try? AVAudioSession.sharedInstance().setActive(false)
}
```

## セキュリティ・プライバシー

### データ保護

#### 子供向けアプリ対応
- **COPPA準拠**: 13歳未満の個人情報収集禁止
- **データ収集なし**: 外部送信一切なし
- **ローカルストレージのみ**: 全データをデバイス内保存

#### セキュリティ対策
```swift
// アプリサンドボックス内でのみデータアクセス
private var documentsDirectory: URL {
    FileManager.default.urls(for: .documentDirectory, 
                           in: .userDomainMask).first!
}
```

## デプロイメント仕様

### App Store対応

#### メタデータ
- **カテゴリ**: Education
- **年齢制限**: 4+ (preschool)
- **価格**: 無料
- **アプリ内購入**: なし

#### 必要素材
- **アイコン**: 1024x1024px
- **スクリーンショット**: iPhone/iPad各5枚
- **プレビュー動画**: 30秒以内

### システム要件
- **iOS**: 17.0以上
- **ストレージ**: 50MB未満
- **RAM**: 最小1GB推奨
- **プロセッサ**: A12 Bionic以降推奨

## 今後の拡張計画

### Phase 2機能
- **カタカナ対応**: カタカナ学習モード追加
- **単語学習**: ひらがなを使った単語学習
- **手書き練習**: Apple Pencil対応の書字練習

### Phase 3機能
- **マルチプレイヤー**: 家族内での競争要素
- **学習分析**: 詳細な学習進捗分析
- **教師ダッシュボード**: 教育機関向け管理機能

---

**文書バージョン**: 1.0  
**最終更新**: 2025年6月16日  
**レビュー担当**: Claude AI Assistant