import Foundation
@testable import HiraganaMatchingGame
import SwiftData
import Testing

/// DataMigrationService のテスト。
///
/// Swift Testing はテストをプロセス内で並列実行するため、`UserDefaults.standard` を直接使うと
/// テスト同士がマイグレーション完了フラグや旧データを奪い合い、結果が実行ごとに変わっていた
/// （#16）。各テストは `IsolatedDefaults` で専用の UserDefaults スイートを作り、
/// それを DataMigrationService に注入することで完全に独立させている。
@Suite("データマイグレーションシステムテスト")
struct DataMigrationServiceTests {

    // MARK: - Test Helpers

    /// テスト 1 本ごとに使い捨てる UserDefaults。テスト末尾で `tearDown()` を呼び永続化ドメインごと削除する。
    private final class IsolatedDefaults {
        let suiteName: String
        let defaults: UserDefaults

        init() throws {
            suiteName = "DataMigrationServiceTests.\(UUID().uuidString)"
            defaults = try #require(UserDefaults(suiteName: suiteName))
            defaults.removePersistentDomain(forName: suiteName)
        }

        /// 明示的に呼ぶ（deinit だと ARC の早期解放でテスト途中にドメインが消えうる）
        func tearDown() {
            defaults.removePersistentDomain(forName: suiteName)
        }
    }

    @MainActor
    private func createTestModelContainer() throws -> ModelContainer {
        let schema = Schema([
            GameProgress.self,
            GameLevel.self,
            UserSettings.self,
            Character.self,
            UnifiedGameProgress.self,
            AchievementRecord.self,
            LevelStats.self
        ])
        return try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
    }

    private func setupLegacyData(in defaults: UserDefaults) {
        // StarUnlockService legacy data
        defaults.set(["あ", "い", "う", "え", "お", "か", "き"], forKey: "StarUnlock_UnlockedCharacters")
        defaults.set(120.5, forKey: "StarUnlock_TotalTimePlayed")
        defaults.set(0.85, forKey: "StarUnlock_TotalAccuracy")
        defaults.set(3, forKey: "StarUnlock_CompletedLevelsCount")
        defaults.set(5, forKey: "StarUnlock_CurrentStreak")
        defaults.set(8, forKey: "StarUnlock_HighestStreak")
        defaults.set(["firstCompletion", "perfectScore"], forKey: "StarUnlock_Achievements")
        defaults.set(["1": 3, "2": 2, "3": 1], forKey: "StarUnlock_LevelStars")

        // Legacy LevelProgression data
        defaults.set(6, forKey: "LevelProgression_TotalStars")

        // Migration flag should be false for testing
        defaults.set(false, forKey: "UnifiedDataMigration_v1_completed")
    }

    @MainActor
    private func fetchUnifiedProgress(from context: ModelContext) throws -> UnifiedGameProgress {
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        return try #require(context.fetch(descriptor).first, "UnifiedGameProgress が作成されていない")
    }

    // MARK: - Migration Need Detection Tests

    @Test("マイグレーション要否判定テスト")
    func migrationNeedDetection() throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }
        let service = DataMigrationService(userDefaults: isolated.defaults)

        // 初期状態：マイグレーションが必要
        #expect(service.isMigrationNeeded() == true)

        // マイグレーション完了フラグを設定
        isolated.defaults.set(true, forKey: "UnifiedDataMigration_v1_completed")
        #expect(service.isMigrationNeeded() == false)
    }

    // MARK: - Basic Migration Tests

    @Test("基本マイグレーション機能テスト") @MainActor
    func basicMigrationFunctionality() async throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }
        setupLegacyData(in: isolated.defaults)

        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService(userDefaults: isolated.defaults)

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

        let progress = try #require(unifiedProgress.first)
        #expect(progress.totalStars >= 6) // LevelStars合計値またはLegacy値
        #expect(progress.currentLevel >= 1)
    }

    @Test("重複マイグレーション防止テスト") @MainActor
    func duplicateMigrationPrevention() async throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }
        setupLegacyData(in: isolated.defaults)

        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService(userDefaults: isolated.defaults)

        // 初回マイグレーション
        try await service.performMigration(modelContext: context)
        let firstCount = try context.fetch(FetchDescriptor<UnifiedGameProgress>()).count

        // 2回目マイグレーション（スキップされるべき）
        try await service.performMigration(modelContext: context)
        let secondCount = try context.fetch(FetchDescriptor<UnifiedGameProgress>()).count

        #expect(firstCount == secondCount) // 重複作成されていない
        #expect(firstCount == 1)
    }

    // MARK: - Data Integrity Tests

    @Test("UserDefaultsデータ整合性テスト") @MainActor
    func userDefaultsDataIntegrity() async throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }
        setupLegacyData(in: isolated.defaults)

        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService(userDefaults: isolated.defaults)

        try await service.performMigration(modelContext: context)

        let progress = try fetchUnifiedProgress(from: context)

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
    }

    @Test("SwiftDataマージ整合性テスト") @MainActor
    func swiftDataMergeIntegrity() async throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }
        setupLegacyData(in: isolated.defaults)

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

        let service = DataMigrationService(userDefaults: isolated.defaults)
        try await service.performMigration(modelContext: context)

        let unifiedProgress = try fetchUnifiedProgress(from: context)

        // GameProgressデータが正しくマージされている
        #expect(unifiedProgress.currentLevel == 4) // GameProgressの値を採用
        #expect(unifiedProgress.totalStars >= 12) // より高い値を採用

        // 文字データのマージ確認（Union）
        let mergedCharacters = unifiedProgress.getUnlockedCharacters()
        #expect(mergedCharacters.count >= 11) // 両方のデータをマージ
        #expect(mergedCharacters.contains("さ")) // GameProgressから
        #expect(mergedCharacters.contains("か")) // UserDefaultsから
    }

    @Test("旧 LevelProgression の合計スターは SwiftData 側より大きい場合のみ採用される") @MainActor
    func legacyTotalStarsAreNotDowngraded() async throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }
        setupLegacyData(in: isolated.defaults) // LevelProgression_TotalStars = 6

        let container = try createTestModelContainer()
        let context = container.mainContext

        let existingProgress = GameProgress()
        existingProgress.totalStars = 20 // SwiftData 側の方が多い
        context.insert(existingProgress)
        try context.save()

        let service = DataMigrationService(userDefaults: isolated.defaults)
        try await service.performMigration(modelContext: context)

        let unifiedProgress = try fetchUnifiedProgress(from: context)
        #expect(unifiedProgress.totalStars == 20)
    }

    // MARK: - Error Handling Tests

    @Test("データ破損エラーハンドリングテスト") @MainActor
    func dataCorruptionErrorHandling() async throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }

        // 破損したUserDefaultsデータを設定
        isolated.defaults.set("invalid_data", forKey: "StarUnlock_UnlockedCharacters") // 配列でなく文字列
        isolated.defaults.set(-1, forKey: "StarUnlock_TotalTimePlayed") // 負の値
        isolated.defaults.set(false, forKey: "UnifiedDataMigration_v1_completed")

        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService(userDefaults: isolated.defaults)

        // マイグレーションは失敗せず、デフォルト値で継続されるべき
        try await service.performMigration(modelContext: context)

        let progress = try fetchUnifiedProgress(from: context)

        // デフォルト値が設定されている
        let characters = progress.getUnlockedCharacters()
        #expect(characters.count >= 5) // 最低限のデフォルトキャラクター
        #expect(characters.contains("あ"))
        #expect(progress.totalTimePlayed >= 0) // 負の値は修正される
    }

    // MARK: - Migration Validation Tests

    @Test("マイグレーション検証機能テスト") @MainActor
    func migrationValidation() async throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }
        setupLegacyData(in: isolated.defaults)

        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService(userDefaults: isolated.defaults)

        try await service.performMigration(modelContext: context)

        // 検証実行
        let isValid = try service.validateMigration(modelContext: context)
        #expect(isValid == true)

        // データが存在することの確認
        let progress = try fetchUnifiedProgress(from: context)

        #expect(!progress.getUnlockedCharacters().isEmpty)
        #expect(progress.totalStars >= 0)
        #expect(progress.currentLevel >= 1)
    }

    @Test("マイグレーション検証失敗ケース") @MainActor
    func migrationValidationFailure() async throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }
        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService(userDefaults: isolated.defaults)

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
    func migrationRollback() throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }

        // マイグレーション完了状態を設定
        isolated.defaults.set(true, forKey: "UnifiedDataMigration_v1_completed")

        let service = DataMigrationService(userDefaults: isolated.defaults)
        #expect(service.isMigrationNeeded() == false)

        // ロールバック実行
        service.rollbackMigration()

        // マイグレーションが再度必要な状態になる
        #expect(service.isMigrationNeeded() == true)
    }

    @Test("旧データクリーンアップテスト") @MainActor
    func oldDataCleanup() async throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }
        setupLegacyData(in: isolated.defaults)

        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService(userDefaults: isolated.defaults)

        // マイグレーション実行
        try await service.performMigration(modelContext: context)

        // 検証実行
        let isValid = try service.validateMigration(modelContext: context)
        #expect(isValid == true)

        // クリーンアップ実行（旧キーは #18 のため削除しない。削除しないことの検証は
        // cleanupKeepsLegacyKeysConsumedByRuntimeServices を参照）
        try service.cleanupOldData(modelContext: context)

        // クリーンアップは何度呼んでも安全
        try service.cleanupOldData(modelContext: context)

        // マイグレーション完了フラグは残存
        #expect(isolated.defaults.bool(forKey: "UnifiedDataMigration_v1_completed") == true)
    }


    @Test("クリーンアップ後も実行時サービスが遅延移行に使う旧キーは残る (#18)") @MainActor
    func cleanupKeepsLegacyKeysConsumedByRuntimeServices() async throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }
        setupLegacyData(in: isolated.defaults)

        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService(userDefaults: isolated.defaults)

        // ContentView.performDataMigrationIfNeeded() と同じ順序で実行
        try await service.performMigration(modelContext: context)
        #expect(try service.validateMigration(modelContext: context))
        try service.cleanupOldData(modelContext: context)

        // AchievementService / LevelStatisticsService / StatisticsService / CharacterUnlockService は
        // 初回生成時にこれらの旧キーから遅延移行する。起動直後に消すと実績・統計が消失する（#18）
        #expect(isolated.defaults.array(forKey: "StarUnlock_Achievements") != nil)
        #expect(isolated.defaults.dictionary(forKey: "StarUnlock_LevelStars") != nil)
        #expect(isolated.defaults.object(forKey: "StarUnlock_TotalTimePlayed") != nil)
        #expect(isolated.defaults.object(forKey: "StarUnlock_CurrentStreak") != nil)
        #expect(isolated.defaults.object(forKey: "StarUnlock_HighestStreak") != nil)
        #expect(isolated.defaults.object(forKey: "LevelProgression_TotalStars") != nil)

        // マイグレーション完了フラグは残る
        #expect(isolated.defaults.bool(forKey: "UnifiedDataMigration_v1_completed") == true)
    }

    // MARK: - Performance Tests

    @Test("大量データマイグレーション性能テスト") @MainActor
    func largeDateMigrationPerformance() async throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }

        // 大量のテストデータを設定
        let largeCharacterSet = Array(1 ... 100).map { "char_\($0)" }
        let largeLevelStars = Dictionary(uniqueKeysWithValues: (1 ... 50).map { ("\($0)", Int.random(in: 0 ... 3)) })
        let largeAchievements = Array(1 ... 20).map { "achievement_\($0)" }

        isolated.defaults.set(largeCharacterSet, forKey: "StarUnlock_UnlockedCharacters")
        isolated.defaults.set(largeLevelStars, forKey: "StarUnlock_LevelStars")
        isolated.defaults.set(largeAchievements, forKey: "StarUnlock_Achievements")
        isolated.defaults.set(false, forKey: "UnifiedDataMigration_v1_completed")

        let container = try createTestModelContainer()
        let context = container.mainContext
        let service = DataMigrationService(userDefaults: isolated.defaults)

        // 性能測定
        let startTime = Date()
        try await service.performMigration(modelContext: context)
        let migrationTime = Date().timeIntervalSince(startTime)

        // 性能要件：5秒以内に完了（大量データでも）
        #expect(migrationTime < 5.0)

        // データ整合性確認
        let progress = try fetchUnifiedProgress(from: context)

        #expect(progress.getUnlockedCharacters().count == largeCharacterSet.count)
        #expect(progress.getAchievements().count == largeAchievements.count)
    }

    // MARK: - Integration Tests

    @Test("マイグレーション後のデータ整合性テスト") @MainActor
    func migrationDataIntegrityTest() async throws {
        let isolated = try IsolatedDefaults()
        defer { isolated.tearDown() }
        setupLegacyData(in: isolated.defaults)

        let container = try createTestModelContainer()
        let context = container.mainContext
        let migrationService = DataMigrationService(userDefaults: isolated.defaults)

        // マイグレーション実行
        try await migrationService.performMigration(modelContext: context)

        // マイグレートされたデータの確認
        let progress = try fetchUnifiedProgress(from: context)

        #expect(progress.totalStars >= 6)
        #expect(progress.getUnlockedCharacters().count == 7)
        #expect(progress.currentStreak == 5)
        #expect(progress.highestStreak == 8)
    }
}
