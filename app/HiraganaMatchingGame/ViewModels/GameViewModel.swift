import Foundation
import SwiftData

@Observable
class GameViewModel {
    var currentLevel: Int = 1
    var currentQuestion: Int = 1
    var score: Int = 0
    var totalQuestions: Int = 5
    var isGameCompleted: Bool = false
    var currentHiragana: String = ""
    var answerChoices: [HiraganaItem] = []
    
    private let hiraganaDataManager = HiraganaDataManager.shared
    private var currentLevelCharacters: [String] = []
    
    init() {
        
    }
    
    func startNewGame(level: Int) {
        currentLevel = level
        currentQuestion = 1
        score = 0
        isGameCompleted = false
        
        let levelConfig = hiraganaDataManager.getLevelConfiguration()
        currentLevelCharacters = levelConfig[level] ?? []
        
        generateNextQuestion()
    }
    
    func selectAnswer(_ imageName: String) {
        let correctAnswer = getCorrectAnswer()
        
        if imageName == correctAnswer.imageName {
            score += 1
        }
        
        currentQuestion += 1
        
        if currentQuestion > totalQuestions {
            isGameCompleted = true
        } else {
            generateNextQuestion()
        }
    }
    
    func getCorrectAnswer() -> HiraganaItem {
        return hiraganaDataManager.getItem(for: currentHiragana) ?? 
               HiraganaItem(character: "", imageName: "", category: "")
    }
    
    func calculateStars(for score: Int) -> Int {
        switch score {
        case 5:
            return 3
        case 4:
            return 2
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func resetGame() {
        currentLevel = 1
        currentQuestion = 1
        score = 0
        isGameCompleted = false
        currentHiragana = ""
        answerChoices = []
    }
    
    private func generateNextQuestion() {
        guard !currentLevelCharacters.isEmpty else { return }
        
        currentHiragana = currentLevelCharacters.randomElement() ?? ""
        answerChoices = hiraganaDataManager.getRandomChoices(for: currentHiragana, count: 3)
    }
    
    func getCurrentProgress() -> Double {
        return Double(currentQuestion - 1) / Double(totalQuestions)
    }
    
    func getScorePercentage() -> Double {
        return Double(score) / Double(totalQuestions)
    }
}