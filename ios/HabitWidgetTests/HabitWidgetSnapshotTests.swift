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

  func testV1RemainsAnIncompleteDirectoryWithItsOriginalHabitProjection() throws {
    let snapshot = try decode(fixture(1))
    XCTAssertFalse(snapshot.hasCompleteCatalog)
    XCTAssertEqual(snapshot.catalog.filter { $0.state == .active && $0.started }.map(\.name), ["first"])
    XCTAssertEqual(snapshot.activeCount, 1)
    XCTAssertEqual(snapshot.completedCount, 0)
    XCTAssertNil(snapshot.locale)
    XCTAssertEqual(snapshot.catalog.first?.sevenDays.count, 7)
  }

  /// Creates isolated native tables without requiring an application build.
  private func resourceBundle(_ tables: [String: [String: String]],
                              unrelated: [String] = []) throws -> Bundle {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("WidgetLocalization-\(UUID().uuidString).bundle")
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    addTeardownBlock { try FileManager.default.removeItem(at: root) }
    let info = ["CFBundleIdentifier": "io.github.friesi23.widgettests.\(UUID().uuidString)",
      "CFBundleDevelopmentRegion": "en"]
    try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
      .write(to: root.appendingPathComponent("Info.plist"))
    for (language, values) in tables {
      let directory = root.appendingPathComponent("\(language).lproj")
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      try PropertyListSerialization.data(fromPropertyList: values, format: .binary, options: 0)
        .write(to: directory.appendingPathComponent("Localizable.strings"))
    }
    for language in unrelated {
      let directory = root.appendingPathComponent("\(language).lproj")
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      try PropertyListSerialization.data(fromPropertyList: ["CFBundleDisplayName": "Other"], format: .binary, options: 0)
        .write(to: directory.appendingPathComponent("InfoPlist.strings"))
    }
    return try XCTUnwrap(Bundle(url: root))
  }

  func testNewAndLegacySnapshotsResolveLocaleWithoutReadingLegacyText() throws {
    let resources = try resourceBundle(["ar": ["HomeWidgetToday": "اليوم"],
      "ru": ["HomeWidgetToday": "Сегодня"]])
    for version in [1, 2] {
      var json = try XCTUnwrap(JSONSerialization.jsonObject(with: fixture(version)) as? [String: Any])
      json["strings"] = ["locale": "ru", "today": "Obsolete snapshot text"]
      let legacy = try decode(JSONSerialization.data(withJSONObject: json))
      XCTAssertEqual(legacy.locale, "ru")
      XCTAssertEqual(legacy.text(.today, bundle: resources), "Сегодня")
      json["locale"] = "ar"
      let current = try decode(JSONSerialization.data(withJSONObject: json))
      XCTAssertEqual(current.locale, "ar")
      XCTAssertEqual(current.text(.today, bundle: resources), "اليوم")
      XCTAssertEqual(current.widgetLocale.language.characterDirection, .rightToLeft)
      json["locale"] = NSNull()
      XCTAssertEqual(try decode(JSONSerialization.data(withJSONObject: json)).locale, "ru")
      json.removeValue(forKey: "strings")
      json["locale"] = "ar"
      XCTAssertEqual(try decode(JSONSerialization.data(withJSONObject: json)).text(.today, bundle: resources), "اليوم")
    }
  }

  func testNativeTextFallsBackThroughEnglishResourcesToHardcodedDefaults() throws {
    let resources = try resourceBundle(["en": ["HomeWidgetToday": "Native default", "HomeWidgetRefresh": "Other English text"],
      "fr": ["HomeWidgetToday": "Aujourd’hui"]])
    let defaults = try resourceBundle(["en": ["HomeWidgetToday": "Native default"]])
    XCTAssertEqual(HabitWidgetText.today.localized(bundle: defaults), "Native default")
    XCTAssertEqual(HabitWidgetText.today.localized(locale: Locale(identifier: "fr_CA"), bundle: resources), "Aujourd’hui")
    XCTAssertEqual(HabitWidgetText.refresh.localized(locale: Locale(identifier: "fr"), bundle: resources), "Other English text")
    XCTAssertEqual(HabitWidgetText.refresh.localized(locale: Locale(identifier: "xx_YY"), bundle: resources), "Other English text")
    XCTAssertEqual(HabitWidgetText.complete.localized(locale: Locale(identifier: "fr"), bundle: resources), "Done")
    let withoutEnglish = try resourceBundle(["fr": ["HomeWidgetToday": "Aujourd’hui"]])
    XCTAssertEqual(HabitWidgetText.today.localized(locale: Locale(identifier: "fr"), bundle: withoutEnglish), "Aujourd’hui")
    XCTAssertEqual(HabitWidgetText.refresh.localized(locale: Locale(identifier: "fr"), bundle: withoutEnglish), "Refresh")
    let empty = try resourceBundle([:])
    XCTAssertEqual(HabitWidgetText.complete.localized(bundle: empty), "Done")
    XCTAssertEqual(HabitWidgetText.undo.localized(bundle: empty), "UNDO")
    let old = try decode(fixture(1))
    XCTAssertEqual(old.text(.today, bundle: empty), "Today")
  }

  func testWidgetLanguageSelectionPreservesScriptRegionAndIgnoresUnrelatedTables() throws {
    let resources = try resourceBundle(["en": ["HomeWidgetToday": "Today"],
      "zh-Hans": ["HomeWidgetToday": "今天"], "zh-Hant": ["HomeWidgetToday": "今日"],
      "ar": ["HomeWidgetToday": "اليوم"]], unrelated: ["zh"])
    for (identifier, expected) in [("zh", "今天"), ("zh_Hans_CN", "今天"),
      ("zh_Hant", "今日"), ("zh-Hant-TW", "今日"), ("zh_TW", "今日"),
      ("ar_SA", "اليوم"), ("en_US", "Today"), ("xx_YY", "Today")] {
      XCTAssertEqual(HabitWidgetText.today.localized(locale: Locale(identifier: identifier), bundle: resources), expected, identifier)
    }
  }

  func testMissingEnglishTableNeverFallsBackToAnUnrelatedLanguage() throws {
    let resources = try resourceBundle(["fr": ["HomeWidgetToday": "Aujourd’hui"]])
    XCTAssertEqual(HabitWidgetText.today.localized(locale: Locale(identifier: "de"), bundle: resources), "Today")
    let empty = try resourceBundle([:])
    for text in HabitWidgetText.allCases {
      XCTAssertEqual(text.localized(locale: Locale(identifier: "de"), bundle: empty), text.englishDefault)
    }
  }

  func testLocaleCannotMakeAnInvalidBusinessSnapshotReadable() throws {
    XCTAssertThrowsError(try decode(modified {
      $0["locale"] = "ar"
      $0["activeCount"] = 100
    }))
    XCTAssertThrowsError(try decode(modified { $0["locale"] = 7 }))
    XCTAssertThrowsError(try decode(modified { $0["strings"] = ["today": 7] }))
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

  func testLegacyRecordStateDoesNotInferPresenceFromProgressOrCapabilities() throws {
    let legacy = try decode(fixture(1))
    XCTAssertEqual(legacy.catalog.first?.recordState, .unknown)
    let snapshot = try decode(modified { json in
      var catalog = json["catalog"] as! [[String: Any]]
      for index in catalog.indices {
        catalog[index].removeValue(forKey: "recordState")
        catalog[index].removeValue(forKey: "canMarkIncomplete")
        catalog[index].removeValue(forKey: "automaticPending")
      }
      catalog[0]["canUndo"] = true
      json["catalog"] = catalog
    })
    XCTAssertTrue(snapshot.hasCompleteCatalog)
    XCTAssertTrue(snapshot.catalog.allSatisfy { $0.recordState == .unknown })
    XCTAssertNil(snapshot.catalog[0].recordStatusText(snapshot))
    XCTAssertTrue(snapshot.catalog[0].canComplete)
    XCTAssertTrue(snapshot.catalog[0].canUndo)
    XCTAssertTrue(snapshot.catalog[0].automaticEligible)
    XCTAssertFalse(snapshot.catalog[0].canMarkIncomplete)
    XCTAssertTrue(snapshot.catalog[0].automaticPending)
  }

  func testRecordLabelsDistinguishMissingAndRecordedZeroWithoutChangingCandidates() throws {
    let resources = try resourceBundle(["en": ["HomeWidgetUnrecorded": "Not recorded",
      "HomeWidgetNotAchieved": "Not achieved", "HomeWidgetAchieved": "Achieved",
      "HomeWidgetSkipped": "Skip"], "zh-Hans": ["HomeWidgetToday": "今天"]])
    let now = try XCTUnwrap(HabitWidgetSnapshot.parseDate("2026-10-17T04:00:00Z"))
    for (state, label, completed, skipped) in [
      ("unrecorded", "Not recorded", false, false), ("notAchieved", "Not achieved", false, false),
      ("achieved", "Achieved", true, false), ("skipped", "Skip", false, true),
    ] {
      let snapshot = try decode(modified { json in
        var habit = (json["catalog"] as! [[String: Any]])[0]
        habit["recordState"] = state
        habit["canMarkIncomplete"] = !completed && !skipped
        habit["automaticPending"] = !completed && !skipped
        habit["completed"] = completed
        habit["canComplete"] = !completed && !skipped
        habit["canUndo"] = !skipped && state != "unrecorded"
        habit["automaticEligible"] = !skipped
        habit["skipped"] = skipped
        // Presence and result come from Dart, never from progress=0.
        habit["progress"] = 0.0
        json["catalog"] = [habit]
        json["activeCount"] = 1
        json["completedCount"] = completed ? 1 : 0
        json["locale"] = "zh"
      })
      XCTAssertEqual(snapshot.catalog[0].recordStatusText(snapshot, bundle: resources), label)
      XCTAssertEqual(snapshot.catalog[0].recordState.rawValue, state)
      let rows = HabitWidgetSlots.resolve(snapshot: snapshot, selections: [nil], count: 1, at: now)
      XCTAssertEqual(rows[0].habit != nil, !completed && !skipped)
      XCTAssertEqual(snapshot.completedCount, completed ? 1 : 0)
    }
  }

  func testLifecycleLabelsTakePriorityAndMalformedRecordStatesAreRejected() throws {
    let snapshot = try decode(modified { json in
      var catalog = json["catalog"] as! [[String: Any]]
      catalog[2]["recordState"] = "achieved"
      catalog[3]["recordState"] = "achieved"
      json["catalog"] = catalog
    })
    XCTAssertNil(snapshot.catalog[2].recordStatusText(snapshot))
    XCTAssertNil(snapshot.catalog[3].recordStatusText(snapshot))
    for invalid: Any in ["done", 42, ["achieved"]] {
      XCTAssertThrowsError(try decode(modified { json in
        var catalog = json["catalog"] as! [[String: Any]]
        catalog[0]["recordState"] = invalid
        json["catalog"] = catalog
      }))
    }
    let empty = try resourceBundle([:])
    XCTAssertEqual(HabitWidgetText.unrecorded.localized(bundle: empty), "Not recorded")
    XCTAssertEqual(HabitWidgetText.notAchieved.localized(bundle: empty), "Not achieved")
    XCTAssertEqual(HabitWidgetText.achieved.localized(bundle: empty), "Achieved")
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

  func testProcessedZeroIsExplicitWhileOlderProjectionKeepsItsCandidateBehavior() throws {
    let data = try modified { json in
      var habit = (json["catalog"] as! [[String: Any]])[0]
      habit["recordState"] = "notAchieved"; habit["automaticPending"] = false
      habit["canComplete"] = false; habit["canMarkIncomplete"] = false; habit["canUndo"] = true
      json["catalog"] = [habit]; json["activeCount"] = 1
    }
    let snapshot = try decode(data)
    let habit = snapshot.catalog[0]
    XCTAssertEqual(habit.recordStatusText(snapshot), "Incomplete")
    XCTAssertFalse(habit.canComplete)
    XCTAssertFalse(habit.canMarkIncomplete)
    let now = try XCTUnwrap(HabitWidgetSnapshot.parseDate("2026-10-17T04:00:00Z"))
    XCTAssertEqual(HabitWidgetSlots.resolve(snapshot: snapshot, selections: [], count: 1, at: now)[0].empty, .noPending)
    var legacy = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    var rows = legacy["catalog"] as! [[String: Any]]
    rows[0].removeValue(forKey: "automaticPending"); rows[0].removeValue(forKey: "canMarkIncomplete")
    legacy["catalog"] = rows
    let old = try decode(JSONSerialization.data(withJSONObject: legacy))
    XCTAssertTrue(old.catalog[0].automaticPending)
    XCTAssertFalse(old.catalog[0].canMarkIncomplete)
    XCTAssertEqual(old.catalog[0].recordStatusText(old), "Not achieved")
    XCTAssertNotNil(HabitWidgetSlots.resolve(snapshot: old, selections: [], count: 1, at: now)[0].habit)
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
