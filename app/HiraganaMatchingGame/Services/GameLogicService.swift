import Foundation

struct GameQuestion {
    let hiragana: String
    let choices: [HiraganaItem]
    let correctAnswer: HiraganaItem
}

struct GameStats {
    let accuracy: Double
    let stars: Int
    let timeTaken: TimeInterval
    let averageTimePerQuestion: Double
}

class GameLogicService {
    private let hiraganaDataManager = HiraganaDataManager.shared
    
    init() {}
    
    func isCorrectAnswer(hiragana: String, imageName: String) -> Bool {
        guard let correctItem = hiraganaDataManager.getItem(for: hiragana) else {
            return false
        }
        return correctItem.imageName == imageName
    }
    
    func generateChoices(for hiragana: String, count: Int) -> [HiraganaItem] {
        return hiraganaDataManager.getRandomChoices(for: hiragana, count: count)
    }
    
    func generateQuestionsForLevel(_ level: Int, questionCount: Int) -> [GameQuestion] {
        let levelConfig = hiraganaDataManager.getLevelConfiguration()
        guard let charactersForLevel = levelConfig[level] else { return [] }
        
        var questions: [GameQuestion] = []
        
        for _ in 0..<questionCount {
            let randomHiragana = charactersForLevel.randomElement() ?? ""
            let choices = generateChoices(for: randomHiragana, count: 3)
            
            guard let correctAnswer = hiraganaDataManager.getItem(for: randomHiragana) else {
                continue
            }
            
            let question = GameQuestion(
                hiragana: randomHiragana,
                choices: choices,
                correctAnswer: correctAnswer
            )
            questions.append(question)
        }
        
        return questions
    }
    
    func calculateStars(correctAnswers: Int, totalQuestions: Int) -> Int {
        let accuracy = Double(correctAnswers) / Double(totalQuestions)
        
        switch accuracy {
        case 1.0:
            return 3
        case 0.8...0.99:
            return 2
        case 0.6...0.79:
            return 1
        default:
            return 0
        }
    }
    
    func canUnlockLevel(_ level: Int, withStars stars: Int) -> Bool {
        if level == 1 { return true }
        if level > 10 { return false }
        
        let requiredStars = (level - 1) * 1
        return stars >= requiredStars
    }
    
    func calculateGameStats(correctAnswers: Int, totalQuestions: Int, timeTaken: TimeInterval) -> GameStats {
        let accuracy = Double(correctAnswers) / Double(totalQuestions)
        let stars = calculateStars(correctAnswers: correctAnswers, totalQuestions: totalQuestions)
        let averageTime = timeTaken / Double(totalQuestions)
        
        return GameStats(
            accuracy: accuracy,
            stars: stars,
            timeTaken: timeTaken,
            averageTimePerQuestion: averageTime
        )
    }
    
    func getNextLevel(currentLevel: Int, earnedStars: Int) -> Int? {
        let nextLevel = currentLevel + 1
        return canUnlockLevel(nextLevel, withStars: earnedStars) ? nextLevel : nil
    }
    
    func validateAnswer(_ answer: String, for hiragana: String) -> Bool {
        return isCorrectAnswer(hiragana: hiragana, imageName: answer)
    }
    
    func generateHint(for hiragana: String) -> String {
        guard let item = hiraganaDataManager.getItem(for: hiragana) else {
            return ""
        }
        return "\(hiragana)は\(item.category)の仲間だよ！"
    }
}