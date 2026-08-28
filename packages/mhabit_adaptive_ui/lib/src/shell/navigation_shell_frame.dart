import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

import '../adaptive/adaptive_navigation_destination.dart';
import '../breakpoints/window_size_class.dart';
import '../window_control/window_control_layout.dart';
import 'adaptive_nav_scope.dart';
import 'adaptive_nav_visibility.dart';

/// Navigation form selected from the current window size classes.
///
/// ```text
/// bar              railCollapsed      railExtended
/// +----------+     +--+----------+    +------+------+
/// | content  |     |r | content  |    | rail |content|
/// +----------+     |a |          |    |      |       |
/// | nav bar  |     |i |          |    |      |       |
/// +----------+     |l |          |    +------+-------+
///                  +--+----------+
/// ```
enum NavigationShellForm {
  /// Compact bottom navigation below the branch content.
  bar,

  /// Medium-and-wider side rail initially showing icons only.
  railCollapsed,

  /// Wide side rail initially showing icons and labels.
  railExtended,
}

/// Default duration for navigation form and compact-chrome transitions.
const Duration navigationShellAnimationDuration = Duration(milliseconds: 250);

/// Builds the leading rail region for the current shell form.
typedef NavigationShellLeadingBuilder =
    Widget Function(
      BuildContext context,
      NavigationShellForm form,
      ValueChanged<int> onDestinationSelected,
    );

/// Builds compact navigation or floating action chrome from shell state.
typedef NavigationShellChromeBuilder =
    Widget Function(BuildContext context, NavigationShellChromeState state);

/// Read-only chrome state supplied to themed shell builders.
@immutable
class NavigationShellChromeState {
  /// Creates a snapshot backed by the shell's visibility listenables.
  const NavigationShellChromeState({
    required this.compact,
    required this.visible,
    required this.scrollWish,
    required this.onDestinationSelected,
    required this.reportScrollWish,
  });

  /// Whether the shell currently uses its compact bottom-bar form.
  final bool compact;

  /// Whether compact navigation chrome should be painted and interactive.
  final ValueListenable<bool> visible;

  /// Whether the active page wants expanded or visible navigation chrome.
  final ValueListenable<bool> scrollWish;

  /// Selects a destination while resetting branch-owned chrome state.
  final ValueChanged<int> onDestinationSelected;

  /// Reports an explicit non-scroll visibility wish to the shell.
  final ValueChanged<bool> reportScrollWish;
}

/// Style-neutral shell mechanics shared by the themed renderers.
class NavigationShellFrame extends StatefulWidget {
  /// Creates a shell frame around [child] with themed chrome builders.
  const NavigationShellFrame({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.compactRouteVisible,
    required this.contextualChromeSuppressed,
    required this.barHeight,
    required this.navHeight,
    required this.keepVisibleOnScroll,
    required this.leadingBuilder,
    required this.compactNavigationBuilder,
    this.floatingActionButtonBuilder,
    this.floatingActionButtonLocation,
    this.switchDuration = navigationShellAnimationDuration,
  });

  /// Branch content displayed beside or above navigation chrome.
  final Widget child;

  /// Zero-based index of the selected destination.
  final int selectedIndex;

  /// Top-level destinations supplied to themed renderers.
  final List<AdaptiveNavigationDestination> destinations;

  /// Called with the index of a destination selected by the user.
  final ValueChanged<int> onDestinationSelected;

  /// Whether route structure allows compact navigation to be shown.
  final bool compactRouteVisible;

  /// Whether contextual commands suppress compact navigation chrome.
  final bool contextualChromeSuppressed;

  /// Height of the compact navigation surface without its outer inset.
  final double barHeight;

  /// Full compact navigation envelope reserved by branch content.
  final double navHeight;

  /// Whether scroll wishes leave the compact chrome envelope visible.
  ///
  /// The themed renderer may still present a minimized surface inside it.
  final bool keepVisibleOnScroll;

  /// Builds the rail region for non-compact shell forms.
  final NavigationShellLeadingBuilder leadingBuilder;

  /// Builds compact navigation from the current chrome state.
  final NavigationShellChromeBuilder compactNavigationBuilder;

  /// Optionally builds a floating action from the current chrome state.
  final NavigationShellChromeBuilder? floatingActionButtonBuilder;

  /// Scaffold placement used by [floatingActionButtonBuilder].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Duration used when switching compact navigation in or out.
  final Duration switchDuration;

  @override
  State<NavigationShellFrame> createState() => _NavigationShellFrameState();
}

class _NavigationShellFrameState extends State<NavigationShellFrame> {
  NavigationShellForm _form = NavigationShellForm.bar;
  final AdaptiveNavVisibilityController _navVisibility =
      AdaptiveNavVisibilityController();
  final AdaptiveScrollWishController _scrollWish =
      AdaptiveScrollWishController();

  @override
  void initState() {
    super.initState();
    _scrollWish.addListener(_recomputeVisibility);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _form = _formFor(WindowSize.of(context));
    if (_form == NavigationShellForm.bar) {
      _recomputeVisibility();
    } else {
      _navVisibility.show();
    }
  }

  @override
  void didUpdateWidget(covariant NavigationShellFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    final branchChanged = oldWidget.selectedIndex != widget.selectedIndex;
    final routeVisibilityChanged =
        oldWidget.compactRouteVisible != widget.compactRouteVisible;
    final contextualVisibilityChanged =
        oldWidget.contextualChromeSuppressed !=
        widget.contextualChromeSuppressed;
    if (routeVisibilityChanged) {
      _scrollWish.reset();
    }
    if (routeVisibilityChanged || contextualVisibilityChanged) {
      _recomputeVisibility();
    }
    if (!branchChanged) return;
    _scrollWish.reset();
    _recomputeVisibility();
  }

  @override
  void dispose() {
    _scrollWish.removeListener(_recomputeVisibility);
    _scrollWish.dispose();
    _navVisibility.dispose();
    super.dispose();
  }

  void _recomputeVisibility() {
    if (!mounted || _form != NavigationShellForm.bar) return;
    final visible =
        widget.compactRouteVisible &&
        (widget.keepVisibleOnScroll || _scrollWish.value) &&
        !widget.contextualChromeSuppressed;
    if (_navVisibility.value == visible) return;
    visible ? _navVisibility.show() : _navVisibility.hide();
  }

  void _onDestinationSelected(int index) {
    _scrollWish.reset();
    widget.onDestinationSelected(index);
  }

  NavigationShellForm _formFor(WindowSize windowSize) {
    if (windowSize.width == WindowSizeClass.compact) {
      return NavigationShellForm.bar;
    }
    if (windowSize.width == WindowSizeClass.medium ||
        windowSize.height == WindowSizeClass.compact) {
      return NavigationShellForm.railCollapsed;
    }
    return NavigationShellForm.railExtended;
  }

  @override
  Widget build(BuildContext context) {
    final compact = _form == NavigationShellForm.bar;
    final windowControlLayout = AdaptiveWindowControlLayoutScope.maybeOf(
      context,
    );
    final padding = MediaQuery.paddingOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final chromeState = NavigationShellChromeState(
      compact: compact,
      visible: _navVisibility,
      scrollWish: _scrollWish,
      onDestinationSelected: _onDestinationSelected,
      reportScrollWish: _scrollWish.report,
    );

    final shell = AdaptiveNavScope(
      visible: compact ? _navVisibility : null,
      scrollWish: compact ? _scrollWish : null,
      barHeight: compact ? widget.barHeight : 0,
      navHeight: compact ? widget.navHeight : 0,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: _NavigationScrollWishObserver(
          onVisibilityChanged: _scrollWish.report,
          child: _NavigationShellBody(
            ambientPadding: padding,
            ambientViewPadding: viewPadding,
            form: _form,
            leadingBuilder: widget.leadingBuilder,
            onDestinationSelected: _onDestinationSelected,
            child: widget.child,
          ),
        ),
        floatingActionButton: widget.floatingActionButtonBuilder?.call(
          context,
          chromeState,
        ),
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        bottomNavigationBar: AnimatedSwitcher(
          duration: widget.switchDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          child: compact
              ? KeyedSubtree(
                  key: const ValueKey('bottom-bar'),
                  child: widget.compactNavigationBuilder(context, chromeState),
                )
              : const SizedBox.shrink(key: ValueKey('bottom-bar-hidden')),
        ),
      ),
    );
    return _withWindowControlOwner(
      context,
      layout: windowControlLayout,
      railOwnsAvoidance: !compact,
      shell: shell,
    );
  }

  Widget _withWindowControlOwner(
    BuildContext context, {
    required AdaptiveWindowControlLayoutScope? layout,
    required bool railOwnsAvoidance,
    required Widget shell,
  }) {
    if (layout != null) {
      return _WindowControlLayoutOwner(
        layout: layout,
        railOwnsAvoidance: railOwnsAvoidance,
        child: shell,
      );
    }
    return AdaptiveWindowControlLayout(
      child: Builder(
        builder: (context) => _WindowControlLayoutOwner(
          layout: AdaptiveWindowControlLayoutScope.maybeOf(context)!,
          railOwnsAvoidance: railOwnsAvoidance,
          child: shell,
        ),
      ),
    );
  }
}

/// Animates compact chrome visibility without owning visibility policy.
class CompactNavigationChromeTransition extends StatelessWidget {
  /// Creates a transition driven by [visibility].
  const CompactNavigationChromeTransition({
    super.key,
    required this.visibility,
    required this.child,
    this.collapseLayout = false,
    this.topClipOverflow = 0,
  });

  /// Read-only visibility state controlled by the shell.
  final ValueListenable<bool> visibility;

  /// Chrome translated and faded by the transition.
  final Widget child;

  /// Whether hidden chrome also collapses its layout height.
  final bool collapseLayout;

  /// Extra paint area retained above a collapsing clip boundary.
  final double topClipOverflow;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: visibility,
    child: child,
    builder: (context, visible, child) => TweenAnimationBuilder<double>(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : navigationShellAnimationDuration,
      curve: Curves.easeOut,
      tween: Tween<double>(begin: visible ? 1 : 0, end: visible ? 1 : 0),
      child: child,
      builder: (context, factor, child) {
        final faded = IgnorePointer(
          ignoring: factor == 0,
          child: Opacity(opacity: factor, child: child),
        );
        if (!collapseLayout) {
          return FractionalTranslation(
            translation: Offset(0, 1 - factor),
            child: faded,
          );
        }
        return ClipRect(
          clipper: _CompactNavigationClipper(topOverflow: topClipOverflow),
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: factor,
            child: faded,
          ),
        );
      },
    ),
  );
}

class _CompactNavigationClipper extends CustomClipper<Rect> {
  const _CompactNavigationClipper({required this.topOverflow});

  final double topOverflow;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, -topOverflow, size.width, size.height);

  @override
  bool shouldReclip(covariant _CompactNavigationClipper oldClipper) =>
      oldClipper.topOverflow != topOverflow;
}

class _NavigationScrollWishObserver extends StatelessWidget {
  const _NavigationScrollWishObserver({
    required this.onVisibilityChanged,
    required this.child,
  });

  final ValueChanged<bool> onVisibilityChanged;
  final Widget child;

  bool _handleNotification(UserScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    switch (notification.direction) {
      case ScrollDirection.forward:
        onVisibilityChanged(true);
      case ScrollDirection.reverse:
        onVisibilityChanged(false);
      case ScrollDirection.idle:
        break;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<UserScrollNotification>(
        onNotification: _handleNotification,
        child: child,
      );
}

class _NavigationShellBody extends StatelessWidget {
  const _NavigationShellBody({
    required this.ambientPadding,
    required this.ambientViewPadding,
    required this.form,
    required this.leadingBuilder,
    required this.onDestinationSelected,
    required this.child,
  });

  final EdgeInsets ambientPadding;
  final EdgeInsets ambientViewPadding;
  final NavigationShellForm form;
  final NavigationShellLeadingBuilder leadingBuilder;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(padding: ambientPadding, viewPadding: ambientViewPadding),
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            leadingBuilder(context, form, onDestinationSelected),
            Expanded(
              child: _NavigationShellBranch(form: form, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationShellBranch extends StatelessWidget {
  const _NavigationShellBranch({required this.form, required this.child});

  final NavigationShellForm form;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (form == NavigationShellForm.bar) return child;

    // NavigationRail's SafeArea owns the shell's logical-start system inset.
    // Remove that consumed inset from the sibling branch so page SafeAreas do
    // not reserve it again. Keep the opposite side available to page content.
    final removeLeft = Directionality.of(context) == TextDirection.ltr;
    return MediaQuery.removePadding(
      context: context,
      removeLeft: removeLeft,
      removeRight: !removeLeft,
      child: child,
    );
  }
}

class _WindowControlLayoutOwner extends StatelessWidget {
  const _WindowControlLayoutOwner({
    required this.layout,
    required this.railOwnsAvoidance,
    required this.child,
  });

  final AdaptiveWindowControlLayoutScope layout;
  final bool railOwnsAvoidance;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveWindowControlLayoutScope(
      horizontalAvoidance: layout.horizontalAvoidance,
      verticalAvoidance: layout.verticalAvoidance,
      horizontalSafeAreaAvoidance: layout.horizontalSafeAreaAvoidance,
      verticalSafeAreaAvoidance: layout.verticalSafeAreaAvoidance,
      effectiveCornerRadii: layout.effectiveCornerRadii,
      owner: railOwnsAvoidance
          ? WindowControlLayoutOwner.rail
          : WindowControlLayoutOwner.appBar,
      child: child,
    );
  }
}
