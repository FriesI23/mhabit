<!--
Title: Pre-Released or Released: v1.2.3+xx
-->

# Pre-Released

## v1.16.2+69

### 🐛 Bug Fixes

- Show correct snackbar message after habit deletion. (#247)
- Fix score bug for habits starting before today. (#248)
- **"Select All"** only select visible habits. (#249)

### 🤖 Android

- Explicitly declare network permission.
- Remove unnecessary `READ_EXTERNAL_STORAGE` permission.

### 📝 Documentation

- Add `LzzyOnDroid` badge to **README.md**.

## v1.16.1+68

- Add Auto Sync Feature
- Update Russian l10n translation, thank for Bora Yurt Page's contribution on Weblate.
- Update Ukrainian l10n translation, thank for Bora Максим Горпиніч's contribution on Weblate.

## v1.16.0+67

- Add WebDav Network Sync
- Add Experimental Features Switcher

### New Feature: WebDav Network Sync

> **WARNING**: This feature involves a database fields modifies.
> Please use the **"Export"** to backup current habits first.
>
> **WARNING**: This feature is experimental and may contain disruptive bugs.
> Please use it with caution.

1. Go to `Settings -> Experimental Features` and enable `"Habit Cloud Sync"` to display the feature entry.
2. Go to `Settings -> Sync Options` to enable and config new server.
3. Press `Sync Now` or pull down at main page to sync with server. Sync Progress displayed in Settings.

If you encounter bugs, please describe current network environment and export corresponding (or all) sync failure logs.
