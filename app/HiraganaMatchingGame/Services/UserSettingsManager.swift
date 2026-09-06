import Combine
import Foundation
import SwiftData

@MainActor
class UserSettingsManager: ObservableObject {
    static let shared = UserSettingsManager()
    
    @Published private(set) var settings: UserSettings?
    private var modelContext: ModelContext?
    
    private init() {}
    
    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSettings()
    }
    
    private func loadSettings() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<UserSettings>()
            let existingSettings = try context.fetch(descriptor)
            
            if let existing = existingSettings.first {
                settings = existing
            } else {
                // 新しいUserSettingsを作成
                let newSettings = UserSettings()
                context.insert(newSettings)
                try context.save()
                settings = newSettings
            }
        } catch {
            print("Error loading UserSettings: \(error)")
            // フォールバック：新しい設定を作成
            let newSettings = UserSettings()
            context.insert(newSettings)
            settings = newSettings
        }
    }
    
    // MARK: - Settings Access
    var soundEnabled: Bool {
        get { settings?.soundEnabled ?? true }
        set {
            settings?.soundEnabled = newValue
            saveSettings()
        }
    }
    
    var musicEnabled: Bool {
        get { settings?.musicEnabled ?? true }
        set {
            settings?.musicEnabled = newValue
            saveSettings()
        }
    }
    
    var soundVolume: Double {
        get { settings?.soundVolume ?? 0.8 }
        set {
            settings?.setSoundVolume(newValue)
            saveSettings()
        }
    }
    
    var gameSpeed: GameSpeed {
        get { settings?.gameSpeed ?? .normal }
        set {
            settings?.setGameSpeed(newValue)
            saveSettings()
        }
    }
    
    var difficulty: GameDifficulty {
        get { settings?.difficulty ?? .normal }
        set {
            settings?.setDifficulty(newValue)
            saveSettings()
        }
    }
    
    var autoAdvance: Bool {
        get { settings?.autoAdvance ?? false }
        set {
            settings?.setAutoAdvance(newValue)
            saveSettings()
        }
    }
    
    var showHints: Bool {
        get { settings?.showHints ?? true }
        set {
            settings?.setShowHints(newValue)
            saveSettings()
        }
    }
    
    var largeText: Bool {
        get { settings?.largeText ?? false }
        set {
            settings?.setLargeText(newValue)
            saveSettings()
        }
    }
    
    var reduceAnimations: Bool {
        get { settings?.reduceAnimations ?? false }
        set {
            settings?.setReduceAnimations(newValue)
            saveSettings()
        }
    }
    
    var hasSeenTutorial: Bool {
        get { settings?.hasSeenTutorial ?? false }
        set {
            settings?.hasSeenTutorial = newValue
            saveSettings()
        }
    }
    
    var voiceSpeed: Double {
        get { settings?.voiceSpeed ?? 1.0 }
        set {
            settings?.setVoiceSpeed(newValue)
            saveSettings()
        }
    }
    
    var playtimeLimit: Int {
        get { settings?.playtimeLimit ?? 0 }
        set {
            settings?.playtimeLimit = newValue
            saveSettings()
        }
    }
    
    var questionsPerSession: Int {
        get { settings?.questionsPerSession ?? 5 }
        set {
            settings?.setQuestionsPerSession(newValue)
            saveSettings()
        }
    }
    
    var questionsPerSessionEnum: QuestionsPerSession {
        get { settings?.questionsPerSessionEnum ?? .few }
        set {
            settings?.setQuestionsPerSessionEnum(newValue)
            saveSettings()
        }
    }
    
    // MARK: - Tutorial Management
    func markTutorialAsCompleted() {
        hasSeenTutorial = true
    }
    
    // MARK: - Save
    private func saveSettings() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("Error saving UserSettings: \(error)")
        }
    }
    
    func resetToDefaults() {
        settings?.resetToDefaults()
        saveSettings()
    }
}
