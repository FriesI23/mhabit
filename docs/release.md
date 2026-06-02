# Release: v1.24.5+161

## 🌐 Localization

- Update the Hebrew text for the shared load-error message and refresh translation outputs (#570).

## 🛠 Refactor

- Refactor page state wiring and dependency setup, and tidy page unit-test paths (#563).
- Refactor reminder handling to improve stability on app start, restart, and day changes (#569).
- Refactor habit summary APIs and simplify related helper logic (#571).
- Refactor custom color generation and improve palette consistency (#572).

## 🧹 Others

- Fix duplicate habit detail refresh when returning via back navigation (#565).
- Update build and release workflows to fix packaging and native build-chain issues (#544, #547, #548).
- Integrate Melos workspace automation and add test-scoped DB and logging helpers for local workflows (#573).
- Stabilize icon font generation and refresh generated icon assets for release builds (#574).

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.24.1+154...v1.24.5+161)
