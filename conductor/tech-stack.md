# Tech Stack - Let's Stretch

## Language

- **Swift** (latest stable version)
- Minimum deployment target: **macOS 14 (Sonoma)**

## UI Framework

- **SwiftUI** - Primary UI framework for declarative, modern interface
- **AppKit** - For advanced customization, menu bar integration, and system-level features not yet available in SwiftUI

## Persistence

- **UserDefaults** - User preferences (reminder intervals, stretch preferences, etc.)
- **JSON files** - Bundled stretch data, routine definitions, and session history

## Architecture

- **MVVM** with SwiftUI's native observation patterns
- `@Observable` macro (Swift 5.9+) for view models
- Combine for reactive event handling where needed

## Key System Frameworks

- **UserNotifications** - Stretch reminders and notifications
- **AppKit (NSStatusItem)** - Menu bar presence
- **SwiftUI Animations** - Stretch instruction animations

## Distribution

- **Direct download** (website distribution)
- Code-signed and notarized for Gatekeeper compatibility
- No App Store sandbox restrictions

## Build & Development

- **Xcode** (latest stable)
- **Swift Package Manager** for dependency management
- **SwiftLint** for code style enforcement

## Testing

- **XCTest** - Unit and integration tests
- **XCUITest** - UI tests where applicable
