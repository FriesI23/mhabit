import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../adaptive/adaptive_navigation_bar.dart';
import '../adaptive/adaptive_navigation_bar_presentation.dart';
import '../adaptive/adaptive_navigation_destination.dart';
import '../adaptive/adaptive_navigation_rail.dart';
import '../adaptive_style.dart';
import '../breakpoints/window_size_class.dart';
import '../cupertino/cupertino_adaptive_navigation_bar.dart';
import '../window_control/window_control_layout.dart';
import 'adaptive_nav_scope.dart';
import 'adaptive_nav_visibility.dart';

/// Extended navigation rail sizing configuration.
///
/// [collapsed] controls the icon-only rail. The extended interval grows from
/// [minimum] to [maximum] as the window moves from [rampStart] to [rampEnd].
/// The default constructor expresses a fixed logical-pixel target inside that
/// interval. Use [fromRatio] to express a relative position instead, where 0
/// selects the minimum and 1 the current upper bound.
class NavigationRailExtent {
  const NavigationRailExtent(
    double width, {
    this.collapsed = 72.0,
    this.minimum = 180.0,
    this.maximum = 360.0,
    this.rampStart = 600.0,
    this.rampEnd = 1600.0,
  }) : assert(width >= 0),
       assert(collapsed > 0),
       assert(minimum > 0),
       assert(minimum >= collapsed),
       assert(maximum >= minimum),
       assert(rampEnd > rampStart),
       _width = width,
       _ratio = null;

  const NavigationRailExtent.fromRatio(
    double ratio, {
    this.collapsed = 72.0,
    this.minimum = 180.0,
    this.maximum = 360.0,
    this.rampStart = 600.0,
    this.rampEnd = 1600.0,
  }) : assert(ratio >= 0 && ratio <= 1),
       assert(collapsed > 0),
       assert(minimum > 0),
       assert(minimum >= collapsed),
       assert(maximum >= minimum),
       assert(rampEnd > rampStart),
       _width = null,
       _ratio = ratio;

  /// Width of the collapsed icon rail.
  final double collapsed;

  /// Smallest extended rail width.
  final double minimum;

  /// Largest extended rail width available to manual resizing.
  final double maximum;

  /// Window width where the available upper bound equals [minimum].
  final double rampStart;

  /// Window width where the available upper bound reaches [maximum].
  final double rampEnd;

  final double? _width;
  final double? _ratio;

  /// Largest rail width available at [windowWidth].
  double upperBoundAt(double windowWidth) {
    final t = ((windowWidth - rampStart) / (rampEnd - rampStart)).clamp(
      0.0,
      1.0,
    );
    return minimum + (maximum - minimum) * t;
  }

  /// Resolves the automatic rail width at [windowWidth].
  double resolve(double windowWidth) {
    final upperBound = upperBoundAt(windowWidth);
    final width = _width;
    if (width != null) return width.clamp(minimum, upperBound);
    return minimum + (upperBound - minimum) * _ratio!;
  }

  /// Clamps a manually requested [width] to the interval at [windowWidth].
  double clamp(double width, {required double windowWidth}) =>
      width.clamp(minimum, upperBoundAt(windowWidth));
}

/// Adaptive navigation chrome around [child].
///
/// The form follows the window's width and height classes ([WindowSize.of]):
/// compact width keeps the adaptive bottom bar; medium width keeps a
/// collapsible [NavigationRail] collapsed by default; wider windows use an
/// extended rail unless their height is compact, in which case the rail also
/// defaults to collapsed. A null height preserves the width-only behavior.
/// The chrome animates when the form changes; the content area always fills
/// the remaining width without a maximum-width cap.
///
/// The extended rail uses a compact fixed target, clamped to the width
/// currently available in the resizable interval. Users can drag the rail's
/// trailing edge farther, up to the M3 drawer width, within that interval; a
/// manual value stays in memory and hands off continuously to the automatic
/// width when the window shrinks (the system never rewrites it, so it resumes
/// when the window grows back).
///
/// In the compact form, route and contextual suppression hide either renderer.
/// A false page scroll wish ([AdaptiveNavScope.reportScrollWish]) hides the
/// Material bar but minimizes the Apple bar. Route and navigation-stack
/// ownership stays with the caller. In non-compact forms the navigation is
/// always visible; [compactRouteVisible] and scroll wishes are ignored.
class AdaptiveNavigationShell extends StatefulWidget {
  const AdaptiveNavigationShell({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    this.compactRouteVisible = true,
    this.railExtent = const NavigationRailExtent(224.0),
    this.appleBarStyle = const AppleNavigationBarStyle(),
  });

  /// Content displayed beside or underneath the navigation chrome.
  final Widget child;

  /// Currently selected destination index.
  final int selectedIndex;

  /// Top-level navigation destinations.
  ///
  /// Non-compact forms map these to [NavigationRailDestination]s.
  final List<AdaptiveNavigationDestination> destinations;

  /// Called when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// Whether route structure allows the compact bottom bar to be shown.
  ///
  /// The caller owns route-stack interpretation. The final compact
  /// visibility also respects the page's current scroll wish. Ignored in
  /// non-compact forms, where navigation is always visible.
  final bool compactRouteVisible;

  /// Extended-rail sizing configuration.
  ///
  /// Controls the automatic width, resizable interval, and its window-width
  /// growth. This is a component-level layout input only and defaults to a
  /// compact 224dp target inside the 180–360dp interval.
  final NavigationRailExtent railExtent;

  /// Apple compact navigation-bar geometry.
  final AppleNavigationBarStyle appleBarStyle;

  @override
  State<AdaptiveNavigationShell> createState() =>
      _AdaptiveNavigationShellState();
}

/// Navigation forms of [AdaptiveNavigationShell].
enum _ShellForm {
  /// Compact: adaptive bottom navigation bar.
  bar,

  /// Collapsible [NavigationRail], collapsed by default.
  railCollapsed,

  /// Collapsible [NavigationRail], extended by default.
  railExtended,
}

/// Chrome animation duration shared by the bottom bar overlay and the rail
/// region.
const Duration _animationDuration = Duration(milliseconds: 250);

class _AdaptiveNavigationShellState extends State<AdaptiveNavigationShell> {
  static const double _materialBarHeight = 80.0;

  /// Current shell form, tracked in [didChangeDependencies].
  _ShellForm _form = _ShellForm.bar;

  /// Current adaptive renderer, tracked in [didChangeDependencies].
  AdaptiveStyle _style = AdaptiveStyle.material;

  /// Whether compact navigation chrome occupies layout space.
  final AdaptiveNavVisibilityController _navVisibility =
      AdaptiveNavVisibilityController();

  /// Whether the active page wants the bar shown, e.g. while scrolling.
  final AdaptiveScrollWishController _scrollWish =
      AdaptiveScrollWishController();

  final AdaptiveContextualChromeController _contextualChrome =
      AdaptiveContextualChromeController();

  @override
  void initState() {
    super.initState();
    _scrollWish.addListener(_recomputeVisibility);
    _contextualChrome.addListener(_recomputeVisibility);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _style = AdaptiveStyle.of(context);
    final form = _formFor(WindowSize.of(context));
    if (form != _form) {
      _form = form;
    }
    if (_form == _ShellForm.bar) {
      _recomputeVisibility();
    } else {
      // The navigation is always visible outside the compact form.
      _navVisibility.show();
    }
  }

  @override
  void didUpdateWidget(covariant AdaptiveNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.compactRouteVisible != widget.compactRouteVisible) {
      _scrollWish.reset();
      _recomputeVisibility();
    }
    if (oldWidget.selectedIndex == widget.selectedIndex) return;
    _scrollWish.reset();
    _contextualChrome.reset();
    _recomputeVisibility();
  }

  @override
  void dispose() {
    _scrollWish.removeListener(_recomputeVisibility);
    _contextualChrome.removeListener(_recomputeVisibility);
    _scrollWish.dispose();
    _contextualChrome.dispose();
    _navVisibility.dispose();
    super.dispose();
  }

  void _recomputeVisibility() {
    if (!mounted || _form != _ShellForm.bar) return;
    final visible =
        widget.compactRouteVisible &&
        (_style == AdaptiveStyle.apple || _scrollWish.value) &&
        !_contextualChrome.value;
    if (_navVisibility.value == visible) return;
    visible ? _navVisibility.show() : _navVisibility.hide();
  }

  void _onDestinationSelected(int index) {
    _scrollWish.reset();
    _contextualChrome.reset();
    widget.onDestinationSelected(index);
  }

  void _expandAppleBar() => _scrollWish.reset();

  /// Maps both window axes to the shell form, shared by all styles.
  ///
  /// Width remains authoritative for compact and medium. Wider windows fall
  /// back to a collapsed rail when height is compact; an unclassified height
  /// preserves the previous width-only extended-rail behavior.
  _ShellForm _formFor(WindowSize windowSize) {
    if (windowSize.width == WindowSizeClass.compact) return _ShellForm.bar;
    if (windowSize.width == WindowSizeClass.medium ||
        windowSize.height == WindowSizeClass.compact) {
      return _ShellForm.railCollapsed;
    }
    return _ShellForm.railExtended;
  }

  @override
  Widget build(BuildContext context) {
    final compact = _form == _ShellForm.bar;
    final windowControlLayout = AdaptiveWindowControlLayoutScope.maybeOf(
      context,
    );
    final padding = MediaQuery.paddingOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final barHeight = _style == AdaptiveStyle.apple
        ? CupertinoAdaptiveNavigationBar.contentHeight
        : _materialBarHeight;
    // The scope exposes the renderer's full envelope so branch pages reserve
    // the same space as the compact chrome. Apple also keeps a small floating
    // margin on windows without a system bottom inset.
    final navHeight = _style == AdaptiveStyle.apple
        ? CupertinoAdaptiveNavigationBar.heightOf(
            context,
            floatingBottomMargin: widget.appleBarStyle.floatingBottomMargin,
          )
        : barHeight + padding.bottom;

    final naviBarBody = ValueListenableBuilder<bool>(
      valueListenable: _scrollWish,
      builder: (context, scrollWish, child) => AdaptiveNavigationBar(
        selectedIndex: widget.selectedIndex,
        presentation: _style == AdaptiveStyle.apple && !scrollWish
            ? AdaptiveNavigationBarPresentation.minimized
            : AdaptiveNavigationBarPresentation.expanded,
        onExpandRequested: _expandAppleBar,
        materialStyle: const MaterialNavigationBarStyle(
          height: _materialBarHeight,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
        appleStyle: widget.appleBarStyle,
        destinations: widget.destinations,
        onDestinationSelected: _onDestinationSelected,
      ),
    );

    final shell = AdaptiveNavScope(
      visible: compact ? _navVisibility : null,
      scrollWish: compact ? _scrollWish : null,
      contextualChrome: _contextualChrome,
      barHeight: compact ? barHeight : 0,
      navHeight: compact ? navHeight : 0,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        extendBody: true,
        resizeToAvoidBottomInset: false,
        // Restore the ambient padding inside the body. Scaffold.extendBody
        // otherwise replaces the bottom padding with the navigation-bar
        // height, while branch pages already reserve that space through
        // AdaptiveNavScope.
        body: _NavigationShellBody(
          ambientPadding: padding,
          ambientViewPadding: viewPadding,
          form: _form,
          selectedIndex: widget.selectedIndex,
          destinations: widget.destinations,
          onDestinationSelected: _onDestinationSelected,
          railExtent: widget.railExtent,
          child: widget.child,
        ),
        // Owning the bar as Scaffold chrome makes this the root Scaffold
        // for the ambient ScaffoldMessenger. SnackBars are therefore laid
        // out above the compact bar instead of below its overlay.
        bottomNavigationBar: AnimatedSwitcher(
          duration:
              _style == AdaptiveStyle.apple &&
                  MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : _animationDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          child: compact
              ? ValueListenableBuilder<bool>(
                  key: const ValueKey('bottom-bar'),
                  valueListenable: _contextualChrome,
                  builder: (context, suppressed, child) => suppressed
                      ? const SizedBox.shrink()
                      : _CompactNavigationBar(
                          visibility: _navVisibility,
                          child: child!,
                        ),
                  child: naviBarBody,
                )
              : const SizedBox.shrink(key: ValueKey('bottom-bar-hidden')),
        ),
      ),
    );
    if (windowControlLayout != null) {
      return _WindowControlLayoutOwner(
        horizontalAvoidance: windowControlLayout.horizontalAvoidance,
        verticalAvoidance: windowControlLayout.verticalAvoidance,
        horizontalSafeAreaAvoidance:
            windowControlLayout.horizontalSafeAreaAvoidance,
        verticalSafeAreaAvoidance:
            windowControlLayout.verticalSafeAreaAvoidance,
        effectiveCornerRadii: windowControlLayout.effectiveCornerRadii,
        railOwnsAvoidance: !compact,
        child: shell,
      );
    }
    return AdaptiveWindowControlLayout(
      child: Builder(
        builder: (context) {
          final layout = AdaptiveWindowControlLayoutScope.maybeOf(context)!;
          return _WindowControlLayoutOwner(
            horizontalAvoidance: layout.horizontalAvoidance,
            verticalAvoidance: layout.verticalAvoidance,
            horizontalSafeAreaAvoidance: layout.horizontalSafeAreaAvoidance,
            verticalSafeAreaAvoidance: layout.verticalSafeAreaAvoidance,
            effectiveCornerRadii: layout.effectiveCornerRadii,
            railOwnsAvoidance: !compact,
            child: shell,
          );
        },
      ),
    );
  }
}

class _WindowControlLayoutOwner extends StatelessWidget {
  const _WindowControlLayoutOwner({
    required this.horizontalAvoidance,
    required this.verticalAvoidance,
    required this.horizontalSafeAreaAvoidance,
    required this.verticalSafeAreaAvoidance,
    required this.effectiveCornerRadii,
    required this.railOwnsAvoidance,
    required this.child,
  });

  final EdgeInsetsDirectional horizontalAvoidance;
  final EdgeInsetsDirectional verticalAvoidance;
  final EdgeInsetsDirectional? horizontalSafeAreaAvoidance;
  final EdgeInsetsDirectional? verticalSafeAreaAvoidance;
  final BorderRadius? effectiveCornerRadii;
  final bool railOwnsAvoidance;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveWindowControlLayoutScope(
      horizontalAvoidance: horizontalAvoidance,
      verticalAvoidance: verticalAvoidance,
      horizontalSafeAreaAvoidance: horizontalSafeAreaAvoidance,
      verticalSafeAreaAvoidance: verticalSafeAreaAvoidance,
      effectiveCornerRadii: effectiveCornerRadii,
      owner: railOwnsAvoidance
          ? WindowControlLayoutOwner.rail
          : WindowControlLayoutOwner.appBar,
      child: child,
    );
  }
}

/// Shell body below the root [Scaffold].
///
/// Its build context sees the padding injected by [Scaffold.extendBody], then
/// restores the ambient padding and view padding captured above the Scaffold
/// so branch pages do not reserve the compact navigation height twice and
/// nested Scaffolds still keep floating widgets above system insets.
class _NavigationShellBody extends StatelessWidget {
  const _NavigationShellBody({
    required this.ambientPadding,
    required this.ambientViewPadding,
    required this.form,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.railExtent,
    required this.child,
  });

  final EdgeInsets ambientPadding;
  final EdgeInsets ambientViewPadding;
  final _ShellForm form;
  final int selectedIndex;
  final List<AdaptiveNavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final NavigationRailExtent railExtent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(padding: ambientPadding, viewPadding: ambientViewPadding),
      child: ColoredBox(
        // Opaque backdrop behind the branch content: the bar is translucent
        // and overlays it, so without this the window background would show
        // through the fading bar.
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Leading chrome in non-compact forms; the panel animates its
            // width when the form switches.
            _NavigationRailRegion(
              form: form,
              selectedIndex: selectedIndex,
              destinations: destinations,
              onDestinationSelected: onDestinationSelected,
              railExtent: railExtent,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Compact navigation chrome animated according to [visibility].
class _CompactNavigationBar extends StatelessWidget {
  const _CompactNavigationBar({required this.visibility, required this.child});

  final ValueListenable<bool> visibility;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: visibility,
      builder: (context, visible, child) => TweenAnimationBuilder<double>(
        duration: _animationDuration,
        curve: Curves.easeOut,
        tween: Tween<double>(begin: visible ? 1 : 0, end: visible ? 1 : 0),
        builder: (context, factor, child) => ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: factor,
            child: Opacity(opacity: factor, child: child),
          ),
        ),
        child: child,
      ),
      child: child,
    );
  }
}

/// Medium+ chrome region of the shell: a collapsible rail panel whose width
/// follows the window and can be dragged at its trailing edge.
///
/// Owns the rail's local state (extended, manual width, dragging) so the
/// shell stays free of expand/collapse mechanics. Always mounted: in the
/// compact form it builds a zero-width box, which keeps the manual width
/// across compact round-trips. The extended state resets to the form
/// default whenever the form changes.
class _NavigationRailRegion extends StatefulWidget {
  const _NavigationRailRegion({
    required this.form,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.railExtent,
  });

  final _ShellForm form;
  final int selectedIndex;
  final List<AdaptiveNavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final NavigationRailExtent railExtent;

  @override
  State<_NavigationRailRegion> createState() => _NavigationRailRegionState();
}

class _NavigationRailRegionState extends State<_NavigationRailRegion> {
  static const double _minimumRailButtonExtent = 44.0;

  /// Whether the rail is extended.
  ///
  /// Initialized from the form's default and toggled by the rail's leading
  /// button; reset to the form default whenever the form changes.
  bool _extended = false;

  /// Manual rail width from the last drag.
  ///
  /// Persists for the region's lifetime; the system never rewrites it. The
  /// effective width hands off to the automatic width continuously when the
  /// window shrinks (see [_manualAboveAuto]), so the value resumes once the
  /// window grows back.
  double? _manualWidth;

  /// Whether [_manualWidth] was dragged above the auto value at its window
  /// width; picks the handoff direction when the window shrinks.
  bool _manualAboveAuto = false;

  /// Accumulated rail width during a drag; assigned to [_manualWidth] on
  /// every update.
  double _dragCurrentWidth = 0.0;

  /// Whether a rail resize drag is in progress (disables width animation).
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _extended = widget.form == _ShellForm.railExtended;
  }

  @override
  void didUpdateWidget(covariant _NavigationRailRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.form == widget.form) return;
    _extended = widget.form == _ShellForm.railExtended;
  }

  /// Auto rail width at [windowWidth], resolved by the configured extent.
  double _railAutoWidth(double windowWidth) =>
      widget.railExtent.resolve(windowWidth);

  /// Effective extended rail width at [windowWidth].
  ///
  /// A manual value dragged below the auto value holds until the auto value
  /// drops to it and then follows the auto value; a manual value dragged
  /// above the auto value holds while it fits the interval and then follows
  /// the interval's upper bound. Both handoffs are continuous, so the rail
  /// never jumps while the window resizes.
  double _effectiveRailWidth(double windowWidth) {
    final manual = _manualWidth;
    if (manual == null) return _railAutoWidth(windowWidth);
    final bound = _manualAboveAuto
        ? widget.railExtent.upperBoundAt(windowWidth)
        : _railAutoWidth(windowWidth);
    return math.min(manual, bound);
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.sizeOf(context).width;
    return AnimatedSize(
      // A zero duration would crash RenderAnimatedSize: its controller
      // listener calls markNeedsLayout and forward(from: 0) notifies
      // synchronously under zero duration. 1ms keeps the async tick path,
      // so drags stay frame-synced and resize animations keep running.
      duration: _dragging
          ? const Duration(milliseconds: 1)
          : _animationDuration,
      curve: Curves.easeOut,
      alignment: Alignment.centerLeft,
      clipBehavior: Clip.hardEdge,
      child: switch (widget.form) {
        _ShellForm.bar => const SizedBox(width: 0),
        _ShellForm.railCollapsed || _ShellForm.railExtended => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRail(context, windowWidth),
            // Divider between the rail and the branch content, matching
            // the NavigationDrawer sample layout.
            const VerticalDivider(width: 1),
          ],
        ),
      },
    );
  }

  /// Collapsible rail with a trailing drag handle.
  ///
  /// The extended width follows the auto value unless a manual value
  /// applies (inside the current interval); collapsed keeps the fixed
  /// icon-rail width.
  Widget _buildRail(BuildContext context, double windowWidth) {
    final width = _extended
        ? _effectiveRailWidth(windowWidth)
        : widget.railExtent.collapsed;
    final horizontalAvoidance =
        AdaptiveWindowControlLayoutScope.railHorizontalAvoidanceOf(context);
    final verticalAvoidance =
        AdaptiveWindowControlLayoutScope.railVerticalAvoidanceOf(context);
    final safeWidth =
        width - horizontalAvoidance.start - horizontalAvoidance.end;
    final useVerticalFallback =
        !_extended && safeWidth < _minimumRailButtonExtent;
    final leadingHorizontalAvoidance = useVerticalFallback
        ? EdgeInsetsDirectional.zero
        : horizontalAvoidance;
    final leadingTopAvoidance = useVerticalFallback
        ? verticalAvoidance.top
        : 0.0;

    return Stack(
      children: [
        AdaptiveNavigationRail(
          key: const ValueKey('rail-panel'),
          selectedIndex: widget.selectedIndex,
          onDestinationSelected: widget.onDestinationSelected,
          extended: _extended,
          minWidth: widget.railExtent.collapsed,
          minExtendedWidth: width,
          leading: SizedBox(
            width: width,
            child: Padding(
              key: const ValueKey('rail-leading-safe-span'),
              padding: EdgeInsetsDirectional.only(
                start: leadingHorizontalAvoidance.start,
                top: leadingTopAvoidance,
                end: leadingHorizontalAvoidance.end,
              ),
              child: Align(
                child: IconButton(
                  key: const ValueKey('rail-toggle-button'),
                  tooltip: _extended
                      ? 'Collapse navigation rail'
                      : 'Expand navigation rail',
                  icon: Icon(_extended ? Icons.menu_open : Icons.menu),
                  onPressed: () => setState(() => _extended = !_extended),
                ),
              ),
            ),
          ),
          destinations: widget.destinations,
        ),
        if (_extended)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _buildResizeHandle(windowWidth),
          ),
      ],
    );
  }

  /// Trailing drag handle that resizes the extended rail within the
  /// effective interval.
  Widget _buildResizeHandle(double windowWidth) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        key: const ValueKey('rail-resize-handle'),
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (details) {
          setState(() {
            _dragging = true;
            _dragCurrentWidth = _effectiveRailWidth(windowWidth);
          });
        },
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragCurrentWidth = widget.railExtent.clamp(
              _dragCurrentWidth + details.delta.dx,
              windowWidth: windowWidth,
            );
            _manualWidth = _dragCurrentWidth;
            _manualAboveAuto = _dragCurrentWidth > _railAutoWidth(windowWidth);
          });
        },
        onHorizontalDragEnd: (_) => setState(() => _dragging = false),
        onHorizontalDragCancel: () => setState(() => _dragging = false),
        child: const SizedBox(width: 8, height: double.infinity),
      ),
    );
  }
}
