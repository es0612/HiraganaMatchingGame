import Testing
import SwiftData
@testable import HiraganaMatchingGame

@Suite("スター獲得・キャラクター解放システムテスト")
struct StarUnlockSystemTests {
    
    @Test("初期キャラクター解放状態確認")
    func initialCharacterUnlockState() {
        let service = TestableStarUnlockService()
        
        // 初期状態：あ行のみ解放
        #expect(service.getUnlockedCharacters().count == 5)
        #expect(service.isCharacterUnlocked("あ") == true)
        #expect(service.isCharacterUnlocked("お") == true)
        
        // か行は未解放
        #expect(service.isCharacterUnlocked("か") == false)
    }
    
    @Test("スター獲得によるキャラクター解放")
    func characterUnlockByStars() {
        let service = TestableStarUnlockService()
        
        // 1スター獲得でか行解放
        service.addStars(1)
        service.updateUnlockedCharacters()
        
        #expect(service.getUnlockedCharacters().count == 10) // あ行+か行
        #expect(service.isCharacterUnlocked("か") == true)
        #expect(service.isCharacterUnlocked("こ") == true)
        
        // 3スター獲得でさ行解放
        service.addStars(2)
        service.updateUnlockedCharacters()
        
        #expect(service.getUnlockedCharacters().count == 15) // あ行+か行+さ行
        #expect(service.isCharacterUnlocked("さ") == true)
        #expect(service.isCharacterUnlocked("そ") == true)
        
        // た行はまだ未解放
        #expect(service.isCharacterUnlocked("た") == false)
    }
    
    @Test("スター獲得計算システム")
    func starCalculationSystem() {
        let service = TestableStarUnlockService()
        
        // 完璧な正解率（100%）
        let perfectStars = service.calculateStars(correctAnswers: 5, totalQuestions: 5, timeTaken: 30.0)
        #expect(perfectStars == 3)
        
        // 良い正解率（80%）
        let goodStars = service.calculateStars(correctAnswers: 4, totalQuestions: 5, timeTaken: 45.0)
        #expect(goodStars == 2)
        
        // 普通の正解率（60%）
        let okStars = service.calculateStars(correctAnswers: 3, totalQuestions: 5, timeTaken: 60.0)
        #expect(okStars == 1)
        
        // 時間ボーナス適用テスト
        let fastStars = service.calculateStars(correctAnswers: 4, totalQuestions: 5, timeTaken: 20.0)
        #expect(fastStars >= 2) // 高速回答でボーナス
        
        // 不正解率が高い場合
        let poorStars = service.calculateStars(correctAnswers: 2, totalQuestions: 5, timeTaken: 90.0)
        #expect(poorStars == 0)
    }
    
    @Test("特別キャラクター解放条件")
    func specialCharacterUnlock() {
        let service = TestableStarUnlockService()
        
        // 通常の解放
        service.addStars(10)
        service.updateUnlockedCharacters()
        #expect(service.isCharacterUnlocked("な") == true)
        
        // 特別キャラクター「ん」は全レベルクリア後
        service.addStars(45) // 十分なスター数
        service.updateUnlockedCharacters()
        #expect(service.isCharacterUnlocked("ん") == true) // わ行のスター要件で解放
    }
    
    @Test("キャラクター解放通知システム")
    func characterUnlockNotification() {
        let service = TestableStarUnlockService()
        var notificationReceived = false
        var unlockedCharacters: [String] = []
        
        service.onCharacterUnlocked = { characters in
            notificationReceived = true
            unlockedCharacters = characters
        }
        
        // スター獲得でキャラクター解放
        service.addStars(1)
        service.updateUnlockedCharacters()
        
        #expect(notificationReceived == true)
        #expect(unlockedCharacters.contains("か") == true)
        #expect(unlockedCharacters.contains("き") == true)
    }
    
    @Test("累積スター統計")
    func cumulativeStarStatistics() {
        let service = TestableStarUnlockService()
        
        // 複数レベルからスター獲得
        service.recordLevelCompletion(level: 1, stars: 3, accuracy: 1.0, time: 30.0)
        service.recordLevelCompletion(level: 2, stars: 2, accuracy: 0.8, time: 45.0)
        
        let stats = service.getStarStatistics()
        
        #expect(stats.totalStars == 5)
        #expect(stats.totalLevelsCompleted == 2)
        #expect(abs(stats.averageStarsPerLevel - 2.5) < 0.01)
    }
    
    @Test("レベル改善による追加スター")
    func levelImprovementStars() {
        let service = TestableStarUnlockService()
        
        // 初回クリア（1スター）
        service.recordLevelCompletion(level: 1, stars: 1, accuracy: 0.6, time: 90.0)
        #expect(service.getTotalStars() == 1)
        
        // 改善クリア（3スター）
        service.recordLevelCompletion(level: 1, stars: 3, accuracy: 1.0, time: 30.0)
        #expect(service.getTotalStars() == 3) // 差分の2スター追加
        
        let levelStats = service.getLevelStatistics(level: 1)
        #expect(levelStats != nil)
        #expect(levelStats!.bestStars == 3)
        #expect(levelStats!.bestAccuracy == 1.0)
        #expect(levelStats!.bestTime == 30.0)
        #expect(levelStats!.totalAttempts == 2)
    }
    
    @Test("キャラクター解放進捗表示")
    func characterUnlockProgress() {
        let service = TestableStarUnlockService()
        
        // 初期進捗
        let initialProgress = service.getUnlockProgress()
        #expect(initialProgress.unlockedCount == 5)
        #expect(initialProgress.totalCount >= 45) // 全ひらがな
        
        // スター獲得後の進捗
        service.addStars(3)
        service.updateUnlockedCharacters()
        
        let updatedProgress = service.getUnlockProgress()
        #expect(updatedProgress.unlockedCount == 15) // あ行+か行+さ行
    }
    
    @Test("実績・バッジシステム")
    func achievementBadgeSystem() {
        let service = TestableStarUnlockService()
        
        // 初期状態：実績なし
        #expect(service.getUnlockedAchievements().isEmpty == true)
        
        // 初回クリア実績
        service.recordLevelCompletion(level: 1, stars: 1, accuracy: 0.6, time: 90.0)
        let achievements1 = service.getUnlockedAchievements()
        #expect(achievements1.contains(.firstCompletion) == true)
        
        // パーフェクト実績
        service.recordLevelCompletion(level: 2, stars: 3, accuracy: 1.0, time: 30.0)
        let achievements2 = service.getUnlockedAchievements()
        #expect(achievements2.contains(.perfectScore) == true)
        
        // スピード実績
        service.recordLevelCompletion(level: 3, stars: 2, accuracy: 0.8, time: 15.0)
        let achievements3 = service.getUnlockedAchievements()
        #expect(achievements3.contains(.speedRun) == true)
        
        // 連続クリア実績
        for level in 4...7 {
            service.recordLevelCompletion(level: level, stars: 2, accuracy: 0.8, time: 40.0)
        }
        let achievements4 = service.getUnlockedAchievements()
        #expect(achievements4.contains(.streak) == true)
    }
}