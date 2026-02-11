import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var statusItemAnimator: StatusItemAnimator?
    private var reminderScheduler: ReminderScheduler?
    private let preferences = UserPreferences()

    private var snoozeMenuItem: NSMenuItem?
    private var skipMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupMenu()
        setupReminder()
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "figure.cooldown",
                accessibilityDescription: "Let's Stretch"
            )
        }

        if let statusItem {
            statusItemAnimator = StatusItemAnimator(statusItem: statusItem)
        }
    }

    // MARK: - Menu

    private func setupMenu() {
        let menu = NSMenu()

        let snooze = NSMenuItem(
            title: "Snooze (\(preferences.snoozeIntervalMinutes) min)",
            action: #selector(snoozeReminder),
            keyEquivalent: ""
        )
        snooze.isHidden = true
        snoozeMenuItem = snooze
        menu.addItem(snooze)

        let skip = NSMenuItem(
            title: "Skip",
            action: #selector(skipReminder),
            keyEquivalent: ""
        )
        skip.isHidden = true
        skipMenuItem = skip
        menu.addItem(skip)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(
            NSMenuItem(
                title: "About Let's Stretch",
                action: #selector(showAbout),
                keyEquivalent: ""
            )
        )

        menu.addItem(NSMenuItem.separator())

        menu.addItem(
            NSMenuItem(
                title: "Quit Let's Stretch",
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q"
            )
        )

        statusItem?.menu = menu
    }

    // MARK: - Reminder

    private func setupReminder() {
        let scheduler = ReminderScheduler(
            intervalMinutes: preferences.reminderIntervalMinutes,
            snoozeMinutes: preferences.snoozeIntervalMinutes
        )
        scheduler.delegate = self
        scheduler.start()
        reminderScheduler = scheduler
    }

    // MARK: - Actions

    @objc private func snoozeReminder() {
        reminderScheduler?.snooze()
        statusItemAnimator?.stopPulsing()
        updateReminderMenuItems(visible: false)
    }

    @objc private func skipReminder() {
        reminderScheduler?.skip()
        statusItemAnimator?.stopPulsing()
        updateReminderMenuItems(visible: false)
    }

    @objc private func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    // MARK: - Helpers

    private func updateReminderMenuItems(visible: Bool) {
        snoozeMenuItem?.isHidden = !visible
        skipMenuItem?.isHidden = !visible
    }
}

// MARK: - ReminderSchedulerDelegate

extension AppDelegate: ReminderSchedulerDelegate {
    func reminderDidFire() {
        statusItemAnimator?.startPulsing()
        updateReminderMenuItems(visible: true)
    }
}
