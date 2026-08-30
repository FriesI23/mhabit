import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;

/// Platform-standard button used by the Cupertino Sidebar shell.
class CupertinoNavigationSidebarButton extends StatelessWidget {
  const CupertinoNavigationSidebarButton({
    super.key,
    required this.focusNode,
    required this.label,
    required this.onPressed,
    required this.buttonKey,
  });

  final FocusNode focusNode;
  final String label;
  final VoidCallback onPressed;
  final Key buttonKey;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    return Tooltip(
      message: label,
      child: CupertinoButton(
        key: buttonKey,
        focusNode: focusNode,
        minimumSize: const Size.square(44),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: Icon(
            direction == TextDirection.ltr
                ? CupertinoIcons.sidebar_left
                : CupertinoIcons.sidebar_right,
          ),
        ),
      ),
    );
  }
}
