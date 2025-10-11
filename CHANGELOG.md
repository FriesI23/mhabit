# Change log

[中文](./docs/CHANGELOG/zh.md)

## 1.18.0-pre.1+103

**🌐 Localization**

- Updated Ukrainian translation, thank to Максим Горпиніч's contribution on Weblate.

**🧹 Others**

- Numbers changes can be saved on iOS/iPadOS (#351)
- Adjusted project code directory structure (#353)
- Refactored App Sync Server Form with MVVM architecture (#364)
- Refactored Habit Form with MVVM architecture (#366)
- [Github Action]: Added pre-release cleanup CI for app release


## 1.17.10+102

**🧹 Others**

- Downgrade AGP to 8.11.1 due to fdroid incompatibility with >=8.12 (#347)

## 1.17.8+100

**✨ New Features**

- Show snackbar after exporting habits. (#337)
- Add localization support to Experimental Features bar. (#337)
- Enable navigation from debugger notifications. (#337)

**🌐 Localization**

- Add Hebrew translation, thanks to Omer I.S's contribution on Weblate.
- Updated Portuguese translation, thanks to Nikolas Gonçalves dos Santos's contribution on Weblate.
- Updated Spain translation, thank to Andres Blasco Arnáiz's contribution on weblate.

**🧹 Others**

- Apply flavor settings to Windows notifications. (#337)
- Bump package dependencies (#342)
- Refactor GitHub Workflows (#343)

**📝 Documentation**

- Simplify TODO markers in notification code.

## 1.17.5+98

**✨ New Features**

- Cancel noti-permission request at app launch on iOS/macOS (#323)
- Add leading zero in date option (#325)

**🌐 Localization**

- Updated Polish translation, thanks to Pandaman331's contribution on Weblate. (#324)

**🧹 Others**

- Improve hint visibility under low brightness (#321)
- Move vscode workspace settings to code-workspace (#322)
- Implement Windows custom flavor support (#327, #330)
- Add conditional check for windows build test (#327)

**📝 Documentation**

- Wiki: Add variable-based flavor support for Windows platform
- Wiki: Document how the score works (#331)

## 1.17.2+95

**🌐 Localization**

- Updated Arabic translation, thanks to abdelbasset jabrane's contribution on Weblate.
- Updated Ukrainian translation, thank to Максим Горпиніч's contribution on Weblate.

**🧹 Others**

- Bump Flutter version to v3.29.3 (#315)
- Bump package dependencies (#316)
  - Upgrade `share_plus` to 11.1.0 (major)
  - Upgrade `data_saver` to 0.4.0 (major)
  - Upgrade `fl_chart` to 1.0.0 (major)
  - Upgrade `copy_with_extension_gen` to v6 (major)

**📝 Documentation**

- Add [Github Wiki](https://github.com/FriesI23/mhabit/wiki) (#312, #313)

## 1.16.22+91

**✨ New Features**

- Show UI feedback on habit deletion (#303)

**🌐 Localization**

- Updated Arabic translation, thanks to abdelbasset jabrane's contribution on Weblate.
- Update Russian translation, thanks to Yurt Page's contribution on Weblate.
- Updated Ukrainian translation, thank to PavloPogonets's contribution on Github.

**🧹 Others**

- Add Flatpak support (#304)
- Bump dependencies (#306)
- Prepare for Flathub submission (#307)

**📝 Documentation**

- Enhance Linux build instructions (#291)

## 1.16.20+89

**🌐 Localization**

- Fix type in English l10n, thank for PavloPogonets's contribution on Github.
- Updated Arabic translation, thanks to abdelbasset jabrane's contribution on Weblate.
- Updated Ukrainian translation, thank to Максим Горпиніч's contribution on Weblate.
- Updated Ukrainian translation, thank to PavloPogonets's contribution on Github.

**🧹 Others**

- Handled missing getetag property on some WebDAV servers (#298)
- Fix synchronization issues in airplane mode (#295)
- Ensure ARB files endwith newline

**📝 Documentation**

- Add documentation example for WebDAV synchronization (#292)
- Update README.md

## 1.16.19+88-pre

**🌐 Localization**

- Updated Ukrainian translation, thank to PavloPogonets's contribution on Github.

**📝 Documentation**

- Update README.md.

## 1.16.18+87-pre

**🌐 Localization**

- Fix type in English l10n, thank for PavloPogonets's contribution on Github.
- Updated Arabic translation, thanks to abdelbasset jabrane's contribution on Weblate.
- Updated Ukrainian translation, thank to Максим Горпиніч's contribution on Weblate.
- Updated Ukrainian translation, thank to PavloPogonets's contribution on Github.

**🧹 Others**

- Handled missing getetag property on some WebDAV servers (#298)
- Fix synchronization issues in airplane mode [#295]
- Ensure ARB files endwith newline

**📝 Documentation**

- Add documentation example for WebDAV synchronization (#292)

## 1.16.17+86

**✨ New Features**

- Add app network sync notification support (#287)
  - add network sync notification for Android / iOS / macOS / Windows / Linux
  - add in-app notification config for non-android

**🌐 Localization**

- Update Russian l10n translation, thanks to Yurt Page's contribution on Weblate.
- Update Turkish l10n translation, thanks to Bora Atıcı and Soykan Aydın for their contributions on Weblate.
- Update Ukrainian l10n translation, thank for PavloPogonets's contribution on Github.

## 1.16.16+85-pre

**✨ New Features**

- Add app network sync notification support (#287)
  - add network sync notification for Android / iOS / macOS / Windows / Linux
  - add in-app notification config for non-android

**🌐 Localization**

- Update Turkish l10n translation, thank for Bora Atıcı's contribution on Weblate.
- Update Ukrainian l10n translation, thank for PavloPogonets's contribution on Github.

## 1.16.15+84-pre

**🌐 Localization**

- Update Russian l10n translation, thanks to Yurt Page's contribution on Weblate.
- Update Turkish l10n translation, thanks to Bora Atıcı and Soykan Aydın for their contributions on Weblate.
- Update Ukrainian l10n translation, thank for Preck757's contribution on Github.

## 1.16.14+83

**✨ New Features**

- Enhance WebDAV sync: trigger in some scenarios when auto-sync is enabled (#278):
  - Reduce delay duration before auto-sync after launch;
  - Add async debouncer utility code;
  - Re-sync after the app stays in background for a while and then returns to foreground;
  - Re-sync after habit status changes;
  - Re-sync after record changes;
- Add privacy declaration in app.
- **[iOS]** Hide "Donate Tile" in iOS App Store's flavor.

**🌐 Localization**

- Update Arabic l10n translation, thanks to abdelbasset jabrane's contribution on Weblate.
- Update Russian l10n translation, thank for Bora Yurt Page's contribution on Weblate.
- Update Spanish l10n translation, thanks to Óscar Fernández Díaz's contribution on Weblate.
- Update Ukrainian l10n translation, thank for Bora Максим Горпиніч's contribution on Weblate.
- Update Ukrainian l10n translation, thank for Preck757's contribution on Github. (#281)
- Update Contributor File.
- Add hebrew languange support (need translate) from elid's request on Weblate.

**🧹 Others**

- Migrate from `flutter_markdown` to `markdown_widget`, see [#162966](https://github.com/flutter/flutter/issues/162966) get more informations. (#272)
- Refactor notification-related code (#275):
  - Add localization for Android notification channel.
  - Upgrade `flutter_local_notifications` to v19.
  - Add Windows support for notifications (with limitations).
- **[Android]** Set `AppDebugger` notification message to `ongoing`.
- **[iOS]** Add China IPC in Application (l10n:zh-cn only).

**📝 Documentation**

- Update README file.

## 1.16.10+78

**🍎 iOS**

- Add support for iOS app-language preference.

**📝 Documentation**

- Add Privacy Policy file.

## 1.16.9+77

**🐛 Bug Fixes**

- Show notification bar once app is loaded on iOS
- Process duplicate uuid when re-calc habit record uuid (#269)

**🌐 Localization**

- Update Spanish l10n translation, thanks to Patricio Carrau's contribution on Weblate.

**🧹 Others**

- chore: bump dependencies (#267)

## 1.16.7+74

**✨ New Features**

- Add iOS and Android Launch Screen Image.
- Enable app sync by default (#264).

**🐛 Bug Fixes**

- Import does not start after selecting the backup file (#257).
- Incorrect encoding of Cyrillic characters and emojis (#254).

**🍎 iOS**

- **Add Flavors:**
  - `f_dev`: For iOS development builds.
  - `f_generic`: For iOS release builds.
  - `f_store`: For iOS App Store release builds.
- **Generate Logo Variants:**
  - Dark
  - Tinted
  - [More Info](https://developer.apple.com/design/human-interface-guidelines/app-icons#iOS-iPadOS)
- **CI:**
  - Add iOS Release CI (for unsigned IPA).

**🍏 macOS**

- **Add Flavors:**
  - `f_dev`: For macOS development builds.
  - `f_generic`: For macOS release builds.

**🪟 Windows**

- Fix Windows MSIX Builder (#261).

**🌐 Localization**

- Update Spanish l10n translation, thanks to Patricio Carrau's contribution on Weblate.

**📝 Documentation**

- Update build notices for iOS / macOS in **README.md**.
- Update Testflight for iOS in **README.md**.
- Update **add_new_locale_support.md**.

## 1.16.3+70

**✨ New Features**

- Add WebDav Network Sync Feature (Experimental).
- Add Auto Sync Feature.
- Add Experimental Features Switcher.

> **WARNING**: WebDav Network Sync modifies database fields.
> Please use the **"Export"** to backup current habits first.
>
> **WARNING**: This feature is experimental and may contain disruptive bugs.
> Please use it with caution.

1. Go to `Settings -> Experimental Features` and enable `"Habit Cloud Sync"` to display the feature entry.
2. Go to `Settings -> Sync Options` to enable and config new server.
3. Press `Sync Now` or pull down at main page to sync with server. Sync Progress displayed in Settings.

If you encounter bugs, please describe current network environment and export corresponding (or all) sync failure logs.

**🐛 Bug Fixes**

- Show correct snackbar message after habit deletion. (#247)
- Fix score bug for habits starting before today. (#248)
- **"Select All"** only select visible habits. (#249)
- (Android) Explicitly declare network permission.
- (Android) Remove unnecessary `READ_EXTERNAL_STORAGE` permission.

**🌐 Localization**

- Update Russian l10n translation, thank for Bora Yurt Page's contribution on Weblate.
- Update Ukrainian l10n translation, thank for Bora Максим Горпиніч's contribution on Weblate.

## 1.15.8+66

- Update Traditional Chinese l10n translation, thank for Peter Dave Hello's contribution on Github.
- Update Turkish l10n translation, thank for Bora Atıcı's contribution on Weblate.
- Update Polish l10n translation, thank for Bartek Skrzypek's contribution on Weblate.
- Add Code Generator/Annotation for `Proxy` design pattern classes (#228).
- Ensure `firstday` config is applied to the calendar picker (#222, #228).
- Skip reason is also applied during export (#227).
- Fix several issues in database operations:
  - Typo in variable name of custom SQL.
  - Use the correct field type for `Record.reason`.
  - Use "update" instead of "replace" when inserting multiple records.
  - Use transactions when inserting multiple records.
- Fix issue where today's status couldn't be modified on the multi-habits changer page.
- Fix `loadData` being completed multiple times when the page initializes (#230).

## 1.15.4+62

- L10n: Add Czech translation, thank for Jirka Čapek's contribution on Weblate.
- CI: Normalize translation ARB Files.
- CI: Add Code checking Github Action.

## 1.15.3+61

- Upgrade `flutter` version to 3.24.5.
- Upgrade dependencies version.
- Migrate from `file_picker` to `file_selector`.
- Unifying saveFile and shareXFiles across platforms.
  - Use "saveFile": Windows / MacOS / Linux.
  - Use "shareXFiles": Android / iOS(iPadOS).
- Optimize page return logic implementation.
- Fix TextFiled's text UI sinking on `Frequency` and `Target Days` picker.
- Fix Habits Exporter function in display page on iPadOS.
- Fix serveral Export related functions on Linux.

## 1.14.4+57

- Strip `DependenciesInfo` block from android, resolve [#205](https://github.com/FriesI23/mhabit/issues/205).

full changes on this realese see: [release.md](https://github.com/FriesI23/mhabit/blob/v1.14.4%2B57/docs/release.md)

## 1.14.3+56

- Add Windows MSIX Installer.
- Add separate error page when app crashes during startup.
- Fix issues with incorrect usage of `Completer`.
- Change debug log path to `Cache` directory.
- Change database path to `Support` directory on non-android platforms.
- Update Ukrainian translation, thank for Максим Горпиніч's contribution on Weblate.

**WARNING**: Because changing database path will involve file migration,
it's strongly recommended to backup (export) habits before upgrading.

full changes on this realese see: [release.md](https://github.com/FriesI23/mhabit/blob/v1.14.3%2B56/docs/release.md)

## 1.14.1+54

- Add Turkey translation, Thanks for S. Aydın's contribution on weblate.
- Bump Dependencies versions on Android.
- Keep `@mipmap/ic_notification` to prevent it from being removed by `shrinkResources`,
  see [https://stackoverflow.com/a/50703322](https://stackoverflow.com/a/50703322).

full changes on this realese see: [release.md](https://github.com/FriesI23/mhabit/blob/v1.14.1%2B54/docs/release.md)

## 1.13.6+52

- Add Polish translation (need translate).
- Add Tranditional Chinese translation, thank for PeterDaveHello's contribution on Github.
- Add Ukrainian translation, thank for Fqwe1's contribution on Weblate.
- Update Spanish translation, thank for gallegonovato's contribution on Weblate.
- Update Italian translation, thank for glemco's contribution on Weblate.
- Update Persian translation, thank for ulracte's contribution on Weblate.
- Bump dependencies version, see [here](https://github.com/FriesI23/mhabit/commit/204922af8eaf0c025739623aad85a12f14cefce5) for more information.

## 1.13.3+49

- Update Spain translation, thank for Andres Blasco Arnáiz and gallegonovato's contribution on weblate.
- Fix show black screen when back from main screen.

full changes on this realese see: [release.md](https://github.com/FriesI23/mhabit/blob/v1.13.3%2B49/docs/release.md)

## 1.13.1+47

- Upgrade flutter to 3.19.6.
- Add Spain translation, thank for Andres Blasco Arnáiz's contribution on weblate.

full changes on this realese see: [release.md](https://github.com/FriesI23/mhabit/blob/v1.13.1%2B47/docs/release.md)

## 1.12.8+45

- Update Translation file (vi)
- Add linux platform support (#174)
- Fix test reporter action HTTP Error (#181)
- Bump dependencies version

## 1.12.5+42

- Add In-App Language Switching
- Add Debug log Collection feature.
- Fixed: Notification icon wasn't shown on native Android platform.
- Fixed: Localization for batched check-in's changed snackbar text.
- Bump dependencies' versions.

## 1.12.2+39

- Add Russian translation. (#169, thanks for @yurtpage's contribution)
- Add Italian translation. (from Weblate, thanks for @spar34vi's translation)
- Add support for the Windows platform. (#164)
- Add support for `dmg` build on macOS. (#168, thanks for @rxzheng's contribution)
- Add `pre-release` version build process. (#171)
- Fixed issue in `OpenContainer` raise exception when navigating via `Tooltips` enabled. (#166)
- Update iOS dependency package versions.
- Optimize code quality.

## 1.12.0+37

- Add Batch Check-in feature

After long press to select multi habits, `Batch Check-in` feature can be
accessed by clicking `FAB` button at bottom right of screen.

## 1.11.1+36

- Add contributor page
- Fixed where pressing back button would exit app in edit mode
- Refactor code pertaining to `db` / `profile` / `provider` / `view`, etc.
- Add lint options to `analysis_options.yaml`

**WARNING**: Strongly recommend backup habits before updating this version.

## 1.11.0+35

- Update dart SDK dependency to >=3.0.0
- Refactor logging module
- Specify provider dependencies on pages
- Remove dependency with summary and detail page
- Rewrite `context.maybeRead` method
- Fix habit's revert operation

## 1.10.6+34

- Fix not reminding issue on android (#144)

## 1.10.5+33

- Freeze score if habit archived (#138)
- Fix not reminding issue on android (#140)
- Fix typo issue in project (#137)

## 1.10.4+32

- Fix incorrect default language (#133)

## 1.10.3+31

- Add French translation (#130)
- Add Arabic translation (#132)

## 1.10.2+30

- Add Vietnamese translation (#121)
- Update for German translation (#123)
- Fix Habit filter (#125)

## 1.10.1+29

- Add German translation
- Add Custom tap actions for Habit Record

## 1.10.0+28

- Upgrade Flutter version to 3.13.9
- Upgrade dependency packages
- Modify app release action to use the submodule from the project
- Fixed some bugs

see changes in [#115](https://github.com/FriesI23/mhabit/pull/115) for
complete overview.

## 1.9.2+27

- Optimize donate dialog (#113)
- Fixed month name alignment (#114)

## 1.9.1+26

- Add donate button for crypto currency (#102)
- Fixed filtering to correctly hide completed habits (#104)

## 1.9.0+25

- Change new app icon (#92)
- Fixed chart bars may overlap problem (#94)

## 1.8.5+24

- Add Themed icon (#89)
- Store the last filled number of target days (#88)
- Show completed habits even when archived (#87)

## 1.8.4+23

- Fixed use the user-entered value for auto-complete instead of using dailyGoal (#85)
- Fixed Included archived habit in most popular habit section (#83)
- Fixed incorrect markdown colors on memo string on dark mode (#79)
- Fixed unclear color for '?' and '×' buttong in dark mode (#75)

## 1.8.3+22

- Add 'Habit Template' feature
- Refactor `Appbar` section of code

## 1.8.2+21

- Add support for Persian language, Thanks for @chromer030's translation contribution🎉
- Fixed some display issues with UI style under RTL layout
- Add translation statistics graph in `readme`
- Split apk per ABI when releasing new version, only supporting `GitHub/Releases` currently.
- Optimize file structure of CI scripts

## 1.8.1+20

- Show Memo on Habit detail page
- Support Markdown formatter on Habit memo
- Fixed positive habit's daily goal set to 0 problem in edit page
- Fixed unable to switch habitType when editting exsit habit

## 1.8.0+19

- Add negative habit
- Refactor some of the code
- Add CI

**IMPORTANT**: Please make a full backup before updating this version.

## 1.7.1+18

- fixed summary text show negative number
- add new target days option

## 1.7.0+17

- add compact UI on habits page
- add a slider to adjust the habits check area radio

## 1.6.0+16

- add custom datetime format picker
- fixed wrong use of create date icon

## 1.5.1+15

- fixed: FAB display overlap with habit

## 1.5.0+14

- add two faster input buttons to change the daily goal value

## 1.4.2+13

- fixed misspelling in theme change button

## 1.4.1+12

- fixed filter issue, see [#38](https://github.com/FriesI23/mhabit/issues/38)

## 1.4.0+11

- add feature to export habit without records
- update `readme`

## 1.3.2+10

- fix fastlane/zh-CN app title name
- fix some spelling errors

## 1.3.1+9

- remove iternet permission on android
- change launchUrl mode to externel appilication
- bump flutter_donation_buttons to 0.2.7
- fix export habits in the order determined by the manual sort position
- add auto generate changlog python script

## 1.3.0+8

- Fix `pubspec.lock` file changed when run `flutter pub get`

## 1.2.5+7

- Add flutter as submodule

## 1.2.4+6

- Add distributionSha256Sum, see [here](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/13058#note_1404993220)

## 1.2.3+5

- fix artifact path with appbundle
- fix app signed progress

## 1.2.2+4

- Fix fastlane locale folder case

## 1.2.1+3

- Add Fastlane file structure
- Add android app signing

## 1.2.0+2

- Feature:
  - Add skip reason dialog on heatmap.
  - Add 'Maximum Daily Goal' value in Change Goal Dialog.
  - Add custom color on skipReason/changeGoal dialog.
- Fixed:
  - Provide remaining text for translation.
  - int like 1 shouldn't display decimal point.
- Other:
  - Change app logo style.

## 1.1.0+1

- Change package domain to `github.io`

## 1.0.0

- New release
