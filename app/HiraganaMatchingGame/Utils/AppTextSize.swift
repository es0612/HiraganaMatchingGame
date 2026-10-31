import SwiftUI

extension View {
    /// アプリ全体の文字サイズの上限。アクセシビリティサイズまで追従させると、
    /// ゲーム画面のカードと選択肢が最初の画面から押し出され、設定画面のラベルも 1 文字ずつ折り返す (#34)。
    /// シートは呼び出し元の環境を引き継がないことがあるので、シートの中身にも付ける
    func appTextSizeLimit() -> some View {
        dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}
