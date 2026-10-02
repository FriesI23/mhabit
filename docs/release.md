# Pre-Released: v1.27.11+200-pre

> Includes updates since the previous stable release, v1.27.9+198.

## ✨ Features

- Add adaptive, collapsible side navigation with an edge style on newer Apple
  systems (#667)
  - Preserve navigation state, search, selection, and page actions across
    layout changes
- Apply app theme colors and custom palettes to the side navigation (#668)
- Let users show or hide navigation destinations in the top toolbar when the
  Apple sidebar is collapsed (#671)

## 🐛 Fixes

- Improve adaptive interaction styling, keyboard focus, and action-menu
  behavior (#669)
- Keep search filters available across layout changes (#669)
- Align theme labels and Markdown typography (#669)
- Refresh habit and group views as soon as synced changes are applied, while
  preserving sync progress and in-progress edits (#672)
- Keep neutral action colors consistent across app bars, dialogs, search,
  sidebars, and group actions, and restore modal blur after nested navigation
  (#673)
- Keep system status and navigation bars visible while the app launches

## 🌐 Localization

- Update Hebrew translation, thanks to Omer I.S.'s contribution on Weblate.

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.27.9+198...v1.27.11+200-pre)
