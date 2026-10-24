import Foundation

/// Decodes and validates a versioned, read-only projection of app data.
struct HabitWidgetSnapshot: Decodable {
  /// Lists the wire formats this reader understands; unknown values fail decoding.
  enum Version: Int, Decodable { case v2 = 2 }

  let version: Version
  let generatedAt: String
  let day: String
  let nextDayAt: String
  let catalog: [HabitWidgetHabit]
  let activeCount: Int
  let completedCount: Int
  let locale: String?

  private enum CodingKeys: String, CodingKey {
    case version, generatedAt, day, nextDayAt, catalog, activeCount, completedCount, locale
  }

  /// Requires the current complete catalog and validates its summary counters.
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    version = try values.decode(Version.self, forKey: .version)
    generatedAt = try values.decode(String.self, forKey: .generatedAt)
    day = try values.decode(String.self, forKey: .day)
    nextDayAt = try values.decode(String.self, forKey: .nextDayAt)
    guard Self.isDay(day), let generated = Self.parseDate(generatedAt),
      let boundary = Self.parseDate(nextDayAt), boundary > generated
    else {
      throw DecodingError.dataCorruptedError(
        forKey: .day,
        in: values,
        debugDescription: "Invalid widget civil-day bounds",
      )
    }
    locale = try values.decodeIfPresent(String.self, forKey: .locale)
    catalog = try values.decode([HabitWidgetHabit].self, forKey: .catalog)
    activeCount = try values.decode(Int.self, forKey: .activeCount)
    completedCount = try values.decode(Int.self, forKey: .completedCount)
    let active = catalog.filter { $0.state == .active && $0.started }
    guard Set(catalog.map(\.id)).count == catalog.count, activeCount == active.count,
      completedCount == active.filter(\.completed).count
    else {
      throw DecodingError.dataCorruptedError(
        forKey: .catalog,
        in: values,
        debugDescription: "Inconsistent widget directory",
      )
    }
  }

  /// Resolves native text in the language captured by this projection.
  func text(_ key: HabitWidgetText, bundle: Bundle = .main) -> String {
    key.localized(locale: locale.map { Locale(identifier: $0) }, bundle: bundle)
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
    if #available(iOS 18.0, *) {
      if let date = try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(value) {
        return date
      }
      return try? Date.ISO8601FormatStyle().parse(value)
    }
    return parseDateFallback(value)
  }

  private static func parseDateFallback(_ value: String) -> Date? {
    // iOS 17 compatibility fix: Foundation loses submillisecond ISO-8601
    // precision (reproduced on iOS 17.5), so an older snapshot can incorrectly
    // clear a newer display hold. Parse whole seconds and the fraction separately.
    guard let decimal = value.firstIndex(of: ".") else {
      return try? Date.ISO8601FormatStyle().parse(value)
    }
    let start = value.index(after: decimal)
    let end = value[start...].firstIndex { !$0.isASCII || !$0.isNumber } ?? value.endIndex
    guard start != end, let fraction = Double("0." + value[start..<end]),
      let date = try? Date.ISO8601FormatStyle().parse(String(value[..<decimal]) + value[end...])
    else { return nil }
    return date.addingTimeInterval(fraction)
  }
}

/// Represents the lifecycle states understood by the native snapshot reader.
enum HabitWidgetHabitState: String, Decodable { case active, archived, unknown }

/// Carries Dart's record-presence and goal result without recomputing targets.
enum HabitWidgetRecordState: String, Decodable {
  case unknown, unrecorded, notAchieved, achieved, skipped
}

/// Supplies validated identity, presentation data and action capabilities.
struct HabitWidgetHabit: Decodable, Identifiable {
  let id: String
  let name: String
  let color: UInt32
  let completed: Bool
  let recordState: HabitWidgetRecordState
  let progress: Double
  let canComplete: Bool
  let canMarkIncomplete: Bool
  let canUndo: Bool
  let expectedRecord: String
  let sevenDays: [HabitWidgetDay]
  let state: HabitWidgetHabitState
  let startDate: String
  let started: Bool
  let skipped: Bool
  let automaticEligible: Bool
  let automaticPending: Bool

  private enum CodingKeys: String, CodingKey {
    case id, name, color, completed, recordState, progress, canComplete, canUndo, expectedRecord,
      sevenDays
    case state, startDate, started, skipped, automaticEligible, automaticPending, canMarkIncomplete
  }

  /// Requires current projection fields and rejects inconsistent capabilities.
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(String.self, forKey: .id)
    name = try values.decode(String.self, forKey: .name)
    color = try values.decode(UInt32.self, forKey: .color)
    completed = try values.decode(Bool.self, forKey: .completed)
    recordState = try values.decode(HabitWidgetRecordState.self, forKey: .recordState)
    progress = try values.decode(Double.self, forKey: .progress)
    canComplete = try values.decode(Bool.self, forKey: .canComplete)
    canMarkIncomplete = try values.decode(Bool.self, forKey: .canMarkIncomplete)
    automaticPending = try values.decode(Bool.self, forKey: .automaticPending)
    canUndo = try values.decode(Bool.self, forKey: .canUndo)
    expectedRecord = try values.decode(String.self, forKey: .expectedRecord)
    sevenDays = try values.decode([HabitWidgetDay].self, forKey: .sevenDays)
    state = try values.decode(HabitWidgetHabitState.self, forKey: .state)
    started = try values.decode(Bool.self, forKey: .started)
    skipped = try values.decode(Bool.self, forKey: .skipped)
    automaticEligible = try values.decode(Bool.self, forKey: .automaticEligible)
    startDate = try values.decode(String.self, forKey: .startDate)
    if id.isEmpty || expectedRecord.isEmpty || !progress.isFinite
      || !HabitWidgetSnapshot.isDay(startDate) || sevenDays.count != 7
      || sevenDays.contains(where: { !$0.progress.isFinite })
      || (automaticEligible && (state != .active || !started || skipped))
      || (canMarkIncomplete && (!canComplete || completed || !automaticPending))
      || ((!started || state == .unknown || skipped)
        && (canComplete || canUndo || canMarkIncomplete))
    {
      throw DecodingError.dataCorruptedError(
        forKey: .id,
        in: values,
        debugDescription: "Invalid widget habit projection",
      )
    }
  }

  /// Restricts progress to the range accepted by native visual controls.
  var boundedProgress: Double { progress.isFinite ? min(max(progress, 0), 1) : 0 }

  /// Exposes an explicit record label only when the new projection is known.
  func recordStatusText(_ snapshot: HabitWidgetSnapshot, bundle: Bundle = .main) -> String? {
    guard started, state != .unknown else { return nil }
    switch recordState {
    case .unknown: return nil
    case .unrecorded: return snapshot.text(.unrecorded, bundle: bundle)
    case .notAchieved:
      return snapshot.text(automaticPending ? .notAchieved : .incomplete, bundle: bundle)
    case .achieved: return snapshot.text(.achieved, bundle: bundle)
    case .skipped: return snapshot.text(.skipped, bundle: bundle)
    }
  }
}

/// Supplies one historical progress value for the compact calendar view.
struct HabitWidgetDay: Decodable {
  let date: String
  let progress: Double

  /// Restricts progress to the range accepted by native visual controls.
  var boundedProgress: Double { progress.isFinite ? min(max(progress, 0), 1) : 0 }
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
      let snapshot = try? JSONDecoder().decode(HabitWidgetSnapshot.self, from: data)
    else { return nil }
    return snapshot
  }
}

extension HabitWidgetSnapshot {
  /// Selects the app-provided locale with a system-locale fallback.
  var widgetLocale: Locale { locale.map { Locale(identifier: $0) } ?? .current }
}

/// Names shared runtime labels independently of static native metadata.
enum HabitWidgetText: String, CaseIterable {
  case today = "HomeWidgetToday"
  case complete = "HomeWidgetComplete"
  case undo = "HomeWidgetUndo"
  case allDone = "HomeWidgetAllDone"
  case completed = "HomeWidgetCompleted"
  case incomplete = "HomeWidgetIncomplete"
  case unrecorded = "HomeWidgetUnrecorded"
  case notAchieved = "HomeWidgetNotAchieved"
  case achieved = "HomeWidgetAchieved"
  case skipped = "HomeWidgetSkipped"
  case next = "HomeWidgetNext"
  case newDay = "HomeWidgetNewDay"
  case refresh = "HomeWidgetRefresh"
  case loading = "HomeWidgetLoading"
  case refreshHint = "HomeWidgetRefreshHint"
  case openApp = "HomeWidgetOpenApp"
  case galleryDescription = "HomeWidgetGalleryDescription"
  case notStarted = "HomeWidgetNotStarted"
  case noPending = "HomeWidgetNoPending"
  case noHabits = "HomeWidgetNoHabits"
  case automatic = "HomeWidgetAutomatic"
  case unavailable = "HomeWidgetUnavailable"
  case nextHint = "HomeWidgetNextHint"
  case errorInvalidAction = "HomeWidgetErrorInvalidAction"
  case errorUnavailable = "HomeWidgetErrorUnavailable"
  case errorTimedOut = "HomeWidgetErrorTimedOut"
  case errorFailed = "HomeWidgetErrorFailed"

  var key: String { rawValue }

  /// Selects a widget table, falling back through English resources to code.
  func localized(locale: Locale? = nil, bundle: Bundle = .main) -> String {
    var languages = bundle.localizations
      .filter {
        FileManager.default.fileExists(
          atPath: bundle.bundleURL.appendingPathComponent("\($0).lproj/Localizable.strings").path
        )
      }
      .sorted { left, right in
        if left == "en" { return right != "en" }
        if right == "en" { return false }
        return left < right
      }
    // Keep English as the matching fallback even when its table is missing.
    if !languages.contains("en") { languages.insert("en", at: 0) }
    let preferences = locale.map { locale -> [String] in
      let identifier = locale.identifier.replacingOccurrences(of: "_", with: "-")
      return [identifier == "zh" ? "zh-Hans" : identifier, "en"]
    }
    let english =
      Bundle(url: bundle.bundleURL.appendingPathComponent("en.lproj"))?
      .localizedString(
        forKey: key,
        value: englishDefault,
        table: nil,
      ) ?? englishDefault
    guard
      let language = Bundle.preferredLocalizations(from: languages, forPreferences: preferences)
        .first,
      let localized = Bundle(url: bundle.bundleURL.appendingPathComponent("\(language).lproj"))
    else { return english }
    return localized.localizedString(forKey: key, value: english, table: nil)
  }

  /// Supplies the last-resort text when a native translation is unavailable.
  var englishDefault: String {
    switch self {
    case .today: return "Today"
    case .complete: return "Done"
    case .undo: return "UNDO"
    case .allDone: return "YOU MADE IT"
    case .completed: return "Completed"
    case .incomplete: return "Missed"
    case .unrecorded: return "Not recorded"
    case .notAchieved: return "Not achieved"
    case .achieved: return "Achieved"
    case .skipped: return "Skip"
    case .next: return "Next"
    case .newDay: return "New day"
    case .refresh: return "Refresh"
    case .loading: return "Loading…"
    case .refreshHint: return "Refresh to see today's progress"
    case .openApp: return "Open Table Habit to get started"
    case .galleryDescription: return "Your habits today, one small step at a time."
    case .notStarted: return "Not started"
    case .noPending: return "No pending habits"
    case .noHabits: return "No available habits"
    case .automatic: return "Automatic"
    case .unavailable: return "Unavailable habit"
    case .nextHint: return "Show the next habit without changing records"
    case .errorInvalidAction: return "This habit action is no longer available."
    case .errorUnavailable: return "Open Table Habit once before using widget actions."
    case .errorTimedOut: return "The habit could not be updated in time. Please try again."
    case .errorFailed: return "The habit could not be updated. Refresh the widget and try again."
    }
  }
}
