# Pre-Released: pre-v1.27.22+211

> [!WARNING]
> On macOS, [beta build 210](https://github.com/FriesI23/mhabit/releases/tag/pre-v1.27.21%2B210)
> may crash when entering full screen or resizing the window. If you encounter
> either issue, upgrade to this beta (build 211).

## ✨ Features

- Enable Esperanto in release builds and update the iOS Home Screen widget's
  Esperanto strings (#717)

## 🐛 Fixes

- Report corrupt Loop ZIP backups as import errors (#715)
- Restore reliable first-frame rendering and window lifecycle handling on
  Windows. Use the English app name in the title bar to avoid garbled text
  (#715)
- Temporarily use Skia for rendering on macOS.

## 🌐 Localization

- Update Esperanto translation, thanks to Jon Stevenson's contribution on Weblate
  (#717)

## 🧹 Others

- Upgrade to Flutter 3.47.9 and Dart 3.13.7, and migrate the adaptive interface
  and animated lists to standalone packages (#715)
- Adopt native Windows build flavors and align Linux and Flatpak packaging
  with the generic distribution (#715)
- Enable Windows ARM64 release builds alongside x64, report failed artifact
  uploads, and fix precheck handling in manual builds (#716)

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.27.20+209...pre-v1.27.22+211)
