import 'package:flutter/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart'
    as desktop;
import 'package:provider/provider.dart';

/// Connects native window interaction to the app's Navigator and root overlays.
///
/// Reads the app-owned controller and provides adaptive UI's optional interaction
/// markers. The window package measures the marked targets and manages their
/// native passthrough views.
class AppWindowInteractionBinding extends StatelessWidget {
  final Widget child;
  const AppWindowInteractionBinding({super.key, required this.child});

  static Widget _wrapInteractionRegion(Widget child) =>
      desktop.DesktopWindowInteractionRegion(child: child);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<desktop.DesktopWindowChrome?>();
    return desktop.DesktopWindowChromeHost(
      controller: controller,
      child: AdaptiveWindowInteractionBinding(
        wrapper: controller == null ? null : _wrapInteractionRegion,
        child: child,
      ),
    );
  }
}
