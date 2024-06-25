# Change log

[中文](./docs/CHANGELOG/zh.md)

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
