import Foundation

/// Identifies how a rendered row acquired its selected entity.
enum HabitWidgetSource: String, Codable, CaseIterable, Sendable {
  case automatic, fixed
}

/// Distinguishes the presentation states of an unoccupied slot.
enum HabitWidgetEmptyState: String {
  case completed, noPending, noHabits, loading, refresh
}

/// Describes one resolved row without retaining mutable shared state.
struct HabitWidgetSlot {
  let source: HabitWidgetSource
  let habit: HabitWidgetHabit?
  let empty: HabitWidgetEmptyState?
}

/// Resolves visible selections into a deterministic, fixed-first list.
///
/// ```text
/// visible selections -> fixed habits in selection order -> automatic habits
///                                                               |
///                                                    stable snapshot order
/// ```
enum HabitWidgetSlots {
  /// Packs fixed selections first, then fills capacity without duplicates.
  static func resolve(snapshot: HabitWidgetSnapshot?, selections: [String?], count: Int,
                      at date: Date, retainedCompletions: Set<String> = []) -> [HabitWidgetSlot] {
    guard let snapshot else {
      return (0..<count).map { _ in HabitWidgetSlot(source: .automatic, habit: nil, empty: .loading) }
    }
    guard snapshot.isCurrent(at: date) else {
      return (0..<count).map { _ in HabitWidgetSlot(source: .automatic, habit: nil, empty: .refresh) }
    }
    let empty: HabitWidgetEmptyState = snapshot.activeCount == 0 ? .noHabits
      : snapshot.completedCount == snapshot.activeCount ? .completed : .noPending
    var reserved = Set<String>()
    var rows = selections.prefix(count).compactMap { selection -> HabitWidgetSlot? in
      guard let id = selection, id != HabitWidgetShared.automaticSelectionID else { return nil }
      guard reserved.insert(id).inserted else { return nil }
      if let habit = snapshot.catalog.first(where: { $0.id == id }) {
        return HabitWidgetSlot(source: .fixed, habit: habit, empty: nil)
      }
      // A partial/legacy directory cannot establish deletion. Keep this choice
      // unavailable until a complete, current directory can safely fall back.
      return snapshot.hasCompleteCatalog ? nil : HabitWidgetSlot(source: .fixed, habit: nil, empty: .loading)
    }
    var used = Set(rows.compactMap { $0.habit?.id })
    let candidates = snapshot.catalog.filter {
      $0.automaticEligible && ($0.automaticPending || retainedCompletions.contains($0.id))
    }
    while rows.count < count {
      let habit = candidates.first { !used.contains($0.id) }
      if let habit { used.insert(habit.id) }
      rows.append(HabitWidgetSlot(source: .automatic, habit: habit, empty: habit == nil ? empty : nil))
    }
    return rows
  }
}
