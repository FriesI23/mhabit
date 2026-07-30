import Foundation

class CollationPlugin: CollationHostApi {
    func sortStrings(request: CollationRequest) throws -> [String] {
        // Note: request.locale is not used here because
        // CFStringTransform(.toLatin) produces a locale-independent Pinyin
        // (zh) / Romaji (ja) / Romaja (ko) form; Latin text is a no-op.
        // localizedStandardCompare handles the final sort using the
        // system locale, which is the correct behavior for a contacts-
        // style collation order.

        let latin: (String) -> String = { value in
            let m = NSMutableString(string: value)
            CFStringTransform(m, nil, kCFStringTransformToLatin, false)
            CFStringTransform(m, nil, kCFStringTransformStripDiacritics, false)
            return m as String
        }

        let entries = request.items.map { item in
            (id: item.id, latin: latin(item.value), original: item.value)
        }

        let sorted = entries.sorted { a, b in
            if a.latin != b.latin {
                return a.latin.localizedStandardCompare(b.latin) == .orderedAscending
            }
            return a.original.localizedStandardCompare(b.original) == .orderedAscending
        }

        return sorted.map(\.id)
    }
}
