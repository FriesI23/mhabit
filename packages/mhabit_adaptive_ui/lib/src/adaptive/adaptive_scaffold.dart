import 'package:flutter/material.dart';

import '../adaptive_style.dart';

/// Adaptive page scaffold.
///
/// The default constructor resolves the style from the current platform;
/// `.material` forces the Material style. Phase 3 adds the apple style
/// (FAB behavior / safe-area differences).
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
  }) : style = null;

  const AdaptiveScaffold.material({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
  }) : style = AdaptiveStyle.material;

  final AdaptiveStyle? style;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? context.adaptiveStyle;
    return switch (effective) {
      // TODO(adaptive-ui::apple): apple style (FAB behavior / safe-area).
      AdaptiveStyle.apple ||
      AdaptiveStyle.material ||
      AdaptiveStyle.desktop => _buildMaterial(),
    };
  }

  Widget _buildMaterial() {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
    );
  }
}
