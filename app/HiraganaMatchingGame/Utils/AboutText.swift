import Foundation

/// 「アプリについて」画面の文言。View から切り離してテストで確かめる (#114)
enum AboutText {
    /// Info.plist の CFBundleShortVersionString から作る。取れないときは nil（バージョンの行を出さない）
    static func version(infoDictionary: [String: Any]?) -> String? {
        guard let version = infoDictionary?["CFBundleShortVersionString"] as? String, !version.isEmpty else {
            return nil
        }
        return "バージョン \(version)"
    }

    /// 文字数は HiraganaCatalog から数える（現代仮名 46 文字、#22）
    static var characterFeature: String {
        "• \(HiraganaCatalog.allCharacters.count)文字のひらがな全てに対応"
    }
}
