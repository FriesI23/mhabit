import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Adds keyboard activation and focus feedback to a Cupertino gesture control.
///
/// The child retains its pointer handling and pressed appearance. This layer
/// does not register another tap gesture or replace the child's tap semantics.
class CupertinoInkWell extends StatefulWidget {
  const CupertinoInkWell({
    super.key,
    required this.child,
    this.onActivate,
    this.focusColor,
    this.shape = const RoundedRectangleBorder(),
    this.focusNode,
    this.autofocus = false,
  });

  final Widget child;
  final VoidCallback? onActivate;
  final Color? focusColor;
  final OutlinedBorder shape;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<CupertinoInkWell> createState() => _CupertinoInkWellState();
}

class _CupertinoInkWellState extends State<CupertinoInkWell> {
  bool _showFocus = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onActivate == null) return widget.child;
    return FocusableActionDetector(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: SystemMouseCursors.click,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onActivate?.call();
            return null;
          },
        ),
      },
      onShowFocusHighlight: (value) => setState(() => _showFocus = value),
      child: Semantics(
        button: true,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: ShapeDecoration(
            shape: widget.shape.copyWith(
              side: _showFocus
                  ? BorderSide(
                      color: CupertinoDynamicColor.resolve(
                        widget.focusColor ??
                            CupertinoTheme.of(context).primaryColor,
                        context,
                      ),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    )
                  : BorderSide.none,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
