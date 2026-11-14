<!-- markdownlint-disable no-inline-html first-line-heading -->

## Flutter

1. Add `<localeName>.arb` file in `assets/l10n` with `@@locale`, the native
   `localeScriptName`, and `appName`. Follow the existing `🚧` naming convention
   and leave untranslated messages absent for Weblate to track.
2. Translate messages from `en.arb`. Push the ARB to Weblate's tracked branch
   for discovery on its next repository update.
3. Run `make normalize-l10n`, then `make gen` from the repository root.
4. Add new locale to `appSupportedLocales` in `lib/common/consts.dart` after
   checking Material, Cupertino, Widgets, and `intl` date support. Keep
   incomplete translations behind `kDebugMode`.

   ```dart
   const appSupportedLocales = [
   Locale.fromSubtags(languageCode: 'en'),
   Locale.fromSubtags(languageCode: 'zh'),
   // Add new locale here
   ];
   ```

5. Complete the platform setup below and run `make verify-generated`. Check
   language selection, date pickers, and formatting before enabling Release use.

### Languages without Flutter component support

ARB files may be added before app support. Missing messages fall back to `en.arb`.
Check [Flutter component support][flutter-localizations] separately.

Welsh (`cy`) uses Flutter's built-in resources. Esperanto (`eo`) uses
[`l10n_esperanto`][l10n-esperanto] 2.x for Material, Cupertino, and `intl`
date/number data. Version 3.x targets `material_ui` / `cupertino_ui`.
Register its delegates after the global delegates in `lib/common/consts.dart`.
Keep `eo` in ARB and Widget snapshots. Widgets uses Flutter's default resources.

Keep `initializeDateFormatting()` before custom delegates in `lib/main.dart`
so dates without an explicit locale work on an Esperanto cold start.

## Android

> Use format `values-xx-rXX` instead of `values-xx-XX` or `values-xx_XX`
> which including a `countryCode`.

1. Add your locale in `resourceConfigurations` located in `android/app/build.gradle`

   ```gradle
   defaultConfig {
       resourceConfigurations += ["en", "zh", <your_language_code>]
   }
   ```

2. Create new folder at `android/app/src/f_generic/res/values-<your_language_code>`
   and create new file `strings.xml` with the following code:

   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <resources>
       <!-- add translated app name here -->
       <string name="appName">translated_app_name</string>
   </resources>
   ```

### App language

> [Android Developers: Per-app language preferences][app-languages]

Add your locale in `locales_config.xml` located in `android/app/src/main/res/xml/locales_config.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<locale-config xmlns:android="http://schemas.android.com/apk/res/android">
<locale android:name="en" />
<locale android:name="zh" />
<!-- Add your locale here -->
<!-- <locale android:name="xx" /> -->
</locale-config>
```

## iOS / macOS

1. Add Localization from `Project -> Runner -> Info`
2. Select `<flavorName>-InfoPlist.strings` and press `Finish`
3. select `<flavorName>-InfoPlist.strings` in left panel, expand tree and select `<flavorName>-InfoPlist.strings (XXXXX)`
4. Set `CFBundleDisplayName` to the translated app name or `Table Habit`,
   preserving each flavor's suffix.

   ```swift
   CFBundleDisplayName = "Table Habit";
   CFBundleName = "Table Habit"; // Only for macOS
   ```

Files live in `ios/Localizations/<locale>.lproj/` and
`macos/Localizations/<locale>.lproj/`. Register them in each Xcode project's
`InfoPlist.strings` variant groups and `knownRegions`.

### iOS Widget

`make gen` fills `ios/HabitWidget/Extension/<locale>.lproj/Localizable.strings`
from ARB using `configs/l10n_strings_refs.json`, preserving native translations.
Missing runtime strings fall back to English. For enabled app locales, register
the file in `ios/Runner.xcodeproj`'s `Localizable.strings` variant group for both
Runner and HabitWidgetExtension.

## Windows

1. Add supported languages in `pubspec.yaml` for MSIX:

   ```yaml
   msix_config:
     languages: en, zh-Hans, <new-language-code>
   ```

2. (Optional) Check <Resources> in AppxManifest.xml to ensure languages are included:

   ```xml
   <Resources>
       <Resource Language="en-us" />
       <Resource Language="zh-cn" />
       <Resource Language="zh-tw" />
       <!-- New language is HERE -->
   </Resources>
   ```

> You can find the `AppxManifest.xml` file in the packaged MSIX (rename suffix `.msix` to `.zip` and extract it)

<!-- refs -->

[app-languages]: https://developer.android.com/guide/topics/resources/app-languages
[flutter-localizations]: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#adding-support-for-a-new-language
[l10n-esperanto]: https://pub.dev/packages/l10n_esperanto

---

1. [2025-07-28] Migrated from: [`FriesI23/mhabit/docs/add_new_locale_support.md`][_migrate]

[_migrate]: https://github.com/FriesI23/mhabit/blob/3d77abe340b2595f03ed42a510d160903f603417/docs/add_new_locale_support.md
