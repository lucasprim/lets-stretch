import Foundation

enum StretchCategory: String, Codable, CaseIterable {
    case deskFriendly = "desk_friendly"
    case matRequired = "mat_required"

    var displayName: String {
        switch self {
        case .deskFriendly: "Desk-Friendly"
        case .matRequired: "Mat Required"
        }
    }
}

struct Stretch: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let instructions: [String]
    let durationSeconds: Int
    let category: StretchCategory
    let targetArea: String
}
