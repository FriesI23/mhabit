import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show MaterialLocalizations;

import '../adaptive/adaptive_app_bar.dart';
import '../adaptive/adaptive_modal_layout.dart';
import '../window_control/modal_app_bar_region.dart';

const _sheetHeightFactor = 0.92;
const _sheetPopupSurfaceBottomOverflow = 13.0;

/// A Cupertino page route for navigation inside a translucent adaptive modal.
///
/// Regular [CupertinoPageRoute]s dim the route below while transitioning and
/// may animate snapshots. Both behaviors conflict with the modal's shared
/// [CupertinoPopupSurface]: dimming changes its color, while snapshots freeze
/// the clip that separates the two transparent pages.
class CupertinoAdaptiveModalPageRoute<T> extends CupertinoPageRoute<T> {
  CupertinoAdaptiveModalPageRoute({
    required super.builder,
    super.title,
    super.settings,
    super.requestFocus,
    super.maintainState,
  }) : super(allowSnapshotting: false);

  @override
  Color? get barrierColor => null;
}

/// Displays a Cupertino modal whose surface can change with the window size.
///
/// The route remains installed while the responsive content built by [builder]
/// selects its current presentation. This preserves that content's state when
/// a resize changes the surface between a bottom sheet and a dialog. The outer
/// route supplies the shared vertically sliding transition.
///
/// ```text
/// compact or short      medium and larger
/// ┌──────────────┐      ┌──────────────┐
/// │              │      │  ┌────────┐  │
/// │   sheet  ↑   │      │  │ dialog │  │
/// └──────────────┘      │  └────────┘  │
///                       └──────────────┘
/// ```
///
/// The returned future completes with the value passed to [Navigator.pop]
/// when the modal is closed. Set [useRootNavigator] to false to push onto the
/// nearest navigator instead of the root navigator.
Future<T?> showCupertinoAdaptiveModalRoute<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required bool useRootNavigator,
  required RouteSettings? routeSettings,
  required String barrierLabel,
}) => Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
  CupertinoAdaptiveModalRoute<T>(
    settings: routeSettings,
    barrierLabel: barrierLabel,
    builder: builder,
  ),
);

/// Displays a fixed Cupertino dialog above the current contents of the app.
///
/// The dialog uses [CupertinoAdaptiveModalRoute] rather than
/// [showCupertinoDialog] so the adaptive surface can retain its vertical drag
/// and dismissal behavior.
///
/// ```text
/// ┌────────────────┐
/// │   ┌────────┐   │
/// │   │ dialog │   │
/// │   └────────┘   │
/// └────────────────┘
/// ```
///
/// The returned future completes with the value passed to [Navigator.pop]
/// when the dialog is closed.
///
/// See also:
///
///  * [showCupertinoAdaptiveModalRoute], which keeps one route while switching
///    between sheet and dialog presentations as the window size changes.
Future<T?> showCupertinoAdaptiveDialogRoute<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required bool useRootNavigator,
  required RouteSettings? routeSettings,
  required String barrierLabel,
}) => showCupertinoAdaptiveModalRoute<T>(
  context: context,
  builder: builder,
  useRootNavigator: useRootNavigator,
  routeSettings: routeSettings,
  barrierLabel: barrierLabel,
);

/// Displays a fixed Cupertino sheet above the current contents of the app.
///
/// This delegates route creation, drag handling, and scroll coordination to
/// Flutter's [CupertinoSheetRoute]. The controller passed to [builder]
/// coordinates the sheet with its primary scrollable content.
///
/// ```text
/// ┌────────────────┐
/// │                │
/// │ ┌────────────┐ │
/// │ │  sheet  ↑  │ │
/// └─┴────────────┴─┘
/// ```
///
/// The returned future completes with the value passed to [Navigator.pop]
/// when the sheet is closed. [enableDrag] and [showDragHandle] configure the
/// corresponding Cupertino sheet behavior.
///
/// See also:
///
///  * [showCupertinoAdaptiveModalRoute], which keeps one route while switching
///    between sheet and dialog presentations as the window size changes.
Future<T?> showCupertinoAdaptiveSheetRoute<T>({
  required BuildContext context,
  required Widget Function(ScrollController controller) builder,
  required bool useRootNavigator,
  required bool enableDrag,
  required bool showDragHandle,
  required RouteSettings? routeSettings,
}) => Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
  CupertinoSheetRoute<T>(
    settings: routeSettings,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    scrollableBuilder: (context, controller) =>
        _CupertinoSheetBackground(child: builder(controller)),
  ),
);

class CupertinoAdaptiveModalRoute<T> extends PopupRoute<T> {
  CupertinoAdaptiveModalRoute({
    super.settings,
    required this.builder,
    required this.barrierLabel,
  });

  final WidgetBuilder builder;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => const Color(0x66000000);

  @override
  bool get barrierDismissible => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  bool _dragInProgress = false;

  bool get isDragged =>
      _dragInProgress && controller != null && controller!.value < 1;

  void startDrag() {
    final routeController = controller;
    if (routeController == null || !isActive) return;
    routeController.stop();
    if (_dragInProgress) return;
    _dragInProgress = true;
    changedInternalState();
  }

  void updateDrag(double delta) {
    final routeController = controller;
    final routeContext = navigator?.context;
    if (routeController == null || routeContext == null) return;
    final height = MediaQuery.sizeOf(routeContext).height;
    if (height <= 0) return;
    routeController.value = (routeController.value - delta / height).clamp(
      0,
      1,
    );
  }

  void endDrag({
    required double dismissThreshold,
    required Future<void> Function() onCloseRequested,
  }) {
    if (_dragInProgress) {
      _dragInProgress = false;
      if (isActive) changedInternalState();
    }
    final routeController = controller;
    final routeContext = navigator?.context;
    if (routeController == null || routeContext == null) return;
    final height = MediaQuery.sizeOf(routeContext).height;
    final displacement = (1 - routeController.value) * height;
    if (displacement >= dismissThreshold) {
      _requestCloseThenSettle(onCloseRequested);
      return;
    }
    _animateBack();
  }

  Future<void> _requestCloseThenSettle(
    Future<void> Function() onCloseRequested,
  ) async {
    await onCloseRequested();
    if (isActive) _animateBack();
  }

  void _animateBack() {
    final routeController = controller;
    if (routeController == null) return;
    routeController.animateTo(
      1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final drivenAnimation = _dragInProgress
        ? animation
        : CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(drivenAnimation),
      child: child,
    );
  }
}

/// Cupertino route surface used by automatically responsive modals.
class CupertinoAdaptiveModalRouteSurface extends StatefulWidget {
  const CupertinoAdaptiveModalRouteSurface({
    super.key,
    required this.presentation,
    required this.enableDrag,
    required this.showDragHandle,
    required this.onCloseRequested,
    required this.contentBuilder,
  });

  final AdaptiveModalPresentation presentation;
  final bool enableDrag;
  final bool showDragHandle;
  final Future<void> Function() onCloseRequested;
  final Widget Function(ScrollController? controller) contentBuilder;

  @override
  State<CupertinoAdaptiveModalRouteSurface> createState() =>
      _CupertinoAdaptiveModalRouteSurfaceState();
}

class _CupertinoAdaptiveModalRouteSurfaceState
    extends State<CupertinoAdaptiveModalRouteSurface> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const maxExtent = _sheetHeightFactor;
    final surface = switch ((widget.presentation, widget.enableDrag)) {
      (AdaptiveModalPresentation.dialog, false) => Center(
        child: CupertinoPopupSurface(child: widget.contentBuilder(null)),
      ),
      (AdaptiveModalPresentation.dialog, true) => Builder(
        builder: (context) {
          final route = ModalRoute.of(context);
          assert(route is CupertinoAdaptiveModalRoute<dynamic>);
          final cupertinoRoute = route! as CupertinoAdaptiveModalRoute<dynamic>;
          return Center(
            child: _CupertinoDialogScrollDismissRegion(
              showDragHandle: widget.showDragHandle,
              onDragStart: cupertinoRoute.startDrag,
              onDragUpdate: cupertinoRoute.updateDrag,
              onDragEnd: ({required dismissThreshold}) =>
                  cupertinoRoute.endDrag(
                    dismissThreshold: dismissThreshold,
                    onCloseRequested: widget.onCloseRequested,
                  ),
              isDragged: () => cupertinoRoute.isDragged,
              contentBuilder: widget.contentBuilder,
            ),
          );
        },
      ),
      (AdaptiveModalPresentation.sheet, false) => Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: double.infinity,
          child: FractionallySizedBox(
            heightFactor: maxExtent,
            child: _buildSheet(null),
          ),
        ),
      ),
      (AdaptiveModalPresentation.sheet, true) => Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: double.infinity,
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if (notification.extent <= notification.minExtent) {
                widget.onCloseRequested();
              }
              return false;
            },
            child: DraggableScrollableSheet(
              controller: _sheetController,
              expand: false,
              initialChildSize: maxExtent,
              minChildSize: AdaptiveModalConstraints.minSheetExtent,
              maxChildSize: maxExtent,
              snap: true,
              builder: (_, controller) => _buildSheet(controller),
            ),
          ),
        ),
      ),
    };
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: ModalWindowControlMotion(
        notifier: _sheetController,
        child: surface,
      ),
    );
  }

  Widget _buildSheet(ScrollController? controller) => SizedBox(
    width: double.infinity,
    child: ClipRSuperellipse(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: _CupertinoSheetBackground(
        child: Column(
          children: [
            if (widget.showDragHandle) const _CupertinoDragHandle(),
            Expanded(child: widget.contentBuilder(controller)),
          ],
        ),
      ),
    ),
  );
}

class _CupertinoSheetBackground extends StatelessWidget {
  const _CupertinoSheetBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => CupertinoUserInterfaceLevel(
    data: CupertinoUserInterfaceLevelData.elevated,
    child: Stack(
      key: const ValueKey('adaptive-cupertino-sheet-surface'),
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -_sheetPopupSurfaceBottomOverflow,
          child: CupertinoPopupSurface(
            key: const ValueKey('adaptive-cupertino-sheet-background'),
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: _sheetPopupSurfaceBottomOverflow,
              ),
              child: child,
            ),
          ),
        ),
      ],
    ),
  );
}

class _CupertinoDialogScrollDismissRegion extends StatefulWidget {
  const _CupertinoDialogScrollDismissRegion({
    required this.showDragHandle,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.isDragged,
    required this.contentBuilder,
  });

  final bool showDragHandle;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final void Function({required double dismissThreshold}) onDragEnd;
  final bool Function() isDragged;
  final Widget Function(ScrollController? controller) contentBuilder;

  @override
  State<_CupertinoDialogScrollDismissRegion> createState() =>
      _CupertinoDialogScrollDismissRegionState();
}

class _CupertinoDialogScrollDismissRegionState
    extends State<_CupertinoDialogScrollDismissRegion> {
  late final _CupertinoDialogScrollController _scrollController =
      _CupertinoDialogScrollController(
        onDragStart: widget.onDragStart,
        onDragUpdate: widget.onDragUpdate,
        onDragEnd: _handleDragEnd,
        isDragged: widget.isDragged,
      );
  Timer? _pointerSignalSettleTimer;

  @override
  void dispose() {
    _pointerSignalSettleTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollInertiaCancelEvent) {
      _pointerSignalSettleTimer?.cancel();
      if (widget.isDragged()) _handleDragEnd();
      return;
    }
    if (event is! PointerScrollEvent || event.scrollDelta.dy >= 0) return;
    final atTop =
        !_scrollController.hasClients ||
        _scrollController.offset <=
            _scrollController.position.minScrollExtent + 0.5;
    if (!atTop && !widget.isDragged()) return;
    widget.onDragStart();
    widget.onDragUpdate(-event.scrollDelta.dy);
    event.respond(allowPlatformDefault: false);
    _pointerSignalSettleTimer?.cancel();
    _pointerSignalSettleTimer = Timer(
      const Duration(milliseconds: 120),
      _handleDragEnd,
    );
  }

  void _handleDragEnd() {
    if (!mounted) return;
    widget.onDragEnd(dismissThreshold: (context.size?.height ?? 0) * 0.5);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerSignal: _handlePointerSignal,
    child: CupertinoPopupSurface(
      key: const ValueKey('adaptive-cupertino-dialog-scroll-dismiss'),
      child: Stack(
        children: [
          widget.contentBuilder(_scrollController),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              supportedDevices: const {
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
                PointerDeviceKind.invertedStylus,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.unknown,
              },
              onVerticalDragStart: (_) => widget.onDragStart(),
              onVerticalDragUpdate: (details) =>
                  widget.onDragUpdate(details.primaryDelta ?? 0),
              onVerticalDragEnd: (_) => _handleDragEnd(),
              onVerticalDragCancel: _handleDragEnd,
              child: const SizedBox(height: kMinInteractiveDimensionCupertino),
            ),
          ),
          if (widget.showDragHandle)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: GestureDetector(
                  key: const ValueKey('adaptive-cupertino-dialog-drag-handle'),
                  behavior: HitTestBehavior.opaque,
                  supportedDevices: const {PointerDeviceKind.mouse},
                  onVerticalDragStart: (_) => widget.onDragStart(),
                  onVerticalDragUpdate: (details) =>
                      widget.onDragUpdate(details.primaryDelta ?? 0),
                  onVerticalDragEnd: (_) => _handleDragEnd(),
                  onVerticalDragCancel: _handleDragEnd,
                  child: const _CupertinoDragHandle(),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Matches the visual defaults used by Flutter's [CupertinoSheetRoute].
class _CupertinoDragHandle extends StatelessWidget {
  const _CupertinoDragHandle();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 24,
    child: Center(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: CupertinoColors.tertiaryLabel,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
        child: SizedBox(width: 36, height: 5),
      ),
    ),
  );
}

class _CupertinoDialogScrollController extends ScrollController {
  _CupertinoDialogScrollController({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.isDragged,
  });

  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;
  final bool Function() isDragged;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) => _CupertinoDialogScrollPosition(
    physics: physics.applyTo(const AlwaysScrollableScrollPhysics()),
    context: context,
    oldPosition: oldPosition,
    onDragStart: onDragStart,
    onDragUpdate: onDragUpdate,
    onDragEnd: onDragEnd,
    isDragged: isDragged,
  );
}

class _CupertinoDialogScrollPosition extends ScrollPositionWithSingleContext {
  _CupertinoDialogScrollPosition({
    required super.physics,
    required super.context,
    super.oldPosition,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.isDragged,
  });

  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;
  final bool Function() isDragged;
  PointerDeviceKind? _dragKind;

  bool get _contentShouldScroll => pixels > minScrollExtent + 0.5;

  bool get _bodyCanDismiss => _dragKind != PointerDeviceKind.mouse;

  @override
  void applyUserOffset(double delta) {
    if (_bodyCanDismiss &&
        !_contentShouldScroll &&
        (delta > 0 || isDragged())) {
      onDragStart();
      onDragUpdate(delta);
      return;
    }
    super.applyUserOffset(delta);
  }

  @override
  void goBallistic(double velocity) {
    if (isDragged()) {
      onDragEnd();
      super.goBallistic(0);
      return;
    }
    super.goBallistic(velocity);
  }

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    _dragKind = details.kind;
    return super.drag(details, dragCancelCallback);
  }
}

/// Cupertino implementation of adaptive modal content.
class CupertinoAdaptiveModal extends StatelessWidget {
  const CupertinoAdaptiveModal({
    super.key,
    required this.title,
    required this.leadingAction,
    required this.actions,
    required this.pinnedBody,
    required this.body,
    required this.bottomActions,
    required this.automaticallyImplyCloseButton,
    required this.onCloseRequested,
    required this.constraints,
    required this.presentation,
    required this.scrollController,
  });

  final Widget? title;
  final Widget? leadingAction;
  final List<Widget> actions;
  final Widget? pinnedBody;
  final Widget body;
  final List<Widget> bottomActions;
  final bool automaticallyImplyCloseButton;
  final VoidCallback onCloseRequested;
  final BoxConstraints? constraints;
  final AdaptiveModalPresentation presentation;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final modalBackgroundColor = CupertinoDynamicColor.resolve(
      CupertinoColors.systemBackground,
      context,
    );
    final impliedClose = automaticallyImplyCloseButton
        ? Semantics(
            label: MaterialLocalizations.of(context).closeButtonLabel,
            button: true,
            child: CupertinoButton(
              key: const ValueKey('adaptive-modal-implied-close'),
              sizeStyle: CupertinoButtonSize.small,
              padding: EdgeInsets.zero,
              onPressed: onCloseRequested,
              child: const Icon(CupertinoIcons.xmark),
            ),
          )
        : null;
    final header = ModalWindowControlAppBarRegion(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: AdaptiveAppBar.apple(
          key: const ValueKey('adaptive-modal-app-bar'),
          leading: leadingAction,
          automaticallyImplyLeading: false,
          title: title == null
              ? const SizedBox.shrink()
              : KeyedSubtree(
                  key: const ValueKey('adaptive-modal-title'),
                  child: title!,
                ),
          actions: [?impliedClose],
          automaticBackgroundVisibility: false,
        ),
      ),
    );
    final footer = actions.isEmpty
        ? null
        : _CupertinoModalActionArea(actions: actions);

    const appBarHeight = kMinInteractiveDimensionCupertino;
    final paddedPinnedBody = pinnedBody == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: appBarHeight),
            child: pinnedBody,
          );
    final paddedBody = pinnedBody == null
        ? Padding(
            padding: const EdgeInsets.only(top: appBarHeight),
            child: body,
          )
        : body;
    final content = CupertinoTheme(
      data: theme,
      child: DefaultTextStyle(
        style: theme.textTheme.textStyle,
        child: CupertinoPageScaffoldBackgroundColor(
          color: modalBackgroundColor,
          child: ScrollNotificationObserver(
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                AdaptiveModalLayout(
                  pinnedBody: paddedPinnedBody,
                  body: paddedBody,
                  bottomActions: bottomActions,
                  scrollController: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  presentation: presentation,
                  constraints: constraints,
                  defaultMaxHeight:
                      presentation == AdaptiveModalPresentation.sheet
                      ? MediaQuery.sizeOf(context).height * _sheetHeightFactor
                      : null,
                  footer: footer,
                ),
                Positioned(top: 0, left: 0, right: 0, child: header),
              ],
            ),
          ),
        ),
      ),
    );
    return switch (ModalRoute.of(context)) {
      final CupertinoPageRoute<dynamic> route => ClipRect(
        key: const ValueKey('adaptive-cupertino-modal-route-clip'),
        clipper: _CupertinoCoveredRouteClipper(
          animation: route.secondaryAnimation ?? kAlwaysDismissedAnimation,
          useLinearTransition: () => route.popGestureInProgress,
          textDirection: Directionality.of(context),
        ),
        child: content,
      ),
      _ => content,
    };
  }
}

class _CupertinoCoveredRouteClipper extends CustomClipper<Rect> {
  _CupertinoCoveredRouteClipper({
    required this.animation,
    required this.useLinearTransition,
    required this.textDirection,
  }) : super(reclip: animation);

  final Animation<double> animation;
  final bool Function() useLinearTransition;
  final TextDirection textDirection;

  @override
  Rect getClip(Size size) {
    final value = animation.value;
    final linearTransition = useLinearTransition();
    final primaryCurveValue = switch ((linearTransition, animation.status)) {
      (true, _) => value,
      (false, AnimationStatus.reverse) =>
        Curves.fastEaseInToSlowEaseOut.flipped.transform(value),
      _ => Curves.fastEaseInToSlowEaseOut.transform(value),
    };
    final secondaryCurveValue = switch ((linearTransition, animation.status)) {
      (true, _) => value,
      (false, AnimationStatus.reverse) => Curves.easeInToLinear.transform(
        value,
      ),
      _ => Curves.linearToEaseOut.transform(value),
    };
    final visibleFraction = (1 - primaryCurveValue + secondaryCurveValue / 3)
        .clamp(0.0, 1.0);
    final visibleWidth = size.width * visibleFraction;
    return switch (textDirection) {
      TextDirection.ltr => Rect.fromLTWH(0, 0, visibleWidth, size.height),
      TextDirection.rtl => Rect.fromLTWH(
        size.width - visibleWidth,
        0,
        visibleWidth,
        size.height,
      ),
    };
  }

  @override
  bool shouldReclip(_CupertinoCoveredRouteClipper oldClipper) =>
      animation != oldClipper.animation ||
      textDirection != oldClipper.textDirection;
}

class _CupertinoModalActionArea extends StatelessWidget {
  const _CupertinoModalActionArea({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final dividerColor = CupertinoDynamicColor.resolve(
      CupertinoColors.separator,
      context,
    );
    return DecoratedBox(
      key: const ValueKey('adaptive-modal-actions'),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: dividerColor, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, action) in actions.indexed) ...[
            if (index > 0)
              SizedBox(height: 0.5, child: ColoredBox(color: dividerColor)),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 50),
              child: action,
            ),
          ],
        ],
      ),
    );
  }
}
