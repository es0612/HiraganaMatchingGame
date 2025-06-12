//
//  ContentView.swift
//  HiraganaMatchingGame
//  
//  Created on 2025/06/12
//


import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        GameView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GameProgress.self, inMemory: true)
}
