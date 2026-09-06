# Release: v1.27.5+194-pre

## ✨ Features

- Complete the adaptive interface migration across navigation, settings, page
  headers, search, selection, and habit actions
  - Preserve branch state and improve back navigation across nested pages
  - Keep actions and menus responsive across window sizes and input modes
- Add quick theme mode controls to app bars and wider navigation layouts (#659)
- Add resizable side navigation for wider layouts (#653)
  - Keep navigation aligned with window controls, safe areas, and layout
    direction changes
  - Improve text rendering and theme behavior across desktop layouts
- Improve app bars, habit actions, and batch status changes across window sizes
  (#655)
  - Keep localized action labels readable and move extra actions into overflow
    menus when space is limited
  - Refine page backgrounds and scroll-under transitions

## 🐛 Fixes

- Keep dialogs above app navigation and refresh selection state consistently
  after reordering or regrouping habits (#656)

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.27.3+192...pre-v1.27.5+194)
