import SwiftUI
import WidgetKit

/// Registers the native widget and its supported configuration families.
@main
struct HabitWidget: Widget {
  let kind = HabitWidgetShared.kind

  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind, intent: HabitWidgetConfiguration.self,
      provider: HabitWidgetConfiguredProvider()) { entry in
      HabitWidgetConfiguredView(entry: entry)
        .containerBackground(for: .widget) { WidgetCanvas() }
    }
    .configurationDisplayName("Table Habit")
    .description("Your habits today, one small step at a time.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}
