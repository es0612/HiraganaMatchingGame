# Code Style and Conventions

## Swift Style Guidelines
- **Naming**: Use descriptive camelCase names for functions/variables, PascalCase for types
- **File Organization**: Group related functionality, use MARK comments for sections
- **SwiftUI**: Use @State, @Observable, @Environment appropriately
- **SwiftData**: Use @Model macro, proper relationship definitions
- **Error Handling**: Use custom Error enums, comprehensive error messages with emojis (🔄, ✅, ⚠️, ❌)

## Architecture Patterns
- **MVVM**: ViewModels use @Observable macro
- **Service Layer**: Business logic in dedicated service classes
- **Dependency Injection**: Pass services through initializers or environment
- **Data Flow**: Unidirectional data flow with proper separation of concerns

## Testing Conventions
- **Framework**: Swift Testing (not XCTest)
- **Structure**: Use @Test and @Suite attributes
- **Naming**: Descriptive Japanese test names for clarity
- **Assertions**: Use #expect() instead of XCTAssert
- **Setup**: In-memory ModelContainer for testing SwiftData

## Comments and Documentation
- **Japanese Comments**: Technical comments in Japanese for clarity
- **Emoji Logging**: Use emojis in print statements (🔄 starting, ✅ success, ⚠️ warning, ❌ error)
- **MARK Comments**: Organize code sections with // MARK: - SectionName