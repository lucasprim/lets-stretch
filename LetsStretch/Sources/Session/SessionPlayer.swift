import Foundation

@Observable
@MainActor
final class SessionPlayer {
    enum Phase: Equatable {
        case stretching(index: Int)
        case resting(nextIndex: Int)
        case completed
    }

    enum PlayState: Equatable {
        case playing
        case paused
    }

    private(set) var phase: Phase = .stretching(index: 0)
    private(set) var playState: PlayState = .playing
    private(set) var secondsRemaining: Int = 0

    let stretches: [Stretch]
    let stretchDurationSeconds: Int
    let restIntervalSeconds: Int

    private var timer: Timer?

    var currentStretch: Stretch? {
        switch phase {
        case .stretching(let index):
            return stretches[safe: index]
        case .resting(let nextIndex):
            return stretches[safe: nextIndex]
        case .completed:
            return nil
        }
    }

    var currentStretchIndex: Int {
        switch phase {
        case .stretching(let index): return index
        case .resting(let nextIndex): return nextIndex - 1
        case .completed: return stretches.count - 1
        }
    }

    var totalStretches: Int { stretches.count }

    var isResting: Bool {
        if case .resting = phase { return true }
        return false
    }

    var isCompleted: Bool {
        phase == .completed
    }

    var progress: Double {
        guard !stretches.isEmpty else { return 0 }
        switch phase {
        case .stretching(let index):
            let elapsed = Double(stretchDurationSeconds - secondsRemaining)
            let stretchProgress = elapsed / Double(max(stretchDurationSeconds, 1))
            return (Double(index) + stretchProgress) / Double(stretches.count)
        case .resting(let nextIndex):
            return Double(nextIndex) / Double(stretches.count)
        case .completed:
            return 1.0
        }
    }

    init(
        stretches: [Stretch],
        stretchDurationSeconds: Int = 20,
        restIntervalSeconds: Int = 5
    ) {
        self.stretches = stretches
        self.stretchDurationSeconds = stretchDurationSeconds
        self.restIntervalSeconds = restIntervalSeconds
        self.secondsRemaining = stretchDurationSeconds
    }

    func prepare() {
        guard !stretches.isEmpty else {
            phase = .completed
            return
        }
        phase = .stretching(index: 0)
        playState = .paused
        secondsRemaining = stretchDurationSeconds
    }

    func start() {
        guard !stretches.isEmpty else {
            phase = .completed
            return
        }
        phase = .stretching(index: 0)
        playState = .playing
        secondsRemaining = stretchDurationSeconds
        startTimer()
    }

    func pause() {
        guard playState == .playing else { return }
        playState = .paused
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        guard playState == .paused else { return }
        playState = .playing
        startTimer()
    }

    func togglePauseResume() {
        if playState == .playing {
            pause()
        } else {
            resume()
        }
    }

    func skipStretch() {
        timer?.invalidate()
        timer = nil
        advanceToNext()
    }

    func endSession() {
        timer?.invalidate()
        timer = nil
        phase = .completed
        playState = .paused
    }

    // MARK: - For Testing

    func tick() {
        handleTick()
    }

    // MARK: - Private

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.handleTick()
            }
        }
    }

    private func handleTick() {
        guard playState == .playing else { return }

        secondsRemaining -= 1

        if secondsRemaining <= 0 {
            advanceToNext()
        }
    }

    private func advanceToNext() {
        switch phase {
        case .stretching(let index):
            let nextIndex = index + 1
            if nextIndex < stretches.count {
                // Start rest interval before next stretch
                phase = .resting(nextIndex: nextIndex)
                secondsRemaining = restIntervalSeconds
                if playState == .playing {
                    startTimer()
                }
            } else {
                // Session complete
                phase = .completed
                playState = .paused
                timer?.invalidate()
                timer = nil
            }

        case .resting(let nextIndex):
            // Start next stretch
            phase = .stretching(index: nextIndex)
            secondsRemaining = stretchDurationSeconds
            if playState == .playing {
                startTimer()
            }

        case .completed:
            break
        }
    }
}

// MARK: - Collection Safe Subscript

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
