import XCTest
@testable import LetsStretch

@MainActor
final class SessionPlayerTests: XCTestCase {

    private var player: SessionPlayer!
    private let testStretches = [
        Stretch(
            id: "s1", name: "Stretch 1", description: "Desc 1",
            instructions: ["Step 1"], durationSeconds: 20,
            category: .deskFriendly, targetArea: "neck"
        ),
        Stretch(
            id: "s2", name: "Stretch 2", description: "Desc 2",
            instructions: ["Step 1"], durationSeconds: 20,
            category: .deskFriendly, targetArea: "shoulders"
        ),
        Stretch(
            id: "s3", name: "Stretch 3", description: "Desc 3",
            instructions: ["Step 1"], durationSeconds: 20,
            category: .deskFriendly, targetArea: "back"
        ),
    ]

    override func setUp() {
        super.setUp()
        player = SessionPlayer(
            stretches: testStretches,
            stretchDurationSeconds: 3,
            restIntervalSeconds: 2
        )
    }

    override func tearDown() {
        player.endSession()
        player = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func testInitialPhaseIsStretchingAtZero() {
        XCTAssertEqual(player.phase, .stretching(index: 0))
    }

    func testStartSetsSecondsRemaining() {
        player.start()
        XCTAssertEqual(player.secondsRemaining, 3)
    }

    func testStartWithEmptyStretchesCompletesImmediately() {
        let emptyPlayer = SessionPlayer(stretches: [])
        emptyPlayer.start()
        XCTAssertTrue(emptyPlayer.isCompleted)
    }

    // MARK: - Tick / Sequencing

    func testTickDecrementsSeconds() {
        player.start()
        player.tick()
        XCTAssertEqual(player.secondsRemaining, 2)
    }

    func testStretchTransitionsToRestAfterDuration() {
        player.start()
        // Tick 3 times to exhaust stretch duration
        player.tick()
        player.tick()
        player.tick()
        XCTAssertEqual(player.phase, .resting(nextIndex: 1))
        XCTAssertEqual(player.secondsRemaining, 2)
    }

    func testRestTransitionsToNextStretch() {
        player.start()
        // Complete first stretch (3 ticks)
        player.tick(); player.tick(); player.tick()
        // Complete rest interval (2 ticks)
        player.tick(); player.tick()
        XCTAssertEqual(player.phase, .stretching(index: 1))
        XCTAssertEqual(player.secondsRemaining, 3)
    }

    func testSessionCompletesAfterAllStretches() {
        player.start()
        // Stretch 1: 3 ticks, Rest: 2 ticks
        // Stretch 2: 3 ticks, Rest: 2 ticks
        // Stretch 3: 3 ticks
        for _ in 0..<13 {
            player.tick()
        }
        XCTAssertTrue(player.isCompleted)
    }

    // MARK: - Pause / Resume

    func testPauseChangesPlayState() {
        player.start()
        player.pause()
        XCTAssertEqual(player.playState, .paused)
    }

    func testResumeChangesPlayState() {
        player.start()
        player.pause()
        player.resume()
        XCTAssertEqual(player.playState, .playing)
    }

    func testTickDoesNothingWhenPaused() {
        player.start()
        player.pause()
        let before = player.secondsRemaining
        player.tick()
        XCTAssertEqual(player.secondsRemaining, before)
    }

    func testTogglePauseResume() {
        player.start()
        player.togglePauseResume()
        XCTAssertEqual(player.playState, .paused)
        player.togglePauseResume()
        XCTAssertEqual(player.playState, .playing)
    }

    // MARK: - Skip

    func testSkipAdvancesToRestThenNextStretch() {
        player.start()
        player.skipStretch()
        // Should be resting before next stretch
        XCTAssertEqual(player.phase, .resting(nextIndex: 1))
    }

    func testSkipLastStretchCompletesSession() {
        player.start()
        // Skip to last stretch
        player.skipStretch() // -> rest before 2
        player.skipStretch() // -> stretching 1 (rest skipped too? No, skip from rest goes to stretching)

        // Let me verify: skip from resting should advance to next stretch
        // Actually skip calls advanceToNext which from .stretching goes to .resting
        // So: start -> stretching(0), skip -> resting(1), skip from rest -> stretching(1)
        // skip again -> resting(2), skip -> stretching(2), skip -> completed
        player.skipStretch() // stretching(1) -> resting(2)
        player.skipStretch() // resting(2) -> stretching(2)
        player.skipStretch() // stretching(2) -> completed (last stretch)
        XCTAssertTrue(player.isCompleted)
    }

    // MARK: - End Session

    func testEndSessionCompletesImmediately() {
        player.start()
        player.endSession()
        XCTAssertTrue(player.isCompleted)
        XCTAssertEqual(player.playState, .paused)
    }

    // MARK: - Progress

    func testProgressStartsAtZero() {
        XCTAssertEqual(player.progress, 0.0, accuracy: 0.01)
    }

    func testProgressAfterOneStretch() {
        player.start()
        // Complete first stretch
        player.tick(); player.tick(); player.tick()
        // Now resting before stretch 2, so 1/3 complete
        XCTAssertEqual(player.progress, 1.0 / 3.0, accuracy: 0.01)
    }

    func testProgressWhenCompleted() {
        player.start()
        for _ in 0..<13 {
            player.tick()
        }
        XCTAssertEqual(player.progress, 1.0, accuracy: 0.01)
    }

    // MARK: - Current Stretch

    func testCurrentStretchDuringStretching() {
        player.start()
        XCTAssertEqual(player.currentStretch?.id, "s1")
    }

    func testCurrentStretchDuringRest() {
        player.start()
        player.tick(); player.tick(); player.tick()
        // During rest, currentStretch shows the next stretch
        XCTAssertEqual(player.currentStretch?.id, "s2")
    }

    func testCurrentStretchWhenCompleted() {
        player.start()
        player.endSession()
        XCTAssertNil(player.currentStretch)
    }
}
