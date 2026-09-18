import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Adds keyboard activation, focus feedback, and supplemental pointer gestures
/// to a Cupertino gesture control.
///
/// The child retains its tap handling and pressed appearance. This layer does
/// not register another tap gesture or replace the child's tap semantics.
class CupertinoInkWell extends StatefulWidget {
  const CupertinoInkWell({
    super.key,
    required this.child,
    this.onActivate,
    this.onLongPress,
    this.pressedColor,
    this.focusColor,
    this.shape = const RoundedRectangleBorder(),
    this.focusNode,
    this.autofocus = false,
  });

  final Widget child;
  final VoidCallback? onActivate;
  final VoidCallback? onLongPress;
  final Color? pressedColor;
  final Color? focusColor;
  final OutlinedBorder shape;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<CupertinoInkWell> createState() => _CupertinoInkWellState();
}

class _CupertinoInkWellState extends State<CupertinoInkWell> {
  bool _showFocus = false;
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.onActivate == null
        ? widget.child
        : FocusableActionDetector(
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
    final pressedColor = CupertinoDynamicColor.resolve(
      widget.pressedColor ?? CupertinoColors.systemGrey4,
      context,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: widget.onLongPress,
      onLongPressCancel: widget.onLongPress == null
          ? null
          : () => _setPressed(false),
      onLongPressEnd: widget.onLongPress == null
          ? null
          : (_) => _setPressed(false),
      child: Listener(
        onPointerDown: widget.onLongPress == null
            ? null
            : (_) => _setPressed(true),
        onPointerUp: widget.onLongPress == null
            ? null
            : (_) => _setPressed(false),
        onPointerCancel: widget.onLongPress == null
            ? null
            : (_) => _setPressed(false),
        child: ColoredBox(
          color: _pressed ? pressedColor : CupertinoColors.transparent,
          child: child,
        ),
      ),
    );
  }
}
