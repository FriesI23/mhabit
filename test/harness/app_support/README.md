# App support native verification

This host exercises the production reminder and dialog with real preferences.
It requires both the `f_dev` flavor and a `.dev` application identifier before
reading or changing reminder preferences. It does not access habit data or open
a browser.

From the app root, build for an available native target:

```sh
.flutter/bin/flutter build macos --debug --flavor f_dev -t test/harness/app_support/native_host.dart
.flutter/bin/flutter build apk --debug --flavor f_dev -t test/harness/app_support/native_host.dart
.flutter/bin/flutter build ios --simulator --debug --flavor f_dev -t test/harness/app_support/native_host.dart
```

Install and launch the same binary three times. The stages verify fresh and
eligible startup, false/exception link failures (each closes its dialog), later dismissal, later restoration
and permanent dismissal, then permanent restoration and cleanup. Each stage
prints `SUPPORT_PROBE_PASS`; a failure prints `SUPPORT_PROBE_FAILED`.

Original reminder keys are saved before any test mutation. Completed and failed
runs restore them and remove probe metadata. If a process is interrupted, the
next run either continues its saved stage or recovers an unfinished first-run
snapshot before starting again. A failed restore retains that original snapshot
and prints `SUPPORT_PROBE_RESTORE_PENDING`, allowing another attempt.

The three-second pause exists only in this verification host for screenshots;
the production startup path does not use a fixed delay. After verification,
rebuild the normal `lib/main.dart` target to replace the host artifact.

## Interactive carousel host

`carousel_host.dart` displays the production carousel, Settings card and
dialog in an isolated `f_dev` app. It uses in-memory reminder conditions and
simulates link and donation results; it never writes preferences or habit data,
opens a browser, or starts a payment flow.

```sh
.flutter/bin/flutter build apk --no-pub --debug --flavor f_dev -t test/harness/app_support/carousel_host.dart
.flutter/bin/flutter build macos --no-pub --debug --flavor f_dev -t test/harness/app_support/carousel_host.dart
.flutter/bin/flutter build ios --no-pub --simulator --debug --flavor f_dev -t test/harness/app_support/carousel_host.dart
```

Use the controls to switch design style, theme, language, reduced motion and
simulated launch failure. Check automatic paging, swipe timer reset, the Settings
card, background/resume and dialog dismissal before actions. Dialog stars should rise and fall
in two overlapping waves, return to a straight row and stay still when paging
away and back; opening a new dialog starts a fresh sequence. Settings stars stay
static. The host logs
`SUPPORT_CAROUSEL_HOST_READY`, selected actions and dialog outcomes. Its mock
launcher and donation callback do not prove real browser/payment integration.
After inspection, rebuild and reinstall the normal `lib/main.dart` target.

Run each host serially, with only one development app process on each device.
On macOS, use LaunchServices to launch the normal app for cold-start acceptance;
multiple `.dev` processes share preferences and can interrupt each other's
foreground state. The isolated hosts do not replace acceptance of the normal
Settings placement, startup coordination or real URL launcher.
