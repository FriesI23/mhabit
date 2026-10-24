import SwiftUI
import WidgetKit

/// Supplies the adaptive background used by the widget container.
struct WidgetCanvas: View {
  @Environment(\.colorScheme)
  private var colorScheme

  var body: some View {
    (colorScheme == .dark
      ? Color(red: 0.055, green: 0.09, blue: 0.085) : Color(red: 0.97, green: 0.98, blue: 0.965))
  }
}

/// Displays a compact heading with a combined accessibility element.
struct WidgetHeading: View {
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

/// Renders recent progress values as accessible calendar cells.
struct HabitWeekGrid: View {
  let habit: HabitWidgetHabit
  let labels: Bool
  @Environment(\.colorScheme)
  private var colorScheme
  @Environment(\.locale)
  private var locale

  var body: some View {
    HStack(spacing: labels ? 4 : 3) {
      ForEach(Array(habit.sevenDays.suffix(7).enumerated()), id: \.offset) { _, day in
        VStack(spacing: 4) {
          RoundedRectangle(cornerRadius: labels ? 4 : 2.5)
            .fill(
              day.boundedProgress > 0
                ? habit.tint.opacity(0.3 + day.boundedProgress * 0.7)
                : Color.primary.opacity(colorScheme == .dark ? 0.14 : 0.08)
            )
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

  /// Converts a wire-format date into a narrow localized weekday label.
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

/// Exposes a refresh intent using the captured app language.
struct WidgetRefreshButton: View {
  let snapshot: HabitWidgetSnapshot
  let compact: Bool

  var body: some View {
    Button(intent: HabitWidgetActionIntent()) {
      Label(snapshot.text(.refresh), systemImage: "arrow.clockwise")
        .font(.system(size: 11, weight: .semibold, design: .rounded))
        .foregroundStyle(.primary)
        .frame(maxWidth: compact ? nil : .infinity)
        .frame(height: compact ? 20 : 28)
        .padding(.horizontal, compact ? 6 : 0)
        .background(Color.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
    .buttonStyle(.plain)
    .accessibilityLabel(snapshot.text(.refreshHint))
    .invalidatableContent()
  }
}

/// Supplies the initial presentation when no valid snapshot is available.
struct WidgetLoadingView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      WidgetHeading(title: "Table Habit")
      Spacer(minLength: 0)
      ProgressView(HabitWidgetText.loading.localized())
        .font(.system(.subheadline, design: .rounded, weight: .semibold))
        .unredacted()
      Text(HabitWidgetText.openApp.localized())
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

extension HabitWidgetHabit {
  /// Converts the serialized RGB value into a native sRGB color.
  var tint: Color {
    Color(
      .sRGB,
      red: Double((color >> 16) & 255) / 255,
      green: Double((color >> 8) & 255) / 255,
      blue: Double(color & 255) / 255,
      opacity: 1,
    )
  }
}
