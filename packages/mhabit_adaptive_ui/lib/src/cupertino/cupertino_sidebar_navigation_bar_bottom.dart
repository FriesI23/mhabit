import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';

/// Adapts sidebar toolbar geometry to a Cupertino navigation bar.
class CupertinoSidebarNavigationBarBottom extends StatelessWidget
    implements PreferredSizeWidget {
  const CupertinoSidebarNavigationBarBottom._({required this.height});

  /// Subtracts the content row and [toolbarTopInset] from the Sidebar height
  /// to avoid reserving top spacing twice. Returns null when no spacer remains.
  static CupertinoSidebarNavigationBarBottom? maybeFromGeometry(
    CupertinoSidebarToolbarGeometry geometry, {
    double toolbarTopInset = 0,
  }) {
    final height = math.max(
      0.0,
      geometry.height - geometry.contentHeight - toolbarTopInset,
    );
    return height == 0
        ? null
        : CupertinoSidebarNavigationBarBottom._(height: height);
  }

  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}
