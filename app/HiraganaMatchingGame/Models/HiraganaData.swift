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
    
    // 画像名から日本語の単語へのマッピング
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
        "train": "きしゃ", // き行のきしゃ（汽車）
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
        "lion": "しし", // し行のしし（獅子）
        "salt": "しお",
        "newspaper": "しんぶん",
        "watermelon": "すいか",
        "sparrow": "すずめ",
        "nest": "す",
        "sand": "すな",
        "cicada": "せみ",
        "world": "せかい", // せ行のせかい（世界）
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
        "world2": "よのなか", // よ行のよのなか（世の中）
        "good": "よい",
        
        // ら行の追加
        "trumpet": "らっぱ",
        "radio": "らじお",
        "lion2": "らいおん", // ら行のらいおん（ライオン）
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
        "train2": "れっしゃ", // れ行のれっしゃ（電車）
        "lettuce": "れたす",
        "candle": "ろうそく",
        "robot": "ろぼっと",
        "rocket": "ろけっと",
        "rope": "ろーぷ",
        
        // わ行の追加
        "ring": "わ",
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
        HiraganaItem(character: "お", imageName: "mother", category: "family"), // おかあさん
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
        HiraganaItem(character: "け", imageName: "smoke", category: "object"), // けむり
        
        HiraganaItem(character: "こ", imageName: "top", category: "toy"),
        HiraganaItem(character: "こ", imageName: "child", category: "character"), // こども
        HiraganaItem(character: "こ", imageName: "heart", category: "emotion"), // こころ
        HiraganaItem(character: "こ", imageName: "ice", category: "food"), // こおり
        
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
        HiraganaItem(character: "た", imageName: "octopus", category: "animal"), // たこ
        HiraganaItem(character: "た", imageName: "egg", category: "food"), // たまご
        HiraganaItem(character: "た", imageName: "tower", category: "building"), // たてもの
        HiraganaItem(character: "た", imageName: "bamboo", category: "plant"), // たけ
        
        HiraganaItem(character: "ち", imageName: "butterfly", category: "animal"), // ちょう
        HiraganaItem(character: "ち", imageName: "cheese", category: "food"), // ちーず
        HiraganaItem(character: "ち", imageName: "map", category: "object"), // ちず
        HiraganaItem(character: "ち", imageName: "bird", category: "animal"), // ちどり
        
        HiraganaItem(character: "つ", imageName: "crane", category: "animal"), // つる
        HiraganaItem(character: "つ", imageName: "moon", category: "nature"), // つき
        HiraganaItem(character: "つ", imageName: "desk", category: "furniture"), // つくえ
        HiraganaItem(character: "つ", imageName: "fishing", category: "activity"), // つり
        
        HiraganaItem(character: "て", imageName: "hand", category: "body"), // て
        HiraganaItem(character: "て", imageName: "letter", category: "object"), // てがみ
        HiraganaItem(character: "て", imageName: "tent", category: "object"), // てんと
        HiraganaItem(character: "て", imageName: "television", category: "appliance"), // てれび
        
        HiraganaItem(character: "と", imageName: "clock", category: "object"), // とけい
        HiraganaItem(character: "と", imageName: "tiger", category: "animal"), // とら
        HiraganaItem(character: "と", imageName: "door", category: "object"), // とびら
        HiraganaItem(character: "と", imageName: "tomato", category: "food"), // とまと
        
        // な行
        HiraganaItem(character: "な", imageName: "eggplant", category: "food"), // なす
        HiraganaItem(character: "な", imageName: "wave", category: "nature"), // なみ
        HiraganaItem(character: "な", imageName: "name", category: "concept"), // なまえ
        HiraganaItem(character: "な", imageName: "summer", category: "season"), // なつ
        
        HiraganaItem(character: "に", imageName: "carrot", category: "food"), // にんじん
        HiraganaItem(character: "に", imageName: "rainbow", category: "nature"), // にじ
        HiraganaItem(character: "に", imageName: "garden", category: "nature"), // にわ
        HiraganaItem(character: "に", imageName: "meat", category: "food"), // にく
        
        HiraganaItem(character: "ぬ", imageName: "doll", category: "toy"), // ぬいぐるみ
        HiraganaItem(character: "ぬ", imageName: "cloth", category: "object"), // ぬの
        HiraganaItem(character: "ぬ", imageName: "mud", category: "nature"), // ぬま
        HiraganaItem(character: "ぬ", imageName: "paint", category: "tool"), // ぬりえ
        
        HiraganaItem(character: "ね", imageName: "cat", category: "animal"), // ねこ
        HiraganaItem(character: "ね", imageName: "mouse", category: "animal"), // ねずみ
        HiraganaItem(character: "ね", imageName: "sleep", category: "activity"), // ねる
        HiraganaItem(character: "ね", imageName: "tie", category: "clothing"), // ねくたい
        
        HiraganaItem(character: "の", imageName: "field", category: "nature"), // のはら
        HiraganaItem(character: "の", imageName: "drink", category: "activity"), // のむ
        HiraganaItem(character: "の", imageName: "seaweed", category: "food"), // のり
        HiraganaItem(character: "の", imageName: "notebook", category: "object"), // のーと
        
        // は行
        HiraganaItem(character: "は", imageName: "flower", category: "nature"), // はな
        HiraganaItem(character: "は", imageName: "brush", category: "tool"), // はけ
        HiraganaItem(character: "は", imageName: "box", category: "object"), // はこ
        HiraganaItem(character: "は", imageName: "scissors", category: "tool"), // はさみ
        
        HiraganaItem(character: "ひ", imageName: "chick", category: "animal"), // ひよこ
        HiraganaItem(character: "ひ", imageName: "fire", category: "element"), // ひ
        HiraganaItem(character: "ひ", imageName: "sun", category: "nature"), // ひ
        HiraganaItem(character: "ひ", imageName: "sheep", category: "animal"), // ひつじ
        
        HiraganaItem(character: "ふ", imageName: "boat", category: "vehicle"), // ふね
        HiraganaItem(character: "ふ", imageName: "envelope", category: "object"), // ふうとう
        HiraganaItem(character: "ふ", imageName: "winter", category: "season"), // ふゆ
        HiraganaItem(character: "ふ", imageName: "futon", category: "furniture"), // ふとん
        
        HiraganaItem(character: "へ", imageName: "snake", category: "animal"), // へび
        HiraganaItem(character: "へ", imageName: "helmet", category: "clothing"), // へるめっと
        HiraganaItem(character: "へ", imageName: "room", category: "building"), // へや
        HiraganaItem(character: "へ", imageName: "wall", category: "building"), // へい
        
        HiraganaItem(character: "ほ", imageName: "bone", category: "object"), // ほね
        HiraganaItem(character: "ほ", imageName: "book", category: "object"), // ほん
        HiraganaItem(character: "ほ", imageName: "star", category: "nature"), // ほし
        HiraganaItem(character: "ほ", imageName: "cheek", category: "body"), // ほほ
        
        // ま行
        HiraganaItem(character: "ま", imageName: "bean", category: "food"), // まめ
        HiraganaItem(character: "ま", imageName: "window", category: "building"), // まど
        HiraganaItem(character: "ま", imageName: "pillow", category: "furniture"), // まくら
        HiraganaItem(character: "ま", imageName: "circle", category: "shape"), // まる
        
        HiraganaItem(character: "み", imageName: "ear", category: "body"), // みみ
        HiraganaItem(character: "み", imageName: "water", category: "nature"), // みず
        HiraganaItem(character: "み", imageName: "road", category: "object"), // みち
        HiraganaItem(character: "み", imageName: "green", category: "color"), // みどり
        
        HiraganaItem(character: "む", imageName: "bug", category: "animal"), // むし
        HiraganaItem(character: "む", imageName: "purple", category: "color"), // むらさき
        HiraganaItem(character: "む", imageName: "village", category: "place"), // むら
        HiraganaItem(character: "む", imageName: "chest", category: "body"), // むね
        
        HiraganaItem(character: "め", imageName: "eye", category: "body"), // め
        HiraganaItem(character: "め", imageName: "glasses", category: "clothing"), // めがね
        HiraganaItem(character: "め", imageName: "noodles", category: "food"), // めん
        HiraganaItem(character: "め", imageName: "female", category: "character"), // めす
        
        HiraganaItem(character: "も", imageName: "peach", category: "food"), // もも
        HiraganaItem(character: "も", imageName: "forest", category: "nature"), // もり
        HiraganaItem(character: "も", imageName: "thing", category: "concept"), // もの
        HiraganaItem(character: "も", imageName: "rice_cake", category: "food"), // もち
        
        // や行
        HiraganaItem(character: "や", imageName: "arrow", category: "object"), // や
        HiraganaItem(character: "や", imageName: "roof", category: "building"), // やね
        HiraganaItem(character: "や", imageName: "vegetable", category: "food"), // やさい
        HiraganaItem(character: "や", imageName: "mountain", category: "nature"), // やま
        
        HiraganaItem(character: "ゆ", imageName: "hot_water", category: "object"), // ゆ
        HiraganaItem(character: "ゆ", imageName: "snow", category: "weather"), // ゆき
        HiraganaItem(character: "ゆ", imageName: "finger", category: "body"), // ゆび
        HiraganaItem(character: "ゆ", imageName: "dream", category: "concept"), // ゆめ
        
        HiraganaItem(character: "よ", imageName: "night", category: "nature"), // よる
        HiraganaItem(character: "よ", imageName: "four", category: "number"), // よん
        HiraganaItem(character: "よ", imageName: "world2", category: "concept"), // よのなか
        HiraganaItem(character: "よ", imageName: "good", category: "concept"), // よい
        
        // ら行
        HiraganaItem(character: "ら", imageName: "trumpet", category: "instrument"), // らっぱ
        HiraganaItem(character: "ら", imageName: "radio", category: "appliance"), // らじお
        HiraganaItem(character: "ら", imageName: "lion2", category: "animal"), // らいおん
        HiraganaItem(character: "ら", imageName: "ramen", category: "food"), // らーめん
        
        HiraganaItem(character: "り", imageName: "apple", category: "food"), // りんご
        HiraganaItem(character: "り", imageName: "squirrel", category: "animal"), // りす
        HiraganaItem(character: "り", imageName: "ribbon", category: "clothing"), // りぼん
        HiraganaItem(character: "り", imageName: "reason", category: "concept"), // りゆう
        
        HiraganaItem(character: "る", imageName: "loop", category: "object"), // る
        HiraganaItem(character: "る", imageName: "ruby", category: "object"), // るびー
        HiraganaItem(character: "る", imageName: "route", category: "concept"), // るーと
        HiraganaItem(character: "る", imageName: "ruler", category: "tool"), // るーらー
        
        HiraganaItem(character: "れ", imageName: "refrigerator", category: "appliance"), // れいぞうこ
        HiraganaItem(character: "れ", imageName: "lemon", category: "food"), // れもん
        HiraganaItem(character: "れ", imageName: "train2", category: "vehicle"), // れっしゃ
        HiraganaItem(character: "れ", imageName: "lettuce", category: "food"), // れたす
        
        HiraganaItem(character: "ろ", imageName: "candle", category: "object"), // ろうそく
        HiraganaItem(character: "ろ", imageName: "robot", category: "character"), // ろぼっと
        HiraganaItem(character: "ろ", imageName: "rocket", category: "vehicle"), // ろけっと
        HiraganaItem(character: "ろ", imageName: "rope", category: "tool"), // ろーぷ
        
        // わ行
        HiraganaItem(character: "わ", imageName: "ring", category: "object"), // わ
        HiraganaItem(character: "わ", imageName: "cotton", category: "object"), // わた
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
    
    func getJapaneseWord(for imageName: String) -> String? {
        return imageNameToJapaneseWord[imageName]
    }
    
    func getRandomChoices(for hiragana: String, count: Int = 3) -> [HiraganaItem] {
        // 指定されたひらがなの全ての選択肢を取得
        let correctItems = allHiraganaData.filter { $0.character == hiragana }
        guard !correctItems.isEmpty else { return [] }
        
        // ランダムに1つの正解を選択
        let correct = correctItems.randomElement()!
        
        let wrongChoices = allHiraganaData.filter { $0.character != hiragana }
            .shuffled()
            .prefix(count - 1)
        
        var choices = Array(wrongChoices)
        choices.append(correct)
        
        return choices.shuffled()
    }
    
    func getQuestionVariations(for hiragana: String) -> [HiraganaItem] {
        return allHiraganaData.filter { $0.character == hiragana }
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