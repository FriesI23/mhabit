<!--
Title: Pre-Released or Released: v1.2.3+xx
-->

# Pre-Release:

## v1.16.11+80

**✨ New Features**

- Hide "Donate Tile" in iOS App Store's flavor.
- Add privacy declaration in app.

<!-- **🐛 Bug Fixes** -->

<!-- **🍎 iOS** -->

<!-- **🍏 macOS** -->

<!-- **🪟 Windows** -->

**🌐 Localization**

- Add hebrew languange support (need translate) from elid's request on Weblate.
- Update Russian l10n translation, thank for Bora Yurt Page's contribution on Weblate.

**🧹 Others**

- Add China IPC in Application (l10n:zh-cn only).
- Migrate from `flutter_markdown` to `markdown_widget`, see [#162966](https://github.com/flutter/flutter/issues/162966) get more informations. (#272)

- Refactor notification-related code (#275):
  - Add localization for Android notification channel.
  - Upgrade `flutter_local_notifications` to v19.
  - Add Windows support for notifications (with limitations).

**📝 Documentation**

- Update README file.
