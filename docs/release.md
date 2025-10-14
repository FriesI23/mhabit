<!-- markdownlint-disable MD036 -->
<!--
Title: Pre-Released or Released: v1.2.3+xx
-->

# Pre-Released: v1.18.0

## v1.18.0-pre.2+104

**🧹 Others**

- Fix App Sync Form to Keep Local Password on UI Changes (#368)
- Refactor Habit Status Changer Structure and Logic (#369)
- Refactor Habit Summary Structure and Logic (#370)
- Refactor Miscellaneous Code Cleanup (#371)
  - Move Habit Status Changer Dispatcher Back to ViewModel
  - Decouple Providers from Material and Widgets
  - Decouple Models from Material and Widgets
- Refactor Separate UI Logic (#372)
  - Replace Material and Widgets Exports with Specific Imports
  - Separate Scroll Behavior Logic from ViewModel
  - Separate Material Theme Logic from ViewModel
  - Separate ShowDialog from ViewModel
- Refactor Move onDailyGoalTextInputChanged to Habit Input Helper
- Refactor Habit Data Flow with Dispatcher (#374)

## v1.18.0-pre.1+103

**🌐 Localization**

- Updated Ukrainian translation, thank to Максим Горпиніч's contribution on Weblate.

**🧹 Others**

- Numbers changes can be saved on iOS/iPadOS (#351)
- Adjusted project code directory structure (#353)
- Refactored App Sync Server Form with MVVM architecture (#364)
- Refactored Habit Form with MVVM architecture (#366)
- [Github Action]: Added pre-release cleanup CI for app release
