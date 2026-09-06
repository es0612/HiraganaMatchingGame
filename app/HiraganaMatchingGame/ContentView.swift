//
//  ContentView.swift
//  HiraganaMatchingGame
//  
//

import SwiftData
import SwiftUI

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
    @State private var gameViewId = UUID()
    @State private var migrationService = DataMigrationService()
    @State private var isMigrating = false
    
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
                    .onChange(of: currentScreen) {
                        if currentScreen == .levelSelection {
                            loadUserSettings()
                            // レベル選択画面に戻った時はメニューBGMを確保
                            if let settings = userSettings, settings.musicEnabled {
                                audioService = AudioService.createWithSettings(settings, startBGM: false)
                                audioService?.switchToMenuBGM()
                            }
                        }
                    }
                
                case .game(let level):
                    GameView(
                        selectedLevel: level,
                        levelProgressionService: levelSelectionViewModel.levelProgressionService,
                        userSettings: userSettings,
                        onGameComplete: { _, _ in
                            // Level completion is handled by GameViewModel
                            // Just save the progress - navigation handled by GameView
                            levelSelectionViewModel.saveProgress()
                        },
                        onBackToLevelSelection: {
                            currentScreen = .levelSelection
                        },
                        onRestart: {
                            // 同じレベルを再開（画面状態は変更せず、ViewをリフレッシュするためにIDを更新）
                            gameViewId = UUID()
                        },
                        onNextLevel: {
                            let nextLevel = level + 1
                            if nextLevel <= levelSelectionViewModel.levelProgressionService.getTotalLevels() {
                                currentScreen = .game(level: nextLevel)
                                gameViewId = UUID()
                            }
                        }
                    )
                    .id(gameViewId)
                
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
                    .onDisappear {
                        userSettings?.markTutorialAsCompleted()
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to persist tutorial completion: \(error)")
                        }
                    }
            }
            
            // スプラッシュ画面
            if showLaunchScreen {
                LaunchView {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showLaunchScreen = false
                    }
                    
                    // スプラッシュ画面終了時にメニューBGMに切り替え
                    audioService?.switchToMenuBGM()
                    
                    // スプラッシュ画面後にチュートリアルチェック
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        checkAndShowTutorial()
                    }
                }
                .transition(.opacity)
                .onAppear {
                    // データマイグレーション実行
                    performDataMigrationIfNeeded()
                    // スプラッシュ画面表示開始時にBGMを開始
                    loadUserSettings()
                    if let settings = userSettings {
                        audioService = AudioService.createWithSettings(settings, startBGM: true)
                    }
                }
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
    
    private func checkAndShowTutorial() {
        guard let settings = userSettings else { return }
        
        // 初回起動時でチュートリアルを見たことがない場合に表示
        if !settings.hasSeenTutorial {
            showTutorial = true
        }
    }
    
    private func performDataMigrationIfNeeded() {
        guard migrationService.isMigrationNeeded() else {
            return
        }
        
        isMigrating = true
        
        Task {
            do {
                try await migrationService.performMigration(modelContext: modelContext)
                
                // Validate migration
                let isValid = try migrationService.validateMigration(modelContext: modelContext)
                if isValid {
                    // Clean up old data after successful migration
                    try migrationService.cleanupOldData(modelContext: modelContext)
                    print("✅ Data migration completed and validated successfully")
                } else {
                    print("⚠️ Migration validation failed")
                }
            } catch {
                print("❌ Migration failed: \(error)")
                // In production, you might want to show an error alert to the user
            }
            
            await MainActor.run {
                isMigrating = false
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GameProgress.self, inMemory: true)
}
