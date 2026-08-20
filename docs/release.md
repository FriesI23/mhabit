# Release: v1.26.12+185-pre

## 🌐 Localization

- Update Czech translation, thanks to Pavel Borecki's contribution on Weblate (#643)

## 🔄 Migration

- Upgrade Flutter to 3.44.9 and align the bundled SDK, FVM configuration,
  build tooling, and app and internal-package dependencies (#644)
- Migrate iOS and macOS dependency integration from CocoaPods to Swift Package
  Manager, raise the iOS deployment target to 15.0, and update CI and Fastlane
  workflows (#644)
- Replace incompatible icon, donation, and data-saver packages and regenerate
  affected native and Dart outputs (#644)
- Adapt application code and tests to Flutter 3.44 API and behavior changes
  and rely on the resolved SQLite dependency instead of a bundled library
  (#644)

## 🐛 Fixes

- Preserve consecutive back navigation for root dialogs and nested detail
  pages, including gesture-driven navigation
- Enable animated menus for search filters and group actions, while disabling
  the affected filterable-menu animation in debug builds to avoid a Flutter
  framework assertion (#644)
- Harden stack-trace parsing for empty or malformed frames so logging remains
  available when diagnostics are incomplete (#644)
- Bind habit identifiers through parameterized database queries to keep habit
  record lookups reliable (#644)
- Replace donation buttons with maintained components and handle link-launch
  failures safely (#644)
- Add regression coverage for menu configuration, stack-trace parsing, and
  habit record queries (#644)

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.26.7+180...pre-v1.26.12+185)
