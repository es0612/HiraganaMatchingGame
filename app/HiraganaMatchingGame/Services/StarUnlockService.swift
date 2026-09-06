import Foundation

/// Facade service that coordinates character unlocking, achievements, and statistics
/// Delegates responsibilities to specialized services for better maintainability
@Observable
class StarUnlockService {
    
    // MARK: - Specialized Services
    private let characterUnlockService = CharacterUnlockService.shared
    private let achievementService = AchievementService.shared
    private let levelStatisticsService = LevelStatisticsService.shared
    private let statisticsService = StatisticsService.shared
    
    // MARK: - Callbacks
    var onCharacterUnlocked: (([String]) -> Void)? {
        didSet {
            characterUnlockService.onCharacterUnlocked = onCharacterUnlocked
        }
    }
    
    var onAchievementUnlocked: ((Achievement) -> Void)? {
        didSet {
            achievementService.onAchievementUnlocked = onAchievementUnlocked
        }
    }
    
    /// Optional provider to read total stars from LevelProgressionService
    var totalStarsProvider: (() -> Int)? {
        didSet {
            characterUnlockService.totalStarsProvider = totalStarsProvider
            statisticsService.totalStarsProvider = totalStarsProvider
        }
    }
    
    init() {
        setupServiceDependencies()
    }
    
    // MARK: - Setup
    
    /// Sets up dependencies between services
    private func setupServiceDependencies() {
        // Set up achievement service dependencies
        achievementService.unlockedCharacterCountProvider = { [weak self] in
            self?.characterUnlockService.getUnlockedCharacters().count ?? 0
        }
        achievementService.completedLevelsCountProvider = { [weak self] in
            self?.levelStatisticsService.getCompletedLevelsCount() ?? 0
        }
        achievementService.currentStreakProvider = { [weak self] in
            self?.statisticsService.getCurrentStreak() ?? 0
        }
        
        // Set up statistics service dependencies
        statisticsService.completedLevelsCountProvider = { [weak self] in
            self?.levelStatisticsService.getCompletedLevelsCount() ?? 0
        }
    }
    
    // MARK: - Character Unlocking (Delegated to CharacterUnlockService)
    
    func getUnlockedCharacters() -> [String] {
        characterUnlockService.getUnlockedCharacters()
    }
    
    func isCharacterUnlocked(_ character: String) -> Bool {
        characterUnlockService.isCharacterUnlocked(character)
    }
    
    func updateUnlockedCharacters() {
        characterUnlockService.updateUnlockedCharacters()
        // Check collector achievement after character unlocking
        achievementService.checkCollectorAchievement()
    }
    
    func unlockSpecialCharacter(_ character: String, requirement: SpecialUnlockRequirement) {
        characterUnlockService.unlockSpecialCharacter(character, requirement: requirement)
    }
    
    // MARK: - Statistics (Delegated to StatisticsService)
    
    func calculateStars(correctAnswers: Int, totalQuestions: Int, timeTaken: Double) -> Int {
        statisticsService.calculateStars(correctAnswers: correctAnswers, totalQuestions: totalQuestions, timeTaken: timeTaken)
    }
    
    /// StarUnlockServiceはスター管理しない（LevelProgressionServiceが管理）
    func getTotalStarsFromService() -> Int {
        statisticsService.getTotalStars()
    }
    
    // MARK: - Level Completion (Coordinated across services)
    
    func recordLevelCompletion(level: Int, stars: Int, accuracy: Double, time: Double) {
        print("🎯 StarUnlockService recording level \(level) completion: stars=\(stars)")
        
        // Record in level statistics service
        levelStatisticsService.recordLevelCompletion(level: level, stars: stars, accuracy: accuracy, time: time)
        
        // Record in general statistics service  
        statisticsService.recordLevelCompletion(accuracy: accuracy, time: time, starsEarned: stars)
        
        // Check achievements
        let isFirstCompletion = levelStatisticsService.getCompletedLevelsCount() == 1
        achievementService.checkAchievements(level: level, stars: stars, accuracy: accuracy, time: time, isFirstCompletion: isFirstCompletion)
        
        // Update character unlocking (references LevelProgressionService star count)
        updateUnlockedCharacters()
    }
    
    // MARK: - Level Statistics (Delegated to LevelStatisticsService)
    
    func getLevelStatistics(level: Int) -> LevelStatistics? {
        levelStatisticsService.getLevelStatistics(level: level)
    }
    
    // MARK: - Overall Statistics (Delegated to StatisticsService)
    
    func getStarStatistics() -> StarStatistics {
        statisticsService.getStarStatistics()
    }
    
    // MARK: - Progress Information (Delegated to CharacterUnlockService)
    
    func getUnlockProgress() -> UnlockProgress {
        characterUnlockService.getUnlockProgress()
    }
    
    func getNextUnlockInfo() -> NextUnlockInfo? {
        characterUnlockService.getNextUnlockInfo()
    }
    
    // MARK: - Achievements (Delegated to AchievementService)
    
    func getUnlockedAchievements() -> Set<Achievement> {
        achievementService.getUnlockedAchievements()
    }
    
    // MARK: - Data Management (Coordinated across services)
    
    func resetProgress() {
        characterUnlockService.resetProgress()
        achievementService.resetAllAchievements()
        levelStatisticsService.resetAllStatistics()
        statisticsService.resetAllStatistics()
        
        // Update character unlocking after reset
        updateUnlockedCharacters()
        
        print("🔄 All progress reset across all services")
    }
}
