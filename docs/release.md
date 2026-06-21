# Release: v1.25.0+163-pre

## ✨ New Features

- Add per-habit custom color support: built-in swatches (cc1–cc10), adaptive
  three-area color picker (swatches / recent history / wheel-hex-RGB), and
  MRU color history capped at 20 (#580).
- Introduce sealed `HabitColor` / `BuiltInHabitColor` / `CustomHabitColor`
  unifying the color model at the business layer; migrate ~27 call sites from
  `colorType` to `color: HabitColor` (#580).
- Extend WebDAV sync payload and local JSON export/import with custom color
  fields, preserving backward compatibility through `_schema_version` (#580).

## 🛠 Refactor

- Migrate build scripts (`sync-rules`, `gen_changelogs`, `normalize_arb`) to
  Python with Poetry for cross-platform compatibility; add `.cmd` wrappers for
  Windows (#578).

## 📝 Documentation

- Update AltStore/SideStore source URLs and fix shell command indentation.

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.24.5+161...v1.25.0+163-pre)
