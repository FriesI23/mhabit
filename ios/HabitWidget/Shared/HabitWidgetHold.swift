import Foundation

/// Validates the version and timestamp attached to a committed write result.
struct HabitWidgetCommit {
  let recordVersion: String
  let committedAt: Date

  /// Returns `nil` when either required commit field is absent or invalid.
  init?(recordVersion: String?, committedAt: String?) {
    guard let version = recordVersion, !version.isEmpty,
          let timestamp = committedAt.flatMap(HabitWidgetSnapshot.parseDate) else { return nil }
    self.recordVersion = version
    self.committedAt = timestamp
  }
}

/// Distinguishes a goal completion from an explicitly incomplete normal record.
enum HabitWidgetHoldResult: String, Codable {
  case completed, incomplete
}

/// Persists the identity and record version of a retained presentation.
struct HabitWidgetHold: Codable, Equatable {
  let habitID: String
  let day: String
  let recordVersion: String
  let committedAt: Date
  let identity: String
  let result: HabitWidgetHoldResult

  /// Matches the authoritative result without interpreting native progress.
  func matches(_ habit: HabitWidgetHabit) -> Bool {
    switch result {
    case .completed: return habit.completed
    case .incomplete: return !habit.completed && !habit.automaticPending && habit.recordState == .notAchieved
    }
  }
}

/// Carries the displayed identity used to validate a subsequent UI action.
struct HabitWidgetHoldEvent {
  let habitID: String
  let day: String
  let recordVersion: String
  let identity: String
}

/// Defines the persistence boundary for shared presentation state.
protocol HabitWidgetHoldStorage {
  /// Reads serialized state without changing the underlying storage.
  func load() -> Data?
  /// Replaces serialized state or throws before acknowledging persistence.
  func save(_ data: Data) throws
}

/// Publishes an atomic file that is immediately readable across processes.
struct HabitWidgetFileHoldStorage: HabitWidgetHoldStorage {
  static let filename = "habit_widget_holds.json"
  private let url: URL?

  /// Uses an explicit file URL or resolves the configured app-group container.
  init(url: URL? = nil) {
    self.url = url ?? HabitWidgetShared.appGroup.flatMap {
      FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: $0)
    }?.appendingPathComponent(Self.filename)
  }

  /// Reads the authoritative shared file without changing it.
  func load() -> Data? {
    guard let url else { return nil }
    return try? Data(contentsOf: url)
  }

  /// Completes an atomic, protected write before returning to its caller.
  func save(_ data: Data) throws {
    guard let url else { throw HabitWidgetHoldError.unavailable }
    // Complete the shared write before requesting a timeline. Preference-cache
    // propagation is asynchronous across the app and extension processes.
    try data.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
  }
}

/// Reports failure to resolve or write the shared presentation container.
enum HabitWidgetHoldError: Error { case unavailable }

/// Validates and persists shared presentation state through a single writer.
///
/// Reads are side-effect free. Mutations are serialized by the app runner.
final class HabitWidgetHoldStore {
  /// Versions the serialized envelope independently of the record projection.
  private struct State: Codable {
    enum Version: Int, Codable { case v2 = 2 }

    let version: Version
    let holds: [HabitWidgetHold]
  }
  private let storage: HabitWidgetHoldStorage
  /// Accepts a persistence boundary shared by live readers and isolated tests.
  init(storage: HabitWidgetHoldStorage = HabitWidgetFileHoldStorage()) { self.storage = storage }

  /// Rejects unsupported, duplicate or malformed persisted identities.
  private func load() -> [String: HabitWidgetHold] {
    guard let data = storage.load(), let state = try? JSONDecoder().decode(State.self, from: data),
          Set(state.holds.map(\.habitID)).count == state.holds.count,
          state.holds.allSatisfy({ UUID(uuidString: $0.habitID) != nil
            && UUID(uuidString: $0.identity) != nil && HabitWidgetSnapshot.isDay($0.day)
            && !$0.recordVersion.isEmpty && $0.committedAt.timeIntervalSince1970.isFinite }) else { return [:] }
    return Dictionary(uniqueKeysWithValues: state.holds.map { ($0.habitID, $0) })
  }

  /// Writes a deterministic envelope after all in-memory checks have passed.
  private func save(_ holds: [String: HabitWidgetHold]) throws {
    let state = State(version: .v2, holds: holds.values.sorted { $0.habitID < $1.habitID })
    try storage.save(JSONEncoder().encode(state))
  }

  /// Returns only identities compatible with the supplied snapshot and date.
  func validHolds(snapshot: HabitWidgetSnapshot?, at date: Date) -> [String: HabitWidgetHold] {
    guard let snapshot, snapshot.isCurrent(at: date) else { return [:] }
    return load().filter { id, hold in
      guard hold.day == snapshot.day, let habit = snapshot.catalog.first(where: { $0.id == id }) else { return false }
      return habit.automaticEligible && hold.matches(habit) && habit.canUndo
        && habit.expectedRecord == hold.recordVersion
    }
  }

  /// Records a committed presentation identity without renewing repeated versions.
  @MainActor
  @discardableResult
  func recorded(habitID: String, day: String, source: HabitWidgetSource,
                 commit: HabitWidgetCommit?, at date: Date, identity: String = UUID().uuidString,
                 result: HabitWidgetHoldResult = .completed) throws -> HabitWidgetHold? {
    guard let commit, UUID(uuidString: habitID) != nil,
          UUID(uuidString: identity) != nil, day == HabitWidgetSnapshot.dayString(date),
          day == HabitWidgetSnapshot.dayString(commit.committedAt) else { return nil }
    var holds = load().filter { $0.value.day == day }
    if source == .fixed {
      if let previous = holds[habitID], previous.recordVersion != commit.recordVersion {
        holds.removeValue(forKey: habitID)
        try save(holds)
      }
      return nil
    }
    if let previous = holds[habitID], previous.recordVersion == commit.recordVersion { return previous }
    let hold = HabitWidgetHold(habitID: habitID, day: day, recordVersion: commit.recordVersion,
                              committedAt: commit.committedAt, identity: identity, result: result)
    holds[habitID] = hold
    try save(holds)
    return hold
  }

  /// Removes an identity only after its matching reverse write was committed.
  @MainActor
  @discardableResult
  func undone(habitID: String, day: String, previousVersion: String,
              identity: String?, commit: HabitWidgetCommit?) throws -> Bool {
    guard commit != nil else { return false }
    var holds = load()
    guard let hold = holds[habitID], hold.day == day, hold.recordVersion == previousVersion,
          identity == nil || hold.identity == identity else { return false }
    holds.removeValue(forKey: habitID)
    try save(holds)
    return true
  }

  /// Consumes a matching presentation identity without changing record data.
  @MainActor
  @discardableResult
  func advance(_ event: HabitWidgetHoldEvent, snapshot: HabitWidgetSnapshot?, at date: Date) throws -> Bool {
    guard let hold = validHolds(snapshot: snapshot, at: date)[event.habitID], hold.day == event.day,
          hold.recordVersion == event.recordVersion, hold.identity == event.identity else { return false }
    var holds = load()
    holds.removeValue(forKey: event.habitID)
    try save(holds)
    return true
  }

  /// Removes obsolete state while preserving commits newer than the publication.
  @MainActor
  @discardableResult
  func reconcile(snapshot: HabitWidgetSnapshot?, at date: Date) throws -> Bool {
    let holds = load()
    let day = HabitWidgetSnapshot.dayString(date)
    let retained = holds.filter { id, hold in
      guard hold.day == day else { return false }
      guard let snapshot, snapshot.isCurrent(at: date),
            let generated = HabitWidgetSnapshot.parseDate(snapshot.generatedAt),
            generated >= hold.committedAt else { return true }
      // Only a current, complete directory can establish deletion. An older
      // publication cannot invalidate a commit which happened after its read.
      guard let habit = snapshot.catalog.first(where: { $0.id == id }) else { return false }
      return habit.state == .active && habit.started && !habit.skipped && hold.matches(habit)
        && habit.canUndo && habit.expectedRecord == hold.recordVersion
    }
    guard retained != holds else { return false }
    try save(retained)
    return true
  }
}
