<!-- omit from toc -->
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/README/images/feature-hero-showcase-dark.png" />
    <source media="(prefers-color-scheme: light)" srcset="docs/README/images/feature-hero-showcase.png" />
    <img src="docs/README/images/feature-hero-showcase.png" alt="Table Habit — cross-platform habit tracker" width="800" />
  </picture>
</p>

<p align="center">
  <img src="assets/logo/icon-1024x1024.png" alt="Table Habit Logo" width="96" />
</p>
<h1 align="center">Table Habit</h1>
<p align="center"><strong>Track micro habits. Grow every day.</strong></p>

<p align="center">
  <a href="https://github.com/FriesI23/mhabit/releases"><img src="https://img.shields.io/github/v/release/FriesI23/mhabit?style=flat-square&label=stable&color=success" alt="Stable version"></a>
  <a href="https://github.com/FriesI23/mhabit/releases"><img src="https://img.shields.io/github/v/release/FriesI23/mhabit?style=flat-square&include_prereleases&label=pre-release&color=orange" alt="Pre-release version"></a>
  <a href="https://github.com/FriesI23/mhabit/actions/workflows/release-app.yml"><img src="https://img.shields.io/github/actions/workflow/status/FriesI23/mhabit/release-app.yml?style=flat-square&label=CI" alt="Build status"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/FriesI23/mhabit?style=flat-square&color=blue" alt="Apache 2.0 License"></a>
  <br>
  <img src="https://img.shields.io/badge/Flutter-3.35.7-02569B?style=flat-square&logo=Flutter&logoColor=white" alt="Built with Flutter 3.35.7">
  <img src="https://img.shields.io/badge/WebDAV-supported-brightgreen?style=flat-square" alt="WebDAV sync supported">
  <a href="https://hosted.weblate.org/engage/mhabit/"><img src="https://hosted.weblate.org/widget/mhabit/app-view/svg-badge.svg" alt="Translation status"></a>
  <a href="https://discord.gg/Hxst5can"><img src="https://img.shields.io/badge/Discord-7289DA?style=flat-square&logo=discord&logoColor=white" alt="Discord community"></a>
</p>

---

**Table Habit** is a **free and open-source** habit tracker that helps you build
micro habits with a unique scoring system, rich growth charts, and
**cross-device WebDAV sync**. Available on Android, iOS, macOS, Windows, and
Linux — **no ads, no account required**. See the translation badge above for supported languages. Licensed under Apache 2.0.

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=io.github.friesi23.mhabit"><img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png" alt="Get Table Habit on Google Play" height="60"></a>
  &nbsp;
  <a href="https://apps.apple.com/app/table-habit/id6744886469"><img src="docs/README/images/apple-get-it-on.svg" alt="Get Table Habit on the App Store" height="60"></a>
  &nbsp;
  <a href="https://f-droid.org/packages/io.github.friesi23.mhabit"><img src="https://f-droid.org/badge/get-it-on.png" alt="Get Table Habit on F-Droid" height="60"></a>
  &nbsp;
  <a href="https://flathub.org/apps/io.github.friesi23.mhabit"><img src="docs/README/images/flathub-get-it-on.svg" alt="Get Table Habit on Flathub" height="60"></a>
  &nbsp;
  <a href="https://apps.microsoft.com/detail/9NG22PL73NGZ"><img src="docs/README/images/msstore-get-it-on.svg" alt="Get Table Habit on Microsoft Store" height="60"></a>
  &nbsp;
  <a href="https://github.com/FriesI23/mhabit/releases/latest"><img src="https://raw.githubusercontent.com/Kunzisoft/Github-badge/4711835e032fe2735dc80c1329beb4685899aa91/get-it-on-github.svg" alt="Download Table Habit from GitHub Releases" height="60"></a>
</p>

|                   |                                                                                                              |
| ----------------- | ------------------------------------------------------------------------------------------------------------ |
| **Price**         | Free — no ads, no in-app purchases                                                                           |
| **License**       | Apache 2.0                                                                                                   |
| **Platforms**     | Android · iOS · macOS · Windows · Linux                                                                      |
| **Sync**          | WebDAV (Nextcloud, Koofr, self-hosted)                                                                       |
| **Languages**     | See the translation badge above for live count — Arabic, Chinese, Czech, French, German, Hebrew, Japanese, … |
| **Offline-first** | Fully functional without internet                                                                            |
| **Account**       | Not required — no sign-up, no telemetry                                                                      |
| **Tech Stack**    | Flutter · Dart · SQLite · Provider                                                                           |

## Why Table Habit?

<table>
  <tr>
    <td width="50%">
      <h3>📊 Smart Scoring — Not Just Streaks</h3>
      <p>A unique habit scoring system that quantifies your consistency. Growth
      curves show your progress over time — not just "did I do it today," but
      <em>how well</em> you're building the habit. Supports both "do" and "don't"
      habits with separate scoring models.</p>
    </td>
    <td width="50%" align="center">
      <picture>
        <source media="(prefers-color-scheme: dark)" srcset="docs/README/images/feature-growth-chart-dark.webp" />
        <source media="(prefers-color-scheme: light)" srcset="docs/README/images/feature-growth-chart.webp" />
        <img src="docs/README/images/feature-growth-chart.webp" alt="Habit scoring growth chart" width="360" />
      </picture>
    </td>
  </tr>
</table>

<table>
  <tr>
    <td width="50%" align="center">
      <picture>
        <source media="(prefers-color-scheme: dark)" srcset="docs/README/images/feature-sync-settings-dark.png" />
        <source media="(prefers-color-scheme: light)" srcset="docs/README/images/feature-sync-settings.png" />
        <img src="docs/README/images/feature-sync-settings.png" alt="WebDAV sync configuration" width="360" />
      </picture>
    </td>
    <td width="50%">
      <h3>🔄 WebDAV Sync — Own Your Data</h3>
      <p>Sync across all devices via any WebDAV-compatible server: Nextcloud,
      Koofr, or self-hosted. No vendor lock-in, no third-party cloud
      dependency. Your habit data stays yours — always.</p>
    </td>
  </tr>
</table>

<table>
  <tr>
    <td width="50%">
      <h3>🎨 Deep Customization</h3>
      <p>Per-habit custom colors with built-in swatches and a full color picker.
      Habit grouping with collapsible sections and drag-and-drop reorder.
      Material 3 + Dynamic Color theming that adapts to your device wallpaper.</p>
    </td>
    <td width="50%" align="center">
      <picture>
        <source media="(prefers-color-scheme: dark)" srcset="docs/README/images/feature-customization-dark.png" />
        <source media="(prefers-color-scheme: light)" srcset="docs/README/images/feature-customization.png" />
        <img src="docs/README/images/feature-customization.png" alt="Custom colors and habit grouping" width="360" />
      </picture>
    </td>
  </tr>
</table>

<table>
  <tr>
    <td width="50%" align="center">
      <picture>
        <source media="(prefers-color-scheme: dark)" srcset="docs/README/images/feature-offline-empty-dark.png" />
        <source media="(prefers-color-scheme: light)" srcset="docs/README/images/feature-offline-empty.png" />
        <img src="docs/README/images/feature-offline-empty.png" alt="Offline-first — no account needed" width="360" />
      </picture>
    </td>
    <td width="50%">
      <h3>🔓 100% Open Source · Privacy First</h3>
      <p>Apache 2.0. No ads, no telemetry, no account required. Import from
      Loop Habit Tracker. Export/import via human-readable JSON — your data is
      always yours. Fully functional offline.</p>
    </td>
  </tr>
</table>

|     |     |
| --- | --- |
| 🌍 **Truly Global** — Community-driven translations via Weblate with full RTL support (Arabic, Hebrew, Persian). 18+ languages and growing. | 🖥️ **Every Platform You Use** — Android, iOS, macOS, Windows, Linux. Native distribution on Google Play, App Store, F-Droid, Flathub, Microsoft Store, and more. |

## Installation

### Quick Install (CLI)

```bash
# macOS — Homebrew
brew tap FriesI23/brew-repo
brew install table-habit

# macOS — Mac App Store (via mas)
mas install 6744886469

# Windows — Scoop
scoop bucket add friesi23-bucket https://github.com/FriesI23/scoop-bucket
scoop install friesi23-bucket/mhabit

# Linux — Flatpak
flatpak install flathub io.github.friesi23.mhabit
```

> **More options**: [AltStore][altstore-source] · [SideStore][sidestore-source] · [IzzyOnDroid][lzzyondroid-myapp] · [Obtainium][obtainium-myapp] · [TestFlight Beta][ios-testflight-pre-release]
>
> Full installation guide: **[Wiki – Installation][wiki-installation]**

<details>
<summary>All Distribution Channels</summary>

| Platform    | Stable Channels                                                                        | Beta / Sideload                                                                                                                     |
| ----------- | -------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **Android** | [Google Play][play-myapp] · [F-Droid][fdroid-myapp] · [IzzyOnDroid][lzzyondroid-myapp] | [GitHub APK][github-myapp] · [Obtainium][obtainium-myapp]                                                                           |
| **iOS**     | [App Store][appstore-myapp]                                                            | [TestFlight][ios-testflight-pre-release] · [AltStore][altstore-source] · [SideStore][sidestore-source] · [GitHub IPA][github-myapp] |
| **macOS**   | [App Store][appstore-myapp] · [Homebrew][homebrew-tap-wiki]                            | [TestFlight][ios-testflight-pre-release] · [GitHub DMG][github-myapp]                                                               |
| **Windows** | [Microsoft Store][msstore-myapp] · [Scoop][scoop-bucket-wiki]                          | [GitHub MSIX][github-myapp]                                                                                                         |
| **Linux**   | [Flathub][flathub-source]                                                              | [GitHub Flatpak][github-myapp]                                                                                                      |

</details>

## Translation

Table Habit is available in many languages thanks to our amazing community
translators on Weblate (see badge above for live count).

<a href="https://hosted.weblate.org/engage/mhabit/">
  <img src="https://hosted.weblate.org/widget/mhabit/app-view/multi-auto.svg" alt="Table Habit translation progress on Weblate" />
</a>

Help translate Table Habit into your language:
[**Join Weblate**][weblate-engage] or submit a PR to
the `weblate-translation` branch.

## Roadmap

| Status | Feature                       | Notes                                             |
| :----: | ----------------------------- | ------------------------------------------------- |
|   ✅   | **Habit Groups**              | Drag-and-drop reorder, collapsible groups (v1.26) |
|   ✅   | **Custom Colors**             | Per-habit swatches + color picker (v1.25)         |
|   ✅   | **Loop Habit Tracker Import** | CSV import from Loop Habit Tracker (v1.25)        |
|   🟨   | **Android Widget**            | In progress                                       |
|   🟨   | **iOS Widget**                | In progress                                       |
|   ⬜   | **More Sync Backends**        | Beyond WebDAV — planned                           |

## Contributing

Contributions make open source great! Here's how you can help:

- **Code**: Pick an [open issue][github-issues], follow the
  [Flutter style guide][flutter-style-guide],
  and open a PR.
- **Documentation**: Wiki pages live in `docs/wiki/` — edit them and open a
  PR. CI auto-syncs to the [GitHub Wiki][github-wiki].
- **Translations**: Join [Weblate][weblate-engage]
  or edit `.arb` files in `lib/l10n/`.
- **Bug Reports**: Open a [GitHub Issue][github-issues].

<details>
<summary>Development Quickstart</summary>

```bash
# Clone and bootstrap
git clone https://github.com/FriesI23/mhabit.git
cd mhabit
make bootstrap   # or: make init

# Code generation (after changing l10n, colors, or annotations)
make gen

# Lint, fix, verify
make aio         # gen + fix + verify-generated
make test        # run all tests
```

See **[Build from Source][wiki-build]**
on the wiki for platform-specific build instructions.

</details>

## Support

Table Habit is a one-person indie project. If you find it useful, consider
supporting its development:

<p align="center">
  <a href="https://www.buymeacoffee.com/d49cb87qgww"><img src="https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee"></a>
</p>

<details>
<summary>Crypto &amp; QR Codes</summary>

|                         Alipay                          |                           WeChat Pay                           |
| :-----------------------------------------------------: | :------------------------------------------------------------: |
| ![Alipay QR Code](docs/README/images/donate-alipay.jpg) | ![WeChat Pay QR Code](docs/README/images/donate-wechatpay.png) |

- **ETH**: [`0x35FC877Ef0234FbeABc51ad7fC64D9c1bE161f8F`](https://etherscan.io/address/0x35FC877Ef0234FbeABc51ad7fC64D9c1bE161f8F)
- **BTC**: [`bc1qz2vjews2fcscmvmcm5ctv47mj6236x9p26zk49`](https://blockchair.com/bitcoin/address/bc1qz2vjews2fcscmvmcm5ctv47mj6236x9p26zk49)

</details>

> Visit **[Donors][page-donors]** to see
> everyone who has supported this project. Thank you!

---

<p align="center">
  <a href="https://www.star-history.com/?repos=FriesI23%2Fmhabit&type=date&legend=top-left">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=FriesI23/mhabit&type=date&theme=dark&legend=top-left" />
      <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=FriesI23/mhabit&type=date&legend=top-left" />
      <img alt="Star history chart for FriesI23/mhabit" src="https://api.star-history.com/chart?repos=FriesI23/mhabit&type=date&legend=top-left" width="640" />
    </picture>
  </a>
</p>

## License

```
Copyright 2023-2026 Fries_I23

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

<p align="center">
  <sub>Made with ❤️ by <a href="https://github.com/FriesI23">Fries_I23</a>
  and <a href="https://github.com/FriesI23/mhabit/graphs/contributors">contributors</a></sub>
</p>

[altstore-source]: https://friesi23.icu/altstore-repo/pages/altstore.html
[sidestore-source]: https://friesi23.icu/altstore-repo/pages/sidestore.html
[lzzyondroid-myapp]: https://apt.izzysoft.de/fdroid/index/apk/io.github.friesi23.mhabit
[obtainium-myapp]: https://apps.obtainium.imranr.dev/redirect?r=obtainium://app/%7B%22id%22%3A%22io.github.friesi23.mhabit%22%2C%22url%22%3A%22https%3A%2F%2Fgithub.com%2FFriesI23%2Fmhabit%22%2C%22author%22%3A%22FriesI23%22%2C%22name%22%3A%22Table%20Habit%22%2C%22additionalSettings%22%3A%22%7B%5C%22includePrereleases%5C%22%3Atrue%2C%5C%22fallbackToOlderReleases%5C%22%3Atrue%2C%5C%22filterReleaseTitlesByRegEx%5C%22%3A%5C%22%5C%22%2C%5C%22filterReleaseNotesByRegEx%5C%22%3A%5C%22%5C%22%2C%5C%22verifyLatestTag%5C%22%3Afalse%2C%5C%22sortMethodChoice%5C%22%3A%5C%22smartname-datefallback%5C%22%2C%5C%22useLatestAssetDateAsReleaseDate%5C%22%3Afalse%2C%5C%22releaseTitleAsVersion%5C%22%3Afalse%2C%5C%22trackOnly%5C%22%3Afalse%2C%5C%22versionExtractionRegEx%5C%22%3A%5C%22%5E%28pre-%29%3Fv%28%5C%5C%5C%5Cd%2B%5C%5C%5C%5C.%5C%5C%5C%5Cd%2B%5C%5C%5C%5C.%5C%5C%5C%5Cd%2B%29%5C%5C%5C%5C%2B%28%5C%5C%5C%5Cd%2B%29%24%5C%22%2C%5C%22matchGroupToUse%5C%22%3A%5C%22%242%5C%22%2C%5C%22versionDetection%5C%22%3Afalse%2C%5C%22releaseDateAsVersion%5C%22%3Afalse%2C%5C%22useVersionCodeAsOSVersion%5C%22%3Afalse%2C%5C%22apkFilterRegEx%5C%22%3A%5C%22%5C%22%2C%5C%22invertAPKFilter%5C%22%3Afalse%2C%5C%22autoApkFilterByArch%5C%22%3Atrue%2C%5C%22appName%5C%22%3A%5C%22Table%20Habit%5C%22%2C%5C%22appAuthor%5C%22%3A%5C%22Friesi23%5C%22%2C%5C%22shizukuPretendToBeGooglePlay%5C%22%3Afalse%2C%5C%22allowInsecure%5C%22%3Afalse%2C%5C%22exemptFromBackgroundUpdates%5C%22%3Afalse%2C%5C%22skipUpdateNotifications%5C%22%3Afalse%2C%5C%22about%5C%22%3A%5C%22%5C%22%2C%5C%22refreshBeforeDownload%5C%22%3Atrue%2C%5C%22includeZips%5C%22%3Afalse%2C%5C%22zippedApkFilterRegEx%5C%22%3A%5C%22%5C%22%7D%22%2C%22categories%22%3A%5B%22Health%22%5D%2C%22overrideSource%22%3A%22GitHub%22%2C%22allowIdChange%22%3Atrue%7D
[ios-testflight-pre-release]: https://testflight.apple.com/join/aJ5PWqaR
[wiki-installation]: https://github.com/FriesI23/mhabit/wiki/Installation
[github-issues]: https://github.com/FriesI23/mhabit/issues
[flutter-style-guide]: https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md
[github-wiki]: https://github.com/FriesI23/mhabit/wiki
[weblate-engage]: https://hosted.weblate.org/engage/mhabit/
[wiki-build]: https://github.com/FriesI23/mhabit/wiki/Dev꞉-Build-From-Source
[page-donors]: https://github.com/FriesI23/mhabit/wiki/Donors
[play-myapp]: https://play.google.com/store/apps/details?id=io.github.friesi23.mhabit&referrer=utm_source%3Dappbadge
[fdroid-myapp]: https://f-droid.org/packages/io.github.friesi23.mhabit
[appstore-myapp]: https://apps.apple.com/app/table-habit/id6744886469
[msstore-myapp]: https://apps.microsoft.com/detail/9NG22PL73NGZ?referrer=appbadge&mode=direct
[github-myapp]: https://github.com/FriesI23/mhabit/releases/latest
[flathub-source]: https://flathub.org/apps/io.github.friesi23.mhabit
[homebrew-tap-wiki]: https://github.com/FriesI23/mhabit/wiki/Installation#homebrew---custom-tap
[scoop-bucket-wiki]: https://github.com/FriesI23/mhabit/wiki/Installation#scoop---custom-bucket
