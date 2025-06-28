//
//  ParticleEffectView.swift
//  HiraganaMatchingGame
//
//

import SwiftUI

struct ParticleEffectView: View {
    let isCorrect: Bool
    @State private var particles: [Particle] = []
    @State private var animationTrigger = false
    
    private struct Particle: Identifiable {
        let id = UUID()
        var x: Double
        var y: Double
        var velocityX: Double
        var velocityY: Double
        var scale: Double
        var opacity: Double
        var rotation: Double
        let emoji: String
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Text(particle.emoji)
                    .font(.system(size: 24))
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
                    .rotationEffect(.degrees(particle.rotation))
                    .position(x: particle.x, y: particle.y)
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
        .onChange(of: isCorrect) { _ in
            particles.removeAll()
            createParticles()
            animateParticles()
        }
    }
    
    private func createParticles() {
        let particleCount = isCorrect ? 15 : 8
        let emojis = isCorrect ? ["⭐", "✨", "🎉", "🌟", "💫"] : ["❌", "💔", "😢"]
        
        particles = (0..<particleCount).map { _ in
            Particle(
                x: 200,  // 中央から開始
                y: 200,
                velocityX: Double.random(in: -100...100),
                velocityY: Double.random(in: -150...(-50)),
                scale: Double.random(in: 0.5...1.5),
                opacity: 1.0,
                rotation: 0,
                emoji: emojis.randomElement() ?? "⭐"
            )
        }
    }
    
    private func animateParticles() {
        // テスト環境では即座にクリア
        if TestUtils.isTestEnvironment {
            particles.removeAll()
            return
        }
        
        withAnimation(.easeOut(duration: 2.0)) {
            animationTrigger.toggle()
            
            for i in particles.indices {
                particles[i].x += particles[i].velocityX * 2
                particles[i].y += particles[i].velocityY * 2
                particles[i].opacity = 0
                particles[i].scale *= 0.3
                particles[i].rotation = Double.random(in: 0...360)
            }
        }
        
        // パーティクルをクリア
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            particles.removeAll()
        }
    }
}

struct ConfettiView: View {
    @State private var animate = false
    @State private var particles: [ConfettiParticle] = []
    
    private struct ConfettiParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var color: Color
        var scale: CGFloat
        var rotation: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Rectangle()
                        .fill(particle.color)
                        .frame(width: 8, height: 4)
                        .scaleEffect(particle.scale)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                createConfetti(in: geometry.size)
                animateConfetti()
            }
        }
    }
    
    private func createConfetti(in size: CGSize) {
        let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
        
        particles = (0..<50).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...size.width),
                y: -10,
                color: colors.randomElement() ?? .blue,
                scale: CGFloat.random(in: 0.5...1.5),
                rotation: Double.random(in: 0...360)
            )
        }
    }
    
    private func animateConfetti() {
        // テスト環境では即座にクリア
        if TestUtils.isTestEnvironment {
            particles.removeAll()
            return
        }
        
        withAnimation(.easeOut(duration: 3.0)) {
            for i in particles.indices {
                particles[i].y += CGFloat.random(in: 500...800)
                particles[i].x += CGFloat.random(in: -100...100)
                particles[i].rotation += Double.random(in: 180...720)
                particles[i].scale *= 0.1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            particles.removeAll()
        }
    }
}

#Preview {
    ParticleEffectView(isCorrect: true)
}