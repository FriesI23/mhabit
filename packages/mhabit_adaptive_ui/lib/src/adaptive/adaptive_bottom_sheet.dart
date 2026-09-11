import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../adaptive_style.dart';

/// Shows a fixed sheet using the active adaptive style's route renderer.
@Deprecated(
  'Use showAdaptiveSheet instead. This API will be removed in Phase 3-7f.',
)
Future<T?> showAdaptiveBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useRootNavigator = true,
  bool barrierDismissible = true,
  bool enableDrag = true,
  bool showDragHandle = false,
  RouteSettings? routeSettings,
}) => switch (AdaptiveStyle.of(context)) {
  AdaptiveStyle.material => showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isDismissible: barrierDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    showDragHandle: showDragHandle,
    routeSettings: routeSettings,
    builder: builder,
  ),
  AdaptiveStyle.apple =>
    Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
      CupertinoSheetRoute<T>(
        settings: routeSettings,
        enableDrag: enableDrag,
        showDragHandle: showDragHandle,
        scrollableBuilder: (context, _) => builder(context),
      ),
    ),
};
