import Foundation

enum Achievement: String, CaseIterable {
    case firstCompletion = "初回クリア"
    case perfectScore = "パーフェクト"
    case speedRun = "スピードマスター"
    case streak = "連続チャンピオン"
    case collector = "コレクター"
    case master = "ひらがなマスター"
    
    var description: String {
        switch self {
        case .firstCompletion: return "初めてレベルを星2つ以上でクリア！"
        case .perfectScore: return "100%の正解率を達成！"
        case .speedRun: return "超速クリア！（平均3秒以下）"
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

/// Service responsible for managing game achievements
final class AchievementService {
    static let shared = AchievementService()
    
    private var unlockedAchievements: Set<Achievement> = []
    
    var onAchievementUnlocked: ((Achievement) -> Void)?
    
    // Dependencies for achievement checking
    var unlockedCharacterCountProvider: (() -> Int)?
    var completedLevelsCountProvider: (() -> Int)?
    var currentStreakProvider: (() -> Int)?
    
    private init() {
        loadAchievements()
    }
    
    // MARK: - Achievement Access
    
    /// Gets all unlocked achievements
    /// - Returns: Set of unlocked achievements
    func getUnlockedAchievements() -> Set<Achievement> {
        unlockedAchievements
    }
    
    /// Checks if a specific achievement is unlocked
    /// - Parameter achievement: The achievement to check
    /// - Returns: True if the achievement is unlocked
    func isAchievementUnlocked(_ achievement: Achievement) -> Bool {
        unlockedAchievements.contains(achievement)
    }
    
    /// Gets all available achievements (for UI display)
    /// - Returns: Array of all possible achievements
    func getAllAchievements() -> [Achievement] {
        Achievement.allCases
    }
    
    /// Gets progress percentage for achievements
    /// - Returns: Percentage of achievements unlocked (0.0 to 1.0)
    func getAchievementProgress() -> Double {
        let totalAchievements = Achievement.allCases.count
        return totalAchievements > 0 ? Double(unlockedAchievements.count) / Double(totalAchievements) : 0.0
    }
    
    // MARK: - Achievement Checking
    
    /// Checks and unlocks achievements based on level completion
    /// - Parameters:
    ///   - level: The level that was completed
    ///   - stars: Stars earned for the level
    ///   - accuracy: Accuracy percentage (0.0 to 1.0)
    ///   - time: Time taken to complete the level
    ///   - isFirstCompletion: Whether this is the first time completing any level
    func checkAchievements(level: Int, stars: Int, accuracy: Double, time: Double, isFirstCompletion: Bool) {
        // First completion achievement (must get at least 2 stars)
        if isFirstCompletion && stars >= 2 && !unlockedAchievements.contains(.firstCompletion) {
            unlockAchievement(.firstCompletion)
        }
        
        // Perfect score achievement
        if accuracy == 1.0 && !unlockedAchievements.contains(.perfectScore) {
            unlockAchievement(.perfectScore)
        }
        
        // Speed run achievement (average 3 seconds or less per question)
        let averageTime = time / Double(max(level * 2, 5)) // Estimate questions based on level
        if averageTime <= 3.0 && stars >= 2 && !unlockedAchievements.contains(.speedRun) {
            unlockAchievement(.speedRun)
        }
        
        // Streak achievement (requires external streak provider)
        if let currentStreak = currentStreakProvider?(),
           currentStreak >= 5 && !unlockedAchievements.contains(.streak) {
            unlockAchievement(.streak)
        }
        
        // Master achievement (all levels completed)
        if let completedLevels = completedLevelsCountProvider?(),
           completedLevels >= 10 && !unlockedAchievements.contains(.master) {
            unlockAchievement(.master)
        }
    }
    
    /// Checks collector achievement (called when characters are unlocked)
    func checkCollectorAchievement() {
        if let unlockedCount = unlockedCharacterCountProvider?(),
           unlockedCount >= 30 && !unlockedAchievements.contains(.collector) {
            unlockAchievement(.collector)
        }
    }
    
    /// Manually checks all achievements that can be checked without level completion
    func recheckAllAchievements() {
        checkCollectorAchievement()
        
        // Check master achievement
        if let completedLevels = completedLevelsCountProvider?(),
           completedLevels >= 10 && !unlockedAchievements.contains(.master) {
            unlockAchievement(.master)
        }
    }
    
    // MARK: - Achievement Management
    
    /// Unlocks a specific achievement
    /// - Parameter achievement: The achievement to unlock
    private func unlockAchievement(_ achievement: Achievement) {
        unlockedAchievements.insert(achievement)
        onAchievementUnlocked?(achievement)
        print("🏆 Achievement unlocked: \(achievement.rawValue) - \(achievement.description)")
        saveAchievements()
    }
    
    /// Manually unlocks an achievement (for testing or special cases)
    /// - Parameter achievement: The achievement to unlock
    func manuallyUnlockAchievement(_ achievement: Achievement) {
        if !unlockedAchievements.contains(achievement) {
            unlockAchievement(achievement)
        }
    }
    
    /// Resets all achievements
    func resetAllAchievements() {
        unlockedAchievements.removeAll()
        saveAchievements()
        print("🔄 All achievements reset")
    }
    
    // MARK: - Statistics
    
    /// Gets statistics about achievements
    /// - Returns: Tuple containing (unlocked count, total count, percentage)
    func getAchievementStatistics() -> (unlockedCount: Int, totalCount: Int, percentage: Double) {
        let totalCount = Achievement.allCases.count
        let unlockedCount = unlockedAchievements.count
        let percentage = totalCount > 0 ? Double(unlockedCount) / Double(totalCount) : 0.0
        
        return (unlockedCount: unlockedCount, totalCount: totalCount, percentage: percentage)
    }
    
    /// Gets recently unlocked achievements (for notifications)
    /// Note: This would need to be enhanced with timestamps for full functionality
    /// - Returns: Array of recently unlocked achievements
    func getRecentlyUnlockedAchievements() -> [Achievement] {
        // Simplified implementation - returns all unlocked achievements
        // In a full implementation, this would filter by unlock timestamp
        Array(unlockedAchievements)
    }
    
    // MARK: - Persistence
    
    /// Saves achievements to persistent storage
    private func saveAchievements() {
        let achievementStrings = unlockedAchievements.map { $0.rawValue }
        UserDefaults.standard.set(achievementStrings, forKey: "Achievement_UnlockedAchievements")
    }
    
    /// Loads achievements from persistent storage
    private func loadAchievements() {
        if let achievementStrings = UserDefaults.standard.array(forKey: "Achievement_UnlockedAchievements") as? [String] {
            unlockedAchievements = Set(achievementStrings.compactMap { Achievement(rawValue: $0) })
        } else {
            // Migrate from old key if exists
            if let oldAchievementStrings = UserDefaults.standard.array(forKey: "StarUnlock_Achievements") as? [String] {
                unlockedAchievements = Set(oldAchievementStrings.compactMap { Achievement(rawValue: $0) })
                saveAchievements() // Save to new key
            } else {
                unlockedAchievements = [] // Start with no achievements
            }
        }
    }
}
