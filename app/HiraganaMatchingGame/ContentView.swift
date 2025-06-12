//
//  ContentView.swift
//  HiraganaMatchingGame
//  
//  Created on 2025/06/12
//


import SwiftUI
import SwiftData

enum AppScreen {
    case levelSelection
    case game(level: Int)
    case characterCollection
    case achievements
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentScreen: AppScreen = .levelSelection
    @State private var levelSelectionViewModel = LevelSelectionViewModel()
    
    var body: some View {
        NavigationStack {
            switch currentScreen {
            case .levelSelection:
                LevelSelectionView(
                    onLevelSelected: { selectedLevel in
                        currentScreen = .game(level: selectedLevel)
                    },
                    onCharacterCollectionPressed: {
                        currentScreen = .characterCollection
                    },
                    onAchievementsPressed: {
                        currentScreen = .achievements
                    }
                )
                .onAppear {
                    levelSelectionViewModel.loadProgress(from: modelContext)
                }
                
            case .game(let level):
                GameView(
                    selectedLevel: level,
                    levelProgressionService: levelSelectionViewModel.levelProgressionService,
                    onGameComplete: { completedLevel, stars in
                        levelSelectionViewModel.completeLevel(completedLevel, stars: stars)
                        currentScreen = .levelSelection
                    },
                    onBackToLevelSelection: {
                        currentScreen = .levelSelection
                    }
                )
                
            case .characterCollection:
                CharacterCollectionView {
                    currentScreen = .levelSelection
                }
                
            case .achievements:
                AchievementsView {
                    currentScreen = .levelSelection
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GameProgress.self, inMemory: true)
}
