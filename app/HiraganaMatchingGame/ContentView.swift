//
//  ContentView.swift
//  HiraganaMatchingGame
//  
//  Created on 2025/06/12
//


import SwiftUI
import SwiftData

enum AppScreen: Equatable {
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
    @State private var audioService: AudioService?
    @State private var showTutorial = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                switch currentScreen {
            case .levelSelection:
                LevelSelectionView(
                    levelSelectionViewModel: levelSelectionViewModel,
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
                .onChange(of: currentScreen) { _ in
                    if currentScreen == .levelSelection {
                        loadUserSettings()
                    }
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
                    loadUserSettings()
                    currentScreen = .levelSelection
                }
                }
            }
            .opacity(showLaunchScreen ? 0 : 1)
            .sheet(isPresented: $showTutorial) {
                TutorialView(isPresented: $showTutorial)
                    .onAppear {
                        // チュートリアル開始時にBGMを一時停止
                        audioService?.stopBackgroundMusic()
                    }
                    .onDisappear {
                        userSettings?.markTutorialAsCompleted()
                        userSettings?.save()
                        // チュートリアル終了時にBGMを再開
                        if userSettings?.musicEnabled == true {
                            audioService?.startBackgroundMusic()
                        }
                    }
            }
            
            // スプラッシュ画面
            if showLaunchScreen {
                LaunchView {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showLaunchScreen = false
                    }
                    
                    // スプラッシュ画面後にチュートリアルチェック
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        checkAndShowTutorial()
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
            settings.load() // UserDefaultsから最新設定を読み込み
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
        
        // AudioServiceを初期化してBGMを開始
        if let settings = userSettings {
            audioService = AudioService(userSettings: settings)
        }
    }
    
    private func checkAndShowTutorial() {
        guard let settings = userSettings else { return }
        
        // 初回起動時でチュートリアルを見たことがない場合に表示
        if !settings.hasSeenTutorial {
            showTutorial = true
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GameProgress.self, inMemory: true)
}
