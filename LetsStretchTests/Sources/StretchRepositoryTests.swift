import XCTest
@testable import LetsStretch

final class StretchRepositoryTests: XCTestCase {

    private var repository: StretchRepository!

    override func setUp() {
        super.setUp()
        repository = StretchRepository(stretches: Self.testStretches)
    }

    // MARK: - Loading

    func testAllStretchesReturnsAllItems() {
        XCTAssertEqual(repository.allStretches().count, 4)
    }

    // MARK: - Filtering by Category

    func testFilterByDeskFriendly() {
        let deskStretches = repository.stretches(in: .deskFriendly)
        XCTAssertEqual(deskStretches.count, 2)
        XCTAssertTrue(deskStretches.allSatisfy { $0.category == .deskFriendly })
    }

    func testFilterByMatRequired() {
        let matStretches = repository.stretches(in: .matRequired)
        XCTAssertEqual(matStretches.count, 2)
        XCTAssertTrue(matStretches.allSatisfy { $0.category == .matRequired })
    }

    // MARK: - Filtering by Target Area

    func testFilterByTargetArea() {
        let neckStretches = repository.stretches(forTargetArea: "neck")
        XCTAssertEqual(neckStretches.count, 1)
        XCTAssertEqual(neckStretches.first?.id, "desk-1")
    }

    func testFilterByNonExistentTargetArea() {
        let stretches = repository.stretches(forTargetArea: "feet")
        XCTAssertTrue(stretches.isEmpty)
    }

    // MARK: - Random

    func testRandomStretchReturnsNonNil() {
        let stretch = repository.randomStretch()
        XCTAssertNotNil(stretch)
    }

    func testRandomStretchWithCategoryFilter() {
        let stretch = repository.randomStretch(in: [.matRequired])
        XCTAssertNotNil(stretch)
        XCTAssertEqual(stretch?.category, .matRequired)
    }

    func testRandomStretchesRespectsCount() {
        let stretches = repository.randomStretches(count: 2)
        XCTAssertEqual(stretches.count, 2)
    }

    func testRandomStretchesDoesNotExceedAvailable() {
        let stretches = repository.randomStretches(count: 10)
        XCTAssertEqual(stretches.count, 4)
    }

    func testRandomStretchesWithCategoryFilter() {
        let stretches = repository.randomStretches(count: 5, in: [.deskFriendly])
        XCTAssertEqual(stretches.count, 2)
        XCTAssertTrue(stretches.allSatisfy { $0.category == .deskFriendly })
    }

    // MARK: - Bundled JSON Loading

    func testLoadFromBundledJSON() throws {
        let bundle = Bundle(for: type(of: self))
        // This test validates the pattern; the actual JSON is in the main bundle
        // which is available during host-app testing
        let repo = try StretchRepository(bundle: .main)
        let all = repo.allStretches()
        XCTAssertGreaterThanOrEqual(all.count, 18)

        let deskFriendly = repo.stretches(in: .deskFriendly)
        XCTAssertGreaterThanOrEqual(deskFriendly.count, 12)

        let matRequired = repo.stretches(in: .matRequired)
        XCTAssertGreaterThanOrEqual(matRequired.count, 6)
    }

    // MARK: - Test Data

    private static let testStretches: [Stretch] = [
        Stretch(
            id: "desk-1",
            name: "Desk Stretch 1",
            description: "A desk stretch targeting the neck.",
            instructions: ["Step 1", "Step 2"],
            durationSeconds: 20,
            category: .deskFriendly,
            targetArea: "neck"
        ),
        Stretch(
            id: "desk-2",
            name: "Desk Stretch 2",
            description: "A desk stretch targeting the shoulders.",
            instructions: ["Step 1"],
            durationSeconds: 25,
            category: .deskFriendly,
            targetArea: "shoulders"
        ),
        Stretch(
            id: "mat-1",
            name: "Mat Stretch 1",
            description: "A mat stretch targeting the back.",
            instructions: ["Step 1", "Step 2", "Step 3"],
            durationSeconds: 30,
            category: .matRequired,
            targetArea: "back"
        ),
        Stretch(
            id: "mat-2",
            name: "Mat Stretch 2",
            description: "A mat stretch targeting the hips.",
            instructions: ["Step 1"],
            durationSeconds: 30,
            category: .matRequired,
            targetArea: "hips"
        ),
    ]
}
