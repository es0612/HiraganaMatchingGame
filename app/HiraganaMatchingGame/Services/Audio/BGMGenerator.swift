//
//  BGMGenerator.swift
//  HiraganaMatchingGame
//
//

import AVFoundation
import Foundation

class BGMGenerator {
    private let isTestMode: Bool
    private var bgmPlayer: AVAudioPlayer?
    
    init(isTestMode: Bool = false) {
        self.isTestMode = isTestMode
    }
    
    func startBackgroundMusic(filename: String = "bgm", volume: Float = 0.3) {
        guard !isTestMode else { return }
        
        // Stop existing BGM
        stopBackgroundMusic()
        
        do {
            // Debug: List all files in bundle
            if let bundlePath = Bundle.main.resourcePath {
                let bundleContents = try? FileManager.default.contentsOfDirectory(atPath: bundlePath)
                print("🔍 Bundle contents: \(bundleContents?.filter { $0.contains("bgm") } ?? [])")
            }
            
            // Try to load custom BGM file first
            if let bgmPath = Bundle.main.path(forResource: filename, ofType: "mp3") {
                let bgmURL = URL(fileURLWithPath: bgmPath)
                bgmPlayer = try AVAudioPlayer(contentsOf: bgmURL)
                print("🎵 SUCCESS: Loaded BGM (\(filename)) from: \(bgmPath)")
            } else {
                print("⚠️ \(filename).mp3 not found in bundle, checking alternative paths...")
                
                // Try alternative resource lookup
                if let bgmURL = Bundle.main.url(forResource: filename, withExtension: "mp3") {
                    bgmPlayer = try AVAudioPlayer(contentsOf: bgmURL)
                    print("🎵 SUCCESS: Loaded BGM (\(filename)) via URL: \(bgmURL)")
                } else {
                    // Fallback to generated BGM
                    let bgmData = generateBackgroundMusic()
                    bgmPlayer = try AVAudioPlayer(data: bgmData)
                    print("🎵 FALLBACK: Using generated BGM for \(filename)")
                }
            }
            
            bgmPlayer?.volume = volume
            bgmPlayer?.numberOfLoops = -1 // Infinite loop
            bgmPlayer?.prepareToPlay()
            bgmPlayer?.play()
            print("🎵 Background music started (\(filename))")
        } catch {
            print("Failed to start background music: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        guard !isTestMode else { return }
        
        bgmPlayer?.stop()
        bgmPlayer = nil
        print("🎵 Background music stopped")
    }
    
    func setBGMVolume(_ volume: Float) {
        bgmPlayer?.volume = max(0.0, min(1.0, volume))
    }
    
    func isBGMPlaying() -> Bool {
        bgmPlayer?.isPlaying == true
    }
    
    // MARK: - BGM Generation
    
    private func generateBackgroundMusic() -> Data {
        // 子供向けのポップで楽しいメロディーを生成（きらきら星風）
        let melodyNotes: [(Double, Double)] = [
            (523.25, 0.6), // C5 - Do (高め)
            (523.25, 0.6), // C5 - Do
            (783.99, 0.6), // G5 - Sol (高音で明るく)
            (783.99, 0.6), // G5 - Sol
            (880.00, 0.6), // A5 - La (より高く)
            (880.00, 0.6), // A5 - La
            (783.99, 1.2), // G5 - Sol (長め)
            
            (698.46, 0.6), // F5 - Fa
            (698.46, 0.6), // F5 - Fa
            (659.25, 0.6), // E5 - Mi
            (659.25, 0.6), // E5 - Mi
            (587.33, 0.6), // D5 - Re
            (587.33, 0.6), // D5 - Re
            (523.25, 1.2) // C5 - Do (終わり)
        ]
        
        let sampleRate = 44100.0
        var audioData = Data()
        
        for (frequency, duration) in melodyNotes {
            let samples = Int(sampleRate * duration)
            
            for i in 0 ..< samples {
                let noteTime = Double(i) / sampleRate
                
                // メイン音
                let mainTone = sin(2.0 * Double.pi * frequency * noteTime)
                
                // ハーモニー（3度上）を追加してよりポップに
                let harmonyFreq = frequency * 1.25992
                let harmonyTone = sin(2.0 * Double.pi * harmonyFreq * noteTime) * 0.3
                
                // 軽やかなトレモロ効果
                let tremolo = 1.0 + 0.1 * sin(2.0 * Double.pi * 6.0 * noteTime)
                
                // ADSR エンベロープ（より柔らかく）
                let attack = min(1.0, noteTime / 0.1)
                let decay = noteTime < 0.2 ? 1.0 : 0.85
                let release = noteTime > (duration - 0.15) ?
                    max(0.0, (duration - noteTime) / 0.15) : 1.0
                let envelope = attack * decay * release
                
                // 全ての要素を組み合わせ
                let finalSample = (mainTone + harmonyTone) * tremolo * envelope * 0.4
                let scaledSample = Int16(finalSample * 32767.0)
                
                withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                    audioData.append(contentsOf: bytes)
                }
            }
        }
        
        print("🎵 Generated fallback BGM (\(audioData.count) bytes)")
        return audioData
    }
    
    deinit {
        stopBackgroundMusic()
    }
}
