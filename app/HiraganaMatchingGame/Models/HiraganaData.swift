import Foundation

struct HiraganaItem: Identifiable, Hashable {
    let id = UUID()
    let character: String
    let imageName: String
    let category: String
    let soundFileName: String
    
    init(character: String, imageName: String, category: String) {
        self.character = character
        self.imageName = imageName
        self.category = category
        soundFileName = "\(character).mp3"
    }
}

/// Facade class that provides a unified interface to hiragana game data and services
/// Delegates to specialized repositories and services for specific functionality
class HiraganaDataManager {
    static let shared = HiraganaDataManager()
    
    private let gameService = HiraganaGameService.shared
    
    private init() {}
    
    // MARK: - Level Management
    
    /// Gets hiragana items available for a specific level
    /// - Parameter level: The level number (1-10)
    /// - Returns: Array of hiragana items available for that level
    func getHiraganaForLevel(_ level: Int) -> [HiraganaItem] {
        gameService.getHiraganaForLevel(level)
    }
    
    /// Gets the level configuration
    /// - Returns: Dictionary mapping level numbers to arrays of available characters
    func getLevelConfiguration() -> [Int: [String]] {
        gameService.getLevelConfiguration()
    }
    
    // MARK: - Game Question Generation
    
    /// Generates random choices for a game question using the first item of the character
    /// - Parameters:
    ///   - hiragana: The correct hiragana character
    ///   - count: Number of choices to generate (default 3)
    /// - Returns: Array of shuffled hiragana items including the correct answer
    func getRandomChoices(for hiragana: String, count: Int = 3) -> [HiraganaItem] {
        gameService.getRandomChoices(for: hiragana, count: count)
    }
    
    /// Generates random choices with a specific correct answer item
    /// - Parameters:
    ///   - correctAnswer: The specific correct hiragana item to use
    ///   - count: Number of choices to generate (default 3)
    /// - Returns: Array of shuffled hiragana items including the specified correct answer
    func getRandomChoicesWithCorrectAnswer(_ correctAnswer: HiraganaItem, count: Int = 3) -> [HiraganaItem] {
        gameService.getRandomChoicesWithCorrectAnswer(correctAnswer, count: count)
    }
    
    /// Gets all possible question variations for a hiragana character
    /// - Parameter hiragana: The hiragana character
    /// - Returns: Array of all hiragana items with that character
    func getQuestionVariations(for hiragana: String) -> [HiraganaItem] {
        gameService.getQuestionVariations(for: hiragana)
    }
    
    // MARK: - Data Access
    
    /// Gets the Japanese word for an image name
    /// - Parameter imageName: The image name to look up
    /// - Returns: The corresponding Japanese word, or nil if not found
    func getJapaneseWord(for imageName: String) -> String? {
        gameService.getJapaneseWord(for: imageName)
    }
    
    /// Gets all unique characters available in the game
    /// - Returns: Array of unique hiragana characters
    func getAllCharacters() -> [String] {
        gameService.getAllCharacters()
    }
    
    /// Gets all available hiragana data
    /// - Returns: Array of all hiragana items
    func getAllHiraganaData() -> [HiraganaItem] {
        gameService.getAllHiraganaData()
    }
    
    /// Gets the first item for a specific character (for consistency)
    /// - Parameter character: The hiragana character
    /// - Returns: The first hiragana item with that character, or nil
    func getItem(for character: String) -> HiraganaItem? {
        gameService.getItem(for: character)
    }
    
    /// Gets reading text for a hiragana character
    /// - Parameter character: The hiragana character
    /// - Returns: The reading text, or the character itself if not found
    func getReadingForCharacter(_ character: String) -> String {
        gameService.getReadingForCharacter(character)
    }
    
    // MARK: - Emoji Support
    
    /// Gets the emoji representation for an image name
    /// - Parameter imageName: The image name to look up
    /// - Returns: The corresponding emoji, or "❓" if not found
    func getEmojiForImageName(_ imageName: String) -> String {
        gameService.getEmojiForImageName(imageName)
    }
    
    // MARK: - Game Progression (Enhanced functionality)
    
    /// Calculates if a level should be unlocked based on performance
    /// - Parameters:
    ///   - currentLevel: The current level
    ///   - score: The score achieved
    ///   - totalQuestions: Total questions in the level
    /// - Returns: True if the next level should be unlocked
    func shouldUnlockNextLevel(currentLevel: Int, score: Int, totalQuestions: Int) -> Bool {
        gameService.shouldUnlockNextLevel(currentLevel: currentLevel, score: score, totalQuestions: totalQuestions)
    }
    
    /// Calculates stars earned based on performance
    /// - Parameters:
    ///   - score: The score achieved
    ///   - totalQuestions: Total questions in the level
    /// - Returns: Number of stars earned (0-3)
    func calculateStarsEarned(score: Int, totalQuestions: Int) -> Int {
        gameService.calculateStarsEarned(score: score, totalQuestions: totalQuestions)
    }
    
    /// Determines if performance is considered "excellent"
    /// - Parameters:
    ///   - score: The score achieved
    ///   - totalQuestions: Total questions in the level
    /// - Returns: True if performance is excellent (90%+ accuracy)
    func isExcellentPerformance(score: Int, totalQuestions: Int) -> Bool {
        gameService.isExcellentPerformance(score: score, totalQuestions: totalQuestions)
    }
    
    /// Gets a random hiragana character for a specific level
    /// - Parameter level: The level to get a character from
    /// - Returns: A random character available at that level, or nil if invalid level
    func getRandomCharacterForLevel(_ level: Int) -> String? {
        gameService.getRandomCharacterForLevel(level)
    }
    
    /// Gets difficulty rating for a level
    /// - Parameter level: The level to evaluate
    /// - Returns: Difficulty rating from 1 (easy) to 5 (very hard)
    func getDifficultyRating(for level: Int) -> Int {
        gameService.getDifficultyRating(for: level)
    }
}
