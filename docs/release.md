<!-- markdownlint-disable MD036 -->
<!--
Title: Pre-Released or Released: v1.2.3+xx
-->

# Pre-Released: v1.20.1+114-pre

**🌐 Localization**

- Updated Ukrainian translation, thank to maksim2005UKR's contribution on Weblate.
- Updated Russian F-Droid description translation, thanks to an anonymous contribution on Weblate.

**🧹 Others**

- Fix: Prevent dispatcher reuse across layout/size changes
- Refactor: Adopt new ViewModel call/invocation pattern (#405)
  - Migrate habit_status_changer to habit_manager
  - Migrate habit_edit to habit_manager
  - Migrate import/export to habit_manager
  - Replace status flags with event_bus pattern
- Refactor: Enforce widget-local ViewModel boundaries (#400)
  - Migrate habit_summary AppSync adapter to AppEvent
  - Migrate habit_summary HabitsStatusChanger adapter to AppEvent
- Refactor: Reduce Provider initialization boilerplate (#404)
- Refactor: Habit module architecture cleanup
  - Habit Status Changer (#397)
    - Move list dispatcher to UI layer
    - Switch from delegate to controller model
  - Habit Display (#398)
    - Move list dispatcher to UI layer
  - Habit Summary ViewModel (#401)
    - Move habit_summary logic to habit_manager
    - Clarify responsibility boundaries
    - Unify/rename APIs: change_habit_status, change_record_status, change_record_value, etc.
    - Remove unused statuses
  - Habit Detail ViewModel (#403)
    - Move habit_detail logic to habit_manager
    - Clarify responsibility boundaries
    - Unify/rename VM APIs: change_habit_status, change_record_status, change_record_value, etc.
    - Decouple Habit Detail ViewModel dependencies
    - Remove unused statuses