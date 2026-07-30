# CollationPlugin SPM Migration

These Swift sources are currently compiled into the iOS/macOS Runner targets
via Xcode file references (not copied). Flutter 3.44 has introduced SPM-based
plugin dependency management, but app-level native code sharing via SPM is
not yet mature.

> TODO: Migrate darwin/CollationPlugin to a local SPM package once Flutter
> SPM plugin support stabilizes for app-level shared native code

## When ready

1. Add a proper `Package.swift` with Flutter framework dependencies
2. Replace Xcode file references with SPM package dependency in both
   `ios/Runner.xcodeproj` and `macos/Runner.xcodeproj`
3. Remove the manual file references from both Xcode projects
4. Verify `flutter build ios` and `flutter build macos` in CI

## Current status

Flutter 3.44.x — SPM plugin support replaces CocoaPods but does not yet
cover app-level shared Darwin sources.

## References

- [Flutter 3.44 SPM for app developers](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)
- [CocoaPods trunk registry read-only (Dec 2, 2026)](https://blog.cocoapods.org/CocoaPods-Specs-Repo/)
