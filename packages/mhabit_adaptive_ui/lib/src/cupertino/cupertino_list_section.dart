import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;

import '../adaptive/adaptive_list_theme.dart';
import '../adaptive/list_section_row_scope.dart';
import '../adaptive_style.dart';

/// Content-layer grouping based on an iOS 26 inset-grouped table reference.
/// Uses Flutter's continuous shape and clip primitives, not Liquid Glass.
class CupertinoAdaptiveListSection extends StatelessWidget {
  const CupertinoAdaptiveListSection({
    super.key,
    this.header,
    required this.children,
    this.surfaceColor,
    this.secondaryColor,
    this.separatorColor,
    this.hasLeading = false,
    this.padding,
  });

  final Widget? header;
  final List<Widget> children;
  final Color? surfaceColor;
  final Color? secondaryColor;
  final Color? separatorColor;
  final bool hasLeading;
  final EdgeInsetsGeometry? padding;

  // App geometry chosen against the iOS 26.5 UIKit reference; these are not
  // claimed to be public, fixed Apple design tokens.
  static const _radius = Radius.circular(26);

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final palette = AdaptiveListTheme.of(context);
    final global = theme.extension<AdaptiveListThemeData>();
    final defaults = _CupertinoListSectionDefaults(context);
    final surface = CupertinoDynamicColor.resolve(
      surfaceColor ??
          palette.surfaceColor ??
          global?.surfaceColor ??
          defaults.surfaceColor,
      context,
    );
    final secondary = CupertinoDynamicColor.resolve(
      secondaryColor ??
          palette.secondaryColor ??
          global?.secondaryColor ??
          defaults.secondaryColor,
      context,
    );
    final separator = CupertinoDynamicColor.resolve(
      separatorColor ??
          palette.separatorColor ??
          global?.separatorColor ??
          defaults.separatorColor,
      context,
    );
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
              child: Semantics(
                header: true,
                child: DefaultTextStyle(
                  style: CupertinoTheme.of(context).textTheme.textStyle
                      .copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: secondary,
                      ),
                  child: header!,
                ),
              ),
            ),
          ClipRSuperellipse(
            borderRadius: const BorderRadius.all(_radius),
            child: ColoredBox(
              color: surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < children.length; index++) ...[
                    if (index > 0)
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: hasLeading ? 56 : 16,
                          end: 16,
                        ),
                        child: SizedBox(
                          height: 1 / MediaQuery.devicePixelRatioOf(context),
                          child: ColoredBox(color: separator),
                        ),
                      ),
                    ListSectionRowScope(
                      key: children[index].key == null
                          ? null
                          : ValueKey<Key>(children[index].key!),
                      style: AdaptiveStyle.apple,
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.vertical(
                          top: index == 0 ? _radius : Radius.zero,
                          bottom: index == children.length - 1
                              ? _radius
                              : Radius.zero,
                        ),
                      ),
                      child: children[index],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CupertinoListSectionDefaults extends AdaptiveListThemeData {
  _CupertinoListSectionDefaults(this.context);

  final BuildContext context;
  late final _colors = Theme.of(context).colorScheme;

  @override
  Color get surfaceColor => _colors.surfaceContainer;

  @override
  Color get secondaryColor => _colors.onSurfaceVariant;

  @override
  Color get separatorColor => _colors.outlineVariant;
}
