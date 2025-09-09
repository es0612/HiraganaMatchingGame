import Foundation

enum SpecialUnlockRequirement {
    case allLevelsCompleted
    case perfectStreak(count: Int)
    case totalStars(count: Int)
    case timeRecord(seconds: Double)
}

struct UnlockProgress {
    let unlockedCount: Int
    let totalCount: Int
    let progressPercentage: Double
    let currentGroup: String
    let nextGroup: String?
}

struct NextUnlockInfo {
    let requiredStars: Int
    let charactersToUnlock: [String]
    let groupName: String
}

/// Service responsible for managing character unlock logic and group progression
final class CharacterUnlockService {
    static let shared = CharacterUnlockService()
    
    private var unlockedCharacters: Set<String> = ["あ", "い", "う", "え", "お"]
    
    var onCharacterUnlocked: (([String]) -> Void)?
    // Provider to read total stars from external service
    var totalStarsProvider: (() -> Int)?
    
    /// Hiragana character groups with their unlock order
    private let characterGroups: [String: [String]] = [
        "あ行": ["あ", "い", "う", "え", "お"],
        "か行": ["か", "き", "く", "け", "こ"],
        "さ行": ["さ", "し", "す", "せ", "そ"],
        "た行": ["た", "ち", "つ", "て", "と"],
        "な行": ["な", "に", "ぬ", "ね", "の"],
        "は行": ["は", "ひ", "ふ", "へ", "ほ"],
        "ま行": ["ま", "み", "む", "め", "も"],
        "や行": ["や", "ゆ", "よ"],
        "ら行": ["ら", "り", "る", "れ", "ろ"],
        "わ行": ["わ", "ゐ", "ゑ", "を", "ん"]
    ]
    
    /// Star requirements for unlocking each character group
    private let groupUnlockRequirements: [String: Int] = [
        "あ行": 0,   // Always available
        "か行": 2,   // 2 stars required
        "さ行": 4,   // 4 stars required
        "た行": 6,   // 6 stars required
        "な行": 8,   // 8 stars required
        "は行": 10,  // 10 stars required
        "ま行": 12,  // 12 stars required
        "や行": 14,  // 14 stars required
        "ら行": 16,  // 16 stars required
        "わ行": 18   // 18 stars required
    ]
    
    private init() {
        loadUnlockedCharacters()
    }
    
    // MARK: - Character Access
    
    /// Gets all currently unlocked characters
    /// - Returns: Sorted array of unlocked characters
    func getUnlockedCharacters() -> [String] {
        return Array(unlockedCharacters).sorted()
    }
    
    /// Checks if a specific character is unlocked
    /// - Parameter character: The hiragana character to check
    /// - Returns: True if the character is unlocked
    func isCharacterUnlocked(_ character: String) -> Bool {
        return unlockedCharacters.contains(character)
    }
    
    /// Gets all character groups
    /// - Returns: Dictionary of group names to character arrays
    func getCharacterGroups() -> [String: [String]] {
        return characterGroups
    }
    
    /// Gets unlock requirements for each group
    /// - Returns: Dictionary of group names to required star counts
    func getGroupUnlockRequirements() -> [String: Int] {
        return groupUnlockRequirements
    }
    
    // MARK: - Unlock Logic
    
    /// Updates unlocked characters based on current star count
    func updateUnlockedCharacters() {
        var newlyUnlocked: [String] = []
        let currentTotalStars = getTotalStars()
        
        for (groupName, requiredStars) in groupUnlockRequirements.sorted(by: { $0.value < $1.value }) {
            if currentTotalStars >= requiredStars {
                if let characters = characterGroups[groupName] {
                    for character in characters {
                        if !unlockedCharacters.contains(character) {
                            unlockedCharacters.insert(character)
                            newlyUnlocked.append(character)
                        }
                    }
                }
            }
        }
        
        // Notify about newly unlocked characters
        if !newlyUnlocked.isEmpty {
            print("🔓 Unlocked characters: \(newlyUnlocked) (Total stars: \(currentTotalStars))")
            onCharacterUnlocked?(newlyUnlocked)
            saveUnlockedCharacters()
        }
    }
    
    /// Unlocks a special character based on specific requirements
    /// - Parameters:
    ///   - character: The character to unlock
    ///   - requirement: The special requirement that must be met
    func unlockSpecialCharacter(_ character: String, requirement: SpecialUnlockRequirement) {
        if canUnlockSpecialCharacter(requirement) {
            unlockedCharacters.insert(character)
            saveUnlockedCharacters()
        }
    }
    
    /// Checks if a special unlock requirement can be met
    /// - Parameter requirement: The requirement to check
    /// - Returns: True if the requirement can be met
    private func canUnlockSpecialCharacter(_ requirement: SpecialUnlockRequirement) -> Bool {
        switch requirement {
        case .allLevelsCompleted:
            // This would need to be injected from external service
            return false // Placeholder - needs external dependency
        case .perfectStreak(_):
            // This would need to be injected from external service
            return false // Placeholder - needs external dependency
        case .totalStars(let count):
            return getTotalStars() >= count
        case .timeRecord(_):
            // This would need to be injected from external service
            return false // Placeholder - needs external dependency
        }
    }
    
    // MARK: - Progress Information
    
    /// Gets current unlock progress information
    /// - Returns: Progress information including counts and percentages
    func getUnlockProgress() -> UnlockProgress {
        let totalCharacters = characterGroups.values.flatMap { $0 }.count
        let progressPercentage = Double(unlockedCharacters.count) / Double(totalCharacters)
        
        let currentGroup = getCurrentUnlockGroup()
        let nextGroup = getNextUnlockGroup()
        
        return UnlockProgress(
            unlockedCount: unlockedCharacters.count,
            totalCount: totalCharacters,
            progressPercentage: progressPercentage,
            currentGroup: currentGroup,
            nextGroup: nextGroup
        )
    }
    
    /// Gets information about the next unlock milestone
    /// - Returns: Information about what characters will be unlocked next, or nil if all unlocked
    func getNextUnlockInfo() -> NextUnlockInfo? {
        let sortedGroups = groupUnlockRequirements.sorted { $0.value < $1.value }
        let currentTotalStars = getTotalStars()
        
        for (groupName, requiredStars) in sortedGroups {
            if currentTotalStars < requiredStars {
                let charactersToUnlock = characterGroups[groupName] ?? []
                return NextUnlockInfo(
                    requiredStars: requiredStars - currentTotalStars,
                    charactersToUnlock: charactersToUnlock,
                    groupName: groupName
                )
            }
        }
        
        return nil // All characters unlocked
    }
    
    /// Gets the currently unlocked group (highest unlocked)
    /// - Returns: Name of the current unlocked group
    private func getCurrentUnlockGroup() -> String {
        let sortedGroups = groupUnlockRequirements.sorted { $0.value > $1.value }
        let currentTotalStars = getTotalStars()
        
        for (groupName, requiredStars) in sortedGroups {
            if currentTotalStars >= requiredStars {
                return groupName
            }
        }
        
        return "あ行"
    }
    
    /// Gets the next group that can be unlocked
    /// - Returns: Name of the next group to unlock, or nil if all unlocked
    private func getNextUnlockGroup() -> String? {
        let sortedGroups = groupUnlockRequirements.sorted { $0.value < $1.value }
        let currentTotalStars = getTotalStars()
        
        for (groupName, requiredStars) in sortedGroups {
            if currentTotalStars < requiredStars {
                return groupName
            }
        }
        
        return nil
    }
    
    // MARK: - Data Management
    
    /// Resets all unlocked characters to the default state
    func resetProgress() {
        unlockedCharacters = ["あ", "い", "う", "え", "お"]
        saveUnlockedCharacters()
    }
    
    /// Gets total stars from external provider or UserDefaults fallback
    /// - Returns: Total star count
    private func getTotalStars() -> Int {
        if let provider = totalStarsProvider { 
            return provider() 
        }
        // Fallback to UserDefaults for backward compatibility
        return UserDefaults.standard.integer(forKey: "LevelProgression_TotalStars")
    }
    
    // MARK: - Persistence
    
    /// Saves unlocked characters to persistent storage
    private func saveUnlockedCharacters() {
        UserDefaults.standard.set(Array(unlockedCharacters), forKey: "CharacterUnlock_UnlockedCharacters")
    }
    
    /// Loads unlocked characters from persistent storage
    private func loadUnlockedCharacters() {
        if let characters = UserDefaults.standard.array(forKey: "CharacterUnlock_UnlockedCharacters") as? [String] {
            unlockedCharacters = Set(characters)
        } else {
            // Migrate from old key if exists
            if let oldCharacters = UserDefaults.standard.array(forKey: "StarUnlock_UnlockedCharacters") as? [String] {
                unlockedCharacters = Set(oldCharacters)
                saveUnlockedCharacters() // Save to new key
            } else {
                unlockedCharacters = ["あ", "い", "う", "え", "お"] // Default
            }
        }
    }
}