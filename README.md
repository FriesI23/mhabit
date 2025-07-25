<!-- markdownlint-disable no-inline-html -->
<!-- markdownlint-disable link-image-reference-definitions -->

# Table Habit

[![Build and Release][github-relaese-badge-svg]][github-relaese-badge]
[![Translation][weblate-badge]][weblate]
[![Latest Stable Version][app-verison-bage-svg]][github-release-page]
[![Latest Version][app-pre-verison-bage-svg]][github-release-page]
[![License][license-badge]][app-license]
[![Flutter][flutter-badge]][deps-flutter-version]
![WebDAV Supported](https://img.shields.io/badge/WebDAV-supported-brightgreen)

[![Trello][app-trello-badge]][app-trello-board]

"Table Habit" is an app that helps you establish and track your own micro habit.
It includes a complete set of growth curves and charts to help you build habits more effectively,
and keeps your data in sync across devices (currently via WebDAV, with more options coming soon).

Moreover, this app completely open source.

[![Get it on F-Droid][github-button]][github-myapp]
[![Get it on Falthub][get-it-on-flathub]][flathub-source]

**Android**:

[![Get it on F-Droid][fdroid-button]][fdroid-myapp]
[![Get it on LzzyOnDroid][lzzyondroid-button]][lzzyondroid-myapp]

**iOS**:

[![Get it on AltStore][get-it-on-altstore]][altstore-source]
[![Get it on SideStore][get-it-on-sidestore]][sidestore-source]

> Public beta will be available through `TestFlight` once app is distributed
> via the App Store.

<!-- [![Get it on Testflight][testflight-button]][ios-testflight-pre-release] -->

## Screenshots

[![Create new habit][create-new-habit-tb]][create-new-habit]
[![Check habit detail][check-habit-detail-tb]][check-habit-detail]
[![Habit heatmap calendar][habit-heatmap-tb]][habit-heatmap]
[![Habit display page][display-page-tb]][display-page]
[![Habit display page operation][display-op-tb]][display-op]
[![Habits export and import][export-and-import-tb]][export-and-import]

## Features

- A scoring system to help develop your own micro habits.
- Support both positive and negative habit.
- An easy-to-use interface for habit check in.
- Different colors used to distinguish between various habits.
- Easily export and import habits using a human-readable format (JSON).
- Adapt to `Material3` and `Dynamic Color` for Android 12 and later versions.
- Adaptation for landscape and large screen devices.
- _[Experimental] Support network sync with WebDAV._
- No ADs in this app.

You can customize each habit with the following options:

- Name
- Type (positive/negative)
- Description
- Color
- Daily goal
- Daily goal unit
- The maximum goal expected to be completed each day
- Frequency
- Start date
- Expected completion time
- Reminder
- etc.

## Supported platforms

| platform | build | publish                                                                                                                                                                                                                                                                   | desc.                      |
| -------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| android  | ✅    | <ul><li>[Github - apk][github-myapp]</li><li>[F-Droid][fdroid-myapp]</li></ul>                                                                                                                                                                                            |                            |
| ios      | ✅    | <ul><li>[Github - ipa][github-myapp]</li><li>[AltStore - custom source][altstore-source]</li><li>[SideStore - custom source][sidestore-source]</li><li>[SideLoad](#note-ios-installation-sideloading)</li><li>~~[TestFlight(Pre)][ios-testflight-pre-release]~~</li></ul> |                            |
| macos    | ✅    | <ul><li>[Github - dmg][github-myapp]</li><li>[HomeBrew - custom tap](#note-macos-installation-homebrew-cask)</li></ul>                                                                                                                                                    |                            |
| windows  | ✅    | <ul><li>[Github - msix][github-myapp] [(1)](supported-platforms-1)</li><li>[Scoop - custom bucket](#note-windows-installation-scoop)</li></ul>                                                                                                                            | limit features: `reminder` |
| linux    | ✅    | <ul><li>[Github - flatpak][github-myapp] [(1)](supported-platforms-1)</li><li>[FLathub][flathub-source]</li></ul>                                                                                                                                                         | limit features: `reminder` |

> <a name="supported-platforms-1"></a> 1. Windows & Linux versions are still in beta,
> some features may be limited or unstable.

### Note: iOS Installation (Sideloading)

1. Install [**AltStore**][altstore] / [**SideStore**][sidestore] follow official instructions.
2. Download `mhabit-unsigned.ipa` on your iOS device directly from the [latest releases][github-myapp].
3. Install this IPA file.

### Note: macOS Installation (HomeBrew Cask)

1. Add Third-Party Repo by running `brew tap FriesI23/brew-repo`.
2. Install by running:

```shell
brew install table-habit
# for pre-release version, use:
brew install table-habit@beta
```

### Note: Windows Installation (Scoop)

1. Add Third-Party Bucket by runngin `scoop bucket add friesi23-bucket https://github.com/FriesI23/scoop-bucket`
2. Install by running:

```pwsh
# Note: Administrator privileges are required during first installation
# because a self-signed certificate needs to be installed.
#
# e.g. gsudo scoop install friesi23-bucket/mhabit

# install
scoop install friesi23-bucket/mhabit
# or
scoop install friesi23-bucket/mhabit-beta
```

### Note: Windows MSIX Insaller

On a first-time attempt to install this MSIX, following prompt may appear:

> This app package’s publisher certificate could not be verified.
> Contact your system administrator or the app developer to obtain
> a new app package with verified certificates.
> The root certificate and all immediate certificates of the signature
> in the app package must be verified (0x800B010A)

This is because the MSIX installation package provided in Github/Releases/Assets
is a self-signed version, corresponding certificate must be trusted
on each machine which attempt to install it.

Install certificate by following the steps below:

> See [**"Installing a test certificate directly from an MSIX package"**][msix-install-cert]
> for steps with screenshots.

1. Right click msix installer package, select **Properties**
2. Switch to **Digital Signatures** tab and click signer under **Embedded Signatures**
3. Click **Details**, In new window click **View Certificate**
4. In new window (Certificate), click **Install Certificate**
5. In **Certificate Import Wizard** window:
   1. Select **Local Machine** and click **Next**
   2. Select **Place all certificates in the following store**
   3. Click **Browse** and select **Trusted Root Certification Authorities**
   4. Click **Finish**.
6. Finally a dialog with "_The import was successful._" should be poped-up.

Or execute commands below:

```powershell
# run at administrator
$signature = Get-AuthenticodeSignature -FilePath "\path\to\your\mhabit.msix"
$certificate = $signature.SignerCertificate
Export-Certificate -Cert $certificate -FilePath ".\mhabit.crt"
Import-Certificate -FilePath ".\mhabit.crt" -CertStoreLocation Cert:\LocalMachine\Root
```

After operations above, this MSIX package should now be able to install successfully.

> Trusting self-signed certificate always carries some risks.
> Skipping signature verification to install via command below is also allowed:
>
> ```powershell
> Add-AppPackage -Path "\path\to\your\mhabit.msix" -AllowUnsigned
> ```

## Todo

| status      | progress                   | desc.                 |
| ----------- | -------------------------- | --------------------- |
| In Progress | Publish to Flathub         |                       |
| -           | Publish to Google Play     |                       |
| In Progress | Publish to iOS App Store   | Waiting for Review 😔 |
| -           | Publish to macOS App Store |                       |

## Build from source

Make sure your flutter version same as `.flutter`, You can use `fvm`` to keep
multiple versions on your local machine, or simply use this submodule to build it!

1. In the project folder, run `flutter pub get`
2. Launch an emulator or connect a device for Android, iOS, Windows, macOS, or Linux
3. Run `flutter run --debug` (optional: `--profile` or `--release`)

### Building for iOS / macOS

iOS required flavor, use `flutter run --debug --flavor f_dev/f_generic` instead command above.

### Building for Linux Desktop

**requires:**

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

5. Then run `flutter build linux --release`, once finished you should see:

   ```shell
   Building Linux application...
   ✓ Built build/linux/x64/release/bundle/mhabit
   ```

6. Enjoy by running the ouput binary `build/linux/x64/release/bundle/mhabit`

## Configuring WebDAV Synchronization (Beta)

You will need a compatible server for it, e.g. Nextcloud, Koofr, etc. You will find some configuration examples below.

### Nextcloud Configuration

1. Create a dedicated app password in your Nextcloud:

   - Go to Profile → Settings → Security → bottom of the page
   - Enter an app name (e.g., "mhabit" or "test") and confirm your password
     ![Create new app][nextcloud-test-app]
   - Save the generated password
     ![Retrieve app credentials][nextcloud-test-app-credentials]

2. Configure mhabit with your Nextcloud server:

   - Go to Settings → Sync Options → Sync Server → Current: WebDAV
   - Enter your server URL (format: `https://example.com/remote.php/dav/files/[nextcloud user]`)
     ![Server configuration][nextcloud-test-app-server-config]

3. Perform initial sync:

   - Now return back to Settings
   - Click the refresh button next to `Sync Now`
   - Successful connection will display sync status
     ![First synchronization][nextcloud-test-app-first-sync]

4. Enjoy automatic sync:
   - Additional syncs will occur without other modals
   - Verify sync status by checking the last sync timestamp
     ![Success synchronizations][nextcloud-test-app-sync-success]

### Koofr Configuration

Follow the ["How do I connect a service to Koofr through WebDAV?"][koofr-webdav]
guide to create an application password and complete the connection settings in the app.

> A1: Don’t use the root directory directly. Instead, create your own folder inside Koofr,
> e.g. `https://app.koofr.net/dav/Koofr/your-folder-name/`
>
> A2: If you see 429 error, please refer to [Error 429][koofr-err429].

## Contributing

I am an independent developer and do not have professional expertise in writing
documentation and project management.

If you have relevant knowledge and are willing to contribute to this project,
you can help me improve the documentation, e.g `README.md` file.

When contribute code to this project, please try to follow
[this][style-guide-for-flutter] guideline.

## Donate

[!["Buy Me A Coffee"][buymeacoffee-badge]](https://www.buymeacoffee.com/d49cb87qgww)
[![Alipay][alipay-badge]](docs/README/images/donate-alipay.jpg)
[![WechatPay][wechat-badge]](docs/README/images/donate-wechatpay.png)

[![ETH][eth-badge]][eth-addr]
[![BTC][btc-badge]][btc-addr]

> Visit [**Donors**][page-donors] page for full list.

## Translation

Feel free to join and help with the translation for `Table Habit`,
you can follow [docs/add_new_locale_support][l10n-doc] to get incolved.

<!-- ![L10nStat][l10n-stat-pic] -->

[![Engage][weblate-engage-badge]][weblate-engage]

## License

```text
Copyright 2023 Fries_I23

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[create-new-habit]: docs/README/images/create-new-habit.gif
[create-new-habit-tb]: docs/README/images/create-new-habit-tb.gif
[check-habit-detail]: docs/README/images/check-habit-detail.gif
[check-habit-detail-tb]: docs/README/images/check-habit-detail-tb.gif
[habit-heatmap]: docs/README/images/habit-heatmap.gif
[habit-heatmap-tb]: docs/README/images/habit-heatmap-tb.gif
[display-page]: docs/README/images/habit-display-page.gif
[display-page-tb]: docs/README/images/habit-display-page-tb.gif
[display-op]: docs/README/images/habit-display-op.gif
[display-op-tb]: docs/README/images/habit-display-op-tb.gif
[export-and-import]: docs/README/images/export-and-import.gif
[export-and-import-tb]: docs/README/images/export-and-import-tb.gif
[fdroid-button]: docs/README/images/fdroid-get-it-on.png
[fdroid-myapp]: https://f-droid.org/packages/io.github.friesi23.mhabit
[lzzyondroid-button]: docs/README/images/lzzyondroid-get-it-on.png
[lzzyondroid-myapp]: https://apt.izzysoft.de/fdroid/index/apk/io.github.friesi23.mhabit
[get-it-on-altstore]: https://raw.githubusercontent.com/FriesI23/altstore-repo/refs/heads/master/assets/get-it-on-altstore.png
[get-it-on-sidestore]: https://raw.githubusercontent.com/FriesI23/altstore-repo/refs/heads/master/assets/get-it-on-sidestore.png
[altstore-source]: https://play4fun.friesi23.cn/altstore-repo/pages/altstore.html
[sidestore-source]: https://play4fun.friesi23.cn/altstore-repo/pages/sidestore.html
[testflight-button]: docs/README/images/testflight-get-it-on.png
[github-button]: docs/README/images/github-get-it-on.png
[github-myapp]: https://github.com/FriesI23/mhabit/releases/latest
[get-it-on-flathub]: docs/README/images/flathub-get-it-on.png
[flathub-source]: https://flathub.org/apps/io.github.friesi23.mhabit
[github-relaese-badge]: https://github.com/FriesI23/mhabit/actions/workflows/app-release.yml
[github-relaese-badge-svg]: https://github.com/FriesI23/mhabit/actions/workflows/app-release.yml/badge.svg
[github-release-page]: https://github.com/FriesI23/mhabit/releases
[app-license]: https://github.com/FriesI23/mhabit/blob/main/LICENSE
[flutter-badge]: https://img.shields.io/badge/_Flutter_-3.24.5-grey.svg?&logo=Flutter&logoColor=white&labelColor=blue
[deps-flutter-version]: https://github.com/flutter/flutter/tree/3.24.5
[license-badge]: https://img.shields.io/github/license/FriesI23/mhabit
[app-verison-bage-svg]: https://img.shields.io/github/v/release/FriesI23/mhabit
[app-pre-verison-bage-svg]: https://img.shields.io/github/v/release/FriesI23/mhabit?include_prereleases&label=pre-release
[app-trello-badge]: https://img.shields.io/badge/Trello-%23026AA7.svg?style=for-the-badge&logo=Trello&logoColor=white
[app-trello-board]: https://trello.com/b/ayPTUeQj/mhabit
[l10n-doc]: docs/add_new_locale_support.md
[buymeacoffee-badge]: https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black
[alipay-badge]: https://img.shields.io/badge/alipay-00A1E9?style=for-the-badge&logo=alipay&logoColor=white
[wechat-badge]: https://img.shields.io/badge/WeChat-07C160?style=for-the-badge&logo=wechat&logoColor=white
[eth-badge]: https://img.shields.io/badge/Ethereum-3C3C3D?style=for-the-badge&logo=Ethereum&logoColor=white
[eth-addr]: https://etherscan.io/address/0x35FC877Ef0234FbeABc51ad7fC64D9c1bE161f8F
[btc-badge]: https://img.shields.io/badge/Bitcoin-000000?style=for-the-badge&logo=bitcoin&logoColor=white
[btc-addr]: https://blockchair.com/bitcoin/address/bc1qz2vjews2fcscmvmcm5ctv47mj6236x9p26zk49
[style-guide-for-flutter]: https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo
[weblate-badge]: https://hosted.weblate.org/widget/mhabit/app-view/svg-badge.svg
[weblate]: https://hosted.weblate.org/projects/mhabit/
[weblate-engage-badge]: https://hosted.weblate.org/widget/mhabit/app-view/multi-auto.svg
[weblate-engage]: https://hosted.weblate.org/engage/mhabit/
[sqflite-ffi-linux]: https://pub.dev/packages/sqflite_common_ffi#linux
[flutter-linux]: https://docs.flutter.dev/get-started/install/linux/desktop#development-tools
[msix-install-cert]: https://www.advancedinstaller.com/install-test-certificate-from-msix.html
[fss-linux]: https://pub.dev/packages/flutter_secure_storage#configure-linux-version
[ios-testflight-pre-release]: https://testflight.apple.com/join/aJ5PWqaR
[altstore]: https://altstore.io/
[sidestore]: https://sidestore.io/
[page-donors]: https://github.com/FriesI23/mhabit/wiki/Donors
[nextcloud-test-app]: docs/README/images/nextcloud-test-app.png
[nextcloud-test-app-credentials]: docs/README/images/nextcloud-test-app-credentials.png
[nextcloud-test-app-server-config]: docs/README/images/nextcloud-test-app-server-config.png
[nextcloud-test-app-first-sync]: docs/README/images/nextcloud-test-app-first-sync.png
[nextcloud-test-app-sync-success]: docs/README/images/nextcloud-test-app-sync-success.png
[koofr-webdav]: https://app.koofr.net/help/webdav#a-idhow-do-i-connect-a-service-to-koofr-through-webdava-how-do-i-connect-a-service-to-koofr-through-webdav
[koofr-err429]: https://app.koofr.net/help/webdav#a-iderror-429a-error-429
