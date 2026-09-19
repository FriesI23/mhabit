import 'dart:async';

import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../breakpoints/breakpoints.dart';
import '../breakpoints/window_size_class.dart';
import '../cupertino/cupertino_adaptive_modal.dart';
import '../material/material_adaptive_modal.dart';
import 'adaptive_back_button.dart';
import 'adaptive_modal_content.dart';
import 'adaptive_modal_layout.dart';

export 'adaptive_modal_layout.dart'
    show AdaptiveModalConstraints, AdaptiveModalPresentation;

/// Shows content as a platform-styled sheet on compact windows and a dialog
/// when both window axes reach the medium size class.
///
/// Automatic presentation is resolved from the current window size while the
/// route remains active. Resizing changes the platform surface without
/// replacing the route or its content subtree. A [presentationOverride] keeps
/// both the presentation and Flutter route type fixed for tests and developer
/// tools.
///
/// A [styleOverride] forces the route and content renderer to a specific style.
/// It is intended as a migration escape hatch and for tests; regular callers
/// should inherit the style from [AdaptiveStyleScope].
///
/// A null [barrierDismissible] makes dialog presentations dismissible, matching
/// Flutter's regular dialog behavior. A fixed Cupertino sheet uses Flutter's
/// non-dismissible [CupertinoSheetRoute] barrier; an automatically responsive
/// route retains its configured barrier while resizing between presentations.
/// [enableDrag] controls gesture dismissal independently. A null
/// [showDragHandle] uses the adaptive default: shown for Material and hidden
/// for Apple. An explicit value overrides that default.
Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  AdaptiveStyle? styleOverride,
  AdaptiveModalPresentation? presentationOverride,
  bool useRootNavigator = true,
  bool? barrierDismissible,
  bool enableDrag = true,
  bool? showDragHandle,
  RouteSettings? routeSettings,
}) {
  final style = styleOverride ?? AdaptiveStyle.of(context);
  final effectiveShowDragHandle =
      showDragHandle ?? style == AdaptiveStyle.material;
  final breakpoints =
      BreakpointsScope.maybeOf(context)?.breakpoints ??
      switch (style) {
        AdaptiveStyle.apple => const AppleBreakpoints(),
        AdaptiveStyle.material => const MaterialBreakpoints(),
      };
  if (presentationOverride == null) {
    final effectiveBarrierDismissible = barrierDismissible ?? true;
    final barrierLabel = MaterialLocalizations.of(
      context,
    ).modalBarrierDismissLabel;
    return switch (style) {
      AdaptiveStyle.apple => showCupertinoAdaptiveModalRoute<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        routeSettings: routeSettings,
        barrierLabel: barrierLabel,
        builder: (_) => _ResponsiveAdaptiveModalRoute(
          style: AdaptiveStyle.apple,
          breakpoints: breakpoints,
          builder: builder,
          enableDrag: enableDrag,
          showDragHandle: effectiveShowDragHandle,
          barrierDismissible: effectiveBarrierDismissible,
          barrierLabel: barrierLabel,
        ),
      ),
      AdaptiveStyle.material => showMaterialAdaptiveModalRoute<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        barrierLabel: barrierLabel,
        routeSettings: routeSettings,
        presentationResolver: (context) =>
            _resolvePresentation(breakpoints, MediaQuery.sizeOf(context)),
        builder: (_) => _ResponsiveAdaptiveModalRoute(
          style: AdaptiveStyle.material,
          breakpoints: breakpoints,
          builder: builder,
          enableDrag: enableDrag,
          showDragHandle: effectiveShowDragHandle,
          barrierDismissible: effectiveBarrierDismissible,
          barrierLabel: barrierLabel,
        ),
      ),
    };
  }
  final presentation = presentationOverride;
  final barrierLabel = MaterialLocalizations.of(
    context,
  ).modalBarrierDismissLabel;

  Widget buildRouteContent({ScrollController? scrollController}) =>
      AdaptiveStyleScope(
        override: style,
        child: _AdaptiveModalRouteScope(
          presentation: presentation,
          scrollController: scrollController,
          child: Builder(builder: builder),
        ),
      );

  return switch ((style, presentation)) {
    (AdaptiveStyle.material, AdaptiveModalPresentation.dialog) =>
      showMaterialAdaptiveDialogRoute<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        barrierDismissible: barrierDismissible ?? true,
        routeSettings: routeSettings,
        builder: (_) => buildRouteContent(),
      ),
    (AdaptiveStyle.apple, AdaptiveModalPresentation.dialog) =>
      showCupertinoAdaptiveDialogRoute<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        routeSettings: routeSettings,
        barrierLabel: barrierLabel,
        builder: (_) => _ResponsiveAdaptiveModalRoute(
          style: AdaptiveStyle.apple,
          breakpoints: breakpoints,
          presentationOverride: AdaptiveModalPresentation.dialog,
          builder: builder,
          enableDrag: enableDrag,
          showDragHandle: effectiveShowDragHandle,
          barrierDismissible: barrierDismissible ?? true,
          barrierLabel: barrierLabel,
        ),
      ),
    (AdaptiveStyle.material, AdaptiveModalPresentation.sheet) =>
      showMaterialAdaptiveSheetRoute<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        barrierDismissible: barrierDismissible ?? true,
        enableDrag: enableDrag,
        showDragHandle: effectiveShowDragHandle,
        routeSettings: routeSettings,
        builder: (controller) =>
            buildRouteContent(scrollController: controller),
      ),
    (AdaptiveStyle.apple, AdaptiveModalPresentation.sheet) =>
      showCupertinoAdaptiveSheetRoute<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        enableDrag: enableDrag,
        showDragHandle: effectiveShowDragHandle,
        routeSettings: routeSettings,
        builder: (controller) =>
            buildRouteContent(scrollController: controller),
      ),
  };
}

AdaptiveModalPresentation _resolvePresentation(
  Breakpoints breakpoints,
  Size windowSize,
) => switch (WindowSize.fromBreakpoints(breakpoints, windowSize).contains(
  const WindowSize(
    width: WindowSizeClass.medium,
    height: WindowSizeClass.medium,
  ),
)) {
  true => AdaptiveModalPresentation.dialog,
  false => AdaptiveModalPresentation.sheet,
};

/// Creates a platform-styled page route for navigation within an
/// [AdaptiveModalNavigator].
Route<T> adaptiveModalPageRoute<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  RouteSettings? settings,
}) => switch (AdaptiveStyle.of(context)) {
  AdaptiveStyle.material => MaterialPageRoute<T>(
    settings: settings,
    builder: builder,
  ),
  AdaptiveStyle.apple => CupertinoAdaptiveModalPageRoute<T>(
    settings: settings,
    builder: builder,
  ),
};

class _ResponsiveAdaptiveModalRoute extends StatefulWidget {
  const _ResponsiveAdaptiveModalRoute({
    required this.style,
    required this.breakpoints,
    this.presentationOverride,
    required this.builder,
    required this.enableDrag,
    required this.showDragHandle,
    required this.barrierDismissible,
    required this.barrierLabel,
  });

  final AdaptiveStyle style;
  final Breakpoints breakpoints;
  final AdaptiveModalPresentation? presentationOverride;
  final WidgetBuilder builder;
  final bool enableDrag;
  final bool showDragHandle;
  final bool barrierDismissible;
  final String barrierLabel;

  @override
  State<_ResponsiveAdaptiveModalRoute> createState() =>
      _ResponsiveAdaptiveModalRouteState();
}

class _ResponsiveAdaptiveModalRouteState
    extends State<_ResponsiveAdaptiveModalRoute> {
  final GlobalKey _contentKey = GlobalKey();
  late final _closeController = _AdaptiveModalCloseController(
    routeClose: _closeRoute,
  );
  late final Widget _content = KeyedSubtree(
    key: _contentKey,
    child: Builder(builder: widget.builder),
  );

  Future<void> _closeRoute() async {
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final presentation =
        widget.presentationOverride ??
        _resolvePresentation(widget.breakpoints, MediaQuery.sizeOf(context));

    Widget buildContent(ScrollController? controller) => AdaptiveStyleScope(
      override: widget.style,
      child: _AdaptiveModalRouteScope(
        presentation: presentation,
        scrollController: controller,
        closeController: _closeController,
        child: _content,
      ),
    );

    final surface = switch (widget.style) {
      AdaptiveStyle.material => MaterialAdaptiveModalRouteSurface(
        presentation: presentation,
        enableDrag: widget.enableDrag,
        showDragHandle: widget.showDragHandle,
        onCloseRequested: _closeController.requestClose,
        contentBuilder: buildContent,
      ),
      AdaptiveStyle.apple => CupertinoAdaptiveModalRouteSurface(
        presentation: presentation,
        enableDrag: widget.enableDrag,
        showDragHandle: widget.showDragHandle,
        onCloseRequested: _closeController.requestClose,
        contentBuilder: buildContent,
      ),
    };
    return Stack(
      fit: StackFit.expand,
      children: [
        ModalBarrier(
          color: Colors.transparent,
          dismissible: widget.barrierDismissible,
          semanticsLabel: widget.barrierLabel,
          onDismiss: widget.barrierDismissible
              ? _closeController.requestClose
              : null,
        ),
        surface,
      ],
    );
  }
}

/// Dialog sizing within the available window and shared modal bounds.
///
/// Sheets retain their platform route's sizing policy. Dialogs fit their
/// content size within the configured bounds on both axes.
sealed class AdaptiveModalSize {
  const AdaptiveModalSize._();

  /// A preferred fixed size, reduced when the available space is smaller.
  const factory AdaptiveModalSize.fixed({double width, double height}) =
      AdaptiveModalFixedSize;

  /// Content-driven size with a default fixed width of 560 and height 0–560.
  /// Each bound can be overridden independently. Tight bounds fix an axis;
  /// loose bounds fit content. Loose width requires intrinsic body layout.
  const factory AdaptiveModalSize.constrained({
    double minWidth,
    double maxWidth,
    double minHeight,
    double maxHeight,
  }) = AdaptiveModalConstrainedSize;

  /// Requested bounds before adapting to the available window space.
  BoxConstraints get constraints;
}

final class AdaptiveModalFixedSize extends AdaptiveModalSize {
  const AdaptiveModalFixedSize({this.width = 560, this.height = 560})
    : assert(width > 0 && width < double.infinity),
      assert(height > 0 && height < double.infinity),
      super._();

  final double width;
  final double height;

  @override
  BoxConstraints get constraints =>
      BoxConstraints.tightFor(width: width, height: height);
}

final class AdaptiveModalConstrainedSize extends AdaptiveModalSize {
  const AdaptiveModalConstrainedSize({
    this.minWidth = 560,
    this.maxWidth = 560,
    this.minHeight = 0,
    this.maxHeight = 560,
  }) : assert(minWidth >= 0 && minWidth < double.infinity),
       assert(minHeight >= 0 && minHeight < double.infinity),
       assert(maxWidth >= minWidth),
       assert(maxHeight >= minHeight),
       super._();

  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;

  @override
  BoxConstraints get constraints => BoxConstraints(
    minWidth: minWidth,
    maxWidth: maxWidth,
    minHeight: minHeight,
    maxHeight: maxHeight,
  );
}

/// Hosts a stable navigation stack inside an adaptive modal route.
///
/// The [builder] receives a context below the nested [Navigator], so ordinary
/// `Navigator.of(context)` calls target this modal-local stack. Popping its
/// initial page through system back closes the surrounding modal. Use [pop]
/// when an explicit action must close the whole modal or return a typed result.
///
/// A nested Navigator's overlay must have a finite viewport. Sheet
/// presentations fill their surface. Dialogs default to a fixed 560 by 560 size
/// within the shared modal bounds. Use [AdaptiveModalSize.constrained] to follow
/// the current AdaptiveModal content height within explicit bounds. Loose width
/// bounds follow its intrinsic body width as well.
class AdaptiveModalNavigator<T> extends StatefulWidget {
  const AdaptiveModalNavigator({
    super.key,
    required this.builder,
    this.size = const AdaptiveModalSize.fixed(),
    this.routeSettings,
  });

  final WidgetBuilder builder;

  /// Dialog sizing policy. Non-AdaptiveModal pages use the maximum size.
  /// Sheet sizing continues to belong to the platform route.
  final AdaptiveModalSize size;
  final RouteSettings? routeSettings;

  /// Closes the surrounding modal rather than the nearest nested page.
  static void pop<R extends Object?>(BuildContext context, [R? result]) {
    final scope = context
        .getInheritedWidgetOfExactType<_InheritedAdaptiveModalNavigator>();
    assert(scope != null, 'No AdaptiveModalNavigator found in context.');
    scope?.closeModal(result);
  }

  @override
  State<AdaptiveModalNavigator<T>> createState() =>
      _AdaptiveModalNavigatorState<T>();
}

class _AdaptiveModalNavigatorState<T> extends State<AdaptiveModalNavigator<T>> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final _sizeObserver = _ModalSizeObserver(_updateSize);
  final _sizeRevision = ValueNotifier<int>(0);
  Size? _contentSize;
  BoxConstraints? _dialogBounds;

  void _updateSize(Size? size) {
    if (!mounted || _contentSize == size) return;
    final previous = _contentSize;
    _contentSize = size;
    final bounds = _dialogBounds;
    // Only notify the outer size layer when the effective viewport changes.
    // Keep measurements while fixed or in a sheet for subsequent resizes.
    if (bounds == null ||
        bounds.constrain(previous ?? bounds.biggest) ==
            bounds.constrain(size ?? bounds.biggest)) {
      return;
    }
    _sizeRevision.value++;
  }

  @override
  void dispose() {
    _sizeRevision.dispose();
    super.dispose();
  }

  void _closeModal(Object? result) =>
      Navigator.of(context).pop<T>(result as T?);

  @override
  Widget build(BuildContext context) {
    final presentation =
        _InheritedAdaptiveModalRoute.maybeOf(context)?.presentation ??
        AdaptiveModalPresentation.dialog;
    final windowSize = MediaQuery.sizeOf(context);
    final navigator = _InheritedAdaptiveModalNavigator(
      closeModal: _closeModal,
      onContentSizeChanged: _sizeObserver.recordSize,
      size: widget.size,
      child: NavigatorPopHandler<Object?>(
        onPopWithResult: (result) =>
            _navigatorKey.currentState?.maybePop<Object?>(result),
        child: Navigator(
          key: _navigatorKey,
          observers: [_sizeObserver],
          onGenerateInitialRoutes: (_, _) => [
            adaptiveModalPageRoute<T>(
              context: context,
              settings: widget.routeSettings,
              builder: (pageContext) => PopScope<T>(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (!didPop) Navigator.of(context).pop<T>(result);
                },
                child: widget.builder(pageContext),
              ),
            ),
          ],
        ),
      ),
    );
    final requested = widget.size.constraints;
    assert(requested.debugAssertIsValid());
    final bounds = requested.enforce(
      BoxConstraints(
        maxWidth: windowSize.width * 0.9,
        maxHeight: AdaptiveModalConstraints.maximumHeightOf(context),
      ),
    );
    _dialogBounds = presentation == AdaptiveModalPresentation.dialog
        ? bounds
        : null;
    return AnimatedSize(
      duration: presentation == AdaptiveModalPresentation.dialog
          ? const Duration(milliseconds: 200)
          : Duration.zero,
      curve: Curves.easeOutCubic,
      child: ListenableBuilder(
        listenable: _sizeRevision,
        child: navigator,
        builder: (context, child) => SizedBox.fromSize(
          size: presentation == AdaptiveModalPresentation.sheet
              ? Size.infinite
              : bounds.constrain(_contentSize ?? bounds.biggest),
          child: child,
        ),
      ),
    );
  }
}

class _ModalSizeObserver extends NavigatorObserver {
  _ModalSizeObserver(this.onSize);

  final ValueChanged<Size?> onSize;
  final _sizes = <Route<dynamic>, Size>{};
  Route<dynamic>? _current;
  bool _scheduled = false;

  void recordSize(ModalRoute<dynamic>? route, Size size) {
    if (route == null ||
        !route.isActive ||
        !size.isFinite ||
        _sizes[route] == size) {
      return;
    }
    _sizes[route] = size;
    if (route == _current) _schedule();
  }

  void _schedule() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.ensureVisualUpdate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      onSize(_sizes[_current]);
    });
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    _current = topRoute;
    _schedule();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sizes.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sizes.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _sizes.remove(oldRoute);
  }
}

/// A modal confirmation command. The caller owns validation and dismissal.
///
/// Material renders [label] as text; Apple uses a checkmark with [label] as its
/// accessible name and tooltip. A null callback disables the command.
@immutable
class AdaptiveModalConfirmAction {
  const AdaptiveModalConfirmAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;
}

/// Platform-adaptive modal content with fixed semantic regions.
///
/// This is the content counterpart to [showAdaptiveSheet], similar to how an
/// [AlertDialog] supplies dialog regions while the show helper owns its route.
/// Callers own the business meaning and callbacks of every action supplied
/// here.
abstract class AdaptiveModal extends StatelessWidget {
  const factory AdaptiveModal({
    Key? key,
    Widget? title,
    Widget? leadingAction,
    List<Widget> appBarActions,
    AdaptiveModalConfirmAction? confirmAction,
    List<Widget> actions,
    Widget? pinnedBody,
    List<Widget> bottomActions,
    bool automaticallyImplyLeading,
    bool automaticallyImplyCloseButton,
    FutureOr<void> Function()? onCloseRequested,
    AdaptiveModalSize? size,
    required Widget body,
  }) = _AdaptiveBoxModal;

  /// Uses one bounded sliver viewport with the route's scroll ownership.
  const factory AdaptiveModal.slivers({
    Key? key,
    Widget? title,
    Widget? leadingAction,
    List<Widget> appBarActions,
    AdaptiveModalConfirmAction? confirmAction,
    List<Widget> actions,
    Widget? pinnedBody,
    List<Widget> bottomActions,
    bool automaticallyImplyLeading,
    bool automaticallyImplyCloseButton,
    FutureOr<void> Function()? onCloseRequested,
    AdaptiveModalSize? size,
    required List<Widget> slivers,
  }) = _AdaptiveSliverModal;

  /// A content-sized box modal without a toolbar or reserved toolbar space.
  const factory AdaptiveModal.simple({
    Key? key,
    required Widget body,
    AdaptiveModalSize? size,
    List<Widget> actions,
    List<Widget> bottomActions,
    FutureOr<void> Function()? onCloseRequested,
  }) = _AdaptiveSimpleModal;

  const AdaptiveModal._({
    super.key,
    this.title,
    this.leadingAction,
    this.appBarActions = const [],
    this.confirmAction,
    this.actions = const [],
    this.pinnedBody,
    this.bottomActions = const [],
    this.automaticallyImplyLeading = false,
    this.automaticallyImplyCloseButton = true,
    this.onCloseRequested,
    this.size,
    this.showAppBar = true,
  });

  final bool showAppBar;
  final Widget? title;
  final Widget? leadingAction;
  final List<Widget> appBarActions;
  final AdaptiveModalConfirmAction? confirmAction;
  final List<Widget> actions;
  final Widget? pinnedBody;
  final List<Widget> bottomActions;
  final bool automaticallyImplyLeading;
  final bool automaticallyImplyCloseButton;
  final FutureOr<void> Function()? onCloseRequested;
  final AdaptiveModalSize? size;
}

class _AdaptiveBoxModal extends AdaptiveModal {
  const _AdaptiveBoxModal({
    super.key,
    super.title,
    super.leadingAction,
    super.appBarActions,
    super.confirmAction,
    super.actions,
    super.pinnedBody,
    super.bottomActions,
    super.automaticallyImplyLeading,
    super.automaticallyImplyCloseButton,
    super.onCloseRequested,
    super.size,
    super.showAppBar,
    required this.body,
  }) : super._();

  final Widget body;

  @override
  Widget build(BuildContext context) => _AdaptiveModal(
    showAppBar: showAppBar,
    title: title,
    leadingAction: leadingAction,
    appBarActions: appBarActions,
    confirmAction: confirmAction,
    actions: actions,
    pinnedBody: pinnedBody,
    bottomActions: bottomActions,
    automaticallyImplyLeading: automaticallyImplyLeading,
    automaticallyImplyCloseButton: automaticallyImplyCloseButton,
    onCloseRequested: onCloseRequested,
    size: size,
    content: AdaptiveModalBoxContent(body: body),
  );
}

class _AdaptiveSimpleModal extends _AdaptiveBoxModal {
  const _AdaptiveSimpleModal({
    super.key,
    required super.body,
    super.size = const AdaptiveModalSize.constrained(),
    super.actions,
    super.bottomActions,
    super.onCloseRequested,
  }) : super(showAppBar: false, automaticallyImplyCloseButton: false);
}

class _AdaptiveSliverModal extends AdaptiveModal {
  const _AdaptiveSliverModal({
    super.key,
    super.title,
    super.leadingAction,
    super.appBarActions,
    super.confirmAction,
    super.actions,
    super.pinnedBody,
    super.bottomActions,
    super.automaticallyImplyLeading,
    super.automaticallyImplyCloseButton,
    super.onCloseRequested,
    super.size,
    required this.slivers,
  }) : super._();

  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) => _AdaptiveModal(
    showAppBar: showAppBar,
    title: title,
    leadingAction: leadingAction,
    appBarActions: appBarActions,
    confirmAction: confirmAction,
    actions: actions,
    pinnedBody: pinnedBody,
    bottomActions: bottomActions,
    automaticallyImplyLeading: automaticallyImplyLeading,
    automaticallyImplyCloseButton: automaticallyImplyCloseButton,
    onCloseRequested: onCloseRequested,
    size: size,
    content: AdaptiveModalSliverContent(slivers: slivers),
  );
}

/// Owns route integration shared by the independent content widgets.
class _AdaptiveModal extends StatefulWidget {
  const _AdaptiveModal({
    required this.showAppBar,
    required this.title,
    required this.leadingAction,
    required this.appBarActions,
    required this.confirmAction,
    required this.actions,
    required this.pinnedBody,
    required this.bottomActions,
    required this.automaticallyImplyLeading,
    required this.automaticallyImplyCloseButton,
    required this.onCloseRequested,
    required this.size,
    required this.content,
  });

  final bool showAppBar;
  final Widget? title;
  final Widget? leadingAction;
  final List<Widget> appBarActions;
  final AdaptiveModalConfirmAction? confirmAction;
  final List<Widget> actions;
  final Widget? pinnedBody;
  final List<Widget> bottomActions;
  final bool automaticallyImplyLeading;
  final bool automaticallyImplyCloseButton;
  final FutureOr<void> Function()? onCloseRequested;
  final AdaptiveModalSize? size;
  final Widget content;

  @override
  State<_AdaptiveModal> createState() => _AdaptiveModalState();
}

class _AdaptiveModalState extends State<_AdaptiveModal> {
  late final ScrollController _fallbackScrollController = ScrollController();
  _AdaptiveModalCloseController? _closeController;
  ModalRoute<dynamic>? _pageRoute;
  ModalRoute<dynamic>? _hostRoute;
  Animation<double>? _pageAnimation;
  Animation<double>? _secondaryPageAnimation;
  bool _hasRouteScrollOwnership = false;
  ScrollController? _inheritedScrollController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pageRoute = ModalRoute.of(context);
    final pageAnimation = pageRoute?.animation;
    final secondaryPageAnimation = pageRoute?.secondaryAnimation;
    _pageRoute = pageRoute;
    if (pageAnimation != _pageAnimation ||
        secondaryPageAnimation != _secondaryPageAnimation) {
      _pageAnimation?.removeStatusListener(_handlePageAnimationStatus);
      _secondaryPageAnimation?.removeStatusListener(_handlePageAnimationStatus);
      _pageAnimation = pageAnimation;
      _secondaryPageAnimation = secondaryPageAnimation;
      _pageAnimation?.addStatusListener(_handlePageAnimationStatus);
      _secondaryPageAnimation?.addStatusListener(_handlePageAnimationStatus);
    }
    final routeScope = _InheritedAdaptiveModalRoute.maybeOf(context);
    _hostRoute = routeScope?.hostRoute;
    _inheritedScrollController = routeScope?.scrollController;
    _hasRouteScrollOwnership = _ownsRouteScrollController(_hostRoute);
    final closeController = routeScope?.closeController;
    if (closeController != _closeController) {
      _closeController?.unregister(this);
      _closeController = closeController;
    }
    _syncCloseRegistration();
  }

  void _syncCloseRegistration() {
    if (_ownsRouteScrollController(_hostRoute)) {
      _closeController?.register(this, _requestClose);
    } else {
      _closeController?.unregister(this);
    }
  }

  @override
  void dispose() {
    _pageAnimation?.removeStatusListener(_handlePageAnimationStatus);
    _secondaryPageAnimation?.removeStatusListener(_handlePageAnimationStatus);
    _closeController?.unregister(this);
    _fallbackScrollController.dispose();
    super.dispose();
  }

  void _handlePageAnimationStatus(AnimationStatus status) {
    if (!mounted) return;
    final ownsController = _ownsRouteScrollController(_hostRoute);
    if (ownsController == _hasRouteScrollOwnership) return;
    _hasRouteScrollOwnership = ownsController;
    _syncCloseRegistration();
    if (_inheritedScrollController != null) setState(() {});
  }

  bool _ownsRouteScrollController(ModalRoute<dynamic>? hostRoute) {
    final pageRoute = _pageRoute;
    if (pageRoute == null || identical(pageRoute, hostRoute)) return true;
    return pageRoute.isCurrent &&
        _pageAnimation?.status == AnimationStatus.completed &&
        _secondaryPageAnimation?.status == AnimationStatus.dismissed;
  }

  Future<void> _requestClose() async {
    final callback = widget.onCloseRequested;
    if (callback != null) {
      await callback();
      return;
    }
    final modalNavigator = context
        .getInheritedWidgetOfExactType<_InheritedAdaptiveModalNavigator>();
    if (modalNavigator != null) {
      modalNavigator.closeModal(null);
      return;
    }
    final controller = _closeController;
    if (controller != null) {
      await controller.routeClose();
      return;
    }
    await Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final routeScope = _InheritedAdaptiveModalRoute.maybeOf(context);
    final presentation =
        routeScope?.presentation ?? AdaptiveModalPresentation.dialog;
    final inheritedScrollController = routeScope?.scrollController;
    final ownsRouteScrollController = _ownsRouteScrollController(
      routeScope?.hostRoute,
    );
    // A Navigator transition keeps both pages mounted. Only its current page
    // may attach to the sheet's draggable controller after both sides of the
    // page transition have settled. Both transitioning pages keep independent
    // controllers so an outgoing Scrollbar never shares a ScrollPosition with
    // the revealed page.
    final scrollController =
        inheritedScrollController != null && ownsRouteScrollController
        ? inheritedScrollController
        : _fallbackScrollController;
    final leadingAction =
        widget.leadingAction ??
        (widget.automaticallyImplyLeading &&
                !identical(_pageRoute, routeScope?.hostRoute) &&
                (_pageRoute?.canPop ?? false)
            ? const AdaptiveBackButton()
            : null);

    final modalNavigator = context
        .dependOnInheritedWidgetOfExactType<_InheritedAdaptiveModalNavigator>();
    final size =
        widget.size ?? modalNavigator?.size ?? const AdaptiveModalSize.fixed();
    final ValueChanged<Size>? onContentSizeChanged =
        presentation == AdaptiveModalPresentation.dialog &&
            modalNavigator != null
        ? (size) => modalNavigator.onContentSizeChanged(_pageRoute, size)
        : null;

    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => MaterialAdaptiveModal(
        showAppBar: widget.showAppBar,
        title: widget.title,
        leadingAction: leadingAction,
        appBarActions: widget.appBarActions,
        confirmAction: widget.confirmAction,
        actions: widget.actions,
        pinnedBody: widget.pinnedBody,
        content: widget.content,
        bottomActions: widget.bottomActions,
        automaticallyImplyCloseButton: widget.automaticallyImplyCloseButton,
        onCloseRequested: _requestClose,
        size: size,
        presentation: presentation,
        scrollController: scrollController,
        onContentSizeChanged: onContentSizeChanged,
      ),
      AdaptiveStyle.apple => CupertinoAdaptiveModal(
        showAppBar: widget.showAppBar,
        title: widget.title,
        leadingAction: leadingAction,
        appBarActions: widget.appBarActions,
        confirmAction: widget.confirmAction,
        actions: widget.actions,
        pinnedBody: widget.pinnedBody,
        content: widget.content,
        bottomActions: widget.bottomActions,
        automaticallyImplyCloseButton: widget.automaticallyImplyCloseButton,
        onCloseRequested: _requestClose,
        size: size,
        presentation: presentation,
        scrollController: scrollController,
        onContentSizeChanged: onContentSizeChanged,
      ),
    };
  }
}

class _AdaptiveModalRouteScope extends StatelessWidget {
  const _AdaptiveModalRouteScope({
    required this.presentation,
    this.scrollController,
    this.closeController,
    required this.child,
  });

  final AdaptiveModalPresentation presentation;
  final ScrollController? scrollController;
  final _AdaptiveModalCloseController? closeController;
  final Widget child;

  @override
  Widget build(BuildContext context) => _InheritedAdaptiveModalRoute(
    presentation: presentation,
    scrollController: scrollController,
    closeController: closeController,
    hostRoute: ModalRoute.of(context),
    child: child,
  );
}

class _InheritedAdaptiveModalNavigator extends InheritedWidget {
  const _InheritedAdaptiveModalNavigator({
    required this.closeModal,
    required this.onContentSizeChanged,
    required this.size,
    required super.child,
  });

  final AdaptiveModalSize size;
  final ValueChanged<Object?> closeModal;
  final void Function(ModalRoute<dynamic>? route, Size size)
  onContentSizeChanged;

  @override
  bool updateShouldNotify(_InheritedAdaptiveModalNavigator oldWidget) =>
      size != oldWidget.size;
}

class _InheritedAdaptiveModalRoute extends InheritedWidget {
  const _InheritedAdaptiveModalRoute({
    required this.presentation,
    this.scrollController,
    this.closeController,
    required this.hostRoute,
    required super.child,
  });

  final AdaptiveModalPresentation presentation;
  final ScrollController? scrollController;
  final _AdaptiveModalCloseController? closeController;
  final ModalRoute<dynamic>? hostRoute;

  static _InheritedAdaptiveModalRoute? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_InheritedAdaptiveModalRoute>();

  @override
  bool updateShouldNotify(_InheritedAdaptiveModalRoute oldWidget) =>
      presentation != oldWidget.presentation ||
      scrollController != oldWidget.scrollController ||
      closeController != oldWidget.closeController ||
      hostRoute != oldWidget.hostRoute;
}

class _AdaptiveModalCloseController {
  _AdaptiveModalCloseController({required this.routeClose});

  final Future<void> Function() routeClose;
  Object? _owner;
  Future<void> Function()? _closeHandler;

  void register(Object owner, Future<void> Function() closeHandler) {
    _owner = owner;
    _closeHandler = closeHandler;
  }

  void unregister(Object owner) {
    if (!identical(_owner, owner)) return;
    _owner = null;
    _closeHandler = null;
  }

  Future<void> requestClose() => (_closeHandler ?? routeClose)();
}
