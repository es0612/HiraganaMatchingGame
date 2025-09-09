import Foundation

/// Service responsible for game logic and level progression
final class HiraganaGameService {
    static let shared = HiraganaGameService()
    
    private let hiraganaItemRepository = HiraganaItemRepository.shared
    private let wordMappingRepository = WordMappingRepository.shared
    private let emojiRepository = EmojiRepository.shared
    
    private init() {}
    
    /// Level configuration defining which characters are available at each level
    private let levelConfiguration: [Int: [String]] = [
        1: ["あ", "い", "う", "え", "お"],
        2: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ"],
        3: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ"],
        4: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と"],
        5: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の"],
        6: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ"],
        7: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も"],
        8: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ"],
        9: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ"],
        10: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ", "わ", "ゐ", "ゑ", "を", "ん"]
    ]
    
    // MARK: - Level Management
    
    /// Gets the level configuration
    /// - Returns: Dictionary mapping level numbers to arrays of available characters
    func getLevelConfiguration() -> [Int: [String]] {
        return levelConfiguration
    }
    
    /// Gets characters available for a specific level
    /// - Parameter level: The level number (1-10)
    /// - Returns: Array of characters available at that level, or empty array if invalid level
    func getCharactersForLevel(_ level: Int) -> [String] {
        return levelConfiguration[level] ?? []
    }
    
    /// Gets hiragana items available for a specific level
    /// - Parameter level: The level number (1-10)
    /// - Returns: Array of hiragana items available for that level
    func getHiraganaForLevel(_ level: Int) -> [HiraganaItem] {
        return hiraganaItemRepository.getHiraganaForLevel(level)
    }
    
    /// Checks if a level is valid
    /// - Parameter level: The level to validate
    /// - Returns: True if level is between 1-10, false otherwise
    func isValidLevel(_ level: Int) -> Bool {
        return level >= 1 && level <= levelConfiguration.count
    }
    
    /// Gets the maximum available level
    /// - Returns: The highest level number available
    func getMaxLevel() -> Int {
        return levelConfiguration.count
    }
    
    // MARK: - Game Question Generation
    
    /// Generates random choices for a game question using the first item of the character
    /// - Parameters:
    ///   - hiragana: The correct hiragana character
    ///   - count: Number of choices to generate (default 3)
    /// - Returns: Array of shuffled hiragana items including the correct answer
    func getRandomChoices(for hiragana: String, count: Int = 3) -> [HiraganaItem] {
        return hiraganaItemRepository.getRandomChoices(for: hiragana, count: count)
    }
    
    /// Generates random choices with a specific correct answer item
    /// - Parameters:
    ///   - correctAnswer: The specific correct hiragana item to use
    ///   - count: Number of choices to generate (default 3)
    /// - Returns: Array of shuffled hiragana items including the specified correct answer
    func getRandomChoicesWithCorrectAnswer(_ correctAnswer: HiraganaItem, count: Int = 3) -> [HiraganaItem] {
        return hiraganaItemRepository.getRandomChoicesWithCorrectAnswer(correctAnswer, count: count)
    }
    
    /// Gets all possible question variations for a hiragana character
    /// - Parameter hiragana: The hiragana character
    /// - Returns: Array of all hiragana items with that character
    func getQuestionVariations(for hiragana: String) -> [HiraganaItem] {
        return hiraganaItemRepository.getQuestionVariations(for: hiragana)
    }
    
    // MARK: - Game Data Access
    
    /// Gets the first item for a specific character (for consistency)
    /// - Parameter character: The hiragana character
    /// - Returns: The first hiragana item with that character, or nil
    func getItem(for character: String) -> HiraganaItem? {
        return hiraganaItemRepository.getItem(for: character)
    }
    
    /// Gets all available hiragana data
    /// - Returns: Array of all hiragana items
    func getAllHiraganaData() -> [HiraganaItem] {
        return hiraganaItemRepository.getAllHiraganaData()
    }
    
    /// Gets all unique characters available in the game
    /// - Returns: Array of unique hiragana characters
    func getAllCharacters() -> [String] {
        return hiraganaItemRepository.getAllCharacters()
    }
    
    /// Gets reading text for a hiragana character
    /// - Parameter character: The hiragana character
    /// - Returns: The reading text, or the character itself if not found
    func getReadingForCharacter(_ character: String) -> String {
        return hiraganaItemRepository.getReadingForCharacter(character)
    }
    
    // MARK: - Word and Emoji Mappings
    
    /// Gets the Japanese word for an image name
    /// - Parameter imageName: The image name to look up
    /// - Returns: The corresponding Japanese word, or nil if not found
    func getJapaneseWord(for imageName: String) -> String? {
        return wordMappingRepository.getJapaneseWord(for: imageName)
    }
    
    /// Gets the emoji representation for an image name
    /// - Parameter imageName: The image name to look up
    /// - Returns: The corresponding emoji, or "❓" if not found
    func getEmojiForImageName(_ imageName: String) -> String {
        return emojiRepository.getEmojiForImageName(imageName)
    }
    
    // MARK: - Game Progression Logic
    
    /// Calculates if a level should be unlocked based on performance
    /// - Parameters:
    ///   - currentLevel: The current level
    ///   - score: The score achieved
    ///   - totalQuestions: Total questions in the level
    /// - Returns: True if the next level should be unlocked
    func shouldUnlockNextLevel(currentLevel: Int, score: Int, totalQuestions: Int) -> Bool {
        let accuracy = Double(score) / Double(totalQuestions)
        let requiredAccuracy = 0.7 // 70% accuracy required to unlock next level
        
        return accuracy >= requiredAccuracy && currentLevel < getMaxLevel()
    }
    
    /// Calculates stars earned based on performance
    /// - Parameters:
    ///   - score: The score achieved
    ///   - totalQuestions: Total questions in the level
    /// - Returns: Number of stars earned (0-3)
    func calculateStarsEarned(score: Int, totalQuestions: Int) -> Int {
        let accuracy = Double(score) / Double(totalQuestions)
        
        if accuracy >= 0.9 {
            return 3 // 90%+ = 3 stars
        } else if accuracy >= 0.7 {
            return 2 // 70-89% = 2 stars
        } else if accuracy >= 0.5 {
            return 1 // 50-69% = 1 star
        } else {
            return 0 // <50% = 0 stars
        }
    }
    
    /// Determines if performance is considered "excellent"
    /// - Parameters:
    ///   - score: The score achieved
    ///   - totalQuestions: Total questions in the level
    /// - Returns: True if performance is excellent (90%+ accuracy)
    func isExcellentPerformance(score: Int, totalQuestions: Int) -> Bool {
        let accuracy = Double(score) / Double(totalQuestions)
        return accuracy >= 0.9
    }
    
    /// Gets a random hiragana character for a specific level
    /// - Parameter level: The level to get a character from
    /// - Returns: A random character available at that level, or nil if invalid level
    func getRandomCharacterForLevel(_ level: Int) -> String? {
        let characters = getCharactersForLevel(level)
        return characters.randomElement()
    }
    
    /// Gets difficulty rating for a level
    /// - Parameter level: The level to evaluate
    /// - Returns: Difficulty rating from 1 (easy) to 5 (very hard)
    func getDifficultyRating(for level: Int) -> Int {
        switch level {
        case 1...2:
            return 1 // Very Easy - Basic vowels and first consonants
        case 3...4:
            return 2 // Easy - Adding more basic consonants
        case 5...6:
            return 3 // Medium - Mid-range hiragana
        case 7...8:
            return 4 // Hard - Complex hiragana including や行
        case 9...10:
            return 5 // Very Hard - All hiragana including rare characters
        default:
            return 1
        }
    }
}