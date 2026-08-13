import 'package:flutter/material.dart';

import '../adaptive_modal.dart';
import '../adaptive_style.dart';

/// One-shot bottom-sheet invocation dispatched to the platform-appropriate
/// style.
///
/// Parameters are bound at construction; invoke the instance to show the
/// sheet: `AdaptiveBottomSheet(context: context, builder: ...)()`.
final class AdaptiveBottomSheet<T> implements AdaptiveModal<T> {
  const AdaptiveBottomSheet({
    required this.context,
    required this.builder,
    this.isScrollControlled = false,
  }) : style = null;

  const AdaptiveBottomSheet.material({
    required this.context,
    required this.builder,
    this.isScrollControlled = false,
  }) : style = AdaptiveStyle.material;

  final AdaptiveStyle? style;

  @override
  final BuildContext context;

  final WidgetBuilder builder;
  final bool isScrollControlled;

  @override
  Future<T?> call() {
    final effective = style ?? adaptiveStyle;
    return switch (effective) {
      // TODO(Phase 3): card-style sheet with gesture dismissal.
      AdaptiveStyle.apple || AdaptiveStyle.material => showModalBottomSheet<T>(
        context: context,
        builder: builder,
        isScrollControlled: isScrollControlled,
      ),
    };
  }
}
