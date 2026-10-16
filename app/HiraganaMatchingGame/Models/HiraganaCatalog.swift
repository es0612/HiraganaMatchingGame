import Foundation

/// ひらがなの行・レベル構成の唯一の定義（#21）。
/// レベル n は rows の先頭 n 行の文字を累積したもの。
enum HiraganaCatalog {
    struct Row {
        let name: String
        let characters: [String]
        let requiredStars: Int
    }

    static let rows: [Row] = [
        Row(name: "あ行", characters: ["あ", "い", "う", "え", "お"], requiredStars: 0),
        Row(name: "か行", characters: ["か", "き", "く", "け", "こ"], requiredStars: 2),
        Row(name: "さ行", characters: ["さ", "し", "す", "せ", "そ"], requiredStars: 4),
        Row(name: "た行", characters: ["た", "ち", "つ", "て", "と"], requiredStars: 6),
        Row(name: "な行", characters: ["な", "に", "ぬ", "ね", "の"], requiredStars: 8),
        Row(name: "は行", characters: ["は", "ひ", "ふ", "へ", "ほ"], requiredStars: 10),
        Row(name: "ま行", characters: ["ま", "み", "む", "め", "も"], requiredStars: 12),
        Row(name: "や行", characters: ["や", "ゆ", "よ"], requiredStars: 14),
        Row(name: "ら行", characters: ["ら", "り", "る", "れ", "ろ"], requiredStars: 16),
        Row(name: "わ行", characters: ["わ", "を", "ん"], requiredStars: 18)
    ]

    static var totalLevels: Int {
        rows.count
    }

    static var allCharacters: [String] {
        rows.flatMap(\.characters)
    }

    /// 1 未満は 1、totalLevels を超えたら totalLevels として扱う。
    static func characters(upToLevel level: Int) -> [String] {
        let clamped = min(max(level, 1), totalLevels)
        return rows.prefix(clamped).flatMap(\.characters)
    }

    /// 文字が属する行。Catalog にない文字は nil。
    static func row(containing character: String) -> Row? {
        rows.first { $0.characters.contains(character) }
    }
}
