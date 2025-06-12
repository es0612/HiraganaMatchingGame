//
//  HiraganaMatchingGameApp.swift
//  HiraganaMatchingGame
//  
//  Created on 2025/06/12
//


import SwiftUI
import SwiftData

@main
struct HiraganaMatchingGameApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GameProgress.self,
            GameLevel.self,
            UserSettings.self,
            Character.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
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
