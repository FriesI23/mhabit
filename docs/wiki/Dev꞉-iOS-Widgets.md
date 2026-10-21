<!-- markdownlint-disable no-inline-html first-line-heading -->

For adding and using a widget, see [iOS Widgets][user-guide]. For general Flutter
build requirements, see [Build From Source][build-guide]. Widgets require iOS 17;
Runner keeps its iOS 15 deployment target.

## Build and Signing

Use the repository's pinned Flutter SDK and run `make bootstrap`. In Xcode, select
your development team for both `Runner` and `HabitWidgetExtension`. Register the
App Group for the variant and enable it for both targets:

<!-- markdownlint-disable MD013 -->
| Variant | App bundle ID | Shared App Group |
| --- | --- | --- |
| default / `f_generic` | `io.github.friesi23.mhabit` | `group.io.github.friesi23.mhabit.widgets` |
| `f_dev` | `io.github.friesi23.mhabit.dev` | `group.io.github.friesi23.mhabit.dev.widgets` |
| `f_store` | `io.github.friesi23.mhabit.store` | `group.io.github.friesi23.mhabit.store.widgets` |
<!-- markdownlint-enable MD013 -->

The extension bundle ID is the app bundle ID followed by `.widgets`. Forks that
change the app identifier must also update App Groups and provisioning profiles.
Distribution needs profiles for both targets; the existing Fastlane lane handles
both. An unsigned build verifies compilation, not provisioning or distribution.

Runner sets `ENABLE_APPINTENTS_DEPLOYMENT_AWARE_PROCESSING=NO` to generate iOS 17
intent metadata while supporting iOS 15. See [Apple's compatibility workaround][apple-metadata].

Run commands from the application repository root:

```sh
.flutter/bin/flutter build ios --simulator --debug --flavor f_dev
.flutter/bin/flutter build ios --release --no-codesign --flavor f_store
```

Launch the app once to publish its first snapshot, then add both widget sizes
from the Home Screen widget gallery.

## Source Ownership

The Xcode groups match the directories under `ios/HabitWidget/`:

- `App/`: the headless Flutter engine runner and plugin registrar bridge.
  These files compile only in Runner.
- `Extension/`: WidgetKit views, extension configuration, entitlements, and
  localized resources. These files belong to `HabitWidgetExtension`.
- `Shared/`: snapshot decoding and the action intent, compiled in both targets.
  `HABIT_WIDGET_EXTENSION` keeps app-only execution out of the extension.

`pigeons/habit_widget.dart` defines the typed startup, action, and foreground
refresh APIs. `make gen` generates `lib/entries/habit_widget_api.g.dart` and
`App/HabitWidgetApi.g.swift`; the Swift API compiles only in Runner. The headless
and foreground APIs use their respective engines' binary messengers. Preserve
the ready handshake, request queue, and timeout when changing the bridge.

App startup stays in Runner. The Dart background entrypoint and foreground event
bridge live in `lib/entries/habit_widget_entry.dart`; record mutations remain in
the existing Dart workflow and database storage layers. No separate Swift package
or native habit database is required.

Widget-only strings live in `Extension/<locale>.lproj/Localizable.strings`.
Use Apple locale identifiers such as `zh-Hans` and `zh-Hant`. Common app labels
arrive in the snapshot; native resource matching preserves the snapshot locale's
script and region, including Flutter's `zh_Hant` identifier.

## Saving and Refreshing

The App Group contains a derived display snapshot. The application's SQLite
database remains authoritative.

A Swift AppIntent runs in the app process without requesting its interface.
It starts a dedicated headless Flutter engine at `habitWidgetBackgroundMain`
and waits for Dart to finish before returning. The registrar bridge keeps
application and scene lifecycle delegates with the foreground engine.

Commands contain the displayed date and a compact record revision token. Dart
rechecks both inside the write transaction and uses the existing record and sync
helpers. Stale, duplicate, archived-habit, and malformed commands cannot overwrite
newer records. The revision includes sync counters to distinguish rapid undo/redo.
Native actions cross the engine boundary as Pigeon requests and typed results.
Dart adapts requests to the existing internal command parser; its URI is not
registered as an external URL scheme.

Undo creates the app's usual deletion marker; restoring a check-in preserves its
UUID. Reminder reconciliation and snapshot publication follow a successful commit.
The foreground app reloads its cached views after widget writes and republishes
snapshots after data, locale, and date changes. WebDAV uses the existing app sync
workflow rather than starting a sync from each widget action.

After a day or time-zone change, stale actions refresh the snapshot instead of
writing to another day. Timeline refresh is system-scheduled; it does not guarantee
an exact midnight update. The Refresh button can load the current day explicitly.

## Verification

Run the focused Dart tests and repository checks:

```sh
.flutter/bin/flutter test test/unit/providers/workflow/habit_widget_test.dart \
  test/unit/entries/habit_widget_entry_test.dart
CI=true make aio
CI=true make test
git diff --check
```

Use Xcode's Analyze action for the app and extension. Check each flavor's source
membership, App Group, extension plist, entitlements, and generated intent metadata
when changing native paths or build configuration.

Verify the following on a simulator and repeat lifecycle checks on a device:

- Both sizes in light and dark appearance, including empty and completed states.
- English, Russian, Simplified Chinese, and Traditional Chinese. Set the app
  language differently from the system language and check Refresh after midnight.
- Complete and undo without presenting the app UI; reopen the app to verify
  persistence and refreshed foreground views.
- Repeat after terminating the app process. Test manual force-quit separately
  on a physical device; a directly invoked intent test does not cover OS dispatch.
- Numeric and negative goals, repeated taps, and stale buttons after in-app
  record edits or habit archival.
- Refresh after a live midnight or time-zone change and verify the local date.
- Reminder reconciliation and actual notification delivery, plus a WebDAV round
  trip after a widget change.

Dart tests cover SQLite mutations, sync metadata, stale actions, rollback, and
method-channel acknowledgement. Builds and static analysis do not replace
Home Screen interaction, device lifecycle, notification, or WebDAV acceptance.
Record validation results for the tested revision in the PR, rather than keeping
historical test counts or simulator success claims in this guide.

<!-- refs -->

[user-guide]: ./Feature꞉-iOS-Widgets
[build-guide]: ./Dev꞉-Build-From-Source
[apple-metadata]: https://developer.apple.com/jp/documentation/xcode-release-notes/xcode-15_3-release-notes
