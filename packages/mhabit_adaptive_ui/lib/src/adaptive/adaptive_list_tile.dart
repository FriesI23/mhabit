import 'package:flutter/material.dart';

import '../adaptive_style.dart';

/// Adaptive list item.
///
/// The default constructor resolves the style from the current platform;
/// `.material` forces the Material style. Phase 3 adds the apple style
/// (Cupertino separator style, 44pt height).
class AdaptiveListTile extends StatelessWidget {
  const AdaptiveListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  }) : style = null;

  const AdaptiveListTile.material({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  }) : style = AdaptiveStyle.material;

  final AdaptiveStyle? style;
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? context.adaptiveStyle;
    return switch (effective) {
      // TODO(adaptive-ui::apple): apple style (Cupertino separator style, 44pt).
      AdaptiveStyle.apple ||
      AdaptiveStyle.material ||
      AdaptiveStyle.desktop => _buildMaterial(),
    };
  }

  Widget _buildMaterial() {
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
