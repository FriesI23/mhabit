import 'package:flutter/cupertino.dart';

import 'adaptive_cupertino_focus_decoration.dart';

/// Applies the shared app focus visual to a focusable descendant.
class AdaptiveCupertinoFocusHalo extends StatefulWidget {
  const AdaptiveCupertinoFocusHalo({
    super.key,
    required this.child,
    this.borderRadius,
  });

  final Widget child;
  final BorderRadiusGeometry? borderRadius;

  @override
  State<AdaptiveCupertinoFocusHalo> createState() =>
      _AdaptiveCupertinoFocusHaloState();
}

class _AdaptiveCupertinoFocusHaloState
    extends State<AdaptiveCupertinoFocusHalo> {
  bool _childHasFocus = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: (hasFocus) {
        if (_childHasFocus == hasFocus) return;
        setState(() => _childHasFocus = hasFocus);
      },
      child: AdaptiveCupertinoFocusDecoration(
        visible: _childHasFocus,
        decoration: ShapeDecoration(
          shape: RoundedSuperellipseBorder(
            borderRadius:
                widget.borderRadius ??
                kCupertinoButtonSizeBorderRadius[CupertinoButtonSize.large]!,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
