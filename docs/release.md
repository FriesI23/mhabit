# Pre-Released: pre-v1.27.23+212

> [!WARNING]
> On macOS, [beta build 210](https://github.com/FriesI23/mhabit/releases/tag/pre-v1.27.21%2B210)
> may crash when entering full screen or resizing the window. If you encounter
> either issue, upgrade to build 211 or later.

## ✨ Features

- Enable Esperanto in release builds and update the iOS Home Screen widget's
  Esperanto strings (#717)

## 🐛 Fixes

- Report corrupt Loop ZIP backups as import errors (#715)
- Restore reliable first-frame rendering and window lifecycle handling on
  Windows. Use the English app name in the title bar to avoid garbled text
  (#715)
- Temporarily use Skia for rendering on macOS.
- Correct English text in habit details, check-ins, reminders, import, export,
  and settings. Show the correct number of days until a habit starts in
  Russian and Ukrainian (#720)

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
- Upgrade the Flatpak runtime and release build container to Freedesktop SDK
  26.08 (#719)

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.27.20+209...pre-v1.27.23+212)
