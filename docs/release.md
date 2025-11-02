<!-- markdownlint-disable MD036 -->
<!--
Title: Pre-Released or Released: v1.2.3+xx
-->

# Pre-Released: v1.20.1+113-pre

**🌐 Localization**

- Updated Ukrainian translation, thank to maksim2005UKR's contribution on Weblate.
- Updated Russian F-Droid description translation, thanks to an anonymous contribution on Weblate.

**🧹 Others**

- Fixed: Dispatcher incorrectly reused on layout/size changes
- Refactor: `Habit Status Changer` (#397)
  - Migrate list dispatcher to UI layer
  - Switch data control from delegate to controller
- Refactor: `Habit Display` (#398)
  - Migrate list dispatcher to UI layer
- Refactor: Avoid UI depending on ViewModels from other widgets layer (#400)
  - migrate habit_summary AppSync adapter to AppEvent
  - migrate habit_summary HabitsStatusChanger adapter to AppEvent
- Refactor: Habit Summary ViewModel (#401)
  - Migrate habit_summary logic to habit_manager, refactor responsibility boundaries
  - Unify and rename APIs: change_habit_status, change_record_status, change_record_value, etc.
  - Remove unused statuses
