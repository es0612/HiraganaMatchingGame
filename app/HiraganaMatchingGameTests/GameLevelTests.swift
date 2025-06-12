import Testing
import SwiftData
@testable import HiraganaMatchingGame

@Test("GameLevelモデル初期化テスト")
func gameLevelInitialization() {
    let hiraganaSet = ["あ", "い", "う", "え", "お"]
    let level = GameLevel(levelNumber: 1, hiraganaSet: hiraganaSet)
    
    #expect(level.levelNumber == 1)
    #expect(level.hiraganaSet == hiraganaSet)
    #expect(level.isCompleted == false)
    #expect(level.bestScore == 0)
}

@Test("レベル完了時のスコア更新")
func levelCompletionScoreUpdate() {
    let level = GameLevel(levelNumber: 1, hiraganaSet: ["あ", "い", "う"])
    
    level.completeLevel(withScore: 5)
    
    #expect(level.isCompleted == true)
    #expect(level.bestScore == 5)
}

@Test("既存ベストスコアより高い場合の更新")
func bestScoreUpdate() {
    let level = GameLevel(levelNumber: 1, hiraganaSet: ["あ", "い", "う"])
    level.completeLevel(withScore: 3)
    
    level.completeLevel(withScore: 5)
    
    #expect(level.bestScore == 5)
}

@Test("既存ベストスコアより低い場合は更新されない")
func bestScoreNotDowngraded() {
    let level = GameLevel(levelNumber: 1, hiraganaSet: ["あ", "い", "う"])
    level.completeLevel(withScore: 5)
    
    level.completeLevel(withScore: 3)
    
    #expect(level.bestScore == 5)
}