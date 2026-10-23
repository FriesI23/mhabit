import AppIntents
import Foundation
import XCTest

final class HabitWidgetSlotsTests: XCTestCase {
  private let now = HabitWidgetSnapshot.parseDate("2026-10-17T08:00:00Z")!
  private let missing = "d299490c-3341-48a5-96ae-972425626d13"
  private func snapshot(version: Int = 2, change: (inout [String: Any]) -> Void = { _ in }) throws -> HabitWidgetSnapshot {
    let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "snapshot-v\(version)", withExtension: "json"))
    var json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
    change(&json)
    return try JSONDecoder().decode(HabitWidgetSnapshot.self, from: JSONSerialization.data(withJSONObject: json))
  }
  private func many(count: Int = 5, completed: Bool = false, skipped: Bool = false) throws -> HabitWidgetSnapshot {
    try snapshot { json in
      let first = (json["catalog"] as! [[String: Any]])[0]
      json["catalog"] = (0..<count).map { index -> [String: Any] in
        var habit = first
        habit["id"] = "b299490c-3341-48a5-96ae-972425626d1\(index)"
        habit["name"] = "Same name"
        habit["completed"] = completed
        habit["canComplete"] = !completed && !skipped
        habit["canUndo"] = completed && !skipped
        habit["skipped"] = skipped
        habit["automaticEligible"] = !skipped
        return habit
      }
      json["activeCount"] = count
      json["completedCount"] = completed ? count : 0
    }
  }
  private func rows(_ snapshot: HabitWidgetSnapshot?, _ ids: [String?] = [], count: Int = 3) -> [HabitWidgetSlot] {
    HabitWidgetSlots.resolve(snapshot: snapshot, selections: ids, count: count, at: now)
  }

  func testAutomaticMixedAndFixedSlotsUseStableOrderWithoutDuplicates() throws {
    let s = try many()
    let ids = s.catalog.map(\.id)
    XCTAssertEqual(rows(s).compactMap { $0.habit?.id }, Array(ids.prefix(3)))
    XCTAssertEqual(rows(s, [nil, ids[0]]).compactMap { $0.habit?.id }, [ids[0], ids[1], ids[2]])
    XCTAssertEqual(rows(s, [ids[3], nil, ids[0]]).compactMap { $0.habit?.id }, [ids[3], ids[0], ids[1]])
    XCTAssertEqual(rows(s, [ids[2], ids[0], ids[4]]).compactMap { $0.habit?.id }, [ids[2], ids[0], ids[4]])
    let duplicate = rows(s, [ids[0], ids[0], ids[0]])
    XCTAssertEqual(duplicate.compactMap { $0.habit?.id }, Array(ids.prefix(3)))
    XCTAssertEqual(duplicate.map(\.source), [.fixed, .automatic, .automatic])
  }

  func testSmallIgnoresHiddenReservationsAndMediumRestoresThem() throws {
    let s = try many()
    let ids = s.catalog.map(\.id)
    let config: [String?] = [nil, ids[0], ids[1]]
    XCTAssertEqual(rows(s, config, count: 1).first?.habit?.id, ids[0])
    XCTAssertEqual(rows(s, config).compactMap { $0.habit?.id }, [ids[0], ids[1], ids[2]])
  }

  func testArchivedFutureAndUnknownFixedRowsStayAheadOfAutomaticRowsAndEmptyCapacity() throws {
    let s = try snapshot()
    let ids = s.catalog.map(\.id)
    XCTAssertEqual(rows(s, [ids[1], ids[2], ids[3]]).compactMap { $0.habit?.id }, Array(ids.suffix(3)))
    let exhausted = rows(s, [nil, nil, ids[1]])
    XCTAssertEqual(exhausted[0].habit?.id, ids[1])
    XCTAssertFalse(exhausted[0].habit!.automaticEligible)
    XCTAssertEqual(exhausted[1].habit?.id, ids[0])
    XCTAssertEqual(exhausted[2].empty, .noPending)
  }

  func testOnlyCurrentCompleteDirectoryCanConfirmMissingFixedIdentity() throws {
    XCTAssertEqual(rows(try snapshot(), [missing])[0].source, .automatic)
    XCTAssertNotNil(rows(try snapshot(), [missing])[0].habit)
    XCTAssertEqual(rows(try snapshot(version: 1), [missing])[0].empty, .loading)
    XCTAssertNil(rows(try snapshot(version: 1), [missing])[0].habit)
    XCTAssertEqual(rows(nil, [missing])[0].empty, .loading)
    let stale = HabitWidgetSlots.resolve(snapshot: try snapshot(), selections: [missing], count: 1,
      at: now.addingTimeInterval(86400))
    XCTAssertEqual(stale[0].empty, .refresh)
  }

  func testThreeEmptyStatesUseGlobalCounts() throws {
    XCTAssertEqual(rows(try many(completed: true))[0].empty, .completed)
    XCTAssertEqual(rows(try many(skipped: true))[0].empty, .noPending)
    let empty = try snapshot { $0["catalog"] = []; $0["activeCount"] = 0; $0["completedCount"] = 0 }
    XCTAssertEqual(rows(empty)[0].empty, .noHabits)
  }

  func testIdentityLookupIsIndependentOfSuggestionsAndNamesAreSearchable() throws {
    let s = try many()
    let ids = s.catalog.map(\.id)
    let excluded = Set([ids[0], ids[1]])
    let choices = HabitWidgetChoices.suggestions(snapshot: s, excluding: excluded, keeping: ids[0], search: "same NAME")
    XCTAssertEqual(choices.map(\.id), [ids[0]] + Array(ids.suffix(3)))
    XCTAssertEqual(HabitWidgetChoices.identities([ids[1], missing, "auto", "bad"], snapshot: s).map(\.id), [ids[1], missing, "auto"])
    let all = HabitWidgetChoices.suggestions(snapshot: try snapshot(), excluding: [], keeping: nil)
    XCTAssertEqual(all.count, 5) // automatic plus archived/future/unknown directory entries
    let configuration = HabitWidgetConfiguration()
    XCTAssertEqual(configuration.selections, Array(repeating: "auto", count: 6))
  }

  func testDynamicPickerNamesUseCapturedLocaleAndIgnoreLegacyText() throws {
    let s = try snapshot {
      $0["locale"] = "ar"
      $0["strings"] = ["locale": "ru", "automatic": "Legacy automatic", "unavailable": "Legacy unavailable"]
    }
    let automatic = HabitWidgetText.automatic.localized(locale: s.widgetLocale)
    let unavailable = HabitWidgetText.unavailable.localized(locale: s.widgetLocale)
    let choices = HabitWidgetChoices.suggestions(snapshot: s, excluding: [], keeping: nil)
    XCTAssertEqual(choices.first?.id, "auto")
    XCTAssertEqual(choices.first?.name, automatic)
    XCTAssertEqual(HabitWidgetChoices.suggestions(snapshot: s, excluding: [], keeping: nil,
      search: automatic).map(\.id), ["auto"])
    XCTAssertEqual(HabitWidgetChoices.identities([missing, "auto"], snapshot: s).map(\.name),
      [unavailable, automatic])
    XCTAssertEqual(HabitWidgetChoices.identities([missing, "auto"], snapshot: nil).map(\.name),
      [HabitWidgetText.unavailable.localized(), HabitWidgetText.automatic.localized()])
  }

  func testIntentQueryWitnessesPreserveDefaultsIdentitySuggestionsAndSearch() async throws {
    try await assertQueryBehavior(HabitWidgetChoiceQuery())
    try await assertQueryBehavior(HabitWidgetSlot2Query())
    try await assertQueryBehavior(HabitWidgetSlot3Query())
    try await assertQueryBehavior(HabitWidgetSlot4Query())
    try await assertQueryBehavior(HabitWidgetSlot5Query())
    try await assertQueryBehavior(HabitWidgetSlot6Query())
  }

  /// Calls through App Intents' protocol requirements to catch lost witnesses.
  private func assertQueryBehavior<Query: EntityStringQuery>(_ query: Query,
    file: StaticString = #filePath, line: UInt = #line) async throws
    where Query.Entity == HabitWidgetChoice, Query.Result == [HabitWidgetChoice],
      Query.DefaultValue == HabitWidgetChoice {
    let result = await query.defaultResult()
    let automatic = try XCTUnwrap(result, file: file, line: line)
    XCTAssertEqual(automatic.id, "auto", file: file, line: line)
    let identities = try await query.entities(for: [missing, "auto", "bad"])
    XCTAssertEqual(identities.map(\.id), [missing, "auto"], file: file, line: line)
    let suggestions = try await query.suggestedEntities()
    XCTAssertEqual(suggestions.first?.id, "auto", file: file, line: line)
    let search = try await query.entities(matching: automatic.name.uppercased())
    XCTAssertTrue(search.contains { $0.id == "auto" }, file: file, line: line)
    let absent = try await query.entities(matching: UUID().uuidString)
    XCTAssertTrue(absent.isEmpty, file: file, line: line)
  }

  func testSequentialPickerExclusionsPreserveSearchAndAutomaticChoice() throws {
    let s = try many()
    let ids = s.catalog.map(\.id)
    let first = HabitWidgetChoices.suggestions(snapshot: s, excluding: [], keeping: nil, search: "same")
    let second = HabitWidgetChoices.suggestions(snapshot: s, excluding: [ids[0]], keeping: nil, search: "same")
    let third = HabitWidgetChoices.suggestions(snapshot: s, excluding: [ids[0], ids[1]], keeping: nil, search: "same")
    XCTAssertEqual(first.map(\.id), ids)
    XCTAssertEqual(second.map(\.id), Array(ids.dropFirst()))
    XCTAssertEqual(third.map(\.id), Array(ids.dropFirst(2)))
    let automaticExcluded = HabitWidgetChoices.suggestions(snapshot: s, excluding: ["auto"], keeping: nil)
    XCTAssertEqual(automaticExcluded.first?.id, "auto")
    // Filtering recommendations never changes saved identity resolution.
    XCTAssertEqual(HabitWidgetChoices.identities([ids[0], ids[1]], snapshot: s).map(\.id), Array(ids.prefix(2)))
  }

  func testSearchIncludesReadOnlyAndArchivedDirectoryEntries() throws {
    let s = try snapshot()
    for name in ["archived", "future", "unknown"] {
      let result = HabitWidgetChoices.suggestions(snapshot: s, excluding: [], keeping: nil, search: name.uppercased())
      XCTAssertEqual(result.map(\.name), [name])
    }
    XCTAssertTrue(HabitWidgetChoices.suggestions(snapshot: s, excluding: [], keeping: nil, search: "absent name").isEmpty)
    XCTAssertEqual(HabitWidgetChoices.identities([missing], snapshot: nil).map(\.id), [missing])
    XCTAssertEqual(HabitWidgetChoices.identities([missing], snapshot: s).map(\.id), [missing])
  }

  func testRetainedCompletionDoesNotDuplicateAnExplicitReservation() throws {
    let s = try many(completed: true)
    let ids = s.catalog.map(\.id)
    let resolved = HabitWidgetSlots.resolve(snapshot: s, selections: [nil, ids[0], nil], count: 3,
      at: now, retainedCompletions: [ids[0], ids[1]])
    XCTAssertEqual(resolved[0].habit?.id, ids[0])
    XCTAssertEqual(resolved[0].source, .fixed)
    XCTAssertEqual(resolved[1].habit?.id, ids[1])
    XCTAssertEqual(resolved[2].empty, .completed)
  }

  func testLargePacksSecondAndFourthFixedChoicesInConfigurationOrder() throws {
    let s = try many(count: 8)
    let ids = s.catalog.map(\.id)
    let resolved = rows(s, [nil, ids[5], nil, ids[2], nil, nil], count: 6)
    XCTAssertEqual(resolved.compactMap { $0.habit?.id }, [ids[5], ids[2], ids[0], ids[1], ids[3], ids[4]])
    XCTAssertEqual(resolved.map(\.source), [.fixed, .fixed, .automatic, .automatic, .automatic, .automatic])
    XCTAssertEqual(rows(s, Array(ids.prefix(6)).map { $0 }, count: 6).compactMap { $0.habit?.id }, Array(ids.prefix(6)))
    XCTAssertEqual(rows(s, count: 6).compactMap { $0.habit?.id }, Array(ids.prefix(6)))
  }

  func testFamilyCapacityIgnoresHiddenChoicesAndRestoresLargeSelections() throws {
    let s = try many(count: 8)
    let ids = s.catalog.map(\.id)
    let config: [String?] = [nil, ids[4], nil, ids[0], nil, ids[2]]
    XCTAssertEqual(rows(s, config, count: 1).compactMap { $0.habit?.id }, [ids[0]])
    XCTAssertEqual(rows(s, config, count: 3).compactMap { $0.habit?.id }, [ids[4], ids[0], ids[1]])
    XCTAssertEqual(rows(s, config, count: 6).compactMap { $0.habit?.id }, [ids[4], ids[0], ids[2], ids[1], ids[3], ids[5]])
  }

  func testDuplicateAndDeletedLargeChoicesFallBackWithoutLeavingGaps() throws {
    let s = try many(count: 8)
    let ids = s.catalog.map(\.id)
    let resolved = rows(s, [nil, ids[3], ids[3], missing, nil, ids[1]], count: 6)
    XCTAssertEqual(resolved.compactMap { $0.habit?.id }, [ids[3], ids[1], ids[0], ids[2], ids[4], ids[5]])
    XCTAssertEqual(resolved.filter { $0.source == .fixed }.count, 2)
    let incomplete = rows(try snapshot(version: 1), [nil, missing, nil], count: 3)
    XCTAssertEqual(incomplete[0].source, .fixed)
    XCTAssertEqual(incomplete[0].empty, .loading)
  }

  func testShortListKeepsAllEmptyCapacityAfterHabits() throws {
    let s = try many(count: 2)
    let ids = s.catalog.map(\.id)
    let resolved = rows(s, [nil, nil, nil, ids[1], nil, nil], count: 6)
    XCTAssertEqual(resolved.prefix(2).compactMap { $0.habit?.id }, [ids[1], ids[0]])
    XCTAssertTrue(resolved.suffix(4).allSatisfy { $0.habit == nil && $0.source == .automatic })
  }

  func testAllFamiliesRetainLastCompletionUntilNextAndKeepFixedCompletion() throws {
    let s = try many(count: 1, completed: true)
    let id = s.catalog[0].id
    for count in [1, 3, 6] {
      let retained = HabitWidgetSlots.resolve(snapshot: s, selections: [], count: count, at: now,
        retainedCompletions: [id])
      XCTAssertEqual(retained[0].habit?.id, id)
      XCTAssertEqual(retained[0].source, .automatic)
      XCTAssertTrue(rows(s, count: count).allSatisfy { $0.habit == nil && $0.empty == .completed })
      let fixed = rows(s, [id], count: count)
      XCTAssertEqual(fixed[0].source, .fixed)
      XCTAssertTrue(try XCTUnwrap(fixed[0].habit).canUndo)
    }
  }

  func testLargePickerSearchExcludesEarlierChoicesAndAlwaysKeepsAutomatic() throws {
    let s = try many(count: 8)
    let ids = s.catalog.map(\.id)
    for earlier in 3...5 {
      let choices = HabitWidgetChoices.suggestions(snapshot: s, excluding: Set(ids.prefix(earlier)),
        keeping: nil, search: "sAME nAME")
      XCTAssertEqual(choices.map(\.id), Array(ids.dropFirst(earlier)))
      let all = HabitWidgetChoices.suggestions(snapshot: s, excluding: Set(ids.prefix(earlier)), keeping: nil)
      XCTAssertEqual(all.map(\.id), ["auto"] + Array(ids.dropFirst(earlier)))
    }
  }
}
