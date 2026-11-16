import Foundation
@testable import HiraganaMatchingGame
import Testing

@Suite("「アプリについて」の文言と開発言語 (#114)")
struct AboutTextTests {
    @Test("バージョンは Info.plist の CFBundleShortVersionString を表示する")
    func versionFromInfoDictionary() {
        let text = AboutText.version(infoDictionary: ["CFBundleShortVersionString": "1.2.3"])
        #expect(text == "バージョン 1.2.3")
    }

    @Test("バージョンが取れないときは行を出さない")
    func versionMissing() {
        #expect(AboutText.version(infoDictionary: nil) == nil)
        #expect(AboutText.version(infoDictionary: [:]) == nil)
        #expect(AboutText.version(infoDictionary: ["CFBundleShortVersionString": ""]) == nil)
    }

    @Test("アプリ本体のバージョンと表示が一致する")
    func versionMatchesAppBundle() throws {
        let bundleVersion = try #require(
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        )
        #expect(AboutText.version(infoDictionary: Bundle.main.infoDictionary) == "バージョン \(bundleVersion)")
    }

    @Test("文字数は現代仮名 46 文字")
    func characterFeature() {
        #expect(AboutText.characterFeature == "• 46文字のひらがな全てに対応")
    }

    @Test("アプリの開発言語は日本語（ストアや OS に英語のアプリとして扱われない）")
    func developmentRegionIsJapanese() {
        let region = Bundle.main.object(forInfoDictionaryKey: "CFBundleDevelopmentRegion") as? String
        #expect(region == "ja")
    }
}
