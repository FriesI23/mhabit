fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios clean

```sh
[bundle exec] fastlane ios clean
```

Clean environment

### ios test

```sh
[bundle exec] fastlane ios test
```

Run Flutter unit tests

### ios build

```sh
[bundle exec] fastlane ios build
```

Build Flutter app for a specified flavor (default: f_generic)

### ios deploy

```sh
[bundle exec] fastlane ios deploy
```

Push a new release build to the App Store

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
