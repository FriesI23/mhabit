<!-- markdownlint-disable no-inline-html first-line-heading -->

Table Habit provides small and medium Home Screen widgets on iOS 17 or later.
The main app still supports iOS 15.

## Add a Widget

1. Open Table Habit once and create or import your habits.
2. Touch and hold an empty area of the Home Screen, then open the widget gallery.
3. Find Table Habit, choose the small or medium size, and add it.

The small widget shows the first active habit in stored order. The medium widget
shows the first three. Habits whose start date is in the future are excluded.
Each row includes the last seven days, including today.

## Complete and Undo

Tap the checkmark or **Done** button to complete today's configured goal without
opening the app interface. Both widget sizes refresh after the change. A completed
habit stays visible, and its button changes to **Undo** to remove today's check-in.

Numeric habits are completed to their configured goal, including negative habits.
Use the app to enter a custom value. A partially completed numeric habit can still
be completed from the widget; the button then changes to Undo.

The medium widget's counter includes all eligible active habits, including those
beyond the three visible rows. A partial value does not count as a completed goal.

## Refresh and Language

After midnight or a time-zone change, a stale widget offers **Refresh** to load
the current day. Tapping an outdated check-in button refreshes the data instead
of changing a different day's record or overwriting a newer check-in.

Widgets refresh when the app's data, language, or date changes. Common labels
follow the app language; widget-specific labels support English, Russian,
Simplified Chinese, and Traditional Chinese, with English as the fallback.

## Current Limitations

- Habits cannot be selected separately for each widget. Selection follows stored
  habit order, and completing a habit does not automatically show the next one.
- Edit habit names, goals, and custom check-in values in the app.
- Skipped days cannot be completed or undone from the widget.
- Widget changes use the existing WebDAV sync workflow when the app next runs it;
  tapping a widget does not immediately start a WebDAV sync.

## Examples

These captures use the same three sample habits. The small widget shows
**Read a little**, while the medium widget shows all three.

### Before Completion

No daily goal is complete (0/3). **Go for a walk** has partial progress, 10/30.

![Small and medium widgets before completion, showing 0 of 3 goals][before]

### After Completion

Completing **Read a little** updates both sizes and changes the counter to 1/3.
Today's square fills in, and the button becomes Undo.

![Both widget sizes after completing Read a little, showing 1 of 3 goals][completed]

### Dark Appearance

Both sizes also support dark appearance. This example shows all three goals
complete (3/3).

![Small and medium widgets in dark appearance, showing 3 of 3 goals][dark]

For build configuration, architecture, and verification, see
[Developing iOS Widgets][developer-guide].

<!-- refs -->

[before]: images/ios-widgets/01-home-light-before.jpg
[completed]: images/ios-widgets/02-home-light-completed.jpg
[dark]: images/ios-widgets/03-home-dark.jpg
[developer-guide]: ./Dev꞉-iOS-Widgets
