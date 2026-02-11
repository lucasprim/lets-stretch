# Swift Style Guide - Let's Stretch

Based on SwiftLint defaults and Apple's Swift API Design Guidelines.

## Naming Conventions

- **Types and protocols**: UpperCamelCase (`StretchRoutine`, `ReminderScheduler`)
- **Functions, methods, properties, variables**: lowerCamelCase (`scheduleReminder()`, `currentStretch`)
- **Constants**: lowerCamelCase (`let maxDuration = 30`)
- **Acronyms**: Treat as words (`httpResponse`, `urlString`, `HTMLParser` at start of type name)
- **Boolean properties**: Read as assertions (`isEnabled`, `hasReminder`, `canSkip`)

## Code Organization

### File Structure

```swift
// 1. Imports (alphabetical)
import AppKit
import SwiftUI

// 2. Type declaration
struct StretchView: View {
    // 3. Properties (grouped by access level)
    // - Public/internal properties
    // - Private properties
    // - Computed properties

    // 4. Body / main implementation

    // 5. Private methods
}

// 6. Extensions (protocol conformances in separate extensions)
extension StretchView: CustomStringConvertible {
    var description: String { ... }
}
```

### MARK Comments

Use `// MARK: -` to organize sections within a file:

```swift
// MARK: - Properties
// MARK: - Lifecycle
// MARK: - Actions
// MARK: - Private Helpers
```

## Formatting

- **Line length**: 120 characters max (SwiftLint default)
- **Indentation**: 4 spaces (no tabs)
- **Trailing commas**: Use in multi-line collections and enums
- **Braces**: Opening brace on same line, closing brace on its own line
- **Blank lines**: One blank line between methods, two between major sections

## SwiftUI Specifics

- Extract subviews when a body exceeds ~30 lines
- Use `@Observable` macro for view models (not ObservableObject)
- Prefer `@State` for view-local state, `@Environment` for injected dependencies
- Name view files to match the view struct (`StretchTimerView.swift`)

```swift
// Preferred
struct StretchCard: View {
    let stretch: Stretch

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            titleSection
            instructionSection
        }
    }

    private var titleSection: some View {
        Text(stretch.name)
            .font(.headline)
    }

    private var instructionSection: some View {
        Text(stretch.instruction)
            .font(.body)
            .foregroundStyle(.secondary)
    }
}
```

## Error Handling

- Use Swift's native error handling (`throws`, `do-catch`)
- Define domain-specific error types as enums conforming to `Error`
- Avoid force unwrapping (`!`) except in tests or truly guaranteed cases
- Prefer `guard let` for early returns over nested `if let`

```swift
enum StretchError: Error {
    case routineNotFound
    case invalidDuration
}
```

## Access Control

- Default to the most restrictive access level needed
- Mark properties and methods `private` unless they need broader access
- Use `fileprivate` sparingly, prefer `private`
- Omit `internal` (it's the default)

## Closures

- Use trailing closure syntax for the last closure parameter
- Use shorthand argument names (`$0`, `$1`) only for simple, obvious closures
- Name closure parameters for anything non-trivial

```swift
// Simple - shorthand OK
stretches.filter { $0.isActive }

// Complex - name parameters
stretches.forEach { stretch in
    scheduleReminder(for: stretch, at: stretch.preferredTime)
}
```

## SwiftLint Configuration

Use SwiftLint with default rules. Key rules enforced:

- `line_length: 120`
- `type_body_length: warning: 250, error: 350`
- `function_body_length: warning: 40, error: 80`
- `force_unwrapping: warning`
- `force_cast: warning`
- `trailing_whitespace: true`
- `vertical_whitespace: max_empty_lines: 1`
