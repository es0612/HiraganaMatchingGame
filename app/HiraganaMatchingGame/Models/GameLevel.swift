import Foundation
import SwiftData

@Model
final class GameLevel {
    var levelNumber: Int
    var hiraganaSet: [String]
    var isCompleted: Bool
    var bestScore: Int
    
    init(levelNumber: Int, hiraganaSet: [String]) {
        self.levelNumber = levelNumber
        self.hiraganaSet = hiraganaSet
        self.isCompleted = false
        self.bestScore = 0
    }
    
    func completeLevel(withScore score: Int) {
        isCompleted = true
        if score > bestScore {
            bestScore = score
        }
    }
    
    func resetLevel() {
        isCompleted = false
        bestScore = 0
    }
}