import WidgetKit

/// Captures the immutable inputs needed to render one archived timeline entry.
struct HabitWidgetConfiguredEntry: TimelineEntry {
  let date: Date
  let snapshot: HabitWidgetSnapshot?
  let selections: [String?]
  let slotCount: Int

  // Capture native display state with the snapshot, before WidgetKit archives
  // the entry. Rendering must not read a newer/different shared state.
  let holds: [String: HabitWidgetHold]
  /// Resolves rows using only the state captured by this entry.
  var slots: [HabitWidgetSlot] {
    HabitWidgetSlots.resolve(snapshot: snapshot, selections: selections, count: slotCount,
                            at: date, retainedCompletions: Set(holds.keys))
  }
}

/// Builds configuration-aware timelines from shared read-only state.
struct HabitWidgetConfiguredProvider: AppIntentTimelineProvider {
  /// Produces an immediate entry for the system placeholder surface.
  func placeholder(in context: Context) -> HabitWidgetConfiguredEntry {
    entry(HabitWidgetConfiguration(), context: context, at: .now)
  }
  /// Captures the current state for the widget gallery or editor.
  func snapshot(for configuration: HabitWidgetConfiguration, in context: Context) async -> HabitWidgetConfiguredEntry {
    entry(configuration, context: context, at: .now)
  }
  /// Schedules current and civil-boundary entries with a periodic refresh request.
  func timeline(for configuration: HabitWidgetConfiguration, in context: Context) async -> Timeline<HabitWidgetConfiguredEntry> {
    let now = Date()
    let current = entry(configuration, context: context, at: now)
    var entries = [current]
    var refresh = now.addingTimeInterval(30 * 60)
    if let nextDay = current.snapshot?.nextDay, nextDay > now {
      entries.append(HabitWidgetConfiguredEntry(date: nextDay, snapshot: current.snapshot,
        selections: current.selections, slotCount: current.slotCount, holds: [:]))
      refresh = min(refresh, nextDay)
    }
    // Manual advancement: no second-scale entry or Undo deadline.
    return Timeline(entries: entries, policy: .after(refresh))
  }
  /// Reads the snapshot before capturing the presentation identities it validates.
  private func entry(_ configuration: HabitWidgetConfiguration, context: Context, at date: Date) -> HabitWidgetConfiguredEntry {
    let snapshot = HabitWidgetShared.readSnapshot()
    let holds = HabitWidgetHoldStore().validHolds(snapshot: snapshot, at: date)
    let count: Int
    switch context.family {
    case .systemSmall: count = 1
    case .systemLarge: count = 6
    default: count = 3
    }
    return HabitWidgetConfiguredEntry(date: date, snapshot: snapshot,
      selections: Array(configuration.selections.prefix(count)), slotCount: count,
      holds: holds)
  }
}
