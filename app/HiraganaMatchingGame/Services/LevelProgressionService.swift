import Foundation
import SwiftData

struct LevelConfiguration {
    let level: Int
    let title: String
    let characters: [String]
    let requiredStars: Int
    let description: String
}

struct ProgressionStats {
    let completedLevels: Int
    let totalStars: Int
    let maxUnlockedLevel: Int
    let completionPercentage: Double
    let averageStarsPerLevel: Double
}

@Observable
class LevelProgressionService {
    private var levelStars: [Int: Int] = [:]
    private var totalStars: Int = 0
    private let totalLevels: Int = HiraganaCatalog.totalLevels
    private var boundProgress: GameProgress?
    
    init() {
        // SwiftData（GameProgress）を優先する設計に移行。
        // ここでは初期値のみ設定し、呼び出し側でloadProgress(from:)を推奨。
        levelStars = [1: 0]
        totalStars = 0
    }
    
    // テスト用のクリーンな初期化
    init(forTesting: Bool) {
        if forTesting {
            levelStars = [1: 0]
            totalStars = 0
        } else {
            // Non-test initialization - start with defaults
            levelStars = [1: 0]
            totalStars = 0
            print("🎮 LevelProgressionService initialized with defaults")
        }
    }
    
    func getCurrentLevel() -> Int {
        getRecommendedNextLevel()
    }
    
    func getMaxUnlockedLevel() -> Int {
        var maxLevel = 1
        for level in 1 ... totalLevels {
            if isLevelUnlocked(level) {
                maxLevel = level
            }
        }
        return maxLevel
    }
    
    func getTotalStars() -> Int {
        // リアルタイムで計算して常に正確な値を返す
        let calculatedTotal = levelStars.values.reduce(0, +)
        if calculatedTotal != totalStars {
            print("⚠️ Star count mismatch: stored=\(totalStars), calculated=\(calculatedTotal)")
            totalStars = calculatedTotal
        }
        return totalStars
    }
    
    func isLevelUnlocked(_ level: Int) -> Bool {
        guard level >= 1 && level <= totalLevels else { return false }
        
        if level == 1 { return true }
        
        // 累積スター数で解放判定
        let requiredStars = getLevelConfiguration(level).requiredStars
        return totalStars >= requiredStars
    }
    
    func completeLevel(_ level: Int, earnedStars: Int) {
        guard level >= 1 && level <= totalLevels else { return }
        guard isLevelUnlocked(level) else { return }
        
        let clampedStars = max(0, min(3, earnedStars))
        let previousStars = levelStars[level] ?? 0
        
        print("🎯 Level \(level) completion: earned=\(clampedStars), previous=\(previousStars)")
        
        // 常に最高スコアを記録（以前より良い場合のみ更新）
        if clampedStars > previousStars {
            levelStars[level] = clampedStars
            print("⭐ Level \(level) stars updated: \(previousStars) → \(clampedStars)")
            
            // 総スター数を再計算
            let newTotalStars = levelStars.values.reduce(0, +)
            totalStars = newTotalStars
            
            print("⭐ Total stars recalculated: \(totalStars)")
            
            // 次のレベルが解放されたかチェック
            let nextLevel = level + 1
            if nextLevel <= totalLevels {
                let wasUnlocked = isLevelUnlocked(nextLevel)
                let nowUnlocked = isLevelUnlocked(nextLevel)
                if !wasUnlocked && nowUnlocked {
                    print("🎉 Level \(nextLevel) unlocked! Total stars: \(totalStars)")
                }
            }

            // SwiftDataへ自動保存（バインドされている場合）
            if let progress = boundProgress {
                saveProgress(to: progress)
            }
        } else {
            print("ℹ️ Level \(level) not updated (earned \(clampedStars) ≤ previous \(previousStars))")
        }
    }
    
    func getStarsForLevel(_ level: Int) -> Int {
        levelStars[level] ?? 0
    }
    
    func canProgressToNextLevel(_ level: Int) -> Bool {
        let starsForLevel = getStarsForLevel(level)
        return starsForLevel >= 2 // 星2つ以上でレベル進行可能
    }
    
    func getProgressionStats() -> ProgressionStats {
        let completedLevels = levelStars.values.filter { $0 > 0 }.count
        let averageStars = completedLevels > 0 ? Double(totalStars) / Double(completedLevels) : 0.0
        let completionPercentage = Double(completedLevels) / Double(totalLevels)
        
        return ProgressionStats(
            completedLevels: completedLevels,
            totalStars: totalStars,
            maxUnlockedLevel: getMaxUnlockedLevel(),
            completionPercentage: completionPercentage,
            averageStarsPerLevel: averageStars
        )
    }
    
    func getRecommendedNextLevel() -> Int {
        for level in 1 ... totalLevels {
            if getStarsForLevel(level) == 0 && isLevelUnlocked(level) {
                return level
            }
        }
        return 1 // フォールバック
    }
    
    func getTotalLevels() -> Int {
        totalLevels
    }
    
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
    
    // MARK: - データ永続化
    
    private func saveToUserDefaults() { /* deprecated: no-op */ }
    
    // デバッグ用：進行データリセット
    func resetProgress() {
        levelStars = [1: 0] // レベル1のみ解放
        totalStars = 0
        print("🔄 Level progress reset")
    }
    
    private func loadFromUserDefaults() { /* deprecated: no-op */ }
    
    func loadProgress(from gameProgress: GameProgress) {
        boundProgress = gameProgress
        // GameProgressから基本データを読み込み
        totalStars = gameProgress.totalStars
        
        // GameProgressから個別レベルのスターデータを復元
        if !gameProgress.levelStarsData.isEmpty {
            do {
                let decodedLevelStars = try JSONDecoder().decode([String: Int].self, from: gameProgress.levelStarsData)
                levelStars.removeAll()
                for (levelString, stars) in decodedLevelStars {
                    if let level = Int(levelString) {
                        levelStars[level] = stars
                    }
                }
                print("📖 Loaded individual level stars from GameProgress")
            } catch {
                print("⚠️ Failed to decode level stars data: \(error)")
                // フォールバック：初期状態
                levelStars = [1: 0]
            }
        } else {
            // levelStarsDataが空の場合は初期状態
            print("📖 No level stars data in GameProgress, using defaults")
            levelStars = [1: 0]
        }
        
        // データの整合性チェック
        let calculatedTotal = levelStars.values.reduce(0, +)
        if calculatedTotal != gameProgress.totalStars {
            print("⚠️ SwiftData integration: star count mismatch - gameProgress=\(gameProgress.totalStars), calculated=\(calculatedTotal)")
            // より高い値を採用（データ欠損を防ぐ）
            totalStars = max(gameProgress.totalStars, calculatedTotal)
            gameProgress.totalStars = totalStars
        }
        
        print("📖 Loaded progress from GameProgress: total_stars=\(totalStars), level_stars=\(levelStars)")
    }
    
    func saveProgress(to gameProgress: GameProgress) {
        boundProgress = gameProgress
        gameProgress.totalStars = totalStars
        gameProgress.currentLevel = getRecommendedNextLevel()
        
        // 個別レベルのスターデータをエンコードして保存
        do {
            var levelStarsDict: [String: Int] = [:]
            for (level, stars) in levelStars {
                levelStarsDict[String(level)] = stars
            }
            gameProgress.levelStarsData = try JSONEncoder().encode(levelStarsDict)
            print("💾 Saved individual level stars to GameProgress")
        } catch {
            print("⚠️ Failed to encode level stars data: \(error)")
        }
        
        // 解放済み文字を更新
        let maxLevel = getMaxUnlockedLevel()
        let config = getLevelConfiguration(maxLevel)
        gameProgress.unlockedCharacters = config.characters
        
        // UserDefaultsへの保存は廃止（SwiftDataを正とする）
    }
}
