# Suggested Commands for HiraganaMatchingGame

## Testing Commands
```bash
# Run all tests
xcodebuild test -scheme HiraganaMatchingGame -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'

# Run specific test suite
xcodebuild test -scheme HiraganaMatchingGame -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' -only-testing:HiraganaMatchingGameTests/DataMigrationServiceTests

# Run unit tests only
xcodebuild test -scheme HiraganaMatchingGame -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' -only-testing:HiraganaMatchingGameTests

# Run UI tests
xcodebuild test -scheme HiraganaMatchingGame -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' -only-testing:HiraganaMatchingGameUITests
```

## Build Commands
```bash
# Clean build
xcodebuild clean -scheme HiraganaMatchingGame

# Build for simulator
xcodebuild build -scheme HiraganaMatchingGame -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'

# Build for device
xcodebuild build -scheme HiraganaMatchingGame -destination 'generic/platform=iOS'
```

## Development Commands
```bash
# Install dependencies (if using SPM)
swift package resolve

# Format code (if using swift-format)
swift-format --in-place --recursive Sources/

# Lint code (if using SwiftLint)
swiftlint
```

## Git Workflow
```bash
# Check status before starting work
git status && git branch

# Create feature branch
git checkout -b feature/data-migration-tests

# Commit with meaningful messages
git add . && git commit -m "feat: add data integrity tests for migration system"
```