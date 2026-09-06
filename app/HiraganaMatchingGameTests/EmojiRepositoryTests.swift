@testable import HiraganaMatchingGame
import Testing

@Test("EmojiRepository基本機能テスト")
func emojiRepositoryBasicFunctionality() {
    let repository = EmojiRepository.shared
    
    // 基本的な絵文字取得テスト
    #expect(repository.getEmojiForImageName("ant") == "🐜")
    #expect(repository.getEmojiForImageName("dog") == "🐶")
    #expect(repository.getEmojiForImageName("cat") == "🐱")
    #expect(repository.getEmojiForImageName("apple") == "🍎")
    #expect(repository.getEmojiForImageName("flower") == "🌸")
    
    // 存在しない画像名のテスト（デフォルト絵文字を返す）
    #expect(repository.getEmojiForImageName("nonexistent") == "❓")
    #expect(repository.getEmojiForImageName("") == "❓")
}

@Test("EmojiRepository全データ取得テスト")
func emojiRepositoryAllDataRetrieval() {
    let repository = EmojiRepository.shared
    
    // 全画像名取得テスト
    let imageNames = repository.getAllImageNames()
    #expect(imageNames.count > 150) // 大量の画像があることを確認（2026-09 時点で 180 件強）
    #expect(imageNames.contains("ant"))
    #expect(imageNames.contains("dog"))
    #expect(imageNames.contains("cat"))
    
    // 全絵文字取得テスト
    let emojis = repository.getAllEmojis()
    #expect(emojis.count > 150)
    #expect(emojis.contains("🐜"))
    #expect(emojis.contains("🐶"))
    #expect(emojis.contains("🐱"))
    
    // 全マッピング取得テスト
    let mappings = repository.getAllMappings()
    #expect(mappings.count > 150)
    #expect(mappings["ant"] == "🐜")
    #expect(mappings["dog"] == "🐶")
}

@Test("EmojiRepositoryマッピング存在確認テスト")
func emojiRepositoryMappingExistence() {
    let repository = EmojiRepository.shared
    
    // 存在するマッピング
    #expect(repository.hasEmojiMapping(for: "ant") == true)
    #expect(repository.hasEmojiMapping(for: "dog") == true)
    #expect(repository.hasEmojiMapping(for: "cat") == true)
    #expect(repository.hasEmojiMapping(for: "apple") == true)
    
    // 存在しないマッピング
    #expect(repository.hasEmojiMapping(for: "nonexistent") == false)
    #expect(repository.hasEmojiMapping(for: "") == false)
    #expect(repository.hasEmojiMapping(for: "unknown_image") == false)
}

@Test("EmojiRepositoryカテゴリ別絵文字テスト")
func emojiRepositoryCategoryBasedEmojis() {
    let repository = EmojiRepository.shared
    
    // 動物系の絵文字
    #expect(repository.getEmojiForImageName("ant") == "🐜")
    #expect(repository.getEmojiForImageName("dog") == "🐶")
    #expect(repository.getEmojiForImageName("cat") == "🐱")
    #expect(repository.getEmojiForImageName("rabbit") == "🐰")
    
    // 食べ物系の絵文字
    #expect(repository.getEmojiForImageName("apple") == "🍎")
    #expect(repository.getEmojiForImageName("strawberry") == "🍓")
    #expect(repository.getEmojiForImageName("cake") == "🍰")
    #expect(repository.getEmojiForImageName("watermelon") == "🍉")
    
    // 自然系の絵文字
    #expect(repository.getEmojiForImageName("flower") == "🌸")
    #expect(repository.getEmojiForImageName("tree") == "🌳")
    #expect(repository.getEmojiForImageName("moon") == "🌙")
    #expect(repository.getEmojiForImageName("sun") == "☀️")
}

@Test("EmojiRepositoryシングルトンテスト")
func emojiRepositorySingleton() {
    let repository1 = EmojiRepository.shared
    let repository2 = EmojiRepository.shared
    
    // 同じインスタンスであることを確認
    #expect(repository1 === repository2)
}

@Test("EmojiRepository五十音順絵文字テスト")
func emojiRepositoryHiraganaOrderEmojis() {
    let repository = EmojiRepository.shared
    
    // あ行
    #expect(repository.getEmojiForImageName("ant") == "🐜") // あり
    #expect(repository.getEmojiForImageName("dog") == "🐶") // いぬ
    #expect(repository.getEmojiForImageName("rabbit") == "🐰") // うさぎ
    #expect(repository.getEmojiForImageName("shrimp") == "🦐") // えび
    #expect(repository.getEmojiForImageName("demon") == "👹") // おに
    
    // か行
    #expect(repository.getEmojiForImageName("crab") == "🦀") // かに
    #expect(repository.getEmojiForImageName("giraffe") == "🦒") // きりん
    #expect(repository.getEmojiForImageName("bear") == "🐻") // くま
    #expect(repository.getEmojiForImageName("cake") == "🍰") // けーき
    #expect(repository.getEmojiForImageName("top") == "🌀") // こま
}

@Test("EmojiRepository特殊文字絵文字テスト")
func emojiRepositorySpecialCharacterEmojis() {
    let repository = EmojiRepository.shared
    
    // わ行
    #expect(repository.getEmojiForImageName("ring") == "💍") // わ
    #expect(repository.getEmojiForImageName("man") == "👨") // をとこ
    #expect(repository.getEmojiForImageName("antenna") == "📡") // あんてな (ん)
    
}
