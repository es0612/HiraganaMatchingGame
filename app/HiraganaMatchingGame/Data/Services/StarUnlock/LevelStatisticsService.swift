import Foundation

struct LevelStatistics {
    let level: Int
    let bestStars: Int
    let bestAccuracy: Double
    let bestTime: Double
    let totalAttempts: Int
    let averageStars: Double
    let lastPlayed: Date?
}

/// Service responsible for managing per-level statistics and performance tracking
final class LevelStatisticsService {
    static let shared = LevelStatisticsService()
    
    private var levelStatistics: [Int: LevelStatistics] = [:]
    
    private init() {
        loadLevelStatistics()
    }
    
    // MARK: - Level Statistics Management
    
    /// Records completion of a level and updates statistics
    /// - Parameters:
    ///   - level: The level that was completed
    ///   - stars: Stars earned for the level
    ///   - accuracy: Accuracy percentage (0.0 to 1.0)
    ///   - time: Time taken to complete the level
    func recordLevelCompletion(level: Int, stars: Int, accuracy: Double, time: Double) {
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
        }
        
        saveLevelStatistics()
    }
    
    /// Gets statistics for a specific level
    /// - Parameter level: The level to get statistics for
    /// - Returns: Level statistics or nil if level hasn't been played
    func getLevelStatistics(level: Int) -> LevelStatistics? {
        return levelStatistics[level]
    }
    
    /// Gets statistics for all played levels
    /// - Returns: Dictionary of level to statistics
    func getAllLevelStatistics() -> [Int: LevelStatistics] {
        return levelStatistics
    }
    
    /// Gets the number of completed levels (levels that have been played at least once)
    /// - Returns: Count of completed levels
    func getCompletedLevelsCount() -> Int {
        return levelStatistics.keys.count
    }
    
    /// Gets the best time across all levels
    /// - Returns: Best time in seconds, or nil if no levels have been completed
    func getBestTimeAcrossAllLevels() -> Double? {
        return levelStatistics.values.min { $0.bestTime < $1.bestTime }?.bestTime
    }
    
    /// Gets the highest accuracy across all levels
    /// - Returns: Highest accuracy (0.0 to 1.0), or nil if no levels have been completed
    func getHighestAccuracyAcrossAllLevels() -> Double? {
        return levelStatistics.values.max { $0.bestAccuracy < $1.bestAccuracy }?.bestAccuracy
    }
    
    /// Gets the most recently played level
    /// - Returns: Level number of most recently played level, or nil if no levels played
    func getMostRecentlyPlayedLevel() -> Int? {
        return levelStatistics.values.max {
            guard let date1 = $0.lastPlayed, let date2 = $1.lastPlayed else { return false }
            return date1 < date2
        }?.level
    }
    
    /// Checks if a level has been completed (played at least once)
    /// - Parameter level: The level to check
    /// - Returns: True if the level has been played
    func isLevelCompleted(_ level: Int) -> Bool {
        return levelStatistics[level] != nil
    }
    
    // MARK: - Data Management
    
    /// Resets all level statistics
    func resetAllStatistics() {
        levelStatistics.removeAll()
        saveLevelStatistics()
        print("🔄 All level statistics reset")
    }
    
    // MARK: - Persistence
    
    /// Saves level statistics to persistent storage
    private func saveLevelStatistics() {
        var levelStarsDict: [String: Int] = [:]
        var levelAccuracyDict: [String: Double] = [:]
        var levelTimeDict: [String: Double] = [:]
        var levelAttemptsDict: [String: Int] = [:]
        
        for (level, stats) in levelStatistics {
            let levelKey = String(level)
            levelStarsDict[levelKey] = stats.bestStars
            levelAccuracyDict[levelKey] = stats.bestAccuracy
            levelTimeDict[levelKey] = stats.bestTime
            levelAttemptsDict[levelKey] = stats.totalAttempts
        }
        
        UserDefaults.standard.set(levelStarsDict, forKey: "LevelStatistics_BestStars")
        UserDefaults.standard.set(levelAccuracyDict, forKey: "LevelStatistics_BestAccuracy")
        UserDefaults.standard.set(levelTimeDict, forKey: "LevelStatistics_BestTime")
        UserDefaults.standard.set(levelAttemptsDict, forKey: "LevelStatistics_TotalAttempts")
    }
    
    /// Loads level statistics from persistent storage
    private func loadLevelStatistics() {
        // Load from new keys first
        if let levelStarsDict = UserDefaults.standard.dictionary(forKey: "LevelStatistics_BestStars") as? [String: Int],
           let levelAccuracyDict = UserDefaults.standard.dictionary(forKey: "LevelStatistics_BestAccuracy") as? [String: Double],
           let levelTimeDict = UserDefaults.standard.dictionary(forKey: "LevelStatistics_BestTime") as? [String: Double],
           let levelAttemptsDict = UserDefaults.standard.dictionary(forKey: "LevelStatistics_TotalAttempts") as? [String: Int] {
            
            for levelKey in levelStarsDict.keys {
                if let level = Int(levelKey),
                   let stars = levelStarsDict[levelKey],
                   let accuracy = levelAccuracyDict[levelKey],
                   let time = levelTimeDict[levelKey],
                   let attempts = levelAttemptsDict[levelKey] {
                    
                    levelStatistics[level] = LevelStatistics(
                        level: level,
                        bestStars: stars,
                        bestAccuracy: accuracy,
                        bestTime: time,
                        totalAttempts: attempts,
                        averageStars: Double(stars), // Simplified - could be calculated more precisely
                        lastPlayed: Date() // Current date as fallback
                    )
                }
            }
        } else {
            // Migrate from old key if exists
            if let oldLevelStarsDict = UserDefaults.standard.dictionary(forKey: "StarUnlock_LevelStars") as? [String: Int] {
                for (levelString, stars) in oldLevelStarsDict {
                    if let level = Int(levelString) {
                        levelStatistics[level] = LevelStatistics(
                            level: level,
                            bestStars: stars,
                            bestAccuracy: 1.0, // Fallback value
                            bestTime: 30.0,     // Fallback value
                            totalAttempts: 1,
                            averageStars: Double(stars),
                            lastPlayed: Date()
                        )
                    }
                }
                saveLevelStatistics() // Save to new keys
            }
        }
    }
}
