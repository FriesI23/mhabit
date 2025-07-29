<!-- markdownlint-disable no-inline-html first-line-heading -->

## Meet "source value 8 is obsolete and will be removed in a future release" on building apk

If you see the messages below while building your Android app,
it’s because `Android Studio Ladybug` upgrade has updated the JDK version to 21.

```log
warning: [options] source value 8 is obsolete and will be removed in a future release
warning: [options] target value 8 is obsolete and will be removed in a future release
warning: [options] To suppress warnings about obsolete options, use -Xlint:-options.
```

These warnings are harmless; you can choose to ignore them or simply use JDK 17 instead of 21.

```shell
# macos arm64
brew install openjdk@17
flutter config --jdk-dir /opt/homebrew/opt/openjdk@17
```

---

1. [2025-07-28] Migrated from: [`FriesI23/mhabit/docs/faq.md`][_migrate]

[_migrate]: https://github.com/FriesI23/mhabit/blob/9fbf03a4a16c0794f8fbb26e3fb3068149695f4e/docs/faq.md
