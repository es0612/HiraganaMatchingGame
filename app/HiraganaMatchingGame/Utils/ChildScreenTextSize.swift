import SwiftUI

extension View {
    /// 子ども向け画面の文字サイズの上限。アクセシビリティサイズまで追従させると、
    /// ゲーム画面のカードと選択肢が最初の画面から押し出される (#34)。保護者向けの設定画面には付けない
    func childScreenTextSizeLimit() -> some View {
        dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}
