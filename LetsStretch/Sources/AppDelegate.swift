import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var statusItemAnimator: StatusItemAnimator?
    private var reminderScheduler: ReminderScheduler?
    let preferences = UserPreferences()
    private var repository: StretchRepository?
    private var popoverManager: StretchPopoverManager?

    private var snoozeMenuItem: NSMenuItem?
    private var skipMenuItem: NSMenuItem?
    private var stretchMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupRepository()
        setupStatusItem()
        setupPopover()
        setupMenu()
        setupReminder()
    }

    // MARK: - Setup

    private func setupRepository() {
        repository = try? StretchRepository()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "figure.cooldown",
                accessibilityDescription: "Let's Stretch"
            )
            button.action = #selector(statusItemClicked)
            button.target = self
        }

        if let statusItem {
            statusItemAnimator = StatusItemAnimator(statusItem: statusItem)
        }
    }

    private func setupPopover() {
        let manager = StretchPopoverManager()
        if let statusItem {
            manager.configure(statusItem: statusItem)
        }
        manager.onDone = { [weak self] in
            self?.handleStretchDone()
        }
        manager.onSkip = { [weak self] in
            self?.handleStretchSkipped()
        }
        manager.onStartSession = { [weak self] in
            self?.handleStartSession()
        }
        popoverManager = manager
    }

    private func setupMenu() {
        let menu = NSMenu()
        addStretchItems(to: menu)
        menu.addItem(NSMenuItem.separator())
        addReminderItems(to: menu)
        menu.addItem(NSMenuItem.separator())
        addAppItems(to: menu)
        statusItem?.menu = menu
    }

    private func addStretchItems(to menu: NSMenu) {
        let stretchItem = NSMenuItem(
            title: "Show Stretch",
            action: #selector(showRandomStretch),
            keyEquivalent: "s"
        )
        stretchMenuItem = stretchItem
        menu.addItem(stretchItem)
        menu.addItem(NSMenuItem(
            title: "Start Session",
            action: #selector(startAutoPlaySession),
            keyEquivalent: ""
        ))
    }

    private func addReminderItems(to menu: NSMenu) {
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
    }

    private func addAppItems(to menu: NSMenu) {
        menu.addItem(NSMenuItem(
            title: "Settings...",
            action: #selector(showSettings),
            keyEquivalent: ","
        ))
        menu.addItem(NSMenuItem(
            title: "About Let's Stretch",
            action: #selector(showAbout),
            keyEquivalent: ""
        ))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Quit Let's Stretch",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
    }

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

    @objc private func statusItemClicked() {
        if reminderScheduler?.state == .reminded {
            showRandomStretch()
        }
    }

    @objc private func showRandomStretch() {
        let categories = preferences.enabledCategories
        guard let stretch = repository?.randomStretch(in: categories) else { return }
        popoverManager?.show(stretch: stretch)
    }

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

    @objc private func showSettings() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    @objc private func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    // MARK: - Stretch Actions

    private func handleStretchDone() {
        reminderScheduler?.dismiss()
        statusItemAnimator?.stopPulsing()
        updateReminderMenuItems(visible: false)
    }

    private func handleStretchSkipped() {
        reminderScheduler?.skip()
        statusItemAnimator?.stopPulsing()
        updateReminderMenuItems(visible: false)
    }

    private func handleStartSession() {
        reminderScheduler?.dismiss()
        statusItemAnimator?.stopPulsing()
        updateReminderMenuItems(visible: false)
        startAutoPlaySession()
    }

    @objc private func startAutoPlaySession() {
        let categories = preferences.enabledCategories
        guard let repository else { return }
        let stretches = repository.randomStretches(
            count: preferences.stretchesPerSession,
            in: categories
        )
        guard !stretches.isEmpty else { return }

        let player = SessionPlayer(
            stretches: stretches,
            stretchDurationSeconds: preferences.stretchDurationSeconds,
            restIntervalSeconds: preferences.restIntervalSeconds
        )
        player.start()
        popoverManager?.showAutoPlay(player: player)
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
