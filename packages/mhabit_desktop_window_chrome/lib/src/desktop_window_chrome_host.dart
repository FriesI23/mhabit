import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_window_utils/widgets/macos_toolbar_passthrough.dart';

import 'desktop_window_chrome.dart';

/// Includes the Navigator and its overlays in the package's interaction scope.
class DesktopWindowChromeHost extends StatelessWidget {
  final DesktopWindowChrome? controller;
  final Widget child;

  const DesktopWindowChromeHost({
    super.key,
    this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final owner = controller;
    if (owner == null) return child;
    return ListenableBuilder(
      listenable: owner,
      child: MacosToolbarPassthroughScope(child: child),
      builder: (context, child) => _InteractionScope(
        enabled:
            !kIsWeb &&
            defaultTargetPlatform == TargetPlatform.macOS &&
            owner.available &&
            !owner.isFullScreen &&
            owner.geometry?.valid == true,
        child: child!,
      ),
    );
  }
}

/// Delegates target measurement, IDs, updates and removal to the package.
class DesktopWindowInteractionRegion extends StatelessWidget {
  final Widget child;

  const DesktopWindowInteractionRegion({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      context
              .dependOnInheritedWidgetOfExactType<_InteractionScope>()
              ?.enabled ==
          true
      ? MacosToolbarPassthrough(child: child)
      : child;
}

class _InteractionScope extends InheritedWidget {
  final bool enabled;

  const _InteractionScope({required this.enabled, required super.child});

  @override
  bool updateShouldNotify(_InteractionScope oldWidget) =>
      enabled != oldWidget.enabled;
}
