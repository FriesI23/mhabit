import 'package:flutter/widgets.dart';

import '../adaptive_style.dart';

/// Geometry and interaction state supplied by the enclosing section row.
/// Explicitly forced tiles only consume the matching renderer's scope.
class ListSectionRowScope extends InheritedWidget {
  const ListSectionRowScope({
    super.key,
    required this.style,
    required this.shape,
    this.statesController,
    required super.child,
  });

  final AdaptiveStyle style;
  final OutlinedBorder shape;
  final WidgetStatesController? statesController;

  static ListSectionRowScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ListSectionRowScope>();

  @override
  bool updateShouldNotify(ListSectionRowScope oldWidget) =>
      style != oldWidget.style ||
      shape != oldWidget.shape ||
      statesController != oldWidget.statesController;
}
