# Release: pre-v1.27.7+196

## ✨ Features

- Improve dialogs and page layouts across window sizes (#661)
  - Adapt sheets and dialogs when resizing while preserving the open form
    and navigation state
  - Migrate group management, sync editing, changelog, donation, and about
    dialogs to shared adaptive presentation
  - Keep nested navigation and close confirmation within the active dialog
  - Align scrolling page headers, safe areas, and window-control avoidance

## 🐛 Fixes

- Restore batch check-in actions for selected habits in Apple layouts (#661)
- Preserve Settings scroll position when rebuilding the page (#661)
- Prevent a delayed group save from closing the group selector after the
  user has already returned from the creation form (#661)

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.27.6+195...pre-v1.27.7+196)
