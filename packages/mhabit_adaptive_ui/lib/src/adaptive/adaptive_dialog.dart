import 'package:flutter/material.dart';

import '../adaptive_modal.dart';
import '../adaptive_style.dart';

/// One-shot dialog invocation dispatched to the platform-appropriate style.
///
/// Parameters are bound at construction; invoke the instance to show the
/// dialog: `AdaptiveDialog(context: context, builder: ...)()`.
final class AdaptiveDialog<T> implements AdaptiveModal<T> {
  const AdaptiveDialog({required this.context, required this.builder})
    : style = null;

  const AdaptiveDialog.material({required this.context, required this.builder})
    : style = AdaptiveStyle.material;

  final AdaptiveStyle? style;

  @override
  final BuildContext context;

  final WidgetBuilder builder;

  @override
  Future<T?> call() {
    final effective = style ?? adaptiveStyle;
    return switch (effective) {
      // TODO(Phase 3): CupertinoAlertDialog / CupertinoActionSheet.
      AdaptiveStyle.apple || AdaptiveStyle.material => showDialog<T>(
        context: context,
        builder: builder,
      ),
    };
  }
}
