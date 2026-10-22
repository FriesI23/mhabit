import Foundation

/// Decodes and validates a versioned, read-only projection of app data.
struct HabitWidgetSnapshot: Decodable {
  let version: Int
  let generatedAt: String
  let day: String
  let nextDayAt: String
  let catalog: [HabitWidgetHabit]
  let activeCount: Int
  let completedCount: Int
  let hasCompleteCatalog: Bool
  let strings: [String: String]?

  private enum CodingKeys: String, CodingKey {
    case version, generatedAt, day, nextDayAt, habits, catalog, activeCount, completedCount, strings
  }

  /// Normalizes supported formats while retaining their directory completeness.
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    version = try values.decode(Int.self, forKey: .version)
    guard version == 1 || version == 2 else {
      throw DecodingError.dataCorruptedError(forKey: .version, in: values, debugDescription: "Unsupported widget snapshot version")
    }
    generatedAt = try values.decode(String.self, forKey: .generatedAt)
    day = try values.decode(String.self, forKey: .day)
    nextDayAt = try values.decode(String.self, forKey: .nextDayAt)
    guard Self.isDay(day), let generated = Self.parseDate(generatedAt),
          let boundary = Self.parseDate(nextDayAt), boundary > generated else {
      throw DecodingError.dataCorruptedError(forKey: .day, in: values, debugDescription: "Invalid widget civil-day bounds")
    }
    strings = try values.decodeIfPresent([String: String].self, forKey: .strings)
    if version == 1 {
      catalog = try values.decode([HabitWidgetHabit].self, forKey: .habits)
      activeCount = catalog.count
      completedCount = catalog.filter(\.completed).count
      hasCompleteCatalog = false
    } else {
      catalog = try values.decode([HabitWidgetHabit].self, forKey: .catalog)
      activeCount = try values.decode(Int.self, forKey: .activeCount)
      completedCount = try values.decode(Int.self, forKey: .completedCount)
      let active = catalog.filter { $0.state == .active && $0.started }
      guard catalog.allSatisfy(\.hasCatalogMetadata),
            Set(catalog.map(\.id)).count == catalog.count,
            activeCount == active.count,
            completedCount == active.filter(\.completed).count else {
        throw DecodingError.dataCorruptedError(forKey: .catalog, in: values, debugDescription: "Incomplete or inconsistent widget directory")
      }
      hasCompleteCatalog = true
    }
  }

  /// Returns a translated snapshot label or the caller's fallback.
  func text(_ key: String, fallback: String) -> String {
    strings?[key] ?? fallback
  }

  var nextDay: Date? { Self.parseDate(nextDayAt) }

  /// Checks both the local civil date and the serialized expiration boundary.
  func isCurrent(at date: Date) -> Bool {
    guard let boundary = nextDay else { return false }
    return date < boundary && day == Self.dayString(date)
  }

  /// Formats a local civil date without locale-dependent digits or calendars.
  static func dayString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = .current
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }

  /// Validates the exact Gregorian `yyyy-MM-dd` wire format.
  static func isDay(_ value: String) -> Bool {
    let parser = DateFormatter()
    parser.calendar = Calendar(identifier: .gregorian)
    parser.locale = Locale(identifier: "en_US_POSIX")
    parser.timeZone = TimeZone(secondsFromGMT: 0)
    parser.dateFormat = "yyyy-MM-dd"
    parser.isLenient = false
    guard value.count == 10, let date = parser.date(from: value) else { return false }
    return parser.string(from: date) == value
  }

  /// Parses wire timestamps while preserving fractional-second ordering.
  static func parseDate(_ value: String) -> Date? {
    // Preserve Dart's microseconds: millisecond truncation can make an older
    // foreground publication appear simultaneous with a later record commit.
    if let date = try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(value) { return date }
    return try? Date.ISO8601FormatStyle().parse(value)
  }
}

/// Represents the lifecycle states understood by the native snapshot reader.
enum HabitWidgetHabitState: String, Decodable {
  case active, archived, unknown
}

/// Supplies validated identity, presentation data and action capabilities.
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
  let state: HabitWidgetHabitState
  let startDate: String?
  let started: Bool
  let skipped: Bool
  let automaticEligible: Bool
  let hasCatalogMetadata: Bool

  private enum CodingKeys: String, CodingKey {
    case id, name, color, completed, progress, canComplete, canUndo, expectedRecord, sevenDays
    case state, startDate, started, skipped, automaticEligible
  }

  /// Decodes legacy defaults and rejects inconsistent capability metadata.
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(String.self, forKey: .id)
    name = try values.decode(String.self, forKey: .name)
    color = try values.decode(UInt32.self, forKey: .color)
    completed = try values.decode(Bool.self, forKey: .completed)
    progress = try values.decode(Double.self, forKey: .progress)
    canComplete = try values.decode(Bool.self, forKey: .canComplete)
    canUndo = try values.decode(Bool.self, forKey: .canUndo)
    expectedRecord = try values.decode(String.self, forKey: .expectedRecord)
    sevenDays = try values.decode([HabitWidgetDay].self, forKey: .sevenDays)
    let decodedState = try values.decodeIfPresent(HabitWidgetHabitState.self, forKey: .state)
    let decodedStarted = try values.decodeIfPresent(Bool.self, forKey: .started)
    let decodedSkipped = try values.decodeIfPresent(Bool.self, forKey: .skipped)
    let decodedEligibility = try values.decodeIfPresent(Bool.self, forKey: .automaticEligible)
    startDate = try values.decodeIfPresent(String.self, forKey: .startDate)
    state = decodedState ?? .active
    started = decodedStarted ?? true
    skipped = decodedSkipped ?? false
    // V1 does not expose status or skip metadata. Its existing capability flags
    // are the only safe fallback; absence from that catalog never means deleted.
    automaticEligible = decodedEligibility ?? canComplete
    hasCatalogMetadata = decodedState != nil && decodedStarted != nil
      && decodedSkipped != nil && decodedEligibility != nil && startDate != nil
    if id.isEmpty || expectedRecord.isEmpty || !progress.isFinite
        || (startDate != nil && !HabitWidgetSnapshot.isDay(startDate!))
        || sevenDays.count != 7 || sevenDays.contains(where: { !$0.progress.isFinite })
        || (automaticEligible && (state != .active || !started || skipped))
        || ((!started || state == .unknown || skipped) && (canComplete || canUndo)) {
      throw DecodingError.dataCorruptedError(forKey: .id, in: values, debugDescription: "Invalid widget habit projection")
    }
  }

  /// Restricts progress to the range accepted by native visual controls.
  var boundedProgress: Double {
    progress.isFinite ? min(max(progress, 0), 1) : 0
  }
}

/// Supplies one historical progress value for the compact calendar view.
struct HabitWidgetDay: Decodable {
  let date: String
  let progress: Double

  /// Restricts progress to the range accepted by native visual controls.
  var boundedProgress: Double {
    progress.isFinite ? min(max(progress, 0), 1) : 0
  }
}

/// Defines shared identifiers and the app-group snapshot read boundary.
enum HabitWidgetShared {
  static let kind = "HabitWidget"
  static let snapshotKey = "habit_widget_snapshot"
  static let automaticSelectionID = "auto"

  static var appGroup: String? {
    Bundle.main.object(forInfoDictionaryKey: "HabitWidgetAppGroup") as? String
  }

  /// Returns a validated snapshot, failing closed for missing or malformed data.
  static func readSnapshot() -> HabitWidgetSnapshot? {
    guard let group = appGroup,
          let json = UserDefaults(suiteName: group)?.string(forKey: snapshotKey),
          let data = json.data(using: .utf8),
          let snapshot = try? JSONDecoder().decode(HabitWidgetSnapshot.self, from: data) else { return nil }
    return snapshot
  }
}

extension HabitWidgetSnapshot {
  /// Selects the app-provided locale with a system-locale fallback.
  var widgetLocale: Locale {
    strings?["locale"].map { Locale(identifier: $0) } ?? .current
  }

  /// Resolves a native resource using the app's language preference.
  func nativeText(_ key: String) -> String {
    let preferences = [widgetLocale.identifier.replacingOccurrences(of: "_", with: "-"), "en"]
    let language = Bundle.preferredLocalizations(
      from: Bundle.main.localizations, forPreferences: preferences).first ?? "en"
    let path = Bundle.main.path(forResource: language, ofType: "lproj")
      ?? Bundle.main.path(forResource: "en", ofType: "lproj")
    let bundle = path.flatMap(Bundle.init(path:)) ?? .main
    return bundle.localizedString(forKey: key, value: key, table: nil)
  }
}
