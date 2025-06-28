//
//  TutorialView.swift
//  HiraganaMatchingGame
//
//

import SwiftUI

struct TutorialView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    @State private var showAnimation = false
    @Environment(\.colorScheme) var colorScheme
    
    private let tutorialSteps = [
        TutorialStep(
            title: "ひらがなゲームへようこそ！",
            description: "楽しくひらがなを覚えましょう！",
            imageName: "🎌",
            subtitle: "文字と絵を合わせて遊びます"
        ),
        TutorialStep(
            title: "ひらがなを見てみよう",
            description: "画面に表示されるひらがなの文字を覚えてね",
            imageName: "あ",
            subtitle: "大きく表示される文字を確認しよう"
        ),
        TutorialStep(
            title: "音を聞いてみよう",
            description: "スピーカーボタンを押すと音が聞こえるよ",
            imageName: "🔊",
            subtitle: "何度でも聞き直せます"
        ),
        TutorialStep(
            title: "正しい絵を選ぼう",
            description: "ひらがなに合う絵をタップして選んでね",
            imageName: "🐜",
            subtitle: "「あ」なら「ありさん（蟻）」を選ぼう"
        ),
        TutorialStep(
            title: "星を集めよう",
            description: "正解すると星がもらえるよ！",
            imageName: "⭐",
            subtitle: "星を集めて新しいレベルを解放しよう"
        ),
        TutorialStep(
            title: "さあ、始めよう！",
            description: "準備完了！楽しく学習しましょう",
            imageName: "🎯",
            subtitle: "がんばって！"
        )
    ]
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [
                    Color.pink.opacity(0.1),
                    Color.orange.opacity(0.1),
                    Color.yellow.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // プログレスバー
                progressBar
                
                Spacer()
                
                // メインコンテンツ
                tutorialContent
                
                Spacer()
                
                // コントロールボタン
                controlButtons
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                showAnimation = true
            }
        }
    }
    
    private var progressBar: some View {
        VStack(spacing: 12) {
            HStack {
                Text("チュートリアル")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(currentStep + 1) / \(tutorialSteps.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: Double(currentStep + 1), total: Double(tutorialSteps.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                .scaleEffect(y: 2)
        }
    }
    
    private var tutorialContent: some View {
        let step = tutorialSteps[currentStep]
        
        return VStack(spacing: 25) {
            // アイコン/文字表示
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color.pink.opacity(0.1)],
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
                        lineWidth: 3
                    )
                    .frame(width: 160, height: 160)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                if step.imageName.count == 1 {
                    // ひらがな文字の場合
                    Text(step.imageName)
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                } else {
                    // 絵文字の場合
                    Text(step.imageName)
                        .font(.system(size: 70))
                }
            }
            .scaleEffect(showAnimation ? 1.0 : 0.5)
            .rotationEffect(.degrees(showAnimation ? 0 : -180))
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showAnimation)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentStep)
            
            // タイトルと説明
            VStack(spacing: 12) {
                Text(step.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(step.description)
                    .font(.body)
                    .foregroundColor(.primary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(step.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .opacity(showAnimation ? 1.0 : 0.0)
            .offset(y: showAnimation ? 0 : 20)
            .animation(.easeInOut(duration: 0.6).delay(0.3), value: showAnimation)
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 20) {
            // スキップボタン
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPresented = false
                }
                // ハプティクスフィードバック
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }) {
                Text("スキップ")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1.5)
                    )
            }
            
            Spacer()
            
            // 戻る/次へボタン
            HStack(spacing: 15) {
                if currentStep > 0 {
                    Button(action: previousStep) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.caption)
                            Text("戻る")
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                        )
                    }
                }
                
                Button(action: nextStep) {
                    HStack(spacing: 8) {
                        Text(currentStep == tutorialSteps.count - 1 ? "始める" : "次へ")
                            .font(.body)
                            .fontWeight(.medium)
                        if currentStep < tutorialSteps.count - 1 {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.pink, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(color: .pink.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
    }
    
    private func nextStep() {
        // ハプティクスフィードバック
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        if currentStep < tutorialSteps.count - 1 {
            withAnimation(.easeInOut(duration: 0.4)) {
                showAnimation = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentStep += 1
                withAnimation(.easeInOut(duration: 0.6)) {
                    showAnimation = true
                }
            }
        } else {
            // 最後のステップ：チュートリアル終了
            withAnimation(.easeInOut(duration: 0.3)) {
                isPresented = false
            }
        }
    }
    
    private func previousStep() {
        // ハプティクスフィードバック
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        if currentStep > 0 {
            withAnimation(.easeInOut(duration: 0.4)) {
                showAnimation = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentStep -= 1
                withAnimation(.easeInOut(duration: 0.6)) {
                    showAnimation = true
                }
            }
        }
    }
}

struct TutorialStep {
    let title: String
    let description: String
    let imageName: String
    let subtitle: String
}

#Preview {
    TutorialView(isPresented: .constant(true))
}