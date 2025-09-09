//
//  AudioPlayer.swift
//  HiraganaMatchingGame
//
//

import AVFoundation
import Foundation

enum AudioPlayerError: Error {
    case fileNotFound
    case playbackFailed
    case sessionSetupFailed
}

class AudioPlayer: ObservableObject {
    @Published var isEnabled: Bool = true
    @Published var volume: Float = 1.0
    @Published var playbackSpeed: Float = 1.0
    
    private let isTestMode: Bool
    private var audioPlayers: [String: AVAudioPlayer?] = [:]
    private var audioSession: AVAudioSession
    
    init(isTestMode: Bool = false) {
        self.isTestMode = isTestMode
        self.audioSession = AVAudioSession.sharedInstance()
        
        if !isTestMode {
            setupAudioSession()
        }
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func hasAudioFile(for identifier: String) -> Bool {
        guard !isTestMode else { return true }
        
        _ = "\(identifier).mp3"
        return Bundle.main.path(forResource: identifier, ofType: "mp3") != nil
    }
    
    func prepareAudio(for identifier: String) async throws {
        guard !isTestMode else { return }
        guard isEnabled else { return }
        
        if audioPlayers[identifier] != nil {
            return // Already prepared
        }
        
        do {
            let audioData = try await loadAudioData(for: identifier)
            let player = try AVAudioPlayer(data: audioData)
            player.volume = volume
            player.rate = playbackSpeed
            player.prepareToPlay()
            
            audioPlayers[identifier] = player
            print("🎵 Audio prepared for: \(identifier)")
        } catch {
            print("Failed to prepare audio for \(identifier): \(error)")
            throw AudioPlayerError.playbackFailed
        }
    }
    
    func playAudio(for identifier: String) async {
        guard !isTestMode else { return }
        guard isEnabled else {
            print("🔇 Audio disabled, skipping playback for: \(identifier)")
            return
        }
        
        do {
            try await prepareAudio(for: identifier)
            
            if let player = audioPlayers[identifier] {
                player?.volume = volume
                player?.rate = playbackSpeed
                player?.play()
                print("🎵 Playing audio: \(identifier)")
            }
        } catch {
            print("Failed to play audio for \(identifier): \(error)")
        }
    }
    
    func stopAllAudio() {
        audioPlayers.values.forEach { player in
            player?.stop()
        }
        print("🔇 All audio stopped")
    }
    
    func isAudioReady(for identifier: String) -> Bool {
        return audioPlayers[identifier] != nil
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
    
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        // Update all existing players
        audioPlayers.values.forEach { player in
            player?.volume = volume
        }
    }
    
    func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = max(0.5, min(2.0, speed))
        // Update all existing players
        audioPlayers.values.forEach { player in
            player?.rate = playbackSpeed
        }
    }
    
    // MARK: - Private Methods
    
    private func loadAudioData(for identifier: String) async throws -> Data {
        if hasAudioFile(for: identifier) {
            guard let path = Bundle.main.path(forResource: identifier, ofType: "mp3"),
                  let audioData = NSData(contentsOfFile: path) as Data? else {
                throw AudioPlayerError.fileNotFound
            }
            return audioData
        } else {
            // Generate mock audio data for development
            return generateMockAudio(for: identifier)
        }
    }
    
    private func generateMockAudio(for identifier: String) -> Data {
        // Generate a simple beep sound as mock audio
        let frequency = 440.0 + Double(identifier.hashValue % 200) // Vary frequency by identifier
        return generateBeepSound(frequency: frequency, duration: 0.5)
    }
    
    private func generateBeepSound(frequency: Double, duration: Double) -> Data {
        let sampleRate = 44100.0
        let samples = Int(sampleRate * duration)
        var audioData = Data()
        
        for i in 0..<samples {
            let time = Double(i) / sampleRate
            let sample = sin(2.0 * Double.pi * frequency * time)
            let scaledSample = Int16(sample * 32767.0)
            
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        return audioData
    }
    
    deinit {
        stopAllAudio()
    }
}
