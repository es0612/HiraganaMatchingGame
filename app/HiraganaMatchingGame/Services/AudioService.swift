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
    
    private var userSettings: UserSettings?
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var audioSession: AVAudioSession
    private var effectPlayer: AVAudioPlayer?
    
    init() {
        self.audioSession = AVAudioSession.sharedInstance()
        setupAudioSession()
    }
    
    init(userSettings: UserSettings) {
        self.audioSession = AVAudioSession.sharedInstance()
        self.userSettings = userSettings
        setupAudioSession()
        syncWithUserSettings()
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
        
        // 実際の音声ファイルがない場合はモック音声を生成
        if Bundle.main.path(forResource: fileName, ofType: nil) != nil {
            return true
        } else {
            // モック音声として、システム音または合成音声を使用
            return createMockAudioFile(for: character)
        }
    }
    
    private func syncWithUserSettings() {
        guard let settings = userSettings else { return }
        
        isSoundEnabled = settings.soundEnabled
        currentVolume = Float(settings.soundVolume)
        playbackSpeed = Float(settings.voiceSpeed)
        
        // 設定変更の監視
        settings.onSettingChanged = { [weak self] settingName in
            DispatchQueue.main.async {
                self?.updateFromSettings(settingName)
            }
        }
    }
    
    private func updateFromSettings(_ settingName: String) {
        guard let settings = userSettings else { return }
        
        switch settingName {
        case "soundEnabled":
            setSoundEnabled(settings.soundEnabled)
        case "soundVolume":
            setVolume(Float(settings.soundVolume))
        case "voiceSpeed":
            setPlaybackSpeed(Float(settings.voiceSpeed))
        default:
            break
        }
    }
    
    private func createMockAudioFile(for character: String) -> Bool {
        // モック音声ファイルを生成（実際の実装では合成音声を使用）
        // 今回は開発版として、システム音やbeep音で代用
        return true // 常に音声が利用可能として扱う
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
        
        // 実際の音声ファイルを確認
        if let path = Bundle.main.path(forResource: fileName, ofType: nil) {
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
        } else {
            // モック音声を生成
            try await prepareMockAudio(for: character)
        }
    }
    
    private func prepareMockAudio(for character: String) async throws {
        // モック音声のための簡単なbeep音を生成
        // 実際のプロダクションでは、AVSpeechSynthesizerや音声合成を使用
        
        do {
            // 短いbeep音を生成（1秒、440Hz）
            let mockAudioData = generateBeepSound(frequency: 440, duration: 0.5)
            let player = try AVAudioPlayer(data: mockAudioData)
            player.prepareToPlay()
            player.volume = currentVolume
            player.rate = playbackSpeed
            audioPlayers[character] = player
        } catch {
            throw AudioServiceError.playbackFailed
        }
    }
    
    private func generateBeepSound(frequency: Double, duration: Double) -> Data {
        // WAVファイル形式のヘッダーを含む音声データを生成
        let sampleRate = 44100.0
        let amplitude = 0.5
        let samples = Int(sampleRate * duration)
        let bytesPerSample = 2
        let dataSize = samples * bytesPerSample
        
        var audioData = Data()
        
        // WAVファイルヘッダー
        audioData.append("RIFF".data(using: .ascii)!)
        audioData.append(withUnsafeBytes(of: UInt32(36 + dataSize).littleEndian) { Data($0) })
        audioData.append("WAVE".data(using: .ascii)!)
        audioData.append("fmt ".data(using: .ascii)!)
        audioData.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
        audioData.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })
        audioData.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })
        audioData.append(withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) })
        audioData.append(withUnsafeBytes(of: UInt32(sampleRate * 2).littleEndian) { Data($0) })
        audioData.append(withUnsafeBytes(of: UInt16(2).littleEndian) { Data($0) })
        audioData.append(withUnsafeBytes(of: UInt16(16).littleEndian) { Data($0) })
        audioData.append("data".data(using: .ascii)!)
        audioData.append(withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Data($0) })
        
        // 音声データ
        for i in 0..<samples {
            let sample = amplitude * sin(2.0 * Double.pi * frequency * Double(i) / sampleRate)
            let intSample = Int16(sample * Double(Int16.max))
            
            withUnsafeBytes(of: intSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        return audioData
    }
    
    func playAudio(for character: String) async {
        guard isSoundEnabled else { 
            print("🔇 Audio disabled, skipping playback for: \(character)")
            return 
        }
        
        print("🎵 Attempting to play audio for: \(character)")
        
        do {
            if audioPlayers[character] == nil {
                try await prepareAudio(for: character)
                print("✅ Audio prepared for: \(character)")
            }
            
            guard let player = audioPlayers[character] else { 
                print("❌ No audio player found for: \(character)")
                return 
            }
            
            await MainActor.run {
                player.volume = currentVolume
                player.rate = playbackSpeed
                player.stop()
                player.currentTime = 0
                player.play()
                print("▶️ Playing audio for: \(character), volume: \(player.volume), rate: \(player.rate)")
            }
        } catch {
            print("❌ Failed to play audio for \(character): \(error)")
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
        guard let characters = levelConfig[level] else { 
            // デフォルトでレベル1の文字を使用
            let defaultCharacters = ["あ", "い", "う", "え", "お"]
            for character in defaultCharacters {
                do {
                    try await prepareAudio(for: character)
                } catch {
                    print("Failed to preload audio for \(character): \(error)")
                }
            }
            return 
        }
        
        for character in characters {
            do {
                try await prepareAudio(for: character)
            } catch {
                print("Failed to preload audio for \(character): \(error)")
            }
        }
    }
    
    // MARK: - 効果音
    
    func playCorrectSound() {
        guard isSoundEnabled else { return }
        
        Task {
            do {
                let correctSoundData = generateCorrectSound()
                effectPlayer = try AVAudioPlayer(data: correctSoundData)
                effectPlayer?.volume = currentVolume
                effectPlayer?.play()
            } catch {
                print("正解音の再生に失敗: \(error)")
            }
        }
    }
    
    func playIncorrectSound() {
        guard isSoundEnabled else { return }
        
        Task {
            do {
                let incorrectSoundData = generateIncorrectSound()
                effectPlayer = try AVAudioPlayer(data: incorrectSoundData)
                effectPlayer?.volume = currentVolume
                effectPlayer?.play()
            } catch {
                print("不正解音の再生に失敗: \(error)")
            }
        }
    }
    
    private func generateCorrectSound() -> Data {
        // 正解音：明るい和音（C-E-G, 523.25-659.25-783.99 Hz）
        let sampleRate: Double = 44100
        let duration: Double = 0.5
        let samples = Int(sampleRate * duration)
        
        var audioData = Data()
        
        // WAVヘッダー
        let header = createWAVHeader(samples: samples, sampleRate: Int(sampleRate))
        audioData.append(header)
        
        // 和音データ生成
        for i in 0..<samples {
            let time = Double(i) / sampleRate
            
            // C-E-G和音 + エンベロープ
            let envelope = sin(Double.pi * time / duration) // 滑らかなフェードイン/アウト
            let c = sin(2.0 * Double.pi * 523.25 * time) * envelope * 0.3
            let e = sin(2.0 * Double.pi * 659.25 * time) * envelope * 0.3
            let g = sin(2.0 * Double.pi * 783.99 * time) * envelope * 0.3
            
            let sample = c + e + g
            var sampleInt16 = Int16(sample * 32767)
            
            audioData.append(Data(bytes: &sampleInt16, count: 2))
            audioData.append(Data(bytes: &sampleInt16, count: 2)) // ステレオ
        }
        
        return audioData
    }
    
    private func generateIncorrectSound() -> Data {
        // 不正解音：低いトーン（200 Hz）
        let sampleRate: Double = 44100
        let duration: Double = 0.3
        let samples = Int(sampleRate * duration)
        
        var audioData = Data()
        
        // WAVヘッダー
        let header = createWAVHeader(samples: samples, sampleRate: Int(sampleRate))
        audioData.append(header)
        
        // 低音データ生成
        for i in 0..<samples {
            let time = Double(i) / sampleRate
            
            // 低い音 + エンベロープ
            let envelope = exp(-time * 5.0) // 急速にフェードアウト
            let tone = sin(2.0 * Double.pi * 200.0 * time) * envelope * 0.5
            
            var sampleInt16 = Int16(tone * 32767)
            
            audioData.append(Data(bytes: &sampleInt16, count: 2))
            audioData.append(Data(bytes: &sampleInt16, count: 2)) // ステレオ
        }
        
        return audioData
    }
    
    private func createWAVHeader(samples: Int, sampleRate: Int) -> Data {
        let bytesPerSample = 4 // 16-bit ステレオ
        let dataSize = samples * bytesPerSample
        
        var header = Data()
        
        // RIFF ヘッダー
        header.append("RIFF".data(using: .ascii)!)
        header.append(withUnsafeBytes(of: UInt32(36 + dataSize).littleEndian) { Data($0) })
        header.append("WAVE".data(using: .ascii)!)
        
        // fmt チャンク
        header.append("fmt ".data(using: .ascii)!)
        header.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })    // PCM
        header.append(withUnsafeBytes(of: UInt16(2).littleEndian) { Data($0) })    // ステレオ
        header.append(withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt32(sampleRate * bytesPerSample).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt16(bytesPerSample).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt16(16).littleEndian) { Data($0) })  // ビット深度
        
        // data チャンク
        header.append("data".data(using: .ascii)!)
        header.append(withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Data($0) })
        
        return header
    }
    
    deinit {
        stopAllAudio()
        try? audioSession.setActive(false)
    }
}