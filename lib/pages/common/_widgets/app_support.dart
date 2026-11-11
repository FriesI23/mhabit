// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoButton;
import 'package:flutter/foundation.dart'
    show listEquals, precisionErrorTolerance;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../common/app_info.dart';
import '../../../common/utils.dart';
import '../../../l10n/localizations.dart';
import '../../../providers/support/about_info.dart';
import '../../../providers/workflow/app_support.dart';
import 'donate_dialog.dart';

/// Display configuration shared by the dialog and Settings cards.
///
/// Figure 1. Filtered page order (omitted pages leave no empty slots):
/// ```text
/// Support -> Participate -> Donate
/// source     source or      visible and at least one
/// URI        feedback URI   available DonateConfig method
/// ```
/// [AboutInfo] validates link targets; [DonateConfig] owns donation methods.
/// An empty list hides the carousel; one card needs no pagination or autoplay.
class AppSupportContent {
  const AppSupportContent({required this.info, this.hideDonate = false});

  final AboutInfo info;
  final bool hideDonate;

  List<_AppSupportCardKind> _cards(String donationWays) => [
    if (info.sourceCodeUri != null) _AppSupportCardKind.support,
    if (info.sourceCodeUri != null || info.issueTrackerUri != null)
      _AppSupportCardKind.participate,
    if (!hideDonate &&
        DonateConfig(info: info).hasAvailableMethod(donationWays))
      _AppSupportCardKind.donate,
  ];

  /// Whether a host has any configured cards to display.
  bool hasCards(String donationWays) => _cards(donationWays).isNotEmpty;

  /// Presents the configured donation options using the shared donation UI.
  Future<void> showDonation(BuildContext context) async {
    await showDonateDialog(context, config: DonateConfig(info: info));
  }
}

/// Shows shared cards, then executes a selection after the dialog leaves.
///
/// This function never consumes reminder events. Normal dismissals count as
/// later; removal, host invalidation and late results count as aborted. The
/// caller's context must remain mounted throughout the operation. A supplied
/// [controller] is single-use; its host must abort it on destruction.
///
/// Figure 2. Dialog closure and action completion are separate milestones:
/// ```text
/// business selection -> pop -> route.completed -> execute -> result
/// ordinary dismissal -> later
/// host invalidation  -> aborted (including an action's late result)
/// ```
/// The caller decides whether to persist the result, allowing previews to use
/// the same interaction without changing reminder history.
Future<AppSupportPromptResult> showAppSupportDialog({
  required BuildContext context,
  required AboutInfo info,
  Future<bool> Function(Uri)? openUrl,
  AppSupportDialogController? controller,
  Future<void> Function(AboutInfo)? showDonation,
  bool? hideDonate,
}) async {
  final state = controller ?? AppSupportDialogController();
  try {
    if (state._finished || !context.mounted) {
      return AppSupportPromptResult.aborted;
    }
    final content = AppSupportContent(
      info: info,
      hideDonate: hideDonate ?? AppInfo().shouldHideDonate(),
    );
    final result = await showAdaptiveModalDialog<AppSupportPromptResult>(
      context: context,
      barrierDismissible: true,
      routeSettings: const RouteSettings(name: 'app-support'),
      builder: (_) => _AppSupportDialog(content: content, controller: state),
    );
    // The pop future completes before the reverse transition. In particular,
    // a donation sheet must not be pushed over the outgoing dialog route.
    await state._route?.completed;
    if (state._aborted || !context.mounted) {
      return AppSupportPromptResult.aborted;
    }
    final selection = state._selection;
    if (selection == null) {
      return result ??
          (state._popped
              ? AppSupportPromptResult.later
              : AppSupportPromptResult.aborted);
    }
    final outcome = await selection.execute(
      info: info,
      openUrl: openUrl ?? launchExternalUrl,
      showDonation: showDonation ?? (_) => content.showDonation(context),
      isAlive: () => context.mounted && !state._aborted,
    );
    if (outcome == AppSupportPromptResult.actionFailed && context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.appSupport_linkFailed)),
      );
    }
    return outcome;
  } finally {
    state._finished = true;
  }
}

/// Host lifetime, distinct from the already-closed dialog's route lifetime.
///
/// Retain this controller until [showAppSupportDialog] completes, not just until
/// its route pops: an external action may still be awaiting a result.
class AppSupportDialogController {
  bool _popped = false;
  bool _finished = false;
  bool _aborted = false;
  bool _removalScheduled = false;
  AppSupportAction? _selection;
  ModalRoute<AppSupportPromptResult>? _route;

  /// Removes only this route and invalidates any operation still in flight.
  void abort() {
    if (_finished) return;
    _aborted = true;
    _finished = true;
    _removeRouteAfterFrame();
  }

  void _attachRoute(ModalRoute<AppSupportPromptResult>? route) {
    _route = route;
    // An abort can arrive after push but before the dialog's first build.
    if (_aborted) _removeRouteAfterFrame();
  }

  void _removeRouteAfterFrame() {
    if (_route?.isActive != true || _removalScheduled) return;
    _removalScheduled = true;
    // Hosts may abort from dispose while the Navigator is finalizing a route.
    // Cancellation is immediate; only removing an active overlay is deferred.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _removalScheduled = false;
      final route = _route;
      final navigator = route?.navigator;
      if (route != null && route.isActive && navigator?.mounted == true) {
        navigator!.removeRoute(route);
      }
    }, debugLabel: 'AppSupportDialog.abort');
    WidgetsBinding.instance.scheduleFrame();
  }

  void _finish(AppSupportPromptResult result) {
    if (_finished || _popped || _route?.isCurrent != true) return;
    _popped = true;
    _route?.navigator?.pop(result);
  }

  void _select(AppSupportAction action) {
    if (_finished || _popped || _route?.isCurrent != true) return;
    _selection = action;
    _finish(AppSupportPromptResult.auxiliaryAction);
  }
}

class _AppSupportDialog extends StatelessWidget {
  const _AppSupportDialog({required this.content, required this.controller});

  final AppSupportContent content;
  final AppSupportDialogController controller;

  @override
  Widget build(BuildContext context) {
    controller._attachRoute(ModalRoute.of<AppSupportPromptResult>(context));
    final l10n = L10n.of(context)!;
    return PopScope<AppSupportPromptResult>(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) controller._popped = true;
      },
      child: AdaptiveDialog(
        content: SizedBox(
          width: 320,
          child: AppSupportCarousel(
            content: content,
            animateStars: true,
            onSelected: controller._select,
          ),
        ),
        actions: [
          AdaptiveDialogAction(
            label: l10n.appSupport_never,
            isDestructiveAction: true,
            onPressed: () => controller._finish(AppSupportPromptResult.never),
          ),
          AdaptiveDialogAction(
            label: l10n.appSupport_later,
            onPressed: () => controller._finish(AppSupportPromptResult.later),
          ),
        ],
      ),
    );
  }
}

/// Hosts an automatic support prompt at a caller-selected location.
///
/// The owner holds eligibility and the once-per-session guard. The caller
/// provides [AppSupportOwner] with ChangeNotifierProvider, chooses when to mount
/// this widget and supplies live presentation safety.
/// This startup host is separate from Settings, which only observes the owner
/// and executes explicit selections without checking startup eligibility.
class AppSupportPrompt extends StatefulWidget {
  const AppSupportPrompt({
    super.key,
    required this.canPresent,
    required this.child,
    this.showPrompt = showAppSupportDialog,
  });

  /// Reads current UI safety, including immediately after asynchronous work.
  /// Callers subscribe to reactive dependencies with Provider so changes also
  /// rebuild this host and permanently cancel this startup's opportunity.
  final bool Function(BuildContext context) canPresent;
  final Widget child;
  final Future<AppSupportPromptResult> Function({
    required BuildContext context,
    required AboutInfo info,
    AppSupportDialogController? controller,
  })
  showPrompt;

  @override
  State<AppSupportPrompt> createState() => _AppSupportPromptState();
}

class _AppSupportPromptState extends State<AppSupportPrompt> {
  late final AppSupportOwner _owner;
  late final AppLifecycleListener _lifecycle;
  final _dialog = AppSupportDialogController();
  bool _checkStarted = false;
  bool _firstFrameComplete = false;
  late bool _hasEnteredForeground;

  @override
  void initState() {
    super.initState();
    _owner = context.read<AppSupportOwner>();
    _hasEnteredForeground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.resumed) {
          if (!_hasEnteredForeground) {
            _hasEnteredForeground = true;
            _tryCheck();
          }
        } else if (_hasEnteredForeground) {
          _owner.skipPrompt();
        }
      },
    );
    HardwareKeyboard.instance.addHandler(_onKey);
    _owner.addListener(_tryCheck);
    _owner.init();
    // Descendant Navigators and AppPostInit must attach before presentation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _firstFrameComplete = true;
      _tryCheck();
    }, debugLabel: 'AppSupportPrompt.ready');
  }

  bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) _owner.skipPrompt();
    return false;
  }

  void _tryCheck() {
    if (!mounted ||
        !_firstFrameComplete ||
        !_owner.initialized ||
        !_hasEnteredForeground ||
        _checkStarted ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    _checkStarted = true;
    unawaited(_check());
  }

  void _cancelIfUnsafe() {
    if (_firstFrameComplete &&
        _hasEnteredForeground &&
        !widget.canPresent(context)) {
      _owner.skipPrompt();
    }
  }

  @override
  void didUpdateWidget(AppSupportPrompt oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cancelIfUnsafe();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cancelIfUnsafe();
  }

  Future<void> _check() => _owner.checkPrompt(
    canPresent: () =>
        mounted &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
        widget.canPresent(context),
    onSaveFailed: () {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.appSupport_saveFailed)),
      );
    },
    showPrompt: (info) async {
      if (!mounted) return AppSupportPromptResult.aborted;
      final result = await widget.showPrompt(
        context: context,
        info: info,
        controller: _dialog,
      );
      return mounted ? result : AppSupportPromptResult.aborted;
    },
  );

  @override
  void dispose() {
    _owner.removeListener(_tryCheck);
    _owner.skipPrompt();
    _dialog.abort();
    _lifecycle.dispose();
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _owner.skipPrompt(),
    onPointerSignal: (_) => _owner.skipPrompt(),
    child: widget.child,
  );
}

/// Shared rendering and local playback. Business actions belong to the host.
///
/// Figure 3. One current card, with optional clickable pagination:
/// ```text
/// +---------------------------+
/// | Title / message           |
/// | *  *  *  *  * (Support)   |
/// | Business action button(s) |
/// +---------------------------+
///          o  (o)  o
/// ```
/// Each instance owns its page controller, finite star animation and one-shot
/// timer. Visibility combines [active], app lifecycle, ancestor Navigator routes,
/// [TickerMode] and viewport intersection. Hidden instances cancel their timer;
/// once visible and idle, a full four-second interval starts again.
/// Pointer activity and scrolling suspend autoplay until the page settles.
/// Keyboard input resets the interval; retaining focus or hovering does not
/// pause it. Accessible navigation and reduced motion disable autoplay.
class AppSupportCarousel extends StatefulWidget {
  const AppSupportCarousel({
    super.key,
    required this.content,
    required this.onSelected,
    this.active = true,
    this.enabled = true,
    this.animateStars = false,
  });

  final AppSupportContent content;

  /// Reports a business selection; paging never invokes this callback.
  final ValueChanged<AppSupportAction> onSelected;

  /// Whether the host permits playback, such as while no action is pending.
  final bool active;

  /// Enables business and pagination buttons; independent of playback [active].
  final bool enabled;

  /// Runs two overlapping star waves once during this carousel instance.
  /// Dialogs opt in; Settings keeps the stars static. Page changes do not replay
  /// the sequence, and reduced motion leaves all five stars at their baseline.
  final bool animateStars;

  @override
  State<AppSupportCarousel> createState() => _AppSupportCarouselState();
}

class _AppSupportCarouselState extends State<AppSupportCarousel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stars;
  // Paging belongs to this instance rather than its ancestor's PageStorage.
  late final _pages = PageController(
    keepPage: false,
    onAttach: _attachPagePosition,
    onDetach: _detachPagePosition,
  );
  final _focus = FocusNode();
  late final AppLifecycleListener _lifecycle;
  Timer? _timer;
  List<_AppSupportCardKind> _cards = const [];
  String _donationWays = '';
  bool _inViewport = false;
  bool _viewportCheckScheduled = false;
  bool _dragging = false;
  bool _correctingPage = false;
  bool _playing = false;
  final _pointers = <int>{};
  bool _foreground = true;
  bool _reduced = false;
  bool _accessibleNavigation = false;
  bool _tickerEnabled = true;
  Size _windowSize = Size.zero;
  int _index = 0;
  ScrollPosition? _scrollPosition;
  final _routes = <ModalRoute<dynamic>>[];
  final _routeAnimations = <Animation<double>>[];

  @override
  void initState() {
    super.initState();
    _stars = AnimationController(
      vsync: this,
      duration: _AppSupportStars.duration,
    );
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        _foreground = state == AppLifecycleState.resumed;
        _updatePlayback();
      },
    );
    _focus.addListener(_resetTimer);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    _accessibleNavigation = MediaQuery.accessibleNavigationOf(context);
    _windowSize = MediaQuery.sizeOf(context);
    _tickerEnabled = TickerMode.valuesOf(context).enabled;
    _donationWays = L10n.of(context)!.appAbout_donateTile_ways;
    _updateCards();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _scrollPosition) {
      _scrollPosition?.removeListener(_scheduleViewportCheck);
      _scrollPosition = position;
      position?.addListener(_scheduleViewportCheck);
    }
    for (final animation in _routeAnimations) {
      animation.removeListener(_updatePlayback);
    }
    _routeAnimations.clear();
    _routes.clear();
    var route = ModalRoute.of(context);
    final visited = <NavigatorState>{};
    while (route != null) {
      _routes.add(route);
      for (final animation in [route.animation, route.secondaryAnimation]) {
        if (animation != null) {
          _routeAnimations.add(animation);
          animation.addListener(_updatePlayback);
        }
      }
      final navigator = route.navigator;
      if (navigator == null || !visited.add(navigator)) break;
      route = ModalRoute.of(navigator.context);
    }
    _updatePlayback();
    _scheduleViewportCheck();
  }

  @override
  void didUpdateWidget(AppSupportCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed = _updateCards();
    _updatePlayback();
    if (changed || (!oldWidget.active && widget.active)) {
      _scheduleViewportCheck();
    }
  }

  bool _updateCards() {
    final cards = widget.content._cards(_donationWays);
    if (listEquals(cards, _cards)) return false;
    _cards = cards;
    _index = _index.clamp(0, math.max(0, cards.length - 1));
    // PageView corrects its scroll bounds when the children change. A fresh
    // position starts at initialPage, so neither case needs a delayed jump.
    return true;
  }

  void _scheduleViewportCheck() {
    if (!mounted || _viewportCheckScheduled) return;
    _viewportCheckScheduled = true;
    // Global transforms must be read after the surrounding layout has settled.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewportCheckScheduled = false;
      if (mounted) _checkViewport();
    }, debugLabel: 'AppSupportCarousel.geometry');
  }

  void _checkViewport() {
    if (!mounted) return;
    final box = context.findRenderObject();
    var visible = box is RenderBox && box.hasSize && box.attached;
    if (visible) {
      final bounds = box.localToGlobal(Offset.zero) & box.size;
      final viewport = RenderAbstractViewport.maybeOf(box);
      final viewportBox = viewport is RenderBox ? viewport as RenderBox : null;
      final clip = viewportBox != null
          ? viewportBox.localToGlobal(Offset.zero) & viewportBox.size
          : Offset.zero & _windowSize;
      visible = bounds.overlaps(clip) && !bounds.isEmpty;
    }
    _inViewport = visible;
    _updatePlayback();
  }

  bool get _visible =>
      widget.active &&
      _foreground &&
      _inViewport &&
      _tickerEnabled &&
      _routes.every((route) => route.isCurrent);

  // These are playback policies, not scroll physics. TickerMode alone cannot
  // stop a Dart Timer; _updatePlayback cancels it when eligibility changes.
  bool get _canPlay =>
      _visible &&
      !_reduced &&
      !_accessibleNavigation &&
      !_dragging &&
      _pointers.isEmpty &&
      _cards.length > 1 &&
      _pages.hasClients;

  void _updatePlayback() {
    if (!mounted) return;
    if (_reduced) {
      if (_stars.value != 1) _stars.value = 1;
    } else if (widget.animateStars &&
        _visible &&
        _cards.contains(_AppSupportCardKind.support)) {
      if (!_stars.isAnimating && !_stars.isCompleted) _stars.forward();
    } else if (_stars.isAnimating) {
      _stars.stop();
    }
    final playing = _canPlay;
    if (_playing == playing) return;
    _playing = playing;
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    if (!mounted || !_canPlay) return;
    // A one-shot timer gives every settled page a complete idle interval;
    // a periodic timer could fire immediately after a user's drag finishes.
    _timer = Timer(const Duration(seconds: 4), () {
      _timer = null;
      if (mounted && _canPlay) unawaited(_goTo((_index + 1) % _cards.length));
    });
  }

  void _attachPagePosition(ScrollPosition position) {
    position.isScrollingNotifier.addListener(_onPageScrolling);
    _dragging = position.isScrollingNotifier.value;
    _updatePlayback();
  }

  void _detachPagePosition(ScrollPosition position) {
    position.isScrollingNotifier.removeListener(_onPageScrolling);
    _dragging = false;
    _updatePlayback();
  }

  void _onPageScrolling() {
    if (!mounted || !_pages.hasClients || _correctingPage) return;
    _dragging = _pages.position.isScrollingNotifier.value;
    if (!_dragging) _alignReducedMotionPage();
    _updatePlayback();
  }

  void _alignReducedMotionPage() {
    if (!_reduced ||
        _dragging ||
        _correctingPage ||
        _cards.isEmpty ||
        !_pages.hasClients) {
      return;
    }
    final position = _pages.position;
    if (!position.hasPixels ||
        !position.hasViewportDimension ||
        !position.hasContentDimensions ||
        position.viewportDimension == 0) {
      return;
    }
    final current = _pages.page!;
    final page = current.round().clamp(0, _cards.length - 1);
    // page is clamped by PagePosition even while bouncing beyond its bounds.
    if ((current - page).abs() < precisionErrorTolerance &&
        !position.outOfRange) {
      return;
    }
    _correctingPage = true;
    try {
      _pages.jumpToPage(page);
    } finally {
      _correctingPage = false;
    }
  }

  bool _onPageMetrics(ScrollMetricsNotification notification) {
    if (notification.depth == 0) {
      _alignReducedMotionPage();
      _checkViewport();
    }
    return false;
  }

  bool _onSizeChanged(SizeChangedLayoutNotification notification) {
    _scheduleViewportCheck();
    return false;
  }

  Future<void> _goTo(int page) async {
    if (!_pages.hasClients || _cards.isEmpty) return;
    _timer?.cancel();
    if (_reduced) {
      _pages.jumpToPage(page);
    } else {
      await _pages.animateToPage(
        page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
    if (mounted) _resetTimer();
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_scheduleViewportCheck);
    for (final animation in _routeAnimations) {
      animation.removeListener(_updatePlayback);
    }
    _lifecycle.dispose();
    _focus.dispose();
    _pages.dispose();
    _stars.dispose();
    _timer?.cancel();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    _resetTimer();
    if (_cards.length < 2) return KeyEventResult.ignored;
    final delta = event.logicalKey == LogicalKeyboardKey.arrowRight
        ? 1
        : event.logicalKey == LogicalKeyboardKey.arrowLeft
        ? -1
        : 0;
    if (delta == 0) return KeyEventResult.ignored;
    final direction = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    _focus.requestFocus();
    unawaited(
      _goTo((_index + delta * direction + _cards.length) % _cards.length),
    );
    return KeyEventResult.handled;
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointers.add(event.pointer);
    _updatePlayback();
  }

  void _onPointerEnd(PointerEvent event) {
    _pointers.remove(event.pointer);
    _updatePlayback();
  }

  void _onPageChanged(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) return const SizedBox.shrink();
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: _onSizeChanged,
      child: SizeChangedLayoutNotifier(
        child: Focus(
          focusNode: _focus,
          skipTraversal: true,
          onKeyEvent: _onKeyEvent,
          child: Listener(
            onPointerDown: _onPointerDown,
            onPointerUp: _onPointerEnd,
            onPointerCancel: _onPointerEnd,
            onPointerSignal: (_) => _resetTimer(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NotificationListener<ScrollMetricsNotification>(
                  onNotification: _onPageMetrics,
                  child: _AppSupportPages(
                    controller: _pages,
                    cards: _cards,
                    content: widget.content,
                    starAnimation: _stars,
                    index: _index,
                    reduced: _reduced,
                    onPageChanged: _onPageChanged,
                    onSelected: widget.enabled ? widget.onSelected : null,
                  ),
                ),
                if (_cards.length > 1)
                  _AppSupportPagination(
                    count: _cards.length,
                    index: _index,
                    onSelected: widget.enabled ? _goTo : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stable content layout; playback and host lifetime belong to the carousel.
///
/// Figure 4. SDK layout composition determines height without a measurement loop:
/// ```text
/// Stack
/// +-- IndexedStack(index: null)    tallest natural card; not painted
/// +-- Positioned.fill(PageView)   interactive pages in that fixed space
/// ```
/// Measuring copies have static stars and disabled callbacks. Constraints,
/// localization and text scaling naturally relayout the stack; page changes
/// keep its height stable. Only the current real page contributes focus and
/// semantics.
class _AppSupportPages extends StatelessWidget {
  const _AppSupportPages({
    required this.controller,
    required this.cards,
    required this.content,
    required this.starAnimation,
    required this.index,
    required this.reduced,
    required this.onPageChanged,
    this.onSelected,
  });

  final PageController controller;
  final List<_AppSupportCardKind> cards;
  final AppSupportContent content;
  final Animation<double> starAnimation;
  final int index;
  final bool reduced;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<AppSupportAction>? onSelected;

  Widget _buildCard(int page, {bool measuring = false}) => _AppSupportCard(
    kind: cards[page],
    content: content,
    starAnimation: starAnimation,
    measuring: measuring,
    onSelected: measuring ? null : onSelected,
  );

  Widget _buildMeasurements() => SizedBox(
    width: double.infinity,
    child: ExcludeFocus(
      child: IndexedStack(
        index: null,
        children: [
          for (var page = 0; page < cards.length; page++)
            _buildCard(page, measuring: true),
        ],
      ),
    ),
  );

  Widget _buildPage(int page) => ExcludeFocus(
    excluding: page != index,
    child: ExcludeSemantics(excluding: page != index, child: _buildCard(page)),
  );

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      // Static cards establish the tallest natural size without painting.
      _buildMeasurements(),
      Positioned.fill(
        child: PageView(
          controller: controller,
          pageSnapping: !reduced,
          physics: reduced ? const _AppSupportPageScrollPhysics() : null,
          onPageChanged: onPageChanged,
          children: [
            for (var page = 0; page < cards.length; page++) _buildPage(page),
          ],
        ),
      ),
    ],
  );
}

class _AppSupportPagination extends StatelessWidget {
  const _AppSupportPagination({
    required this.count,
    required this.index,
    this.onSelected,
  });

  final int count;
  final int index;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var page = 0; page < count; page++)
          Semantics(
            container: true,
            label: l10n.appSupport_page(page + 1, count),
            selected: page == index,
            child: _AppSupportPageIndicator(
              key: ValueKey('app-support-page-$page'),
              selected: page == index,
              onPressed: onSelected == null ? null : () => onSelected!(page),
            ),
          ),
      ],
    );
  }
}

class _AppSupportCard extends StatelessWidget {
  const _AppSupportCard({
    required this.kind,
    required this.content,
    required this.starAnimation,
    required this.measuring,
    this.onSelected,
  });
  final _AppSupportCardKind kind;
  final AppSupportContent content;
  final Animation<double> starAnimation;
  final bool measuring;
  final ValueChanged<AppSupportAction>? onSelected;

  Widget _buildActionButton(
    BuildContext context,
    AppSupportAction action,
    String label,
  ) {
    final callback = onSelected == null ? null : () => onSelected!(action);
    return AdaptiveStyle.of(context) == AdaptiveStyle.apple
        ? CupertinoButton(
            onPressed: callback,
            child: Text(label, textAlign: TextAlign.center),
          )
        : TextButton(
            onPressed: callback,
            child: Text(label, textAlign: TextAlign.center),
          );
  }

  List<Widget> _buildActions(BuildContext context) {
    final l10n = L10n.of(context)!;
    return switch (kind) {
      _AppSupportCardKind.support => [
        _buildActionButton(
          context,
          AppSupportAction.support,
          l10n.appSupport_open('GitHub'),
        ),
      ],
      _AppSupportCardKind.participate => [
        if (content.info.sourceCodeUri != null)
          _buildActionButton(
            context,
            AppSupportAction.sourceCode,
            l10n.appAbout_sourceCodeTile_titleText,
          ),
        if (content.info.issueTrackerUri != null)
          _buildActionButton(
            context,
            AppSupportAction.feedback,
            l10n.appAbout_issueTrackerTile_titleText,
          ),
      ],
      _AppSupportCardKind.donate => [
        _buildActionButton(
          context,
          AppSupportAction.donate,
          l10n.appAbout_donateTile_titleText,
        ),
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final title = switch (kind) {
      _AppSupportCardKind.support => l10n.appSupport_title,
      _AppSupportCardKind.participate => l10n.appSupport_participateTitle,
      _AppSupportCardKind.donate => l10n.appAbout_donateTile_titleText,
    };
    final message = switch (kind) {
      _AppSupportCardKind.support => l10n.appSupport_message,
      _AppSupportCardKind.participate => l10n.appSupport_participateMessage,
      _AppSupportCardKind.donate => l10n.appAbout_donateTile_subTitleText,
    };

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            if (kind == _AppSupportCardKind.support)
              measuring
                  ? const SizedBox(height: 44)
                  : _AppSupportStars(animation: starAnimation),
            ..._buildActions(context),
          ],
        ),
      ),
    );
  }
}

// Star styling inspired by Running Services Monitor, revision
// 772e266fb7dd95c76a64b74d10b33af8b95122ab.
// Copyright (c) 2025 Biplob Kumar Sutradhar; MIT, see LICENSE_THIRDPARTY.md.
/// Decorative stars driven by the carousel's single finite animation.
///
/// Figure 5. Overlapping bounce intervals form a wave, then repeat once:
/// ```text
/// time ->
/// star 1  /\____
/// star 2   /\___
/// star 3    /\__
/// star 4     /\_
/// star 5      /\
///         wave 1 | wave 2 | baseline
/// ```
/// Each bounce lasts 720 ms, with a 120 ms stagger: two 1.2-second waves.
/// The parent pauses/resumes progress on visibility changes without resetting
/// it. Stars expose neither a rating value nor accessibility actions.
class _AppSupportStars extends StatelessWidget {
  const _AppSupportStars({required this.animation});

  final Animation<double> animation;
  static const _starCount = 5;
  static const _waves = 2;
  static const _bounceMs = 720;
  static const _staggerMs = 120;
  static const _waveMs = _bounceMs + (_starCount - 1) * _staggerMs;
  static const duration = Duration(milliseconds: _waveMs * _waves);

  static final _bounce = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: -8.0,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: -8.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 1,
    ),
  ]);

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: 44,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            // Overlapping intervals form a travelling wave, with every star
            // returning to its baseline at the end of the second wave.
            final elapsedMs =
                (animation.value * duration.inMilliseconds) % _waveMs;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _starCount; i++)
                  Transform.translate(
                    key: ValueKey('app-support-star-$i'),
                    offset: Offset(
                      0,
                      animation.value < 1
                          ? _bounce.transform(
                              ((elapsedMs - i * _staggerMs) / _bounceMs).clamp(
                                0.0,
                                1.0,
                              ),
                            )
                          : 0,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      size: 28,
                      color: Theme.brightnessOf(context) == Brightness.dark
                          ? Colors.amber.shade300
                          : Colors.amber.shade600,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

// Keep Flutter's standard dot appearance while giving each page a full-sized
// pointer and keyboard target. Playback restarts after the page has settled.
// TabPageSelector itself is display-only; composing its SDK indicator with
// standard buttons preserves Tab/Enter activation and a 44px hit target.
class _AppSupportPageIndicator extends StatelessWidget {
  const _AppSupportPageIndicator({
    super.key,
    required this.selected,
    this.onPressed,
  });

  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    final indicator = TabPageSelectorIndicator(
      backgroundColor: selected ? color : Colors.transparent,
      borderColor: color,
      size: 12,
    );
    return AdaptiveStyle.of(context) == AdaptiveStyle.apple
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size.square(44),
            onPressed: onPressed,
            child: indicator,
          )
        : TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size.square(44),
              padding: EdgeInsets.zero,
            ),
            onPressed: onPressed,
            child: indicator,
          );
  }
}

// A reduced-motion drag snaps directly to its destination without a ballistic
// animation. Programmatic and keyboard changes also use jumpToPage.
// PageScrollPhysics normally adds a spring simulation; NeverScrollableScrollPhysics
// would also prevent manual dragging. The idle listener performs the direct snap.
class _AppSupportPageScrollPhysics extends PageScrollPhysics {
  const _AppSupportPageScrollPhysics({super.parent});
  @override
  _AppSupportPageScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _AppSupportPageScrollPhysics(parent: buildParent(ancestor));
  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) => null;
}

enum _AppSupportCardKind { support, participate, donate }
