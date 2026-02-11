import AppKit

@MainActor
final class StatusItemAnimator {
    private let statusItem: NSStatusItem
    private var pulseTimer: Timer?
    private var isPulsing = false
    private var isVisible = true

    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
    }

    func startPulsing() {
        guard !isPulsing else { return }
        isPulsing = true
        isVisible = true

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
    }

    private func toggleVisibility() {
        isVisible.toggle()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            statusItem.button?.animator().alphaValue = isVisible ? 1.0 : 0.3
        }
    }
}
