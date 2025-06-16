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
    
    var body: some View {
        VStack(spacing: 20) {
            instructionText
            
            hiraganaCardView
            
            answerChoicesView
        }
    }
    
    private var instructionText: some View {
        Text("この文字に合う絵を選んでね！")
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(.primary.opacity(0.8))
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    private var hiraganaCardView: some View {
        ZStack {
            // 背景カード
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color.pink.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .stroke(
                    LinearGradient(
                        colors: [Color.pink.opacity(0.6), Color.orange.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 220, height: 220)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            // ひらがな文字を完全に中央配置
            Text(currentHiragana)
                .font(.system(size: 90, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(width: 220, height: 220)
                .scaleEffect(showFeedback ? 1.2 : 1.0)
                .rotationEffect(.degrees(showFeedback ? 10 : 0))
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showFeedback)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentHiragana)
            
            // サウンドボタンを右上に配置
            VStack {
                HStack {
                    Spacer()
                    soundButton
                        .offset(x: -15, y: 15)
                }
                Spacer()
            }
        }
    }
    
    private var soundButton: some View {
        Button(action: onSoundButtonTap) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                )
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: currentHiragana)
        .accessibilityLabel("ひらがなの音を聞く")
        .accessibilityHint("\(currentHiragana)の音声を再生します")
    }
    
    private var answerChoicesView: some View {
        VStack(spacing: 15) {
            Text("正しい絵をタップしてください")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary.opacity(0.7))
            
            if isLandscape {
                HStack(spacing: 20) {
                    ForEach(answerChoices, id: \.id) { choice in
                        answerChoiceButton(choice)
                    }
                }
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(answerChoices, id: \.id) { choice in
                        answerChoiceButton(choice)
                    }
                }
            }
        }
    }
    
    private func answerChoiceButton(_ choice: HiraganaItem) -> some View {
        Button(action: {
            // タップ時のハプティクスフィードバック
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                onAnswerSelected(choice.imageName)
            }
        }) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color.blue.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: choiceButtonSize, height: choiceButtonSize)
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
        .onAppear {
            // 選択肢ボタンが表示される時の楽しいアニメーション
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(Double.random(in: 0...0.5))) {
                // 小さな跳ねるアニメーション
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
    
    private var choiceButtonSize: CGFloat {
        isLandscape ? 90 : 110
    }
    
    // MARK: - Helper Functions
    
    private func getEmojiForImageName(_ imageName: String) -> String {
        switch imageName {
        // あ行
        case "ant": return "🐜"
        case "dog": return "🐶"
        case "rabbit": return "🐰"
        case "shrimp": return "🦐"
        case "demon": return "👹"
        
        // か行
        case "crab": return "🦀"
        case "giraffe": return "🦒"
        case "bear": return "🐻"
        case "cake": return "🍰"
        case "top": return "🌀"
        
        // さ行
        case "monkey": return "🐵"
        case "deer": return "🦌"
        case "watermelon": return "🍉"
        case "cicada": return "🦗"
        case "sky": return "🌌"
        
        // た行
        case "octopus": return "🐙"
        case "butterfly": return "🦋"
        case "crane": return "🕊️"
        case "hand": return "✋"
        case "clock": return "⏰"
        
        // な行
        case "eggplant": return "🍆"
        case "carrot": return "🥕"
        case "doll": return "🪆"
        case "cat": return "🐱"
        case "field": return "🌾"
        
        // は行
        case "flower": return "🌸"
        case "chick": return "🐤"
        case "boat": return "⛵"
        case "snake": return "🐍"
        case "bone": return "🦴"
        
        // ま行
        case "bean": return "🫘"
        case "ear": return "👂"
        case "bug": return "🐛"
        case "eye": return "👁️"
        case "peach": return "🍑"
        
        // や行
        case "arrow": return "🏹"
        case "hot_water": return "♨️"
        case "night": return "🌙"
        
        // ら行
        case "trumpet": return "🎺"
        case "apple": return "🍎"
        case "loop": return "🔄"
        case "refrigerator": return "🧊"
        case "candle": return "🕯️"
        
        // わ行
        case "ring": return "💍"
        case "man": return "👨"
        case "antenna": return "📡"
        
        default: return "❓"
        }
    }
    
    private func getReadingForCharacter(_ character: String) -> String {
        let readings: [String: String] = [
            // あ行
            "あ": "あり", "い": "いぬ", "う": "うさぎ", "え": "えび", "お": "おに",
            
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
            HiraganaItem(character: "あ", imageName: "ant", category: "あ行"),
            HiraganaItem(character: "い", imageName: "dog", category: "あ行"),
            HiraganaItem(character: "う", imageName: "rabbit", category: "あ行"),
            HiraganaItem(character: "え", imageName: "shrimp", category: "あ行")
        ],
        showFeedback: false,
        onSoundButtonTap: { print("Sound tapped") },
        onAnswerSelected: { imageName in print("Selected: \(imageName)") }
    )
    .padding()
}