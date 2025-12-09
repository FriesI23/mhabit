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
[![Discord][app-discord-badge]][app-discord-channel]

"Table Habit" is an app that helps you establish and track your own micro habit.
It includes a complete set of growth curves and charts to help you build habits more effectively,
and keeps your data in sync across devices (currently via WebDAV, with more options coming soon).

Moreover, this app completely open source.


[<img src="https://raw.githubusercontent.com/Kunzisoft/Github-badge/4711835e032fe2735dc80c1329beb4685899aa91/get-it-on-github.svg"
  alt="Get in on Github"
  height="80">][github-myapp]
[<img src="https://f-droid.org/badge/get-it-on.png"
  alt="Get it on F-Droid"
  height="80">][fdroid-myapp]
[<img src="docs/README/images/flathub-get-it-on.svg"
  alt="Get it on Flathub"
  height="80">][flathub-source]
[<img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"
  alt="Download from Google Play"
  height="80">][play-myapp]
[<img src="docs/README/images/apple-get-it-on.svg"
  alt="Get from Apple Store"
  height="80">][appsotre-myapp]
[<img src="docs/README/images/msstore-get-it-on.svg"
  alt="Download from Microsoft Store"
  height="80">][msstore-myapp]

| platform               | build | publish                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ---------------------- | ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Android                | ✅     | [<img src="https://gitlab.com/IzzyOnDroid/repo/-/raw/master/assets/IzzyOnDroid.png" alt="Get it on LzzyOnDroid" height="80">][lzzyondroid-myapp] <br/> [F-Droid][fdroid-myapp] / [Play Store][play-myapp] / [GitHub - apk][github-myapp]                                                                                                                                                                                                                                                                                                                                    |
| iOS                    | ✅     | [<img src="https://raw.githubusercontent.com/FriesI23/altstore-repo/refs/heads/master/assets/get-it-on-altstore-org.png" alt="Get it on AltStore" height="80">][altstore-source] [<img src="https://raw.githubusercontent.com/FriesI23/altstore-repo/refs/heads/master/assets/get-it-on-sidestore-org.png" alt="Get it on SideStore" height="80">][sidestore-source] [<img src="docs/README/images/testflight-get-it-on.svg" alt="Available on TestFlight" height="80">][ios-testflight-pre-release] <br/> [iOS Apple Store][appsotre-myapp] / [GitHub - ipa][github-myapp] |
| macOS                  | ✅     | [<img src="docs/README/images/testflight-get-it-on.svg" alt="Available on TestFlight" height="80">][ios-testflight-pre-release] <br/> [Mac Apple Store][appsotre-myapp] / [HomeBrew Tap][homebrew-tap-wiki] / [GitHub - dmg][github-myapp]                                                                                                                                                                                                                                                                                                                                  |
| Windows <sup>(1)</sup> | ✅     | [Scoop Bucket][scoop-bucket-wiki] / [GitHub - msix][github-myapp]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Linux <sup>(1)</sup>   | ✅     | [Microsoft Store][msstore-myapp] / [Flathub][flathub-source] / [GitHub - flatpak][github-myapp]                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |

> 1. Scheduled habit reminders are not yet implemented

## Features

- A scoring system to help develop your own micro habits.
- Support both positive and negative habit.
- An easy-to-use interface for habit check in.
- A quick search and filter to help quickly find past habits.
- Different colors used to distinguish between various habits.
- Easily export and import habits using a human-readable format (JSON).
- Adapt to `Material3` and `Dynamic Color` for Android 12 and later versions.
- Adaptation for landscape and large screen devices.
- Support network sync with WebDAV.
- No ADs in this app.

For more information, please visit our [**Wiki**][wiki].

## Screenshots

[![Create new habit][create-new-habit-tb]][create-new-habit]
[![Check habit detail][check-habit-detail-tb]][check-habit-detail]
[![Habit display page][display-page-tb]][display-page]
[![Habit display page operation][display-op-tb]][display-op]

## Todo

| status | progress                               | desc. |
| ------ | -------------------------------------- | ----- |
| -      | Scheduled reminders on Linux / Windows |       |
| -      | Android Widget                         |       |
| -      | iOS Widget                             |       |

## Contributing

I am an independent developer and do not have professional expertise in writing
documentation and project management.

If you have relevant knowledge and are willing to contribute to this project,
you can help me improve project documentations, e.g `README.md` file.

To ensure wiki pages can be indexed by search engines (due to limitations from GitHub),
public editing permissions have been disabled. If you’d like to contribute documentation,
please submit files to the `docs/wiki` folder and open a PR.
Once merged, an automated CI process will sync changes to the [wiki][wiki].

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

Feel free to join and help translate Table Habit!
To request a new language, follow the instructions on ["Wiki – Request New Language"][l10n-doc].
To update translations, you can either contribute directly on [Weblate.org][weblate]
or modify the `.arb` files locally and request a PR to `weblate-translation` branch.

<!-- ![L10nStat][l10n-stat-pic] -->

[![Engage][weblate-engage-badge]][weblate-engage]

## Star History

<a href="https://www.star-history.com/#FriesI23/mhabit&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=FriesI23/mhabit&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=FriesI23/mhabit&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=FriesI23/mhabit&type=date&legend=top-left" />
 </picture>
</a>

## License

```text
Copyright 2023-2025 Fries_I23

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
[display-page]: docs/README/images/habit-display-page.gif
[display-page-tb]: docs/README/images/habit-display-page-tb.gif
[display-op]: docs/README/images/habit-display-op.gif
[display-op-tb]: docs/README/images/habit-display-op-tb.gif
[fdroid-myapp]: https://f-droid.org/packages/io.github.friesi23.mhabit
[lzzyondroid-myapp]: https://apt.izzysoft.de/fdroid/index/apk/io.github.friesi23.mhabit
[play-myapp]: https://play.google.com/store/apps/details?id=io.github.friesi23.mhabit&referrer=utm_source%3Dappbadge
[altstore-source]: https://play4fun.friesi23.cn/altstore-repo/pages/altstore.html
[sidestore-source]: https://play4fun.friesi23.cn/altstore-repo/pages/sidestore.html
[appsotre-myapp]: https://apps.apple.com/app/table-habit/id6744886469
[msstore-myapp]: https://apps.microsoft.com/detail/9NG22PL73NGZ?referrer=appbadge&mode=direct
[github-myapp]: https://github.com/FriesI23/mhabit/releases/latest
[flathub-source]: https://flathub.org/apps/io.github.friesi23.mhabit
[github-relaese-badge]: https://github.com/FriesI23/mhabit/actions/workflows/release-app.yml
[github-relaese-badge-svg]: https://github.com/FriesI23/mhabit/actions/workflows/release-app.yml/badge.svg
[github-release-page]: https://github.com/FriesI23/mhabit/releases
[app-license]: https://github.com/FriesI23/mhabit/blob/main/LICENSE
[flutter-badge]: https://img.shields.io/badge/_Flutter_-3.29.3-grey.svg?&logo=Flutter&logoColor=white&labelColor=blue
[deps-flutter-version]: https://github.com/flutter/flutter/tree/3.29.3
[license-badge]: https://img.shields.io/github/license/FriesI23/mhabit
[app-verison-bage-svg]: https://img.shields.io/github/v/release/FriesI23/mhabit
[app-pre-verison-bage-svg]: https://img.shields.io/github/v/release/FriesI23/mhabit?include_prereleases&label=pre-release
[app-trello-badge]: https://img.shields.io/badge/Trello-%23026AA7.svg?style=for-the-badge&logo=Trello&logoColor=white
[app-trello-board]: https://trello.com/b/ayPTUeQj/mhabit
[app-discord-badge]: https://img.shields.io/badge/Discord-7289DA.svg?style=for-the-badge&logo=discord&logoColor=white
[app-discord-channel]: https://discord.gg/Hxst5can
[l10n-doc]: https://github.com/FriesI23/mhabit/wiki/L10n%EA%9E%89-Request-New-Language
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
[ios-testflight-pre-release]: https://testflight.apple.com/join/aJ5PWqaR
[page-donors]: https://github.com/FriesI23/mhabit/wiki/Donors
[fdroid-wiki]: https://github.com/FriesI23/mhabit/wiki/Installation#f-droid--lzzlzzyondroid
[sideloaded-wiki]: https://github.com/FriesI23/mhabit/wiki/Installation#altstore--sidestore---custom-source
[homebrew-tap-wiki]: https://github.com/FriesI23/mhabit/wiki/Installation#homebrew---custom-tap
[flathub-wiki]: https://github.com/FriesI23/mhabit/wiki/Installation#flathub
[scoop-bucket-wiki]: https://github.com/FriesI23/mhabit/wiki/Installation#scoop---custom-bucket
[wiki]: https://github.com/FriesI23/mhabit/wiki
