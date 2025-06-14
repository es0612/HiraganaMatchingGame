import Testing
import SwiftData
@testable import HiraganaMatchingGame

@Suite("レベル進行サービステスト")
struct LevelProgressionServiceTests {
    
    @Test("初期レベル確認")
    func initialLevel() {
        let service = LevelProgressionService(forTesting: true)
        
        #expect(service.getCurrentLevel() == 1)
        #expect(service.getMaxUnlockedLevel() == 1)
        #expect(service.getTotalStars() == 0)
    }
    
    @Test("レベル解放条件チェック")
    func levelUnlockRequirements() {
        let service = LevelProgressionService(forTesting: true)
        
        // レベル1は常に解放済み
        #expect(service.isLevelUnlocked(1) == true)
        
        // レベル2は前のレベル（1）をクリアする必要がある
        #expect(service.isLevelUnlocked(2) == false)
        service.completeLevel(1, earnedStars: 2)
        #expect(service.isLevelUnlocked(2) == true)
        
        // レベル3は前のレベル（2）をクリアする必要がある
        #expect(service.isLevelUnlocked(3) == false)
        service.completeLevel(2, earnedStars: 2)
        #expect(service.isLevelUnlocked(3) == true)
        
        // レベル5は前のレベル（4）まで順番にクリアする必要がある
        #expect(service.isLevelUnlocked(5) == false)
        service.completeLevel(3, earnedStars: 2)
        service.completeLevel(4, earnedStars: 2)
        #expect(service.isLevelUnlocked(5) == true)
    }
    
    @Test("レベル完了処理")
    func levelCompletion() {
        let service = LevelProgressionService(forTesting: true)
        
        // レベル1完了（3スター）
        service.completeLevel(1, earnedStars: 3)
        
        #expect(service.getTotalStars() == 3)
        #expect(service.getStarsForLevel(1) == 3)
        #expect(service.isLevelUnlocked(2) == true)
        // 順次解放なので、レベル2をクリアするまでレベル3は解放されない
        #expect(service.isLevelUnlocked(3) == false)
        
        // レベル2完了（1スター）
        service.completeLevel(2, earnedStars: 1)
        
        #expect(service.getTotalStars() == 4)
        #expect(service.getStarsForLevel(2) == 1)
        #expect(service.isLevelUnlocked(3) == true)
    }
    
    @Test("スター更新（より良いスコア）")
    func starImprovement() {
        let service = LevelProgressionService(forTesting: true)
        
        // 初回クリア（1スター）
        service.completeLevel(1, earnedStars: 1)
        #expect(service.getStarsForLevel(1) == 1)
        #expect(service.getTotalStars() == 1)
        
        // より良いスコアでクリア（3スター）
        service.completeLevel(1, earnedStars: 3)
        #expect(service.getStarsForLevel(1) == 3)
        #expect(service.getTotalStars() == 3)
        
        // より悪いスコアでクリア（2スター） - 更新されない
        service.completeLevel(1, earnedStars: 2)
        #expect(service.getStarsForLevel(1) == 3)
        #expect(service.getTotalStars() == 3)
    }
    
    @Test("レベル進行統計")
    func levelProgressionStats() {
        let service = LevelProgressionService(forTesting: true)
        
        // 複数レベルクリア
        service.completeLevel(1, earnedStars: 3)
        service.completeLevel(2, earnedStars: 2)
        service.completeLevel(3, earnedStars: 1)
        
        let stats = service.getProgressionStats()
        
        #expect(stats.completedLevels == 3)
        #expect(stats.totalStars == 6)
        #expect(stats.maxUnlockedLevel == 4) // レベル3クリアでレベル4が解放
        #expect(stats.completionPercentage > 0.0)
        
        // 全レベルクリア進捗
        let totalLevels = service.getTotalLevels()
        let expectedCompletion = Double(3) / Double(totalLevels)
        #expect(abs(stats.completionPercentage - expectedCompletion) < 0.01)
    }
    
    @Test("次のレベル推奨")
    func nextLevelRecommendation() {
        let service = LevelProgressionService(forTesting: true)
        
        // 初期状態
        #expect(service.getRecommendedNextLevel() == 1)
        
        // レベル1クリア
        service.completeLevel(1, earnedStars: 2)
        #expect(service.getRecommendedNextLevel() == 2)
        
        // レベル2クリア
        service.completeLevel(2, earnedStars: 1)
        #expect(service.getRecommendedNextLevel() == 3)
        
        // 途中レベルもクリア
        service.completeLevel(3, earnedStars: 3)
        #expect(service.getRecommendedNextLevel() == 4) // 順序通りを推奨
    }
    
    @Test("レベル設定取得")
    func levelConfiguration() {
        let service = LevelProgressionService(forTesting: true)
        
        let level1Config = service.getLevelConfiguration(1)
        #expect(level1Config.requiredStars == 0)
        #expect(level1Config.characters.count == 5) // あ行
        #expect(level1Config.questionsCount == 5)
        #expect(level1Config.title == "あ行をおぼえよう")
        
        let level2Config = service.getLevelConfiguration(2)
        #expect(level2Config.requiredStars == 1)
        #expect(level2Config.characters.count == 10) // あ行+か行
        #expect(level2Config.title == "か行をおぼえよう")
        
        let level10Config = service.getLevelConfiguration(10)
        #expect(level10Config.requiredStars == 9)
        #expect(level10Config.characters.count == 48) // 全文字（「ゐ」「ゑ」含む）
        #expect(level10Config.title == "すべてのひらがな")
    }
    
    @Test("エラーハンドリング")
    func errorHandling() {
        let service = LevelProgressionService(forTesting: true)
        
        // 不正なレベル番号
        #expect(service.isLevelUnlocked(0) == false)
        #expect(service.isLevelUnlocked(-1) == false)
        #expect(service.isLevelUnlocked(100) == false)
        
        // 不正なスター数
        service.completeLevel(1, earnedStars: -1)
        #expect(service.getStarsForLevel(1) == 0)
        
        service.completeLevel(1, earnedStars: 5)
        #expect(service.getStarsForLevel(1) == 3) // 最大3スター
        
        // 解放されていないレベルのクリア試行
        service.completeLevel(10, earnedStars: 3)
        #expect(service.getStarsForLevel(10) == 0) // 記録されない
    }
}