//
//  SpeechSynthesizer.swift
//  HiraganaMatchingGame
//
//

import AVFoundation
import Foundation

/// 読み上げの差し替え口。テストで呼び出しを記録するために使う（#73）
protocol SpeechSpeaking: AnyObject {
    func speakText(_ text: String, slowly: Bool) async
    func speakCharacter(_ character: String, slowly: Bool) async
    func stopSpeaking()
    func pauseSpeaking()
    func continueSpeaking()
    func setEnabled(_ enabled: Bool)
    func setSpeechRate(_ rate: Float)
    func setVolume(_ newVolume: Float)
}

class SpeechSynthesizer: NSObject, ObservableObject, SpeechSpeaking {
    @Published var isEnabled: Bool = true
    @Published var speechRate: Float = 0.5
    @Published var volume: Float = 1.0
    
    private let isTestMode: Bool
    private var speechSynthesizer: AVSpeechSynthesizer
    
    /// 読み上げがアプリのオーディオセッション（.ambient、BGM 用）を使うか
    var usesApplicationAudioSession: Bool {
        speechSynthesizer.usesApplicationAudioSession
    }
    
    /// 読み上げはアプリのセッション（.ambient）から切り離し、システムが用意する別のセッションで鳴らす。
    /// PO 判断（2026-11-01、#73）: 音のボタンの読み上げは消音中でも鳴らし、BGM は消音に従う。
    /// 別のセッションが消音スイッチを無視するかは Apple の資料に書かれておらず、実機で確かめる
    private static func makeSynthesizer() -> AVSpeechSynthesizer {
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.usesApplicationAudioSession = false
        return synthesizer
    }
    
    override init() {
        isTestMode = false
        speechSynthesizer = Self.makeSynthesizer()
        super.init()
        speechSynthesizer.delegate = self
    }
    
    init(isTestMode: Bool) {
        self.isTestMode = isTestMode
        speechSynthesizer = Self.makeSynthesizer()
        super.init()
        if !isTestMode {
            speechSynthesizer.delegate = self
        }
    }
    
    func speakText(_ text: String, slowly: Bool = false) async {
        guard !isTestMode else { return }
        guard isEnabled else {
            print("🔇 Speech disabled, skipping speech for: \(text)")
            return
        }
        
        // Stop current speech
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        
        // Adjust speech parameters
        if slowly {
            utterance.rate = speechRate * 0.7 // Even slower for learning
        } else {
            utterance.rate = speechRate
        }
        
        utterance.volume = volume
        utterance.pitchMultiplier = 1.2 // Slightly higher pitch for children
        
        print("🗣️ Speaking: \(text) (slowly: \(slowly))")
        speechSynthesizer.speak(utterance)
        
        // Wait for completion in non-test mode
        if !isTestMode {
            await waitForSpeechCompletion()
        }
    }
    
    func speakCharacter(_ character: String, slowly: Bool = false) async {
        guard !isTestMode else { return }
        
        // Use proper Japanese pronunciation for hiragana
        let pronunciationText = getJapanesePronunciation(for: character)
        await speakText(pronunciationText, slowly: slowly)
    }
    
    func stopSpeaking() {
        guard !isTestMode else { return }
        
        speechSynthesizer.stopSpeaking(at: .immediate)
        print("🔇 Speech stopped")
    }
    
    func pauseSpeaking() {
        guard !isTestMode else { return }
        
        speechSynthesizer.pauseSpeaking(at: .word)
        print("⏸️ Speech paused")
    }
    
    func continueSpeaking() {
        guard !isTestMode else { return }
        
        speechSynthesizer.continueSpeaking()
        print("▶️ Speech continued")
    }
    
    func isSpeaking() -> Bool {
        speechSynthesizer.isSpeaking
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled {
            stopSpeaking()
        }
    }
    
    func setSpeechRate(_ rate: Float) {
        speechRate = max(0.1, min(1.0, rate))
    }
    
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
    }
    
    // MARK: - Private Methods
    
    private func getJapanesePronunciation(for character: String) -> String {
        let pronunciations: [String: String] = [
            "あ": "あ", "い": "い", "う": "う", "え": "え", "お": "お",
            "か": "か", "き": "き", "く": "く", "け": "け", "こ": "こ",
            "さ": "さ", "し": "し", "す": "す", "せ": "せ", "そ": "そ",
            "た": "た", "ち": "ち", "つ": "つ", "て": "て", "と": "と",
            "な": "な", "に": "に", "ぬ": "ぬ", "ね": "ね", "の": "の",
            "は": "は", "ひ": "ひ", "ふ": "ふ", "へ": "へ", "ほ": "ほ",
            "ま": "ま", "み": "み", "む": "む", "め": "め", "も": "も",
            "や": "や", "ゆ": "ゆ", "よ": "よ",
            "ら": "ら", "り": "り", "る": "る", "れ": "れ", "ろ": "ろ",
            "わ": "わ", "を": "を", "ん": "ん"
        ]
        
        return pronunciations[character] ?? character
    }
    
    private func waitForSpeechCompletion() async {
        // テスト環境では即座に完了
        if TestUtils.isTestEnvironment {
            return
        }
        
        await withCheckedContinuation { continuation in
            // Use a simple timer-based approach for completion detection
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if !self.speechSynthesizer.isSpeaking {
                    timer.invalidate()
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechSynthesizer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("🗣️ Speech started: \(utterance.speechString)")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("🗣️ Speech finished: \(utterance.speechString)")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("🗣️ Speech cancelled: \(utterance.speechString)")
    }
}
