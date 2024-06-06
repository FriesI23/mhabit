<!--
Title: Pre-Released or Released: v1.2.3+xx
-->

# Released: v1.12.8+45

- Update Translation file (vi)
- Add linux platform support (#174)
- Fix test reporter action HTTP Error (#181)
- Bump dependencies version

## Linux Platform Support

**Note**: Need to install following dependencies first:

```shell
# https://docs.flutter.dev/get-started/install/linux/desktop?tab=vscode#development-tools
sudo apt-get install \
      clang cmake git \
      ninja-build pkg-config \
      libgtk-3-dev liblzma-dev \
      libstdc++-12-dev
# https://pub.dev/packages/sqflite_common_ffi#linux
sudo apt-get -y install libsqlite3-0 libsqlite3-dev
```

**Note**: Reminder feature temporarily unavailable on Linux desktop.
