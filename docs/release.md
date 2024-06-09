<!--
Title: Pre-Released or Released: v1.2.3+xx
-->

# Pre-Released

## pre-v1.13.0+46

Upgrade flutter version to 3.19.6 (last stable version with dart 3.3 (3.3.4). Main reason for upgrading this version is:

- More stronger syntax checking (to prevent some bugs at async coding).
- To prevent falling too far behind Flutter's major version, which could be more difficult for future upgrades.
- Flutter project itself has fixed lot of bugs.

This update include following changes:

1. Fix unexpected warnings if enable `use_build_context_synchronously`, see [here](https://github.com/dart-lang/linter/issues/4753) to get more information.

2. Breaking changes
   - [Deprecate textScaleFactor in favor of TextScaler](https://docs.flutter.dev/release/breaking-changes/deprecate-textscalefactor)
   - [Android Predictive Back](https://docs.flutter.dev/release/breaking-changes/android-predictive-back)
   - [Deprecated imperative apply of Flutter's Gradle plugins](https://docs.flutter.dev/release/breaking-changes/flutter-gradle-plugin-apply)

> for full breaking changes with two versions, see [Flutter 3.19](https://docs.flutter.dev/release/breaking-changes#released-in-flutter-3-19) and [Flutter 3.16](https://docs.flutter.dev/release/breaking-changes#released-in-flutter-3-16).

3. Fix Scrollbar's Exception on desktop platforms (windows/macos/linux) in app's `changelog` and `license` dialog.

