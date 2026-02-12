import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var statusItemAnimator: StatusItemAnimator?
    private var reminderScheduler: ReminderScheduler?
    let preferences = UserPreferences()
    private var repository: StretchRepository?
    private var popoverManager: StretchPopoverManager?

    private var statusMenu: NSMenu?
    private var settingsWindow: NSWindow?
    private var snoozeMenuItem: NSMenuItem?
    private var skipMenuItem: NSMenuItem?
    private var stretchMenuItem: NSMenuItem?
    private var stretchCycleIndex: Int {
        get { UserDefaults.standard.integer(forKey: "stretchCycleIndex") }
        set { UserDefaults.standard.set(newValue, forKey: "stretchCycleIndex") }
    }

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
        manager.onTryAnother = { [weak self] in
            self?.showNextStretch()
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
        statusMenu = menu
    }

    private func addStretchItems(to menu: NSMenu) {
        let stretchItem = NSMenuItem(
            title: "Show Stretch",
            action: #selector(showNextStretch),
            keyEquivalent: ""
        )
        stretchItem.target = self
        stretchMenuItem = stretchItem
        menu.addItem(stretchItem)

        let sessionItem = NSMenuItem(
            title: "Start Session",
            action: #selector(startAutoPlaySession),
            keyEquivalent: ""
        )
        sessionItem.target = self
        menu.addItem(sessionItem)
    }

    private func addReminderItems(to menu: NSMenu) {
        let snooze = NSMenuItem(
            title: "Snooze (\(preferences.snoozeIntervalMinutes) min)",
            action: #selector(snoozeReminder),
            keyEquivalent: ""
        )
        snooze.target = self
        snooze.isHidden = true
        snoozeMenuItem = snooze
        menu.addItem(snooze)

        let skip = NSMenuItem(
            title: "Skip",
            action: #selector(skipReminder),
            keyEquivalent: ""
        )
        skip.target = self
        skip.isHidden = true
        skipMenuItem = skip
        menu.addItem(skip)
    }

    private func addAppItems(to menu: NSMenu) {
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(showSettings),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        let aboutItem = NSMenuItem(
            title: "About Let's Stretch",
            action: #selector(showAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)

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
            showNextStretch()
        } else {
            guard let button = statusItem?.button, let menu = statusMenu else { return }
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 5), in: button)
        }
    }

    @objc private func showNextStretch() {
        let categories = preferences.enabledCategories
        guard let result = repository?.cycledStretch(at: stretchCycleIndex, in: categories) else { return }
        stretchCycleIndex = result.nextIndex
        popoverManager?.show(stretch: result.stretch)
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
        if let existing = settingsWindow, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hostingController = NSHostingController(
            rootView: SettingsView(preferences: preferences)
        )
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Let's Stretch Settings"
        window.styleMask = [.titled, .closable]
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow = window
    }

    @objc private func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        let credits = NSMutableAttributedString()
        let style = NSMutableParagraphStyle()
        style.alignment = .center

        let bodyAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11),
            .foregroundColor: NSColor.secondaryLabelColor,
            .paragraphStyle: style
        ]
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 11),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: style
        ]

        credits.append(NSAttributedString(string: "Created by ", attributes: bodyAttrs))
        credits.append(NSAttributedString(string: "Lucas Prim", attributes: boldAttrs))
        credits.append(NSAttributedString(string: "\nBuilt with ", attributes: bodyAttrs))
        credits.append(NSAttributedString(string: "Claude Code", attributes: boldAttrs))
        credits.append(NSAttributedString(
            string: "\n\nA gentle reminder to stretch throughout your day.",
            attributes: bodyAttrs
        ))

        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: "Let's Stretch",
            .credits: credits
        ])
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
        player.prepare()
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
