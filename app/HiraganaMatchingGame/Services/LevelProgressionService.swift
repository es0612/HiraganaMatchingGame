import Foundation
import SwiftData

struct LevelConfiguration {
    let level: Int
    let title: String
    let characters: [String]
    let requiredStars: Int
    let questionsCount: Int
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
    private let totalLevels: Int = 10
    
    init() {
        loadFromUserDefaults()
        
        // 初期化時はレベル1のみ解放（初回起動時）
        if levelStars.isEmpty {
            levelStars[1] = 0
        }
    }
    
    func getCurrentLevel() -> Int {
        return getRecommendedNextLevel()
    }
    
    func getMaxUnlockedLevel() -> Int {
        var maxLevel = 1
        for level in 1...totalLevels {
            if isLevelUnlocked(level) {
                maxLevel = level
            }
        }
        return maxLevel
    }
    
    func getTotalStars() -> Int {
        return totalStars
    }
    
    func isLevelUnlocked(_ level: Int) -> Bool {
        guard level >= 1 && level <= totalLevels else { return false }
        
        if level == 1 { return true }
        
        let requiredStars = level - 1
        return totalStars >= requiredStars
    }
    
    func completeLevel(_ level: Int, earnedStars: Int) {
        guard level >= 1 && level <= totalLevels else { return }
        guard isLevelUnlocked(level) else { return }
        
        let clampedStars = max(0, min(3, earnedStars))
        let previousStars = levelStars[level] ?? 0
        
        if clampedStars > previousStars {
            totalStars = totalStars - previousStars + clampedStars
            levelStars[level] = clampedStars
            saveToUserDefaults()
        }
    }
    
    func getStarsForLevel(_ level: Int) -> Int {
        return levelStars[level] ?? 0
    }
    
    func addStars(_ stars: Int) {
        totalStars += stars
    }
    
    func getProgressionStats() -> ProgressionStats {
        let completedLevels = levelStars.keys.filter { levelStars[$0]! > 0 }.count
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
        for level in 1...totalLevels {
            if getStarsForLevel(level) == 0 && isLevelUnlocked(level) {
                return level
            }
        }
        return 1 // フォールバック
    }
    
    func getTotalLevels() -> Int {
        return totalLevels
    }
    
    func getLevelConfiguration(_ level: Int) -> LevelConfiguration {
        guard level >= 1 && level <= totalLevels else {
            return LevelConfiguration(
                level: 1,
                title: "あ行をおぼえよう",
                characters: ["あ", "い", "う", "え", "お"],
                requiredStars: 0,
                questionsCount: 5,
                description: "ひらがなの基本、あ行をマスターしよう！"
            )
        }
        
        let configurations: [Int: LevelConfiguration] = [
            1: LevelConfiguration(
                level: 1,
                title: "あ行をおぼえよう",
                characters: ["あ", "い", "う", "え", "お"],
                requiredStars: 0,
                questionsCount: 5,
                description: "ひらがなの基本、あ行をマスターしよう！"
            ),
            2: LevelConfiguration(
                level: 2,
                title: "か行をおぼえよう",
                characters: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ"],
                requiredStars: 1,
                questionsCount: 5,
                description: "か行を覚えて、ひらがなの世界を広げよう！"
            ),
            3: LevelConfiguration(
                level: 3,
                title: "さ行をおぼえよう",
                characters: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ"],
                requiredStars: 2,
                questionsCount: 6,
                description: "さ行をマスターして、更にレベルアップ！"
            ),
            4: LevelConfiguration(
                level: 4,
                title: "た行をおぼえよう",
                characters: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と"],
                requiredStars: 3,
                questionsCount: 6,
                description: "た行も仲間に加えて、どんどん上達！"
            ),
            5: LevelConfiguration(
                level: 5,
                title: "な行をおぼえよう",
                characters: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の"],
                requiredStars: 4,
                questionsCount: 7,
                description: "な行を覚えて、ひらがなマスターに近づこう！"
            ),
            6: LevelConfiguration(
                level: 6,
                title: "は行をおぼえよう",
                characters: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ"],
                requiredStars: 5,
                questionsCount: 7,
                description: "は行をマスターして、さらなる高みを目指そう！"
            ),
            7: LevelConfiguration(
                level: 7,
                title: "ま行をおぼえよう",
                characters: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も"],
                requiredStars: 6,
                questionsCount: 8,
                description: "ま行も覚えて、ひらがなの達人に！"
            ),
            8: LevelConfiguration(
                level: 8,
                title: "や行をおぼえよう",
                characters: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ"],
                requiredStars: 7,
                questionsCount: 8,
                description: "や行をマスターして、ゴールが見えてきた！"
            ),
            9: LevelConfiguration(
                level: 9,
                title: "ら行をおぼえよう",
                characters: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ"],
                requiredStars: 8,
                questionsCount: 9,
                description: "ら行をクリアして、最終ステージへ！"
            ),
            10: LevelConfiguration(
                level: 10,
                title: "すべてのひらがな",
                characters: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ", "わ", "ゐ", "ゑ", "を", "ん"],
                requiredStars: 9,
                questionsCount: 10,
                description: "全てのひらがなをマスターして、真のひらがな博士になろう！"
            )
        ]
        
        return configurations[level]!
    }
    
    func resetProgress() {
        levelStars.removeAll()
        levelStars[1] = 0
        totalStars = 0
        saveToUserDefaults()
    }
    
    // MARK: - データ永続化
    
    private func saveToUserDefaults() {
        UserDefaults.standard.set(totalStars, forKey: "LevelProgression_TotalStars")
        
        // レベルスター辞書を保存
        var levelStarsDict: [String: Int] = [:]
        for (level, stars) in levelStars {
            levelStarsDict[String(level)] = stars
        }
        UserDefaults.standard.set(levelStarsDict, forKey: "LevelProgression_LevelStars")
    }
    
    private func loadFromUserDefaults() {
        totalStars = UserDefaults.standard.integer(forKey: "LevelProgression_TotalStars")
        
        if let levelStarsDict = UserDefaults.standard.dictionary(forKey: "LevelProgression_LevelStars") as? [String: Int] {
            levelStars.removeAll()
            for (levelString, stars) in levelStarsDict {
                if let level = Int(levelString) {
                    levelStars[level] = stars
                }
            }
        }
    }
    
    func loadProgress(from gameProgress: GameProgress) {
        totalStars = gameProgress.totalStars
        
        // GameProgressから個別レベルのスター情報を復元
        // 実装では追加のプロパティが必要かもしれません
        for level in 1...totalLevels {
            if gameProgress.unlockedCharacters.count >= getLevelConfiguration(level).characters.count {
                // 仮の実装：解放文字数からレベル完了を推測
                levelStars[level] = 1
            }
        }
    }
    
    func saveProgress(to gameProgress: GameProgress) {
        gameProgress.totalStars = totalStars
        gameProgress.currentLevel = getRecommendedNextLevel()
        
        // 解放済み文字を更新
        let maxLevel = getMaxUnlockedLevel()
        let config = getLevelConfiguration(maxLevel)
        gameProgress.unlockedCharacters = config.characters
    }
}