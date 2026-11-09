//
//  EffectPlayer.swift
//  HiraganaMatchingGame
//
//

import AVFoundation
import Foundation

enum SoundEffect {
    case correct
    case incorrect
    case levelUp
    case button
    case achievement
    
    var frequency: Double {
        switch self {
        case .correct: return 800.0
        case .incorrect: return 300.0
        case .levelUp: return 1000.0
        case .button: return 600.0
        case .achievement: return 1200.0
        }
    }
    
    var duration: Double {
        switch self {
        case .correct: return 0.5
        case .incorrect: return 0.3
        case .levelUp: return 1.0
        case .button: return 0.2
        case .achievement: return 0.8
        }
    }
}

class EffectPlayer: ObservableObject {
    @Published var isEnabled: Bool = true
    @Published var volume: Float = 1.0
    
    private let isTestMode: Bool
    private var effectPlayer: AVAudioPlayer?
    
    init(isTestMode: Bool = false) {
        self.isTestMode = isTestMode
    }
    
    func playEffect(_ effect: SoundEffect) {
        guard !isTestMode else { return }
        guard isEnabled else { return }
        
        Task {
            do {
                let audioData = generateEffectSound(effect)
                effectPlayer = try AVAudioPlayer(data: audioData)
                effectPlayer?.volume = volume
                effectPlayer?.play()
                print("🔊 Playing effect: \(effect)")
            } catch {
                print("Failed to play effect \(effect): \(error)")
            }
        }
    }
    
    func playCorrectSound() {
        playEffect(.correct)
    }
    
    func playIncorrectSound() {
        playEffect(.incorrect)
    }
    
    func playLevelUpSound() {
        playEffect(.levelUp)
    }
    
    func playButtonSound() {
        playEffect(.button)
    }
    
    func playAchievementSound() {
        playEffect(.achievement)
    }
    
    func stopEffect() {
        effectPlayer?.stop()
        effectPlayer = nil
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled {
            stopEffect()
        }
    }
    
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        effectPlayer?.volume = volume
    }
    
    // MARK: - Sound Generation
    
    /// AVAudioPlayer で再生できる WAV 形式のデータを返す（#83）
    func generateEffectSound(_ effect: SoundEffect) -> Data {
        let samples: Data
        switch effect {
        case .correct:
            samples = generateHappySound()
        case .incorrect:
            samples = generateSadSound()
        case .levelUp:
            samples = generateTriumphSound()
        case .button:
            samples = generateClickSound()
        case .achievement:
            samples = generateFanfareSound()
        }
        return wavData(fromSamples: samples)
    }
    
    /// 16 bit・モノラル・44.1 kHz の波形に WAV ヘッダーを付ける。
    /// ヘッダーのない波形は AVAudioPlayer(data:) が読めない（kAudioFileUnsupportedFileTypeError）
    private func wavData(fromSamples samples: Data) -> Data {
        let sampleRate: UInt32 = 44100
        let channels: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let blockAlign = channels * bitsPerSample / 8
        let byteRate = sampleRate * UInt32(blockAlign)
        
        var data = Data()
        func append<T: FixedWidthInteger>(_ value: T) {
            withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
        }
        data.append(contentsOf: Array("RIFF".utf8))
        append(UInt32(36 + samples.count))
        data.append(contentsOf: Array("WAVE".utf8))
        data.append(contentsOf: Array("fmt ".utf8))
        append(UInt32(16)) // fmt チャンクの長さ
        append(UInt16(1)) // リニア PCM
        append(channels)
        append(sampleRate)
        append(byteRate)
        append(blockAlign)
        append(bitsPerSample)
        data.append(contentsOf: Array("data".utf8))
        append(UInt32(samples.count))
        data.append(samples)
        return data
    }
    
    private func generateHappySound() -> Data {
        // Ascending happy chord
        let frequencies = [523.25, 659.25, 783.99] // C-E-G major chord
        return generateChord(frequencies: frequencies, duration: 0.5)
    }
    
    private func generateSadSound() -> Data {
        // Descending sad tone
        let frequencies = [400.0, 350.0, 300.0]
        return generateDescendingTones(frequencies: frequencies, duration: 0.3)
    }
    
    private func generateTriumphSound() -> Data {
        // Victory fanfare
        let notes = [
            (523.25, 0.2), // C
            (659.25, 0.2), // E
            (783.99, 0.2), // G
            (1046.5, 0.4) // C (octave)
        ]
        return generateMelody(notes: notes)
    }
    
    private func generateClickSound() -> Data {
        // Short click sound
        generateBeepSound(frequency: 600.0, duration: 0.1)
    }
    
    private func generateFanfareSound() -> Data {
        // Achievement fanfare
        let notes = [
            (783.99, 0.2), // G
            (880.00, 0.2), // A
            (987.77, 0.2), // B
            (1046.5, 0.2) // C
        ]
        return generateMelody(notes: notes)
    }
    
    private func generateBeepSound(frequency: Double, duration: Double) -> Data {
        let sampleRate = 44100.0
        let samples = Int(sampleRate * duration)
        var audioData = Data()
        
        for i in 0 ..< samples {
            let time = Double(i) / sampleRate
            let envelope = time < 0.1 ? time / 0.1 :
                time > (duration - 0.1) ? (duration - time) / 0.1 : 1.0
            let sample = sin(2.0 * Double.pi * frequency * time) * envelope
            let scaledSample = Int16(sample * 16383.0) // Reduced amplitude
            
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        return audioData
    }
    
    private func generateChord(frequencies: [Double], duration: Double) -> Data {
        let sampleRate = 44100.0
        let samples = Int(sampleRate * duration)
        var audioData = Data()
        
        for i in 0 ..< samples {
            let time = Double(i) / sampleRate
            let envelope = time < 0.1 ? time / 0.1 :
                time > (duration - 0.1) ? (duration - time) / 0.1 : 1.0
            
            var mixedSample = 0.0
            for frequency in frequencies {
                mixedSample += sin(2.0 * Double.pi * frequency * time)
            }
            mixedSample = mixedSample / Double(frequencies.count) * envelope
            
            let scaledSample = Int16(mixedSample * 16383.0)
            
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        return audioData
    }
    
    private func generateDescendingTones(frequencies: [Double], duration: Double) -> Data {
        let toneDuration = duration / Double(frequencies.count)
        var audioData = Data()
        
        for frequency in frequencies {
            let toneData = generateBeepSound(frequency: frequency, duration: toneDuration)
            audioData.append(toneData)
        }
        
        return audioData
    }
    
    private func generateMelody(notes: [(frequency: Double, duration: Double)]) -> Data {
        var audioData = Data()
        
        for (frequency, duration) in notes {
            let noteData = generateBeepSound(frequency: frequency, duration: duration)
            audioData.append(noteData)
        }
        
        return audioData
    }
}
