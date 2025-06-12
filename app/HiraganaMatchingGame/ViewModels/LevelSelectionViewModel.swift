import Foundation
import SwiftData

@Observable
class LevelSelectionViewModel {
    var levelProgressionService: LevelProgressionService
    var gameProgress: GameProgress?
    private var modelContext: ModelContext?
    
    init(levelProgressionService: LevelProgressionService = LevelProgressionService()) {
        self.levelProgressionService = levelProgressionService
    }
    
    func loadProgress(from context: ModelContext) {
        self.modelContext = context
        
        let descriptor = FetchDescriptor<GameProgress>()
        do {
            let results = try context.fetch(descriptor)
            if let existingProgress = results.first {
                gameProgress = existingProgress
                levelProgressionService.loadProgress(from: existingProgress)
            } else {
                // 初回起動時の初期化
                createInitialProgress(in: context)
            }
        } catch {
            print("Failed to load game progress: \(error)")
            createInitialProgress(in: context)
        }
    }
    
    func saveProgress() {
        guard let context = modelContext else { return }
        
        if let progress = gameProgress {
            levelProgressionService.saveProgress(to: progress)
        } else {
            createInitialProgress(in: context)
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save game progress: \(error)")
        }
    }
    
    private func createInitialProgress(in context: ModelContext) {
        let newProgress = GameProgress()
        context.insert(newProgress)
        gameProgress = newProgress
        levelProgressionService.saveProgress(to: newProgress)
    }
    
    func completeLevel(_ level: Int, stars: Int) {
        levelProgressionService.completeLevel(level, earnedStars: stars)
        saveProgress()
    }
    
    func getLevelConfiguration(_ level: Int) -> LevelConfiguration {
        return levelProgressionService.getLevelConfiguration(level)
    }
    
    func isLevelUnlocked(_ level: Int) -> Bool {
        return levelProgressionService.isLevelUnlocked(level)
    }
    
    func getStarsForLevel(_ level: Int) -> Int {
        return levelProgressionService.getStarsForLevel(level)
    }
    
    func getTotalStars() -> Int {
        return levelProgressionService.getTotalStars()
    }
    
    func getProgressionStats() -> ProgressionStats {
        return levelProgressionService.getProgressionStats()
    }
    
    func getRecommendedLevel() -> Int {
        return levelProgressionService.getRecommendedNextLevel()
    }
    
    func getTotalLevels() -> Int {
        return levelProgressionService.getTotalLevels()
    }
    
    func resetAllProgress() {
        levelProgressionService.resetProgress()
        if let progress = gameProgress {
            progress.currentLevel = 1
            progress.totalStars = 0
            progress.unlockedCharacters = ["あ", "い", "う", "え", "お"]
        }
        saveProgress()
    }
}