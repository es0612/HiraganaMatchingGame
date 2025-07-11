import SwiftUI

struct LevelSelectionView: View {
    @State var levelSelectionViewModel: LevelSelectionViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme
    
    let onLevelSelected: (Int) -> Void
    let onCharacterCollectionPressed: () -> Void
    let onAchievementsPressed: () -> Void
    let onSettingsPressed: () -> Void
    
    private var levelProgressionService: LevelProgressionService {
        levelSelectionViewModel.levelProgressionService
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: colorScheme == .dark ? [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05)
                    ] : [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerView
                        
                        progressOverviewView
                        
                        levelGridView
                            .accessibilityIdentifier("レベル選択グリッド")
                        
                        footerView
                            .padding(.bottom, max(geometry.safeAreaInsets.bottom, 20))
                    }
                    .padding()
                }
                .accessibilityIdentifier("レベル選択画面")
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("レベルを選んでね！")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("ひらがなをマスターしよう")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private var progressOverviewView: some View {
        VStack(spacing: 15) {
            HStack {
                progressBadge(
                    title: "総スター数",
                    value: "\(levelProgressionService.getTotalStars())",
                    icon: "star.fill",
                    color: .yellow
                )
                
                Spacer()
                
                progressBadge(
                    title: "クリア済み",
                    value: "\(levelProgressionService.getProgressionStats().completedLevels)/\(levelProgressionService.getTotalLevels())",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            
            ProgressView(value: levelProgressionService.getProgressionStats().completionPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 8)
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white.opacity(0.8))
                .shadow(radius: 5)
        )
    }
    
    private func progressBadge(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 5) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var levelGridView: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: isLandscape ? 5 : 3)
        
        return LazyVGrid(columns: columns, spacing: 15) {
            ForEach(1...levelProgressionService.getTotalLevels(), id: \.self) { level in
                levelButton(for: level)
            }
        }
    }
    
    private func levelButton(for level: Int) -> some View {
        let isUnlocked = levelProgressionService.isLevelUnlocked(level)
        let stars = levelProgressionService.getStarsForLevel(level)
        let config = levelProgressionService.getLevelConfiguration(level)
        let isRecommended = levelProgressionService.getRecommendedNextLevel() == level
        
        
        return Button(action: {
            if isUnlocked {
                // タップ時のハプティクスフィードバック
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    onLevelSelected(level)
                }
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isUnlocked ? 
                            (colorScheme == .dark ? Color(.systemGray6) : Color.white) : 
                            (colorScheme == .dark ? Color(.systemGray5).opacity(0.3) : Color.gray.opacity(0.3))
                        )
                        .frame(width: levelButtonSize, height: levelButtonSize)
                        .shadow(
                            color: colorScheme == .dark ? 
                                Color.white.opacity(isUnlocked ? 0.1 : 0.05) : 
                                Color.black.opacity(isUnlocked ? 0.1 : 0.05), 
                            radius: colorScheme == .dark ? 1 : 3
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(isRecommended ? Color.orange : Color.clear, lineWidth: 3)
                                .scaleEffect(isRecommended ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isRecommended)
                        )
                    
                    VStack(spacing: 4) {
                        Text("\(level)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(
                                isUnlocked ? 
                                    (colorScheme == .dark ? Color.white : Color.black) : 
                                    (colorScheme == .dark ? Color.gray : Color.secondary)
                            )
                        
                        if isUnlocked {
                            starsView(stars: stars)
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.title3)
                                .foregroundColor(colorScheme == .dark ? Color.gray : Color.secondary)
                        }
                    }
                }
                
                Text(config.title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(
                        isUnlocked ? 
                            (colorScheme == .dark ? Color.white : Color.primary) : 
                            (colorScheme == .dark ? Color.gray : Color.secondary)
                    )
                    .frame(height: 30)
                
                if isRecommended && isUnlocked {
                    Text("おすすめ")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.orange)
                        )
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isUnlocked)
    }
    
    private func starsView(stars: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundColor(index < stars ? .yellow : .gray.opacity(0.3))
                    .scaleEffect(index < stars ? 1.2 : 1.0)
                    .rotationEffect(.degrees(index < stars ? 360 : 0))
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                        .delay(Double(index) * 0.1), 
                        value: stars
                    )
            }
        }
    }
    
    private var footerView: some View {
        VStack(spacing: 15) {
            if levelProgressionService.getProgressionStats().completedLevels > 0 {
                Text("素晴らしい！これまでに\(levelProgressionService.getTotalStars())個のスターを獲得しました！")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("レベル1から始めよう！")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    Button("コレクション") {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        onCharacterCollectionPressed()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.green.opacity(0.8))
                    )
                    
                    Button("実績") {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        onAchievementsPressed()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.purple.opacity(0.8))
                    )
                    
                    Button("設定") {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        onSettingsPressed()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.gray.opacity(0.6))
                    )
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            levelSelectionViewModel.refreshProgress()
        }
    }
    
    // MARK: - Computed Properties
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
    
    private var levelButtonSize: CGFloat {
        isLandscape ? 60 : 80
    }
}

#Preview {
    LevelSelectionView(
        levelSelectionViewModel: LevelSelectionViewModel(),
        onLevelSelected: { level in
            print("Selected level: \(level)")
        },
        onCharacterCollectionPressed: {
            print("Character collection pressed")
        },
        onAchievementsPressed: {
            print("Achievements pressed")
        },
        onSettingsPressed: {
            print("Settings pressed")
        }
    )
}