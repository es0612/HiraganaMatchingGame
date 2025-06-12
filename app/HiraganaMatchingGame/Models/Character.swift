import Foundation
import SwiftData

@Model
final class Character {
    var name: String
    var imageName: String
    var unlockRequirement: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    init(name: String, imageName: String, unlockRequirement: Int) {
        self.name = name
        self.imageName = imageName
        self.unlockRequirement = unlockRequirement
        self.isUnlocked = false
        self.unlockedDate = nil
    }
    
    func unlock() {
        if !isUnlocked {
            isUnlocked = true
            unlockedDate = Date()
        }
    }
    
    func canUnlock(withStars stars: Int) -> Bool {
        return stars >= unlockRequirement
    }
    
    func reset() {
        isUnlocked = false
        unlockedDate = nil
    }
}