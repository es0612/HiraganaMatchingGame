import Foundation
import Testing
import SwiftData
@testable import HiraganaMatchingGame

@Suite("データマイグレーションシステムテスト")
struct DataMigrationServiceTests {
    
    // MARK: - Test Helpers
    
    @MainActor
    private func createTestModelContainer() throws -> ModelContainer {
        let schema = Schema([
            GameProgress.self,
            GameLevel.self,
            UserSettings.self,
            Character.self,
            UnifiedGameProgress.self,
            AchievementRecord.self,
            LevelStats.self,
        ])
        return try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
    }
    
    private func setupTestUserDefaults() {
        // StarUnlockService legacy data
        UserDefaults.standard.set(["あ", "い", "う", "え", "お", "か", "き"], forKey: "StarUnlock_UnlockedCharacters")
        UserDefaults.standard.set(120.5, forKey: "StarUnlock_TotalTimePlayed")
        UserDefaults.standard.set(0.85, forKey: "StarUnlock_TotalAccuracy")
        UserDefaults.standard.set(3, forKey: "StarUnlock_CompletedLevelsCount")
        UserDefaults.standard.set(5, forKey: "StarUnlock_CurrentStreak")
        UserDefaults.standard.set(8, forKey: "StarUnlock_HighestStreak")
        UserDefaults.standard.set(["firstCompletion", "perfectScore"], forKey: "StarUnlock_Achievements")
        UserDefaults.standard.set(["1": 3, "2": 2, "3": 1], forKey: "StarUnlock_LevelStars")
        
        // Legacy LevelProgression data
        UserDefaults.standard.set(6, forKey: "LevelProgression_TotalStars")
        
        // Migration flag should be false for testing
        UserDefaults.standard.set(false, forKey: "UnifiedDataMigration_v1_completed")
    }
    
    private func cleanupTestUserDefaults() {
        let keysToClean = [
            "StarUnlock_UnlockedCharacters",
            "StarUnlock_TotalTimePlayed",
            "StarUnlock_TotalAccuracy", 
            "StarUnlock_CompletedLevelsCount",
            "StarUnlock_CurrentStreak",
            "StarUnlock_HighestStreak",
            "StarUnlock_Achievements",
            "StarUnlock_LevelStars",
            "LevelProgression_TotalStars",
            "UnifiedDataMigration_v1_completed"
        ]
        
        for key in keysToClean {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    // MARK: - Migration Need Detection Tests
    
    @Test("マイグレーション要否判定テスト")
    func migrationNeedDetection() {
        cleanupTestUserDefaults()
        let service = DataMigrationService()
        
        // 初期状態：マイグレーションが必要
        #expect(service.isMigrationNeeded() == true)
        
        // マイグレーション完了フラグを設定
        UserDefaults.standard.set(true, forKey: "UnifiedDataMigration_v1_completed")
        #expect(service.isMigrationNeeded() == false)
        
        cleanupTestUserDefaults()
    }
    
    // MARK: - Basic Migration Tests
    
    @Test("基本マイグレーション機能テスト") @MainActor
    func basicMigrationFunctionality() async throws {
        cleanupTestUserDefaults()
        setupTestUserDefaults()
        
        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService()
        
        // マイグレーション実行前の状態確認
        #expect(service.isMigrationNeeded() == true)
        
        // マイグレーション実行
        try await service.performMigration(modelContext: context)
        
        // マイグレーション完了確認
        #expect(service.isMigrationNeeded() == false)
        
        // UnifiedGameProgressの作成確認
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        let unifiedProgress = try context.fetch(descriptor)
        #expect(unifiedProgress.count == 1)
        
        let progress = unifiedProgress.first!
        #expect(progress.totalStars >= 6) // LevelStars合計値またはLegacy値
        #expect(progress.currentLevel >= 1)
        
        cleanupTestUserDefaults()
    }
    
    @Test("重複マイグレーション防止テスト") @MainActor
    func duplicateMigrationPrevention() async throws {
        cleanupTestUserDefaults()
        setupTestUserDefaults()
        
        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService()
        
        // 初回マイグレーション
        try await service.performMigration(modelContext: context)
        let firstCount = try context.fetch(FetchDescriptor<UnifiedGameProgress>()).count
        
        // 2回目マイグレーション（スキップされるべき）
        try await service.performMigration(modelContext: context)
        let secondCount = try context.fetch(FetchDescriptor<UnifiedGameProgress>()).count
        
        #expect(firstCount == secondCount) // 重複作成されていない
        #expect(firstCount == 1)
        
        cleanupTestUserDefaults()
    }
    
    // MARK: - Data Integrity Tests
    
    @Test("UserDefaultsデータ整合性テスト") @MainActor
    func userDefaultsDataIntegrity() async throws {
        cleanupTestUserDefaults()
        setupTestUserDefaults()
        
        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService()
        
        try await service.performMigration(modelContext: context)
        
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        let progress = try context.fetch(descriptor).first!
        
        // キャラクター解放データ検証
        let unlockedCharacters = progress.getUnlockedCharacters()
        #expect(unlockedCharacters.count == 7)
        #expect(unlockedCharacters.contains("あ"))
        #expect(unlockedCharacters.contains("か"))
        #expect(unlockedCharacters.contains("き"))
        
        // 統計データ検証
        #expect(progress.totalTimePlayed == 120.5)
        #expect(progress.totalAccuracy == 0.85)
        #expect(progress.completedLevelsCount == 3)
        #expect(progress.currentStreak == 5)
        #expect(progress.highestStreak == 8)
        
        // 実績データ検証
        let achievements = progress.getAchievements()
        #expect(achievements.count == 2)
        #expect(achievements.contains("firstCompletion"))
        #expect(achievements.contains("perfectScore"))
        
        cleanupTestUserDefaults()
    }
    
    @Test("SwiftDataマージ整合性テスト") @MainActor  
    func swiftDataMergeIntegrity() async throws {
        cleanupTestUserDefaults()
        setupTestUserDefaults()
        
        let container = try createTestModelContainer()
        let context = container.mainContext
        
        // 既存のGameProgressを事前に作成
        let existingProgress = GameProgress()
        existingProgress.currentLevel = 4
        existingProgress.totalStars = 12
        existingProgress.unlockedCharacters = ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ"]
        
        let levelStarsDict = ["1": 3, "2": 3, "3": 2, "4": 1]
        existingProgress.levelStarsData = try JSONEncoder().encode(levelStarsDict)
        
        context.insert(existingProgress)
        try context.save()
        
        let service = DataMigrationService()
        try await service.performMigration(modelContext: context)
        
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        let unifiedProgress = try context.fetch(descriptor).first!
        
        // GameProgressデータが正しくマージされている
        #expect(unifiedProgress.currentLevel == 4) // GameProgressの値を採用
        #expect(unifiedProgress.totalStars >= 12) // より高い値を採用
        
        // 文字データのマージ確認（Union）
        let mergedCharacters = unifiedProgress.getUnlockedCharacters()
        #expect(mergedCharacters.count >= 11) // 両方のデータをマージ
        #expect(mergedCharacters.contains("さ")) // GameProgressから
        #expect(mergedCharacters.contains("か")) // UserDefaultsから
        
        cleanupTestUserDefaults()
    }
    
    // MARK: - Error Handling Tests
    
    @Test("データ破損エラーハンドリングテスト") @MainActor
    func dataCorruptionErrorHandling() async throws {
        cleanupTestUserDefaults()
        
        // 破損したUserDefaultsデータを設定
        UserDefaults.standard.set("invalid_data", forKey: "StarUnlock_UnlockedCharacters") // 配列でなく文字列
        UserDefaults.standard.set(-1, forKey: "StarUnlock_TotalTimePlayed") // 負の値
        UserDefaults.standard.set(false, forKey: "UnifiedDataMigration_v1_completed")
        
        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService()
        
        // マイグレーションは失敗せず、デフォルト値で継続されるべき
        try await service.performMigration(modelContext: context)
        
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        let progress = try context.fetch(descriptor).first!
        
        // デフォルト値が設定されている
        let characters = progress.getUnlockedCharacters()
        #expect(characters.count >= 5) // 最低限のデフォルトキャラクター
        #expect(characters.contains("あ"))
        #expect(progress.totalTimePlayed >= 0) // 負の値は修正される
        
        cleanupTestUserDefaults()
    }
    
    // MARK: - Migration Validation Tests
    
    @Test("マイグレーション検証機能テスト") @MainActor
    func migrationValidation() async throws {
        cleanupTestUserDefaults()
        setupTestUserDefaults()
        
        let container = try createTestModelContainer()
        let context = container.mainContext  
        let service = DataMigrationService()
        
        try await service.performMigration(modelContext: context)
        
        // 検証実行
        let isValid = try service.validateMigration(modelContext: context)
        #expect(isValid == true)
        
        // データが存在することの確認
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        let progress = try context.fetch(descriptor).first!
        
        #expect(progress.getUnlockedCharacters().count > 0)
        #expect(progress.totalStars >= 0)
        #expect(progress.currentLevel >= 1)
        
        cleanupTestUserDefaults()
    }
    
    @Test("マイグレーション検証失敗ケース") @MainActor
    func migrationValidationFailure() async throws {
        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService()
        
        // UnifiedGameProgressが存在しない状態で検証
        #expect(throws: MigrationError.dataNotFound) {
            try service.validateMigration(modelContext: context)
        }
        
        // 破損データを手動で作成
        let corruptedProgress = UnifiedGameProgress()
        corruptedProgress.totalStars = -1 // 無効な値
        corruptedProgress.currentLevel = 0 // 無効な値
        
        context.insert(corruptedProgress)
        try context.save()
        
        // 破損データの検証は失敗するべき
        #expect(throws: MigrationError.self) {
            try service.validateMigration(modelContext: context)
        }
    }
    
    // MARK: - Rollback and Cleanup Tests
    
    @Test("マイグレーションロールバック機能テスト")
    func migrationRollback() {
        cleanupTestUserDefaults()
        
        // マイグレーション完了状態を設定
        UserDefaults.standard.set(true, forKey: "UnifiedDataMigration_v1_completed")
        
        let service = DataMigrationService()
        #expect(service.isMigrationNeeded() == false)
        
        // ロールバック実行
        service.rollbackMigration()
        
        // マイグレーションが再度必要な状態になる
        #expect(service.isMigrationNeeded() == true)
        
        cleanupTestUserDefaults()
    }
    
    @Test("旧データクリーンアップテスト") @MainActor
    func oldDataCleanup() async throws {
        cleanupTestUserDefaults()
        setupTestUserDefaults()
        
        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService()
        
        // マイグレーション実行
        try await service.performMigration(modelContext: context)
        
        // 検証実行
        let isValid = try service.validateMigration(modelContext: context)
        #expect(isValid == true)
        
        // クリーンアップ実行
        try service.cleanupOldData(modelContext: context)
        
        // UserDefaultsの旧データが削除されている
        #expect(UserDefaults.standard.array(forKey: "StarUnlock_UnlockedCharacters") == nil)
        #expect(UserDefaults.standard.object(forKey: "StarUnlock_TotalTimePlayed") == nil)
        #expect(UserDefaults.standard.object(forKey: "StarUnlock_LevelStars") == nil)
        
        // マイグレーション完了フラグは残存
        #expect(UserDefaults.standard.bool(forKey: "UnifiedDataMigration_v1_completed") == true)
        
        cleanupTestUserDefaults()
    }
    
    // MARK: - Performance Tests
    
    @Test("大量データマイグレーション性能テスト") @MainActor
    func largeDateMigrationPerformance() async throws {
        cleanupTestUserDefaults()
        
        // 大量のテストデータを設定
        let largeCharacterSet = Array(1...100).map { "char_\($0)" }
        let largeLevelStars = Dictionary(uniqueKeysWithValues: (1...50).map { ("\($0)", Int.random(in: 0...3)) })
        let largeAchievements = Array(1...20).map { "achievement_\($0)" }
        
        UserDefaults.standard.set(largeCharacterSet, forKey: "StarUnlock_UnlockedCharacters")
        UserDefaults.standard.set(largeLevelStars, forKey: "StarUnlock_LevelStars")
        UserDefaults.standard.set(largeAchievements, forKey: "StarUnlock_Achievements")
        UserDefaults.standard.set(false, forKey: "UnifiedDataMigration_v1_completed")
        
        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService()
        
        // 性能測定
        let startTime = Date()
        try await service.performMigration(modelContext: context)
        let migrationTime = Date().timeIntervalSince(startTime)
        
        // 性能要件：5秒以内に完了（大量データでも）
        #expect(migrationTime < 5.0)
        
        // データ整合性確認
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        let progress = try context.fetch(descriptor).first!
        
        #expect(progress.getUnlockedCharacters().count == largeCharacterSet.count)
        #expect(progress.getAchievements().count == largeAchievements.count)
        
        cleanupTestUserDefaults()
    }
    
    // MARK: - Integration Tests
    
    @Test("マイグレーション後のデータ整合性テスト") @MainActor
    func migrationDataIntegrityTest() async throws {
        cleanupTestUserDefaults()
        setupTestUserDefaults()
        
        let container = try createTestModelContainer()
        let context = container.mainContext
        let migrationService = DataMigrationService()
        
        // マイグレーション実行
        try await migrationService.performMigration(modelContext: context)
        
        // マイグレートされたデータの確認
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        let progress = try context.fetch(descriptor).first
        
        #expect(progress != nil)
        #expect(progress!.totalStars >= 6)
        #expect(progress!.getUnlockedCharacters().count == 7)
        #expect(progress!.currentStreak == 5)
        #expect(progress!.highestStreak == 8)
        
        cleanupTestUserDefaults()
    }
}