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
    /// 旧 LevelProgressionService が UserDefaults に保存していた合計スター（SwiftData 移行前のデータ）
    private let legacyTotalStarsKey = "LevelProgression_TotalStars"

    /// 読み書きに使う UserDefaults。
    /// 本番は `.standard`、テストは `UserDefaults(suiteName:)` で作った独立インスタンスを渡し、
    /// 並列実行されるテスト同士がグローバル状態を奪い合わないようにする。
    private let defaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        defaults = userDefaults
    }

    func isMigrationNeeded() -> Bool {
        !defaults.bool(forKey: migrationKey)
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

        // Step 4: Carry over legacy total stars (pre-SwiftData) if they are higher
        migrateLegacyTotalStars(to: unifiedProgress)

        // Step 5: Save the unified progress
        modelContext.insert(unifiedProgress)
        try modelContext.save()

        // Step 6: Mark migration as completed
        defaults.set(true, forKey: migrationKey)

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
        if let characters = defaults.array(forKey: "StarUnlock_UnlockedCharacters") as? [String] {
            unifiedProgress.setUnlockedCharacters(Set(characters))
            print("  ✅ Migrated \(characters.count) unlocked characters")
        } else {
            // Set default characters
            unifiedProgress.setUnlockedCharacters(["あ", "い", "う", "え", "お"])
            print("  📝 Set default unlocked characters")
        }

        // Migrate play statistics
        // 破損データ（負の値）はそのまま持ち込まず 0 に補正する
        unifiedProgress.totalTimePlayed = max(0, defaults.double(forKey: "StarUnlock_TotalTimePlayed"))
        unifiedProgress.totalAccuracy = max(0, defaults.double(forKey: "StarUnlock_TotalAccuracy"))
        unifiedProgress.completedLevelsCount = max(0, defaults.integer(forKey: "StarUnlock_CompletedLevelsCount"))
        unifiedProgress.currentStreak = max(0, defaults.integer(forKey: "StarUnlock_CurrentStreak"))
        unifiedProgress.highestStreak = max(0, defaults.integer(forKey: "StarUnlock_HighestStreak"))

        print("  ✅ Migrated play statistics")

        // Migrate achievements
        if let achievementStrings = defaults.array(forKey: "StarUnlock_Achievements") as? [String] {
            for achievementString in achievementStrings {
                unifiedProgress.addAchievement(achievementString)
            }
            print("  ✅ Migrated \(achievementStrings.count) achievements")
        }

        // Migrate level statistics
        if let levelStarsDict = defaults.dictionary(forKey: "StarUnlock_LevelStars") as? [String: Int] {
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

    /// 旧バージョン（SwiftData 導入前）が UserDefaults に保存していた合計スターを引き継ぐ。
    /// SwiftData 側の値と比較して大きい方を採用し、古いバージョンから更新したユーザーのスターが消えないようにする。
    private func migrateLegacyTotalStars(to unifiedProgress: UnifiedGameProgress) {
        let legacyTotalStars = defaults.integer(forKey: legacyTotalStarsKey)
        guard legacyTotalStars > unifiedProgress.totalStars else { return }

        unifiedProgress.totalStars = legacyTotalStars
        print("  ✅ Carried over legacy total stars: \(legacyTotalStars)")
    }

    // Rollback method for testing or error recovery
    func rollbackMigration() {
        defaults.removeObject(forKey: migrationKey)
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
            legacyTotalStarsKey
        ]

        for key in keysToRemove {
            defaults.removeObject(forKey: key)
        }

        // Note: We keep old GameProgress for now as backup until fully tested
        // In production, you may want to delete old GameProgress records after validation

        print("✅ Old UserDefaults data cleaned up")
    }
}
