import Foundation
import XCTest

private final class MemoryHoldStorage: HabitWidgetHoldStorage {
  var data: Data?
  var writes = 0
  var fail = false
  func load() -> Data? { data }
  func save(_ data: Data) throws {
    if fail { throw HabitWidgetHoldError.unavailable }
    writes += 1
    self.data = data
  }
}

final class HabitWidgetHoldTests: XCTestCase {
  private let now = HabitWidgetSnapshot.parseDate("2026-10-17T04:00:00Z")!
  private let identity1 = "ae881fd3-e34c-4340-8df5-a9a4a61d9751"
  private let identity2 = "ae881fd3-e34c-4340-8df5-a9a4a61d9752"
  private let secondID = "ae881fd3-e34c-4340-8df5-a9a4a61d9753"
  private func commit(_ version: String) -> HabitWidgetCommit {
    HabitWidgetCommit(recordVersion: version, committedAt: "2026-10-17T04:00:00Z")!
  }
  private func snapshot(version: String = "v1", change: (inout [String: Any]) -> Void = { _ in }) throws -> HabitWidgetSnapshot {
    let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "snapshot-v2", withExtension: "json"))
    var json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
    var habit = (json["catalog"] as! [[String: Any]])[0]
    habit["completed"] = true; habit["progress"] = 1.0
    habit["canComplete"] = false; habit["canUndo"] = true; habit["expectedRecord"] = version
    json["catalog"] = [habit]; json["activeCount"] = 1; json["completedCount"] = 1
    json["generatedAt"] = "2026-10-17T04:00:01Z"
    change(&json)
    return try JSONDecoder().decode(HabitWidgetSnapshot.self, from: JSONSerialization.data(withJSONObject: json))
  }
  private func event(_ hold: HabitWidgetHold, identity: String? = nil) -> HabitWidgetHoldEvent {
    HabitWidgetHoldEvent(habitID: hold.habitID, day: hold.day, recordVersion: hold.recordVersion, identity: identity ?? hold.identity)
  }

  @MainActor
  func testOnlyAppliedAutomaticCompletionCreatesHoldAndDuplicateCannotRenew() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    XCTAssertNil(try store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: nil, at: now))
    XCTAssertNil(try store.completed(habitID: id, day: snapshot.day, source: .fixed, commit: commit("v1"), at: now))
    XCTAssertEqual(storage.writes, 0)
    let first = try XCTUnwrap(store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now, identity: identity1))
    let repeated = try store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now.addingTimeInterval(60), identity: identity2)
    XCTAssertEqual(repeated, first)
    XCTAssertEqual(storage.writes, 1)
    let restored = HabitWidgetHoldStore(storage: storage)
    XCTAssertEqual(restored.validHolds(snapshot: snapshot, at: now.addingTimeInterval(600))[id], first)
  }

  @MainActor
  func testUndoRedoAndOldIdentityEventsCannotConsumeNewRound() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    let first = try XCTUnwrap(store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now, identity: identity1))
    XCTAssertFalse(try store.undone(habitID: id, day: snapshot.day, previousVersion: "v1", identity: identity2, commit: commit("undo")))
    XCTAssertFalse(try store.undone(habitID: id, day: snapshot.day, previousVersion: "v1", identity: identity1, commit: nil))
    XCTAssertTrue(try store.undone(habitID: id, day: snapshot.day, previousVersion: "v1", identity: identity1, commit: commit("undo")))
    let next = try XCTUnwrap(store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v2"), at: now, identity: identity2))
    let updated = try self.snapshot(version: "v2")
    XCTAssertFalse(try store.advance(event(first), snapshot: updated, at: now))
    XCTAssertFalse(try store.advance(event(next, identity: identity1), snapshot: updated, at: now))
    XCTAssertFalse(try store.undone(habitID: id, day: snapshot.day, previousVersion: "v1", identity: identity1, commit: commit("old-undo")))
    XCTAssertEqual(store.validHolds(snapshot: updated, at: now)[id], next)
    XCTAssertTrue(try store.advance(event(next), snapshot: updated, at: now))
    XCTAssertTrue(store.validHolds(snapshot: updated, at: now).isEmpty)
  }

  @MainActor
  func testMultipleHabitsWidgetsAndFixedRowsShareWithoutShiftingFixedPositions() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot { json in
      var habits = json["catalog"] as! [[String: Any]]
      var second = habits[0]; second["id"] = self.secondID; second["expectedRecord"] = "v2"
      habits.append(second); json["catalog"] = habits
      json["activeCount"] = 2; json["completedCount"] = 2
    }
    let firstID = snapshot.catalog[0].id
    let first = try XCTUnwrap(store.completed(habitID: firstID, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now))
    try store.completed(habitID: secondID, day: snapshot.day, source: .automatic, commit: commit("v2"), at: now)
    let shared = HabitWidgetHoldStore(storage: storage)
    let before = shared.validHolds(snapshot: snapshot, at: now)
    XCTAssertEqual(before.count, 2)
    XCTAssertTrue(try store.advance(event(first), snapshot: snapshot, at: now))
    let after = Set(shared.validHolds(snapshot: snapshot, at: now).keys)
    XCTAssertEqual(after, [secondID])
    let rows = HabitWidgetSlots.resolve(snapshot: snapshot, selections: [firstID, nil, nil], count: 3, at: now, retainedCompletions: after)
    XCTAssertEqual(rows[0].source, .fixed); XCTAssertEqual(rows[0].habit?.id, firstID)
    XCTAssertEqual(rows[1].habit?.id, secondID); XCTAssertEqual(rows[2].empty, .completed)
  }

  @MainActor
  func testForegroundPublicationNeverRenewsAndExternalChangeInvalidatesPermanently() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    let hold = try XCTUnwrap(store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now))
    let bytes = storage.data
    XCTAssertFalse(try store.reconcile(snapshot: snapshot, at: now.addingTimeInterval(10)))
    XCTAssertEqual(bytes, storage.data)
    XCTAssertFalse(try store.reconcile(snapshot: nil, at: now))
    let older = try self.snapshot(version: "older") { $0["generatedAt"] = "2026-10-17T03:00:00Z" }
    XCTAssertFalse(try store.reconcile(snapshot: older, at: now))
    XCTAssertTrue(store.validHolds(snapshot: older, at: now).isEmpty) // mismatched readers fail closed
    XCTAssertEqual(store.validHolds(snapshot: snapshot, at: now)[id], hold)
    XCTAssertTrue(try store.reconcile(snapshot: self.snapshot(version: "external"), at: now))
    XCTAssertTrue(store.validHolds(snapshot: snapshot, at: now).isEmpty) // restoring old values cannot revive it
  }

  @MainActor
  func testOlderPublicationWithinTheSameMillisecondCannotInvalidateNewCommit() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    let committed = try XCTUnwrap(HabitWidgetCommit(recordVersion: "v1", committedAt: "2026-10-17T04:00:00.000900Z"))
    try store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: committed, at: now, identity: identity1)
    let older = try self.snapshot(version: "old") { $0["generatedAt"] = "2026-10-17T04:00:00.000100Z" }
    XCTAssertFalse(try store.reconcile(snapshot: older, at: now))
    XCTAssertEqual(store.validHolds(snapshot: snapshot, at: now)[id]?.identity, identity1)
  }

  @MainActor
  func testAppliedFixedCompletionInvalidatesAnOlderAutomaticVersionWithoutCreatingHold() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    try store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now)
    XCTAssertNil(try store.completed(habitID: id, day: snapshot.day, source: .fixed, commit: commit("v2"), at: now))
    XCTAssertTrue(store.validHolds(snapshot: snapshot, at: now).isEmpty)
    XCTAssertTrue(store.validHolds(snapshot: try self.snapshot(version: "v2"), at: now).isEmpty)
  }

  @MainActor
  func testCurrentCompleteDeletionAndCrossDayInvalidateButLegacyMissingDoesNot() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    let hold = try XCTUnwrap(store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now))
    let empty = try self.snapshot { $0["catalog"] = []; $0["activeCount"] = 0; $0["completedCount"] = 0 }
    let legacyURL = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "snapshot-v1", withExtension: "json"))
    var legacyJSON = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: legacyURL)) as? [String: Any])
    legacyJSON["habits"] = []; legacyJSON["generatedAt"] = "2026-10-17T04:00:01Z"
    let legacy = try JSONDecoder().decode(HabitWidgetSnapshot.self, from: JSONSerialization.data(withJSONObject: legacyJSON))
    XCTAssertFalse(try store.reconcile(snapshot: legacy, at: now))
    XCTAssertTrue(try store.reconcile(snapshot: empty, at: now))
    try store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now)
    XCTAssertFalse(try store.advance(event(hold), snapshot: snapshot, at: now.addingTimeInterval(86400)))
    XCTAssertTrue(try store.reconcile(snapshot: nil, at: now.addingTimeInterval(86400)))
    XCTAssertTrue(store.validHolds(snapshot: snapshot, at: now).isEmpty)
  }

  @MainActor
  func testConcurrentNextConsumesIdentityOnce() async throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    let hold = try XCTUnwrap(store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now))
    let event = self.event(hold); let now = self.now
    let successes = await withTaskGroup(of: Bool.self) { group in
      for _ in 0..<20 { group.addTask { @MainActor in (try? store.advance(event, snapshot: snapshot, at: now)) ?? false } }
      var count = 0
      for await consumed in group where consumed { count += 1 }
      return count
    }
    XCTAssertEqual(successes, 1); XCTAssertEqual(storage.writes, 2)
  }

  @MainActor
  func testTimelineEntryCapturesTheMatchingDisplayStateBeforeArchiving() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    let hold = try XCTUnwrap(store.completed(habitID: id, day: snapshot.day, source: .automatic,
      commit: commit("v1"), at: now))
    let before = HabitWidgetConfiguredEntry(date: now, snapshot: snapshot, selections: [], slotCount: 1,
      holds: store.validHolds(snapshot: snapshot, at: now))
    XCTAssertTrue(try store.advance(event(hold), snapshot: snapshot, at: now))
    let after = HabitWidgetConfiguredEntry(date: now, snapshot: snapshot, selections: [], slotCount: 1,
      holds: store.validHolds(snapshot: snapshot, at: now))
    XCTAssertEqual(before.holds[id], hold)
    XCTAssertEqual(before.slots.first?.habit?.id, id)
    XCTAssertTrue(after.holds.isEmpty)
    XCTAssertEqual(after.slots.first?.empty, .completed)
  }

  @MainActor
  func testCorruptMetadataAndFailedPersistenceNeverProduceAValidHold() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    storage.data = Data("{\"version\":99,\"holds\":[]}".utf8)
    XCTAssertTrue(store.validHolds(snapshot: snapshot, at: now).isEmpty)
    storage.fail = true
    XCTAssertThrowsError(try store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now))
    XCTAssertTrue(HabitWidgetHoldStore(storage: storage).validHolds(snapshot: snapshot, at: now).isEmpty)
    XCTAssertNil(HabitWidgetCommit(recordVersion: "", committedAt: "2026-10-17T04:00:00Z"))
    XCTAssertNil(HabitWidgetCommit(recordVersion: "v1", committedAt: "broken"))
  }

  @MainActor
  func testReadersNeverPersistWhenSnapshotsAreUnavailableStaleOrMismatched() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    try store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now)
    let bytes = storage.data, writes = storage.writes
    XCTAssertTrue(store.validHolds(snapshot: nil, at: now).isEmpty)
    XCTAssertTrue(store.validHolds(snapshot: snapshot, at: now.addingTimeInterval(86400)).isEmpty)
    XCTAssertTrue(store.validHolds(snapshot: try self.snapshot(version: "external"), at: now).isEmpty)
    XCTAssertEqual(storage.data, bytes)
    XCTAssertEqual(storage.writes, writes)
    XCTAssertNotNil(store.validHolds(snapshot: snapshot, at: now)[id])
  }

  @MainActor
  func testFailedAdvancePreservesTheIdentityForRetry() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    let hold = try XCTUnwrap(store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now))
    let bytes = storage.data
    storage.fail = true
    XCTAssertThrowsError(try store.advance(event(hold), snapshot: snapshot, at: now))
    XCTAssertEqual(storage.data, bytes)
    XCTAssertEqual(store.validHolds(snapshot: snapshot, at: now)[id], hold)
    storage.fail = false
    XCTAssertTrue(try store.advance(event(hold), snapshot: snapshot, at: now))
    XCTAssertFalse(try store.advance(event(hold), snapshot: snapshot, at: now))
    XCTAssertEqual(storage.writes, 2)
  }

  @MainActor
  func testFailedUndoPersistenceDoesNotConsumeTheMatchingIdentity() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    let hold = try XCTUnwrap(store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now))
    storage.fail = true
    XCTAssertThrowsError(try store.undone(habitID: id, day: snapshot.day, previousVersion: "v1", identity: hold.identity, commit: commit("undo")))
    XCTAssertEqual(store.validHolds(snapshot: snapshot, at: now)[id], hold)
    storage.fail = false
    XCTAssertTrue(try store.undone(habitID: id, day: snapshot.day, previousVersion: "v1", identity: hold.identity, commit: commit("undo")))
    XCTAssertTrue(store.validHolds(snapshot: snapshot, at: now).isEmpty)
  }

  @MainActor
  func testFailedReconciliationRetainsPersistedStateUntilSuccessfulRetry() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    let hold = try XCTUnwrap(store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now))
    let changed = try self.snapshot(version: "external")
    storage.fail = true
    XCTAssertThrowsError(try store.reconcile(snapshot: changed, at: now))
    XCTAssertEqual(store.validHolds(snapshot: snapshot, at: now)[id], hold)
    storage.fail = false
    XCTAssertTrue(try store.reconcile(snapshot: changed, at: now))
    XCTAssertTrue(store.validHolds(snapshot: snapshot, at: now).isEmpty)
    XCTAssertFalse(try store.reconcile(snapshot: changed, at: now))
    XCTAssertEqual(storage.writes, 2)
  }

  @MainActor
  func testAdvanceRequiresEveryDisplayedIdentityFieldAndCurrentSnapshot() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    let hold = try XCTUnwrap(store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now))
    let wrongDay = HabitWidgetHoldEvent(habitID: id, day: "2026-10-16", recordVersion: "v1", identity: hold.identity)
    let wrongVersion = HabitWidgetHoldEvent(habitID: id, day: snapshot.day, recordVersion: "v2", identity: hold.identity)
    XCTAssertFalse(try store.advance(wrongDay, snapshot: snapshot, at: now))
    XCTAssertFalse(try store.advance(wrongVersion, snapshot: snapshot, at: now))
    XCTAssertFalse(try store.advance(event(hold), snapshot: nil, at: now))
    XCTAssertFalse(try store.advance(event(hold), snapshot: try self.snapshot(version: "external"), at: now))
    XCTAssertFalse(try store.advance(event(hold), snapshot: snapshot, at: now.addingTimeInterval(86400)))
    XCTAssertEqual(storage.writes, 1)
    XCTAssertEqual(store.validHolds(snapshot: snapshot, at: now)[id], hold)
  }

  @MainActor
  func testMalformedPersistedEnvelopeFailsClosedWithoutRewritingStorage() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    try store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now)
    let original = try XCTUnwrap(storage.data)
    let changes: [(inout [String: Any]) -> Void] = [
      { $0["version"] = 2 },
      { json in let holds = json["holds"] as! [[String: Any]]; json["holds"] = holds + holds },
      { json in var holds = json["holds"] as! [[String: Any]]; holds[0]["identity"] = "invalid"; json["holds"] = holds },
      { json in var holds = json["holds"] as! [[String: Any]]; holds[0]["habitID"] = "invalid"; json["holds"] = holds },
      { json in var holds = json["holds"] as! [[String: Any]]; holds[0]["day"] = "2026-02-30"; json["holds"] = holds },
      { json in var holds = json["holds"] as! [[String: Any]]; holds[0]["recordVersion"] = ""; json["holds"] = holds },
    ]
    for change in changes {
      var json = try XCTUnwrap(JSONSerialization.jsonObject(with: original) as? [String: Any])
      change(&json)
      storage.data = try JSONSerialization.data(withJSONObject: json)
      let malformed = storage.data
      XCTAssertTrue(store.validHolds(snapshot: snapshot, at: now).isEmpty)
      XCTAssertEqual(storage.data, malformed)
    }
    XCTAssertEqual(storage.writes, 1)
  }

  @MainActor
  func testCrossDayCommitAndInvalidIdentifiersCannotCreatePresentationState() throws {
    let storage = MemoryHoldStorage(); let store = HabitWidgetHoldStore(storage: storage)
    let snapshot = try snapshot(); let id = snapshot.catalog[0].id
    let previousDayCommit = HabitWidgetCommit(recordVersion: "v1", committedAt: "2026-10-16T04:00:00Z")
    XCTAssertNil(try store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: previousDayCommit, at: now))
    XCTAssertNil(try store.completed(habitID: "invalid", day: snapshot.day, source: .automatic, commit: commit("v1"), at: now))
    XCTAssertNil(try store.completed(habitID: id, day: snapshot.day, source: .automatic, commit: commit("v1"), at: now, identity: "invalid"))
    XCTAssertEqual(storage.writes, 0)
  }
}
