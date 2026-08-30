import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show MaterialLocalizations;

import '../adaptive/adaptive_navigation_destination.dart';
import '../material/material_navigation_rail.dart' show NavigationRailExtent;
import '../shell/navigation_shell_frame.dart';
import '../shell/navigation_sidebar_app_bar_leading.dart';
import '../window_control/window_control_layout.dart';
import 'cupertino_navigation_sidebar_button.dart';
import 'cupertino_navigation_sidebar_panel.dart';

/// Cupertino-owned side-navigation body.
///
/// Medium and larger windows use one beside Sidebar presentation. The Sidebar
/// can be completely hidden, but never collapses to an icon-only rail.
class CupertinoNavigationSidebar extends StatefulWidget {
  const CupertinoNavigationSidebar({
    super.key,
    required this.form,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.railExtent,
    this.expandNavigationLabel,
    this.collapseNavigationLabel,
    required this.child,
  });

  final NavigationShellForm form;
  final int selectedIndex;
  final List<AdaptiveNavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final NavigationRailExtent railExtent;

  /// Optional override for the localized action label used when showing.
  final String? expandNavigationLabel;

  /// Optional override for the localized action label used when hiding.
  final String? collapseNavigationLabel;
  final Widget child;

  @override
  State<CupertinoNavigationSidebar> createState() =>
      _CupertinoNavigationSidebarState();
}

class _CupertinoNavigationSidebarState extends State<CupertinoNavigationSidebar>
    with SingleTickerProviderStateMixin {
  static const double _surfaceMargin = 12;
  static const double _contentGap = 12;
  static const double _edgeGestureWidth = 20;
  static const double _appBarLeadingPadding = 16;
  static const double _panelToggleTrailingPadding = 8;

  late final AnimationController _animation = AnimationController(
    vsync: this,
    value: 1,
  );
  late final Animation<double> _curvedAnimation = CurvedAnimation(
    parent: _animation,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeOut,
  );
  final FocusNode _toggleFocusNode = FocusNode(
    debugLabel: 'cupertino-sidebar-toggle',
  );
  bool _visible = true;
  double? _manualWidth;
  bool _manualAboveAuto = false;
  double _dragCurrentWidth = 0;
  bool _dragging = false;
  double _edgeDragDistance = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animation.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : navigationShellAnimationDuration;
  }

  @override
  void dispose() {
    _toggleFocusNode.dispose();
    _animation.dispose();
    super.dispose();
  }

  double _automaticWidth(double windowWidth) =>
      widget.railExtent.resolve(windowWidth);

  double _effectiveWidth(double windowWidth) {
    final manualWidth = _manualWidth;
    if (manualWidth == null) return _automaticWidth(windowWidth);
    final bound = _manualAboveAuto
        ? widget.railExtent.upperBoundAt(windowWidth)
        : _automaticWidth(windowWidth);
    return math.min(manualWidth, bound);
  }

  void _toggle() {
    setState(() => _visible = !_visible);
    if (_visible) {
      _animation.forward();
    } else {
      _animation.reverse();
    }
  }

  void _handleResizeStart(double windowWidth) {
    setState(() {
      _dragging = true;
      _dragCurrentWidth = _effectiveWidth(windowWidth);
    });
  }

  void _handleResizeUpdate(double logicalDelta, double windowWidth) {
    setState(() {
      _dragCurrentWidth = widget.railExtent.clamp(
        _dragCurrentWidth + logicalDelta,
        windowWidth: windowWidth,
      );
      _manualWidth = _dragCurrentWidth;
      _manualAboveAuto = _dragCurrentWidth > _automaticWidth(windowWidth);
    });
  }

  void _handleResizeEnd() {
    if (!_dragging) return;
    setState(() => _dragging = false);
  }

  void _handleEdgeDragStart() => _edgeDragDistance = 0;

  void _handleEdgeDragUpdate(double logicalDelta) {
    _edgeDragDistance += logicalDelta;
  }

  void _handleEdgeDragEnd(double logicalVelocity) {
    final shouldOpen =
        _edgeDragDistance >= kTouchSlop || logicalVelocity >= kMinFlingVelocity;
    _edgeDragDistance = 0;
    if (!shouldOpen || _visible) return;
    setState(() => _visible = true);
    _animation.forward();
  }

  void _handleEdgeDragCancel() => _edgeDragDistance = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.form == NavigationShellForm.compact) return widget.child;

    final materialLocalizations = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    final expandNavigationLabel =
        widget.expandNavigationLabel ??
        materialLocalizations?.collapsedIconTapHint ??
        'Expand';
    final collapseNavigationLabel =
        widget.collapseNavigationLabel ??
        materialLocalizations?.expandedIconTapHint ??
        'Collapse';
    final windowWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = _effectiveWidth(windowWidth);
    final mediaPadding = MediaQuery.paddingOf(context);
    final direction = Directionality.of(context);
    final leadingSafeMargin = math.max(
      _surfaceMargin,
      direction == TextDirection.ltr ? mediaPadding.left : mediaPadding.right,
    );
    final toolbarTopInset = math.max(0.0, _surfaceMargin - mediaPadding.top);
    final buttonTop = math.max(_surfaceMargin, mediaPadding.top);
    final sideNavigationAvoidance =
        AdaptiveWindowControlLayoutScope.sideNavigationHorizontalAvoidanceOf(
          context,
        );
    final visibleButtonStart =
        leadingSafeMargin +
        panelWidth -
        math.max(sideNavigationAvoidance.end, _panelToggleTrailingPadding) -
        NavigationSidebarAppBarLeading.buttonExtent;
    final hiddenButtonStart =
        sideNavigationAvoidance.start + _appBarLeadingPadding;
    return AnimatedBuilder(
      animation: _curvedAnimation,
      builder: (context, child) {
        final progress = _curvedAnimation.value;
        final panelActive = _animation.value > 0;
        final appBarProgress = 1 - progress;
        final toolbarAvoidance = EdgeInsetsDirectional.lerp(
          EdgeInsetsDirectional.zero,
          sideNavigationAvoidance,
          appBarProgress,
        )!;
        final buttonStart =
            hiddenButtonStart +
            (visibleButtonStart - hiddenButtonStart) * progress;
        final branch = _CupertinoSidebarBranch(
          occupiedSpan:
              (leadingSafeMargin + panelWidth + _contentGap) * progress,
          child: NavigationSidebarAppBarLeading(
            toolbarAvoidance: toolbarAvoidance,
            toolbarTopInset: toolbarTopInset,
            progress: appBarProgress,
            child: widget.child,
          ),
        );
        final stack = Stack(
          key: const ValueKey('cupertino-sidebar-beside-host'),
          fit: StackFit.expand,
          children: [
            branch,
            if (panelActive)
              _CupertinoSidebarAnimatedPanel(
                progress: progress,
                child: CupertinoNavigationSidebarPanel(
                  width: panelWidth,
                  contentActive: progress == 1,
                  selectedIndex: widget.selectedIndex,
                  destinations: widget.destinations,
                  onDestinationSelected: widget.onDestinationSelected,
                  dragging: _dragging,
                  onResizeStart: () => _handleResizeStart(windowWidth),
                  onResizeUpdate: (delta) =>
                      _handleResizeUpdate(delta, windowWidth),
                  onResizeEnd: _handleResizeEnd,
                ),
              ),
            PositionedDirectional(
              key: const ValueKey('cupertino-sidebar-toggle-position'),
              start: buttonStart,
              top: buttonTop,
              width: NavigationSidebarAppBarLeading.buttonExtent,
              height: NavigationSidebarAppBarLeading.buttonExtent,
              child: CupertinoNavigationSidebarButton(
                focusNode: _toggleFocusNode,
                label: _visible
                    ? collapseNavigationLabel
                    : expandNavigationLabel,
                onPressed: _toggle,
                buttonKey: const ValueKey('cupertino-sidebar-toggle'),
              ),
            ),
          ],
        );
        return _CupertinoSidebarEdgeGesture(
          enabled: !panelActive,
          edgeWidth: _edgeGestureWidth,
          onStart: _handleEdgeDragStart,
          onUpdate: _handleEdgeDragUpdate,
          onEnd: _handleEdgeDragEnd,
          onCancel: _handleEdgeDragCancel,
          child: stack,
        );
      },
    );
  }
}

class _CupertinoSidebarEdgeGesture extends StatelessWidget {
  const _CupertinoSidebarEdgeGesture({
    required this.enabled,
    required this.edgeWidth,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.onCancel,
    required this.child,
  });

  final bool enabled;
  final double edgeWidth;
  final VoidCallback onStart;
  final ValueChanged<double> onUpdate;
  final ValueChanged<double> onEnd;
  final VoidCallback onCancel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final viewWidth = MediaQuery.sizeOf(context).width;
    return RawGestureDetector(
      key: const ValueKey('cupertino-sidebar-edge-gesture'),
      behavior: HitTestBehavior.translucent,
      gestures: enabled
          ? <Type, GestureRecognizerFactory>{
              _CupertinoSidebarEdgeDragRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                    _CupertinoSidebarEdgeDragRecognizer
                  >(_CupertinoSidebarEdgeDragRecognizer.new, (recognizer) {
                    recognizer
                      ..edgeWidth = edgeWidth
                      ..viewWidth = viewWidth
                      ..textDirection = direction
                      ..onStart = (_) {
                        onStart();
                      }
                      ..onUpdate = (details) {
                        final logicalDelta = direction == TextDirection.ltr
                            ? details.delta.dx
                            : -details.delta.dx;
                        onUpdate(logicalDelta);
                      }
                      ..onEnd = (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        final logicalVelocity = direction == TextDirection.ltr
                            ? velocity
                            : -velocity;
                        onEnd(logicalVelocity);
                      }
                      ..onCancel = onCancel;
                  }),
            }
          : const <Type, GestureRecognizerFactory>{},
      child: child,
    );
  }
}

class _CupertinoSidebarEdgeDragRecognizer
    extends HorizontalDragGestureRecognizer {
  double edgeWidth = 0;
  double viewWidth = 0;
  TextDirection textDirection = TextDirection.ltr;

  @override
  bool isPointerAllowed(PointerEvent event) {
    if (!super.isPointerAllowed(event)) return false;
    return switch (textDirection) {
      TextDirection.ltr => event.position.dx <= edgeWidth,
      TextDirection.rtl => event.position.dx >= viewWidth - edgeWidth,
    };
  }

  @override
  String get debugDescription => 'cupertino sidebar edge drag';
}

class _CupertinoSidebarBranch extends StatelessWidget {
  const _CupertinoSidebarBranch({
    required this.occupiedSpan,
    required this.child,
  });

  final double occupiedSpan;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('cupertino-sidebar-branch-safe-span'),
      padding: EdgeInsetsDirectional.only(start: occupiedSpan),
      child: child,
    );
  }
}

class _CupertinoSidebarAnimatedPanel extends StatelessWidget {
  const _CupertinoSidebarAnimatedPanel({
    required this.progress,
    required this.child,
  });

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: FractionalTranslation(
          translation: Offset(
            (direction == TextDirection.ltr ? -1 : 1) * (1 - progress),
            0,
          ),
          child: Opacity(opacity: progress, child: child),
        ),
      ),
    );
  }
}
