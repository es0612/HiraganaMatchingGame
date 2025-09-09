# HiraganaMatchingGame Project Overview

## Purpose
iOS educational app for teaching Japanese hiragana characters to children. Features progressive level-based learning with star rewards and character unlocks.

## Tech Stack
- **Platform**: iOS 17.0+
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData (migrating from mixed UserDefaults/SwiftData)
- **Architecture**: MVVM with @Observable
- **Testing**: Swift Testing framework (modern replacement for XCTest)
- **Audio**: AVFoundation with custom AudioService

## Current Architecture Challenge
App has mixed persistence architecture (UserDefaults + SwiftData) causing technical debt. Phase 1 implementation focuses on:
1. Unifying persistence to SwiftData-only via UnifiedGameProgress model
2. Implementing DataMigrationService for UserDefaults → SwiftData migration
3. Refactoring large AudioService (751 lines) with AudioManager delegation

## Key Models
- `UnifiedGameProgress`: New consolidated SwiftData model
- `AchievementRecord`: SwiftData achievement tracking
- `LevelStats`: SwiftData level statistics
- `GameProgress`: Legacy model (being phased out)
- `StarUnlockService`: Legacy UserDefaults service (being replaced)
- `RefactoredStarUnlockService`: New SwiftData-only replacement