import SwiftUI
import WidgetKit

/// Registers the native widget and its supported configuration families.
@main
struct HabitWidget: Widget {
  let kind = HabitWidgetShared.kind

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: HabitWidgetConfiguration.self,
      provider: HabitWidgetConfiguredProvider(),
    ) { entry in
      HabitWidgetConfiguredView(entry: entry)
        .containerBackground(for: .widget) { WidgetCanvas() }
    }
    .configurationDisplayName("Table Habit")
    .description(
      Text(
        verbatim: HabitWidgetShared.readSnapshot()?.text(.galleryDescription)
          ?? HabitWidgetText.galleryDescription.localized()
      )
    )
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}
