import XCTest
@testable import LetsStretch

final class UserPreferencesTests: XCTestCase {

    private var testDefaults: UserDefaults!
    private var preferences: UserPreferences!

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: "com.lucasprim.LetsStretch.tests")!
        testDefaults.removePersistentDomain(forName: "com.lucasprim.LetsStretch.tests")
        preferences = UserPreferences(defaults: testDefaults)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: "com.lucasprim.LetsStretch.tests")
        testDefaults = nil
        preferences = nil
        super.tearDown()
    }

    // MARK: - Defaults

    func testDefaultReminderInterval() {
        XCTAssertEqual(preferences.reminderIntervalMinutes, 45)
    }

    func testDefaultSnoozeInterval() {
        XCTAssertEqual(preferences.snoozeIntervalMinutes, 10)
    }

    func testDefaultEnabledCategories() {
        XCTAssertEqual(preferences.enabledCategories, [.deskFriendly])
    }

    func testDefaultStretchDuration() {
        XCTAssertEqual(preferences.stretchDurationSeconds, 20)
    }

    func testDefaultRestInterval() {
        XCTAssertEqual(preferences.restIntervalSeconds, 5)
    }

    func testDefaultStretchesPerSession() {
        XCTAssertEqual(preferences.stretchesPerSession, 5)
    }

    func testDefaultLaunchAtLogin() {
        XCTAssertFalse(preferences.launchAtLogin)
    }

    // MARK: - Persistence

    func testReminderIntervalPersists() {
        preferences.reminderIntervalMinutes = 30
        let reloaded = UserPreferences(defaults: testDefaults)
        XCTAssertEqual(reloaded.reminderIntervalMinutes, 30)
    }

    func testSnoozeIntervalPersists() {
        preferences.snoozeIntervalMinutes = 5
        let reloaded = UserPreferences(defaults: testDefaults)
        XCTAssertEqual(reloaded.snoozeIntervalMinutes, 5)
    }

    func testEnabledCategoriesPersists() {
        preferences.enabledCategories = [.deskFriendly, .matRequired]
        let reloaded = UserPreferences(defaults: testDefaults)
        XCTAssertEqual(reloaded.enabledCategories, [.deskFriendly, .matRequired])
    }

    func testLaunchAtLoginPersists() {
        preferences.launchAtLogin = true
        let reloaded = UserPreferences(defaults: testDefaults)
        XCTAssertTrue(reloaded.launchAtLogin)
    }
}
