import Foundation

/// VoiceOver の読み上げ文。View から切り離してテストで文言を確かめる (#34)
enum AccessibilityText {
    static let back = "戻る"
    static let closeHint = "ヒントを閉じる"

    static func stars(_ earned: Int, total: Int = 3) -> String {
        "スター \(earned)こ（\(total)こ中）"
    }

    static func levelButton(level: Int, title: String, stars: Int, isUnlocked: Bool, isRecommended: Bool) -> String {
        var parts = ["レベル \(level)", title]
        if isUnlocked {
            parts.append(self.stars(stars))
            if isRecommended {
                parts.append("おすすめ")
            }
        } else {
            parts.append("ロック中")
        }
        return parts.joined(separator: "、")
    }

    static func answerChoice(reading: String) -> String {
        "\(reading)の絵"
    }
}
