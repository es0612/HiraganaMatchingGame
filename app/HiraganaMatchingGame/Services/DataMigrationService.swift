import Foundation
import SwiftData

enum MigrationError: Error, Equatable {
    case migrationFailed(String)
    case dataNotFound
    case corruptedData(String)
}

@Observable
class DataMigrationService {
    
    private let migrationKey = "UnifiedDataMigration_v1_completed"
    
    func isMigrationNeeded() -> Bool {
        return !UserDefaults.standard.bool(forKey: migrationKey)
    }
    
    func performMigration(modelContext: ModelContext) async throws {
        print("🔄 Starting data migration to UnifiedGameProgress...")
        
        // Check if migration is needed
        guard isMigrationNeeded() else {
            print("✅ Migration already completed, skipping")
            return
        }
        
        // Step 1: Migrate or create UnifiedGameProgress
        let unifiedProgress = try await createUnifiedProgress(modelContext: modelContext)
        
        // Step 2: Migrate UserDefaults data from StarUnlockService
        try migrateStarUnlockData(to: unifiedProgress)
        
        // Step 3: Migrate SwiftData from existing GameProgress
        try await migrateGameProgressData(to: unifiedProgress, modelContext: modelContext)
        
        // Step 4: Save the unified progress
        modelContext.insert(unifiedProgress)
        try modelContext.save()
        
        // Step 5: Mark migration as completed
        UserDefaults.standard.set(true, forKey: migrationKey)
        
        print("✅ Data migration completed successfully")
    }
    
    private func createUnifiedProgress(modelContext: ModelContext) async throws -> UnifiedGameProgress {
        // Check if UnifiedGameProgress already exists
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        let existingProgress = try? modelContext.fetch(descriptor)
        
        if let existing = existingProgress?.first {
            print("📖 Found existing UnifiedGameProgress, updating...")
            return existing
        } else {
            print("🆕 Creating new UnifiedGameProgress...")
            return UnifiedGameProgress()
        }
    }
    
    private func migrateStarUnlockData(to unifiedProgress: UnifiedGameProgress) throws {
        print("📦 Migrating StarUnlockService data from UserDefaults...")
        
        // Migrate unlocked characters
        if let characters = UserDefaults.standard.array(forKey: "StarUnlock_UnlockedCharacters") as? [String] {
            unifiedProgress.setUnlockedCharacters(Set(characters))
            print("  ✅ Migrated \(characters.count) unlocked characters")
        } else {
            // Set default characters
            unifiedProgress.setUnlockedCharacters(["あ", "い", "う", "え", "お"])
            print("  📝 Set default unlocked characters")
        }
        
        // Migrate play statistics
        unifiedProgress.totalTimePlayed = UserDefaults.standard.double(forKey: "StarUnlock_TotalTimePlayed")
        unifiedProgress.totalAccuracy = UserDefaults.standard.double(forKey: "StarUnlock_TotalAccuracy")
        unifiedProgress.completedLevelsCount = UserDefaults.standard.integer(forKey: "StarUnlock_CompletedLevelsCount")
        unifiedProgress.currentStreak = UserDefaults.standard.integer(forKey: "StarUnlock_CurrentStreak")
        unifiedProgress.highestStreak = UserDefaults.standard.integer(forKey: "StarUnlock_HighestStreak")
        
        print("  ✅ Migrated play statistics")
        
        // Migrate achievements
        if let achievementStrings = UserDefaults.standard.array(forKey: "StarUnlock_Achievements") as? [String] {
            for achievementString in achievementStrings {
                unifiedProgress.addAchievement(achievementString)
            }
            print("  ✅ Migrated \(achievementStrings.count) achievements")
        }
        
        // Migrate level statistics
        if let levelStarsDict = UserDefaults.standard.dictionary(forKey: "StarUnlock_LevelStars") as? [String: Int] {
            for (levelString, stars) in levelStarsDict {
                if let level = Int(levelString) {
                    // Create basic LevelStats (we don't have detailed data in UserDefaults)
                    unifiedProgress.updateLevelStatistic(
                        level: level,
                        bestStars: stars,
                        bestAccuracy: 1.0, // Approximation
                        bestTime: 30.0, // Approximation
                        totalAttempts: 1, // Approximation
                        averageStars: Double(stars)
                    )
                }
            }
            print("  ✅ Migrated \(levelStarsDict.count) level statistics")
        }
    }
    
    private func migrateGameProgressData(to unifiedProgress: UnifiedGameProgress, modelContext: ModelContext) async throws {
        print("📦 Migrating GameProgress data from SwiftData...")
        
        let descriptor = FetchDescriptor<GameProgress>()
        let existingProgress = try? modelContext.fetch(descriptor)
        
        if let gameProgress = existingProgress?.first {
            // Migrate basic progress data
            unifiedProgress.currentLevel = gameProgress.currentLevel
            unifiedProgress.totalStars = gameProgress.totalStars
            unifiedProgress.lastPlayedDate = gameProgress.lastPlayedDate
            unifiedProgress.levelStarsData = gameProgress.levelStarsData
            
            print("  ✅ Migrated basic progress data")
            print("    - Current Level: \(gameProgress.currentLevel)")
            print("    - Total Stars: \(gameProgress.totalStars)")
            print("    - Last Played: \(gameProgress.lastPlayedDate)")
            
            // Update unlocked characters from existing data if available
            if !gameProgress.unlockedCharacters.isEmpty {
                let existingCharacters = unifiedProgress.getUnlockedCharacters()
                let mergedCharacters = existingCharacters.union(Set(gameProgress.unlockedCharacters))
                unifiedProgress.setUnlockedCharacters(mergedCharacters)
                print("  ✅ Merged unlocked characters (\(mergedCharacters.count) total)")
            }
        } else {
            print("  📝 No existing GameProgress found, using defaults")
        }
    }
    
    // Rollback method for testing or error recovery
    func rollbackMigration() {
        UserDefaults.standard.removeObject(forKey: migrationKey)
        print("🔄 Migration rollback completed")
    }
    
    // Validation method to check migration integrity
    func validateMigration(modelContext: ModelContext) throws -> Bool {
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        let unifiedProgress = try modelContext.fetch(descriptor)
        
        guard let progress = unifiedProgress.first else {
            throw MigrationError.dataNotFound
        }
        
        // Basic validation checks
        let unlockedCharacters = progress.getUnlockedCharacters()
        guard !unlockedCharacters.isEmpty else {
            throw MigrationError.corruptedData("No unlocked characters found")
        }
        
        guard progress.totalStars >= 0 else {
            throw MigrationError.corruptedData("Invalid total stars")
        }
        
        guard progress.currentLevel >= 1 else {
            throw MigrationError.corruptedData("Invalid current level")
        }
        
        print("✅ Migration validation passed")
        return true
    }
    
    // Cleanup old data after successful migration and validation
    func cleanupOldData(modelContext: ModelContext) throws {
        print("🧹 Cleaning up old data after migration...")
        
        // Remove old UserDefaults data
        let keysToRemove = [
            "StarUnlock_UnlockedCharacters",
            "StarUnlock_TotalTimePlayed", 
            "StarUnlock_TotalAccuracy",
            "StarUnlock_CompletedLevelsCount",
            "StarUnlock_CurrentStreak",
            "StarUnlock_HighestStreak", 
            "StarUnlock_Achievements",
            "StarUnlock_LevelStars",
            "LevelProgression_TotalStars" // Legacy fallback key
        ]
        
        for key in keysToRemove {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Note: We keep old GameProgress for now as backup until fully tested
        // In production, you may want to delete old GameProgress records after validation
        
        print("✅ Old UserDefaults data cleaned up")
    }
}