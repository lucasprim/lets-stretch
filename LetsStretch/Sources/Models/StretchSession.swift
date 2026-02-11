import Foundation

struct StretchSession: Identifiable {
    let id: UUID
    let stretches: [Stretch]
    let stretchDurationSeconds: Int
    let restIntervalSeconds: Int
    let startedAt: Date

    init(
        stretches: [Stretch],
        stretchDurationSeconds: Int = 20,
        restIntervalSeconds: Int = 5
    ) {
        self.id = UUID()
        self.stretches = stretches
        self.stretchDurationSeconds = stretchDurationSeconds
        self.restIntervalSeconds = restIntervalSeconds
        self.startedAt = Date()
    }

    var totalDurationSeconds: Int {
        let stretchTime = stretches.count * stretchDurationSeconds
        let restTime = max(0, stretches.count - 1) * restIntervalSeconds
        return stretchTime + restTime
    }
}
