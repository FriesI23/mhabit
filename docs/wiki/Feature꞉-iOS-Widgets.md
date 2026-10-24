<!-- markdownlint-disable no-inline-html first-line-heading -->

Table Habit provides small, medium, and large Home Screen widgets on iOS 17 or
later.

### Add a Widget

1. Open Table Habit once and create or import your habits.
2. Touch and hold an empty area of the Home Screen, then open the widget gallery.
3. Find Table Habit, choose the small, medium, or large size, and add it.

### Choose Habits

Touch and hold the widget and choose **Edit Widget**. Small widgets show one
habit, medium three, and large six.

Choose **Automatic** or a fixed habit. Fixed habits appear first and stay visible
after check-in. Archived habits can be selected; habits that have not started
cannot be checked in.

### Complete and Undo

Tap **Done** to complete today's goal, **Missed** to record an ordinary habit
as incomplete, or **Undo** to remove today's check-in. Use the app for custom
values. Negative habits show their goal status instead of Missed.

For automatic habits, tap **Next** after check-in to show another habit while
keeping the record. There is no Undo countdown. Fixed habits keep Undo and do not
offer Next. Widgets on this device share Undo and Next updates.

For ordinary habits, zero-value records count as handled but incomplete. When no
habits remain displayed, incomplete or skipped goals show **No pending habits**
instead of a completion message.

### Refresh and Limitations

Tap **Refresh** after midnight or a time-zone change to load the current day.
Widget labels follow the app language. Refreshes are scheduled by iOS and may
be delayed.

### Examples

| Before check-in   | After check-in      | Dark appearance    |
| ----------------- | ------------------- | ------------------ |
| ![Before][before] | ![After][completed] | ![Dark mode][dark] |

For building and testing widgets, see [Developing iOS Widgets][developer-guide].

<!-- refs -->

[before]: images/ios-widgets/01-home-light-before.jpg
[completed]: images/ios-widgets/02-home-light-completed.jpg
[dark]: images/ios-widgets/03-home-dark.jpg
[developer-guide]: ./Dev꞉-iOS-Widgets
