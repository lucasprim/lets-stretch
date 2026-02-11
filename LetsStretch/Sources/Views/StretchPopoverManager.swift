import AppKit
import SwiftUI

@MainActor
final class StretchPopoverManager {
    private let popover = NSPopover()
    private var statusItem: NSStatusItem?

    var onDone: (() -> Void)?
    var onSkip: (() -> Void)?
    var onStartSession: (() -> Void)?

    init() {
        popover.behavior = .transient
        popover.animates = true
    }

    func configure(statusItem: NSStatusItem) {
        self.statusItem = statusItem
    }

    func show(stretch: Stretch) {
        let view = StretchDetailView(
            stretch: stretch,
            onDone: { [weak self] in
                self?.close()
                self?.onDone?()
            },
            onSkip: { [weak self] in
                self?.close()
                self?.onSkip?()
            },
            onStartSession: { [weak self] in
                self?.close()
                self?.onStartSession?()
            }
        )

        showView(view)
    }

    func showAutoPlay(player: SessionPlayer) {
        let view = AutoPlayView(
            player: player,
            onComplete: { [weak self] in
                self?.close()
                self?.onDone?()
            },
            onEnd: { [weak self] in
                self?.close()
                self?.onDone?()
            }
        )

        popover.behavior = .applicationDefined
        showView(view)
    }

    func close() {
        popover.performClose(nil)
        popover.behavior = .transient
    }

    var isShown: Bool {
        popover.isShown
    }

    // MARK: - Private

    private func showView<V: View>(_ view: V) {
        popover.contentViewController = NSHostingController(rootView: view)

        guard let button = statusItem?.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
}
