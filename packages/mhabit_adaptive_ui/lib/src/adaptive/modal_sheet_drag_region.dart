import 'package:flutter/material.dart';

/// Controls the extent and direct-drag lifecycle of an automatic modal sheet.
///
/// This controller is passed to [DraggableScrollableSheet.controller]. Fixed
/// chrome wrapped in [ModalSheetDragRegion] uses [start], [update], [end], and
/// [cancel] to change the sheet extent without first changing the body scroll
/// offset. The body continues to use the [ScrollController] supplied by
/// [DraggableScrollableSheet.builder].
///
/// ```text
/// ┌──────── automatic modal sheet ────────┐
/// │  ───── drag handle ─────  ⇅ extent   │
/// │  app bar                  ⇅ extent   │
/// ├──────────────────────────────────────┤
/// │  scrollable body           ↕ scroll  │
/// └──────────────────────────────────────┘
/// ```
///
/// A downward fling or a drag of at least half the maximum sheet height asks
/// the route to close. Otherwise the sheet returns to [maxExtent]. If closing
/// is rejected, [shouldSettleAfterClose] lets the controller return the still
/// active sheet to its maximum extent.
class ModalSheetDragController extends DraggableScrollableController {
  /// Creates a controller for an automatic modal sheet.
  ///
  /// The returned object must also be supplied to the corresponding
  /// [DraggableScrollableSheet.controller].
  ModalSheetDragController({
    required this.maxExtent,
    required this.minExtent,
    required this.onCloseRequested,
    required this.shouldSettleAfterClose,
  });

  /// Returns the current maximum sheet extent as a fraction of its parent.
  ///
  /// This is a callback because the maximum may change with the available
  /// window size.
  final double Function() maxExtent;

  /// The minimum sheet extent as a fraction of its parent.
  final double minExtent;

  /// Requests that the route containing the sheet close.
  ///
  /// The future completes after the close request has been handled, including
  /// any application-level close guard.
  final Future<void> Function() onCloseRequested;

  /// Whether the sheet should return to [maxExtent] after a close request.
  ///
  /// This should return true when the route is still active, such as when a
  /// close guard rejected the request.
  final bool Function() shouldSettleAfterClose;

  bool _dragInProgress = false;
  bool _disposed = false;

  static const double _minFlingVelocity = 700;

  /// Begins a direct drag from fixed sheet chrome.
  ///
  /// Any active extent or body-scroll animation is stopped before tracking the
  /// gesture. This method has no effect while the controller is detached.
  void start(DragStartDetails details) {
    if (_disposed || !isAttached) return;
    jumpTo(size);
    _dragInProgress = true;
  }

  /// Applies a direct vertical drag delta to the sheet extent.
  ///
  /// The extent is clamped just above [minExtent] so reaching the lower bound
  /// cannot request a close before [end] decides how the gesture should settle.
  void update(DragUpdateDetails details) {
    if (_disposed || !_dragInProgress || !isAttached) return;
    final delta = details.primaryDelta ?? 0;
    final minPixels = sizeToPixels(minExtent);
    final maxPixels = sizeToPixels(maxExtent());
    final requestedPixels = (pixels - delta).clamp(minPixels + 0.01, maxPixels);
    jumpTo(pixelsToSize(requestedPixels));
  }

  /// Ends a direct drag and either requests closing or restores [maxExtent].
  void end(DragEndDetails details) {
    if (_disposed || !_dragInProgress) return;
    _dragInProgress = false;
    _settle(primaryVelocity: details.primaryVelocity ?? 0);
  }

  /// Cancels a direct drag and restores [maxExtent].
  void cancel() {
    if (_disposed || !_dragInProgress) return;
    _dragInProgress = false;
    _animateBack();
  }

  void _settle({double primaryVelocity = 0}) {
    if (!isAttached) return;
    final maxPixels = sizeToPixels(maxExtent());
    final displacement = maxPixels - pixels;
    if (primaryVelocity >= _minFlingVelocity ||
        displacement >= maxPixels * 0.5) {
      _requestCloseThenSettle();
    } else {
      _animateBack();
    }
  }

  Future<void> _requestCloseThenSettle() async {
    await onCloseRequested();
    if (!_disposed && shouldSettleAfterClose()) _animateBack();
  }

  void _animateBack() {
    if (_disposed || !isAttached) return;
    animateTo(
      maxExtent(),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Supplies a [ModalSheetDragController] to descendant modal chrome.
class ModalSheetDragControllerScope extends InheritedWidget {
  /// Creates a scope for fixed drag regions in [child].
  const ModalSheetDragControllerScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The controller shared by the sheet and its fixed drag regions.
  final ModalSheetDragController controller;

  /// Returns the nearest controller and registers [context] as a dependent.
  ///
  /// Returns null when no [ModalSheetDragControllerScope] is present.
  static ModalSheetDragController? maybeControllerOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ModalSheetDragControllerScope>()
          ?.controller;

  @override
  bool updateShouldNotify(ModalSheetDragControllerScope oldWidget) =>
      controller != oldWidget.controller;
}

/// Makes fixed modal chrome directly drag its sheet.
///
/// Use this for regions such as a drag handle or app bar. Scrollable body
/// content should instead use the controller supplied by
/// [DraggableScrollableSheet.builder].
class ModalSheetDragRegion extends StatefulWidget {
  /// Creates a direct drag region around [child].
  const ModalSheetDragRegion({
    super.key,
    required this.controller,
    required this.child,
  });

  /// The sheet controller that receives vertical drag callbacks.
  final ModalSheetDragController controller;

  /// The fixed chrome that acts as the drag target.
  final Widget child;

  @override
  State<ModalSheetDragRegion> createState() => _ModalSheetDragRegionState();
}

class _ModalSheetDragRegionState extends State<ModalSheetDragRegion> {
  @override
  void didUpdateWidget(ModalSheetDragRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == oldWidget.controller) return;
    final oldController = oldWidget.controller;
    WidgetsBinding.instance.addPostFrameCallback((_) => oldController.cancel());
  }

  @override
  void dispose() {
    final controller = widget.controller;
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onVerticalDragStart: widget.controller.start,
    onVerticalDragUpdate: widget.controller.update,
    onVerticalDragEnd: widget.controller.end,
    onVerticalDragCancel: widget.controller.cancel,
    child: widget.child,
  );
}
