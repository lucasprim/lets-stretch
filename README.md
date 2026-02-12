# Let's Stretch

A lightweight macOS menu bar app that reminds you to stretch throughout the day. Built with SwiftUI for macOS 14+.

## Features

- **Menu bar app** — lives in your menu bar, stays out of your way
- **18 curated stretches** — designed specifically for desk workers
- **Timed reminders** — configurable intervals with a gentle pulsing icon
- **Step-by-step instructions** — clear visual guidance for each stretch
- **Auto-play sessions** — chain multiple stretches together
- **Launch at login** — start stretching from day one

## Install

### Homebrew (recommended)

```bash
brew install --cask lucasprim/lets-stretch/lets-stretch
```

### Manual download

Head to the [Releases](../../releases/latest) page and download the latest `LetsStretch.zip`. Unzip it and drag `LetsStretch.app` to your Applications folder.

> **Note:** Since the app is not notarized by Apple, macOS will block it on first launch. After unzipping, run this in Terminal:
>
> ```bash
> xattr -cr /Applications/LetsStretch.app
> ```
>
> Then open the app normally. You only need to do this once.

## Build from Source

### Prerequisites

- macOS 14.0 (Sonoma) or later
- Xcode 16+ with Swift 6.0
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

### Steps

```bash
# Clone the repository
git clone https://github.com/lucasprim/lets-stretch.git
cd lets-stretch

# Generate the Xcode project
xcodegen generate

# Build
xcodebuild -project LetsStretch.xcodeproj -scheme LetsStretch -configuration Release build

# Or open in Xcode
open LetsStretch.xcodeproj
```

### Running Tests

```bash
xcodebuild -project LetsStretch.xcodeproj -scheme LetsStretchTests -configuration Debug test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
