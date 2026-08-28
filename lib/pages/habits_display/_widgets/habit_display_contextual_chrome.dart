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

import 'package:flutter/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

/// Resolves the Habits page chrome for the current adaptive context.
///
/// Resolve below the active [AdaptiveStyleScope], [MediaQuery], and
/// [AdaptiveNavScope] so every derived value uses the same context boundary.
@immutable
class HabitDisplayContextualChrome {
  const HabitDisplayContextualChrome._({
    required this.suppressShellChrome,
    required this.hideFloatingActionButton,
    required this.showSelectionBottomToolbar,
    required this.extendBody,
    required this.bottomPlaceholderHeight,
    required this.fixedButtonNavigationHeight,
  });

  static HabitDisplayContextualChrome resolve({
    required BuildContext context,
    required bool isSelectionMode,
  }) {
    final appleSelection =
        AdaptiveStyle.of(context) == AdaptiveStyle.apple && isSelectionMode;
    final compactAppleSelection =
        appleSelection &&
        WindowSize.of(context).width == WindowSizeClass.compact;
    return HabitDisplayContextualChrome._(
      suppressShellChrome: appleSelection,
      hideFloatingActionButton: appleSelection,
      showSelectionBottomToolbar: compactAppleSelection,
      extendBody: compactAppleSelection,
      bottomPlaceholderHeight: compactAppleSelection
          ? CupertinoSelectBottomToolbar.totalHeightOf(context)
          : AdaptiveNavScope.maybeOf(context)?.navHeight,
      fixedButtonNavigationHeight: !compactAppleSelection,
    );
  }

  final bool suppressShellChrome;
  final bool hideFloatingActionButton;
  final bool showSelectionBottomToolbar;
  final bool extendBody;
  final double? bottomPlaceholderHeight;
  final bool fixedButtonNavigationHeight;
}

extension HabitDisplayContextualChromeContext on BuildContext {
  /// Resolves the Habits page chrome from this context and explicit feature
  /// state.
  HabitDisplayContextualChrome resolveHabitDisplayContextualChrome({
    required bool isSelectionMode,
  }) => HabitDisplayContextualChrome.resolve(
    context: this,
    isSelectionMode: isSelectionMode,
  );
}
