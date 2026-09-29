import 'package:flutter/widgets.dart';

import 'adaptive_cupertino_focus_theme.dart';

/// Keeps animated content bounded while allowing a Cupertino focus halo to
/// paint just outside the layout slot.
class CupertinoFocusHaloClip extends StatelessWidget {
  const CupertinoFocusHaloClip({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final overflow = AdaptiveCupertinoFocusThemeData.of(
      context,
    ).haloPaintOutset;
    return ClipRect(
      clipper: _CupertinoFocusHaloRectClipper(overflow),
      child: child,
    );
  }
}

class _CupertinoFocusHaloRectClipper extends CustomClipper<Rect> {
  const _CupertinoFocusHaloRectClipper(this.overflow) : assert(overflow >= 0);

  final double overflow;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(
    -overflow,
    -overflow,
    size.width + overflow,
    size.height + overflow,
  );

  @override
  bool shouldReclip(_CupertinoFocusHaloRectClipper oldClipper) =>
      overflow != oldClipper.overflow;
}
