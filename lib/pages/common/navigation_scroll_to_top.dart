import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../routes/app_navigation_branch.dart';
import '../../routes/app_navigation_scroll_controller.dart';

/// Registers this page's scroll-to-top action for navigation reselection.
mixin NavigationScrollToTopMixin<T extends StatefulWidget> on State<T> {
  AppNavigationScrollController? _navigationScrollToTopDispatcher;

  /// Branch whose navigation reselection requests should scroll this page.
  AppNavigationBranch get navigationScrollToTopBranch;

  /// Page-owned vertical controller targeted by navigation scroll-to-top.
  ScrollController get navigationScrollToTopController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.watch<AppNavigationScrollController?>();
    if (identical(controller, _navigationScrollToTopDispatcher)) return;
    _navigationScrollToTopDispatcher?.unregisterScrollToTop(
      navigationScrollToTopBranch,
      _handleNavigationScrollToTop,
    );
    _navigationScrollToTopDispatcher = controller
      ?..registerScrollToTop(
        navigationScrollToTopBranch,
        _handleNavigationScrollToTop,
      );
  }

  void _handleNavigationScrollToTop() {
    final controller = navigationScrollToTopController;
    if (!mounted || !controller.hasClients) return;
    final position = controller.position;
    if (!position.hasContentDimensions ||
        position.pixels == position.minScrollExtent) {
      return;
    }
    final disableAnimations =
        context
            .getInheritedWidgetOfExactType<MediaQuery>()
            ?.data
            .disableAnimations ??
        false;
    if (disableAnimations) {
      controller.jumpTo(position.minScrollExtent);
    } else {
      unawaited(
        controller.animateTo(
          position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _navigationScrollToTopDispatcher?.unregisterScrollToTop(
      navigationScrollToTopBranch,
      _handleNavigationScrollToTop,
    );
    super.dispose();
  }
}
