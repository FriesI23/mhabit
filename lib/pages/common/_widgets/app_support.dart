// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoButton;
import 'package:flutter/foundation.dart'
    show ValueListenable, listEquals, precisionErrorTolerance;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:simple_icons/simple_icons.dart';

import '../../../common/app_info.dart';
import '../../../common/distribution.dart';
import '../../../common/utils.dart';
import '../../../extensions/context_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../providers/support/about_info.dart';
import '../../../providers/workflow/app_support.dart';
import '../../../widgets/widgets.dart';
import 'donate_dialog.dart';

/// Display configuration shared by the dialog and Settings cards.
///
/// [AboutInfo] validates link targets; [DonateConfig] owns donation methods.
/// An empty list hides the carousel; one card needs no pagination or autoplay.
class AppSupportContent {
  const AppSupportContent({
    required this.info,
    this.hideDonate = false,
    this.channelAction = AppSupportAction.githubStar,
  });

  final AboutInfo info;
  final bool hideDonate;
  final AppSupportAction channelAction;

  List<_AppSupportCardKind> _cards(String donationWays) => [
    if (info.sourceCodeUri != null || channelAction.isStore)
      _AppSupportCardKind.support,
    if (!hideDonate &&
        DonateConfig(info: info).hasAvailableMethod(donationWays))
      _AppSupportCardKind.donate,
    if (info.sourceCodeUri != null || info.issueTrackerUri != null)
      _AppSupportCardKind.participate,
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
/// The caller records link and dismissal results. Normal dismissals return
/// [AppSupportResult.remindLater]. Removal, host invalidation and late results
/// return [AppSupportResult.cancelled]. The caller's context must remain mounted
/// throughout the operation. A supplied [controller] is single-use and its host
/// must cancel it on destruction.
///
/// Previews reuse the same interaction without changing reminder history.
Future<AppSupportResult> showAppSupportDialog({
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
      return AppSupportResult.cancelled;
    }
    final owner = context.maybeRead<AppSupportOwner>();
    final content = AppSupportContent(
      info: info,
      hideDonate: hideDonate ?? AppInfo().shouldHideDonate(),
      channelAction:
          owner?.channelAction ??
          AppSupportAction.forDistribution(
            distribution: defaultAppDistribution,
          ),
    );
    final AppSupportResult? result;
    state._beginRoute();
    try {
      result = await showAdaptiveModalDialog<AppSupportResult>(
        context: context,
        barrierDismissible: true,
        routeSettings: const RouteSettings(name: 'app-support'),
        builder: (_) => owner == null
            ? _AppSupportDialog(content: content, controller: state)
            : ListenableBuilder(
                listenable: owner,
                builder: (_, _) => _AppSupportDialog(
                  content: AppSupportContent(
                    info: info,
                    hideDonate: content.hideDonate,
                    channelAction: owner.channelAction,
                  ),
                  controller: state,
                ),
              ),
      );
      // The pop future completes before the reverse transition. In particular,
      // a donation sheet must not be pushed over the outgoing dialog route.
      await state._route?.completed;
    } finally {
      state._completeRoute();
    }
    if (state._cancelled || !context.mounted) {
      return AppSupportResult.cancelled;
    }
    final selection = state._selectedAction;
    if (selection == null) {
      return result ??
          (state._popped
              ? AppSupportResult.remindLater
              : AppSupportResult.cancelled);
    }
    final outcome = await selection.openDestination(
      info: info,
      openUrl: openUrl ?? launchExternalUrl,
      showDonation: showDonation ?? (_) => content.showDonation(context),
      isHostActive: () => context.mounted && !state._cancelled,
    );
    if (outcome == AppSupportResult.actionFailed && context.mounted) {
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
  bool _cancelled = false;
  bool _removalScheduled = false;
  AppSupportAction? _selectedAction;
  ModalRoute<AppSupportResult>? _route;
  Completer<void>? _routeCompletion;

  /// Removes only this route and invalidates any operation still in flight.
  void cancel() {
    if (_finished) return;
    _cancelled = true;
    _finished = true;
    _removeRouteAfterFrame();
  }

  /// Cancels the interaction and waits until its dialog route has left.
  ///
  /// Includes a pushed route that has not built yet and an outgoing transition.
  /// Does not wait for an external link or donation operation after route removal.
  /// Cancelling before presentation completes immediately without scheduling a frame.
  Future<void> cancelAndWait() {
    cancel();
    return _routeCompletion?.future ?? Future.value();
  }

  void _beginRoute() => _routeCompletion ??= Completer<void>();

  void _completeRoute() {
    final completion = _routeCompletion;
    if (completion != null && !completion.isCompleted) completion.complete();
  }

  void _attachRoute(ModalRoute<AppSupportResult>? route) {
    _route = route;
    // Cancellation can arrive after push but before the dialog's first build.
    if (_cancelled) _removeRouteAfterFrame();
  }

  void _removeRouteAfterFrame() {
    if (_route?.isActive != true || _removalScheduled) return;
    _removalScheduled = true;
    // Hosts may cancel from dispose while the Navigator is finalizing a route.
    // Cancellation is immediate; only removing an active overlay is deferred.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _removalScheduled = false;
      final route = _route;
      final navigator = route?.navigator;
      if (route != null && route.isActive && navigator?.mounted == true) {
        navigator!.removeRoute(route);
      }
    }, debugLabel: 'AppSupportDialog.cancel');
    WidgetsBinding.instance.scheduleFrame();
  }

  void _closeDialog([AppSupportResult? result]) {
    if (_finished || _popped || _route?.isCurrent != true) return;
    _popped = true;
    _route?.navigator?.pop(result);
  }

  void _selectAction(AppSupportAction action) {
    if (_finished || _popped || _route?.isCurrent != true) return;
    _selectedAction = action;
    _closeDialog();
  }
}

class _AppSupportDialog extends StatelessWidget {
  const _AppSupportDialog({required this.content, required this.controller});

  final AppSupportContent content;
  final AppSupportDialogController controller;

  @override
  Widget build(BuildContext context) {
    controller._attachRoute(ModalRoute.of<AppSupportResult>(context));
    final l10n = L10n.of(context)!;
    return PopScope<AppSupportResult>(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) controller._popped = true;
      },
      child: AdaptiveDialog(
        content: SizedBox(
          width: 320,
          child: AppSupportCarousel(
            content: content,
            onSelected: controller._selectAction,
          ),
        ),
        actions: [
          AdaptiveDialogAction(
            label: l10n.appSupport_never,
            isDestructiveAction: true,
            onPressed: () =>
                controller._closeDialog(AppSupportResult.stopReminding),
          ),
          AdaptiveDialogAction(
            label: l10n.appSupport_later,
            onPressed: () =>
                controller._closeDialog(AppSupportResult.remindLater),
          ),
        ],
      ),
    );
  }
}

/// Hosts an automatic support reminder at a caller-selected location.
///
/// The owner holds eligibility and the once-per-session guard. The caller
/// provides [AppSupportOwner] with ChangeNotifierProvider, chooses when to mount
/// this widget and supplies live presentation safety.
/// This startup host is separate from Settings, which only observes the owner
/// and executes explicit selections without checking startup eligibility.
class AppSupportReminder extends StatefulWidget {
  const AppSupportReminder({
    super.key,
    required this.canShowDialog,
    required this.child,
    this.fallbackForeground,
    this.showSupportDialog = showAppSupportDialog,
  });

  /// Reads current UI safety, including immediately after asynchronous work.
  /// Callers subscribe to reactive dependencies with Provider so changes also
  /// rebuild this host and permanently cancel this startup's opportunity.
  final bool Function(BuildContext context) canShowDialog;

  /// Native foreground evidence while Flutter has no lifecycle state yet.
  /// Once a lifecycle state arrives, it always takes precedence.
  final ValueListenable<bool>? fallbackForeground;
  final Widget child;
  final Future<AppSupportResult> Function({
    required BuildContext context,
    required AboutInfo info,
    AppSupportDialogController? controller,
  })
  showSupportDialog;

  @override
  State<AppSupportReminder> createState() => _AppSupportReminderState();
}

class _AppSupportReminderState extends State<AppSupportReminder> {
  late final AppSupportOwner _owner;
  late final AppLifecycleListener _lifecycle;
  final _dialog = AppSupportDialogController();
  bool _reminderCheckStarted = false;
  bool _firstFrameComplete = false;
  late bool _hasEnteredForeground;

  bool get _isForeground {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    return lifecycle == null
        ? (widget.fallbackForeground?.value ?? false)
        : lifecycle == AppLifecycleState.resumed;
  }

  @override
  void initState() {
    super.initState();
    _owner = context.read<AppSupportOwner>();
    _hasEnteredForeground = _isForeground;
    _lifecycle = AppLifecycleListener(
      onStateChange: (_) => _onForegroundChanged(),
    );
    widget.fallbackForeground?.addListener(_onForegroundChanged);
    HardwareKeyboard.instance.addHandler(_onKey);
    _owner.addListener(_tryShowReminder);
    _owner.init();
    // Descendant Navigators and AppPostInit must attach before presentation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _firstFrameComplete = true;
      _tryShowReminder();
    }, debugLabel: 'AppSupportReminder.ready');
  }

  void _onForegroundChanged() {
    if (_isForeground) {
      if (!_hasEnteredForeground) {
        _hasEnteredForeground = true;
        _tryShowReminder();
      }
    } else if (_hasEnteredForeground) {
      _owner.skipReminderForSession();
    }
  }

  bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      _owner.skipReminderForSession();
    }
    return false;
  }

  void _tryShowReminder() {
    if (!mounted ||
        !_firstFrameComplete ||
        !_owner.inited ||
        !_hasEnteredForeground ||
        _reminderCheckStarted ||
        !_isForeground) {
      return;
    }
    _reminderCheckStarted = true;
    unawaited(_showReminderIfEligible());
  }

  void _skipReminderIfUnsafe() {
    if (_firstFrameComplete &&
        _hasEnteredForeground &&
        !widget.canShowDialog(context)) {
      _owner.skipReminderForSession();
    }
  }

  @override
  void didUpdateWidget(AppSupportReminder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fallbackForeground != widget.fallbackForeground) {
      oldWidget.fallbackForeground?.removeListener(_onForegroundChanged);
      widget.fallbackForeground?.addListener(_onForegroundChanged);
      _onForegroundChanged();
    }
    _skipReminderIfUnsafe();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _skipReminderIfUnsafe();
  }

  Future<void> _showReminderIfEligible() => _owner.showReminderIfEligible(
    canShowDialog: () =>
        mounted && _isForeground && widget.canShowDialog(context),
    onReminderSaveFailed: () {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.appSupport_saveFailed)),
      );
    },
    showSupportDialog: (info) async {
      if (!mounted) return AppSupportResult.cancelled;
      final result = await widget.showSupportDialog(
        context: context,
        info: info,
        controller: _dialog,
      );
      return mounted ? result : AppSupportResult.cancelled;
    },
  );

  @override
  void dispose() {
    widget.fallbackForeground?.removeListener(_onForegroundChanged);
    _owner.removeListener(_tryShowReminder);
    _owner.skipReminderForSession();
    _dialog.cancel();
    _lifecycle.dispose();
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  @override
  // Let startup sync confirmations dismiss this automatic reminder first.
  Widget build(BuildContext context) =>
      Provider<AppSupportDialogController>.value(
        value: _dialog,
        child: Listener(
          onPointerDown: (_) => _owner.skipReminderForSession(),
          onPointerSignal: (_) => _owner.skipReminderForSession(),
          child: widget.child,
        ),
      );
}

/// Shared rendering and local playback. Business actions belong to the host.
///
/// Each instance owns its page controller, finite star animation and one-shot
/// timer. Visibility combines [active], app lifecycle, ancestor Navigator routes,
/// [TickerMode] and viewport intersection. Hidden instances cancel their timer;
/// once visible and idle, a full four-second interval starts again.
/// Pointer activity and scrolling suspend autoplay until the page settles.
/// Keyboard input resets the interval; retaining focus or hovering does not
/// pause it. Accessible navigation and reduced motion disable autoplay.
/// Decorative animations run once per instance, only on their current visible
/// page. Leaving the page pauses progress; returning does not restart it.
class AppSupportCarousel extends StatefulWidget {
  const AppSupportCarousel({
    super.key,
    required this.content,
    required this.onSelected,
    this.active = true,
  });

  final AppSupportContent content;

  /// Reports a business selection; paging never invokes this callback.
  final ValueChanged<AppSupportAction> onSelected;

  /// Whether the host permits playback.
  final bool active;

  @override
  State<AppSupportCarousel> createState() => _AppSupportCarouselState();
}

class _AppSupportCarouselState extends State<AppSupportCarousel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stars;
  final _heroPlayback = ValueNotifier<_AppSupportCardKind?>(null);
  // Paging belongs to this instance rather than its ancestor's PageStorage.
  final _pages = PageController(keepPage: false);
  final _focus = FocusNode();
  late final AppLifecycleListener _lifecycle;
  Timer? _autoplayTimer;
  List<_AppSupportCardKind> _cards = const [];
  String _donationWays = '';
  bool _inViewport = false;
  bool _viewportCheckScheduled = false;
  bool _pageScrolling = false;
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
    _routes.clear();
    // ModalRoute.of registers inherited dependencies for each Navigator, so a
    // covering route updates playback without listening to route animations.
    var route = ModalRoute.of(context);
    final visited = <NavigatorState>{};
    while (route != null) {
      _routes.add(route);
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
    if (cards.isEmpty) {
      // Removing PageView during a drag has no final scroll notification.
      _pageScrolling = false;
      _pointers.clear();
    }
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
      !_pageScrolling &&
      _pointers.isEmpty &&
      _cards.length > 1 &&
      _pages.hasClients;

  void _updatePlayback() {
    if (!mounted) return;
    final hero = _visible && !_reduced && !_pageScrolling && _cards.isNotEmpty
        ? _cards[_index]
        : null;
    // Lifecycle and geometry listeners need to update the images too, without
    // rebuilding the whole carousel or relying on Timer/TickerMode alone.
    _heroPlayback.value = hero;
    if (_reduced) {
      if (_stars.value != 1) _stars.value = 1;
    } else if (hero == _AppSupportCardKind.support) {
      if (!_stars.isAnimating && !_stars.isCompleted) _stars.forward();
    } else if (_stars.isAnimating) {
      _stars.stop();
    }
    final playing = _canPlay;
    if (_playing == playing) return;
    _playing = playing;
    _restartAutoplayTimer();
  }

  void _restartAutoplayTimer() {
    _autoplayTimer?.cancel();
    _autoplayTimer = null;
    if (!mounted || !_canPlay) return;
    // A one-shot timer gives every settled page a complete idle interval;
    // a periodic timer could fire immediately after a user's drag finishes.
    _autoplayTimer = Timer(const Duration(seconds: 4), () {
      _autoplayTimer = null;
      if (mounted && _canPlay) {
        unawaited(_showPage((_index + 1) % _cards.length));
      }
    });
  }

  bool _onPageScroll(ScrollNotification notification) {
    if (notification.depth != 0 || _correctingPage) return false;
    if (notification is ScrollStartNotification ||
        notification is ScrollEndNotification) {
      _pageScrolling = notification is ScrollStartNotification;
      if (!_pageScrolling) _alignReducedMotionPage();
      _updatePlayback();
    }
    return false;
  }

  void _alignReducedMotionPage() {
    if (!_reduced ||
        _pageScrolling ||
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

  Future<void> _showPage(int page) async {
    if (!_pages.hasClients || _cards.isEmpty) return;
    _autoplayTimer?.cancel();
    if (_reduced) {
      _pages.jumpToPage(page);
    } else {
      await _pages.animateToPage(
        page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
    if (mounted) _restartAutoplayTimer();
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_scheduleViewportCheck);
    _lifecycle.dispose();
    _focus.dispose();
    _pages.dispose();
    _heroPlayback.dispose();
    _stars.dispose();
    _autoplayTimer?.cancel();
    super.dispose();
  }

  void _movePage(int delta) {
    _restartAutoplayTimer();
    if (_cards.length < 2) return;
    final direction = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    _focus.requestFocus();
    unawaited(
      _showPage((_index + delta * direction + _cards.length) % _cards.length),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointers.add(event.pointer);
    _updatePlayback();
  }

  void _onPointerEnd(PointerEvent event) {
    _pointers.remove(event.pointer);
    _updatePlayback();
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    _updatePlayback();
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) return const SizedBox.shrink();
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: _onSizeChanged,
      child: SizeChangedLayoutNotifier(
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                _movePage(1),
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                _movePage(-1),
          },
          child: Focus(
            focusNode: _focus,
            skipTraversal: true,
            onFocusChange: (_) => _restartAutoplayTimer(),
            onKeyEvent: (_, event) {
              if (event is KeyDownEvent || event is KeyRepeatEvent) {
                _restartAutoplayTimer();
              }
              return KeyEventResult.ignored;
            },
            // Observe presses on child buttons without competing with their
            // tap recognizers or PageView's horizontal drag recognizer.
            child: Listener(
              onPointerDown: _onPointerDown,
              onPointerUp: _onPointerEnd,
              onPointerCancel: _onPointerEnd,
              onPointerSignal: (_) => _restartAutoplayTimer(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NotificationListener<ScrollMetricsNotification>(
                    onNotification: _onPageMetrics,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onPageScroll,
                      child: _AppSupportPages(
                        controller: _pages,
                        cards: _cards,
                        content: widget.content,
                        starAnimation: _stars,
                        heroPlayback: _heroPlayback,
                        index: _index,
                        reduced: _reduced,
                        onPageChanged: _onPageChanged,
                        onSelected: widget.onSelected,
                      ),
                    ),
                  ),
                  if (_cards.length > 1)
                    _AppSupportPagination(
                      count: _cards.length,
                      index: _index,
                      onSelected: _showPage,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Measures static cards to keep page height stable without a measurement loop.
/// Only the current real page contributes focus and semantics.
class _AppSupportPages extends StatelessWidget {
  const _AppSupportPages({
    required this.controller,
    required this.cards,
    required this.content,
    required this.starAnimation,
    required this.heroPlayback,
    required this.index,
    required this.reduced,
    required this.onPageChanged,
    this.onSelected,
  });

  final PageController controller;
  final List<_AppSupportCardKind> cards;
  final AppSupportContent content;
  final Animation<double> starAnimation;
  final ValueListenable<_AppSupportCardKind?> heroPlayback;
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
    key: ValueKey(cards[page]),
    excluding: page != index,
    child: ExcludeSemantics(
      excluding: page != index,
      child: ValueListenableBuilder<_AppSupportCardKind?>(
        valueListenable: heroPlayback,
        builder: (context, playing, child) =>
            TickerMode(enabled: playing == cards[page], child: child!),
        child: _buildCard(page),
      ),
    ),
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

  Widget _buildHero(BuildContext context) {
    if (measuring) return const SizedBox(height: 44);
    return ExcludeSemantics(
      child: SizedBox(
        key: ValueKey('app-support-hero-${kind.name}'),
        height: 44,
        child: Center(
          child: switch (kind) {
            _AppSupportCardKind.support => _AppSupportStars(
              animation: starAnimation,
            ),
            _AppSupportCardKind.donate => const BuyMeACoffeeIcon(),
            _AppSupportCardKind.participate => Icon(
              Icons.code_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          },
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final l10n = L10n.of(context)!;
    return switch (kind) {
      _AppSupportCardKind.support => [
        if (content.info.sourceCodeUri != null)
          _GitHubSupportButton(onSelected: onSelected),
        if (content.channelAction.isStore)
          _StoreSupportButton(
            action: content.channelAction,
            onSelected: onSelected,
          ),
      ],
      _AppSupportCardKind.participate => [
        if (content.info.sourceCodeUri != null)
          _AppSupportActionButton(
            action: AppSupportAction.sourceCode,
            label: l10n.appAbout_sourceCodeTile_titleText,
            onSelected: onSelected,
          ),
        if (content.info.issueTrackerUri != null)
          _AppSupportActionButton(
            action: AppSupportAction.feedback,
            label: l10n.appAbout_issueTrackerTile_titleText,
            onSelected: onSelected,
          ),
      ],
      _AppSupportCardKind.donate => [
        _AppSupportActionButton(
          action: AppSupportAction.donate,
          label: l10n.appAbout_donateTile_titleText,
          onSelected: onSelected,
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
            _buildHero(context),
            const SizedBox(height: 10),
            Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _buildActions(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Each support destination owns its action and localized label.
class _GitHubSupportButton extends StatelessWidget {
  const _GitHubSupportButton({required this.onSelected});

  final ValueChanged<AppSupportAction>? onSelected;

  @override
  Widget build(BuildContext context) => _AppSupportActionButton(
    action: AppSupportAction.githubStar,
    label: L10n.of(context)!.appSupport_starOnGitHub,
    onSelected: onSelected,
  );
}

class _StoreSupportButton extends StatelessWidget {
  const _StoreSupportButton({required this.action, required this.onSelected});

  final AppSupportAction action;
  final ValueChanged<AppSupportAction>? onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final label = switch (action) {
      AppSupportAction.googlePlay => l10n.appSupport_rateOnGooglePlay,
      AppSupportAction.appStore => l10n.appSupport_rateOnAppStore,
      AppSupportAction.microsoftStore => l10n.appSupport_openOnMicrosoftStore,
      AppSupportAction.flathub => l10n.appSupport_favoriteOnFlathub,
      _ => throw StateError('Expected a store support action'),
    };
    return _AppSupportActionButton(
      action: action,
      label: label,
      onSelected: onSelected,
    );
  }
}

class _AppSupportActionButton extends StatelessWidget {
  const _AppSupportActionButton({
    required this.action,
    required this.label,
    required this.onSelected,
  });

  final AppSupportAction action;
  final String label;
  final ValueChanged<AppSupportAction>? onSelected;

  @override
  Widget build(BuildContext context) {
    final callback = onSelected == null ? null : () => onSelected!(action);
    final icon = Icon(switch (action) {
      AppSupportAction.githubStar => Icons.star_rounded,
      AppSupportAction.googlePlay => SimpleIcons.googleplay,
      AppSupportAction.appStore => SimpleIcons.appstore,
      AppSupportAction.microsoftStore => Icons.storefront_outlined,
      AppSupportAction.flathub => SimpleIcons.flathub,
      AppSupportAction.donate => SimpleIcons.buymeacoffee,
      AppSupportAction.sourceCode => Icons.code_rounded,
      AppSupportAction.feedback => Icons.bug_report_outlined,
    }, size: 16);
    final text = Text(label, textAlign: TextAlign.center);
    return AdaptiveStyle.of(context) == AdaptiveStyle.apple
        ? CupertinoButton.tinted(
            key: ValueKey('app-support-action-${action.name}'),
            onPressed: callback,
            minimumSize: const Size(0, 44),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 8),
                Flexible(child: text),
              ],
            ),
          )
        : FilledButton.tonalIcon(
            key: ValueKey('app-support-action-${action.name}'),
            onPressed: callback,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            icon: icon,
            label: text,
          );
  }
}

// Star styling inspired by Running Services Monitor, revision
// 772e266fb7dd95c76a64b74d10b33af8b95122ab.
// Copyright (c) 2025 Biplob Kumar Sutradhar; MIT, see LICENSE_THIRDPARTY.md.
/// Decorative stars driven by the carousel's single finite animation.
///
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

enum _AppSupportCardKind {
  /// GitHub Star and the current channel's store review or favorite link.
  support,

  /// Available donation methods.
  donate,

  /// Source code and feedback links.
  participate,
}
