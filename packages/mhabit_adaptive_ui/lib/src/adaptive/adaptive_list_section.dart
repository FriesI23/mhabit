import 'package:flutter/cupertino.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_list_section.dart';
import '../material/material_list_section.dart';

/// A short, non-scrolling group of rows with a transparent exterior.
///
/// Apple uses a continuous rounded group with inset separators. Material uses
/// M3 Expressive segmented surfaces. The group surface follows the app's
/// ColorScheme rather than painting a second page background.
///
/// Children keep their own callbacks. Adaptive rows consume the section's
/// geometry; arbitrary children must provide their own platform controls.
/// [hasLeading] aligns Apple separators with rows that have leading content.
/// [padding] overrides the platform's default exterior section padding when
/// the section is already hosted inside another padded surface.
class AdaptiveListSection extends StatelessWidget {
  const AdaptiveListSection({
    super.key,
    this.header,
    required this.children,
    this.hasLeading = false,
    this.padding,
  }) : style = null;

  const AdaptiveListSection.material({
    super.key,
    this.header,
    required this.children,
    this.hasLeading = false,
    this.padding,
  }) : style = AdaptiveStyle.material;

  const AdaptiveListSection.apple({
    super.key,
    this.header,
    required this.children,
    this.hasLeading = false,
    this.padding,
  }) : style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final Widget? header;
  final List<Widget> children;
  final bool hasLeading;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final effective = style ?? AdaptiveStyle.of(context);
    return AdaptiveStyleScope(
      override: effective,
      child: switch (effective) {
        AdaptiveStyle.apple => CupertinoAdaptiveListSection(
          header: header,
          hasLeading: hasLeading,
          padding: padding,
          children: children,
        ),
        AdaptiveStyle.material => MaterialAdaptiveListSection(
          header: header,
          padding: padding,
          children: children,
        ),
      },
    );
  }
}
