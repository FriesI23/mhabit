<!-- markdownlint-disable no-inline-html first-line-heading -->

Following sections are based on `Android` platform.
Others will be marked separately.
Contributions to this guide are welcome via [README#Contributing][readme-contributing].

## History

- _\[2025-07-31\]_: Initialize documentation, based on [**88efd12**][commit-88efd12] with version 'v1.16.22+91'.

## "Table Habit" Screen

The "Table Habit" Screen is the default view when app launched:

![table-habit-screen-01](./images/User-Guide/table-habit-screen-01.png)

The blank area below the AppBar will display habit content after a habit is created. Other marked areas:

1. After clicking, some basic statistics will be shown.
2. Clicking allows you to expand or collapse the check-in table.
   The expanded view shows the status for more days (Collapsed by default).
3. `Setting` Button.
4. `New Habit` Button.

Once some habits are created and contain check-in information, the following details are included:

![table-habit-screen-02](./images/User-Guide/table-habit-screen-02.png)

The left circular shows the habit score progress,right side is "check-in" area.
The check-in status is divided into the following types (using `"positive habits`" as an example):

- "❔": Indicates not yet checked in. It's treated the same as "❌" (not completed) when calculating score.

1. "✔️": Habit is exactly completed.
   This means the check-in value matches the "Daily Goal" quota configured in the habit’s meta info.
   The score will be increased accordingly, based on "Target Days" number and a curve-based algorithm.
2. "❌": Habit is not completed. The check-in value remains at **0**.
3. "➖": Habit has been skipped. No score will be deducted for today.
4. "<num>" (4, 5): Means the check-in value is any other number.
   Values greater than the "Daily Goal" are considered "over-completed" and will earn additional points (up to a certain limit).
   Conversely, values below the "Daily Goal" cause partial point deductions (less than the "❌" status), also based on a penalty algorithm.

<!-- refs -->

[readme-contributing]: https://github.com/FriesI23/mhabit#contributing
[commit-88efd12]: https://github.com/FriesI23/mhabit/tree/88efd124775e6a59f9830a1e9bc36c442075c4aa
