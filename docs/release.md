# Released: v1.22.0+123-pre

**✨ New Features**

- Feature: Add Today Mode
  - Add “Today Mode” — a clean, minimal UI for habit tracking
  - Support bottom navigation bar to switch between views (today / habits)
  - Habit Today supports both card and grid layouts
  - Persist selected tab across app launches

**🌐 Localization**

- Update Hebrew translation, thanks to sudo-py-dev's contribution on Weblate

**🧹 Others**

- Fixed: Use `MediaQuery.sizeOf(context)` for responsive layout sizing
- Fixed: Apply UI logic cleanup and fixes from code review feedback
- Fixed: Ensure Today page refreshes correctly when the date changes