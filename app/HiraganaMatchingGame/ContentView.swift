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
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentScreen: AppScreen = .levelSelection
    @State private var levelSelectionViewModel = LevelSelectionViewModel()
    
    var body: some View {
        NavigationStack {
            switch currentScreen {
            case .levelSelection:
                LevelSelectionView { selectedLevel in
                    currentScreen = .game(level: selectedLevel)
                }
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
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GameProgress.self, inMemory: true)
}
