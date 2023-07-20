# Table Habit

[![Build and Release][github-relaese-badge-svg]][github-relaese-badge]
[![Latest Stable Version][app-verison-bage-svg]][github-release-page]
[![License][license-badge]][app-license]
[![Flutter][flutter-badge]][deps-flutter-version]

[![Trello][app-trello-badge]][app-trello-board]

"Table Habit" is an app that helps you establish and track your own micro habit.
Its includes a complete set of growth curves and charts to help you establish
habits more effectively.

Moreover, this app completely open source.

[![Get it on F-Droid][fdroid-button]][fdroid-myapp]
[![Get it on F-Droid][github-button]][github-myapp]

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

## Todo

| status  | progress               | desc.                                                        |
| ------- | ---------------------- | ------------------------------------------------------------ |
| PLANNED | Sync with Webdav       | Expected sync solution is similar to Joplin's WebDAV method. |
| -       | Publish to Google Play |                                                              |
| -       | Build iOS version      | build with iOS, need change some UI to Cupertino style.      |
| -       | Complete Documentation | [`README.md`](README.md)                                     |

## Build from source

Make sure your flutter version is `3.7.12`, you can use `fvm` to keep multi
versions in your local machine.

1. in project folder, run `flutter pub get`
2. open an android or ios emulator
3. run `flutter run --debug`

## Contributing

I am an independent developer and do not have professional expertise in writing
documentation and project management.

If you have relevant knowledge and are willing to contribute to this project,
you can help me improve the documentation, e.g `README.md` file.

## Donate

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/d49cb87qgww)

![Alipay](docs/README/images/donate-alipay.jpg)
![WechatPay](docs/README/images/donate-wechatpay.png)

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
[github-button]: docs/README/images/github-get-it-on.png
[github-myapp]: https://github.com/FriesI23/mhabit/releases/latest
[github-relaese-badge]: https://github.com/FriesI23/mhabit/actions/workflows/release.yml
[github-relaese-badge-svg]: https://github.com/FriesI23/mhabit/actions/workflows/release.yml/badge.svg
[github-release-page]: https://github.com/FriesI23/mhabit/releases
[app-license]: https://github.com/FriesI23/mhabit/blob/main/LICENSE
[flutter-badge]: https://img.shields.io/badge/_Flutter_-3.7.12-grey.svg?&logo=Flutter&logoColor=white&labelColor=blue
[deps-flutter-version]: https://github.com/flutter/flutter/tree/3.7.12
[license-badge]: https://img.shields.io/github/license/FriesI23/mhabit
[app-verison-bage-svg]: https://img.shields.io/github/v/release/FriesI23/mhabit
[app-trello-badge]: https://img.shields.io/badge/Trello-%23026AA7.svg?style=for-the-badge&logo=Trello&logoColor=white
[app-trello-board]: https://trello.com/b/ayPTUeQj/mhabit
