import Foundation
import AVFoundation

enum AudioServiceError: Error {
    case fileNotFound
    case playbackFailed
    case audioSessionSetupFailed
}

class AudioService: ObservableObject {
    @Published var isSoundEnabled: Bool = true
    @Published var isMusicEnabled: Bool = true
    @Published var currentVolume: Float = 1.0
    @Published var playbackSpeed: Float = 1.0
    
    private var userSettings: UserSettings?
    private let isTestMode: Bool
    
    private var audioPlayers: [String: AVAudioPlayer?] = [:]
    private var audioSession: AVAudioSession
    private var effectPlayer: AVAudioPlayer?
    private var bgmPlayer: AVAudioPlayer?
    private var speechSynthesizer: AVSpeechSynthesizer
    
    init(isTestMode: Bool = false) {
        self.isTestMode = isTestMode
        self.audioSession = AVAudioSession.sharedInstance()
        self.speechSynthesizer = AVSpeechSynthesizer()
        if !isTestMode {
            setupAudioSession()
        }
    }
    
    init(userSettings: UserSettings, isTestMode: Bool = false, startBGM: Bool = false) {
        self.isTestMode = isTestMode
        self.audioSession = AVAudioSession.sharedInstance()
        self.speechSynthesizer = AVSpeechSynthesizer()
        self.userSettings = userSettings
        if !isTestMode {
            setupAudioSession()
            syncWithUserSettings(startBGM: startBGM)
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
    
    private func syncWithUserSettings(startBGM: Bool = false) {
        guard let settings = userSettings else { return }
        
        isSoundEnabled = settings.soundEnabled
        isMusicEnabled = settings.musicEnabled
        currentVolume = Float(settings.soundVolume)
        playbackSpeed = Float(settings.voiceSpeed)
        
        // BGMを開始（スプラッシュスクリーン時のみ）
        if isMusicEnabled && startBGM {
            startBackgroundMusic()
        }
        
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
        case "musicEnabled":
            let newMusicEnabled = settings.musicEnabled
            if newMusicEnabled != isMusicEnabled {
                setMusicEnabled(newMusicEnabled)
                if newMusicEnabled {
                    startBackgroundMusic()
                } else {
                    stopBackgroundMusic()
                }
            }
        case "soundVolume":
            setVolume(Float(settings.soundVolume))
            // BGMの音量も更新
            bgmPlayer?.volume = Float(settings.soundVolume) * 0.15
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
    
    func setMusicEnabled(_ enabled: Bool) {
        isMusicEnabled = enabled
        if enabled {
            startBackgroundMusic()
        } else {
            stopBackgroundMusic()
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
        // テスト環境では音声合成を使用してメモリ問題を回避
        await MainActor.run {
            // 音声準備完了としてマーク（実際のファイルは作成しない）
            // プレースホルダーとしてnilを設定し、キーの存在で準備完了を示す
            audioPlayers[character] = nil
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
        guard !isTestMode else { return }
        guard isSoundEnabled else { 
            print("🔇 Audio disabled, skipping playback for: \(character)")
            return 
        }
        
        print("🎵 Playing speech synthesis for: \(character)")
        
        await MainActor.run {
            // 既存の音声を停止
            speechSynthesizer.stopSpeaking(at: .immediate)
            
            // 音声合成の設定
            let utterance = AVSpeechUtterance(string: character)
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            utterance.rate = playbackSpeed * 0.25 // より遅く、はっきりと
            utterance.volume = currentVolume
            utterance.pitchMultiplier = 1.2 // 少し高めの音程で子供に優しく
            utterance.preUtteranceDelay = 0.1 // 発音前の短い間
            utterance.postUtteranceDelay = 0.2 // 発音後の余韻
            
            // 音声合成で再生
            speechSynthesizer.speak(utterance)
            print("🗣️ Speaking: \(character) with voice synthesis")
        }
    }
    
    func speakText(_ text: String, slowly: Bool = false) async {
        guard !isTestMode else { return }
        guard isSoundEnabled else { 
            print("🔇 Audio disabled, skipping speech for: \(text)")
            return 
        }
        
        print("🎵 Speaking text slowly: \(text)")
        
        await MainActor.run {
            // 既存の音声を停止
            speechSynthesizer.stopSpeaking(at: .immediate)
            
            // 音声合成の設定
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            
            if slowly {
                utterance.rate = playbackSpeed * 0.3 // より遅く、はっきりと
            } else {
                utterance.rate = playbackSpeed * 0.5
            }
            
            utterance.volume = currentVolume
            utterance.pitchMultiplier = 1.2 // 少し高めの音程で子供に優しく
            
            // 音声合成で再生
            speechSynthesizer.speak(utterance)
            print("🗣️ Speaking text: \(text)")
        }
    }
    
    func isAudioReady(for character: String) -> Bool {
        return audioPlayers.keys.contains(character)
    }
    
    func stopAllAudio() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        for (_, player) in audioPlayers {
            player?.stop()
        }
        // BGMは継続
    }
    
    // MARK: - BGM機能
    
    func startBackgroundMusic() {
        guard !isTestMode else { return }
        guard isMusicEnabled else { 
            print("🎵 Music disabled, not starting BGM")
            return 
        }
        
        // 既存のBGMが再生中の場合は何もしない
        if bgmPlayer?.isPlaying == true {
            print("🎵 BGM already playing")
            return
        }
        
        print("🎵 Starting background music...")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                // BGMを停止してリセット
                self.bgmPlayer?.stop()
                self.bgmPlayer = nil
                
                // Debug: List all files in bundle
                if let bundlePath = Bundle.main.resourcePath {
                    let bundleContents = try? FileManager.default.contentsOfDirectory(atPath: bundlePath)
                    print("🔍 Bundle contents: \(bundleContents?.filter { $0.contains("bgm") } ?? [])")
                }
                
                // Try to load custom BGM file first
                if let bgmPath = Bundle.main.path(forResource: "bgm", ofType: "mp3") {
                    let bgmURL = URL(fileURLWithPath: bgmPath)
                    self.bgmPlayer = try AVAudioPlayer(contentsOf: bgmURL)
                    print("🎵 SUCCESS: Loaded custom BGM file from: \(bgmPath)")
                } else if let bgmURL = Bundle.main.url(forResource: "bgm", withExtension: "mp3") {
                    self.bgmPlayer = try AVAudioPlayer(contentsOf: bgmURL)
                    print("🎵 SUCCESS: Loaded custom BGM via URL: \(bgmURL)")
                } else {
                    // Fallback to generated BGM
                    let bgmData = self.generateBackgroundMusic()
                    self.bgmPlayer = try AVAudioPlayer(data: bgmData)
                    print("🎵 FALLBACK: Using generated BGM")
                }
                
                self.bgmPlayer?.numberOfLoops = -1 // 無限ループ
                self.bgmPlayer?.volume = self.currentVolume * 0.15 // BGMはデフォルトの半分の音量
                self.bgmPlayer?.prepareToPlay()
                let started = self.bgmPlayer?.play() ?? false
                print("🎵 Background music started: \(started)")
                
                if !started {
                    print("⚠️ BGM failed to start")
                }
                
            } catch {
                print("❌ BGM再生に失敗: \(error)")
            }
        }
    }
    
    func stopBackgroundMusic() {
        bgmPlayer?.stop()
        bgmPlayer = nil
        print("🎵 Background music stopped")
    }
    
    func isBGMPlaying() -> Bool {
        return bgmPlayer?.isPlaying ?? false
    }
    
    private func generateBackgroundMusic() -> Data {
        // 子供向けのポップで楽しいメロディーを生成
        let sampleRate: Double = 44100
        let duration: Double = 12.0 // 12秒のより長いループ
        let samples = Int(sampleRate * duration)
        
        var audioData = Data()
        
        // WAVヘッダー
        let header = createWAVHeader(samples: samples, sampleRate: Int(sampleRate))
        audioData.append(header)
        
        // 楽しいメロディー「きらきら星」風のポップアレンジ
        // C-C-G-G-A-A-G-F-F-E-E-D-D-C の明るいメロディー
        let melodyNotes: [(Double, Double)] = [
            (523.25, 0.6), // C5 - Do (高め)
            (523.25, 0.6), // C5 - Do
            (783.99, 0.6), // G5 - Sol (高音で明るく)
            (783.99, 0.6), // G5 - Sol
            (880.00, 0.6), // A5 - La (最高音)
            (880.00, 0.6), // A5 - La
            (783.99, 1.2), // G5 - Sol (長め)
            (698.46, 0.6), // F5 - Fa
            (698.46, 0.6), // F5 - Fa
            (659.25, 0.6), // E5 - Mi
            (659.25, 0.6), // E5 - Mi
            (587.33, 0.6), // D5 - Re
            (587.33, 0.6), // D5 - Re
            (523.25, 1.2)  // C5 - Do (終わり)
        ]
        
        var currentTime: Double = 0
        
        for (frequency, noteDuration) in melodyNotes {
            let noteStartSample = Int(currentTime * sampleRate)
            let noteEndSample = Int((currentTime + noteDuration) * sampleRate)
            
            for i in noteStartSample..<noteEndSample {
                let time = Double(i) / sampleRate
                let noteTime = time - currentTime
                
                // より楽しい音作り：複数の倍音とエンベロープ
                let envelope = createChildFriendlyEnvelope(noteTime: noteTime, duration: noteDuration)
                
                // メインのメロディー
                let mainTone = sin(2.0 * Double.pi * frequency * noteTime)
                
                // ハーモニー（3度上）を追加してよりポップに
                let harmonyFreq = frequency * 1.25992 // 3度上のハーモニー
                let harmonyTone = sin(2.0 * Double.pi * harmonyFreq * noteTime) * 0.3
                
                // 軽やかなトレモロ効果
                let tremolo = 1.0 + 0.1 * sin(2.0 * Double.pi * 6.0 * noteTime)
                
                let finalTone = (mainTone + harmonyTone) * envelope * tremolo * 0.25
                
                var sampleInt16 = Int16(finalTone * 32767)
                
                audioData.append(Data(bytes: &sampleInt16, count: 2))
                audioData.append(Data(bytes: &sampleInt16, count: 2)) // ステレオ
            }
            
            currentTime += noteDuration
        }
        
        return audioData
    }
    
    private func createChildFriendlyEnvelope(noteTime: Double, duration: Double) -> Double {
        // 子供向けの楽しい音のエンベロープ
        let attack = min(duration * 0.1, 0.05) // 立ち上がり
        let decay = min(duration * 0.2, 0.1)  // 減衰
        let sustain = 0.8 // サスティンレベル
        let release = duration * 0.3 // リリース
        
        if noteTime < attack {
            // アタック（0から1に）
            return noteTime / attack
        } else if noteTime < attack + decay {
            // ディケイ（1からサスティンレベルに）
            let decayProgress = (noteTime - attack) / decay
            return 1.0 - (1.0 - sustain) * decayProgress
        } else if noteTime < duration - release {
            // サスティン（一定レベル維持）
            return sustain
        } else {
            // リリース（サスティンから0に）
            let releaseProgress = (noteTime - (duration - release)) / release
            return sustain * (1.0 - releaseProgress)
        }
    }
    
    func pauseAllAudio() {
        for (_, player) in audioPlayers {
            player?.pause()
        }
    }
    
    func resumeAllAudio() {
        guard isSoundEnabled else { return }
        
        for (_, player) in audioPlayers {
            if let player = player, player.currentTime > 0 {
                player.play()
            }
        }
    }
    
    private func updateAllPlayersVolume() {
        for (_, player) in audioPlayers {
            player?.volume = currentVolume
        }
    }
    
    private func updateAllPlayersSpeed() {
        for (_, player) in audioPlayers {
            player?.rate = playbackSpeed
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
        guard !isTestMode else { return }
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
        guard !isTestMode else { return }
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
        stopBackgroundMusic()
        try? audioSession.setActive(false)
    }
}