import CoreGraphics

/// ゲーム画面の大きさの段階（#80）。
/// GameView は大きい順に試し、選択肢がスクロールせずに全部見える最初の段階を使う。
/// 狭い画面や大きい文字サイズでは、2 行目の選択肢が下のボタン列の裏に隠れていた。
enum GameLayoutScale: CaseIterable {
    case regular
    case compact
    case minimum

    var hiraganaCardSize: CGFloat {
        switch self {
        case .regular: 220
        case .compact: 160
        case .minimum: 120
        }
    }

    var hiraganaFontSize: CGFloat {
        switch self {
        case .regular: 90
        case .compact: 66
        case .minimum: 50
        }
    }

    var choiceSize: CGFloat {
        switch self {
        case .regular: 110
        case .compact: 92
        case .minimum: 76
        }
    }

    /// 縦に並ぶ部品どうしの間隔
    var spacing: CGFloat {
        switch self {
        case .regular: 20
        case .compact: 14
        case .minimum: 10
        }
    }
}
