import Foundation
import AVFoundation

enum AudioServiceError: Error {
    case fileNotFound
    case playbackFailed
    case audioSessionSetupFailed
}

class AudioService: ObservableObject {
    @Published var isSoundEnabled: Bool = true
    @Published var currentVolume: Float = 1.0
    @Published var playbackSpeed: Float = 1.0
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var audioSession: AVAudioSession
    
    init() {
        self.audioSession = AVAudioSession.sharedInstance()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func hasAudioFile(for character: String) -> Bool {
        // 開発段階では全ての文字に音声ファイルがあると仮定
        // 実際の実装では Bundle.main.path で確認
        let fileName = "\(character).mp3"
        return Bundle.main.path(forResource: fileName, ofType: nil) != nil
    }
    
    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
        if !enabled {
            stopAllAudio()
        }
    }
    
    func setVolume(_ volume: Float) {
        currentVolume = max(0.0, min(1.0, volume))
        updateAllPlayersVolume()
    }
    
    func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = max(0.5, min(2.0, speed))
        updateAllPlayersSpeed()
    }
    
    func prepareAudio(for character: String) async throws {
        guard hasAudioFile(for: character) else {
            throw AudioServiceError.fileNotFound
        }
        
        let fileName = "\(character).mp3"
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            throw AudioServiceError.fileNotFound
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = currentVolume
            player.rate = playbackSpeed
            audioPlayers[character] = player
        } catch {
            throw AudioServiceError.playbackFailed
        }
    }
    
    func playAudio(for character: String) async {
        guard isSoundEnabled else { return }
        
        do {
            if audioPlayers[character] == nil {
                try await prepareAudio(for: character)
            }
            
            guard let player = audioPlayers[character] else { return }
            
            await MainActor.run {
                player.stop()
                player.currentTime = 0
                player.play()
            }
        } catch {
            print("Failed to play audio for \(character): \(error)")
        }
    }
    
    func isAudioReady(for character: String) -> Bool {
        return audioPlayers[character] != nil
    }
    
    func stopAllAudio() {
        for (_, player) in audioPlayers {
            player.stop()
        }
    }
    
    func pauseAllAudio() {
        for (_, player) in audioPlayers {
            player.pause()
        }
    }
    
    func resumeAllAudio() {
        guard isSoundEnabled else { return }
        
        for (_, player) in audioPlayers {
            if player.currentTime > 0 {
                player.play()
            }
        }
    }
    
    private func updateAllPlayersVolume() {
        for (_, player) in audioPlayers {
            player.volume = currentVolume
        }
    }
    
    private func updateAllPlayersSpeed() {
        for (_, player) in audioPlayers {
            player.rate = playbackSpeed
        }
    }
    
    func preloadAudioForLevel(_ level: Int) async {
        let levelConfig = HiraganaDataManager.shared.getLevelConfiguration()
        guard let characters = levelConfig[level] else { return }
        
        for character in characters {
            do {
                try await prepareAudio(for: character)
            } catch {
                print("Failed to preload audio for \(character): \(error)")
            }
        }
    }
    
    deinit {
        stopAllAudio()
        try? audioSession.setActive(false)
    }
}