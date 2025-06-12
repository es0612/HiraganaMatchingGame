import Testing
import SwiftData
@testable import HiraganaMatchingGame

@Test("Characterモデル初期化テスト")
func characterInitialization() {
    let character = Character(name: "ねこ", imageName: "cat", unlockRequirement: 10)
    
    #expect(character.name == "ねこ")
    #expect(character.imageName == "cat")
    #expect(character.unlockRequirement == 10)
    #expect(character.isUnlocked == false)
    #expect(character.unlockedDate == nil)
}

@Test("キャラクター解放テスト")
func characterUnlock() {
    let character = Character(name: "ねこ", imageName: "cat", unlockRequirement: 10)
    
    character.unlock()
    
    #expect(character.isUnlocked == true)
    #expect(character.unlockedDate != nil)
}

@Test("解放済みキャラクターの再解放テスト")
func alreadyUnlockedCharacter() {
    let character = Character(name: "ねこ", imageName: "cat", unlockRequirement: 10)
    character.unlock()
    let firstUnlockDate = character.unlockedDate
    
    character.unlock()
    
    #expect(character.unlockedDate == firstUnlockDate)
}

@Test("解放条件チェックテスト")
func unlockRequirementCheck() {
    let character = Character(name: "ねこ", imageName: "cat", unlockRequirement: 10)
    
    #expect(character.canUnlock(withStars: 5) == false)
    #expect(character.canUnlock(withStars: 10) == true)
    #expect(character.canUnlock(withStars: 15) == true)
}