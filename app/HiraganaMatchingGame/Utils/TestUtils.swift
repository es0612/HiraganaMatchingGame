//
//  TestUtils.swift
//  HiraganaMatchingGame
//
//

import Foundation

struct TestUtils {
    /// テスト環境かどうかを判定
    static var isTestEnvironment: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
               ProcessInfo.processInfo.environment["XCInjectBundleInto"] != nil ||
               NSClassFromString("XCTest") != nil
    }
    
    /// テスト実行時のデバッグ出力
    static func debugPrint(_ message: String) {
        if isTestEnvironment {
            print("[TEST] \(message)")
        }
    }
}
