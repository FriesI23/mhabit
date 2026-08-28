# Release: v1.27.3+192

> This release combines all pre-release changes starting with
> `pre-v1.26.15+188`.

## ✨ Features

- Expand adaptive navigation, search, filtering, and habit-selection actions
  (#646)
  - Improve adaptive search and filtering across different window sizes
  - Keep primary and overflow selection actions available in compact layouts
- Keep adaptive app bars and navigation rails clear of window controls (#647)
- Add adaptive navigation bars and rails with responsive presentation (#649)
  - Add floating compact navigation with expanded and minimized states
  - Add contextual habit-selection actions and page-owned primary actions
  - Preserve navigation behavior across safe areas, resizing, and layout
    direction changes

## 🐛 Fixes

- Improve navigation inset handling, third-party file imports, and Today refresh
  behavior (#650)
- Preserve the habit-list scroll position after returning from habit details
- Stabilize compact navigation during scrolling (#652)
  - Keep the navigation state stable during gentle scrolling
  - Minimize or restore navigation only for intentional swipes
- Restore standard floating-navigation margins on rectangular-screen phones
  while preserving rounded-screen spacing
- Improve dark navigation surfaces and compact primary-action alignment
  - Increase dark floating-surface contrast while keeping shadows restrained
  - Align the compact primary action with the navigation bar across larger
    bottom insets
- Refine navigation scroll-under transitions
  - Update app bar backgrounds automatically as content scrolls underneath
  - Preserve the intended floating-surface elevation during transitions

## 🌐 Localization

- Add Dutch language support (#651)
- Update Czech translation, thanks to Pavel Borecki's contribution on Weblate
  (#651)

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.26.14+187...v1.27.3+192)
