import Foundation

enum StretchRepositoryError: Error {
    case fileNotFound
    case decodingFailed(Error)
}

final class StretchRepository: Sendable {
    private let stretches: [Stretch]

    init(bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: "stretches", withExtension: "json") else {
            throw StretchRepositoryError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.stretches = try decoder.decode([Stretch].self, from: data)
        } catch let error as DecodingError {
            throw StretchRepositoryError.decodingFailed(error)
        }
    }

    init(stretches: [Stretch]) {
        self.stretches = stretches
    }

    func allStretches() -> [Stretch] {
        stretches
    }

    func stretches(in category: StretchCategory) -> [Stretch] {
        stretches.filter { $0.category == category }
    }

    func stretches(forTargetArea targetArea: String) -> [Stretch] {
        stretches.filter { $0.targetArea == targetArea }
    }

    func randomStretch(in categories: Set<StretchCategory>? = nil) -> Stretch? {
        let filtered: [Stretch]
        if let categories {
            filtered = stretches.filter { categories.contains($0.category) }
        } else {
            filtered = stretches
        }
        return filtered.randomElement()
    }

    func cycledStretch(at index: Int, in categories: Set<StretchCategory>? = nil) -> (stretch: Stretch, nextIndex: Int)? {
        let filtered: [Stretch]
        if let categories {
            filtered = stretches.filter { categories.contains($0.category) }
        } else {
            filtered = stretches
        }
        guard !filtered.isEmpty else { return nil }
        let safeIndex = index % filtered.count
        return (filtered[safeIndex], (safeIndex + 1) % filtered.count)
    }

    func randomStretches(count: Int, in categories: Set<StretchCategory>? = nil) -> [Stretch] {
        let filtered: [Stretch]
        if let categories {
            filtered = stretches.filter { categories.contains($0.category) }
        } else {
            filtered = stretches
        }
        return Array(filtered.shuffled().prefix(count))
    }
}
