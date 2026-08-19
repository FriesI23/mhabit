import 'package:flutter/widgets.dart';

/// Route observer for shell branches.
///
/// Attach one instance to each nested branch navigator whose stack needs to
/// be observed. The app layer can combine these snapshots with its own route
/// policy before passing presentation state to adaptive navigation chrome.
class AdaptiveBranchRouteObserver extends NavigatorObserver {
  final List<Route<dynamic>> _stack = [];
  String? _topRouteName;

  /// Stack depth of the observed branch navigator.
  int get depth => _stack.length;

  /// [RouteSettings.name] of the branch navigator's top route.
  ///
  /// It is null for unnamed routes.
  String? get topRouteName => _topRouteName;

  /// Names of every route in the branch navigator, bottom to top; unnamed
  /// routes (e.g. dialogs) yield null entries.
  List<String?> get routeNameStack =>
      List.unmodifiable(_stack.map((route) => route.settings.name));

  /// Called when [depth] or [topRouteName] change.
  VoidCallback? onStackChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.add(route);
    _topRouteName = route.settings.name;
    onStackChanged?.call();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_stack.isNotEmpty && identical(_stack.last, route)) {
      _stack.removeLast();
    }
    _topRouteName = _stack.isNotEmpty ? _stack.last.settings.name : null;
    onStackChanged?.call();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) {
      final index = _stack.lastIndexWhere((r) => identical(r, oldRoute));
      if (index >= 0) {
        if (newRoute == null) {
          _stack.removeAt(index);
        } else {
          _stack[index] = newRoute;
        }
      }
    }
    _topRouteName = _stack.isNotEmpty ? _stack.last.settings.name : null;
    onStackChanged?.call();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // didPop already removed a popped route, so removeWhere only matters
    // for removals below the top (e.g. page replacement).
    _stack.removeWhere((r) => identical(r, route));
    _topRouteName = _stack.isNotEmpty ? _stack.last.settings.name : null;
    onStackChanged?.call();
  }
}
