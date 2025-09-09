@testable import HiraganaMatchingGame
import Testing

@Test("WordMappingRepository基本機能テスト")
func wordMappingRepositoryBasicFunctionality() {
    let repository = WordMappingRepository.shared
    
    // 日本語単語取得テスト
    #expect(repository.getJapaneseWord(for: "ant") == "ありさん")
    #expect(repository.getJapaneseWord(for: "dog") == "いぬ")
    #expect(repository.getJapaneseWord(for: "cat") == "ねこ")
    #expect(repository.getJapaneseWord(for: "apple") == "りんご")
    
    // 存在しない画像名のテスト
    #expect(repository.getJapaneseWord(for: "nonexistent") == nil)
}

@Test("WordMappingRepository全データ取得テスト")
func wordMappingRepositoryAllDataRetrieval() {
    let repository = WordMappingRepository.shared
    
    // 全画像名取得テスト
    let imageNames = repository.getAllImageNames()
    #expect(imageNames.count > 200) // 大量の画像があることを確認
    #expect(imageNames.contains("ant"))
    #expect(imageNames.contains("dog"))
    #expect(imageNames.contains("cat"))
    
    // 全日本語単語取得テスト
    let japaneseWords = repository.getAllJapaneseWords()
    #expect(japaneseWords.count > 200)
    #expect(japaneseWords.contains("ありさん"))
    #expect(japaneseWords.contains("いぬ"))
    #expect(japaneseWords.contains("ねこ"))
    
    // 全マッピング取得テスト
    let mappings = repository.getAllMappings()
    #expect(mappings.count > 200)
    #expect(mappings["ant"] == "ありさん")
    #expect(mappings["dog"] == "いぬ")
}

@Test("WordMappingRepository五十音カバレッジテスト")
func wordMappingRepositoryHiraganaCoverage() {
    let repository = WordMappingRepository.shared
    let mappings = repository.getAllMappings()
    
    // あ行のチェック
    let aWords = mappings.values.filter { $0.hasPrefix("あ") || $0.hasPrefix("い") || $0.hasPrefix("う") || $0.hasPrefix("え") || $0.hasPrefix("お") }
    #expect(aWords.count >= 5)
    
    // か行のチェック
    let kaWords = mappings.values.filter { $0.hasPrefix("か") || $0.hasPrefix("き") || $0.hasPrefix("く") || $0.hasPrefix("け") || $0.hasPrefix("こ") }
    #expect(kaWords.count >= 5)
    
    // さ行のチェック
    let saWords = mappings.values.filter { $0.hasPrefix("さ") || $0.hasPrefix("し") || $0.hasPrefix("す") || $0.hasPrefix("せ") || $0.hasPrefix("そ") }
    #expect(saWords.count >= 5)
}

@Test("WordMappingRepositoryシングルトンテスト")
func wordMappingRepositorySingleton() {
    let repository1 = WordMappingRepository.shared
    let repository2 = WordMappingRepository.shared
    
    // 同じインスタンスであることを確認
    #expect(repository1 === repository2)
}

@Test("WordMappingRepository特定文字の単語数テスト")
func wordMappingRepositorySpecificCharacterWordCount() {
    let repository = WordMappingRepository.shared
    let mappings = repository.getAllMappings()
    
    // 「あ」で始まる単語数チェック
    let aWords = mappings.values.filter { $0.hasPrefix("あ") }
    #expect(aWords.count >= 3)
    
    // 「ね」で始まる単語数チェック（ねこ等）
    let neWords = mappings.values.filter { $0.hasPrefix("ね") }
    #expect(neWords.count >= 2)
    
    // 「り」で始まる単語数チェック（りんご等）
    let riWords = mappings.values.filter { $0.hasPrefix("り") }
    #expect(riWords.count >= 2)
}
