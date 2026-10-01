import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../cupertino/adaptive_cupertino_focus_theme.dart';
import '../cupertino/cupertino_neutral_button.dart';

/// An icon button that uses the platform renderer selected by adaptive style.
///
/// Material uses [IconButton]. Apple uses Flutter's standard
/// [CupertinoButton] with the 44-point toolbar interaction extent.
class AdaptiveIconButton extends StatelessWidget {
  const AdaptiveIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  }) : style = null;

  const AdaptiveIconButton.material({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  }) : style = AdaptiveStyle.material;

  const AdaptiveIconButton.apple({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  }) : style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) =>
      switch (style ?? AdaptiveStyle.of(context)) {
        AdaptiveStyle.material => IconButton(
          icon: icon,
          tooltip: tooltip,
          onPressed: onPressed,
        ),
        AdaptiveStyle.apple => _buildApple(context),
      };

  Widget _buildApple(BuildContext context) {
    final button = AdaptiveCupertinoFocusHalo(
      child: CupertinoNeutralButtonBuilder(
        builder: (context) => CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(44),
          sizeStyle: CupertinoButtonSize.small,
          focusColor: CupertinoColors.transparent,
          onPressed: onPressed,
          child: icon,
        ),
      ),
    );
    final tooltip = this.tooltip;
    return tooltip == null || tooltip.isEmpty
        ? button
        : Tooltip(message: tooltip, child: button);
  }
}
