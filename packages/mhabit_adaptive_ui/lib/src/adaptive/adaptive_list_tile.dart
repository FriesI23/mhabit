import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_adaptive_list_tile.dart';
import 'list_section_row_scope.dart';

enum _AdaptiveListTileKind { standard, external, navigation }

/// Adaptive list item.
///
/// The default constructor resolves the style from the current platform;
/// `.material` and `.apple` force a renderer. Apple uses a standard Cupertino
/// list tile with wrapping text and keyboard activation. Separators belong to
/// the surrounding list section; trailing content is supplied by the caller.
/// `.external` represents a destination outside the app and supplies the
/// platform-appropriate external-navigation indicator.
/// `.navigation` represents navigation to another destination inside the app
/// and supplies the platform-appropriate disclosure indicator.
class AdaptiveListTile extends StatelessWidget {
  const AdaptiveListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
  }) : style = null,
       _kind = _AdaptiveListTileKind.standard;

  const AdaptiveListTile.external({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.onTap,
    this.onLongPress,
  }) : style = null,
       trailing = null,
       _kind = _AdaptiveListTileKind.external;

  const AdaptiveListTile.navigation({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.onTap,
    this.onLongPress,
  }) : style = null,
       trailing = null,
       _kind = _AdaptiveListTileKind.navigation;

  const AdaptiveListTile.material({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
  }) : style = AdaptiveStyle.material,
       _kind = _AdaptiveListTileKind.standard;

  const AdaptiveListTile.apple({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
  }) : style = AdaptiveStyle.apple,
       _kind = _AdaptiveListTileKind.standard;

  final AdaptiveStyle? style;
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final _AdaptiveListTileKind _kind;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? AdaptiveStyle.of(context);
    final effectiveTrailing = switch ((_kind, effective)) {
      (_AdaptiveListTileKind.external, AdaptiveStyle.material) => const Icon(
        Icons.open_in_new,
      ),
      (_AdaptiveListTileKind.external, AdaptiveStyle.apple) => const Icon(
        CupertinoIcons.arrow_up_right_square,
      ),
      (_AdaptiveListTileKind.navigation, AdaptiveStyle.material) => null,
      (_AdaptiveListTileKind.navigation, AdaptiveStyle.apple) => const Icon(
        CupertinoIcons.chevron_forward,
      ),
      (_AdaptiveListTileKind.standard, _) => trailing,
    };
    return switch (effective) {
      AdaptiveStyle.apple => CupertinoAdaptiveListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: effectiveTrailing,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
      AdaptiveStyle.material => _buildMaterial(context, effectiveTrailing),
    };
  }

  Widget _buildMaterial(BuildContext context, Widget? effectiveTrailing) {
    final section = ListSectionRowScope.maybeOf(context);
    return ListTile(
      statesController: section?.style == AdaptiveStyle.material
          ? section?.statesController
          : null,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: effectiveTrailing,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
