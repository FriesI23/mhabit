import 'package:flutter/foundation.dart';

import 'app_navigation_branch.dart';

/// Dispatches navigation scroll requests to the registered branch root pages.
class AppNavigationScrollController {
  final Map<AppNavigationBranch, VoidCallback> _actions = {};

  void registerScrollToTop(AppNavigationBranch branch, VoidCallback action) {
    _actions[branch] = action;
  }

  void unregisterScrollToTop(AppNavigationBranch branch, VoidCallback action) {
    if (_actions[branch] == action) _actions.remove(branch);
  }

  void scrollToTop(AppNavigationBranch branch) => _actions[branch]?.call();

  void clear() => _actions.clear();
}
