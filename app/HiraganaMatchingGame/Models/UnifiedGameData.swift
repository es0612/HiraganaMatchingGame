import Foundation
import SwiftData

// MARK: - Achievement Model
@Model
final class AchievementRecord {
    var achievementType: String
    var unlockedDate: Date
    
    init(achievementType: String, unlockedDate: Date = Date()) {
        self.achievementType = achievementType
        self.unlockedDate = unlockedDate
    }
}

// MARK: - Level Statistics Model
@Model
final class LevelStats {
    var level: Int
    var bestStars: Int
    var bestAccuracy: Double
    var bestTime: Double
    var totalAttempts: Int
    var averageStars: Double
    var lastPlayed: Date
    
    init(level: Int, bestStars: Int = 0, bestAccuracy: Double = 0.0, bestTime: Double = 0.0, totalAttempts: Int = 0, averageStars: Double = 0.0, lastPlayed: Date = Date()) {
        self.level = level
        self.bestStars = bestStars
        self.bestAccuracy = bestAccuracy
        self.bestTime = bestTime
        self.totalAttempts = totalAttempts
        self.averageStars = averageStars
        self.lastPlayed = lastPlayed
    }
}

// MARK: - Unified Game Progress Model
@Model
final class UnifiedGameProgress {
    // Basic progress (from GameProgress)
    var currentLevel: Int
    var totalStars: Int
    var lastPlayedDate: Date
    var levelStarsData: Data // JSON encoded level stars
    
    // Character unlock data (from StarUnlockService)
    var unlockedCharactersData: Data // JSON encoded Set<String>
    
    // Play statistics (from StarUnlockService)
    var totalTimePlayed: Double
    var totalAccuracy: Double
    var completedLevelsCount: Int
    var currentStreak: Int
    var highestStreak: Int
    
    // Relations to other models
    @Relationship(deleteRule: .cascade) var achievements: [AchievementRecord]
    @Relationship(deleteRule: .cascade) var levelStatistics: [LevelStats]
    
    init(currentLevel: Int = 1, totalStars: Int = 0) {
        self.currentLevel = currentLevel
        self.totalStars = totalStars
        self.lastPlayedDate = Date()
        self.levelStarsData = Data()
        self.unlockedCharactersData = Data()
        self.totalTimePlayed = 0.0
        self.totalAccuracy = 0.0
        self.completedLevelsCount = 0
        self.currentStreak = 0
        self.highestStreak = 0
        self.achievements = []
        self.levelStatistics = []
    }
    
    // MARK: - Convenience Methods
    
    func getUnlockedCharacters() -> Set<String> {
        guard !unlockedCharactersData.isEmpty else {
            return ["あ", "い", "う", "え", "お"] // Default
        }
        
        do {
            let characters = try JSONDecoder().decode(Set<String>.self, from: unlockedCharactersData)
            return characters
        } catch {
            print("⚠️ Failed to decode unlocked characters: \(error)")
            return ["あ", "い", "う", "え", "お"]
        }
    }
    
    func setUnlockedCharacters(_ characters: Set<String>) {
        do {
            unlockedCharactersData = try JSONEncoder().encode(characters)
        } catch {
            print("⚠️ Failed to encode unlocked characters: \(error)")
        }
    }
    
    func getLevelStars() -> [Int: Int] {
        guard !levelStarsData.isEmpty else { return [1: 0] }
        
        do {
            let levelStarsDict = try JSONDecoder().decode([String: Int].self, from: levelStarsData)
            var result: [Int: Int] = [:]
            for (levelString, stars) in levelStarsDict {
                if let level = Int(levelString) {
                    result[level] = stars
                }
            }
            return result
        } catch {
            print("⚠️ Failed to decode level stars: \(error)")
            return [1: 0]
        }
    }
    
    func setLevelStars(_ levelStars: [Int: Int]) {
        do {
            var levelStarsDict: [String: Int] = [:]
            for (level, stars) in levelStars {
                levelStarsDict[String(level)] = stars
            }
            levelStarsData = try JSONEncoder().encode(levelStarsDict)
        } catch {
            print("⚠️ Failed to encode level stars: \(error)")
        }
    }
    
    func addStars(_ stars: Int) {
        totalStars += stars
    }
    
    func advanceToNextLevel() {
        currentLevel += 1
    }
    
    func updateLastPlayedDate() {
        lastPlayedDate = Date()
    }
    
    // MARK: - Achievement Management
    
    func hasAchievement(_ achievementType: String) -> Bool {
        return achievements.contains { $0.achievementType == achievementType }
    }
    
    func addAchievement(_ achievementType: String) {
        if !hasAchievement(achievementType) {
            let record = AchievementRecord(achievementType: achievementType)
            achievements.append(record)
        }
    }
    
    func getAchievements() -> Set<String> {
        return Set(achievements.map { $0.achievementType })
    }
    
    // MARK: - Level Statistics Management
    
    func getLevelStatistic(for level: Int) -> LevelStats? {
        return levelStatistics.first { $0.level == level }
    }
    
    func updateLevelStatistic(level: Int, bestStars: Int, bestAccuracy: Double, bestTime: Double, totalAttempts: Int, averageStars: Double) {
        if let existingStat = getLevelStatistic(for: level) {
            existingStat.bestStars = max(existingStat.bestStars, bestStars)
            existingStat.bestAccuracy = max(existingStat.bestAccuracy, bestAccuracy)
            existingStat.bestTime = min(existingStat.bestTime, bestTime)
            existingStat.totalAttempts = totalAttempts
            existingStat.averageStars = averageStars
            existingStat.lastPlayed = Date()
        } else {
            let newStat = LevelStats(
                level: level,
                bestStars: bestStars,
                bestAccuracy: bestAccuracy,
                bestTime: bestTime,
                totalAttempts: totalAttempts,
                averageStars: averageStars,
                lastPlayed: Date()
            )
            levelStatistics.append(newStat)
        }
    }
}