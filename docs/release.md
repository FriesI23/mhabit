# Released: v1.22.1+124-pre

**✨ New Features**

- Feature: Add Today Mode (#418)
  - Add “Today Mode” — a clean, minimal UI for habit tracking
  - Support bottom navigation bar to switch between views (today / habits)
  - Habit Today supports both card and grid layouts
  - Persist selected tab across app launches

**🌐 Localization**

- Update Hebrew translation, thanks to sudo-py-dev's contribution on Weblate (#421)
- Add Japanese translation, thanks to the contribution from my friend shirleycrow (#423)

**🧹 Others**

- Fixed: Use `MediaQuery.sizeOf(context)` for responsive layout sizing (#418)
- Fixed: Apply UI logic cleanup and fixes from code review feedback (#418)
- Fixed: Ensure Today page refreshes correctly when the date changes (#418)
