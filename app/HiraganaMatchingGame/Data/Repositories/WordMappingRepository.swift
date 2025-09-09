import Foundation

/// Repository responsible for managing image name to Japanese word mappings
final class WordMappingRepository {
    static let shared = WordMappingRepository()
    
    private init() {}
    
    /// Maps image names to their corresponding Japanese words
    private let imageNameToJapaneseWord: [String: String] = [
        // あ行の追加
        "ant": "ありさん",
        "duck": "あひる",
        "rain": "あめ",
        "red": "あか",
        "dog": "いぬ",
        "strawberry": "いちご",
        "chair": "いす",
        "house": "いえ",
        "rabbit": "うさぎ",
        "horse": "うま",
        "sea": "うみ",
        "song": "うた",
        "shrimp": "えび",
        "station": "えき",
        "picture": "え",
        "pencil": "えんぴつ",
        "demon": "おに",
        "king": "おう",
        "mother": "おかあさん",
        "tea": "おちゃ",
        
        // か行の追加
        "crab": "かに",
        "turtle": "かめ",
        "bag": "かばん",
        "key": "かぎ",
        "giraffe": "きりん",
        "tree": "き",
        "train": "きしゃ",
        "mushroom": "きのこ",
        "bear": "くま",
        "car": "くるま",
        "cloud": "くも",
        "fruit": "くだもの",
        "cake": "けーき",
        "frog": "けろ",
        "game": "げーむ",
        "smoke": "けむり",
        "top": "こま",
        "child": "こども",
        "heart": "こころ",
        "ice": "こおり",
        
        // さ行の追加
        "monkey": "さる",
        "fish": "さかな",
        "cherry": "さくら",
        "desert": "さばく",
        "deer": "しか",
        "lion": "しし",
        "salt": "しお",
        "newspaper": "しんぶん",
        "watermelon": "すいか",
        "sparrow": "すずめ",
        "nest": "す",
        "sand": "すな",
        "cicada": "せみ",
        "world": "せかい",
        "soap": "せっけん",
        "back": "せなか",
        "sky": "そら",
        "socks": "そっくす",
        "outside": "そと",
        "sleeve": "そで",
        
        // た行の追加
        "octopus": "たこ",
        "egg": "たまご",
        "tower": "たてもの",
        "bamboo": "たけ",
        "butterfly": "ちょう",
        "cheese": "ちーず",
        "map": "ちず",
        "bird": "ちどり",
        "crane": "つる",
        "moon": "つき",
        "desk": "つくえ",
        "fishing": "つり",
        "hand": "て",
        "letter": "てがみ",
        "tent": "てんと",
        "television": "てれび",
        "clock": "とけい",
        "tiger": "とら",
        "door": "とびら",
        "tomato": "とまと",
        
        // な行の追加
        "eggplant": "なす",
        "wave": "なみ",
        "name": "なまえ",
        "summer": "なつ",
        "carrot": "にんじん",
        "rainbow": "にじ",
        "garden": "にわ",
        "meat": "にく",
        "doll": "ぬいぐるみ",
        "cloth": "ぬの",
        "mud": "ぬま",
        "paint": "ぬりえ",
        "cat": "ねこ",
        "mouse": "ねずみ",
        "sleep": "ねる",
        "tie": "ねくたい",
        "field": "のはら",
        "drink": "のむ",
        "seaweed": "のり",
        "notebook": "のーと",
        
        // は行の追加
        "flower": "はな",
        "brush": "はけ",
        "box": "はこ",
        "scissors": "はさみ",
        "chick": "ひよこ",
        "fire": "ひ",
        "sun": "ひ",
        "sheep": "ひつじ",
        "boat": "ふね",
        "envelope": "ふうとう",
        "winter": "ふゆ",
        "futon": "ふとん",
        "snake": "へび",
        "helmet": "へるめっと",
        "room": "へや",
        "wall": "へい",
        "bone": "ほね",
        "book": "ほん",
        "star": "ほし",
        "cheek": "ほほ",
        
        // ま行の追加
        "bean": "まめ",
        "window": "まど",
        "pillow": "まくら",
        "circle": "まる",
        "ear": "みみ",
        "water": "みず",
        "road": "みち",
        "green": "みどり",
        "bug": "むし",
        "purple": "むらさき",
        "village": "むら",
        "chest": "むね",
        "eye": "め",
        "glasses": "めがね",
        "noodles": "めん",
        "female": "めす",
        "peach": "もも",
        "forest": "もり",
        "thing": "もの",
        "rice_cake": "もち",
        
        // や行の追加
        "arrow": "や",
        "roof": "やね",
        "vegetable": "やさい",
        "mountain": "やま",
        "hot_water": "ゆ",
        "snow": "ゆき",
        "finger": "ゆび",
        "dream": "ゆめ",
        "night": "よる",
        "four": "よん",
        "world2": "よのなか",
        "good": "よい",
        
        // ら行の追加
        "trumpet": "らっぱ",
        "radio": "らじお",
        "lion2": "らいおん",
        "ramen": "らーめん",
        "apple": "りんご",
        "squirrel": "りす",
        "ribbon": "りぼん",
        "reason": "りゆう",
        "loop": "る",
        "ruby": "るびー",
        "route": "るーと",
        "ruler": "るーらー",
        "refrigerator": "れいぞうこ",
        "lemon": "れもん",
        "train2": "れっしゃ",
        "lettuce": "れたす",
        "candle": "ろうそく",
        "robot": "ろぼっと",
        "rocket": "ろけっと",
        "rope": "ろーぷ",
        
        // わ行の追加
        "ring": "わ",
        "wi": "ゐ",
        "we": "ゑ",
        "cotton": "わた",
        "young": "わかい",
        "japanese": "わふう",
        "man": "おとこ",
        "dance": "をどり",
        "woman": "をんな",
        "antenna": "あんてな",
        "bread": "ぱん",
        "engine": "えんじん",
        "pen": "ぺん"
    ]
    
    /// Gets the Japanese word for the given image name
    /// - Parameter imageName: The image name to look up
    /// - Returns: The corresponding Japanese word, or nil if not found
    func getJapaneseWord(for imageName: String) -> String? {
        return imageNameToJapaneseWord[imageName]
    }
    
    /// Gets all available image names
    /// - Returns: Array of all image names in the mapping
    func getAllImageNames() -> [String] {
        return Array(imageNameToJapaneseWord.keys)
    }
    
    /// Gets all available Japanese words
    /// - Returns: Array of all Japanese words in the mapping
    func getAllJapaneseWords() -> [String] {
        return Array(imageNameToJapaneseWord.values)
    }
    
    /// Gets all image-to-word mappings
    /// - Returns: Dictionary containing all mappings
    func getAllMappings() -> [String: String] {
        return imageNameToJapaneseWord
    }
}
