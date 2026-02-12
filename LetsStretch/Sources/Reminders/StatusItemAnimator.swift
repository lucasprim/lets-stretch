import AppKit

@MainActor
final class StatusItemAnimator {
    private let statusItem: NSStatusItem
    private var pulseTimer: Timer?
    private var isPulsing = false
    private var isVisible = true
    private var originalImage: NSImage?

    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
    }

    func startPulsing() {
        guard !isPulsing else { return }
        isPulsing = true
        isVisible = true

        if let button = statusItem.button {
            originalImage = button.image
            let config = NSImage.SymbolConfiguration(paletteColors: [.systemRed])
            if let tinted = button.image?.withSymbolConfiguration(config) {
                tinted.isTemplate = false
                button.image = tinted
            }
        }

        pulseTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.toggleVisibility()
            }
        }
    }

    func stopPulsing() {
        isPulsing = false
        pulseTimer?.invalidate()
        pulseTimer = nil
        statusItem.button?.alphaValue = 1.0
        if let originalImage {
            statusItem.button?.image = originalImage
        }
        originalImage = nil
    }

    private func toggleVisibility() {
        isVisible.toggle()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            statusItem.button?.animator().alphaValue = isVisible ? 1.0 : 0.3
        }
    }
}
