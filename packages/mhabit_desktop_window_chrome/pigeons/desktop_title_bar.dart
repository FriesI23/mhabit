import 'package:pigeon/pigeon.dart';

/// Native appearance controls for an independent system title bar.
///
/// Colors are resolved by the app at window scope. These calls preserve the
/// system caption buttons and window interactions.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/desktop_title_bar_api.g.dart',
    cppHeaderOut: 'windows/desktop_title_bar.g.h',
    cppSourceOut: 'windows/desktop_title_bar.g.cpp',
    cppOptions: CppOptions(namespace: 'mhabit_desktop_window_chrome'),
    dartPackageName: 'mhabit_desktop_window_chrome',
  ),
)
@HostApi()
abstract class DesktopTitleBarHostApi {
  /// Applies caption and text colors, returning true if both were applied.
  ///
  /// Both colors use packed 0xAARRGGBB; alpha is ignored.
  /// The dark-mode flag is the application's preference and is an optional hint.
  /// Returns false for an unavailable window, failed ownership, unsupported
  /// color attributes or active high contrast; color failures attempt to restore
  /// both system color defaults. Once claimed, application ownership and the
  /// cached request remain active until reset, so system changes can retry it.
  bool setAppearance(int backgroundArgb, int foregroundArgb, bool dark);

  /// Releases application ownership and restores system appearance.
  ///
  /// Best-effort and safe to repeat, including after window destruction.
  /// Unsupported DWM reset attributes are ignored.
  void reset();
}
