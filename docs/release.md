<!--
Title: Pre-Released or Released: v1.2.3+xx
-->

# Pre-Released

## v1.14.0+53

- Bump Dependencies versions.
  - `gradle` to 8.9
  - `com.android.application` to 8.7.0
  - `androidx.window:window` to 1.2.0
  - `androidx.window:window-java` to 1.2.0
  - `com.android.tools:desugar_jdk_libs` to 2.1.2
  - change compatibile jave version from 1.8 to 17
  - upgrade flutter package's major versions
    - `fl_chart` to 0.69.0
    - `flutter_local_notifications` to 17.2.3
    - `flutter_markdown` to 0.7.3+2
  - bump flutter package versions,
    run `git diff 62317cd 0ef4434 -- "pubspec.lock"` see full changelog
- Keep `@mipmap/ic_notification` to prevent it from being removed by `shrinkResources`,
  see https://stackoverflow.com/a/50703322.
