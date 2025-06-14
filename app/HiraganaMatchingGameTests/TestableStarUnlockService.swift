import Foundation
@testable import HiraganaMatchingGame

// テスト専用のStarUnlockService（@Observableなし）
class TestableStarUnlockService {
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
    
    func getUnlockedCharacters() -> [String] {
        return Array(unlockedCharacters)
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
        var newlyUnlockedCharacters: [String] = []
        
        for (groupName, requiredStars) in groupUnlockRequirements {
            if totalStars >= requiredStars {
                if let characters = characterGroups[groupName] {
                    for character in characters {
                        if !unlockedCharacters.contains(character) {
                            unlockedCharacters.insert(character)
                            newlyUnlockedCharacters.append(character)
                        }
                    }
                }
            }
        }
        
        if !newlyUnlockedCharacters.isEmpty {
            onCharacterUnlocked?(newlyUnlockedCharacters)
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
            return true // 簡易実装
        }
    }
    
    func calculateStars(correctAnswers: Int, totalQuestions: Int, timeTaken: Double) -> Int {
        let accuracy = Double(correctAnswers) / Double(totalQuestions)
        
        var stars = 0
        if accuracy >= 0.9 {
            stars = 3
        } else if accuracy >= 0.7 {
            stars = 2
        } else if accuracy >= 0.5 {
            stars = 1
        }
        
        // 時間ボーナス
        if timeTaken <= 30.0 && stars > 0 {
            stars = min(3, stars + 1)
        }
        
        return stars
    }
    
    func recordLevelCompletion(level: Int, stars: Int, accuracy: Double, time: Double) {
        // 既存の統計を更新
        if let existingStats = levelStatistics[level] {
            let newBestStars = max(existingStats.bestStars, stars)
            let newBestAccuracy = max(existingStats.bestAccuracy, accuracy)
            let newBestTime = min(existingStats.bestTime, time)
            let newAttempts = existingStats.totalAttempts + 1
            
            levelStatistics[level] = LevelStatistics(
                level: level,
                bestStars: newBestStars,
                bestAccuracy: newBestAccuracy,
                bestTime: newBestTime,
                totalAttempts: newAttempts,
                averageStars: Double(totalStars) / Double(newAttempts),
                lastPlayed: Date()
            )
            
            // 改善された場合のみスターを追加
            if stars > existingStats.bestStars {
                addStars(stars - existingStats.bestStars)
            }
        } else {
            // 新しいレベル完了
            levelStatistics[level] = LevelStatistics(
                level: level,
                bestStars: stars,
                bestAccuracy: accuracy,
                bestTime: time,
                totalAttempts: 1,
                averageStars: Double(stars),
                lastPlayed: Date()
            )
            addStars(stars)
            completedLevelsCount += 1
        }
        
        updateOverallStatistics(accuracy: accuracy, time: time)
        updateStreak(stars: stars)
        checkAchievements(level: level, stars: stars, accuracy: accuracy, time: time)
    }
    
    private func updateOverallStatistics(accuracy: Double, time: Double) {
        totalTimePlayed += time
        totalAccuracy = (totalAccuracy + accuracy) / 2.0
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
        let completedLevels = levelStatistics.count
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
        return UnlockProgress(
            unlockedCount: unlockedCharacters.count,
            totalCount: totalCharacters,
            progressPercentage: Double(unlockedCharacters.count) / Double(totalCharacters),
            currentGroup: getCurrentUnlockGroup(),
            nextGroup: getNextUnlockGroup()
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
        let sortedGroups = groupUnlockRequirements.sorted { $0.value < $1.value }
        
        for (groupName, requiredStars) in sortedGroups.reversed() {
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
        // 初回クリア実績
        if levelStatistics.count == 1 {
            unlockAchievement(.firstCompletion)
        }
        
        // パーフェクト実績
        if stars == 3 && accuracy >= 1.0 {
            unlockAchievement(.perfectScore)
        }
        
        // スピード実績
        if time <= 20.0 {
            unlockAchievement(.speedRun)
        }
        
        // 連続実績
        if currentStreak >= 5 {
            unlockAchievement(.streak)
        }
        
        checkCollectorAchievement()
        checkMasterAchievement()
    }
    
    private func checkCollectorAchievement() {
        if unlockedCharacters.count >= 25 {
            unlockAchievement(.collector)
        }
    }
    
    private func checkMasterAchievement() {
        if unlockedCharacters.count >= 50 {
            unlockAchievement(.master)
        }
    }
    
    private func unlockAchievement(_ achievement: Achievement) {
        if !unlockedAchievements.contains(achievement) {
            unlockedAchievements.insert(achievement)
            onAchievementUnlocked?(achievement)
        }
    }
}