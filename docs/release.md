# Release: v1.27.9+198

> Includes updates since the previous stable release, v1.27.6+195.

## ✨ Features

- Cycle check-ins from unknown to done, skipped, and back to unknown (#657)
  - Delete a single check-in or several at once with confirmation
  - Sync deletions across devices and keep record identity for later check-ins
- Improve dialogs and page layouts across window sizes (#661)
  - Adapt sheets and dialogs when resizing while preserving the open form
    and navigation state
  - Migrate group management, sync editing, changelog, donation, and about
    dialogs to shared adaptive presentation
  - Keep nested navigation and close confirmation within the active dialog
  - Align scrolling page headers, safe areas, and window-control avoidance
- Improve habit detail actions and refresh retained details when returning
  to them (#662)
- Improve Settings, grouped lists, and dialogs across window sizes (#663)
  - Add date format, reminder, export, import progress, and group editing flows
  - Keep import results and group actions tied to the selected items
- Preserve unknown WebDAV fields when syncing groups and records, improving
  compatibility with newer app versions (#665)

## 🐛 Fixes

- Restore batch check-in actions for selected habits in Apple layouts (#661)
- Preserve Settings scroll position when rebuilding the page (#661)
- Prevent a delayed group save from closing the group selector after the
  user has already returned from the creation form (#661)
- Improve loading error recovery (#662)
- Bound import concurrency and expose failures for individual items (#663)

## 🌐 Localization

- Update Italian translation, thanks to Simone De Carli's contribution on
  Weblate (#664)

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.27.6+195...v1.27.9+198)
