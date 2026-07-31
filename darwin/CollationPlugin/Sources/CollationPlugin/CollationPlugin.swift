import Foundation

class CollationPlugin: CollationHostApi {
    func sortStrings(request: CollationRequest) throws -> [String] {
        let entries = request.items.map { item in
            (id: item.id, value: item.value)
        }

        let sorted = entries.sorted { a, b in
            a.value.localizedStandardCompare(b.value) == .orderedAscending
        }

        return sorted.map(\.id)
    }
}
