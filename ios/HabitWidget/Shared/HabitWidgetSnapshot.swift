import Foundation

/// The widget reads a projection of app data. Only Dart writes habit records.
struct HabitWidgetSnapshot: Decodable {
  let version: Int
  let generatedAt: String
  let day: String
  let nextDayAt: String
  let habits: [HabitWidgetHabit]
  let strings: [String: String]?

  func text(_ key: String, fallback: String) -> String {
    strings?[key] ?? fallback
  }

  var nextDay: Date? { Self.parseDate(nextDayAt) }

  func isCurrent(at date: Date) -> Bool {
    guard version == 1, let boundary = nextDay else { return false }
    return date < boundary && day == Self.dayString(date)
  }

  static func dayString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = .current
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }

  static func parseDate(_ value: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = formatter.date(from: value) { return date }
    formatter.formatOptions = [.withInternetDateTime]
    return formatter.date(from: value)
  }
}

struct HabitWidgetHabit: Decodable, Identifiable {
  let id: String
  let name: String
  let color: UInt32
  let completed: Bool
  let progress: Double
  let canComplete: Bool
  let canUndo: Bool
  let expectedRecord: String
  let sevenDays: [HabitWidgetDay]

  var boundedProgress: Double {
    progress.isFinite ? min(max(progress, 0), 1) : 0
  }
}

struct HabitWidgetDay: Decodable {
  let date: String
  let progress: Double

  var boundedProgress: Double {
    progress.isFinite ? min(max(progress, 0), 1) : 0
  }
}

enum HabitWidgetShared {
  static let kind = "HabitWidget"
  static let snapshotKey = "habit_widget_snapshot"

  static var appGroup: String? {
    Bundle.main.object(forInfoDictionaryKey: "HabitWidgetAppGroup") as? String
  }

  static func readSnapshot() -> HabitWidgetSnapshot? {
    guard let group = appGroup,
          let json = UserDefaults(suiteName: group)?.string(forKey: snapshotKey),
          let data = json.data(using: .utf8),
          let snapshot = try? JSONDecoder().decode(HabitWidgetSnapshot.self, from: data),
          snapshot.version == 1 else { return nil }
    return snapshot
  }
}
