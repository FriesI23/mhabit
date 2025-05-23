<!-- markdownlint-disable MD036 -->
<!--
Title: Pre-Released or Released: v1.2.3+xx
-->

# Pre-Release

## 1.16.13+82

**🌐 Localization**

- Update Spanish l10n translation, thanks to Óscar Fernández Díaz's contribution on Weblate.
- Update Arabic l10n translation, thanks to abdelbasset jabrane's contribution on Weblate.
- Update Contributor File.

**🧹 Others**

- [Android] Set `AppDebugger` notification message to `ongoing`.

## v.16.12+81

**✨ New Features**

- Enhance WebDAV sync: trigger in some scenarios when auto-sync is enabled (#278)
  - Reduce delay duration before auto-sync after launch
  - Add async debouncer utility
  - Re-sync after switching app to background for some time
  - Re-sync after habit status changes
  - Re-sync after record changes

**🌐 Localization**

- Update Ukrainian l10n translation, thank for Bora Максим Горпиніч's contribution on Weblate.

## v1.16.11+80

**✨ New Features**

- Hide "Donate Tile" in iOS App Store's flavor.
- Add privacy declaration in app.

<!-- **🐛 Bug Fixes** -->

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
