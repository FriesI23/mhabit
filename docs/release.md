<!-- markdownlint-disable MD036 -->
<!--
Title: Pre-Released or Released: v1.2.3+xx
-->

# Pre-Released: v1.19.0+107-pre

**✨ New Features**

- Feature: Quick Search (#385)
  - Added an experimental feature switch
  - Added a new search bar
  - Added a flexible UI layout
  - Improved UI refresh logic to ensure the state updates correctly
  - Separated the calendar bar from the main view
  - Removed RouteAware to simplify route management
- Cleanup: Removed App Sync experimental feature switch (#386)

**🌐 Localization**

- Update Turkish translation, thanks to Soykan Aydın's contributions on Weblate

**🧹 Others**

- Refactor: Moved App Sync experimental feature switches to a separate provider (#381)
- Refactor: Extracted AppBar build logic from the main page (#382)
- Fix: Skip redundant data loading on the `Habit Display` page (#383)
- Fix: Rebuilt `ColorScheme.fromSeed` when dynamic colors are active (#384)
- Chore: Bumped dependency versions
