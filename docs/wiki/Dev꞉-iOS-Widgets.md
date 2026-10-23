<!-- markdownlint-disable no-inline-html first-line-heading -->

Widgets require iOS 17 or later. For adding and using a widget, see
[iOS Widgets][user-guide].

### Build and Signing

Follow [Build From Source][build-guide] using the repository's Flutter SDK.
Open `ios/Runner.xcworkspace` and select the same development team for
`Runner` and `HabitWidgetExtension`. Enable the matching App Group on both targets:

<!-- markdownlint-disable MD013 -->
| Scheme | App Group |
| --- | --- |
| default / `f_generic` | `group.io.github.friesi23.mhabit.widgets` |
| `f_dev` | `group.io.github.friesi23.mhabit.dev.widgets` |
| `f_store` | `group.io.github.friesi23.mhabit.store.widgets` |
<!-- markdownlint-enable MD013 -->

The extension bundle ID is the app bundle ID followed by `.widgets`.
If changing the app identifier, update the App Groups and signing profiles too.
Distribution requires provisioning profiles for both targets.

Run commands from the application repository root:

```shell
.flutter/bin/flutter build ios --simulator --debug --flavor f_dev
.flutter/bin/flutter build ios --release --no-codesign --flavor f_store
```

Open the app once to load its data, then add a widget from the Home Screen.

### Source Files

Widget sources are under `ios/HabitWidget/`:

- `App/`: background Flutter engine and native bridge.
- `Extension/`: widget views, resources, and extension configuration.
- `Shared/`: snapshot models, configuration, and action intents.

The Dart entrypoint is `lib/entries/habit_widget/entry.dart`.
After changing `pigeons/habit_widget.dart`, run `make gen` to regenerate the bridge.

The widget has not been released. Snapshots and shared holds use only the current
v2 structure, without development-format migrations or field defaults. The shared
hold file is `habit_widget_holds.json`; locale comes from the snapshot's root
`locale`. Action URIs require an explicit `automatic` or `fixed` source.
After changing development formats, reopen the app to publish a current snapshot;
old widget snapshots and holds are not migrated. Snapshot and hold versions are
separate raw-value enums decoded by Codable. Accept only explicitly supported
versions; route future supported formats at the decoding boundary.

Maintain widget text in `Extension/*.lproj/Localizable.strings` with bare
PascalCase `HomeWidget*` keys. `make gen` fills missing entries from ARB through
`configs/l10n_strings_refs.json`, preserving existing translations.
Runtime text falls back from the selected language to `en.lproj`, then to
the hardcoded English default in Swift. Keep its enum switch exhaustive.

### Testing

Run these commands on macOS with Xcode and an iOS 17+ simulator installed:

```shell
make test-all
make test-integration
```

`test-all` runs unit tests; `test-integration` runs macOS and iOS integration tests.
For widget-only checks, use `make test-ios` or `make test-ios-integration`.
Integration builds default to `f_generic`. To select another flavor or simulator:

```shell
make test-ios-integration FLAVOR=f_dev \
  IOS_TEST_DESTINATION='platform=iOS Simulator,id=<UDID>'
```

Results are saved under `build/test-results/native/`.
Also check all three widget sizes on the Home Screen, including large widgets
with six habits, fixed habits before automatic ones, and a single completion
message when all habits are complete and no rows remain. Verify check-ins in
the app.

<!-- refs -->

[user-guide]: ./Feature꞉-iOS-Widgets
[build-guide]: ./Dev꞉-Build-From-Source
