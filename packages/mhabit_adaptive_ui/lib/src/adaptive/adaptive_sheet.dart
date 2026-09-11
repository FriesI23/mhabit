import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../breakpoints/breakpoints.dart';
import '../breakpoints/window_size_class.dart';
import '../cupertino/cupertino_adaptive_modal.dart';
import '../material/material_adaptive_modal.dart';
import 'adaptive_back_button.dart';
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
/// A null [barrierDismissible] makes dialog presentations dismissible, matching
/// Flutter's regular dialog behavior. A fixed Cupertino sheet uses Flutter's
/// non-dismissible [CupertinoSheetRoute] barrier; an automatically responsive
/// route retains its configured barrier while resizing between presentations.
/// [enableDrag] controls gesture dismissal independently.
Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  AdaptiveModalPresentation? presentationOverride,
  bool useRootNavigator = true,
  bool? barrierDismissible,
  bool enableDrag = true,
  bool showDragHandle = false,
  RouteSettings? routeSettings,
}) {
  final style = AdaptiveStyle.of(context);
  if (presentationOverride == null) {
    final breakpoints = Breakpoints.of(context);
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
          showDragHandle: showDragHandle,
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
          showDragHandle: showDragHandle,
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
          breakpoints: Breakpoints.of(context),
          presentationOverride: AdaptiveModalPresentation.dialog,
          builder: builder,
          enableDrag: enableDrag,
          showDragHandle: showDragHandle,
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
        showDragHandle: showDragHandle,
        routeSettings: routeSettings,
        builder: (controller) =>
            buildRouteContent(scrollController: controller),
      ),
    (AdaptiveStyle.apple, AdaptiveModalPresentation.sheet) =>
      showCupertinoAdaptiveSheetRoute<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        enableDrag: enableDrag,
        showDragHandle: showDragHandle,
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
  final _closeController = _AdaptiveModalCloseController();
  late final Widget _content = KeyedSubtree(
    key: _contentKey,
    child: Builder(builder: widget.builder),
  );

  @override
  Widget build(BuildContext context) {
    _closeController.routeClose = () async {
      Navigator.pop(context);
    };
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

/// Hosts a stable navigation stack inside an adaptive modal route.
///
/// The [builder] receives a context below the nested [Navigator], so ordinary
/// `Navigator.of(context)` calls target this modal-local stack. Popping its
/// initial page through system back closes the surrounding modal. Use [pop]
/// when an explicit action must close the whole modal or return a typed result.
///
/// A nested Navigator's overlay must have a finite viewport. Sheet
/// presentations fill their surface; dialog presentations use [dialogSize]
/// constrained to the shared modal bounds.
class AdaptiveModalNavigator<T> extends StatefulWidget {
  const AdaptiveModalNavigator({
    super.key,
    required this.builder,
    this.dialogSize = const Size(560, 560),
    this.routeSettings,
  });

  final WidgetBuilder builder;
  final Size dialogSize;
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
      child: NavigatorPopHandler<Object?>(
        onPopWithResult: (result) =>
            _navigatorKey.currentState?.maybePop<Object?>(result),
        child: Navigator(
          key: _navigatorKey,
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
    return switch (presentation) {
      AdaptiveModalPresentation.sheet => SizedBox.expand(child: navigator),
      AdaptiveModalPresentation.dialog => SizedBox(
        width: math.min(widget.dialogSize.width, windowSize.width * 0.9),
        height: math.min(
          widget.dialogSize.height,
          AdaptiveModalConstraints.maximumHeightOf(context),
        ),
        child: navigator,
      ),
    };
  }
}

/// Platform-adaptive modal content with fixed semantic regions.
///
/// This is the content counterpart to [showAdaptiveSheet], similar to how an
/// [AlertDialog] supplies dialog regions while the show helper owns its route.
/// Callers own the business meaning and callbacks of every action supplied
/// here.
class AdaptiveModal extends StatefulWidget {
  const AdaptiveModal({
    super.key,
    required this.body,
    this.title,
    this.leadingAction,
    this.actions = const [],
    this.pinnedBody,
    this.bottomActions = const [],
    this.automaticallyImplyLeading = false,
    this.automaticallyImplyCloseButton = true,
    this.onCloseRequested,
    this.constraints,
  });

  final Widget? title;
  final Widget? leadingAction;
  final List<Widget> actions;
  final Widget? pinnedBody;
  final Widget body;
  final List<Widget> bottomActions;
  final bool automaticallyImplyLeading;
  final bool automaticallyImplyCloseButton;
  final VoidCallback? onCloseRequested;
  final BoxConstraints? constraints;

  @override
  State<AdaptiveModal> createState() => _AdaptiveModalState();
}

class _AdaptiveModalState extends State<AdaptiveModal> {
  late final ScrollController _fallbackScrollController = ScrollController();
  _AdaptiveModalCloseController? _closeController;
  ModalRoute<dynamic>? _pageRoute;
  Animation<double>? _pageAnimation;
  Animation<double>? _secondaryPageAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pageRoute = ModalRoute.of(context);
    final pageAnimation = pageRoute?.animation;
    final secondaryPageAnimation = pageRoute?.secondaryAnimation;
    if (pageAnimation == _pageAnimation &&
        secondaryPageAnimation == _secondaryPageAnimation) {
      _pageRoute = pageRoute;
      return;
    }
    _pageAnimation?.removeStatusListener(_handlePageAnimationStatus);
    _secondaryPageAnimation?.removeStatusListener(_handlePageAnimationStatus);
    _pageRoute = pageRoute;
    _pageAnimation = pageAnimation;
    _secondaryPageAnimation = secondaryPageAnimation;
    _pageAnimation?.addStatusListener(_handlePageAnimationStatus);
    _secondaryPageAnimation?.addStatusListener(_handlePageAnimationStatus);
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
    if (mounted) setState(() {});
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
      callback();
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
    final closeController = routeScope?.closeController;
    final ownsRouteScrollController = _ownsRouteScrollController(
      routeScope?.hostRoute,
    );
    if (closeController != _closeController) {
      _closeController?.unregister(this);
      _closeController = closeController;
    }
    if (ownsRouteScrollController) {
      closeController?.register(this, _requestClose);
    } else {
      closeController?.unregister(this);
    }
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
        (widget.automaticallyImplyLeading && (_pageRoute?.canPop ?? false)
            ? const AdaptiveBackButton()
            : null);

    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => MaterialAdaptiveModal(
        title: widget.title,
        leadingAction: leadingAction,
        actions: widget.actions,
        pinnedBody: widget.pinnedBody,
        body: widget.body,
        bottomActions: widget.bottomActions,
        automaticallyImplyCloseButton: widget.automaticallyImplyCloseButton,
        onCloseRequested: _requestClose,
        constraints: widget.constraints,
        presentation: presentation,
        scrollController: scrollController,
      ),
      AdaptiveStyle.apple => CupertinoAdaptiveModal(
        title: widget.title,
        leadingAction: leadingAction,
        actions: widget.actions,
        pinnedBody: widget.pinnedBody,
        body: widget.body,
        bottomActions: widget.bottomActions,
        automaticallyImplyCloseButton: widget.automaticallyImplyCloseButton,
        onCloseRequested: _requestClose,
        constraints: widget.constraints,
        presentation: presentation,
        scrollController: scrollController,
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
    required super.child,
  });

  final ValueChanged<Object?> closeModal;

  @override
  bool updateShouldNotify(_InheritedAdaptiveModalNavigator oldWidget) => false;
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
  Object? _owner;
  Future<void> Function()? _closeHandler;
  Future<void> Function() routeClose = _noop;

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

  static Future<void> _noop() async {}
}
