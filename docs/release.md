# Pre-Released: v1.27.16+205

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

## 🧹 Others

- Standardize Swift formatting and add formatting checks to local and CI
  workflows (#688)
- Update contributor credits

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.27.15+204...pre-v1.27.16+205)
