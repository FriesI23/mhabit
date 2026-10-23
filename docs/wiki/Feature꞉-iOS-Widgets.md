<!-- markdownlint-disable no-inline-html first-line-heading -->

Table Habit provides small, medium, and large Home Screen widgets on iOS 17 or
later.

### Add a Widget

1. Open Table Habit once and create or import your habits.
2. Touch and hold an empty area of the Home Screen, then open the widget gallery.
3. Find Table Habit, choose the small, medium, or large size, and add it.

### Choose Habits

Touch and hold the widget and choose **Edit Widget**. Configure up to one habit
for the small size, three for medium, or six for large. Each choice, labeled
**Habit 1**, **Habit 2**, and so on, defaults to **Automatic**, which shows an
unfinished habit, or you can choose a specific habit.

Fixed habits appear first in configuration order, followed by automatic habits.
Only the choices available for the current size are used. Fixed habits stay
visible, including archived habits and completed habits with Undo. Habits that
have not started are visible but cannot be checked in.

When fewer habits are available, the list starts at the top and leaves the rest
empty. An all-automatic widget shows one centered completion message after
today's habits are complete and no completed habit is still waiting for Next.
The header count still covers all started, active habits.

### Complete and Undo

Tap the checkmark or **Done** to complete today's goal without opening the app.
Tap **Undo** to remove today's check-in. Use the app to enter a custom value.

After completing an automatic habit, use **Next** to show another habit.
Next advances only that habit and preserves its completed check-in. Automatic
widgets on this device share that completion display, so Undo or Next also
updates the other widgets.

### Refresh and Limitations

Tap **Refresh** after midnight or a time-zone change to load the current day.
Widget labels follow the app language, with English as the fallback. System
configuration titles follow the system language.

- Widget refreshes are scheduled by iOS and may be delayed.
- Widget selections stay on this device.
- Skipped days cannot be completed or undone from the widget.
- Widget changes sync through the app's usual WebDAV workflow, rather than
  starting a sync on every tap.

For building and testing widgets, see [Developing iOS Widgets][developer-guide].

<!-- refs -->

[developer-guide]: ./Dev꞉-iOS-Widgets
