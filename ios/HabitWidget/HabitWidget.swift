import SwiftUI
import WidgetKit

struct HabitWidgetEntry: TimelineEntry {
  let date: Date
  let snapshot: HabitWidgetSnapshot?
}

struct HabitWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> HabitWidgetEntry { .preview }

  func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
    completion(context.isPreview ? .preview : HabitWidgetEntry(date: .now, snapshot: HabitWidgetShared.readSnapshot()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void) {
    let now = Date()
    let snapshot = HabitWidgetShared.readSnapshot()
    var entries = [HabitWidgetEntry(date: now, snapshot: snapshot)]
    var refresh = now.addingTimeInterval(30 * 60)
    if let nextDay = snapshot?.nextDay, nextDay > now {
      // Rendering this entry disables yesterday's actions even when the app has
      // not run since midnight. Never invent completion data for the new day.
      entries.append(HabitWidgetEntry(date: nextDay, snapshot: snapshot))
      refresh = min(refresh, nextDay)
    }
    completion(Timeline(entries: entries, policy: .after(refresh)))
  }
}

@main
struct HabitWidget: Widget {
  let kind = HabitWidgetShared.kind

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: HabitWidgetProvider()) { entry in
      HabitWidgetView(entry: entry)
        .containerBackground(for: .widget) { WidgetCanvas() }
    }
    .configurationDisplayName("Table Habit")
    .description("Your habits today, one small step at a time.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

private struct WidgetCanvas: View {
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    (colorScheme == .dark ? Color(red: 0.055, green: 0.09, blue: 0.085) : Color(red: 0.97, green: 0.98, blue: 0.965))
  }
}

struct HabitWidgetView: View {
  let entry: HabitWidgetEntry
  @Environment(\.widgetFamily) private var family

  var body: some View {
    content.environment(\.locale, entry.snapshot?.widgetLocale ?? .current)
  }

  @ViewBuilder
  private var content: some View {
    if let snapshot = entry.snapshot, !snapshot.habits.isEmpty {
      let current = snapshot.isCurrent(at: entry.date)
      if family == .systemSmall {
        SingleHabitView(snapshot: snapshot, current: current)
      } else {
        TodayHabitsView(snapshot: snapshot, current: current)
      }
    } else {
      WidgetEmptyView(snapshot: entry.snapshot)
    }
  }
}

private struct SingleHabitView: View {
  let snapshot: HabitWidgetSnapshot
  let current: Bool

  var body: some View {
    if let habit = snapshot.habits.first {
      VStack(alignment: .leading, spacing: 8) {
        WidgetHeading(title: current
          ? snapshot.text("today", fallback: String(localized: "Today"))
          : snapshot.nativeText("New day"))
        Text(habit.name)
          .font(.system(.headline, design: .rounded, weight: .bold))
          .lineLimit(2)
          .minimumScaleFactor(0.8)
          .frame(maxWidth: .infinity, alignment: .leading)
        Spacer(minLength: 0)
        HabitWeekGrid(habit: habit, labels: true)
        if current {
          HabitActionButton(habit: habit, snapshot: snapshot, compact: false)
        } else {
          WidgetRefreshButton(snapshot: snapshot, compact: false)
        }
      }
    }
  }
}

private struct TodayHabitsView: View {
  let snapshot: HabitWidgetSnapshot
  let current: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 9) {
      HStack {
        WidgetHeading(title: current
          ? snapshot.text("today", fallback: String(localized: "Today"))
          : snapshot.nativeText("New day"))
        Spacer()
        if current {
          Text("\(snapshot.habits.filter(\.completed).count)/\(snapshot.habits.count)")
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .foregroundStyle(.secondary)
            .monospacedDigit()
        } else {
          WidgetRefreshButton(snapshot: snapshot, compact: true)
        }
      }
      ForEach(Array(snapshot.habits.prefix(3))) { habit in
        HStack(spacing: 10) {
          RoundedRectangle(cornerRadius: 2)
            .fill(habit.tint)
            .frame(width: 3, height: 25)
            .widgetAccentable()
          Text(habit.name)
            .font(.system(.subheadline, design: .rounded, weight: .semibold))
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
          HabitWeekGrid(habit: habit, labels: false)
            .frame(width: 89)
          if current {
            HabitActionButton(habit: habit, snapshot: snapshot, compact: true)
          } else {
            Image(systemName: "clock")
              .foregroundStyle(.tertiary)
              .frame(width: 28, height: 28)
              .accessibilityLabel("Refresh to see today's progress")
          }
        }
        .frame(maxHeight: .infinity)
      }
      if snapshot.habits.count < 3 { Spacer(minLength: 0) }
    }
  }
}

private struct WidgetHeading: View {
  let title: String

  var body: some View {
    HStack(spacing: 5) {
      Image(systemName: "square.grid.2x2.fill")
        .font(.system(size: 9, weight: .bold))
      Text(title.uppercased())
        .font(.system(size: 10, weight: .bold, design: .rounded))
        .tracking(1.3)
    }
    .foregroundStyle(.secondary)
    .accessibilityElement(children: .combine)
  }
}

private struct HabitWeekGrid: View {
  let habit: HabitWidgetHabit
  let labels: Bool
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.locale) private var locale

  var body: some View {
    HStack(spacing: labels ? 4 : 3) {
      ForEach(Array(habit.sevenDays.suffix(7).enumerated()), id: \.offset) { _, day in
        VStack(spacing: 4) {
          RoundedRectangle(cornerRadius: labels ? 4 : 2.5)
            .fill(day.boundedProgress > 0
              ? habit.tint.opacity(0.3 + day.boundedProgress * 0.7)
              : Color.primary.opacity(colorScheme == .dark ? 0.14 : 0.08))
            .aspectRatio(1, contentMode: .fit)
            .widgetAccentable(day.boundedProgress > 0)
          if labels {
            Text(dayLabel(day.date))
              .font(.system(size: 8, weight: .medium, design: .rounded))
              .foregroundStyle(.secondary)
          }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(day.date)
        .accessibilityValue("\(Int(day.boundedProgress * 100))%")
      }
    }
  }

  private func dayLabel(_ day: String) -> String {
    let parser = DateFormatter()
    parser.locale = Locale(identifier: "en_US_POSIX")
    parser.calendar = Calendar(identifier: .gregorian)
    parser.dateFormat = "yyyy-MM-dd"
    guard let date = parser.date(from: day) else { return "" }
    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.setLocalizedDateFormatFromTemplate("EEEEE")
    return formatter.string(from: date)
  }
}

private struct HabitActionButton: View {
  @Environment(\.colorScheme) private var colorScheme

  let habit: HabitWidgetHabit
  let snapshot: HabitWidgetSnapshot
  let compact: Bool

  private var action: HabitWidgetAction? {
    if habit.canComplete { return .complete }
    return habit.canUndo ? .undo : nil
  }

  private var title: String {
    snapshot.text(action == .undo ? "undo" : "complete", fallback: action == .undo
      ? String(localized: "Undo") : String(localized: "Complete"))
  }

  var body: some View {
    if let action {
      Button(intent: HabitWidgetActionIntent(habit: habit, day: snapshot.day, action: action)) {
        HStack(spacing: 5) {
          Image(systemName: action == .undo ? "arrow.uturn.backward" : "checkmark")
            .font(.system(size: compact ? 12 : 10, weight: .bold))
          if !compact {
            Text(title)
              .font(.system(size: 11, weight: .semibold, design: .rounded))
              .lineLimit(1)
              .minimumScaleFactor(0.7)
          }
        }
        .foregroundStyle(colorScheme == .dark ? Color.primary : habit.tint)
        .frame(maxWidth: compact ? nil : .infinity)
        .frame(width: compact ? 28 : nil, height: 28)
        .background(habit.tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 9))
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .accessibilityLabel("\(title): \(habit.name)")
      .invalidatableContent()
    } else {
      Text(habit.completed ? "✓" : "\(Int(habit.boundedProgress * 100))%")
        .font(.system(.caption, design: .rounded, weight: .semibold))
        .foregroundStyle(colorScheme == .dark ? Color.primary : habit.tint)
        .frame(maxWidth: compact ? nil : .infinity)
        .frame(width: compact ? 28 : nil, height: 28)
        .accessibilityLabel(habit.name)
        .accessibilityValue("\(Int(habit.boundedProgress * 100))%")
    }
  }
}

private struct WidgetRefreshButton: View {
  let snapshot: HabitWidgetSnapshot
  let compact: Bool

  var body: some View {
    Button(intent: HabitWidgetActionIntent()) {
      Label(snapshot.nativeText("Refresh"), systemImage: "arrow.clockwise")
        .font(.system(size: 11, weight: .semibold, design: .rounded))
        .foregroundStyle(.primary)
        .frame(maxWidth: compact ? nil : .infinity)
        .frame(height: compact ? 20 : 28)
        .padding(.horizontal, compact ? 6 : 0)
        .background(Color.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
    .buttonStyle(.plain)
    .accessibilityLabel(snapshot.nativeText("Refresh to see today's progress"))
    .invalidatableContent()
  }
}

private struct WidgetEmptyView: View {
  let snapshot: HabitWidgetSnapshot?

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      WidgetHeading(title: "Table Habit")
      Spacer(minLength: 0)
      Image(systemName: "square.grid.3x3")
        .font(.system(size: 25, weight: .light))
        .foregroundStyle(.secondary)
      Text(snapshot?.text("empty", fallback: String(localized: "A little progress, every day."))
        ?? String(localized: "A little progress, every day."))
        .font(.system(.subheadline, design: .rounded, weight: .semibold))
        .lineLimit(2)
      if let snapshot {
        WidgetRefreshButton(snapshot: snapshot, compact: false)
      } else {
        Text("Open Table Habit to get started")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private extension HabitWidgetHabit {
  var tint: Color {
    Color(.sRGB, red: Double((color >> 16) & 255) / 255,
      green: Double((color >> 8) & 255) / 255,
      blue: Double(color & 255) / 255, opacity: 1)
  }
}

private extension HabitWidgetSnapshot {
  var widgetLocale: Locale {
    strings?["locale"].map { Locale(identifier: $0) } ?? .current
  }

  func nativeText(_ key: String) -> String {
    let language = widgetLocale.language.languageCode?.identifier ?? "en"
    let path = Bundle.main.path(forResource: language, ofType: "lproj")
      ?? Bundle.main.path(forResource: "en", ofType: "lproj")
    let bundle = path.flatMap(Bundle.init(path:)) ?? .main
    return bundle.localizedString(forKey: key, value: key, table: nil)
  }
}

extension HabitWidgetEntry {
  static var preview: HabitWidgetEntry {
    let calendar = Calendar(identifier: .gregorian)
    let now = Date()
    let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
    let history = (0..<7).map { offset in
      HabitWidgetDay(date: HabitWidgetSnapshot.dayString(calendar.date(byAdding: .day, value: offset - 6, to: now)!),
        progress: [1.0, 0.5, 1, 0, 1, 1, 0][offset])
    }
    let habits = [
      HabitWidgetHabit(id: "preview-read", name: String(localized: "Read a little"), color: 0xFF2D9B83,
        completed: false, progress: 0, canComplete: true, canUndo: false, expectedRecord: "preview", sevenDays: history),
      HabitWidgetHabit(id: "preview-walk", name: String(localized: "Go for a walk"), color: 0xFFD18C44,
        completed: true, progress: 1, canComplete: false, canUndo: true, expectedRecord: "preview", sevenDays: history),
      HabitWidgetHabit(id: "preview-focus", name: String(localized: "Make time to focus"), color: 0xFF7D81C9,
        completed: false, progress: 0, canComplete: true, canUndo: false, expectedRecord: "preview", sevenDays: history)
    ]
    return HabitWidgetEntry(date: now, snapshot: HabitWidgetSnapshot(version: 1,
      generatedAt: ISO8601DateFormatter().string(from: now), day: HabitWidgetSnapshot.dayString(now),
      nextDayAt: ISO8601DateFormatter().string(from: nextDay), habits: habits, strings: nil))
  }
}

#Preview(as: .systemSmall) { HabitWidget() } timeline: { HabitWidgetEntry.preview }
#Preview(as: .systemMedium) { HabitWidget() } timeline: { HabitWidgetEntry.preview }
