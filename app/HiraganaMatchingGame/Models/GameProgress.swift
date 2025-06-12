import Foundation
import SwiftData

@Model
final class GameProgress {
    var currentLevel: Int
    var totalStars: Int
    var unlockedCharacters: [String]
    var lastPlayedDate: Date
    
    init(currentLevel: Int = 1, totalStars: Int = 0) {
        self.currentLevel = currentLevel
        self.totalStars = totalStars
        self.unlockedCharacters = []
        self.lastPlayedDate = Date()
    }
    
    func addStars(_ stars: Int) {
        totalStars += stars
    }
    
    func advanceToNextLevel() {
        currentLevel += 1
    }
    
    func unlockCharacter(_ characterName: String) {
        if !unlockedCharacters.contains(characterName) {
            unlockedCharacters.append(characterName)
        }
    }
    
    func updateLastPlayedDate() {
        lastPlayedDate = Date()
    }
}