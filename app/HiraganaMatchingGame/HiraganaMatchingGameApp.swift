//
//  HiraganaMatchingGameApp.swift
//  HiraganaMatchingGame
//  
//


import SwiftUI
import SwiftData

@main
struct HiraganaMatchingGameApp: App {
    var sharedModelContainer: ModelContainer = {
        // テスト環境かどうかを判定
        let isTestEnvironment = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        
        let schema = Schema([
            GameProgress.self,
            GameLevel.self,
            UserSettings.self,
            Character.self,
            // New unified data models
            UnifiedGameProgress.self,
            AchievementRecord.self,
            LevelStats.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema, 
            isStoredInMemoryOnly: isTestEnvironment
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("ModelContainer creation error: \(error)")
            // テスト環境では、より簡単な設定でリトライ
            if isTestEnvironment {
                do {
                    return try ModelContainer(for: schema, configurations: [ModelConfiguration(isStoredInMemoryOnly: true)])
                } catch {
                    fatalError("Could not create test ModelContainer: \(error)")
                }
            }
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// テスト用のModelContainer作成関数
@available(iOS 17.0, *)
func createTestModelContainer() throws -> ModelContainer {
    let schema = Schema([
        GameProgress.self,
        GameLevel.self,
        UserSettings.self,
        Character.self,
        // New unified data models
        UnifiedGameProgress.self,
        AchievementRecord.self,
        LevelStats.self,
    ])
    
    let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [modelConfiguration])
}
