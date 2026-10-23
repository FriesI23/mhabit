import SwiftUI
import WidgetKit

/// Renders an archived entry using its captured locale and layout direction.
struct HabitWidgetConfiguredView: View {
  let entry: HabitWidgetConfiguredEntry
  var body: some View {
    content.environment(\.locale, entry.snapshot?.widgetLocale ?? .current)
      .environment(\.layoutDirection, (entry.snapshot?.widgetLocale ?? .current).language.characterDirection == .rightToLeft ? .rightToLeft : .leftToRight)
  }

  /// Selects the current, expired or unavailable snapshot presentation.
  @ViewBuilder private var content: some View {
    if let snapshot = entry.snapshot {
      if !snapshot.isCurrent(at: entry.date) {
        VStack(alignment: .leading, spacing: 10) {
          WidgetHeading(title: snapshot.text(.newDay))
          Spacer(minLength: 0)
          Text(snapshot.text(.refreshHint)).font(.caption)
          WidgetRefreshButton(snapshot: snapshot, compact: false)
        }
      } else if entry.slotCount == 1 {
        small(snapshot)
      } else {
        list(snapshot)
      }
    } else {
      WidgetLoadingView()
    }
  }

  /// Composes the single-row widget presentation.
  private func small(_ snapshot: HabitWidgetSnapshot) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      WidgetHeading(title: snapshot.text(.today))
      if let slot = entry.slots.first, let habit = slot.habit {
        Text(habit.name).font(.system(.headline, design: .rounded, weight: .bold))
          .lineLimit(2).minimumScaleFactor(0.8).frame(maxWidth: .infinity, alignment: .leading)
        Spacer(minLength: 0)
        HabitWeekGrid(habit: habit, labels: true)
        HabitWidgetConfiguredControls(habit: habit, snapshot: snapshot, source: slot.source,
          hold: entry.holds[habit.id], compact: false)
      } else {
        let state = entry.slots.first?.empty ?? .noHabits
        HabitWidgetEmptyView(state: state, snapshot: snapshot)
        if state != .completed { WidgetRefreshButton(snapshot: snapshot, compact: false) }
      }
    }
  }

  /// Shares the medium/large row layout, leaving unused capacity at the bottom.
  private func list(_ snapshot: HabitWidgetSnapshot) -> some View {
    let slots = entry.slots
    let isEmpty = slots.allSatisfy { $0.habit == nil }
    return VStack(alignment: .leading, spacing: 9) {
      HStack {
        WidgetHeading(title: snapshot.text(.today))
        Spacer()
        Text("\(snapshot.completedCount)/\(snapshot.activeCount)")
          .font(.system(.caption, design: .rounded, weight: .semibold)).foregroundStyle(.secondary).monospacedDigit()
      }
      if isEmpty {
        HabitWidgetEmptyView(state: slots.first?.empty ?? .noHabits, snapshot: snapshot)
      } else {
        ForEach(Array(slots.enumerated()), id: \.offset) { _, slot in
          HStack(spacing: 9) {
            if let habit = slot.habit {
              RoundedRectangle(cornerRadius: 2).fill(habit.tint).frame(width: 3, height: 25).widgetAccentable()
              VStack(alignment: .leading, spacing: 2) {
                Text(habit.name).font(.system(.subheadline, design: .rounded, weight: .semibold)).lineLimit(1)
              }.frame(maxWidth: .infinity, alignment: .leading)
              HabitWeekGrid(habit: habit, labels: false).frame(width: 89)
              HabitWidgetConfiguredControls(habit: habit, snapshot: snapshot, source: slot.source,
                hold: entry.holds[habit.id], compact: true)
            } else if slot.source == .fixed {
              // An incomplete catalog cannot establish that a saved choice was
              // deleted. Keep its loading status instead of claiming completion.
              Text((slot.empty ?? .noPending).message(snapshot)).font(.caption2).foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
              Color.clear.accessibilityHidden(true)
            }
          }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
    }
  }
}

/// Presents one centered message for the entire available widget body.
private struct HabitWidgetEmptyView: View {
  let state: HabitWidgetEmptyState
  let snapshot: HabitWidgetSnapshot

  var body: some View {
    VStack(spacing: 8) {
      if state == .completed {
        Image(systemName: "checkmark.circle").font(.system(size: 28, weight: .regular))
          .accessibilityHidden(true)
      }
      Text(state.message(snapshot))
        .font(.system(.subheadline, design: .rounded, weight: .semibold))
        .multilineTextAlignment(.center).lineLimit(3)
    }
    .foregroundStyle(.secondary)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
  }
}

/// Maps captured capabilities to independently accessible intent controls.
private struct HabitWidgetConfiguredControls: View {
  let habit: HabitWidgetHabit
  let snapshot: HabitWidgetSnapshot
  let source: HabitWidgetSource
  let hold: HabitWidgetHold?
  let compact: Bool
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.layoutDirection) private var direction

  var body: some View {
    if habit.canComplete {
      button(.complete)
    } else if habit.canUndo && (source == .fixed || hold != nil) {
      HStack(spacing: 5) {
        button(.undo)
        if source == .automatic, hold != nil { button(.next) }
      }
    } else {
      Text(status).font(.system(size: compact ? 9 : 11, weight: .medium, design: .rounded))
        .foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.7)
        .frame(maxWidth: compact ? nil : .infinity).frame(width: compact ? 45 : nil, height: 28)
        .accessibilityLabel("\(habit.name): \(status)")
    }
  }

  /// Supplies a localized description when no executable control is available.
  private var status: String {
    if !habit.started { return snapshot.text(.notStarted) }
    if habit.skipped { return snapshot.text(.skipped) }
    if habit.state == .unknown { return snapshot.text(.unavailable) }
    return habit.completed ? snapshot.text(.completed) : "\(Int(habit.boundedProgress * 100))%"
  }

  /// Builds one control carrying the displayed version and optional identity.
  private func button(_ action: HabitWidgetAction) -> some View {
    let title = action == .next ? snapshot.text(.next)
      : snapshot.text(action == .undo ? .undo : .complete)
    let icon = action == .next ? (direction == .rightToLeft ? "chevron.left" : "chevron.right") : action == .undo ? "arrow.uturn.backward" : "checkmark"
    return Button(intent: HabitWidgetActionIntent(habit: habit, day: snapshot.day,
      action: action, source: source, holdIdentity: source == .automatic ? hold?.identity : nil)) {
      HStack(spacing: 4) {
        Image(systemName: icon).font(.system(size: compact ? 12 : 10, weight: .bold))
        if !compact { Text(title).font(.system(size: 11, weight: .semibold, design: .rounded)).lineLimit(1).minimumScaleFactor(0.7) }
      }
      .foregroundStyle(colorScheme == .dark ? Color.primary : habit.tint)
      .frame(maxWidth: compact ? nil : .infinity).frame(width: compact ? 28 : nil, height: 28)
      .background(habit.tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 9)).contentShape(Rectangle())
    }
    .buttonStyle(.plain).accessibilityLabel("\(title): \(habit.name)")
      .accessibilityHint(action == .next ? snapshot.text(.nextHint) : "")
      .invalidatableContent()
  }
}

private extension HabitWidgetEmptyState {
  /// Resolves the native message using the captured app language.
  func message(_ snapshot: HabitWidgetSnapshot) -> String {
    switch self {
    case .completed: return snapshot.text(.allDone)
    case .noPending: return snapshot.text(.noPending)
    case .noHabits: return snapshot.text(.noHabits)
    case .loading: return snapshot.text(.openApp)
    case .refresh: return snapshot.text(.refreshHint)
    }
  }
}
