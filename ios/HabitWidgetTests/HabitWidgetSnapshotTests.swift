// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import Foundation
import XCTest

final class HabitWidgetSnapshotTests: XCTestCase {
  private func fixture(_ version: Int) throws -> Data {
    let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "snapshot-v\(version)", withExtension: "json"))
    return try Data(contentsOf: url)
  }

  private func decode(_ data: Data) throws -> HabitWidgetSnapshot {
    try JSONDecoder().decode(HabitWidgetSnapshot.self, from: data)
  }

  private func modified(_ change: (inout [String: Any]) -> Void) throws -> Data {
    var json = try XCTUnwrap(JSONSerialization.jsonObject(with: fixture(2)) as? [String: Any])
    change(&json)
    return try JSONSerialization.data(withJSONObject: json)
  }

  func testV1RemainsAnIncompleteDirectoryWithItsOriginalDisplay() throws {
    let snapshot = try decode(fixture(1))
    XCTAssertFalse(snapshot.hasCompleteCatalog)
    XCTAssertEqual(snapshot.catalog.filter { $0.state == .active && $0.started }.map(\.name), ["first"])
    XCTAssertEqual(snapshot.activeCount, 1)
    XCTAssertEqual(snapshot.completedCount, 0)
    XCTAssertEqual(snapshot.strings?["today"], "Сегодня")
    XCTAssertEqual(snapshot.catalog.first?.sevenDays.count, 7)
  }

  func testV2DirectoryPreservesTheLegacyActiveStartedView() throws {
    let snapshot = try decode(fixture(2))
    XCTAssertTrue(snapshot.hasCompleteCatalog)
    XCTAssertEqual(snapshot.catalog.map(\.name), ["first", "archived", "future", "unknown"])
    XCTAssertEqual(snapshot.catalog.filter { $0.state == .active && $0.started }.map(\.name), ["first"])
    XCTAssertTrue(snapshot.catalog[1].canComplete)
    XCTAssertFalse(snapshot.catalog[1].automaticEligible)
    XCTAssertFalse(snapshot.catalog[2].started)
    XCTAssertFalse(snapshot.catalog[2].canComplete)
    XCTAssertFalse(snapshot.catalog[3].canComplete)
    XCTAssertEqual(snapshot.activeCount, 1)
  }

  func testMalformedUnknownAndIncompleteSnapshotsCannotConfirmDeletion() throws {
    XCTAssertThrowsError(try decode(Data("not json".utf8)))
    XCTAssertThrowsError(try decode(modified { $0["version"] = 99 }))
    XCTAssertThrowsError(try decode(modified { $0.removeValue(forKey: "catalog") }))
    XCTAssertThrowsError(try decode(modified { $0.removeValue(forKey: "activeCount") }))
    XCTAssertThrowsError(try decode(modified { $0["day"] = "2026-02-30" }))
    XCTAssertThrowsError(try decode(modified { $0["nextDayAt"] = "broken" }))
    XCTAssertThrowsError(try decode(modified { json in
      var catalog = json["catalog"] as! [[String: Any]]
      catalog[0].removeValue(forKey: "started")
      json["catalog"] = catalog
    }))
  }

  func testDuplicateIdentitiesAndInconsistentCountsAreRejected() throws {
    XCTAssertThrowsError(try decode(modified { $0["activeCount"] = 4 }))
    XCTAssertThrowsError(try decode(modified { $0["completedCount"] = 1 }))
    XCTAssertThrowsError(try decode(modified { json in
      var catalog = json["catalog"] as! [[String: Any]]
      catalog[1]["id"] = catalog[0]["id"]
      json["catalog"] = catalog
    }))
  }

  func testBothVersionsDisableActionsAtTheCivilDayBoundary() throws {
    let previous = NSTimeZone.default
    NSTimeZone.default = TimeZone(secondsFromGMT: 0)!
    defer { NSTimeZone.default = previous }
    for version in [1, 2] {
      let snapshot = try decode(fixture(version))
      XCTAssertTrue(snapshot.isCurrent(at: try XCTUnwrap(HabitWidgetSnapshot.parseDate("2026-10-17T12:00:00Z"))))
      XCTAssertFalse(snapshot.isCurrent(at: try XCTUnwrap(snapshot.nextDay)))
      XCTAssertFalse(snapshot.isCurrent(at: try XCTUnwrap(HabitWidgetSnapshot.parseDate("2026-10-18T04:00:00Z"))))
    }
  }

  func testFractionalTimestampsPreserveSubMillisecondOrdering() throws {
    let older = try XCTUnwrap(HabitWidgetSnapshot.parseDate("2026-10-17T04:00:00.000100Z"))
    let committed = try XCTUnwrap(HabitWidgetSnapshot.parseDate("2026-10-17T04:00:00.000900Z"))
    XCTAssertLessThan(older, committed)
    XCTAssertEqual(committed.timeIntervalSince(older), 0.0008, accuracy: 0.000001)
    XCTAssertNotNil(HabitWidgetSnapshot.parseDate("2026-10-17T04:00:00Z"))
    XCTAssertNil(HabitWidgetSnapshot.parseDate("invalid timestamp"))
  }

  func testInvalidCapabilitiesAndMalformedProjectionCannotEnableActions() throws {
    let changes: [(inout [String: Any]) -> Void] = [
      { $0["id"] = "" },
      { $0["expectedRecord"] = "" },
      { $0["sevenDays"] = [] },
      { $0["startDate"] = "2026-02-30" },
      { $0["skipped"] = true },
      { $0["state"] = "unknown" },
      { $0["started"] = false },
    ]
    for change in changes {
      XCTAssertThrowsError(try decode(modified { json in
        var catalog = json["catalog"] as! [[String: Any]]
        change(&catalog[0])
        json["catalog"] = catalog
      }))
    }
    XCTAssertThrowsError(try decode(modified { $0["nextDayAt"] = $0["generatedAt"] }))
  }
}
