# Task Completion Checklist

## When completing any development task:

1. **Run Tests**
   ```bash
   xcodebuild test -scheme HiraganaMatchingGame -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'
   ```

2. **Build Validation** 
   ```bash
   xcodebuild build -scheme HiraganaMatchingGame -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'
   ```

3. **Code Quality** (if available)
   ```bash
   swiftlint
   swift-format --in-place --recursive .
   ```

4. **Git Workflow**
   ```bash
   git status
   git add .
   git commit -m "descriptive message with emoji 🎯"
   ```

5. **Documentation Update**
   - Update relevant comments if architectural changes made
   - Update memory files if major changes affect project structure

## Specific to Data Migration Tasks:
- Validate migration with test data
- Check data integrity before/after migration
- Verify rollback functionality works
- Test performance with various data sizes
- Confirm no UserDefaults dependencies remain