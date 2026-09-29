import Foundation
import Testing

/// App Store 提出に必要な Privacy Manifest がアプリバンドルに入っているか (#23)
@Suite("Privacy Manifest (#23)")
struct PrivacyManifestTests {
    private func loadManifest() throws -> [String: Any] {
        let url = try #require(Bundle.main.url(forResource: "PrivacyInfo", withExtension: "xcprivacy"))
        let data = try Data(contentsOf: url)
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
        return try #require(plist as? [String: Any])
    }

    @Test("トラッキングしない・収集データなしと申告している")
    func declaresNoTrackingAndNoCollectedData() throws {
        let manifest = try loadManifest()
        #expect(manifest["NSPrivacyTracking"] as? Bool == false)
        #expect((manifest["NSPrivacyTrackingDomains"] as? [String])?.isEmpty == true)
        #expect((manifest["NSPrivacyCollectedDataTypes"] as? [Any])?.isEmpty == true)
    }

    @Test("UserDefaults の利用理由 CA92.1 を申告している")
    func declaresUserDefaultsReason() throws {
        let manifest = try loadManifest()
        let apiTypes = try #require(manifest["NSPrivacyAccessedAPITypes"] as? [[String: Any]])
        let userDefaults = try #require(apiTypes.first {
            $0["NSPrivacyAccessedAPIType"] as? String == "NSPrivacyAccessedAPICategoryUserDefaults"
        })
        #expect(userDefaults["NSPrivacyAccessedAPITypeReasons"] as? [String] == ["CA92.1"])
    }
}
