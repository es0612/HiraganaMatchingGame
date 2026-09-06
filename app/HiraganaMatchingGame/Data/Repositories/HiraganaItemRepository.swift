import Foundation

/// Repository responsible for managing hiragana item data and game progression
final class HiraganaItemRepository {
    static let shared = HiraganaItemRepository()
    
    private init() {}
    
    /// All available hiragana items with their associated images and categories
    private let allHiraganaData: [HiraganaItem] = [
        // あ行 - 各文字に複数の選択肢を追加
        HiraganaItem(character: "あ", imageName: "ant", category: "animal"),
        HiraganaItem(character: "あ", imageName: "duck", category: "animal"), // あひる
        HiraganaItem(character: "あ", imageName: "rain", category: "weather"), // あめ
        HiraganaItem(character: "あ", imageName: "red", category: "color"), // あか
        
        HiraganaItem(character: "い", imageName: "dog", category: "animal"),
        HiraganaItem(character: "い", imageName: "strawberry", category: "food"), // いちご
        HiraganaItem(character: "い", imageName: "chair", category: "furniture"), // いす
        HiraganaItem(character: "い", imageName: "house", category: "building"), // いえ
        
        HiraganaItem(character: "う", imageName: "rabbit", category: "animal"),
        HiraganaItem(character: "う", imageName: "horse", category: "animal"), // うま
        HiraganaItem(character: "う", imageName: "sea", category: "nature"), // うみ
        HiraganaItem(character: "う", imageName: "song", category: "music"), // うた
        
        HiraganaItem(character: "え", imageName: "shrimp", category: "animal"),
        HiraganaItem(character: "え", imageName: "station", category: "building"), // えき
        HiraganaItem(character: "え", imageName: "picture", category: "object"), // え
        HiraganaItem(character: "え", imageName: "pencil", category: "tool"), // えんぴつ
        
        HiraganaItem(character: "お", imageName: "demon", category: "character"),
        HiraganaItem(character: "お", imageName: "king", category: "character"), // おう
        HiraganaItem(character: "お", imageName: "mother", category: "character"), // おかあさん
        HiraganaItem(character: "お", imageName: "tea", category: "drink"), // おちゃ
        
        // か行
        HiraganaItem(character: "か", imageName: "crab", category: "animal"),
        HiraganaItem(character: "か", imageName: "turtle", category: "animal"), // かめ
        HiraganaItem(character: "か", imageName: "bag", category: "object"), // かばん
        HiraganaItem(character: "か", imageName: "key", category: "tool"), // かぎ
        
        HiraganaItem(character: "き", imageName: "giraffe", category: "animal"),
        HiraganaItem(character: "き", imageName: "tree", category: "nature"), // き
        HiraganaItem(character: "き", imageName: "train", category: "vehicle"), // きしゃ
        HiraganaItem(character: "き", imageName: "mushroom", category: "food"), // きのこ
        
        HiraganaItem(character: "く", imageName: "bear", category: "animal"),
        HiraganaItem(character: "く", imageName: "car", category: "vehicle"), // くるま
        HiraganaItem(character: "く", imageName: "cloud", category: "weather"), // くも
        HiraganaItem(character: "く", imageName: "fruit", category: "food"), // くだもの
        
        HiraganaItem(character: "け", imageName: "cake", category: "food"),
        HiraganaItem(character: "け", imageName: "frog", category: "animal"), // けろ
        HiraganaItem(character: "け", imageName: "game", category: "toy"), // げーむ
        HiraganaItem(character: "け", imageName: "smoke", category: "weather"), // けむり
        
        HiraganaItem(character: "こ", imageName: "top", category: "toy"),
        HiraganaItem(character: "こ", imageName: "child", category: "character"), // こども
        HiraganaItem(character: "こ", imageName: "heart", category: "concept"), // こころ
        HiraganaItem(character: "こ", imageName: "ice", category: "weather"), // こおり
        
        // さ行
        HiraganaItem(character: "さ", imageName: "monkey", category: "animal"),
        HiraganaItem(character: "さ", imageName: "fish", category: "animal"), // さかな
        HiraganaItem(character: "さ", imageName: "cherry", category: "food"), // さくら
        HiraganaItem(character: "さ", imageName: "desert", category: "nature"), // さばく
        
        HiraganaItem(character: "し", imageName: "deer", category: "animal"),
        HiraganaItem(character: "し", imageName: "lion", category: "animal"), // しし
        HiraganaItem(character: "し", imageName: "salt", category: "food"), // しお
        HiraganaItem(character: "し", imageName: "newspaper", category: "object"), // しんぶん
        
        HiraganaItem(character: "す", imageName: "watermelon", category: "food"),
        HiraganaItem(character: "す", imageName: "sparrow", category: "animal"), // すずめ
        HiraganaItem(character: "す", imageName: "nest", category: "nature"), // す
        HiraganaItem(character: "す", imageName: "sand", category: "nature"), // すな
        
        HiraganaItem(character: "せ", imageName: "cicada", category: "animal"),
        HiraganaItem(character: "せ", imageName: "world", category: "concept"), // せかい
        HiraganaItem(character: "せ", imageName: "soap", category: "object"), // せっけん
        HiraganaItem(character: "せ", imageName: "back", category: "body"), // せなか
        
        HiraganaItem(character: "そ", imageName: "sky", category: "nature"),
        HiraganaItem(character: "そ", imageName: "socks", category: "clothing"), // そっくす
        HiraganaItem(character: "そ", imageName: "outside", category: "concept"), // そと
        HiraganaItem(character: "そ", imageName: "sleeve", category: "clothing"), // そで
        
        // た行
        HiraganaItem(character: "た", imageName: "octopus", category: "animal"),
        HiraganaItem(character: "た", imageName: "egg", category: "food"), // たまご
        HiraganaItem(character: "た", imageName: "tower", category: "building"), // たてもの
        HiraganaItem(character: "た", imageName: "bamboo", category: "nature"), // たけ
        
        HiraganaItem(character: "ち", imageName: "butterfly", category: "animal"),
        HiraganaItem(character: "ち", imageName: "cheese", category: "food"), // ちーず
        HiraganaItem(character: "ち", imageName: "map", category: "object"), // ちず
        HiraganaItem(character: "ち", imageName: "bird", category: "animal"), // ちどり
        
        HiraganaItem(character: "つ", imageName: "crane", category: "animal"),
        HiraganaItem(character: "つ", imageName: "moon", category: "nature"), // つき
        HiraganaItem(character: "つ", imageName: "desk", category: "furniture"), // つくえ
        HiraganaItem(character: "つ", imageName: "fishing", category: "activity"), // つり
        
        HiraganaItem(character: "て", imageName: "hand", category: "body"),
        HiraganaItem(character: "て", imageName: "letter", category: "object"), // てがみ
        HiraganaItem(character: "て", imageName: "tent", category: "object"), // てんと
        HiraganaItem(character: "て", imageName: "television", category: "electronics"), // てれび
        
        HiraganaItem(character: "と", imageName: "clock", category: "object"),
        HiraganaItem(character: "と", imageName: "tiger", category: "animal"), // とら
        HiraganaItem(character: "と", imageName: "door", category: "object"), // とびら
        HiraganaItem(character: "と", imageName: "tomato", category: "food"), // とまと
        
        // な行
        HiraganaItem(character: "な", imageName: "eggplant", category: "food"),
        HiraganaItem(character: "な", imageName: "wave", category: "nature"), // なみ
        HiraganaItem(character: "な", imageName: "name", category: "concept"), // なまえ
        HiraganaItem(character: "な", imageName: "summer", category: "weather"), // なつ
        
        HiraganaItem(character: "に", imageName: "carrot", category: "food"),
        HiraganaItem(character: "に", imageName: "rainbow", category: "weather"), // にじ
        HiraganaItem(character: "に", imageName: "garden", category: "nature"), // にわ
        HiraganaItem(character: "に", imageName: "meat", category: "food"), // にく
        
        HiraganaItem(character: "ぬ", imageName: "doll", category: "toy"),
        HiraganaItem(character: "ぬ", imageName: "cloth", category: "material"), // ぬの
        HiraganaItem(character: "ぬ", imageName: "mud", category: "nature"), // ぬま
        HiraganaItem(character: "ぬ", imageName: "paint", category: "activity"), // ぬりえ
        
        HiraganaItem(character: "ね", imageName: "cat", category: "animal"),
        HiraganaItem(character: "ね", imageName: "mouse", category: "animal"), // ねずみ
        HiraganaItem(character: "ね", imageName: "sleep", category: "activity"), // ねる
        HiraganaItem(character: "ね", imageName: "tie", category: "clothing"), // ねくたい
        
        HiraganaItem(character: "の", imageName: "field", category: "nature"),
        HiraganaItem(character: "の", imageName: "drink", category: "activity"), // のむ
        HiraganaItem(character: "の", imageName: "seaweed", category: "food"), // のり
        HiraganaItem(character: "の", imageName: "notebook", category: "object"), // のーと
        
        // は行
        HiraganaItem(character: "は", imageName: "flower", category: "nature"),
        HiraganaItem(character: "は", imageName: "brush", category: "tool"), // はけ
        HiraganaItem(character: "は", imageName: "box", category: "object"), // はこ
        HiraganaItem(character: "は", imageName: "scissors", category: "tool"), // はさみ
        
        HiraganaItem(character: "ひ", imageName: "chick", category: "animal"),
        HiraganaItem(character: "ひ", imageName: "fire", category: "element"), // ひ
        HiraganaItem(character: "ひ", imageName: "sun", category: "nature"), // ひ
        HiraganaItem(character: "ひ", imageName: "sheep", category: "animal"), // ひつじ
        
        HiraganaItem(character: "ふ", imageName: "boat", category: "vehicle"),
        HiraganaItem(character: "ふ", imageName: "envelope", category: "object"), // ふうとう
        HiraganaItem(character: "ふ", imageName: "winter", category: "weather"), // ふゆ
        HiraganaItem(character: "ふ", imageName: "futon", category: "furniture"), // ふとん
        
        HiraganaItem(character: "へ", imageName: "snake", category: "animal"),
        HiraganaItem(character: "へ", imageName: "helmet", category: "clothing"), // へるめっと
        HiraganaItem(character: "へ", imageName: "room", category: "building"), // へや
        HiraganaItem(character: "へ", imageName: "wall", category: "building"), // へい
        
        HiraganaItem(character: "ほ", imageName: "bone", category: "body"),
        HiraganaItem(character: "ほ", imageName: "book", category: "object"), // ほん
        HiraganaItem(character: "ほ", imageName: "star", category: "nature"), // ほし
        HiraganaItem(character: "ほ", imageName: "cheek", category: "body"), // ほほ
        
        // ま行
        HiraganaItem(character: "ま", imageName: "bean", category: "food"),
        HiraganaItem(character: "ま", imageName: "window", category: "object"), // まど
        HiraganaItem(character: "ま", imageName: "pillow", category: "furniture"), // まくら
        HiraganaItem(character: "ま", imageName: "circle", category: "shape"), // まる
        
        HiraganaItem(character: "み", imageName: "ear", category: "body"),
        HiraganaItem(character: "み", imageName: "water", category: "element"), // みず
        HiraganaItem(character: "み", imageName: "road", category: "building"), // みち
        HiraganaItem(character: "み", imageName: "green", category: "color"), // みどり
        
        HiraganaItem(character: "む", imageName: "bug", category: "animal"),
        HiraganaItem(character: "む", imageName: "purple", category: "color"), // むらさき
        HiraganaItem(character: "む", imageName: "village", category: "building"), // むら
        HiraganaItem(character: "む", imageName: "chest", category: "body"), // むね
        
        HiraganaItem(character: "め", imageName: "eye", category: "body"),
        HiraganaItem(character: "め", imageName: "glasses", category: "object"), // めがね
        HiraganaItem(character: "め", imageName: "noodles", category: "food"), // めん
        HiraganaItem(character: "め", imageName: "female", category: "character"), // めす
        
        HiraganaItem(character: "も", imageName: "peach", category: "food"),
        HiraganaItem(character: "も", imageName: "forest", category: "nature"), // もり
        HiraganaItem(character: "も", imageName: "thing", category: "concept"), // もの
        HiraganaItem(character: "も", imageName: "rice_cake", category: "food"), // もち
        
        // や行
        HiraganaItem(character: "や", imageName: "arrow", category: "tool"),
        HiraganaItem(character: "や", imageName: "roof", category: "building"), // やね
        HiraganaItem(character: "や", imageName: "vegetable", category: "food"), // やさい
        HiraganaItem(character: "や", imageName: "mountain", category: "nature"), // やま
        
        HiraganaItem(character: "ゆ", imageName: "hot_water", category: "element"),
        HiraganaItem(character: "ゆ", imageName: "snow", category: "weather"), // ゆき
        HiraganaItem(character: "ゆ", imageName: "finger", category: "body"), // ゆび
        HiraganaItem(character: "ゆ", imageName: "dream", category: "concept"), // ゆめ
        
        HiraganaItem(character: "よ", imageName: "night", category: "time"),
        HiraganaItem(character: "よ", imageName: "four", category: "number"), // よん
        HiraganaItem(character: "よ", imageName: "world2", category: "concept"), // よのなか
        HiraganaItem(character: "よ", imageName: "good", category: "concept"), // よい
        
        // ら行
        HiraganaItem(character: "ら", imageName: "trumpet", category: "music"),
        HiraganaItem(character: "ら", imageName: "radio", category: "electronics"), // らじお
        HiraganaItem(character: "ら", imageName: "lion2", category: "animal"), // らいおん
        HiraganaItem(character: "ら", imageName: "ramen", category: "food"), // らーめん
        
        HiraganaItem(character: "り", imageName: "apple", category: "food"),
        HiraganaItem(character: "り", imageName: "squirrel", category: "animal"), // りす
        HiraganaItem(character: "り", imageName: "ribbon", category: "object"), // りぼん
        HiraganaItem(character: "り", imageName: "reason", category: "concept"), // りゆう
        
        HiraganaItem(character: "る", imageName: "loop", category: "shape"),
        HiraganaItem(character: "る", imageName: "ruby", category: "object"), // るびー
        HiraganaItem(character: "る", imageName: "route", category: "concept"), // るーと
        HiraganaItem(character: "る", imageName: "ruler", category: "tool"), // るーらー
        
        HiraganaItem(character: "れ", imageName: "refrigerator", category: "electronics"),
        HiraganaItem(character: "れ", imageName: "lemon", category: "food"), // れもん
        HiraganaItem(character: "れ", imageName: "train2", category: "vehicle"), // れっしゃ
        HiraganaItem(character: "れ", imageName: "lettuce", category: "food"), // れたす
        
        HiraganaItem(character: "ろ", imageName: "candle", category: "object"),
        HiraganaItem(character: "ろ", imageName: "robot", category: "machine"), // ろぼっと
        HiraganaItem(character: "ろ", imageName: "rocket", category: "vehicle"), // ろけっと
        HiraganaItem(character: "ろ", imageName: "rope", category: "tool"), // ろーぷ
        
        // わ行
        HiraganaItem(character: "わ", imageName: "ring", category: "object"),
        HiraganaItem(character: "ゐ", imageName: "wi", category: "character"), // ゐ
        HiraganaItem(character: "ゑ", imageName: "we", category: "character"), // ゑ
        HiraganaItem(character: "わ", imageName: "cotton", category: "material"), // わた
        HiraganaItem(character: "わ", imageName: "young", category: "concept"), // わかい
        HiraganaItem(character: "わ", imageName: "japanese", category: "concept"), // わふう
        
        HiraganaItem(character: "を", imageName: "man", category: "character"), // をとこ
        HiraganaItem(character: "を", imageName: "dance", category: "activity"), // をどり
        HiraganaItem(character: "を", imageName: "woman", category: "character"), // をんな
        
        HiraganaItem(character: "ん", imageName: "antenna", category: "object"), // あんてな
        HiraganaItem(character: "ん", imageName: "bread", category: "food"), // ぱん
        HiraganaItem(character: "ん", imageName: "engine", category: "machine"), // えんじん
        HiraganaItem(character: "ん", imageName: "pen", category: "tool") // ぺん
    ]
    
    /// Character to reading mappings for each hiragana
    private let readingMap: [String: String] = [
        // あ行
        "あ": "あり", "い": "いぬ", "う": "うさぎ", "え": "えび", "お": "おに",
        
        // か行
        "か": "かに", "き": "きりん", "く": "くま", "け": "けーき", "こ": "こま",
        
        // さ行
        "さ": "さる", "し": "しか", "す": "すいか", "せ": "せみ", "そ": "そら",
        
        // た行
        "た": "たこ", "ち": "ちょう", "つ": "つる", "て": "て", "と": "とけい",
        
        // な行
        "な": "なす", "に": "にんじん", "ぬ": "ぬいぐるみ", "ね": "ねこ", "の": "のはら",
        
        // は行
        "は": "はな", "ひ": "ひよこ", "ふ": "ふね", "へ": "へび", "ほ": "ほね",
        
        // ま行
        "ま": "まめ", "み": "みみ", "む": "むし", "め": "め", "も": "もも",
        
        // や行
        "や": "やじるし", "ゆ": "ゆ", "よ": "よる",
        
        // ら行
        "ら": "らっぱ", "り": "りんご", "る": "るーぷ", "れ": "れいぞうこ", "ろ": "ろうそく",
        
        // わ行
        "わ": "わ", "ゐ": "ゐ", "ゑ": "ゑ", "を": "をとこ", "ん": "あんてな"
    ]
    
    /// Gets all hiragana items
    /// - Returns: Array of all available hiragana items
    func getAllHiraganaData() -> [HiraganaItem] {
        allHiraganaData
    }
    
    /// Gets hiragana items for a specific level
    /// - Parameter level: The level number (1-10)
    /// - Returns: Array of hiragana items available for that level
    func getHiraganaForLevel(_ level: Int) -> [HiraganaItem] {
        let rows = ["あいうえお", "かきくけこ", "さしすせそ", "たちつてと", "なにぬねの",
                    "はひふへほ", "まみむめも", "やゆよ", "らりるれろ", "わをん"]
        
        guard level > 0 && level <= rows.count else { return [] }
        
        var characters: [String] = []
        for i in 0 ..< level {
            characters.append(contentsOf: Array(rows[i]).map(String.init))
        }
        
        return allHiraganaData.filter { characters.contains($0.character) }
    }
    
    /// Gets all possible question variations for a hiragana character
    /// - Parameter hiragana: The hiragana character
    /// - Returns: Array of all hiragana items with that character
    func getQuestionVariations(for hiragana: String) -> [HiraganaItem] {
        allHiraganaData.filter { $0.character == hiragana }
    }
    
    /// Gets the first item for a specific character (for consistency)
    /// - Parameter character: The hiragana character
    /// - Returns: The first hiragana item with that character, or nil
    func getItem(for character: String) -> HiraganaItem? {
        allHiraganaData.first { $0.character == character }
    }
    
    /// Gets all unique characters available in the repository
    /// - Returns: Array of unique hiragana characters
    func getAllCharacters() -> [String] {
        Array(Set(allHiraganaData.map { $0.character }))
    }
    
    /// Gets reading text for a hiragana character
    /// - Parameter character: The hiragana character
    /// - Returns: The reading text, or the character itself if not found
    func getReadingForCharacter(_ character: String) -> String {
        readingMap[character] ?? character
    }
    
    /// Gets random choices for a game question
    /// - Parameters:
    ///   - hiragana: The correct hiragana character
    ///   - count: Number of choices to generate (default 3)
    /// - Returns: Array of shuffled hiragana items including the correct answer
    func getRandomChoices(for hiragana: String, count: Int = 3) -> [HiraganaItem] {
        // 指定されたひらがなの最初の選択肢を正解として使用（一貫性を保つため）
        let correctItems = allHiraganaData.filter { $0.character == hiragana }
        guard let correct = correctItems.first else { return [] }
        
        let wrongChoices = allHiraganaData.filter { $0.character != hiragana }
            .shuffled()
            .prefix(count - 1)
        
        var choices = Array(wrongChoices)
        choices.append(correct)
        
        return choices.shuffled()
    }
    
    /// Gets random choices with a specific correct answer
    /// - Parameters:
    ///   - correctAnswer: The specific correct hiragana item to use
    ///   - count: Number of choices to generate (default 3)
    /// - Returns: Array of shuffled hiragana items including the specified correct answer
    func getRandomChoicesWithCorrectAnswer(_ correctAnswer: HiraganaItem, count: Int = 3) -> [HiraganaItem] {
        let wrongChoices = allHiraganaData.filter { $0.character != correctAnswer.character }
            .shuffled()
            .prefix(count - 1)
        
        var choices = Array(wrongChoices)
        choices.append(correctAnswer)
        
        return choices.shuffled()
    }
}
