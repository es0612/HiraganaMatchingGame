import SwiftUI

struct LevelSelectionView: View {
    @State private var levelProgressionService = LevelProgressionService()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    let onLevelSelected: (Int) -> Void
    let onCharacterCollectionPressed: () -> Void
    let onAchievementsPressed: () -> Void
    let onSettingsPressed: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    headerView
                    
                    progressOverviewView
                    
                    Spacer()
                    
                    levelGridView
                        .accessibilityIdentifier("レベル選択グリッド")
                    
                    Spacer()
                    
                    footerView
                }
                .padding()
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
                .fill(Color.white.opacity(0.8))
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
        
        // デバッグ出力
        if level <= 5 {
            let previousLevel = level - 1
            let previousStars = previousLevel > 0 ? levelProgressionService.getStarsForLevel(previousLevel) : -1
            print("🔓 Level \(level): unlocked=\(isUnlocked), stars=\(stars), previous(\(previousLevel))=\(previousStars)")
        }
        
        return Button(action: {
            if isUnlocked {
                onLevelSelected(level)
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isUnlocked ? Color.white : Color.gray.opacity(0.3))
                        .frame(width: levelButtonSize, height: levelButtonSize)
                        .shadow(color: .black.opacity(isUnlocked ? 0.1 : 0.05), radius: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(isRecommended ? Color.orange : Color.clear, lineWidth: 3)
                        )
                    
                    VStack(spacing: 4) {
                        Text("\(level)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(isUnlocked ? .primary : .secondary)
                        
                        if isUnlocked {
                            starsView(stars: stars)
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Text(config.title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
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
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(index < stars ? .yellow : .gray.opacity(0.3))
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
            
            HStack(spacing: 15) {
                Button("コレクション") {
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