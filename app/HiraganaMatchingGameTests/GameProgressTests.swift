import Testing
import SwiftData
@testable import HiraganaMatchingGame

@Test("GameProgressモデル初期化テスト")
func gameProgressInitialization() {
    let progress = GameProgress()
    
    #expect(progress.currentLevel == 1)
    #expect(progress.totalStars == 0)
    #expect(progress.unlockedCharacters.isEmpty)
    #expect(progress.lastPlayedDate != nil)
}

@Test("レベルクリア時のスター獲得")
func starAcquisitionOnLevelClear() {
    let progress = GameProgress()
    let initialStars = progress.totalStars
    
    progress.addStars(3)
    
    #expect(progress.totalStars == initialStars + 3)
}

@Test("レベル進行テスト")
func levelProgression() {
    let progress = GameProgress()
    let initialLevel = progress.currentLevel
    
    progress.advanceToNextLevel()
    
    #expect(progress.currentLevel == initialLevel + 1)
}

@Test("キャラクター解放テスト")
func characterUnlocking() {
    let progress = GameProgress()
    let characterName = "ねこ"
    
    progress.unlockCharacter(characterName)
    
    #expect(progress.unlockedCharacters.contains(characterName))
}

@Test("SwiftData永続化テスト") @MainActor
func gameProgressPersistence() throws {
    let schema = Schema([
        GameProgress.self,
        GameLevel.self,
        UserSettings.self,
        Character.self,
    ])
    let container = try ModelContainer(
        for: schema,
        configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
    )
    let context = container.mainContext
    
    let progress = GameProgress(currentLevel: 5, totalStars: 15)
    context.insert(progress)
    
    try context.save()
    
    let descriptor = FetchDescriptor<GameProgress>()
    let savedProgress = try context.fetch(descriptor)
    
    #expect(savedProgress.count == 1)
    #expect(savedProgress.first?.currentLevel == 5)
    #expect(savedProgress.first?.totalStars == 15)
}