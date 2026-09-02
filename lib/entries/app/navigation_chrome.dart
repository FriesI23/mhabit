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

import '../../routes/app_navigation_branch.dart';

/// Builds the current auxiliary navigation presentations for the app shell.
typedef AppNavigationAuxiliaryChromeBuilder =
    List<AppNavigationAuxiliaryChrome> Function(BuildContext context);

/// Declarative presentation and interaction for one auxiliary destination.
///
/// The shell consumes this contract without knowing the destination's route
/// or business meaning. The app entry owns those details.
@immutable
final class AppNavigationAuxiliaryChrome {
  /// Creates auxiliary navigation chrome.
  const AppNavigationAuxiliaryChrome({
    required this.destination,
    required this.selected,
    required this.onSelected,
  });

  /// Destination rendered by non-compact navigation forms.
  final AdaptiveNavigationDestination destination;

  /// Whether the auxiliary destination currently owns the content area.
  final bool selected;

  /// Invoked when the auxiliary destination is selected.
  final VoidCallback onSelected;
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
