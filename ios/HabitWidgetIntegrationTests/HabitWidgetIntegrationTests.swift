// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import Foundation
import XCTest

/// Checks built application artifacts and file-backed component boundaries.
///
/// This suite never launches the application or writes its shared preferences,
/// database, or app-group files. It does not exercise system widget dispatch.
final class HabitWidgetIntegrationTests: XCTestCase {
  private let now = HabitWidgetSnapshot.parseDate("2026-10-17T04:00:00Z")!
  private var previousTimeZone: TimeZone!
  private var directory: URL!

  override func setUpWithError() throws {
    previousTimeZone = NSTimeZone.default
    NSTimeZone.default = TimeZone(secondsFromGMT: 0)!
    directory = FileManager.default.temporaryDirectory.appendingPathComponent(
      "HabitWidgetIntegrationTests-\(UUID().uuidString)",
      isDirectory: true,
    )
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  }

  override func tearDownWithError() throws {
    defer { NSTimeZone.default = previousTimeZone }
    if let directory { try FileManager.default.removeItem(at: directory) }
  }

  /// Opens the built product supplied by the integration scheme.
  private func applicationBundle() throws -> Bundle {
    let path = try XCTUnwrap(
      ProcessInfo.processInfo.environment["HABIT_WIDGET_TEST_APP_PATH"],
      "Run the HabitWidgetIntegrationTests scheme to supply the compiled application path.",
    )
    return try XCTUnwrap(Bundle(path: path))
  }

  private func widgetBundle(in application: Bundle) throws -> Bundle {
    try XCTUnwrap(
      Bundle(
        url: application.bundleURL.appendingPathComponent(
          "PlugIns/HabitWidgetExtension.appex",
          isDirectory: true,
        )
      )
    )
  }

  private func localizedTable(_ language: String, in bundle: Bundle) throws -> [String: String] {
    let url = bundle.bundleURL.appendingPathComponent("\(language).lproj/Localizable.strings")
    return try XCTUnwrap(
      PropertyListSerialization.propertyList(from: Data(contentsOf: url), format: nil)
        as? [String: String]
    )
  }

  /// Produces a committed projection using the shared cross-language fixture.
  private func snapshotData(version: String = "v1") throws -> Data {
    let url = try XCTUnwrap(
      Bundle(for: Self.self).url(forResource: "snapshot-v2", withExtension: "json")
    )
    var json = try XCTUnwrap(
      JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
    )
    var habit = (json["catalog"] as! [[String: Any]])[0]
    habit["canMarkIncomplete"] = false
    habit["automaticPending"] = false
    habit["recordState"] = "achieved"
    habit["completed"] = true
    habit["progress"] = 1.0
    habit["canComplete"] = false
    habit["canUndo"] = true
    habit["expectedRecord"] = version
    json["catalog"] = [habit]
    json["activeCount"] = 1
    json["completedCount"] = 1
    json["generatedAt"] = "2026-10-17T04:00:01Z"
    json["locale"] = "en"
    json.removeValue(forKey: "strings")
    return try JSONSerialization.data(withJSONObject: json)
  }

  private func snapshot(version: String = "v1") throws -> HabitWidgetSnapshot {
    try JSONDecoder().decode(HabitWidgetSnapshot.self, from: snapshotData(version: version))
  }

  private func event(_ hold: HabitWidgetHold) -> HabitWidgetHoldEvent {
    HabitWidgetHoldEvent(
      habitID: hold.habitID,
      day: hold.day,
      recordVersion: hold.recordVersion,
      identity: hold.identity,
    )
  }

  func testApplicationAndEmbeddedExtensionShareResolvedConfiguration() throws {
    let application = try applicationBundle()
    let widget = try widgetBundle(in: application)
    let applicationID = try XCTUnwrap(application.bundleIdentifier)
    let group = try XCTUnwrap(
      application.object(forInfoDictionaryKey: "HabitWidgetAppGroup") as? String
    )
    XCTAssertEqual(group, "group.\(applicationID).widgets")
    XCTAssertEqual(widget.bundleIdentifier, "\(applicationID).widgets")
    XCTAssertEqual(widget.object(forInfoDictionaryKey: "HabitWidgetAppGroup") as? String, group)
    let configuration = try XCTUnwrap(
      widget.object(forInfoDictionaryKey: "NSExtension") as? [String: Any]
    )
    XCTAssertEqual(
      configuration["NSExtensionPointIdentifier"] as? String,
      "com.apple.widgetkit-extension",
    )
    XCTAssertFalse(group.contains("$("), "Build settings must be resolved in both products.")
  }

  func testApplicationAndExtensionContainAllWidgetLocalesAndSeparateMetadataKeys() throws {
    let languages = [
      "ar", "cs", "de", "en", "es", "eu", "fa", "fr", "he", "hu", "it", "ja", "nb", "nl", "pl",
      "pt", "ru", "tr", "uk", "vi", "zh-Hans", "zh-Hant",
    ]
    let metadata = Set(
      ([
        "habitAction", "complete", "undo", "refresh", "next", "markIncomplete", "selectionSource",
        "automatic", "fixed", "updateHabit", "actionDescription", "habit", "day", "expectedRecord",
        "holdIdentity", "action", "name", "configureHabits",
      ] + (1...6).map { "habit\($0)" })
      .map {
        "HomeWidgetMetadata\($0.prefix(1).uppercased())\($0.dropFirst())"
      }
    )
    let runtime = Set(HabitWidgetText.allCases.map(\.key))
    let application = try applicationBundle()
    for bundle in [application, try widgetBundle(in: application)] {
      XCTAssertTrue(Set(languages).isSubset(of: Set(bundle.localizations)))
      for language in languages {
        let values = try localizedTable(language, in: bundle)
        XCTAssertTrue(Set(values.keys).isSubset(of: metadata.union(runtime)), "\(language)")
        XCTAssertTrue(values.values.allSatisfy { !$0.isEmpty })
        for key in ["HomeWidgetComplete", "HomeWidgetIncomplete"] {
          XCTAssertNotNil(values[key], "Localize both check-in buttons: \(language), \(key)")
        }
        if ["en", "ru", "zh-Hans", "zh-Hant"].contains(language) {
          let required =
            language == "ru" ? metadata.subtracting(["HomeWidgetMetadataMarkIncomplete"]) : metadata
          XCTAssertTrue(
            required.isSubset(of: Set(values.keys)),
            "Keep existing metadata translations: \(language)",
          )
        }
        if language == "en" {
          XCTAssertEqual(Set(values.keys), metadata.union(runtime))
        }
      }
    }
  }

  func testAppLocaleSelectsTheSameNativeRuntimeTextInBothProducts() throws {
    let application = try applicationBundle()
    let products = [application, try widgetBundle(in: application)]
    for (locale, language) in [
      ("zh", "zh-Hans"), ("zh_Hant", "zh-Hant"), ("zh-Hant-TW", "zh-Hant"), ("ar", "ar"),
      ("en_US", "en"),
    ] {
      var json = try XCTUnwrap(JSONSerialization.jsonObject(with: snapshotData()) as? [String: Any])
      json["locale"] = locale
      let snapshot = try JSONDecoder()
        .decode(
          HabitWidgetSnapshot.self,
          from: JSONSerialization.data(withJSONObject: json),
        )
      for bundle in products {
        let table = try localizedTable(language, in: bundle)
        XCTAssertEqual(
          snapshot.text(.today, bundle: bundle),
          try XCTUnwrap(table[HabitWidgetText.today.key]),
          "\(bundle.bundleURL.lastPathComponent): \(locale)",
        )
      }
    }
  }

  func testEveryRuntimeKeyUsesItsTranslationOrEnglishInBothProducts() throws {
    let application = try applicationBundle()
    for bundle in [application, try widgetBundle(in: application)] {
      let english = try localizedTable("en", in: bundle)
      for language in bundle.localizations
      where FileManager.default.fileExists(
        atPath: bundle.bundleURL.appendingPathComponent("\(language).lproj/Localizable.strings")
          .path
      ) {
        let translated = try localizedTable(language, in: bundle)
        for text in HabitWidgetText.allCases {
          let expected = try XCTUnwrap(translated[text.key] ?? english[text.key])
          XCTAssertEqual(
            text.localized(locale: Locale(identifier: language), bundle: bundle),
            expected,
            "\(bundle.bundleURL.lastPathComponent): \(language): \(text.key)",
          )
        }
      }
      for text in HabitWidgetText.allCases {
        XCTAssertEqual(
          text.localized(locale: Locale(identifier: "xx_YY"), bundle: bundle),
          english[text.key],
        )
      }
    }
  }

  func testRecordStatesUseChineseScriptsAndTaiwanRegionAliasesInBothProducts() throws {
    let application = try applicationBundle()
    let states: [(HabitWidgetRecordState, HabitWidgetText)] = [
      (.unrecorded, .unrecorded), (.notAchieved, .notAchieved), (.achieved, .achieved),
    ]
    let products = [application, try widgetBundle(in: application)]
    for (locale, language) in [
      ("zh", "zh-Hans"), ("zh_CN", "zh-Hans"), ("zh_Hans_CN", "zh-Hans"),
      ("zh_TW", "zh-Hant"), ("zh_tw", "zh-Hant"), ("zh-Hant", "zh-Hant"),
      ("zh_Hant_TW", "zh-Hant"), ("en", "en"), ("xx_YY", "en"),
    ] {
      for (state, text) in states {
        var json = try XCTUnwrap(
          JSONSerialization.jsonObject(with: snapshotData()) as? [String: Any]
        )
        var habit = (json["catalog"] as! [[String: Any]])[0]
        habit["recordState"] = state.rawValue
        habit["canMarkIncomplete"] = state != .achieved
        habit["automaticPending"] = state != .achieved
        habit["completed"] = state == .achieved
        habit["canComplete"] = state != .achieved
        habit["canUndo"] = state != .unrecorded
        habit["progress"] = state == .achieved ? 1.0 : 0.0
        json["catalog"] = [habit]
        json["completedCount"] = state == .achieved ? 1 : 0
        json["locale"] = locale
        let snapshot = try JSONDecoder()
          .decode(
            HabitWidgetSnapshot.self,
            from: JSONSerialization.data(withJSONObject: json),
          )
        for bundle in products {
          let table = try localizedTable(language, in: bundle)
          let expected = try XCTUnwrap(table[text.key])
          XCTAssertEqual(snapshot.text(text, bundle: bundle), expected, locale)
          XCTAssertEqual(
            snapshot.catalog[0].recordStatusText(snapshot, bundle: bundle),
            expected,
            locale,
          )
        }
      }
    }
  }

  func testApplicationAndExtensionContainExtractedIntentMetadata() throws {
    let application = try applicationBundle()
    for bundle in [application, try widgetBundle(in: application)] {
      let data = try Data(
        contentsOf: bundle.bundleURL.appendingPathComponent(
          "Metadata.appintents/extract.actionsdata"
        )
      )
      let metadata = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
      let actions = try XCTUnwrap(metadata["actions"] as? [String: Any])
      let entities = try XCTUnwrap(metadata["entities"] as? [String: Any])
      let queries = try XCTUnwrap(metadata["queries"] as? [String: Any])
      let enums = try XCTUnwrap(metadata["enums"] as? [[String: Any]])
      let actionEnum = try XCTUnwrap(
        enums.first { $0["identifier"] as? String == "HabitWidgetAction" }
      )
      let cases = try XCTUnwrap(actionEnum["cases"] as? [[String: Any]])
      let incomplete = try XCTUnwrap(
        cases.first { $0["identifier"] as? String == "markIncomplete" }
      )
      let representation = try XCTUnwrap(incomplete["displayRepresentation"] as? [String: Any])
      XCTAssertEqual(
        (representation["title"] as? [String: Any])?["key"] as? String,
        "HomeWidgetMetadataMarkIncomplete",
      )
      let update = try XCTUnwrap(actions["HabitWidgetActionIntent"] as? [String: Any])
      XCTAssertEqual(
        (update["title"] as? [String: Any])?["key"] as? String,
        "HomeWidgetMetadataUpdateHabit",
      )
      let configuration = try XCTUnwrap(actions["HabitWidgetConfiguration"] as? [String: Any])
      let choice = try XCTUnwrap(entities["HabitWidgetChoice"] as? [String: Any])
      XCTAssertEqual(
        (configuration["title"] as? [String: Any])?["key"] as? String,
        "HomeWidgetMetadataConfigureHabits",
      )
      XCTAssertEqual(
        (choice["displayTypeName"] as? [String: Any])?["key"] as? String,
        "HomeWidgetMetadataHabit",
      )
      let parameters = try XCTUnwrap(configuration["parameters"] as? [[String: Any]])
      XCTAssertEqual(
        parameters.compactMap { ($0["title"] as? [String: Any])?["key"] as? String },
        (1...6).map { "HomeWidgetMetadataHabit\($0)" },
      )
      XCTAssertEqual(parameters.compactMap { $0["name"] as? String }, (1...6).map { "slot\($0)" })
      let queryNames = [
        "HabitWidgetChoiceQuery", "HabitWidgetSlot2Query", "HabitWidgetSlot3Query",
        "HabitWidgetSlot4Query", "HabitWidgetSlot5Query", "HabitWidgetSlot6Query",
      ]
      for (index, name) in queryNames.enumerated() {
        let query = try XCTUnwrap(queries[name] as? [String: Any])
        let identifier = try XCTUnwrap(query["fullyQualifiedIdentifier"] as? String)
        let parameter = try XCTUnwrap(
          parameters.first { $0["name"] as? String == "slot\(index + 1)" }
        )
        XCTAssertEqual(query["entityType"] as? String, "HabitWidgetChoice")
        // Preserve the extractor's existing identity, suggestion, and search
        // capability set when method implementations move to a protocol.
        XCTAssertEqual(query["capabilities"] as? Int, 70, name)
        XCTAssertEqual(query["defaultQueryForEntity"] as? Bool, index == 0, name)
        XCTAssertEqual(parameter["queryIdentifier"] as? String, identifier)
        if index == 0 { XCTAssertEqual(choice["defaultQueryIdentifier"] as? String, identifier) }
      }
    }
  }

  @MainActor
  func testAtomicFileIsImmediatelyVisibleToIndependentReadersAndColdRestoration() throws {
    let url = directory.appendingPathComponent("holds.json")
    let store = HabitWidgetHoldStore(storage: HabitWidgetFileHoldStorage(url: url))
    let other = HabitWidgetHoldStore(storage: HabitWidgetFileHoldStorage(url: url))
    let snapshot = try snapshot()
    let id = snapshot.catalog[0].id
    let commit = try XCTUnwrap(
      HabitWidgetCommit(recordVersion: "v1", committedAt: "2026-10-17T04:00:00Z")
    )
    let hold = try XCTUnwrap(
      store.recorded(habitID: id, day: snapshot.day, source: .automatic, commit: commit, at: now)
    )
    XCTAssertEqual(other.validHolds(snapshot: snapshot, at: now)[id], hold)
    XCTAssertTrue(try other.advance(event(hold), snapshot: snapshot, at: now))
    XCTAssertTrue(store.validHolds(snapshot: snapshot, at: now).isEmpty)
    let restored = HabitWidgetHoldStore(storage: HabitWidgetFileHoldStorage(url: url))
    XCTAssertTrue(restored.validHolds(snapshot: snapshot, at: now).isEmpty)
    try Data("corrupt".utf8).write(to: url)
    XCTAssertTrue(restored.validHolds(snapshot: snapshot, at: now).isEmpty)
  }

  /// Connects snapshot decoding, persistent identities, entries, and advancement.
  @MainActor
  func testPersistedCompletionRestoresIntoTimelinesAndNextAdvancesIndependentReaders() throws {
    let snapshotURL = directory.appendingPathComponent("snapshot.json")
    let holdURL = directory.appendingPathComponent("holds.json")
    let published = try snapshotData()
    try published.write(to: snapshotURL, options: .atomic)
    let snapshot = try JSONDecoder()
      .decode(
        HabitWidgetSnapshot.self,
        from: Data(contentsOf: snapshotURL),
      )
    let id = snapshot.catalog[0].id
    let writer = HabitWidgetHoldStore(storage: HabitWidgetFileHoldStorage(url: holdURL))
    let commit = try XCTUnwrap(
      HabitWidgetCommit(recordVersion: "v1", committedAt: "2026-10-17T04:00:00Z")
    )
    let hold = try XCTUnwrap(
      writer.recorded(habitID: id, day: snapshot.day, source: .automatic, commit: commit, at: now)
    )
    let reader = HabitWidgetHoldStore(storage: HabitWidgetFileHoldStorage(url: holdURL))
    let retained = reader.validHolds(snapshot: snapshot, at: now)
    let small = HabitWidgetConfiguredEntry(
      date: now,
      snapshot: snapshot,
      selections: [],
      slotCount: 1,
      holds: retained,
    )
    let medium = HabitWidgetConfiguredEntry(
      date: now,
      snapshot: snapshot,
      selections: [],
      slotCount: 3,
      holds: retained,
    )
    let large = HabitWidgetConfiguredEntry(
      date: now,
      snapshot: snapshot,
      selections: [],
      slotCount: 6,
      holds: retained,
    )
    XCTAssertEqual(small.slots.first?.habit?.id, id)
    XCTAssertEqual(medium.slots.first?.habit?.id, id)
    XCTAssertEqual(large.slots.first?.habit?.id, id)
    XCTAssertEqual(small.holds[id]?.identity, medium.holds[id]?.identity)
    XCTAssertEqual(medium.holds[id]?.identity, large.holds[id]?.identity)
    XCTAssertTrue(try writer.advance(event(hold), snapshot: snapshot, at: now))
    XCTAssertFalse(try reader.advance(event(hold), snapshot: snapshot, at: now))
    for count in [1, 3, 6] {
      let entry = HabitWidgetConfiguredEntry(
        date: now,
        snapshot: snapshot,
        selections: [],
        slotCount: count,
        holds: reader.validHolds(snapshot: snapshot, at: now),
      )
      XCTAssertTrue(entry.holds.isEmpty)
      XCTAssertTrue(entry.slots.allSatisfy { $0.empty == .completed })
    }
    XCTAssertEqual(
      small.holds[id],
      hold,
      "An archived entry keeps the state captured before Next.",
    )
    XCTAssertEqual(
      try Data(contentsOf: snapshotURL),
      published,
      "Next cannot change the published record projection.",
    )
  }

  @MainActor
  func testExternalSnapshotInvalidatesPersistedIdentityBeforeTimelineCapture() throws {
    let url = directory.appendingPathComponent("holds.json")
    let original = try snapshot()
    let writer = HabitWidgetHoldStore(storage: HabitWidgetFileHoldStorage(url: url))
    let commit = try XCTUnwrap(
      HabitWidgetCommit(recordVersion: "v1", committedAt: "2026-10-17T04:00:00Z")
    )
    try writer.recorded(
      habitID: original.catalog[0].id,
      day: original.day,
      source: .automatic,
      commit: commit,
      at: now,
    )
    let changed = try snapshot(version: "external")
    XCTAssertTrue(try writer.reconcile(snapshot: changed, at: now))
    let restored = HabitWidgetHoldStore(storage: HabitWidgetFileHoldStorage(url: url))
    let entry = HabitWidgetConfiguredEntry(
      date: now,
      snapshot: changed,
      selections: [],
      slotCount: 1,
      holds: restored.validHolds(snapshot: changed, at: now),
    )
    XCTAssertTrue(entry.holds.isEmpty)
    XCTAssertEqual(entry.slots.first?.empty, .completed)
    XCTAssertTrue(restored.validHolds(snapshot: original, at: now).isEmpty)
  }

  @MainActor
  func testIncompleteRestoresAcrossProductsAndNextLeavesItsProjectionUntouched() throws {
    var json = try XCTUnwrap(JSONSerialization.jsonObject(with: snapshotData()) as? [String: Any])
    var habit = (json["catalog"] as! [[String: Any]])[0]
    habit["recordState"] = "notAchieved"
    habit["completed"] = false
    habit["progress"] = 0.0
    json["catalog"] = [habit]
    json["completedCount"] = 0
    let published = try JSONSerialization.data(withJSONObject: json)
    let snapshot = try JSONDecoder().decode(HabitWidgetSnapshot.self, from: published)
    let id = snapshot.catalog[0].id
    let holdURL = directory.appendingPathComponent("holds.json")
    let writer = HabitWidgetHoldStore(storage: HabitWidgetFileHoldStorage(url: holdURL))
    let commit = try XCTUnwrap(
      HabitWidgetCommit(recordVersion: "v1", committedAt: "2026-10-17T04:00:00Z")
    )
    let hold = try XCTUnwrap(
      writer.recorded(
        habitID: id,
        day: snapshot.day,
        source: .automatic,
        commit: commit,
        at: now,
        result: .incomplete,
      )
    )
    let reader = HabitWidgetHoldStore(storage: HabitWidgetFileHoldStorage(url: holdURL))
    for count in [1, 3, 6] {
      let entry = HabitWidgetConfiguredEntry(
        date: now,
        snapshot: snapshot,
        selections: [],
        slotCount: count,
        holds: reader.validHolds(snapshot: snapshot, at: now),
      )
      XCTAssertEqual(entry.slots.first?.habit?.id, id)
      XCTAssertEqual(entry.holds[id]?.result, .incomplete)
      XCTAssertEqual(entry.holds[id]?.identity, hold.identity)
      XCTAssertFalse(entry.slots.first!.habit!.canComplete)
      XCTAssertFalse(entry.slots.first!.habit!.canMarkIncomplete)
    }
    XCTAssertTrue(try reader.advance(event(hold), snapshot: snapshot, at: now))
    let next = HabitWidgetConfiguredEntry(
      date: now,
      snapshot: snapshot,
      selections: [],
      slotCount: 1,
      holds: writer.validHolds(snapshot: snapshot, at: now),
    )
    XCTAssertEqual(next.slots.first?.empty, .noPending)
    XCTAssertEqual(snapshot.completedCount, 0)
    XCTAssertEqual(
      try JSONDecoder().decode(HabitWidgetSnapshot.self, from: published).catalog[0].expectedRecord,
      "v1",
    )
    let stored = try XCTUnwrap(
      JSONSerialization.jsonObject(with: Data(contentsOf: holdURL)) as? [String: Any]
    )
    XCTAssertEqual(stored["version"] as? Int, 2)
  }
}
