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
    case settings
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentScreen: AppScreen = .levelSelection
    @State private var levelSelectionViewModel = LevelSelectionViewModel()
    @State private var userSettings: UserSettings?
    @State private var showLaunchScreen = true
    
    var body: some View {
        ZStack {
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
                    },
                    onSettingsPressed: {
                        currentScreen = .settings
                    }
                )
                .onAppear {
                    levelSelectionViewModel.loadProgress(from: modelContext)
                    loadUserSettings()
                }
                
            case .game(let level):
                if let settings = userSettings {
                    GameView(
                        selectedLevel: level,
                        levelProgressionService: levelSelectionViewModel.levelProgressionService,
                        userSettings: settings,
                        onGameComplete: { completedLevel, stars in
                            levelSelectionViewModel.completeLevel(completedLevel, stars: stars)
                            currentScreen = .levelSelection
                        },
                        onBackToLevelSelection: {
                            currentScreen = .levelSelection
                        }
                    )
                } else {
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
                
            case .characterCollection:
                CharacterCollectionView {
                    currentScreen = .levelSelection
                }
                
            case .achievements:
                AchievementsView {
                    currentScreen = .levelSelection
                }
                
            case .settings:
                SettingsView(modelContext: modelContext) {
                    currentScreen = .levelSelection
                }
                }
            }
            .opacity(showLaunchScreen ? 0 : 1)
            
            // スプラッシュ画面
            if showLaunchScreen {
                LaunchView {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showLaunchScreen = false
                    }
                }
                .transition(.opacity)
            }
        }
    }
    
    private func loadUserSettings() {
        let descriptor = FetchDescriptor<UserSettings>()
        let existingSettings = try? modelContext.fetch(descriptor)
        
        if let settings = existingSettings?.first {
            userSettings = settings
        } else {
            let newSettings = UserSettings()
            modelContext.insert(newSettings)
            userSettings = newSettings
            
            do {
                try modelContext.save()
            } catch {
                print("Failed to save user settings: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GameProgress.self, inMemory: true)
}
