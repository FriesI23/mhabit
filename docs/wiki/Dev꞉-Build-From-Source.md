<!-- markdownlint-disable no-inline-html first-line-heading -->

Make sure your flutter version same as `.flutter`, You can use `fvm` to keep
multiple versions on your local machine, or simply use this submodule to build it!

1. In the project folder, run `flutter pub get`
2. Launch an emulator or connect a device for Android, iOS, Windows, macOS, or Linux

Generally, you can build the app with `flutter build` (default: `--release`),
or run it directly using `flutter run` (default: `--debug`).

### Release channels

Set `APP_DISTRIBUTION` at compile time to choose the intended release channel,
independently of platform and flavor. Missing, empty, or unknown values default
to `github`.

```shell
flutter build appbundle --flavor f_generic --dart-define=APP_DISTRIBUTION=google_play
```

Supported values are `github`, `google_play`, `app_store`, `microsoft_store`,
`fdroid`, `flathub`, and `custom`.

Use **Settings → Developer → Support channel** to change the channel for the
current process, then **Show support prompt now** to preview it. Restarting
restores the build default.

### Formatting Swift

On macOS, use the same Xcode toolchain as CI (Swift 6.1+) and run from the
application repository root:

```shell
make format-swift  # Format handwritten Swift
make check-swift   # Check without writing files
```

Formatting options are defined in `.swift-format`. Generated files, dependencies,
and build caches are excluded.

`make format` and `make fix` also format Swift; `make aio` and CI run the check.
These aggregate commands skip Swift on other platforms.

### Building for Android

For reproducible APKs and app bundles, select the NDK pinned in the checked-out
tag before running Flutter. Gradle reads `app.ndkVersion` directly. Flutter
native build hooks use `ANDROID_NDK_HOME`. With `ANDROID_HOME` set to your SDK
directory, run these commands from the repository root:

```shell
revision=$(sed -n 's/^app\.ndkVersion=//p' android/gradle.properties)
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "ndk;$revision"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/$revision"
```

To reproduce a GitHub split APK, start from a clean checkout on Linux. After
`flutter pub get`, apply the JNI build-ID patch from
`.github/actions/patch_android_jni_build_id/action.yml` in that tag, then run
`flutter build apk --release --split-per-abi`.

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

1. Install the following packages for [SQFlite database][sqflite-ffi-linux],
   [`flutter_secure_storage`][fss-linux], and the native window build hook:

   ```shell
   sudo apt-get -y install \
      lld-14 libsqlite3-0 libsqlite3-dev \
      libsecret-1-dev libjsoncpp-dev \
      libgtk-3-dev libx11-dev libxi-dev
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

5. Then run `flutter build linux --release --flavor f_generic`, once finished you should see:

   ```shell
   Building Linux application...
   ✓ Built build/linux/<arch>/f_generic/release/bundle/mhabit
   ```

6. Enjoy by running the output binary:
   - x86_64: `build/linux/x64/f_generic/release/bundle/mhabit`
   - aarch64: `build/linux/arm64/f_generic/release/bundle/mhabit`

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

Default build outputs are located at `build/windows/<arch>/f_generic/runner/Release`
(`x64` or `arm64`).

> To build `msix` package, refer to `scripts\build_msix.cmd`
> and `.github/workflows/release-app.yml#jobs.build-windows-msix`.

Windows uses Flutter's native flavors, with `f_generic` selected by default.
Following flavors are allowed:

- `f_dev`

  - \# For development
  - productName: `mhabit-dev`
  - UserData: `%AppData%\Roaming\io.github.friesi23\mhabit-dev`
  - command:

    ```pwsh
    flutter build windows --flavor f_dev <other optional args>
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
    flutter build windows --flavor f_generic <other optional args>
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
