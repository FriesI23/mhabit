import AppIntents
import Foundation

/// Provides a stable picker identity and a user-facing display name.
@available(iOS 17.0, *)
struct HabitWidgetChoice: AppEntity {
  let id: String
  @Property(title: "Name") var name: String
  init(id: String, name: String) { self.id = id; self.name = name }
  static var typeDisplayRepresentation: TypeDisplayRepresentation = "Habit"
  static var defaultQuery = HabitWidgetChoiceQuery()
  static var automatic: HabitWidgetChoice { HabitWidgetChoice(id: HabitWidgetShared.automaticSelectionID, name: HabitWidgetShared.readSnapshot()?.nativeText("Automatic") ?? String(localized: "Automatic")) }

  var displayRepresentation: DisplayRepresentation {
    if id == HabitWidgetShared.automaticSelectionID { return DisplayRepresentation(title: "\(name)") }
    // Stable identity also distinguishes equal names in the system picker.
    return DisplayRepresentation(title: "\(name)", subtitle: "\(id)")
  }
}

/// Shares identity resolution and filtering across concrete App Intents queries.
@available(iOS 17.0, *)
enum HabitWidgetChoices {
  /// Resolves saved identities independently of the current recommendation list.
  static func identities(_ ids: [String], snapshot: HabitWidgetSnapshot?) -> [HabitWidgetChoice] {
    ids.compactMap { id in
      if id == HabitWidgetShared.automaticSelectionID { return .automatic }
      guard UUID(uuidString: id) != nil else { return nil }
      // Preserve saved identity even when a partial directory cannot resolve it.
      return HabitWidgetChoice(id: id, name: snapshot?.catalog.first(where: { $0.id == id })?.name
        ?? snapshot?.nativeText("Unavailable habit") ?? String(localized: "Unavailable habit"))
    }
  }

  /// Filters available names while preserving their snapshot ordering.
  static func suggestions(snapshot: HabitWidgetSnapshot?, excluding: Set<String>,
                          keeping: String?, search: String? = nil) -> [HabitWidgetChoice] {
    let choices = [HabitWidgetChoice.automatic] + (snapshot?.catalog ?? []).map {
      HabitWidgetChoice(id: $0.id, name: $0.name)
    }
    return choices.filter {
      ($0.id == HabitWidgetShared.automaticSelectionID || $0.id == keeping || !excluding.contains($0.id))
        && (search?.isEmpty != false || $0.name.localizedCaseInsensitiveContains(search!))
    }
  }
}

/// Describes the saved selections exposed by the system widget editor.
@available(iOS 17.0, *)
struct HabitWidgetConfiguration: WidgetConfigurationIntent {
  static var title: LocalizedStringResource = "Configure habits"
  @Parameter(title: "Habit 1", query: HabitWidgetChoiceQuery()) var slot1: HabitWidgetChoice?
  @Parameter(title: "Habit 2", query: HabitWidgetSlot2Query()) var slot2: HabitWidgetChoice?
  @Parameter(title: "Habit 3", query: HabitWidgetSlot3Query()) var slot3: HabitWidgetChoice?
  @Parameter(title: "Habit 4", query: HabitWidgetSlot4Query()) var slot4: HabitWidgetChoice?
  @Parameter(title: "Habit 5", query: HabitWidgetSlot5Query()) var slot5: HabitWidgetChoice?
  @Parameter(title: "Habit 6", query: HabitWidgetSlot6Query()) var slot6: HabitWidgetChoice?

  static var parameterSummary: some ParameterSummary {
    When(widgetFamily: .equalTo, .systemSmall) {
      Summary { \.$slot1 }
    } otherwise: {
      When(widgetFamily: .equalTo, .systemLarge) {
        Summary { \.$slot1; \.$slot2; \.$slot3; \.$slot4; \.$slot5; \.$slot6 }
      } otherwise: {
        Summary { \.$slot1; \.$slot2; \.$slot3 }
      }
    }
  }

  /// Initializes every parameter explicitly, including currently hidden habits.
  init() {
    slot1 = .automatic; slot2 = .automatic; slot3 = .automatic
    slot4 = .automatic; slot5 = .automatic; slot6 = .automatic
  }
  /// Returns saved identities in configuration order; the family limits use.
  var selections: [String?] { [slot1?.id, slot2?.id, slot3?.id, slot4?.id, slot5?.id, slot6?.id] }
}

/// Defines the filtering context for a shared entity query implementation.
@available(iOS 17.0, *)
protocol HabitWidgetQuery: EntityStringQuery {
  /// Identifiers omitted from recommendations and name search.
  var excludedIdentifiers: Set<String> { get }
}

/// Implements identity lookup, recommendations, search, and defaults once.
/// Concrete adapters declare associated types explicitly to avoid recursive
/// inference through `AppEntity.defaultQuery`.
@available(iOS 17.0, *)
extension HabitWidgetQuery
where Entity == HabitWidgetChoice, Result == [HabitWidgetChoice], DefaultValue == HabitWidgetChoice {
  /// Resolves stored identifiers without applying picker exclusions.
  func entities(for identifiers: [String]) async throws -> [HabitWidgetChoice] {
    HabitWidgetChoices.identities(identifiers, snapshot: HabitWidgetShared.readSnapshot())
  }
  /// Supplies recommendations using the query's filtering context.
  func suggestedEntities() async throws -> [HabitWidgetChoice] { choices(search: nil) }
  /// Searches names using the same exclusions as recommendations.
  func entities(matching string: String) async throws -> [HabitWidgetChoice] { choices(search: string) }
  /// Supplies an explicit default for unset parameters.
  func defaultResult() async -> HabitWidgetChoice? { .automatic }
  private func choices(search: String?) -> [HabitWidgetChoice] {
    HabitWidgetChoices.suggestions(snapshot: HabitWidgetShared.readSnapshot(), excluding: excludedIdentifiers,
                                   keeping: nil, search: search)
  }
}

/// Supplies choices without depending on another intent parameter.
@available(iOS 17.0, *)
struct HabitWidgetChoiceQuery: HabitWidgetQuery {
  typealias Entity = HabitWidgetChoice
  typealias Result = [HabitWidgetChoice]
  typealias DefaultValue = HabitWidgetChoice
  var excludedIdentifiers: Set<String> { [] }
}

/// Adapts the shared query logic to the second parameter's dependency metadata.
///
/// Each adapter's required `init()` reconstructs its fixed dependency set.
/// Dependencies remain acyclic during system identity resolution:
///
/// ```text
/// slot 1 <--- slot 2
///    ^           ^
///    +--- slot 3-+
/// ```
@available(iOS 17.0, *)
struct HabitWidgetSlot2Query: HabitWidgetQuery {
  typealias Entity = HabitWidgetChoice
  typealias Result = [HabitWidgetChoice]
  typealias DefaultValue = HabitWidgetChoice
  @IntentParameterDependency<HabitWidgetConfiguration> var configuration: IntentProjection<HabitWidgetConfiguration>?
  init() { _configuration = IntentParameterDependency(\.$slot1) }
  var excludedIdentifiers: Set<String> {
    Set([configuration?.slot1.id].compactMap { $0 })
  }
}

/// Adapts the shared query logic to the third parameter's earlier dependencies.
@available(iOS 17.0, *)
struct HabitWidgetSlot3Query: HabitWidgetQuery {
  typealias Entity = HabitWidgetChoice
  typealias Result = [HabitWidgetChoice]
  typealias DefaultValue = HabitWidgetChoice
  @IntentParameterDependency<HabitWidgetConfiguration> var configuration: IntentProjection<HabitWidgetConfiguration>?
  init() { _configuration = IntentParameterDependency(\.$slot1, \.$slot2) }
  var excludedIdentifiers: Set<String> {
    Set([configuration?.slot1.id, configuration?.slot2.id].compactMap { $0 })
  }
}

/// Adapts the shared query logic to the fourth parameter's earlier dependencies.
@available(iOS 17.0, *)
struct HabitWidgetSlot4Query: HabitWidgetQuery {
  typealias Entity = HabitWidgetChoice
  typealias Result = [HabitWidgetChoice]
  typealias DefaultValue = HabitWidgetChoice
  @IntentParameterDependency<HabitWidgetConfiguration> var configuration: IntentProjection<HabitWidgetConfiguration>?
  init() { _configuration = IntentParameterDependency(\.$slot1, \.$slot2, \.$slot3) }
  var excludedIdentifiers: Set<String> {
    Set([configuration?.slot1.id, configuration?.slot2.id, configuration?.slot3.id].compactMap { $0 })
  }
}

/// Adapts the shared query logic to the fifth parameter's earlier dependencies.
@available(iOS 17.0, *)
struct HabitWidgetSlot5Query: HabitWidgetQuery {
  typealias Entity = HabitWidgetChoice
  typealias Result = [HabitWidgetChoice]
  typealias DefaultValue = HabitWidgetChoice
  @IntentParameterDependency<HabitWidgetConfiguration> var configuration: IntentProjection<HabitWidgetConfiguration>?
  init() { _configuration = IntentParameterDependency(\.$slot1, \.$slot2, \.$slot3, \.$slot4) }
  var excludedIdentifiers: Set<String> {
    Set([configuration?.slot1.id, configuration?.slot2.id, configuration?.slot3.id,
         configuration?.slot4.id].compactMap { $0 })
  }
}

/// Adapts the shared query logic to the sixth parameter's earlier dependencies.
@available(iOS 17.0, *)
struct HabitWidgetSlot6Query: HabitWidgetQuery {
  typealias Entity = HabitWidgetChoice
  typealias Result = [HabitWidgetChoice]
  typealias DefaultValue = HabitWidgetChoice
  @IntentParameterDependency<HabitWidgetConfiguration> var configuration: IntentProjection<HabitWidgetConfiguration>?
  init() { _configuration = IntentParameterDependency(\.$slot1, \.$slot2, \.$slot3, \.$slot4, \.$slot5) }
  var excludedIdentifiers: Set<String> {
    Set([configuration?.slot1.id, configuration?.slot2.id, configuration?.slot3.id,
         configuration?.slot4.id, configuration?.slot5.id].compactMap { $0 })
  }
}
