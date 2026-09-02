import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart'
    show BackButton, CloseButton, Color, MaterialLocalizations, Tooltip;
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/widgets.dart'
    show
        BuildContext,
        Center,
        Icon,
        Navigator,
        StatelessWidget,
        VoidCallback,
        Widget;

import '../adaptive_style.dart';
import 'adaptive_icon_button.dart';

/// The navigation meaning represented by an [AdaptiveBackButton].
enum AdaptiveBackButtonType { back, close }

/// A route-dismiss button rendered with the active platform style.
///
/// When [onPressed] is omitted, the button dismisses visible tooltips before
/// attempting to pop the nearest [Navigator].
class AdaptiveBackButton extends StatelessWidget {
  const AdaptiveBackButton({
    super.key,
    this.type = AdaptiveBackButtonType.back,
    this.color,
    this.onPressed,
  }) : style = null;

  const AdaptiveBackButton.material({
    super.key,
    this.type = AdaptiveBackButtonType.back,
    this.color,
    this.onPressed,
  }) : style = AdaptiveStyle.material;

  const AdaptiveBackButton.apple({
    super.key,
    this.type = AdaptiveBackButtonType.back,
    this.color,
    this.onPressed,
  }) : style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final AdaptiveBackButtonType type;
  final Color? color;
  final VoidCallback? onPressed;

  Future<void> _popRoute(BuildContext context) async {
    final dismissedTooltip = Tooltip.dismissAllToolTips();
    await Future<void>.delayed(
      dismissedTooltip
          ? const Duration(milliseconds: 150) * timeDilation
          : Duration.zero,
    );
    if (context.mounted) await Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = this.onPressed ?? () => _popRoute(context);
    return switch (style ?? AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => Center(
        child: switch (type) {
          AdaptiveBackButtonType.back => BackButton(
            onPressed: onPressed,
            color: color,
          ),
          AdaptiveBackButtonType.close => CloseButton(
            onPressed: onPressed,
            color: color,
          ),
        },
      ),
      AdaptiveStyle.apple => _buildApple(context, onPressed),
    };
  }

  Widget _buildApple(BuildContext context, VoidCallback onPressed) {
    final localizations = MaterialLocalizations.of(context);
    return Center(
      child: AdaptiveIconButton.apple(
        onPressed: onPressed,
        tooltip: switch (type) {
          AdaptiveBackButtonType.back => localizations.backButtonTooltip,
          AdaptiveBackButtonType.close => localizations.closeButtonTooltip,
        },
        icon: Icon(switch (type) {
          AdaptiveBackButtonType.back => CupertinoIcons.back,
          AdaptiveBackButtonType.close => CupertinoIcons.xmark,
        }, color: color),
      ),
    );
  }
}
