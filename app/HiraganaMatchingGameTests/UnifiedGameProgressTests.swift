import Foundation
@testable import HiraganaMatchingGame
import SwiftData
import Testing

@Suite("UnifiedGameProgressモデルテスト")
struct UnifiedGameProgressTests {
    
    // MARK: - Test Helpers
    
    @MainActor
    private func createTestModelContainer() throws -> ModelContainer {
        let schema = Schema([
            UnifiedGameProgress.self,
            AchievementRecord.self,
            LevelStats.self,
        ])
        return try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
    }
    
    // MARK: - Initialization Tests
    
    @Test("UnifiedGameProgress初期化テスト")
    func unifiedGameProgressInitialization() {
        let progress = UnifiedGameProgress()
        
        #expect(progress.currentLevel == 1)
        #expect(progress.totalStars == 0)
        #expect(progress.lastPlayedDate != nil)
        #expect(progress.levelStarsData.isEmpty)
        #expect(progress.unlockedCharactersData.isEmpty)
        #expect(progress.totalTimePlayed == 0.0)
        #expect(progress.totalAccuracy == 0.0)
        #expect(progress.completedLevelsCount == 0)
        #expect(progress.currentStreak == 0)
        #expect(progress.highestStreak == 0)
        #expect(progress.achievements.isEmpty)
        #expect(progress.levelStatistics.isEmpty)
    }
    
    @Test("カスタム初期化テスト")
    func customInitialization() {
        let progress = UnifiedGameProgress(currentLevel: 5, totalStars: 15)
        
        #expect(progress.currentLevel == 5)
        #expect(progress.totalStars == 15)
        #expect(progress.lastPlayedDate != nil)
    }
    
    // MARK: - Character Unlock Management Tests
    
    @Test("キャラクター解放データエンコード・デコードテスト")
    func characterUnlockDataManagement() {
        let progress = UnifiedGameProgress()
        
        // 初期状態：デフォルトキャラクター
        let defaultCharacters = progress.getUnlockedCharacters()
        #expect(defaultCharacters.count == 5)
        #expect(defaultCharacters.contains("あ"))
        #expect(defaultCharacters.contains("お"))
        
        // カスタムキャラクターセット設定
        let customCharacters: Set<String> = ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ"]
        progress.setUnlockedCharacters(customCharacters)
        
        // 正しくエンコード・デコードされる
        let retrievedCharacters = progress.getUnlockedCharacters()
        #expect(retrievedCharacters == customCharacters)
        #expect(retrievedCharacters.count == 10)
        #expect(retrievedCharacters.contains("か"))
        #expect(retrievedCharacters.contains("こ"))
    }
    
    @Test("空キャラクターデータのデフォルト処理テスト")
    func emptyCharacterDataDefaultHandling() {
        let progress = UnifiedGameProgress()
        
        // 空のデータの場合、デフォルト値を返す
        progress.unlockedCharactersData = Data()
        let characters = progress.getUnlockedCharacters()
        
        #expect(characters.count == 5)
        #expect(characters.contains("あ"))
        #expect(characters.contains("い"))
        #expect(characters.contains("う"))
        #expect(characters.contains("え"))
        #expect(characters.contains("お"))
    }
    
    @Test("破損キャラクターデータのエラーハンドリング")
    func corruptedCharacterDataErrorHandling() {
        let progress = UnifiedGameProgress()
        
        // 破損したJSONデータを設定
        progress.unlockedCharactersData = "invalid_json".data(using: .utf8)!
        
        // エラー時はデフォルト値を返す
        let characters = progress.getUnlockedCharacters()
        #expect(characters.count == 5)
        #expect(characters == Set(["あ", "い", "う", "え", "お"]))
    }
    
    // MARK: - Level Stars Management Tests
    
    @Test("レベルスターデータエンコード・デコードテスト")
    func levelStarsDataManagement() {
        let progress = UnifiedGameProgress()
        
        // 初期状態：デフォルト値
        let defaultStars = progress.getLevelStars()
        #expect(defaultStars.count == 1)
        #expect(defaultStars[1] == 0)
        
        // カスタムレベルスター設定
        let customLevelStars: [Int: Int] = [1: 3, 2: 2, 3: 1, 4: 3, 5: 0]
        progress.setLevelStars(customLevelStars)
        
        // 正しくエンコード・デコードされる
        let retrievedStars = progress.getLevelStars()
        #expect(retrievedStars == customLevelStars)
        #expect(retrievedStars[1] == 3)
        #expect(retrievedStars[4] == 3)
        #expect(retrievedStars[5] == 0)
    }
    
    @Test("空レベルスターデータのデフォルト処理テスト")
    func emptyLevelStarsDefaultHandling() {
        let progress = UnifiedGameProgress()
        
        // 空のデータの場合、デフォルト値を返す
        progress.levelStarsData = Data()
        let stars = progress.getLevelStars()
        
        #expect(stars.count == 1)
        #expect(stars[1] == 0)
    }
    
    @Test("破損レベルスターデータのエラーハンドリング")
    func corruptedLevelStarsErrorHandling() {
        let progress = UnifiedGameProgress()
        
        // 破損したJSONデータを設定
        progress.levelStarsData = "invalid_json".data(using: .utf8)!
        
        // エラー時はデフォルト値を返す
        let stars = progress.getLevelStars()
        #expect(stars.count == 1)
        #expect(stars[1] == 0)
    }
    
    // MARK: - Basic Operations Tests
    
    @Test("基本操作テスト - スター追加・レベル進行")
    func basicOperations() {
        let progress = UnifiedGameProgress()
        let initialStars = progress.totalStars
        let initialLevel = progress.currentLevel
        let initialDate = progress.lastPlayedDate
        
        // スター追加
        progress.addStars(5)
        #expect(progress.totalStars == initialStars + 5)
        
        // レベル進行
        progress.advanceToNextLevel()
        #expect(progress.currentLevel == initialLevel + 1)
        
        // 最終プレイ日更新
        Thread.sleep(forTimeInterval: 0.001) // 時間差を作る
        progress.updateLastPlayedDate()
        #expect(progress.lastPlayedDate > initialDate)
    }
    
    // MARK: - Achievement Management Tests
    
    @Test("実績管理テスト")
    func achievementManagement() {
        let progress = UnifiedGameProgress()
        
        // 初期状態：実績なし
        #expect(progress.getAchievements().isEmpty)
        #expect(progress.hasAchievement("firstCompletion") == false)
        
        // 実績追加
        progress.addAchievement("firstCompletion")
        #expect(progress.hasAchievement("firstCompletion") == true)
        #expect(progress.getAchievements().contains("firstCompletion"))
        #expect(progress.achievements.count == 1)
        
        // 複数実績追加
        progress.addAchievement("perfectScore")
        progress.addAchievement("speedRun")
        #expect(progress.achievements.count == 3)
        #expect(progress.getAchievements().count == 3)
        #expect(progress.hasAchievement("perfectScore") == true)
        #expect(progress.hasAchievement("speedRun") == true)
        
        // 重複実績の追加防止
        progress.addAchievement("firstCompletion") // 既存
        #expect(progress.achievements.count == 3) // 増えない
        
        // 存在しない実績の確認
        #expect(progress.hasAchievement("nonexistentAchievement") == false)
    }
    
    @Test("実績データの永続化テスト") @MainActor
    func achievementPersistence() throws {
        let container = try createTestModelContainer()
        let context = container.mainContext
        
        let progress = UnifiedGameProgress()
        progress.addAchievement("testAchievement1")
        progress.addAchievement("testAchievement2")
        
        context.insert(progress)
        try context.save()
        
        // 再読み込み確認
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        let savedProgress = try context.fetch(descriptor).first!
        
        #expect(savedProgress.achievements.count == 2)
        #expect(savedProgress.hasAchievement("testAchievement1") == true)
        #expect(savedProgress.hasAchievement("testAchievement2") == true)
        #expect(savedProgress.getAchievements().contains("testAchievement1"))
        #expect(savedProgress.getAchievements().contains("testAchievement2"))
    }
    
    // MARK: - Level Statistics Management Tests
    
    @Test("レベル統計管理テスト")
    func levelStatisticsManagement() {
        let progress = UnifiedGameProgress()
        
        // 初期状態：統計なし
        #expect(progress.getLevelStatistic(for: 1) == nil)
        #expect(progress.levelStatistics.isEmpty)
        
        // 新規統計追加
        progress.updateLevelStatistic(
            level: 1,
            bestStars: 3,
            bestAccuracy: 1.0,
            bestTime: 30.0,
            totalAttempts: 1,
            averageStars: 3.0
        )
        
        let stat1 = progress.getLevelStatistic(for: 1)
        #expect(stat1 != nil)
        #expect(stat1!.level == 1)
        #expect(stat1!.bestStars == 3)
        #expect(stat1!.bestAccuracy == 1.0)
        #expect(stat1!.bestTime == 30.0)
        #expect(stat1!.totalAttempts == 1)
        #expect(stat1!.averageStars == 3.0)
        #expect(stat1!.lastPlayed != nil)
        
        // 既存統計の更新（改善）
        progress.updateLevelStatistic(
            level: 1,
            bestStars: 2, // 悪化（更新されない）
            bestAccuracy: 0.9, // 悪化（更新されない）
            bestTime: 25.0, // 改善（更新される）
            totalAttempts: 2,
            averageStars: 2.5
        )
        
        let updatedStat = progress.getLevelStatistic(for: 1)!
        #expect(updatedStat.bestStars == 3) // 保持
        #expect(updatedStat.bestAccuracy == 1.0) // 保持
        #expect(updatedStat.bestTime == 25.0) // 更新
        #expect(updatedStat.totalAttempts == 2) // 更新
        #expect(updatedStat.averageStars == 2.5) // 更新
        
        // 複数レベル統計
        progress.updateLevelStatistic(
            level: 2,
            bestStars: 2,
            bestAccuracy: 0.8,
            bestTime: 45.0,
            totalAttempts: 1,
            averageStars: 2.0
        )
        
        #expect(progress.levelStatistics.count == 2)
        #expect(progress.getLevelStatistic(for: 1) != nil)
        #expect(progress.getLevelStatistic(for: 2) != nil)
        #expect(progress.getLevelStatistic(for: 3) == nil)
    }
    
    @Test("レベル統計の永続化テスト") @MainActor
    func levelStatisticsPersistence() throws {
        let container = try createTestModelContainer()
        let context = container.mainContext
        
        let progress = UnifiedGameProgress()
        progress.updateLevelStatistic(
            level: 1,
            bestStars: 3,
            bestAccuracy: 1.0,
            bestTime: 30.0,
            totalAttempts: 1,
            averageStars: 3.0
        )
        progress.updateLevelStatistic(
            level: 2,
            bestStars: 2,
            bestAccuracy: 0.8,
            bestTime: 45.0,
            totalAttempts: 2,
            averageStars: 1.5
        )
        
        context.insert(progress)
        try context.save()
        
        // 再読み込み確認
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        let savedProgress = try context.fetch(descriptor).first!
        
        #expect(savedProgress.levelStatistics.count == 2)
        
        let stat1 = savedProgress.getLevelStatistic(for: 1)!
        #expect(stat1.bestStars == 3)
        #expect(stat1.bestAccuracy == 1.0)
        #expect(stat1.bestTime == 30.0)
        
        let stat2 = savedProgress.getLevelStatistic(for: 2)!
        #expect(stat2.bestStars == 2)
        #expect(stat2.bestAccuracy == 0.8)
        #expect(stat2.totalAttempts == 2)
        #expect(stat2.averageStars == 1.5)
    }
    
    // MARK: - Complex Data Management Tests
    
    @Test("複雑データ統合テスト") @MainActor
    func complexDataIntegration() throws {
        let container = try createTestModelContainer()
        let context = container.mainContext
        
        let progress = UnifiedGameProgress(currentLevel: 3, totalStars: 8)
        
        // キャラクター解放データ設定
        let characters: Set<String> = ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ"]
        progress.setUnlockedCharacters(characters)
        
        // レベルスターデータ設定
        let levelStars: [Int: Int] = [1: 3, 2: 3, 3: 2]
        progress.setLevelStars(levelStars)
        
        // プレイ統計設定
        progress.totalTimePlayed = 150.5
        progress.totalAccuracy = 0.92
        progress.completedLevelsCount = 3
        progress.currentStreak = 2
        progress.highestStreak = 5
        
        // 実績追加
        progress.addAchievement("firstCompletion")
        progress.addAchievement("perfectScore")
        progress.addAchievement("speedRun")
        
        // レベル統計追加
        progress.updateLevelStatistic(level: 1, bestStars: 3, bestAccuracy: 1.0, bestTime: 25.0, totalAttempts: 1, averageStars: 3.0)
        progress.updateLevelStatistic(level: 2, bestStars: 3, bestAccuracy: 1.0, bestTime: 28.0, totalAttempts: 1, averageStars: 3.0)
        progress.updateLevelStatistic(level: 3, bestStars: 2, bestAccuracy: 0.8, bestTime: 45.0, totalAttempts: 1, averageStars: 2.0)
        
        context.insert(progress)
        try context.save()
        
        // 再読み込みとデータ検証
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        let savedProgress = try context.fetch(descriptor).first!
        
        // 基本データ検証
        #expect(savedProgress.currentLevel == 3)
        #expect(savedProgress.totalStars == 8)
        #expect(savedProgress.totalTimePlayed == 150.5)
        #expect(savedProgress.totalAccuracy == 0.92)
        #expect(savedProgress.completedLevelsCount == 3)
        #expect(savedProgress.currentStreak == 2)
        #expect(savedProgress.highestStreak == 5)
        
        // エンコードデータ検証
        let savedCharacters = savedProgress.getUnlockedCharacters()
        #expect(savedCharacters == characters)
        #expect(savedCharacters.count == 15)
        
        let savedLevelStars = savedProgress.getLevelStars()
        #expect(savedLevelStars == levelStars)
        #expect(savedLevelStars[1] == 3)
        #expect(savedLevelStars[3] == 2)
        
        // リレーションデータ検証
        #expect(savedProgress.achievements.count == 3)
        #expect(savedProgress.hasAchievement("perfectScore") == true)
        
        #expect(savedProgress.levelStatistics.count == 3)
        let stat1 = savedProgress.getLevelStatistic(for: 1)!
        #expect(stat1.bestStars == 3)
        #expect(stat1.bestTime == 25.0)
        
        let stat3 = savedProgress.getLevelStatistic(for: 3)!
        #expect(stat3.bestStars == 2)
        #expect(stat3.bestAccuracy == 0.8)
    }
    
    // MARK: - Performance Tests
    
    @Test("大量データ性能テスト") @MainActor
    func largeDataPerformance() throws {
        let container = try createTestModelContainer()
        let context = container.mainContext
        
        let progress = UnifiedGameProgress()
        
        // 大量キャラクターデータ
        let largeCharacterSet: Set<String> = Set((1...1000).map { "char_\($0)" })
        let startCharacterTime = Date()
        progress.setUnlockedCharacters(largeCharacterSet)
        let characterEncodeTime = Date().timeIntervalSince(startCharacterTime)
        
        // 大量レベルスターデータ
        let largeLevelStars = Dictionary(uniqueKeysWithValues: (1...100).map { ($0, Int.random(in: 0...3)) })
        let startLevelTime = Date()
        progress.setLevelStars(largeLevelStars)
        let levelEncodeTime = Date().timeIntervalSince(startLevelTime)
        
        // 大量実績データ
        let achievementStartTime = Date()
        for i in 1...50 {
            progress.addAchievement("achievement_\(i)")
        }
        let achievementTime = Date().timeIntervalSince(achievementStartTime)
        
        // 大量レベル統計データ
        let statisticsStartTime = Date()
        for i in 1...50 {
            progress.updateLevelStatistic(
                level: i,
                bestStars: Int.random(in: 1...3),
                bestAccuracy: Double.random(in: 0.5...1.0),
                bestTime: Double.random(in: 20...60),
                totalAttempts: Int.random(in: 1...10),
                averageStars: Double.random(in: 1.0...3.0)
            )
        }
        let statisticsTime = Date().timeIntervalSince(statisticsStartTime)
        
        // 永続化性能測定
        let persistenceStartTime = Date()
        context.insert(progress)
        try context.save()
        let persistenceTime = Date().timeIntervalSince(persistenceStartTime)
        
        // 読み込み性能測定
        let loadStartTime = Date()
        let descriptor = FetchDescriptor<UnifiedGameProgress>()
        let savedProgress = try context.fetch(descriptor).first!
        let loadTime = Date().timeIntervalSince(loadStartTime)
        
        // デコード性能測定
        let decodeStartTime = Date()
        let decodedCharacters = savedProgress.getUnlockedCharacters()
        let decodedLevelStars = savedProgress.getLevelStars()
        let decodeTime = Date().timeIntervalSince(decodeStartTime)
        
        // 性能要件確認（各操作1秒以内）
        #expect(characterEncodeTime < 1.0)
        #expect(levelEncodeTime < 1.0)
        #expect(achievementTime < 1.0)
        #expect(statisticsTime < 1.0)
        #expect(persistenceTime < 1.0)
        #expect(loadTime < 1.0)
        #expect(decodeTime < 1.0)
        
        // データ整合性確認
        #expect(decodedCharacters.count == 1000)
        #expect(decodedLevelStars.count == 100)
        #expect(savedProgress.achievements.count == 50)
        #expect(savedProgress.levelStatistics.count == 50)
    }
}
