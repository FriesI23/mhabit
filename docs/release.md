# Released: v1.27.15+204

## ✨ Features

- Integrate native desktop title bars and keep app bars pinned while scrolling
  (#677)
  - Fuse macOS window controls with adaptive toolbars and handle fullscreen
    transitions
  - Match native title bar colors to the app theme on Windows and Linux
- Keep a manually collapsed sidebar closed across layout and interface-style
  changes within the current session (#679)
- Restore desktop window size and position before the window first appears
  (#681)
  - Save ordinary window geometry without treating fullscreen or maximized
    bounds as the preferred window size

## 🐛 Fixes

- Preserve open dialogs and their state while updating theme colors, and keep
  dialog app bars consistent with their local theme (#677)
- Restore the Settings Back button when the sidebar and its collapsed toolbar
  navigation are hidden (#678)

## 🧹 Others

- Add desktop native regression tests and integrate them into local and CI
  test workflows (#677)

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.27.13+202...v1.27.15+204)
