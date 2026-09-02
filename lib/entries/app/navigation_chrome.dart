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

import 'package:flutter/foundation.dart';

/// A top-level destination owned by the app navigation shell.
///
/// [navigationIndex] is an explicit router contract. It must not depend on the
/// declaration order used by Dart's built-in [Enum.index].
enum AppNavigationBranch {
  habits(navigationIndex: 0),
  today(navigationIndex: 1);

  const AppNavigationBranch({required this.navigationIndex});

  /// Index used by go_router's stateful navigation shell.
  final int navigationIndex;

  /// Returns the branch explicitly assigned to [navigationIndex].
  static AppNavigationBranch fromNavigationIndex(int navigationIndex) =>
      values.firstWhere(
        (branch) => branch.navigationIndex == navigationIndex,
        orElse: () => throw ArgumentError.value(
          navigationIndex,
          'navigationIndex',
          'No app navigation branch uses this index',
        ),
      );
}

/// App-level primary commands that navigation chrome can present.
enum AppNavigationPrimaryAction { createHabit }

/// Declarative navigation-chrome state for one [AppNavigationBranch].
///
/// This describes what the shell may present. Command callbacks are registered
/// separately with [AppNavigationChromeController], so immutable presentation
/// state does not capture page state or a [BuildContext].
@immutable
final class AppNavigationBranchChrome {
  /// Creates the navigation-chrome state for a branch.
  const AppNavigationBranchChrome({
    this.primaryAction,
    this.contextualChromeSuppressed = false,
  });

  /// Primary command exposed by the branch, if any.
  final AppNavigationPrimaryAction? primaryAction;

  /// Whether contextual commands temporarily suppress navigation chrome.
  final bool contextualChromeSuppressed;

  /// Returns this state with the supplied mutable presentation properties.
  AppNavigationBranchChrome copyWith({bool? contextualChromeSuppressed}) =>
      AppNavigationBranchChrome(
        primaryAction: primaryAction,
        contextualChromeSuppressed:
            contextualChromeSuppressed ?? this.contextualChromeSuppressed,
      );

  @override
  bool operator ==(Object other) =>
      other is AppNavigationBranchChrome &&
      primaryAction == other.primaryAction &&
      contextualChromeSuppressed == other.contextualChromeSuppressed;

  @override
  int get hashCode => Object.hash(primaryAction, contextualChromeSuppressed);
}

/// Owns per-branch navigation-chrome state and its registered commands.
///
/// Registering a callback does not notify listeners because it does not alter
/// presentation. Only visible chrome-state changes trigger a shell update.
class AppNavigationChromeController extends ChangeNotifier {
  final Map<AppNavigationBranch, AppNavigationBranchChrome> _branches = {
    AppNavigationBranch.habits: const AppNavigationBranchChrome(
      primaryAction: AppNavigationPrimaryAction.createHabit,
    ),
    AppNavigationBranch.today: const AppNavigationBranchChrome(),
  };
  final Map<AppNavigationBranch, VoidCallback> _primaryActions = {};

  /// Returns the declarative chrome state for [branch].
  AppNavigationBranchChrome chromeFor(AppNavigationBranch branch) =>
      _branches[branch] ?? const AppNavigationBranchChrome();

  /// Registers the callback implementing [branch]'s primary command.
  void registerPrimaryAction(AppNavigationBranch branch, VoidCallback action) {
    _primaryActions[branch] = action;
  }

  /// Releases [action] if it is still the callback registered for [branch].
  void unregisterPrimaryAction(
    AppNavigationBranch branch,
    VoidCallback action,
  ) {
    if (identical(_primaryActions[branch], action)) {
      _primaryActions.remove(branch);
    }
  }

  /// Invokes the current primary-command callback for [branch], if registered.
  void invokePrimaryAction(AppNavigationBranch branch) =>
      _primaryActions[branch]?.call();

  /// Updates whether contextual UI suppresses navigation chrome for [branch].
  void setContextualChromeSuppressed(
    AppNavigationBranch branch,
    bool suppressed,
  ) {
    final current = chromeFor(branch);
    if (current.contextualChromeSuppressed == suppressed) return;
    _branches[branch] = current.copyWith(
      contextualChromeSuppressed: suppressed,
    );
    notifyListeners();
  }
}
