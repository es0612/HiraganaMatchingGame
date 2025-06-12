import SwiftUI

struct AchievementsView: View {
    @State private var starUnlockService = StarUnlockService()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    let onBackPressed: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.indigo.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    headerView
                    
                    statisticsView
                    
                    achievementsGridView
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: onBackPressed) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            VStack {
                Text("実績・統計")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("あなたの成長記録")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // プレースホルダー
            Color.clear
                .frame(width: 44, height: 44)
        }
    }
    
    private var statisticsView: some View {
        let stats = starUnlockService.getStarStatistics()
        
        return VStack(spacing: 15) {
            Text("統計情報")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                statisticCard(
                    title: "総スター数",
                    value: "\(stats.totalStars)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                statisticCard(
                    title: "クリア済み",
                    value: "\(stats.totalLevelsCompleted)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                statisticCard(
                    title: "平均スター",
                    value: String(format: "%.1f", stats.averageStarsPerLevel),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
                
                statisticCard(
                    title: "最高連続",
                    value: "\(stats.highestStreak)",
                    icon: "flame.fill",
                    color: .red
                )
                
                statisticCard(
                    title: "プレイ時間",
                    value: formatTime(stats.totalTimePlayed),
                    icon: "clock.fill",
                    color: .orange
                )
                
                statisticCard(
                    title: "平均正解率",
                    value: "\(Int(stats.averageAccuracy * 100))%",
                    icon: "target",
                    color: .purple
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
                .shadow(radius: 5)
        )
    }
    
    private func statisticCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var achievementsGridView: some View {
        let unlockedAchievements = starUnlockService.getUnlockedAchievements()
        let allAchievements = Achievement.allCases
        
        return VStack(spacing: 15) {
            Text("実績")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("獲得した実績: \(unlockedAchievements.count)/\(allAchievements.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: isLandscape ? 3 : 2), spacing: 20) {
                ForEach(allAchievements, id: \.self) { achievement in
                    achievementCard(achievement, isUnlocked: unlockedAchievements.contains(achievement))
                }
            }
        }
    }
    
    private func achievementCard(_ achievement: Achievement, isUnlocked: Bool) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? achievement.iconColor : Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(isUnlocked ? 0.2 : 0.1), radius: 3)
                
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? .white : .gray)
            }
            
            VStack(spacing: 4) {
                Text(achievement.rawValue)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isUnlocked ? .primary : .gray)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            if isUnlocked {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("達成済み")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            } else {
                Text("未達成")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isUnlocked ? Color.white : Color.gray.opacity(0.1))
                .stroke(isUnlocked ? achievement.iconColor.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 2)
                .shadow(color: .black.opacity(isUnlocked ? 0.1 : 0.05), radius: 3)
        )
        .scaleEffect(isUnlocked ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isUnlocked)
    }
    
    // MARK: - Helper Functions
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        
        if minutes > 0 {
            return "\(minutes)分\(remainingSeconds)秒"
        } else {
            return "\(remainingSeconds)秒"
        }
    }
    
    // MARK: - Computed Properties
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
}

// MARK: - Achievement Extensions

extension Achievement {
    var iconColor: Color {
        switch self {
        case .firstCompletion: return .blue
        case .perfectScore: return .yellow
        case .speedRun: return .orange
        case .streak: return .red
        case .collector: return .green
        case .master: return .purple
        }
    }
}

#Preview {
    AchievementsView {
        print("Back pressed")
    }
}