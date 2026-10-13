import 'package:pigeon/pigeon.dart';

/// Wire rectangle in logical points relative to Flutter's top-left origin.
/// Coordinates stay on physical edges across LTR/RTL changes; backing scale
/// must not be applied again after the native adapter converts the rectangle.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/desktop_window_chrome_api.g.dart',
    swiftOut:
        'macos/mhabit_desktop_window_chrome/Sources/mhabit_desktop_window_chrome/DesktopWindowChrome.g.swift',
    dartPackageName: 'mhabit_desktop_window_chrome',
  ),
)
class ChromeRect {
  /// Physical offset from the viewport's left edge, in logical points.
  double x;

  /// Physical offset from the viewport's top edge, in logical points.
  double y;

  /// Rectangle width in logical points.
  double width;

  /// Rectangle height in logical points.
  double height;

  ChromeRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

/// One native layout snapshot. Viewport dimensions use logical points.
class ChromeGeometry {
  /// Whether Flutter is attached to its window with nonempty viewport bounds.
  bool ready;

  /// Whether geometry is usable; ordinary fusion requires all three buttons.
  bool valid;

  /// Includes the fullscreen entry transition, before the system animation ends.
  bool fullScreen;

  /// Flutter viewport width in logical points.
  double width;

  /// Flutter viewport height in logical points.
  double height;

  /// Visible native buttons converted to Flutter viewport coordinates.
  List<ChromeRect> buttons;

  ChromeGeometry({
    required this.ready,
    required this.valid,
    required this.fullScreen,
    required this.width,
    required this.height,
    required this.buttons,
  });
}

/// Plugin-owned geometry and decoration bridge; window_manager owns window lifecycle.
@HostApi()
abstract class DesktopChromeHostApi {
  /// Queries layout readiness and native geometry without changing the window.
  ChromeGeometry geometry();

  /// Enables ordinary-window fusion or restores standard system decoration.
  /// Active fullscreen windows retain system decoration.
  void configure(bool fused);

  /// Removes layout changes, observers and message handlers.
  /// Does not close the window or replace its window_manager delegate.
  void dispose();
}

/// Native notifications for the plugin-owned window-chrome lifecycle.
@FlutterApi()
abstract class DesktopChromeFlutterApi {
  /// Requests a fresh query after native viewport or button geometry changes.
  void geometryChanged();

  /// Sent after native decoration is restored, before fullscreen entry begins.
  /// Flutter must clear ordinary-window avoidance before the system animation.
  void willEnterFullScreen();
}
