import XCTest
@testable import LetsStretch

final class StretchTests: XCTestCase {

    // MARK: - Model Tests

    func testStretchDecodingFromJSON() throws {
        let json = """
        {
            "id": "test-stretch",
            "name": "Test Stretch",
            "description": "A test stretch.",
            "instructions": ["Step 1", "Step 2"],
            "durationSeconds": 20,
            "category": "desk_friendly",
            "targetArea": "neck"
        }
        """.data(using: .utf8)!

        let stretch = try JSONDecoder().decode(Stretch.self, from: json)

        XCTAssertEqual(stretch.id, "test-stretch")
        XCTAssertEqual(stretch.name, "Test Stretch")
        XCTAssertEqual(stretch.category, .deskFriendly)
        XCTAssertEqual(stretch.instructions.count, 2)
        XCTAssertEqual(stretch.durationSeconds, 20)
        XCTAssertEqual(stretch.targetArea, "neck")
    }

    func testStretchCategoryDisplayName() {
        XCTAssertEqual(StretchCategory.deskFriendly.displayName, "Desk-Friendly")
        XCTAssertEqual(StretchCategory.matRequired.displayName, "Mat Required")
    }

    func testStretchCategoryRawValues() {
        XCTAssertEqual(StretchCategory.deskFriendly.rawValue, "desk_friendly")
        XCTAssertEqual(StretchCategory.matRequired.rawValue, "mat_required")
    }

    // MARK: - StretchSession Tests

    func testSessionTotalDuration() {
        let stretches = makeTestStretches(count: 3)
        let session = StretchSession(
            stretches: stretches,
            stretchDurationSeconds: 20,
            restIntervalSeconds: 5
        )

        // 3 stretches * 20s + 2 rest intervals * 5s = 70s
        XCTAssertEqual(session.totalDurationSeconds, 70)
    }

    func testSessionSingleStretchNoRestInterval() {
        let stretches = makeTestStretches(count: 1)
        let session = StretchSession(
            stretches: stretches,
            stretchDurationSeconds: 20,
            restIntervalSeconds: 5
        )

        // 1 stretch * 20s + 0 rest intervals = 20s
        XCTAssertEqual(session.totalDurationSeconds, 20)
    }

    // MARK: - Helpers

    private func makeTestStretches(count: Int) -> [Stretch] {
        (0..<count).map { index in
            Stretch(
                id: "test-\(index)",
                name: "Test Stretch \(index)",
                description: "Description \(index)",
                instructions: ["Step 1"],
                durationSeconds: 20,
                category: .deskFriendly,
                targetArea: "neck"
            )
        }
    }
}
