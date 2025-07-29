<!-- markdownlint-disable no-inline-html first-line-heading -->

Provide multi install ways on each platform,
and ensure at least one installable package is available for download
from the [Release page][github-releases].

## Android

### F-Droid / LzzLzzyOnDroid

- Stable Version
- Install an Update from Store

Search and download app using ["F-Droid App Store"][fdroid-app] or download by visiting:

| ["F-Droid"][fdroid-myapp] | ["LzzLzzyOnDroid"][lzzyondroid-myapp] |

### Github: APK

- Stable Version
- Beta Version

Fetch last version's `*.apk` file from ["Github Releases"][github-releases] page.
Beta version marked as `pre-release`.

## iOS

> Store version is currently stuck in the `Waiting for Review` status for unknown reasons,
> so only the `SideLoaded` version is available.

### AltStore / SideStore - Custom Source

- Stable Version
- Install an Update from Store

> **Requires** either a free Apple ID (with 7-day / 3 self-signed apps limit),
> a paid developer account, or EU users on iOS 17.4+ with sideloading enabled.

1. Install [**AltStore**][altstore] / [**SideStore**][sidestore] follow official instructions.
2. Press ["AltStore Source"][altstore-source] / ["SideStore Source"][sidestore-source],
   then press `Add to *Store` on opened page, this will add new source
   named `Friesi23's Source` at your store's app.
3. Click `Friesi23's Source`, find `Table Habit` and tap install button.

### Github: IPA

- Stable Version
- Beta Version

> **Requires** either a free Apple ID (with 7-day / 3 self-signed apps limit),
> a paid developer account, or a jailbroken device.

1. Install a **Sideloaded-support Store** or a **Jailbreak-Support Store** (e.g. `ThrollStore`).
2. Download `mhabit-unsigned.ipa` on your iOS device directly from ["Github Releases"][github-releases].
3. Open Store app and switch to `My Apps` Tab, Click `+` button in the top-left corner of the screen,
   select prev-downloaded `.ipa` file.

## macOS

### HomeBrew - Custom Tap

- Stable Version
- Beta Version
- Install an Update by `brew update && brew upgrade` command

1. Open `Terminal.app`.
2. Add Third-Party Repo by running `brew tap FriesI23/brew-repo`.
3. Install by running:

```shell
brew install table-habit
# for pre-release version, use:
brew install table-habit@beta
```

### Github: DMG

- Stable Version
- Beta Version

1. Fetch last version's `*.dmg` file from ["Github Releases"][github-releases] page.
   Beta version marked as `pre-release`.
2. Double click `dmg` file, then drag app to `/Applications` folder (or `~/Applications`).

## Linux

### Flathub

- Stable Version
- Install an Update from Store

Download by visiting ["Flathub"][flathub-myapp] or running:

```shell
flatpak install flathub io.github.friesi23.mhabitTable Habit
```

Ensure Flatpak is properly installed and Flathub is correctly configured,
more info see: [`Flathub - Setup`](https://flathub.org/setup)

### Github: Flatpak

- Stable Version
- Beta Version

1. Fetch last version's `*.flatpak` file from ["Github Releases"][github-releases] page.
   Beta version marked as `pre-release`.

   > Ensure to download correct architecture (aarch64/x86_64).

2. Running command below:

   ```shell
   flatpak install --user mhabit-<arch>.flatpak -y
   ```

## Windows

### Scoop - Custom Bucket

- Stable Version
- Beta Version
- Install an Update by `scoop update / upgrade`

Ensure Scoop is properly installed, more info see: [Scoop - Quickstart](https://scoop.sh/)

1. Add Third-Party Bucket by running `scoop bucket add friesi23-bucket https://github.com/FriesI23/scoop-bucket`
2. Install by running:

```powershell
# Note: Administrator privileges are required during first installation
# because a self-signed certificate needs to be installed.
#
# e.g. gsudo scoop install friesi23-bucket/mhabit

# install
scoop install friesi23-bucket/mhabit
# or
scoop install friesi23-bucket/mhabit-beta
```

### Github: MSIX

- Stable Version
- Beta Version

1. Fetch last version's `*.msix` file from ["Github Releases"][github-releases] page.
   Beta version marked as `pre-release`.
2. Double click `MSIX` file and install.
   > If installtion failed due to signature issues,
   > please refer to [this](#cant-install-windows-app-via-msix-installer-show-signature-error) FAQ.

## FAQ

### Can't Install Windows App via MSIX Installer, show signature error

On a first-time attempt to install this MSIX, following prompt may appear:

> This app package’s publisher certificate could not be verified.
> Contact your system administrator or the app developer to obtain
> a new app package with verified certificates.
> The root certificate and all immediate certificates of the signature
> in the app package must be verified (0x800B010A).

This is because the MSIX installation package provided in Github/Releases/Assets
is a self-signed version, corresponding certificate must be trusted
on each machine which attempt to install it.

Install the certificate by following theese steps:

> See [**"Installing a test certificate directly from an MSIX package"**][msix-install-cert]
> for steps with screenshots.

1. Right click msix installer package, select **Properties**
2. Switch to **Digital Signatures** tab and click signer under **Embedded Signatures**
3. Click **Details**, in new window click **View Certificate**
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

<!-- refs -->

[github-releases]: https://github.com/FriesI23/mhabit/releases
[fdroid-app]: https://f-droid.org/F-Droid.apk
[fdroid-myapp]: https://f-droid.org/packages/io.github.friesi23.mhabit
[lzzyondroid-myapp]: https://apt.izzysoft.de/fdroid/index/apk/io.github.friesi23.mhabit
[altstore]: https://altstore.io/
[sidestore]: https://sidestore.io/
[altstore-source]: https://play4fun.friesi23.cn/altstore-repo/pages/altstore.html
[sidestore-source]: https://play4fun.friesi23.cn/altstore-repo/pages/sidestore.html
[flathub-myapp]: https://flathub.org/apps/io.github.friesi23.mhabit
[msix-install-cert]: https://www.advancedinstaller.com/install-test-certificate-from-msix.html

---

1. [2025-07-28] Migrated from: [`FriesI23/mhabit/README.md`][_migrate]

[_migrate]: https://github.com/FriesI23/mhabit/blob/09f6cabd6f7b2fa3aca1c087d48e9a6069c28033/README.md
