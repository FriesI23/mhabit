// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';

import '../support/commons.dart';

/// Navigation's reporting access to the containing window's appearance.
///
/// Sources are plain identity tokens, never widgets, State or BuildContext.
/// Null backgrounds contribute no color and use the window's own surface.
abstract interface class AppWindowNavigationSurfaceAccess {
  void reportSurface({required Object source, required Color? background});

  /// Clears the contribution only if [source] still owns the active report.
  void clearSurface(Object source);
}

/// Combines window-level theme data and renderer-resolved navigation surfaces.
///
/// The window binding provides navigation's [AppWindowNavigationSurfaceAccess]
/// and listens for resolved appearance changes. This owner only manages data;
/// frame scheduling and native submission belong to the binding.
class AppWindowAppearanceOwner
    implements ProviderMounted, AppWindowNavigationSurfaceAccess {
  final ValueNotifier<DesktopTitleBarAppearance?> _changes = ValueNotifier(
    null,
  );
  DesktopTitleBarAppearance? _windowAppearance;
  Object? _navigationSource;
  Color? _navigationSurfaceColor;
  bool _mounted = true;

  @override
  bool get mounted => _mounted;

  /// Listened to only by the binding, which schedules native submission.
  ///
  /// The owner itself remains an ordinary Provider value; navigation receives
  /// reporting access without subscribing to these synchronous notifications.
  Listenable get changes => _changes;

  /// Current window colors, with an optional renderer-owned navigation surface.
  DesktopTitleBarAppearance? get appearance {
    final window = _windowAppearance;
    if (window == null || _navigationSurfaceColor == null) return window;
    return DesktopTitleBarAppearance(
      background: _navigationSurfaceColor!,
      foreground: window.foreground,
      brightness: window.brightness,
    );
  }

  /// Called only at the window boundary, outside page and overlay themes.
  void updateWindow(DesktopTitleBarAppearance windowAppearance) {
    if (!mounted || windowAppearance == _windowAppearance) return;
    _windowAppearance = windowAppearance;
    _changes.value = appearance;
  }

  @override
  void reportSurface({required Object source, required Color? background}) {
    if (!mounted) return;
    if (identical(source, _navigationSource) &&
        background == _navigationSurfaceColor) {
      return;
    }
    _navigationSource = source;
    _navigationSurfaceColor = background;
    _changes.value = appearance;
  }

  @override
  void clearSurface(Object source) {
    if (!mounted || !identical(source, _navigationSource)) return;
    _navigationSource = null;
    _navigationSurfaceColor = null;
    _changes.value = appearance;
  }

  /// Stops listening and ignores late reports from navigation teardown.
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    _windowAppearance = null;
    _navigationSource = null;
    _navigationSurfaceColor = null;
    _changes.dispose();
  }
}
