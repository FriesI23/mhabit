import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;

import '../adaptive/adaptive_list_theme.dart';
import '../adaptive/list_section_row_scope.dart';
import '../adaptive_style.dart';
import 'cupertino_ink_well.dart';

const double _kGroupedContentHeight = 40;
const double _kGroupedMinHeight = 54;
const double _kGroupedMinHeightWithSubtitle = 60;

/// Standard Cupertino row with keyboard activation and wrapping text slots.
/// Color overrides take precedence over AdaptiveListThemeData and ColorScheme.
class CupertinoAdaptiveListTile extends StatelessWidget {
  const CupertinoAdaptiveListTile({
    super.key,
    required this.title,
    this.foregroundColor,
    this.secondaryColor,
    this.activatedColor,
    this.focusColor,
    this.iconColor,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
  });

  final Widget title;
  final Color? foregroundColor;
  final Color? secondaryColor;
  final Color? activatedColor;
  final Color? focusColor;
  final Color? iconColor;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  ListSectionRowScope? _groupedSectionOf(BuildContext context) {
    final section = ListSectionRowScope.maybeOf(context);
    return section?.style == AdaptiveStyle.apple ? section : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AdaptiveListTheme.of(context);
    final global = theme.extension<AdaptiveListThemeData>();
    final defaults = _CupertinoListTileDefaults(context);
    final foregroundColor = CupertinoDynamicColor.resolve(
      this.foregroundColor ??
          palette.foregroundColor ??
          global?.foregroundColor ??
          defaults.foregroundColor,
      context,
    );
    final secondaryColor = CupertinoDynamicColor.resolve(
      this.secondaryColor ??
          palette.secondaryColor ??
          global?.secondaryColor ??
          defaults.secondaryColor,
      context,
    );
    final activatedColor = CupertinoDynamicColor.resolve(
      this.activatedColor ??
          palette.activatedColor ??
          global?.activatedColor ??
          defaults.activatedColor,
      context,
    );
    final focusColor = CupertinoDynamicColor.resolve(
      this.focusColor ??
          palette.focusColor ??
          global?.focusColor ??
          defaults.focusColor,
      context,
    );
    final iconColor = CupertinoDynamicColor.resolve(
      this.iconColor ??
          palette.iconColor ??
          global?.iconColor ??
          defaults.iconColor,
      context,
    );
    final section = _groupedSectionOf(context);
    final grouped = section != null;
    final effectiveTrailing = grouped && trailing != null
        ? ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: _kGroupedContentHeight,
            ),
            child: trailing,
          )
        : trailing;
    final tile = CupertinoListTile(
      onTap: onTap,
      backgroundColorActivated: activatedColor,
      padding: grouped
          ? EdgeInsetsDirectional.fromSTEB(
              16,
              subtitle == null ? 7 : 10,
              16,
              subtitle == null ? 7 : 10,
            )
          : null,
      leadingSize: grouped && leading == null ? 23 : 28,
      leadingToTitle: grouped ? 12 : 16,
      title: _WrappingText(color: foregroundColor, child: title),
      subtitle: subtitle == null
          ? null
          : _WrappingText(
              fontSize: grouped ? 15 : null,
              color: secondaryColor,
              child: subtitle!,
            ),
      leading: leading == null
          ? null
          : IconTheme.merge(
              data: IconThemeData(color: iconColor),
              child: leading!,
            ),
      trailing: grouped && effectiveTrailing != null
          ? IconTheme.merge(
              data: IconThemeData(size: 20, color: iconColor),
              child: effectiveTrailing,
            )
          : effectiveTrailing,
    );
    final content = grouped
        ? ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: subtitle == null
                  ? _kGroupedMinHeight
                  : _kGroupedMinHeightWithSubtitle,
            ),
            child: tile,
          )
        : tile;
    return CupertinoInkWell(
      onActivate: onTap,
      onLongPress: onLongPress,
      pressedColor: activatedColor,
      focusColor: focusColor,
      shape: section?.shape ?? const RoundedRectangleBorder(),
      child: content,
    );
  }
}

// Reset the SDK's one-line default without reconstructing caller-provided
// Text/Text.rich widgets. Explicit caller text constraints still take priority.
class _WrappingText extends StatelessWidget {
  const _WrappingText({
    required this.child,
    this.fontSize,
    required this.color,
  });

  final Widget child;
  final double? fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) => DefaultTextStyle(
    style: DefaultTextStyle.of(
      context,
    ).style.copyWith(fontSize: fontSize, color: color),
    softWrap: true,
    overflow: TextOverflow.clip,
    child: child,
  );
}

class _CupertinoListTileDefaults extends AdaptiveListThemeData {
  _CupertinoListTileDefaults(this.context);

  final BuildContext context;
  late final _colors = Theme.of(context).colorScheme;

  @override
  Color get foregroundColor => _colors.onSurface;

  @override
  Color get secondaryColor => _colors.onSurfaceVariant;

  @override
  Color get activatedColor => _colors.surfaceContainerHighest;

  @override
  Color get focusColor => _colors.primary;

  @override
  Color get iconColor => _colors.onSurfaceVariant;
}
