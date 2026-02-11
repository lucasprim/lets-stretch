import Foundation

@MainActor
protocol ReminderSchedulerDelegate: AnyObject {
    func reminderDidFire()
}

protocol TimerProvider {
    func scheduledTimer(
        withTimeInterval interval: TimeInterval,
        repeats: Bool,
        block: @escaping @Sendable (Timer) -> Void
    ) -> Timer
}

struct DefaultTimerProvider: TimerProvider {
    func scheduledTimer(
        withTimeInterval interval: TimeInterval,
        repeats: Bool,
        block: @escaping @Sendable (Timer) -> Void
    ) -> Timer {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
    }
}

@Observable
@MainActor
final class ReminderScheduler {
    enum State: Equatable {
        case idle
        case scheduled
        case reminded
        case snoozed
    }

    private(set) var state: State = .idle
    private var timer: Timer?
    private let timerProvider: TimerProvider

    weak var delegate: ReminderSchedulerDelegate?

    var intervalMinutes: Int
    var snoozeMinutes: Int

    init(
        intervalMinutes: Int = 45,
        snoozeMinutes: Int = 10,
        timerProvider: TimerProvider = DefaultTimerProvider()
    ) {
        self.intervalMinutes = intervalMinutes
        self.snoozeMinutes = snoozeMinutes
        self.timerProvider = timerProvider
    }

    func start() {
        stop()
        scheduleTimer(minutes: intervalMinutes)
        state = .scheduled
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        state = .idle
    }

    func snooze() {
        guard state == .reminded else { return }
        scheduleTimer(minutes: snoozeMinutes)
        state = .snoozed
    }

    func skip() {
        guard state == .reminded || state == .snoozed else { return }
        scheduleTimer(minutes: intervalMinutes)
        state = .scheduled
    }

    func dismiss() {
        guard state == .reminded else { return }
        scheduleTimer(minutes: intervalMinutes)
        state = .scheduled
    }

    // MARK: - Internal (for testing)

    func fireForTesting() {
        handleTimerFired()
    }

    // MARK: - Private

    private func scheduleTimer(minutes: Int) {
        timer?.invalidate()
        let interval = TimeInterval(minutes * 60)
        timer = timerProvider.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.handleTimerFired()
            }
        }
    }

    private func handleTimerFired() {
        state = .reminded
        delegate?.reminderDidFire()
    }
}
