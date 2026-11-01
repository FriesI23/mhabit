# Pre-Released: v1.27.17+206

Table Habit now supports iOS Home Screen widgets! Thanks to
[@IlyaPalochkin](https://github.com/IlyaPalochkin) for contributing the initial
interactive widgets (#680).

## ✨ Features

- Add interactive Home Screen widgets for iOS 17+, with seven-day progress and
  check-in, undo and refresh actions without opening the app (#680)
- Choose automatic or fixed habits, including archived habits; fixed habits
  appear first. Small, medium and large widgets show up to one, three and six
  habits respectively (#687)
- Keep automatic check-ins visible until tapping **Next** to show another habit;
  widgets on the same device share check-in and Next updates. Fixed habits stay
  visible with Undo. Show a completion message when all goals are complete, or
  **No pending habits** when incomplete or skipped goals leave no rows (#687)
- Mark ordinary habits incomplete with **Missed**, distinguish ordinary and
  negative habit record states, and display labels in the app language (#687)

## 🐛 Fixes

- Improve foldable-screen layouts: fit dialogs, sheets and date/time pickers to
  the selected screen area, and place confirmations in the right or lower area
  (#691)
- Keep toolbars, sidebars, search and floating controls clear of window controls
  (#691)
- Preserve navigation state across safe-area changes and fix Material
  localization reloads (#691)

## 🧹 Others

- Standardize Swift formatting and add formatting checks to local and CI
  workflows (#688)
- Update adaptive UI dependencies and select stable Xcode 27.x in CI (#691)
- Refresh Apple build dependency locks
- Update contributor credits

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.27.15+204...pre-v1.27.17+206)
