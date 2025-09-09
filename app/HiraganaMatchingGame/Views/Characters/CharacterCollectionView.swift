import SwiftUI

struct CharacterCollectionView: View {
    @State private var starUnlockService = StarUnlockService()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme
    
    let onBackPressed: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [
                        colorScheme == .dark ? Color.green.opacity(0.05) : Color.green.opacity(0.1),
                        colorScheme == .dark ? Color.cyan.opacity(0.05) : Color.cyan.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    headerView
                    
                    progressSummaryView
                    
                    characterGridView
                    
                    Spacer()
                    
                    footerView
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
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
            }
            
            Spacer()
            
            VStack {
                Text("ひらがなコレクション")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                
                Text("集めた文字たち")
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
            }
            
            Spacer()
            
            // プレースホルダー（左右対称にするため）
            Color.clear
                .frame(width: 44, height: 44)
        }
    }
    
    private var progressSummaryView: some View {
        let progress = starUnlockService.getUnlockProgress()
        
        return VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text("解放済み文字")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                    
                    Text("\(progress.unlockedCount)/\(progress.totalCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("進捗")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                    
                    Text("\(Int(progress.progressPercentage * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            ProgressView(value: progress.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .frame(height: 8)
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            HStack {
                Text("現在: \(progress.currentGroup)")
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                
                Spacer()
                
                if let nextGroup = progress.nextGroup,
                   let nextUnlock = starUnlockService.getNextUnlockInfo() {
                    Text("次: \(nextGroup) (\(nextUnlock.requiredStars)スター)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(.systemGray6).opacity(0.3) : Color.white.opacity(0.8))
                .shadow(
                    color: colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.1),
                    radius: 5
                )
        )
    }
    
    private var characterGridView: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: isLandscape ? 10 : 6)
        let allCharacters = getAllHiraganaCharacters()
        
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(allCharacters, id: \.self) { character in
                    characterCard(character)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func characterCard(_ character: String) -> some View {
        let isUnlocked = starUnlockService.isCharacterUnlocked(character)
        let group = getCharacterGroup(character)
        
        return VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isUnlocked ?
                        (colorScheme == .dark ? Color(.systemGray6) : Color.white) :
                        (colorScheme == .dark ? Color(.systemGray5).opacity(0.3) : Color.gray.opacity(0.3))
                    )
                    .frame(width: characterCardSize, height: characterCardSize)
                    .shadow(
                        color: colorScheme == .dark ?
                            .white.opacity(isUnlocked ? 0.1 : 0.05) :
                            .black.opacity(isUnlocked ? 0.1 : 0.05),
                        radius: 3
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(getGroupColor(group), lineWidth: isUnlocked ? 2 : 0)
                    )
                
                if isUnlocked {
                    Text(character)
                        .font(.system(size: characterCardSize * 0.5, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isUnlocked)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: characterCardSize * 0.3))
                        .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                        .rotationEffect(.degrees(-10))
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isUnlocked)
                }
                
                if isUnlocked {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                                .scaleEffect(1.2)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1), value: isUnlocked)
                        }
                        Spacer()
                    }
                    .padding(4)
                }
            }
            
            Text(getCharacterReading(character))
                .font(.caption2)
                .foregroundColor(isUnlocked ?
                    (colorScheme == .dark ? .white : .primary) :
                    (colorScheme == .dark ? .gray : .secondary)
                )
                .lineLimit(1)
        }
    }
    
    private var footerView: some View {
        VStack(spacing: 15) {
            if let nextUnlock = starUnlockService.getNextUnlockInfo() {
                VStack(spacing: 8) {
                    Text("次の解放まで")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                    
                    Text("\(nextUnlock.requiredStars)スター必要")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                    
                    HStack(spacing: 4) {
                        ForEach(nextUnlock.charactersToUnlock.prefix(5), id: \.self) { character in
                            Text(character)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange.opacity(0.2))
                                )
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.orange.opacity(0.1))
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
            }
            
            // 実績表示
            achievementsView
        }
    }
    
    private var achievementsView: some View {
        let achievements = starUnlockService.getUnlockedAchievements()
        
        return VStack(spacing: 10) {
            if !achievements.isEmpty {
                Text("獲得した実績")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(achievements), id: \.self) { achievement in
                            achievementBadge(achievement)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("レベルをクリアして実績を獲得しよう！")
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private func achievementBadge(_ achievement: Achievement) -> some View {
        VStack(spacing: 4) {
            Image(systemName: achievement.iconName)
                .font(.title2)
                .foregroundColor(.yellow)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                )
            
            Text(achievement.rawValue)
                .font(.caption2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
                .frame(width: 60)
        }
    }
    
    // MARK: - Helper Functions
    
    private func getAllHiraganaCharacters() -> [String] {
        let groups = [
            ["あ", "い", "う", "え", "お"],
            ["か", "き", "く", "け", "こ"],
            ["さ", "し", "す", "せ", "そ"],
            ["た", "ち", "つ", "て", "と"],
            ["な", "に", "ぬ", "ね", "の"],
            ["は", "ひ", "ふ", "へ", "ほ"],
            ["ま", "み", "む", "め", "も"],
            ["や", "ゆ", "よ"],
            ["ら", "り", "る", "れ", "ろ"],
            ["わ", "ゐ", "ゑ", "を", "ん"]
        ]
        return groups.flatMap { $0 }
    }
    
    private func getCharacterGroup(_ character: String) -> String {
        let groupMap: [String: [String]] = [
            "あ行": ["あ", "い", "う", "え", "お"],
            "か行": ["か", "き", "く", "け", "こ"],
            "さ行": ["さ", "し", "す", "せ", "そ"],
            "た行": ["た", "ち", "つ", "て", "と"],
            "な行": ["な", "に", "ぬ", "ね", "の"],
            "は行": ["は", "ひ", "ふ", "へ", "ほ"],
            "ま行": ["ま", "み", "む", "め", "も"],
            "や行": ["や", "ゆ", "よ"],
            "ら行": ["ら", "り", "る", "れ", "ろ"],
            "わ行": ["わ", "ゐ", "ゑ", "を", "ん"]
        ]
        
        for (group, characters) in groupMap {
            if characters.contains(character) {
                return group
            }
        }
        return "その他"
    }
    
    private func getGroupColor(_ group: String) -> Color {
        switch group {
        case "あ行": return .red
        case "か行": return .orange
        case "さ行": return .yellow
        case "た行": return .green
        case "な行": return .cyan
        case "は行": return .blue
        case "ま行": return .purple
        case "や行": return .pink
        case "ら行": return .brown
        case "わ行": return .gray
        default: return .black
        }
    }
    
    private func getCharacterReading(_ character: String) -> String {
        let readings: [String: String] = [
            "あ": "あり", "い": "いぬ", "う": "うさぎ", "え": "えび", "お": "おに",
            "か": "かに", "き": "きりん", "く": "くま", "け": "けーき", "こ": "こま",
            "さ": "さる", "し": "しか", "す": "すいか", "せ": "せみ", "そ": "そら",
            "た": "たこ", "ち": "ちょう", "つ": "つる", "て": "て", "と": "とけい",
            "な": "なす", "に": "にんじん", "ぬ": "ぬいぐるみ", "ね": "ねこ", "の": "のはら",
            "は": "はな", "ひ": "ひよこ", "ふ": "ふうせん", "へ": "へび", "ほ": "ほし",
            "ま": "まめ", "み": "みかん", "む": "むし", "め": "めがね", "も": "もも",
            "や": "やま", "ゆ": "ゆき", "よ": "よる",
            "ら": "らいおん", "り": "りんご", "る": "るーれっと", "れ": "れもん", "ろ": "ろうそく",
            "わ": "わに", "ゐ": "ゐ", "ゑ": "ゑ", "を": "を", "ん": "ん"
        ]
        return readings[character] ?? character
    }
    
    // MARK: - Computed Properties
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
    
    private var characterCardSize: CGFloat {
        isLandscape ? 50 : 60
    }
}

#Preview {
    CharacterCollectionView {
        print("Back pressed")
    }
}
