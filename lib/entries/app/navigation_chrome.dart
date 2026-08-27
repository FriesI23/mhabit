import 'package:flutter/foundation.dart';

enum AppNavigationBranch {
  habits,
  today;

  static AppNavigationBranch fromIndex(int index) => values[index];
}

enum AppNavigationPrimaryAction { createHabit }

@immutable
final class AppNavigationBranchChrome {
  const AppNavigationBranchChrome({
    this.primaryAction,
    this.contextualChromeSuppressed = false,
  });

  final AppNavigationPrimaryAction? primaryAction;
  final bool contextualChromeSuppressed;

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

class AppNavigationChromeController extends ChangeNotifier {
  final Map<AppNavigationBranch, AppNavigationBranchChrome> _branches = {
    AppNavigationBranch.habits: const AppNavigationBranchChrome(
      primaryAction: AppNavigationPrimaryAction.createHabit,
    ),
    AppNavigationBranch.today: const AppNavigationBranchChrome(),
  };
  final Map<AppNavigationBranch, VoidCallback> _primaryActions = {};

  AppNavigationBranchChrome chromeFor(AppNavigationBranch branch) =>
      _branches[branch] ?? const AppNavigationBranchChrome();

  void registerPrimaryAction(AppNavigationBranch branch, VoidCallback action) {
    _primaryActions[branch] = action;
  }

  void unregisterPrimaryAction(
    AppNavigationBranch branch,
    VoidCallback action,
  ) {
    if (identical(_primaryActions[branch], action)) {
      _primaryActions.remove(branch);
    }
  }

  void invokePrimaryAction(AppNavigationBranch branch) =>
      _primaryActions[branch]?.call();

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
