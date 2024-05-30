# Add new locale support

## Flutter

1. Add `<localeName>.arb` file in `assets/l10n`.
2. Translate all fields in `en.arb` file.
3. run `flutter gen-l10n` in library root path.
4. Add new locale to `appSupportedLocales` in `lib/common/consts.dart`

```dart
const appSupportedLocales = [
  Locale.fromSubtags(languageCode: 'en'),
  Locale.fromSubtags(languageCode: 'zh'),
  // Add new locale here
];
```

## Android

> Use format `values-xx-rXX` instead of `values-xx-XX` or `values-xx_XX`
> which including a `countryCode`.

1. Add your locale in `resourceConfigurations` located in `android/app/build.gradle`

```gradle
defaultConfig {
    resourceConfigurations += ["en", "zh", <your_language_code>]
}
```

2. Create new folder at `android/app/src/main/res/values-<your_language_code>`
   and create new file `strings.xml` with the following code:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- add translated app name here -->
    <string name="appName">translated_app_name</string>
</resources>
```

### App language

1. Add your locale in `locales_config.xml` located in `android/app/src/main/res/xml/locales_config.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<locale-config xmlns:android="http://schemas.android.com/apk/res/android">
  <locale android:name="en" />
  <locale android:name="zh" />
  <!-- Add your locale here -->
  <!-- <locale android:name="xx" /> -->
</locale-config>
```

## iOS

1. Add Localization from `Project -> Runner -> Info`
2. Select `InfoPlist.strings` and press `Finish`
3. select `InfoPlist.strings` in left panel, expand tree and select `InfoPlist.strings (XXXXX)`
4. rename `CFBundleDisplayName` and `CFBundleName` value to translatted string.

```strings
CFBundleDisplayName = "Table Habit";
CFBundleName = "Table Habit";
```
