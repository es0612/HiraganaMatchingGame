import Foundation

struct StarStatistics {
    let totalStars: Int
    let totalLevelsCompleted: Int
    let averageStarsPerLevel: Double
    let totalTimePlayed: Double
    let averageAccuracy: Double
    let highestStreak: Int
}

/// Service responsible for managing overall game statistics and streak tracking
final class StatisticsService {
    static let shared = StatisticsService()
    
    private var totalTimePlayed: Double = 0
    private var totalAccuracy: Double = 0
    private var totalCompletions: Int = 0
    private var currentStreak: Int = 0
    private var highestStreak: Int = 0
    
    // Provider to read total stars from external service
    var totalStarsProvider: (() -> Int)?
    // Provider to read completed levels count from external service
    var completedLevelsCountProvider: (() -> Int)?
    
    private init() {
        loadStatistics()
    }
    
    // MARK: - Statistics Management
    
    /// Records completion of a level and updates overall statistics
    /// - Parameters:
    ///   - accuracy: Accuracy percentage (0.0 to 1.0)
    ///   - time: Time taken to complete the level
    ///   - starsEarned: Stars earned for this completion
    func recordLevelCompletion(accuracy: Double, time: Double, starsEarned: Int) {
        totalTimePlayed += time
        totalCompletions += 1
        
        // Update average accuracy with running average
        totalAccuracy = ((totalAccuracy * Double(totalCompletions - 1)) + accuracy) / Double(totalCompletions)
        
        // Update streak
        updateStreak(stars: starsEarned)
        
        saveStatistics()
    }
    
    /// Updates the current streak based on stars earned
    /// - Parameter stars: Stars earned in the most recent level
    private func updateStreak(stars: Int) {
        if stars > 0 {
            currentStreak += 1
            highestStreak = max(highestStreak, currentStreak)
        } else {
            currentStreak = 0
        }
    }
    
    /// Gets current streak count
    /// - Returns: Current consecutive successful levels
    func getCurrentStreak() -> Int {
        return currentStreak
    }
    
    /// Gets highest streak achieved
    /// - Returns: Highest consecutive successful levels achieved
    func getHighestStreak() -> Int {
        return highestStreak
    }
    
    /// Gets total time played across all levels
    /// - Returns: Total time in seconds
    func getTotalTimePlayed() -> Double {
        return totalTimePlayed
    }
    
    /// Gets average accuracy across all completions
    /// - Returns: Average accuracy (0.0 to 1.0)
    func getAverageAccuracy() -> Double {
        return totalAccuracy
    }
    
    /// Gets total number of level completions (including retries)
    /// - Returns: Total completion count
    func getTotalCompletions() -> Int {
        return totalCompletions
    }
    
    // MARK: - Comprehensive Statistics
    
    /// Gets comprehensive star statistics combining data from multiple sources
    /// - Returns: Comprehensive statistics including external data
    func getStarStatistics() -> StarStatistics {
        let totalStars = getTotalStars()
        let completedLevels = getCompletedLevelsCount()
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
    
    /// Calculates stars based on accuracy and time performance
    /// - Parameters:
    ///   - correctAnswers: Number of correct answers
    ///   - totalQuestions: Total number of questions
    ///   - timeTaken: Time taken to complete
    /// - Returns: Stars earned (0-3)
    func calculateStars(correctAnswers: Int, totalQuestions: Int, timeTaken: Double) -> Int {
        let accuracy = Double(correctAnswers) / Double(totalQuestions)
        let baseStars: Int
        
        // Base star calculation
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
        
        // Time bonus (average 6 seconds or less per question gives bonus)
        let averageTimePerQuestion = timeTaken / Double(totalQuestions)
        if averageTimePerQuestion <= 6.0 && baseStars > 0 {
            return min(3, baseStars + 1) // Maximum 3 stars
        }
        
        return baseStars
    }
    
    // MARK: - Data Management
    
    /// Resets all statistics to default values
    func resetAllStatistics() {
        totalTimePlayed = 0
        totalAccuracy = 0
        totalCompletions = 0
        currentStreak = 0
        highestStreak = 0
        saveStatistics()
        print("🔄 All statistics reset")
    }
    
    /// Gets total stars from external provider or fallback
    /// - Returns: Total star count
    func getTotalStars() -> Int {
        if let provider = totalStarsProvider {
            return provider()
        }
        // Fallback to UserDefaults for backward compatibility
        return UserDefaults.standard.integer(forKey: "LevelProgression_TotalStars")
    }
    
    /// Gets completed levels count from external provider
    /// - Returns: Number of completed levels
    private func getCompletedLevelsCount() -> Int {
        if let provider = completedLevelsCountProvider {
            return provider()
        }
        // Fallback: return total completions as rough estimate
        return totalCompletions
    }
    
    // MARK: - Persistence
    
    /// Saves statistics to persistent storage
    private func saveStatistics() {
        UserDefaults.standard.set(totalTimePlayed, forKey: "Statistics_TotalTimePlayed")
        UserDefaults.standard.set(totalAccuracy, forKey: "Statistics_TotalAccuracy")
        UserDefaults.standard.set(totalCompletions, forKey: "Statistics_TotalCompletions")
        UserDefaults.standard.set(currentStreak, forKey: "Statistics_CurrentStreak")
        UserDefaults.standard.set(highestStreak, forKey: "Statistics_HighestStreak")
    }
    
    /// Loads statistics from persistent storage
    private func loadStatistics() {
        totalTimePlayed = UserDefaults.standard.double(forKey: "Statistics_TotalTimePlayed")
        totalAccuracy = UserDefaults.standard.double(forKey: "Statistics_TotalAccuracy")
        totalCompletions = UserDefaults.standard.integer(forKey: "Statistics_TotalCompletions")
        currentStreak = UserDefaults.standard.integer(forKey: "Statistics_CurrentStreak")
        highestStreak = UserDefaults.standard.integer(forKey: "Statistics_HighestStreak")
        
        // Migrate from old keys if new ones don't exist and old ones do
        if totalTimePlayed == 0 && UserDefaults.standard.double(forKey: "StarUnlock_TotalTimePlayed") > 0 {
            totalTimePlayed = UserDefaults.standard.double(forKey: "StarUnlock_TotalTimePlayed")
            totalAccuracy = UserDefaults.standard.double(forKey: "StarUnlock_TotalAccuracy")
            totalCompletions = UserDefaults.standard.integer(forKey: "StarUnlock_CompletedLevelsCount")
            currentStreak = UserDefaults.standard.integer(forKey: "StarUnlock_CurrentStreak")
            highestStreak = UserDefaults.standard.integer(forKey: "StarUnlock_HighestStreak")
            saveStatistics() // Save to new keys
        }
    }
}
