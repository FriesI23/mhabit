import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:provider/provider.dart';

import '../../common/consts.dart';
import '../../l10n/localizations.dart';
import '../../providers/app_ui/app_window_appearance.dart';

/// Synchronizes window-level appearance with the native title bar.
///
/// Provides the window owner and navigation's reporting access above Navigator
/// overlays, and submits the latest appearance at the end of the frame.
class AppWindowTitleBarBinding extends StatefulWidget {
  const AppWindowTitleBarBinding({super.key, required this.child});
  final Widget child;

  @override
  State<AppWindowTitleBarBinding> createState() =>
      _AppWindowTitleBarBindingState();
}

class _AppWindowTitleBarBindingState extends State<AppWindowTitleBarBinding> {
  AppWindowAppearanceOwner? _owner;
  DesktopWindowTitleBar? _titleBar;
  bool _scheduled = false;
  String? _title;

  void _schedule() {
    if (!mounted ||
        _scheduled ||
        _titleBar == null ||
        _owner?.appearance == null) {
      return;
    }
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      final title = _title;
      if (title != null) unawaited(_titleBar?.setTitle(title));
      final appearance = _owner?.appearance;
      if (appearance != null) {
        unawaited(_titleBar?.applyAppearance(appearance));
      }
    });
    // Reports may also arrive while the window is idle, outside a build frame.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _owner?.changes.removeListener(_schedule);
    _owner = null;
    _titleBar = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = L10n.of(context)?.appName ?? appName;
    if (_title != title) {
      _title = title;
      _schedule();
    }
    return MultiProvider(
      providers: [
        // Ordinary Provider publishes identity; the binding alone listens to
        // changes, without notifying UI consumers during navigation builds.
        Provider<AppWindowAppearanceOwner>(
          create: (_) {
            final owner = AppWindowAppearanceOwner();
            owner.changes.addListener(_schedule);
            return owner;
          },
          dispose: (_, owner) => owner.dispose(),
        ),
        ProxyProvider2<
          DesktopWindowTitleBar?,
          AppWindowAppearanceOwner,
          AppWindowNavigationSurfaceAccess
        >(
          // Even a standalone or error page without a reporter needs its theme
          // applied. Keep the owner instance stable across dependency updates.
          lazy: false,
          update: (context, titleBar, owner, _) {
            final nativeChanged = !identical(titleBar, _titleBar);
            _titleBar = titleBar;
            _owner = owner;
            final theme = Theme.of(context);
            owner.updateWindow(
              DesktopTitleBarAppearance(
                background: theme.colorScheme.surface,
                foreground: theme.colorScheme.onSurface,
                brightness: theme.brightness,
              ),
            );
            // A new native controller needs submission even if colors are equal.
            if (nativeChanged) _schedule();
            return owner;
          },
        ),
      ],
      child: widget.child,
    );
  }
}

/// Placed directly inside the navigation shell, above its page-local themes.
/// Reports renderer-resolved surface data without knowing the UI style or
/// painting a surface of its own.
class AppWindowNavigationSurfaceReporter extends StatefulWidget {
  const AppWindowNavigationSurfaceReporter({super.key, required this.child});
  final Widget child;

  @override
  State<AppWindowNavigationSurfaceReporter> createState() =>
      _AppWindowNavigationSurfaceReporterState();
}

class _AppWindowNavigationSurfaceReporterState
    extends State<AppWindowNavigationSurfaceReporter> {
  // Identity belongs to the report, not to this State or another widget.
  final Object _source = Object();
  AppWindowNavigationSurfaceAccess? _access;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final access = context.watch<AppWindowNavigationSurfaceAccess?>();
    if (!identical(access, _access)) _access?.clearSurface(_source);
    _access = access;
    access?.reportSurface(
      source: _source,
      background: AdaptiveNavScope.maybeOf(context)?.navigationSurfaceColor,
    );
  }

  @override
  void deactivate() {
    // Use the cached access without looking up a deactivated widget's ancestors.
    // Reparenting establishes fresh dependencies and reports to its new owner.
    _access?.clearSurface(_source);
    _access = null;
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
