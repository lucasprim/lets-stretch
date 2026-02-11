import Foundation

@Observable
final class UserPreferences {
    private let defaults: UserDefaults

    var reminderIntervalMinutes: Int {
        didSet { defaults.set(reminderIntervalMinutes, forKey: Keys.reminderInterval) }
    }

    var snoozeIntervalMinutes: Int {
        didSet { defaults.set(snoozeIntervalMinutes, forKey: Keys.snoozeInterval) }
    }

    var enabledCategories: Set<StretchCategory> {
        didSet {
            let rawValues = enabledCategories.map(\.rawValue)
            defaults.set(rawValues, forKey: Keys.enabledCategories)
        }
    }

    var stretchDurationSeconds: Int {
        didSet { defaults.set(stretchDurationSeconds, forKey: Keys.stretchDuration) }
    }

    var restIntervalSeconds: Int {
        didSet { defaults.set(restIntervalSeconds, forKey: Keys.restInterval) }
    }

    var stretchesPerSession: Int {
        didSet { defaults.set(stretchesPerSession, forKey: Keys.stretchesPerSession) }
    }

    var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: Keys.launchAtLogin) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        self.reminderIntervalMinutes = defaults.object(forKey: Keys.reminderInterval) as? Int
            ?? Defaults.reminderIntervalMinutes
        self.snoozeIntervalMinutes = defaults.object(forKey: Keys.snoozeInterval) as? Int
            ?? Defaults.snoozeIntervalMinutes
        self.stretchDurationSeconds = defaults.object(forKey: Keys.stretchDuration) as? Int
            ?? Defaults.stretchDurationSeconds
        self.restIntervalSeconds = defaults.object(forKey: Keys.restInterval) as? Int
            ?? Defaults.restIntervalSeconds
        self.stretchesPerSession = defaults.object(forKey: Keys.stretchesPerSession) as? Int
            ?? Defaults.stretchesPerSession
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)

        if let rawValues = defaults.stringArray(forKey: Keys.enabledCategories) {
            self.enabledCategories = Set(rawValues.compactMap { StretchCategory(rawValue: $0) })
        } else {
            self.enabledCategories = Defaults.enabledCategories
        }
    }

    // MARK: - Constants

    private enum Keys {
        static let reminderInterval = "reminderIntervalMinutes"
        static let snoozeInterval = "snoozeIntervalMinutes"
        static let enabledCategories = "enabledCategories"
        static let stretchDuration = "stretchDurationSeconds"
        static let restInterval = "restIntervalSeconds"
        static let stretchesPerSession = "stretchesPerSession"
        static let launchAtLogin = "launchAtLogin"
    }

    enum Defaults {
        static let reminderIntervalMinutes = 45
        static let snoozeIntervalMinutes = 10
        static let enabledCategories: Set<StretchCategory> = [.deskFriendly]
        static let stretchDurationSeconds = 20
        static let restIntervalSeconds = 5
        static let stretchesPerSession = 5
    }
}
