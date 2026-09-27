import 'package:flutter/cupertino.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';

/// Adapts sidebar toolbar geometry to a Cupertino navigation bar.
class CupertinoSidebarNavigationBarBottom extends StatelessWidget
    implements PreferredSizeWidget {
  const CupertinoSidebarNavigationBarBottom._({required this.height});

  static CupertinoSidebarNavigationBarBottom? maybeFromGeometry(
    CupertinoSidebarToolbarGeometry geometry,
  ) {
    final height = geometry.height - geometry.contentHeight;
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
