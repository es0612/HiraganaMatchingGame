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
        self.soundFileName = "\(character).mp3"
    }
}

class HiraganaDataManager {
    static let shared = HiraganaDataManager()
    
    private init() {}
    
    private let allHiraganaData: [HiraganaItem] = [
        HiraganaItem(character: "あ", imageName: "ant", category: "animal"),
        HiraganaItem(character: "い", imageName: "dog", category: "animal"),
        HiraganaItem(character: "う", imageName: "rabbit", category: "animal"),
        HiraganaItem(character: "え", imageName: "shrimp", category: "animal"),
        HiraganaItem(character: "お", imageName: "demon", category: "character"),
        
        HiraganaItem(character: "か", imageName: "crab", category: "animal"),
        HiraganaItem(character: "き", imageName: "giraffe", category: "animal"),
        HiraganaItem(character: "く", imageName: "bear", category: "animal"),
        HiraganaItem(character: "け", imageName: "cake", category: "food"),
        HiraganaItem(character: "こ", imageName: "top", category: "toy"),
        
        HiraganaItem(character: "さ", imageName: "monkey", category: "animal"),
        HiraganaItem(character: "し", imageName: "deer", category: "animal"),
        HiraganaItem(character: "す", imageName: "watermelon", category: "food"),
        HiraganaItem(character: "せ", imageName: "cicada", category: "animal"),
        HiraganaItem(character: "そ", imageName: "sky", category: "nature"),
        
        HiraganaItem(character: "た", imageName: "octopus", category: "animal"),
        HiraganaItem(character: "ち", imageName: "butterfly", category: "animal"),
        HiraganaItem(character: "つ", imageName: "crane", category: "animal"),
        HiraganaItem(character: "て", imageName: "hand", category: "body"),
        HiraganaItem(character: "と", imageName: "clock", category: "object"),
        
        HiraganaItem(character: "な", imageName: "eggplant", category: "food"),
        HiraganaItem(character: "に", imageName: "carrot", category: "food"),
        HiraganaItem(character: "ぬ", imageName: "doll", category: "toy"),
        HiraganaItem(character: "ね", imageName: "cat", category: "animal"),
        HiraganaItem(character: "の", imageName: "field", category: "nature"),
        
        HiraganaItem(character: "は", imageName: "flower", category: "nature"),
        HiraganaItem(character: "ひ", imageName: "chick", category: "animal"),
        HiraganaItem(character: "ふ", imageName: "boat", category: "vehicle"),
        HiraganaItem(character: "へ", imageName: "snake", category: "animal"),
        HiraganaItem(character: "ほ", imageName: "bone", category: "object"),
        
        HiraganaItem(character: "ま", imageName: "bean", category: "food"),
        HiraganaItem(character: "み", imageName: "ear", category: "body"),
        HiraganaItem(character: "む", imageName: "bug", category: "animal"),
        HiraganaItem(character: "め", imageName: "eye", category: "body"),
        HiraganaItem(character: "も", imageName: "peach", category: "food"),
        
        HiraganaItem(character: "や", imageName: "arrow", category: "object"),
        HiraganaItem(character: "ゆ", imageName: "hot_water", category: "object"),
        HiraganaItem(character: "よ", imageName: "night", category: "nature"),
        
        HiraganaItem(character: "ら", imageName: "trumpet", category: "instrument"),
        HiraganaItem(character: "り", imageName: "apple", category: "food"),
        HiraganaItem(character: "る", imageName: "loop", category: "object"),
        HiraganaItem(character: "れ", imageName: "refrigerator", category: "appliance"),
        HiraganaItem(character: "ろ", imageName: "candle", category: "object"),
        
        HiraganaItem(character: "わ", imageName: "ring", category: "object"),
        HiraganaItem(character: "を", imageName: "man", category: "character"),
        HiraganaItem(character: "ん", imageName: "antenna", category: "object")
    ]
    
    func getHiraganaForLevel(_ level: Int) -> [HiraganaItem] {
        let rows = ["あいうえお", "かきくけこ", "さしすせそ", "たちつてと", "なにぬねの", 
                   "はひふへほ", "まみむめも", "やゆよ", "らりるれろ", "わをん"]
        
        guard level > 0 && level <= rows.count else { return [] }
        
        var characters: [String] = []
        for i in 0..<level {
            characters.append(contentsOf: Array(rows[i]).map(String.init))
        }
        
        return allHiraganaData.filter { characters.contains($0.character) }
    }
    
    func getRandomChoices(for hiragana: String, count: Int = 3) -> [HiraganaItem] {
        let correctItem = allHiraganaData.first { $0.character == hiragana }
        guard let correct = correctItem else { return [] }
        
        let wrongChoices = allHiraganaData.filter { $0.character != hiragana }
            .shuffled()
            .prefix(count - 1)
        
        var choices = Array(wrongChoices)
        choices.append(correct)
        
        return choices.shuffled()
    }
    
    func getAllCharacters() -> [String] {
        return allHiraganaData.map { $0.character }
    }
    
    func getItem(for character: String) -> HiraganaItem? {
        return allHiraganaData.first { $0.character == character }
    }
    
    func getLevelConfiguration() -> [Int: [String]] {
        return [
            1: ["あ", "い", "う", "え", "お"],
            2: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ"],
            3: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ"],
            4: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と"],
            5: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の"],
            6: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ"],
            7: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も"],
            8: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ"],
            9: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ"],
            10: ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ", "わ", "を", "ん"]
        ]
    }
}