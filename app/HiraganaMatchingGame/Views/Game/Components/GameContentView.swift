//
//  GameContentView.swift
//  HiraganaMatchingGame
//
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
        return HiraganaDataManager.shared.getEmojiForImageName(imageName)
    }
    
    private func getReadingForCharacter(_ character: String) -> String {
        return HiraganaDataManager.shared.getReadingForCharacter(character)
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