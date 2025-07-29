<!-- markdownlint-disable no-inline-html first-line-heading -->

Make sure your flutter version same as `.flutter`, You can use `fvm`` to keep
multiple versions on your local machine, or simply use this submodule to build it!

1. In the project folder, run `flutter pub get`
2. Launch an emulator or connect a device for Android, iOS, Windows, macOS, or Linux

Generally, you can build the app with `flutter build` (default: `--release`),
or run it directly using `flutter run` (default: `--debug`).

### Building for Android

Following Android flavors are allowed:

- `f_dev`
  - \# For development
  - appId: `io.github.friesi23.mhabit.dev`
  - command:
    - `flutter run --flavor f_dev <other optional args>`
    - `flutter build --flavor f_dev <other optional args>`
- `f_generic`
  - **default**
  - \# For Publish
  - appId: `io.github.friesi23.mhabit`
  - command:
    - `flutter run <other optional args>`
    - `flutter run --flavor f_generic <other optional args>`
    - `flutter build <other optional args>`
    - `flutter build --flavor f_generic <other optional args>`

Build outputs located at `build/app/outputs`.

### Building for iOS / macOS

iOS requires a scheme. Supported schemes are as follows:

- `f_dev`
  - \# For development
  - appId: `io.github.friesi23.mhabit.dev`
  - command:
    - `flutter run --flavor f_dev <other optional args>`
    - `flutter build --flavor f_dev <other optional args>`
- `f_generic`
  - \# For Publish
  - appId: `io.github.friesi23.mhabit`
  - command:
    - `flutter run --flavor f_generic <other optional args>`
    - `flutter build --flavor f_generic <other optional args>`
- `f_store`
  - \# For Publish to Apple Store
  - appId: `io.github.friesi23.mhabit.store`
  - command:
    - `flutter run --flavor f_store <other optional args>`
    - `flutter build --flavor f_store <other optional args>`

Build outputs located at:

- iOS: `build/ios/` (e.g. `build/ios/ipa`)
- macOS: `uild/macos/Build/Products` (e.g. `build/macos/Build/Products/Release`)

> To build `dmg` package, refer to `scripts/build_dmg.sh`
> and `.github\workflows\app-release.yml#jobs.build-macos-dmg`.

### Building for Linux Desktop

1. installing the following packages for [SQFlite database][sqflite-ffi-linux]
   and [`flutter_secure_storage`][fss-linux]:

   ```shell
   sudo apt-get -y install \
      libsqlite3-0 libsqlite3-dev \
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

6. Enjoy by running the ouput binary:
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

Build outputs located at `build\windows\x64\runner` (e.g. `build\windows\x64\runner\Release`)

> To build `msix` package, refer to `scripts\build_msix.cmd`
> and `.github\workflows\app-release.yml#jobs.build-windows-msix`.

<!-- refs -->

[sqflite-ffi-linux]: https://pub.dev/packages/sqflite_common_ffi#linux
[fss-linux]: https://pub.dev/packages/flutter_secure_storage#configure-linux-version
[flutter-linux]: https://docs.flutter.dev/get-started/install/linux/desktop#development-tools
[flutter-windows]: https://docs.flutter.dev/get-started/install/windows/desktop

---

1. [2025-07-29] Migrated from: [`FriesI23/mhabit/README.md`][_migrate]

[_migrate]: https://github.com/FriesI23/mhabit/blob/09f6cabd6f7b2fa3aca1c087d48e9a6069c28033/README.md
