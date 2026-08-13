import 'package:flutter/material.dart';

import '../adaptive_style.dart';

/// Adaptive sliver search bar.
///
/// Must be placed in a viewport `slivers:` list. The default constructor
/// resolves the style from the current platform; `.material` forces the
/// Material style. Phase 3 adds the apple style (iOS-style expanding search).
class AdaptiveSliverSearchBar extends StatelessWidget {
  const AdaptiveSliverSearchBar({
    super.key,
    required this.onChanged,
    this.hintText,
    this.onSubmitted,
  }) : style = null;

  const AdaptiveSliverSearchBar.material({
    super.key,
    required this.onChanged,
    this.hintText,
    this.onSubmitted,
  }) : style = AdaptiveStyle.material;

  final AdaptiveStyle? style;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? context.adaptiveStyle;
    return switch (effective) {
      // TODO(Phase 3): apple style (iOS-style expanding search).
      AdaptiveStyle.apple || AdaptiveStyle.material => _buildMaterial(),
    };
  }

  Widget _buildMaterial() {
    // Equivalent of the app's current `SliverSearchTopAppBar` baseline.
    return SliverAppBar(
      pinned: true,
      title: SearchBar(
        hintText: hintText,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
