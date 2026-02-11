import XCTest
@testable import LetsStretch

@MainActor
final class ReminderSchedulerTests: XCTestCase {

    private var scheduler: ReminderScheduler!
    private var delegateSpy: DelegateSpy!

    override func setUp() {
        super.setUp()
        scheduler = ReminderScheduler(intervalMinutes: 45, snoozeMinutes: 10)
        delegateSpy = DelegateSpy()
        scheduler.delegate = delegateSpy
    }

    override func tearDown() {
        scheduler.stop()
        scheduler = nil
        delegateSpy = nil
        super.tearDown()
    }

    // MARK: - State

    func testInitialStateIsIdle() {
        XCTAssertEqual(scheduler.state, .idle)
    }

    func testStartChangesStateToScheduled() {
        scheduler.start()
        XCTAssertEqual(scheduler.state, .scheduled)
    }

    func testStopChangesStateToIdle() {
        scheduler.start()
        scheduler.stop()
        XCTAssertEqual(scheduler.state, .idle)
    }

    // MARK: - Firing

    func testFiringChangesStateToReminded() {
        scheduler.start()
        scheduler.fireForTesting()
        XCTAssertEqual(scheduler.state, .reminded)
    }

    func testFiringCallsDelegate() {
        scheduler.start()
        scheduler.fireForTesting()
        XCTAssertTrue(delegateSpy.didFire)
    }

    // MARK: - Snooze

    func testSnoozeFromRemindedChangesToSnoozed() {
        scheduler.start()
        scheduler.fireForTesting()
        scheduler.snooze()
        XCTAssertEqual(scheduler.state, .snoozed)
    }

    func testSnoozeFromIdleDoesNothing() {
        scheduler.snooze()
        XCTAssertEqual(scheduler.state, .idle)
    }

    func testSnoozeFromScheduledDoesNothing() {
        scheduler.start()
        scheduler.snooze()
        XCTAssertEqual(scheduler.state, .scheduled)
    }

    // MARK: - Skip

    func testSkipFromRemindedChangesToScheduled() {
        scheduler.start()
        scheduler.fireForTesting()
        scheduler.skip()
        XCTAssertEqual(scheduler.state, .scheduled)
    }

    func testSkipFromSnoozedChangesToScheduled() {
        scheduler.start()
        scheduler.fireForTesting()
        scheduler.snooze()
        scheduler.skip()
        XCTAssertEqual(scheduler.state, .scheduled)
    }

    func testSkipFromIdleDoesNothing() {
        scheduler.skip()
        XCTAssertEqual(scheduler.state, .idle)
    }

    // MARK: - Dismiss

    func testDismissFromRemindedChangesToScheduled() {
        scheduler.start()
        scheduler.fireForTesting()
        scheduler.dismiss()
        XCTAssertEqual(scheduler.state, .scheduled)
    }

    func testDismissFromIdleDoesNothing() {
        scheduler.dismiss()
        XCTAssertEqual(scheduler.state, .idle)
    }

    // MARK: - Configuration

    func testIntervalIsConfigurable() {
        scheduler.intervalMinutes = 30
        XCTAssertEqual(scheduler.intervalMinutes, 30)
    }

    func testSnoozeMinutesIsConfigurable() {
        scheduler.snoozeMinutes = 5
        XCTAssertEqual(scheduler.snoozeMinutes, 5)
    }

    // MARK: - Helpers

    private final class DelegateSpy: ReminderSchedulerDelegate {
        var didFire = false

        func reminderDidFire() {
            didFire = true
        }
    }
}
