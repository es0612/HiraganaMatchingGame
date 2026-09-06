import Foundation

/// Repository responsible for managing image name to emoji mappings
final class EmojiRepository {
    static let shared = EmojiRepository()
    
    private init() {}
    
    /// Maps image names to their corresponding emoji representations
    private let emojiMap: [String: String] = [
        // あ行
        "ant": "🐜", "duck": "🦆", "rain": "🌧️", "red": "🔴",
        "dog": "🐶", "strawberry": "🍓", "chair": "🪑", "house": "🏠",
        "rabbit": "🐰", "horse": "🐴", "sea": "🌊", "song": "🎵",
        "shrimp": "🦐", "station": "🚉", "picture": "🖼️", "pencil": "✏️",
        "demon": "👹", "king": "👑", "mother": "👩", "tea": "🍵",
        
        // か行
        "crab": "🦀", "turtle": "🐢", "bag": "👜", "key": "🔑",
        "giraffe": "🦒", "tree": "🌳", "train": "🚂", "mushroom": "🍄",
        "bear": "🐻", "car": "🚗", "cloud": "☁️", "fruit": "🍇",
        "cake": "🍰", "frog": "🐸", "game": "🎮", "smoke": "💨",
        "top": "🌀", "child": "👶", "heart": "❤️", "ice": "🧊",
        
        // さ行
        "monkey": "🐒", "fish": "🐟", "cherry": "🍒", "desert": "🏜️",
        "deer": "🦌", "lion": "🦁", "salt": "🧂", "newspaper": "📰",
        "watermelon": "🍉", "sparrow": "🐦", "nest": "🪹", "sand": "🏖️",
        "cicada": "🦗", "world": "🌍", "soap": "🧼", "back": "↩️",
        "sky": "🌌", "socks": "🧦", "outside": "🌲", "sleeve": "👕",
        
        // た行
        "octopus": "🐙", "egg": "🥚", "tower": "🗼", "bamboo": "🎋",
        "butterfly": "🦋", "cheese": "🧀", "map": "🗺️", "bird": "🐦",
        "crane": "🦩", "moon": "🌙", "desk": "🪑", "fishing": "🎣",
        "hand": "✋", "letter": "✉️", "tent": "⛺", "television": "📺",
        "clock": "⏰", "tiger": "🐅", "door": "🚪", "tomato": "🍅",
        
        // な行
        "eggplant": "🍆", "wave": "🌊", "name": "📛", "summer": "☀️",
        "carrot": "🥕", "rainbow": "🌈", "garden": "🏡", "meat": "🥩",
        "doll": "🪆", "cloth": "🧵", "mud": "🪨", "paint": "🎨",
        "cat": "🐱", "mouse": "🐭", "sleep": "😴", "tie": "👔",
        "field": "🌾", "drink": "🥤", "seaweed": "🌿", "notebook": "📓",
        
        // は行
        "flower": "🌸", "brush": "🖌️", "box": "📦", "scissors": "✂️",
        "chick": "🐤", "fire": "🔥", "sun": "☀️", "sheep": "🐑",
        "boat": "🚤", "envelope": "✉️", "winter": "❄️", "futon": "🛏️",
        "snake": "🐍", "helmet": "⛑️", "room": "🏠", "wall": "🧱",
        "bone": "🦴", "book": "📖", "star": "⭐", "cheek": "😊",
        
        // ま行
        "bean": "🫘", "window": "🪟", "pillow": "🛏️", "circle": "⭕",
        "ear": "👂", "water": "💧", "road": "🛣️", "green": "💚",
        "bug": "🐛", "purple": "💜", "village": "🏘️", "chest": "📦",
        "eye": "👁️", "glasses": "👓", "noodles": "🍜", "female": "👩",
        "peach": "🍑", "forest": "🌲", "thing": "📦", "rice_cake": "🍡",
        
        // や行
        "arrow": "➡️", "roof": "🏠", "vegetable": "🥬", "mountain": "⛰️",
        "hot_water": "♨️", "snow": "❄️", "finger": "👉", "dream": "💭",
        "night": "🌙", "four": "4️⃣", "world2": "🌏", "good": "👍",
        
        // ら行
        "trumpet": "🎺", "radio": "📻", "lion2": "🦁", "ramen": "🍜",
        "apple": "🍎", "squirrel": "🐿️", "ribbon": "🎀", "reason": "💭",
        "loop": "🔄", "ruby": "💎", "route": "🛣️", "ruler": "📏",
        "refrigerator": "🧊", "lemon": "🍋", "train2": "🚆", "lettuce": "🥬",
        "candle": "🕯️", "robot": "🤖", "rocket": "🚀", "rope": "🪢",
        
        // わ行
        "ring": "💍", "cotton": "☁️", "young": "👶", "japanese": "🇯🇵",
        "man": "👨", "dance": "💃", "woman": "👩", "antenna": "📡",
        "bread": "🍞", "engine": "⚙️", "pen": "🖊️"
    ]
    
    /// Gets the emoji representation for the given image name
    /// - Parameter imageName: The image name to look up
    /// - Returns: The corresponding emoji, or "❓" if not found
    func getEmojiForImageName(_ imageName: String) -> String {
        emojiMap[imageName] ?? "❓"
    }
    
    /// Gets all available image names that have emoji mappings
    /// - Returns: Array of all image names with emoji representations
    func getAllImageNames() -> [String] {
        Array(emojiMap.keys)
    }
    
    /// Gets all available emojis
    /// - Returns: Array of all emoji representations
    func getAllEmojis() -> [String] {
        Array(emojiMap.values)
    }
    
    /// Gets all emoji mappings
    /// - Returns: Dictionary containing all image name to emoji mappings
    func getAllMappings() -> [String: String] {
        emojiMap
    }
    
    /// Checks if an emoji mapping exists for the given image name
    /// - Parameter imageName: The image name to check
    /// - Returns: True if mapping exists, false otherwise
    func hasEmojiMapping(for imageName: String) -> Bool {
        emojiMap[imageName] != nil
    }
}
