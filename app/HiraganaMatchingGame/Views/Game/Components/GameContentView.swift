//
//  GameContentView.swift
//  HiraganaMatchingGame
//
//  Created on 2025/06/16
//

import SwiftUI

struct GameContentView: View {
    let currentHiragana: String
    let answerChoices: [HiraganaItem]
    let showFeedback: Bool
    let onSoundButtonTap: () -> Void
    let onAnswerSelected: (String) -> Void
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme
    
    // エモジマップを静的プロパティとして定義
    private static let emojiMap: [String: String] = [
        // あ行
        "ant": "🐜", "duck": "🦆", "rain": "🌧️", "red": "🔴",
        "dog": "🐶", "strawberry": "🍓", "chair": "🪑", "house": "🏠",
        "rabbit": "🐰", "horse": "🐴", "sea": "🌊", "song": "🎵",
        "shrimp": "🦐", "station": "🚉", "picture": "🖼️", "pencil": "✏️",
        "demon": "👹", "king": "👑", "mother": "👩", "tea": "🍵",
        
        // か行
        "crab": "🦀", "turtle": "🐢", "bag": "👜", "key": "🔑",
        "giraffe": "🦒", "tree": "🌳", "train": "🚂", "mushroom": "🍄",
        "bear": "🐻", "car": "🚗", "cloud": "☁️", "fruit": "🍇",
        "cake": "🍰", "frog": "🐸", "game": "🎮", "smoke": "💨",
        "top": "🌀", "child": "👶", "heart": "❤️", "ice": "🧊",
        
        // さ行
        "monkey": "🐒", "fish": "🐟", "cherry": "🍒", "desert": "🏜️",
        "deer": "🦌", "lion": "🦁", "salt": "🧂", "newspaper": "📰",
        "watermelon": "🍉", "sparrow": "🐦", "nest": "🪹", "sand": "🏖️",
        "cicada": "🦗", "world": "🌍", "soap": "🧼", "back": "↩️",
        "sky": "🌌", "socks": "🧦", "outside": "🌲", "sleeve": "👕",
        
        // た行
        "octopus": "🐙", "egg": "🥚", "tower": "🗼", "bamboo": "🎋",
        "butterfly": "🦋", "cheese": "🧀", "map": "🗺️", "bird": "🐦",
        "crane": "🦩", "moon": "🌙", "desk": "🪑", "fishing": "🎣",
        "hand": "✋", "letter": "✉️", "tent": "⛺", "television": "📺",
        "clock": "⏰", "tiger": "🐅", "door": "🚪", "tomato": "🍅",
        
        // な行
        "eggplant": "🍆", "wave": "🌊", "name": "📛", "summer": "☀️",
        "carrot": "🥕", "rainbow": "🌈", "garden": "🏡", "meat": "🥩",
        "doll": "🪆", "cloth": "🧵", "mud": "🪨", "paint": "🎨",
        "cat": "🐱", "mouse": "🐭", "sleep": "😴", "tie": "👔",
        "field": "🌾", "drink": "🥤", "seaweed": "🌿", "notebook": "📓",
        
        // は行
        "flower": "🌸", "brush": "🖌️", "box": "📦", "scissors": "✂️",
        "chick": "🐤", "fire": "🔥", "sun": "☀️", "sheep": "🐑",
        "boat": "🚤", "envelope": "✉️", "winter": "❄️", "futon": "🛏️",
        "snake": "🐍", "helmet": "⛑️", "room": "🏠", "wall": "🧱",
        "bone": "🦴", "book": "📖", "star": "⭐", "cheek": "😊",
        
        // ま行
        "bean": "🫘", "window": "🪟", "pillow": "🛏️", "circle": "⭕",
        "ear": "👂", "water": "💧", "road": "🛣️", "green": "💚",
        "bug": "🐛", "purple": "💜", "village": "🏘️", "chest": "📦",
        "eye": "👁️", "glasses": "👓", "noodles": "🍜", "female": "👩",
        "peach": "🍑", "forest": "🌲", "thing": "📦", "rice_cake": "🍡",
        
        // や行
        "arrow": "➡️", "roof": "🏠", "vegetable": "🥬", "mountain": "⛰️",
        "hot_water": "♨️", "snow": "❄️", "finger": "👉", "dream": "💭",
        "night": "🌙", "four": "4️⃣", "world2": "🌏", "good": "👍",
        
        // ら行
        "trumpet": "🎺", "radio": "📻", "lion2": "🦁", "ramen": "🍜",
        "apple": "🍎", "squirrel": "🐿️", "ribbon": "🎀", "reason": "💭",
        "loop": "🔄", "ruby": "💎", "route": "🛣️", "ruler": "📏",
        "refrigerator": "🧊", "lemon": "🍋", "train2": "🚆", "lettuce": "🥬",
        "candle": "🕯️", "robot": "🤖", "rocket": "🚀", "rope": "🪢",
        
        // わ行
        "ring": "💍", "cotton": "☁️", "young": "👶", "japanese": "🇯🇵",
        "man": "👨", "dance": "💃", "woman": "👩", "antenna": "📡",
        "bread": "🍞", "engine": "⚙️", "pen": "🖊️"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            instructionText
            
            hiraganaCardView
            
            answerChoicesView
        }
    }
    
    // MARK: - Computed Properties
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
    
    private var choiceButtonSize: CGFloat {
        isLandscape ? 90 : 110
    }
    
    // MARK: - View Components
    
    private var instructionText: some View {
        Text("この文字にあう絵をえらんでね")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            .multilineTextAlignment(.center)
            .accessibilityLabel("ゲームの説明：この文字に合う絵を選んでください")
    }
    
    private var hiraganaCardView: some View {
        VStack(spacing: 12) {
            Button(action: onSoundButtonTap) {
                VStack(spacing: 8) {
                    Text(currentHiragana)
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title3)
                        Text("音を聞く")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                }
                .frame(width: 200, height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                        .shadow(
                            color: colorScheme == .dark ? 
                                Color.white.opacity(0.1) : 
                                Color.black.opacity(0.15), 
                            radius: 8, 
                            x: 0, 
                            y: 4
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("ひらがな \(currentHiragana) の音を聞く")
            .accessibilityHint("タップすると \(currentHiragana) の発音が聞けます")
        }
    }
    
    private var answerChoicesView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: isLandscape ? 4 : 2), spacing: 16) {
            ForEach(answerChoices) { choice in
                choiceButton(for: choice)
            }
        }
        .padding(.horizontal, isLandscape ? 40 : 20)
    }
    
    private func choiceButton(for choice: HiraganaItem) -> some View {
        Button(action: {
            onAnswerSelected(choice.imageName)
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                        .shadow(
                            color: colorScheme == .dark ? 
                                Color.white.opacity(0.05) : 
                                Color.black.opacity(0.1), 
                            radius: colorScheme == .dark ? 2 : 4, 
                            x: 0, 
                            y: 2
                        )
                    
                    // 絵文字を中央に配置
                    Text(getEmojiForImageName(choice.imageName))
                        .font(.system(size: choiceButtonSize * 0.55))
                        .frame(width: choiceButtonSize, height: choiceButtonSize)
                        .scaleEffect(showFeedback ? 1.2 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showFeedback)
                }
                
                Text(getReadingForCharacter(choice.character))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.3)), value: currentHiragana)
        .accessibilityLabel("\(getReadingForCharacter(choice.character))の絵")
        .accessibilityHint("タップして\(choice.character)の文字に合う絵として選択します")
    }
    
    // MARK: - Helper Functions
    
    private func getEmojiForImageName(_ imageName: String) -> String {
        if let emoji = Self.emojiMap[imageName] {
            return emoji
        } else {
            print("⚠️ Missing emoji mapping for imageName: '\(imageName)'")
            return "❓"
        }
    }
    
    private func getReadingForCharacter(_ character: String) -> String {
        // HiraganaDataManagerのimageNameToJapaneseWordマッピングを使用
        let hiraganaDataManager = HiraganaDataManager.shared
        
        // 該当するひらがなの最初の選択肢の読み方を取得
        let hiraganaItems = hiraganaDataManager.getQuestionVariations(for: character)
        if let firstItem = hiraganaItems.first,
           let reading = hiraganaDataManager.getJapaneseWord(for: firstItem.imageName) {
            return reading
        }
        
        // フォールバック：従来の固定マッピング
        let readings: [String: String] = [
            // あ行
            "あ": "ありさん", "い": "いぬ", "う": "うさぎ", "え": "えび", "お": "おに",
            
            // か行
            "か": "かに", "き": "きりん", "く": "くま", "け": "けーき", "こ": "こま",
            
            // さ行
            "さ": "さる", "し": "しか", "す": "すいか", "せ": "せみ", "そ": "そら",
            
            // た行
            "た": "たこ", "ち": "ちょう", "つ": "つる", "て": "て", "と": "とけい",
            
            // な行
            "な": "なす", "に": "にんじん", "ぬ": "ぬいぐるみ", "ね": "ねこ", "の": "のはら",
            
            // は行
            "は": "はな", "ひ": "ひよこ", "ふ": "ふね", "へ": "へび", "ほ": "ほね",
            
            // ま行
            "ま": "まめ", "み": "みみ", "む": "むし", "め": "め", "も": "もも",
            
            // や行
            "や": "やじるし", "ゆ": "ゆ", "よ": "よる",
            
            // ら行
            "ら": "らっぱ", "り": "りんご", "る": "るーぷ", "れ": "れいぞうこ", "ろ": "ろうそく",
            
            // わ行
            "わ": "わ", "を": "をとこ", "ん": "あんてな"
        ]
        
        return readings[character] ?? character
    }
}

#Preview {
    GameContentView(
        currentHiragana: "あ",
        answerChoices: [
            HiraganaItem(character: "あ", imageName: "ant", category: "animals"),
            HiraganaItem(character: "い", imageName: "dog", category: "animals"),
            HiraganaItem(character: "う", imageName: "rabbit", category: "animals")
        ],
        showFeedback: false,
        onSoundButtonTap: { print("Sound button tapped") },
        onAnswerSelected: { imageName in print("Selected: \(imageName)") }
    )
}