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
eligible startup, failed link retries and later dismissal, later restoration
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
