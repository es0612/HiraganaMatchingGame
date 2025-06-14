import Foundation

enum SpecialUnlockRequirement {
    case allLevelsCompleted
    case perfectStreak(count: Int)
    case totalStars(count: Int)
    case timeRecord(seconds: Double)
}

enum Achievement: String, CaseIterable {
    case firstCompletion = "初回クリア"
    case perfectScore = "パーフェクト"
    case speedRun = "スピードマスター"
    case streak = "連続チャンピオン"
    case collector = "コレクター"
    case master = "ひらがなマスター"
    
    var description: String {
        switch self {
        case .firstCompletion: return "初めてレベルをクリア！"
        case .perfectScore: return "100%の正解率を達成！"
        case .speedRun: return "素早くクリア！"
        case .streak: return "連続でレベルクリア！"
        case .collector: return "たくさんのキャラクターを解放！"
        case .master: return "全てのひらがなをマスター！"
        }
    }
    
    var iconName: String {
        switch self {
        case .firstCompletion: return "star.circle.fill"
        case .perfectScore: return "crown.fill"
        case .speedRun: return "bolt.circle.fill"
        case .streak: return "flame.fill"
        case .collector: return "cube.box.fill"
        case .master: return "graduationcap.fill"
        }
    }
}

struct LevelStatistics {
    let level: Int
    let bestStars: Int
    let bestAccuracy: Double
    let bestTime: Double
    let totalAttempts: Int
    let averageStars: Double
    let lastPlayed: Date?
}

struct StarStatistics {
    let totalStars: Int
    let totalLevelsCompleted: Int
    let averageStarsPerLevel: Double
    let totalTimePlayed: Double
    let averageAccuracy: Double
    let highestStreak: Int
}

struct UnlockProgress {
    let unlockedCount: Int
    let totalCount: Int
    let progressPercentage: Double
    let currentGroup: String
    let nextGroup: String?
}

struct NextUnlockInfo {
    let requiredStars: Int
    let charactersToUnlock: [String]
    let groupName: String
}

@Observable
class StarUnlockService {
    private var totalStars: Int = 0
    private var unlockedCharacters: Set<String> = ["あ", "い", "う", "え", "お"]
    private var levelStatistics: [Int: LevelStatistics] = [:]
    private var unlockedAchievements: Set<Achievement> = []
    private var totalTimePlayed: Double = 0
    private var totalAccuracy: Double = 0
    private var completedLevelsCount: Int = 0
    private var currentStreak: Int = 0
    private var highestStreak: Int = 0
    
    var onCharacterUnlocked: (([String]) -> Void)?
    var onAchievementUnlocked: ((Achievement) -> Void)?
    
    private let characterGroups: [String: [String]] = [
        "あ行": ["あ", "い", "う", "え", "お"],
        "か行": ["か", "き", "く", "け", "こ"],
        "さ行": ["さ", "し", "す", "せ", "そ"],
        "た行": ["た", "ち", "つ", "て", "と"],
        "な行": ["な", "に", "ぬ", "ね", "の"],
        "は行": ["は", "ひ", "ふ", "へ", "ほ"],
        "ま行": ["ま", "み", "む", "め", "も"],
        "や行": ["や", "ゆ", "よ"],
        "ら行": ["ら", "り", "る", "れ", "ろ"],
        "わ行": ["わ", "ゐ", "ゑ", "を", "ん"]
    ]
    
    private let groupUnlockRequirements: [String: Int] = [
        "あ行": 0,
        "か行": 1,
        "さ行": 3,
        "た行": 6,
        "な行": 10,
        "は行": 15,
        "ま行": 21,
        "や行": 28,
        "ら行": 36,
        "わ行": 45
    ]
    
    init() {
        loadFromUserDefaults()
        updateUnlockedCharacters()
    }
    
    func getUnlockedCharacters() -> [String] {
        return Array(unlockedCharacters).sorted()
    }
    
    func isCharacterUnlocked(_ character: String) -> Bool {
        return unlockedCharacters.contains(character)
    }
    
    func addStars(_ stars: Int) {
        totalStars += stars
    }
    
    func getTotalStars() -> Int {
        return totalStars
    }
    
    func updateUnlockedCharacters() {
        var newlyUnlocked: [String] = []
        
        for (groupName, requiredStars) in groupUnlockRequirements.sorted(by: { $0.value < $1.value }) {
            if totalStars >= requiredStars {
                if let characters = characterGroups[groupName] {
                    for character in characters {
                        if !unlockedCharacters.contains(character) {
                            unlockedCharacters.insert(character)
                            newlyUnlocked.append(character)
                        }
                    }
                }
            }
        }
        
        // 新しく解放されたキャラクターがある場合は通知
        if !newlyUnlocked.isEmpty {
            onCharacterUnlocked?(newlyUnlocked)
            checkCollectorAchievement()
        }
    }
    
    func unlockSpecialCharacter(_ character: String, requirement: SpecialUnlockRequirement) {
        if canUnlockSpecialCharacter(requirement) {
            unlockedCharacters.insert(character)
        }
    }
    
    private func canUnlockSpecialCharacter(_ requirement: SpecialUnlockRequirement) -> Bool {
        switch requirement {
        case .allLevelsCompleted:
            return completedLevelsCount >= 10
        case .perfectStreak(let count):
            return highestStreak >= count
        case .totalStars(let count):
            return totalStars >= count
        case .timeRecord(let seconds):
            let bestTime = levelStatistics.values.min { $0.bestTime < $1.bestTime }?.bestTime ?? Double.infinity
            return bestTime <= seconds
        }
    }
    
    func calculateStars(correctAnswers: Int, totalQuestions: Int, timeTaken: Double) -> Int {
        let accuracy = Double(correctAnswers) / Double(totalQuestions)
        let baseStars: Int
        
        // 基本スター計算
        switch accuracy {
        case 1.0:
            baseStars = 3
        case 0.8...0.99:
            baseStars = 2
        case 0.6...0.79:
            baseStars = 1
        default:
            baseStars = 0
        }
        
        // 時間ボーナス（平均1問あたり10秒以下でボーナス）
        let averageTimePerQuestion = timeTaken / Double(totalQuestions)
        if averageTimePerQuestion <= 6.0 && baseStars > 0 {
            return min(3, baseStars + 1) // 最大3スター
        }
        
        return baseStars
    }
    
    func recordLevelCompletion(level: Int, stars: Int, accuracy: Double, time: Double) {
        let previousBestStars = levelStatistics[level]?.bestStars ?? 0
        let starDifference = max(0, stars - previousBestStars)
        
        // スター更新
        if starDifference > 0 {
            addStars(starDifference)
            updateUnlockedCharacters()
        }
        
        // レベル統計更新
        updateLevelStatistics(level: level, stars: stars, accuracy: accuracy, time: time)
        
        // 全体統計更新
        updateOverallStatistics(accuracy: accuracy, time: time)
        
        // 実績チェック
        checkAchievements(level: level, stars: stars, accuracy: accuracy, time: time)
        
        // 連続記録更新
        updateStreak(stars: stars)
        
        // データを保存
        saveToUserDefaults()
    }
    
    private func updateLevelStatistics(level: Int, stars: Int, accuracy: Double, time: Double) {
        if let existing = levelStatistics[level] {
            let newBestStars = max(existing.bestStars, stars)
            let newBestAccuracy = max(existing.bestAccuracy, accuracy)
            let newBestTime = min(existing.bestTime, time)
            let newTotalAttempts = existing.totalAttempts + 1
            let newAverageStars = ((existing.averageStars * Double(existing.totalAttempts)) + Double(stars)) / Double(newTotalAttempts)
            
            levelStatistics[level] = LevelStatistics(
                level: level,
                bestStars: newBestStars,
                bestAccuracy: newBestAccuracy,
                bestTime: newBestTime,
                totalAttempts: newTotalAttempts,
                averageStars: newAverageStars,
                lastPlayed: Date()
            )
        } else {
            levelStatistics[level] = LevelStatistics(
                level: level,
                bestStars: stars,
                bestAccuracy: accuracy,
                bestTime: time,
                totalAttempts: 1,
                averageStars: Double(stars),
                lastPlayed: Date()
            )
            completedLevelsCount += 1
        }
    }
    
    private func updateOverallStatistics(accuracy: Double, time: Double) {
        totalTimePlayed += time
        totalAccuracy = ((totalAccuracy * Double(completedLevelsCount - 1)) + accuracy) / Double(completedLevelsCount)
    }
    
    private func updateStreak(stars: Int) {
        if stars > 0 {
            currentStreak += 1
            highestStreak = max(highestStreak, currentStreak)
        } else {
            currentStreak = 0
        }
    }
    
    func getStarStatistics() -> StarStatistics {
        let completedLevels = levelStatistics.keys.count
        let averageStars = completedLevels > 0 ? Double(totalStars) / Double(completedLevels) : 0.0
        
        return StarStatistics(
            totalStars: totalStars,
            totalLevelsCompleted: completedLevels,
            averageStarsPerLevel: averageStars,
            totalTimePlayed: totalTimePlayed,
            averageAccuracy: totalAccuracy,
            highestStreak: highestStreak
        )
    }
    
    func getLevelStatistics(level: Int) -> LevelStatistics? {
        return levelStatistics[level]
    }
    
    func getUnlockProgress() -> UnlockProgress {
        let totalCharacters = characterGroups.values.flatMap { $0 }.count
        let progressPercentage = Double(unlockedCharacters.count) / Double(totalCharacters)
        
        let currentGroup = getCurrentUnlockGroup()
        let nextGroup = getNextUnlockGroup()
        
        return UnlockProgress(
            unlockedCount: unlockedCharacters.count,
            totalCount: totalCharacters,
            progressPercentage: progressPercentage,
            currentGroup: currentGroup,
            nextGroup: nextGroup
        )
    }
    
    func getNextUnlockInfo() -> NextUnlockInfo? {
        let sortedGroups = groupUnlockRequirements.sorted { $0.value < $1.value }
        
        for (groupName, requiredStars) in sortedGroups {
            if totalStars < requiredStars {
                let charactersToUnlock = characterGroups[groupName] ?? []
                return NextUnlockInfo(
                    requiredStars: requiredStars - totalStars,
                    charactersToUnlock: charactersToUnlock,
                    groupName: groupName
                )
            }
        }
        
        return nil
    }
    
    private func getCurrentUnlockGroup() -> String {
        let sortedGroups = groupUnlockRequirements.sorted { $0.value > $1.value }
        
        for (groupName, requiredStars) in sortedGroups {
            if totalStars >= requiredStars {
                return groupName
            }
        }
        
        return "あ行"
    }
    
    private func getNextUnlockGroup() -> String? {
        let sortedGroups = groupUnlockRequirements.sorted { $0.value < $1.value }
        
        for (groupName, requiredStars) in sortedGroups {
            if totalStars < requiredStars {
                return groupName
            }
        }
        
        return nil
    }
    
    func getUnlockedAchievements() -> Set<Achievement> {
        return unlockedAchievements
    }
    
    private func checkAchievements(level: Int, stars: Int, accuracy: Double, time: Double) {
        // 初回クリア
        if completedLevelsCount == 1 && !unlockedAchievements.contains(.firstCompletion) {
            unlockAchievement(.firstCompletion)
        }
        
        // パーフェクト
        if accuracy == 1.0 && !unlockedAchievements.contains(.perfectScore) {
            unlockAchievement(.perfectScore)
        }
        
        // スピードラン（平均5秒以下）
        let averageTime = time / 5.0 // 5問想定
        if averageTime <= 5.0 && !unlockedAchievements.contains(.speedRun) {
            unlockAchievement(.speedRun)
        }
        
        // 連続クリア
        if currentStreak >= 5 && !unlockedAchievements.contains(.streak) {
            unlockAchievement(.streak)
        }
        
        // マスター（全レベルクリア）
        if completedLevelsCount >= 10 && !unlockedAchievements.contains(.master) {
            unlockAchievement(.master)
        }
    }
    
    private func checkCollectorAchievement() {
        if unlockedCharacters.count >= 30 && !unlockedAchievements.contains(.collector) {
            unlockAchievement(.collector)
        }
    }
    
    private func unlockAchievement(_ achievement: Achievement) {
        unlockedAchievements.insert(achievement)
        onAchievementUnlocked?(achievement)
    }
    
    func resetProgress() {
        totalStars = 0
        unlockedCharacters = ["あ", "い", "う", "え", "お"]
        levelStatistics.removeAll()
        unlockedAchievements.removeAll()
        totalTimePlayed = 0
        totalAccuracy = 0
        completedLevelsCount = 0
        currentStreak = 0
        highestStreak = 0
        updateUnlockedCharacters()
        saveToUserDefaults()
    }
    
    // MARK: - データ永続化
    
    private func saveToUserDefaults() {
        UserDefaults.standard.set(totalStars, forKey: "StarUnlock_TotalStars")
        UserDefaults.standard.set(Array(unlockedCharacters), forKey: "StarUnlock_UnlockedCharacters")
        UserDefaults.standard.set(totalTimePlayed, forKey: "StarUnlock_TotalTimePlayed")
        UserDefaults.standard.set(totalAccuracy, forKey: "StarUnlock_TotalAccuracy")
        UserDefaults.standard.set(completedLevelsCount, forKey: "StarUnlock_CompletedLevelsCount")
        UserDefaults.standard.set(currentStreak, forKey: "StarUnlock_CurrentStreak")
        UserDefaults.standard.set(highestStreak, forKey: "StarUnlock_HighestStreak")
        
        // 実績保存
        let achievementStrings = unlockedAchievements.map { $0.rawValue }
        UserDefaults.standard.set(achievementStrings, forKey: "StarUnlock_Achievements")
        
        // レベル統計保存（簡略化）
        var levelStarsDict: [String: Int] = [:]
        for (level, stats) in levelStatistics {
            levelStarsDict[String(level)] = stats.bestStars
        }
        UserDefaults.standard.set(levelStarsDict, forKey: "StarUnlock_LevelStars")
    }
    
    private func loadFromUserDefaults() {
        totalStars = UserDefaults.standard.integer(forKey: "StarUnlock_TotalStars")
        
        if let characters = UserDefaults.standard.array(forKey: "StarUnlock_UnlockedCharacters") as? [String] {
            unlockedCharacters = Set(characters)
        } else {
            unlockedCharacters = ["あ", "い", "う", "え", "お"] // デフォルト
        }
        
        totalTimePlayed = UserDefaults.standard.double(forKey: "StarUnlock_TotalTimePlayed")
        totalAccuracy = UserDefaults.standard.double(forKey: "StarUnlock_TotalAccuracy")
        completedLevelsCount = UserDefaults.standard.integer(forKey: "StarUnlock_CompletedLevelsCount")
        currentStreak = UserDefaults.standard.integer(forKey: "StarUnlock_CurrentStreak")
        highestStreak = UserDefaults.standard.integer(forKey: "StarUnlock_HighestStreak")
        
        // 実績読み込み
        if let achievementStrings = UserDefaults.standard.array(forKey: "StarUnlock_Achievements") as? [String] {
            unlockedAchievements = Set(achievementStrings.compactMap { Achievement(rawValue: $0) })
        }
        
        // レベル統計読み込み（簡略化）
        if let levelStarsDict = UserDefaults.standard.dictionary(forKey: "StarUnlock_LevelStars") as? [String: Int] {
            for (levelString, stars) in levelStarsDict {
                if let level = Int(levelString) {
                    levelStatistics[level] = LevelStatistics(
                        level: level,
                        bestStars: stars,
                        bestAccuracy: 1.0, // 仮の値
                        bestTime: 30.0, // 仮の値
                        totalAttempts: 1,
                        averageStars: Double(stars),
                        lastPlayed: Date()
                    )
                }
            }
        }
    }
}