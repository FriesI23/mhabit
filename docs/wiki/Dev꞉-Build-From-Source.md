<!-- markdownlint-disable no-inline-html first-line-heading -->

Make sure your flutter version same as `.flutter`, You can use `fvm` to keep
multiple versions on your local machine, or simply use this submodule to build it!

1. In the project folder, run `flutter pub get`
2. Launch an emulator or connect a device for Android, iOS, Windows, macOS, or Linux

Generally, you can build the app with `flutter build` (default: `--release`),
or run it directly using `flutter run` (default: `--debug`).

### Formatting Swift

Each language uses its own formatter and conventions: `dart format` for Dart,
`swift format` for Swift. The project shares Make/CI entrypoints and applies a
few readability preferences to Swift rather than reproducing Dart's layout.

Use the same Swift toolchain as CI when comparing formatting results. CI selects
Xcode through its setup action; locally, use `DEVELOPER_DIR` or your environment's
toolchain selection. The script uses `swift format` without version checks.

```shell
make format-swift
make check-swift
```

Both targets use the current Swift toolchain, explicit `.swift-format`
configuration and Git-discovered handwritten Swift files, including new files.
Generated Swift (`*.g.swift`, `GeneratedPluginRegistrant.swift`), dependencies
and build caches are excluded. Checks are strict and do not write files.

`.swift-format` sets two-space indentation and a 100-column limit. This
follows the [Google Swift style](https://google.github.io/swift/) referenced by
[Flutter's plugin contribution guide](https://github.com/flutter/packages/blob/main/CONTRIBUTING.md#style).
The remaining options are project readability preferences:

- `respectsExistingLineBreaks: true`: preserve handwritten line breaks, especially
  one modifier per line in SwiftUI. Short getters can retain either single-line
  or multiline layout.
- `lineBreakBetweenDeclarationAttributes: true`: put each declaration attribute
  on its own line, above the declaration.
- `lineBreakAroundMultilineExpressionChainComponents: true`: separate wrapped
  chain components from the surrounding calls. This does not force every short
  modifier onto a separate line; write those line breaks explicitly.
- `lineBreakBeforeEachArgument: true`: put wrapped arguments on separate lines.
- `multilineTrailingCommaBehavior: alwaysUsed`: consistently add trailing commas
  in multiline lists, rather than retaining the input's comma style. This syntax
  requires a Swift 6.1+ compiler, provided by the CI Xcode selection.

Other settings use the current tool's defaults. Keep `rules` omitted to
preserve the built-in rule set; specifying that dictionary replaces it rather
than merging individual overrides. Review formatting changes when updating the
toolchain selected by CI or the repository configuration.

On macOS, `make format` and `make fix` also format Swift; `make aio` finishes
with a Swift check. Other platforms silently skip Swift in these aggregate
commands; standalone Swift targets require macOS. Direct Melos commands remain
Dart-only. CI runs `make check-swift` for pull requests and main branch pushes.

### Building for Android

Following Android flavors are allowed:

- `f_dev`

  - \# For development
  - appId: `io.github.friesi23.mhabit.dev`
  - command:

    ```shell
    flutter run --flavor f_dev <other optional args>
    flutter build --flavor f_dev <other optional args>
    ```

- `f_generic`

  - **default**
  - \# For Publish
  - appId: `io.github.friesi23.mhabit`
  - command:

    ```shell
    flutter run <other optional args>
    flutter run --flavor f_generic <other optional args>
    flutter build <other optional args>
    flutter build --flavor f_generic <other optional args>
    ```

Build outputs located at `build/app/outputs`.

### Building for iOS / macOS

For iOS widget extension signing, App Groups, and verification, see
[Developing iOS Widgets](./Dev꞉-iOS-Widgets).

iOS requires a scheme. Supported schemes are as follows:

- `f_dev`

  - \# For development
  - appId: `io.github.friesi23.mhabit.dev`
  - command:

    ```shell
    flutter run --flavor f_dev <other optional args>
    flutter build --flavor f_dev <other optional args>
    ```

- `f_generic`

  - \# For Publish
  - appId: `io.github.friesi23.mhabit`
  - command:

    ```shell
    flutter run --flavor f_generic <other optional args>
    flutter build --flavor f_generic <other optional args>
    ```

- `f_store`

  - \# For Publish to Apple Store
  - appId: `io.github.friesi23.mhabit.store`
  - command:

    ```shell
    flutter run --flavor f_store <other optional args>
    flutter build --flavor f_store <other optional args>
    ```

Build outputs located at:

- iOS: `build/ios/` (e.g. `build/ios/ipa`)
- macOS: `uild/macos/Build/Products` (e.g. `build/macos/Build/Products/Release`)

> To build `dmg` package, refer to `scripts/build_dmg.sh`
> and `.github\workflows\app-release.yml#jobs.build-macos-dmg`.

### Building for Linux Desktop

1. Installing the following packages for [SQFlite database][sqflite-ffi-linux]
   and [`flutter_secure_storage`][fss-linux]:

   ```shell
   sudo apt-get -y install \
      lld-14 libsqlite3-0 libsqlite3-dev \
      libsecret-1-dev libjsoncpp-dev
   ```

2. Please follow this [official guide][flutter-linux] to initialize your
   Flutter development environment.

3. Once you've got the following result with the command `flutter doctor` you are good to go:

   ```shell
   Doctor summary (to see all details, run flutter doctor -v):
   [✓] Flutter (Channel stable, X.X.X, on Your Linux Platform)
   (...)
   [✓] Linux toolchain - develop for Linux desktop
   (...)
   ```

4. In project folder, run `flutter pub get`

5. Then run `flutter build linux`, once finished you should see:

   ```shell
   Building Linux application...
   ✓ Built build/linux/<arch>/release/bundle/mhabit
   ```

6. Enjoy by running the output binary:
   - x86_64: `build/linux/x64/release/bundle/mhabit`
   - aarch64: `build/linux/arm64/release/bundle/mhabit`

> To build `flatpak` package, refer to `scripts/build_flatpak_pre.sh`, `scripts/build_flatpak.sh`
> and `.github/workflows/app-release.yml#jobs.build-linux||build-linux-flatpak`.

### Building for Windows Desktop

Please follow this [official guide][flutter-windows] to initialize your
Flutter development environment first.

Then run commands below:

```shell
flutter pub get
flutter build windows
```

Default build outputs are located at `build\windows\x64\runner` (e.g. `build\windows\x64\runner\Release`)

> To build `msix` package, refer to `scripts\build_msix.cmd`
> and `.github\workflows\app-release.yml#jobs.build-windows-msix`.

This project implement a variable-based approach to simulate Windows flavors.
Following flavors are allowed:

- `f_dev`

  - \# For development
  - productName: `mhabit-dev`
  - UserData: `%AppData%\Roaming\io.github.friesi23\mhabit-dev`
  - command:

    ```pwsh
    $env:APP_FLAVOR_WIN='f_dev'
    flutter build windows <other optional args>
    Remove-Item Env:\APP_FLAVOR_WIN
    ```

- `f_generic`

  - **default**
  - \# For Publish
  - productName: `mhabit`
  - UserData: `%AppData%\Roaming\io.github.friesi23\mhabit`
  - command:

    ```pwsh
    # without flavor
    flutter build windows <other optional args>
    ```

    ```pwsh
    $env:APP_FLAVOR_WIN='f_generic'
    flutter build windows <other optional args>
    Remove-Item Env:\APP_FLAVOR_WIN
    ```

<!-- refs -->

[sqflite-ffi-linux]: https://pub.dev/packages/sqflite_common_ffi#linux
[fss-linux]: https://pub.dev/packages/flutter_secure_storage#configure-linux-version
[flutter-linux]: https://docs.flutter.dev/platform-integration/linux/setup
[flutter-windows]: https://docs.flutter.dev/platform-integration/windows/setup

---

1. [2025-07-29] Migrated from: [`FriesI23/mhabit/README.md`][_migrate].
2. [2025-08-31] Add guidance of variable-based flavor support for Windows platform.

[_migrate]: https://github.com/FriesI23/mhabit/blob/09f6cabd6f7b2fa3aca1c087d48e9a6069c28033/README.md
