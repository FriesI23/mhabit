fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android clean

```sh
[bundle exec] fastlane android clean
```

Clean environment

### android test

```sh
[bundle exec] fastlane android test
```

Run Flutter unit tests

### android build

```sh
[bundle exec] fastlane android build
```

Build Flutter appbundle for a specified flavor (default: f_generic)

### android deploy_play_store

```sh
[bundle exec] fastlane android deploy_play_store
```

Deploy to Google Play Store

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
