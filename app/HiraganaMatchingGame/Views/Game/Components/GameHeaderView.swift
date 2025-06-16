//
//  GameHeaderView.swift
//  HiraganaMatchingGame
//
//  Created on 2025/06/16
//

import SwiftUI

struct GameHeaderView: View {
    let currentLevel: Int
    let currentProgress: Double
    let currentPotentialStars: Int
    let timeRemaining: Int
    let isTimeLimitEnabled: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            levelBadgeView
            
            Spacer()
            
            VStack(spacing: 4) {
                progressBarView
                
                if isTimeLimitEnabled {
                    timeDisplayView
                }
            }
            
            Spacer()
            
            starsView
        }
    }
    
    private var levelBadgeView: some View {
        Text("レベル \(currentLevel)")
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.9), Color.orange.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            )
    }
    
    private var progressBarView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 10)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.8), Color.blue.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * currentProgress, height: 10)
                    .animation(.easeInOut(duration: 0.3), value: currentProgress)
            }
        }
        .frame(height: 10)
        .frame(maxWidth: 200)
    }
    
    private var starsView: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: "star.fill")
                    .foregroundColor(index < currentPotentialStars ? .yellow : .gray.opacity(0.3))
                    .font(.title2)
            }
        }
    }
    
    private var timeDisplayView: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.caption)
                .foregroundColor(.orange)
            Text(formatTime(timeRemaining))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    GameHeaderView(
        currentLevel: 1,
        currentProgress: 0.6,
        currentPotentialStars: 2,
        timeRemaining: 120,
        isTimeLimitEnabled: true
    )
    .padding()
}