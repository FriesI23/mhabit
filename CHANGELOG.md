# Change log

[中文](./docs/CHANGELOG/zh.md)

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
