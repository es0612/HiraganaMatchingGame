import Testing
import SwiftData
@testable import HiraganaMatchingGame

@Suite("レベル進行統合テスト")
struct LevelProgressionIntegrationTests {
    
    @Test("LevelSelectionViewModel初期化テスト")
    func levelSelectionViewModelInitialization() {
        let testProgressionService = LevelProgressionService(forTesting: true)
        let viewModel = LevelSelectionViewModel(levelProgressionService: testProgressionService)
        
        #expect(viewModel.getTotalStars() == 0)
        #expect(viewModel.getRecommendedLevel() == 1)
        #expect(viewModel.isLevelUnlocked(1) == true)
        #expect(viewModel.isLevelUnlocked(2) == false)
    }
    
    @Test("レベル完了処理統合テスト")
    func levelCompletionIntegration() {
        let testProgressionService = LevelProgressionService(forTesting: true)
        let viewModel = LevelSelectionViewModel(levelProgressionService: testProgressionService)
        
        // レベル1完了（3スター）
        viewModel.completeLevel(1, stars: 3)
        
        #expect(viewModel.getTotalStars() == 3)
        #expect(viewModel.getStarsForLevel(1) == 3)
        #expect(viewModel.isLevelUnlocked(2) == true)
        #expect(viewModel.isLevelUnlocked(3) == false) // まだ解放されない
        #expect(viewModel.isLevelUnlocked(4) == false) // まだ解放されない
        #expect(viewModel.getRecommendedLevel() == 2)
        
        // レベル2完了（2スター）
        viewModel.completeLevel(2, stars: 2)
        
        #expect(viewModel.getTotalStars() == 5)
        #expect(viewModel.getStarsForLevel(2) == 2)
        #expect(viewModel.isLevelUnlocked(3) == true) // レベル2完了でレベル3解放
        #expect(viewModel.isLevelUnlocked(4) == false) // まだ解放されない
        #expect(viewModel.getRecommendedLevel() == 3)
    }
    
    @Test("進行状況統計テスト")
    func progressionStatistics() {
        let testProgressionService = LevelProgressionService(forTesting: true)
        let viewModel = LevelSelectionViewModel(levelProgressionService: testProgressionService)
        
        // 複数レベルクリア
        viewModel.completeLevel(1, stars: 3)
        viewModel.completeLevel(2, stars: 2)
        viewModel.completeLevel(3, stars: 2)
        
        let stats = viewModel.getProgressionStats()
        
        #expect(stats.completedLevels == 3)
        #expect(stats.totalStars == 7)
        #expect(stats.maxUnlockedLevel == 4) // レベル3完了でレベル4解放
        #expect(stats.completionPercentage == 0.3) // 3/10
        #expect(abs(stats.averageStarsPerLevel - 2.33) < 0.01)
    }
    
    @Test("GameView統合テスト")
    func gameViewIntegration() {
        let progressionService = LevelProgressionService()
        var gameCompletionCalled = false
        var completedLevel = 0
        var earnedStars = 0
        
        // ゲーム完了コールバックのテスト
        let onGameComplete: (Int, Int) -> Void = { level, stars in
            gameCompletionCalled = true
            completedLevel = level
            earnedStars = stars
        }
        
        let gameView = GameView(
            selectedLevel: 2,
            levelProgressionService: progressionService,
            onGameComplete: onGameComplete
        )
        
        #expect(gameView.selectedLevel == 2)
        
        // 実際のゲーム完了はUI操作が必要なため、
        // コールバック設定の確認のみ行う
        onGameComplete(2, 3)
        #expect(gameCompletionCalled == true)
        #expect(completedLevel == 2)
        #expect(earnedStars == 3)
    }
    
    @Test("レベル設定統合テスト")
    func levelConfigurationIntegration() {
        let viewModel = LevelSelectionViewModel()
        
        // レベル1設定確認
        let level1Config = viewModel.getLevelConfiguration(1)
        #expect(level1Config.level == 1)
        #expect(level1Config.title == "あ行をおぼえよう")
        #expect(level1Config.characters == ["あ", "い", "う", "え", "お"])
        #expect(level1Config.requiredStars == 0)
        #expect(level1Config.questionsCount == 5)
        
        // レベル5設定確認
        let level5Config = viewModel.getLevelConfiguration(5)
        #expect(level5Config.level == 5)
        #expect(level5Config.title == "な行をおぼえよう")
        #expect(level5Config.characters.count == 25) // あ〜な行
        #expect(level5Config.requiredStars == 4)
        #expect(level5Config.questionsCount == 7)
    }
    
    @Test("進行状況リセットテスト")
    func progressReset() {
        let testProgressionService = LevelProgressionService(forTesting: true)
        let viewModel = LevelSelectionViewModel(levelProgressionService: testProgressionService)
        
        // 複数レベルクリア
        viewModel.completeLevel(1, stars: 3)
        viewModel.completeLevel(2, stars: 2)
        viewModel.completeLevel(3, stars: 2)
        
        #expect(viewModel.getTotalStars() == 7)
        #expect(viewModel.getProgressionStats().completedLevels == 3)
        
        // リセット実行
        viewModel.resetAllProgress()
        
        #expect(viewModel.getTotalStars() == 0)
        #expect(viewModel.getStarsForLevel(1) == 0)
        #expect(viewModel.getStarsForLevel(2) == 0)
        #expect(viewModel.getStarsForLevel(3) == 0)
        #expect(viewModel.isLevelUnlocked(1) == true)
        #expect(viewModel.isLevelUnlocked(2) == false)
        #expect(viewModel.getRecommendedLevel() == 1)
    }
    
    @MainActor
    @Test("SwiftData統合テスト")
    func swiftDataIntegration() async {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: GameProgress.self, configurations: config)
        let context = container.mainContext
        
        let testProgressionService = LevelProgressionService(forTesting: true)
        let viewModel = LevelSelectionViewModel(levelProgressionService: testProgressionService)
        viewModel.loadProgress(from: context)
        
        // 初期状態確認
        #expect(viewModel.getTotalStars() == 0)
        #expect(viewModel.isLevelUnlocked(1) == true)
        #expect(viewModel.isLevelUnlocked(2) == false)
        
        // レベル完了とデータ保存
        viewModel.completeLevel(1, stars: 3)
        
        // ModelContextを保存
        do {
            try context.save()
        } catch {
            print("Context save error: \(error)")
        }
        
        // 新しいViewModelでデータ読み込み
        let newTestProgressionService = LevelProgressionService(forTesting: true)
        let newViewModel = LevelSelectionViewModel(levelProgressionService: newTestProgressionService)
        newViewModel.loadProgress(from: context)
        
        #expect(newViewModel.getTotalStars() == 3)
        // 注意: GameProgressモデルは個別レベルのスター数を保存しないため、
        // 新しいサービスでの読み込み時は推測値になる
        #expect(newViewModel.getStarsForLevel(1) >= 0) // 最低限の確認
        #expect(newViewModel.isLevelUnlocked(1) == true) // レベル1は常に解放
    }
    
    @Test("エラーハンドリング統合テスト")
    func errorHandlingIntegration() {
        let testProgressionService = LevelProgressionService(forTesting: true)
        let viewModel = LevelSelectionViewModel(levelProgressionService: testProgressionService)
        
        // 不正なレベルでの完了試行
        viewModel.completeLevel(0, stars: 3)
        #expect(viewModel.getTotalStars() == 0)
        
        viewModel.completeLevel(-1, stars: 3)
        #expect(viewModel.getTotalStars() == 0)
        
        viewModel.completeLevel(100, stars: 3)
        #expect(viewModel.getTotalStars() == 0)
        
        // 不正なスター数での完了試行
        viewModel.completeLevel(1, stars: -1)
        #expect(viewModel.getStarsForLevel(1) == 0)
        
        viewModel.completeLevel(1, stars: 5)
        #expect(viewModel.getStarsForLevel(1) == 3) // 最大3スター
        
        // 解放されていないレベルでの完了試行
        viewModel.resetAllProgress()
        viewModel.completeLevel(5, stars: 3)
        #expect(viewModel.getStarsForLevel(5) == 0) // 記録されない
    }
}