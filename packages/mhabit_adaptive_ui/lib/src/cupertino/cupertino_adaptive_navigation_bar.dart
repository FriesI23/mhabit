import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, immutable, kIsWeb;

import '../adaptive/adaptive_navigation_bar_presentation.dart';
import '../adaptive/adaptive_navigation_destination.dart';
import '../window_control/window_control_layout.dart';

/// An Apple-styled bottom bar for compact top-level navigation.
///
/// The bar renders [destinations] in a leading floating surface and reserves a
/// separate, non-interactive trailing surface for a future primary action. In
/// the [AdaptiveNavigationBarPresentation.expanded] presentation, every
/// destination is visible and users can either tap a destination or drag
/// horizontally across the surface before releasing to select one. In the
/// [AdaptiveNavigationBarPresentation.minimized] presentation, only the
/// selected destination remains visible and tapping it calls
/// [onExpandRequested].
///
/// The rendered height is [contentHeight] plus enough bottom spacing for both
/// [MediaQueryData.viewPadding] and the floating surface margin. Presentation
/// changes animate within that stable outer envelope and honor
/// [MediaQueryData.disableAnimations]. Changes to the available width are
/// applied immediately so window resizing stays in sync with its parent
/// layout.
///
/// Most callers should use `AdaptiveNavigationBar.apple` or
/// `AdaptiveNavigationShell` instead of constructing this renderer directly.
class CupertinoAdaptiveNavigationBar extends StatelessWidget {
  static const double contentHeight = 50.0;
  static const double _minimumTapExtent = 44.0;
  static const double _minimizedSurfaceExtent = _minimumTapExtent;
  static const double _surfaceGap = 8.0;
  static const double _surfaceRadius = contentHeight / 2;
  static const double _iconSize = 24.0;
  static const double _labelBottomPadding = 3.0;
  static const double _blurSigma = 10.0;
  static const Duration _transitionDuration = Duration(milliseconds: 250);

  /// Returns the stable outer height required by the floating bar.
  ///
  /// The result includes the resolved floating margin. A non-null
  /// [floatingBottomMargin] overrides the platform geometry; otherwise the
  /// renderer combines its visual baseline with UIKit's corner-adaptation
  /// avoidance and falls back to Flutter's bottom view padding.
  static double heightOf(BuildContext context, {double? floatingBottomMargin}) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final safeAreaGeometry =
        AdaptiveWindowControlLayoutScope.safeAreaGeometryOf(context);
    final verticalSafeAreaAvoidance = safeAreaGeometry?.verticalAvoidance
        .resolve(Directionality.of(context));
    final resolvedFloatingMargin =
        _NavigationBarBoundaryInsets.floatingMarginFor(
          viewPadding: viewPadding,
          verticalSafeAreaAvoidance: verticalSafeAreaAvoidance,
          configuredMargin: floatingBottomMargin,
        );
    return contentHeight + resolvedFloatingMargin;
  }

  /// Creates an Apple-styled compact navigation bar.
  ///
  /// [selectedIndex] identifies the current entry in [destinations].
  /// [onDestinationSelected] is called for expanded tap and drag selections,
  /// while [onExpandRequested] is reserved for the minimized selected item.
  /// A null or infinite [expandedNavigationWidth] fills the width available
  /// before the trailing placeholder; a finite value is clamped to fit.
  /// A null [floatingBottomMargin] combines the visual baseline with UIKit's
  /// corner-adaptation avoidance, then falls back to Flutter geometry.
  const CupertinoAdaptiveNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onExpandRequested,
    required this.destinations,
    required this.presentation,
    required this.expandedNavigationWidth,
    this.floatingBottomMargin,
  }) : assert(
         floatingBottomMargin == null ||
             (floatingBottomMargin >= 0 &&
                 floatingBottomMargin < double.infinity),
       );

  /// The zero-based index of the selected destination.
  final int selectedIndex;

  /// Called with a destination index selected from the expanded surface.
  final ValueChanged<int> onDestinationSelected;

  /// Called when the selected destination is tapped while minimized.
  final VoidCallback onExpandRequested;

  /// The top-level destinations displayed by the leading surface.
  final List<AdaptiveNavigationDestination> destinations;

  /// Whether the navigation surface displays every destination or only the
  /// selected destination.
  final AdaptiveNavigationBarPresentation presentation;

  /// Preferred width of the expanded destination surface.
  ///
  /// A null or infinite value fills the available width before the trailing
  /// placeholder. A finite value is clamped when less space is available.
  final double? expandedNavigationWidth;

  /// Overrides the distance between the floating surfaces and the bottom.
  ///
  /// Values must be finite and non-negative; values smaller than the
  /// renderer's minimum surface margin are clamped.
  final double? floatingBottomMargin;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final duration = disableAnimations ? Duration.zero : _transitionDuration;
    final directionality = Directionality.of(context);
    final safeAreaGeometry =
        AdaptiveWindowControlLayoutScope.safeAreaGeometryOf(context);
    final verticalSafeAreaAvoidance = safeAreaGeometry?.verticalAvoidance
        .resolve(directionality);
    final boundaryInsets = _NavigationBarBoundaryInsets.resolve(
      viewPadding: MediaQuery.viewPaddingOf(context),
      verticalSafeAreaAvoidance: verticalSafeAreaAvoidance,
      effectiveCornerRadii: safeAreaGeometry?.effectiveCornerRadii,
      floatingBottomMargin: floatingBottomMargin,
      displayCornerRadii: MediaQuery.displayCornerRadiiOf(context),
    );

    return SizedBox(
      key: const ValueKey('cupertino-adaptive-navigation-bar'),
      height: contentHeight + boundaryInsets.floatingMargin,
      child: Padding(
        padding: boundaryInsets.horizontalPadding,
        child: _NavigationBarLayout(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          onExpandRequested: onExpandRequested,
          destinations: destinations,
          presentation: presentation,
          expandedNavigationWidth: expandedNavigationWidth,
          duration: duration,
        ),
      ),
    );
  }
}

@immutable
class _NavigationBarBoundaryInsets {
  const _NavigationBarBoundaryInsets({
    required this.horizontalPadding,
    required this.floatingMargin,
  });

  static const double _minimumHorizontalMargin = 12.0;
  static const double _minimumSurfaceMargin = 8.0;
  static const double _fallbackMaximumFloatingMargin = 28.0;
  // Xcode's 3x iPhone 16 Pro and Pro Max framebuffer masks both resolve to
  // approximately 62.5pt. Round up for a conservative pre-iOS 26 fallback.
  static const BorderRadius _legacyIosFallbackCornerRadii = BorderRadius.only(
    bottomLeft: Radius.circular(63.0),
    bottomRight: Radius.circular(63.0),
  );

  final EdgeInsets horizontalPadding;
  final double floatingMargin;

  static _NavigationBarBoundaryInsets resolve({
    required EdgeInsets viewPadding,
    required EdgeInsets? verticalSafeAreaAvoidance,
    required BorderRadius? effectiveCornerRadii,
    required double? floatingBottomMargin,
    required BorderRadius? displayCornerRadii,
  }) {
    final floatingMargin = floatingMarginFor(
      viewPadding: viewPadding,
      verticalSafeAreaAvoidance: verticalSafeAreaAvoidance,
      configuredMargin: floatingBottomMargin,
    );
    final cornerRadii =
        effectiveCornerRadii ??
        displayCornerRadii ??
        ((!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
            ? _legacyIosFallbackCornerRadii
            : null);
    // UIKit's horizontal safe-area adaptation is edge-wide and may include
    // top window controls on iPad. Bottom chrome instead derives its local
    // horizontal boundary from the two physical bottom corner radii.
    final (leftMargin, rightMargin) = cornerRadii == null
        ? _fallbackHorizontalMargins(floatingMargin)
        : _reportedCornerHorizontalMargins(
            radii: cornerRadii,
            floatingMargin: floatingMargin,
          );

    return _NavigationBarBoundaryInsets(
      horizontalPadding: EdgeInsets.only(left: leftMargin, right: rightMargin),
      floatingMargin: floatingMargin,
    );
  }

  static double floatingMarginFor({
    required EdgeInsets viewPadding,
    required EdgeInsets? verticalSafeAreaAvoidance,
    required double? configuredMargin,
  }) {
    final baselineMargin = math.max(
      _minimumSurfaceMargin,
      math.min(_fallbackMaximumFloatingMargin, viewPadding.bottom),
    );
    final requestedMargin =
        configuredMargin ??
        math.max(baselineMargin, verticalSafeAreaAvoidance?.bottom ?? 0);
    return math.max(_minimumSurfaceMargin, requestedMargin);
  }

  static (double, double) _fallbackHorizontalMargins(double floatingMargin) {
    // Without corner geometry, keep a Calendar-style visual margin derived
    // from the persistent bottom inset.
    final fallbackMargin = math.max(_minimumHorizontalMargin, floatingMargin);
    return (fallbackMargin, fallbackMargin);
  }

  static (double, double) _reportedCornerHorizontalMargins({
    required BorderRadius radii,
    required double floatingMargin,
  }) {
    final visualMargin = math.max(_minimumHorizontalMargin, floatingMargin);
    return (
      math.max(
        visualMargin,
        _horizontalInsetAt(
          radius: radii.bottomLeft,
          distanceFromBottom: floatingMargin,
        ),
      ),
      math.max(
        visualMargin,
        _horizontalInsetAt(
          radius: radii.bottomRight,
          distanceFromBottom: floatingMargin,
        ),
      ),
    );
  }

  static double _horizontalInsetAt({
    required Radius radius,
    required double distanceFromBottom,
  }) {
    if (radius.x <= 0 || radius.y <= 0 || distanceFromBottom >= radius.y) {
      return 0;
    }
    // Intersect the reported elliptical display corner with the surface's
    // bottom edge, then keep the surface outside that boundary.
    final normalizedY = (radius.y - distanceFromBottom) / radius.y;
    final normalizedX = math.sqrt(math.max(0, 1 - normalizedY * normalizedY));
    return radius.x * (1 - normalizedX);
  }
}

class _NavigationBarLayout extends StatelessWidget {
  const _NavigationBarLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onExpandRequested,
    required this.destinations,
    required this.presentation,
    required this.expandedNavigationWidth,
    required this.duration,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onExpandRequested;
  final List<AdaptiveNavigationDestination> destinations;
  final AdaptiveNavigationBarPresentation presentation;
  final double? expandedNavigationWidth;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        height: CupertinoAdaptiveNavigationBar.contentHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maximumNavigationExtent = math.max(
              CupertinoAdaptiveNavigationBar._minimizedSurfaceExtent,
              constraints.maxWidth -
                  CupertinoAdaptiveNavigationBar.contentHeight -
                  CupertinoAdaptiveNavigationBar._surfaceGap,
            );
            final expandedExtent = _resolveExpandedExtent(
              maximumNavigationExtent,
            );
            final minimized =
                presentation == AdaptiveNavigationBarPresentation.minimized;

            return TweenAnimationBuilder<double>(
              tween: Tween(end: minimized ? 1 : 0),
              duration: duration,
              curve: Curves.easeOut,
              builder: (context, presentationProgress, child) =>
                  _NavigationBarSurfaces(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                    onExpandRequested: onExpandRequested,
                    destinations: destinations,
                    presentation: presentation,
                    presentationProgress: presentationProgress,
                    expandedNavigationWidth: expandedExtent,
                    duration: duration,
                  ),
            );
          },
        ),
      ),
    );
  }

  double _resolveExpandedExtent(double maximumExtent) {
    final requestedExtent = expandedNavigationWidth;
    if (requestedExtent == null || !requestedExtent.isFinite) {
      return maximumExtent;
    }
    return math.min(requestedExtent, maximumExtent);
  }
}

class _NavigationBarSurfaces extends StatelessWidget {
  const _NavigationBarSurfaces({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onExpandRequested,
    required this.destinations,
    required this.presentation,
    required this.presentationProgress,
    required this.expandedNavigationWidth,
    required this.duration,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onExpandRequested;
  final List<AdaptiveNavigationDestination> destinations;
  final AdaptiveNavigationBarPresentation presentation;
  final double presentationProgress;
  final double expandedNavigationWidth;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    const compactExtent =
        CupertinoAdaptiveNavigationBar._minimizedSurfaceExtent;
    final navigationExtent = lerpDouble(
      expandedNavigationWidth,
      compactExtent,
      presentationProgress,
    )!;
    final surfaceHeight = lerpDouble(
      CupertinoAdaptiveNavigationBar.contentHeight,
      compactExtent,
      presentationProgress,
    )!;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        PositionedDirectional(
          key: const ValueKey('cupertino-navigation-surface'),
          start: 0,
          bottom: 0,
          width: navigationExtent,
          height: surfaceHeight,
          child: _GlassSurface(
            child: _NavigationSurfaceContent(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              onExpandRequested: onExpandRequested,
              destinations: destinations,
              presentation: presentation,
              presentationProgress: presentationProgress,
              expandedNavigationWidth: expandedNavigationWidth,
              duration: duration,
            ),
          ),
        ),
        PositionedDirectional(
          key: const ValueKey('cupertino-primary-action-placeholder'),
          end: 0,
          bottom: 0,
          width: surfaceHeight,
          height: surfaceHeight,
          child: const _PrimaryActionPlaceholder(),
        ),
      ],
    );
  }
}

class _NavigationSurfaceContent extends StatefulWidget {
  const _NavigationSurfaceContent({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onExpandRequested,
    required this.destinations,
    required this.presentation,
    required this.presentationProgress,
    required this.expandedNavigationWidth,
    required this.duration,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onExpandRequested;
  final List<AdaptiveNavigationDestination> destinations;
  final AdaptiveNavigationBarPresentation presentation;
  final double presentationProgress;
  final double expandedNavigationWidth;
  final Duration duration;

  @override
  State<_NavigationSurfaceContent> createState() =>
      _NavigationSurfaceContentState();
}

class _NavigationSurfaceContentState extends State<_NavigationSurfaceContent> {
  int? _dragPreviewIndex;
  bool _pointerCancelled = false;

  bool get _minimized =>
      widget.presentation == AdaptiveNavigationBarPresentation.minimized;

  @override
  void didUpdateWidget(covariant _NavigationSurfaceContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_minimized) _dragPreviewIndex = null;
  }

  int _destinationIndexAt(Offset localPosition) {
    final width = context.size?.width ?? widget.expandedNavigationWidth;
    final logicalX = Directionality.of(context) == TextDirection.ltr
        ? localPosition.dx
        : width - localPosition.dx;
    final destinationExtent = width / widget.destinations.length;
    return (logicalX / destinationExtent).floor().clamp(
      0,
      widget.destinations.length - 1,
    );
  }

  void _handleDragPosition(Offset localPosition) {
    final index = _destinationIndexAt(localPosition);
    if (_dragPreviewIndex == index) return;
    setState(() => _dragPreviewIndex = index);
  }

  void _handleDragEnd() {
    if (_pointerCancelled) {
      _pointerCancelled = false;
      _handleDragCancel();
      return;
    }
    final index = _dragPreviewIndex;
    if (index == null) return;
    setState(() => _dragPreviewIndex = null);
    widget.onDestinationSelected(index);
  }

  void _handleDragCancel() {
    if (_dragPreviewIndex == null) return;
    setState(() => _dragPreviewIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = CupertinoLocalizations.of(context);
    final theme = CupertinoTheme.of(context);
    final activeColor = CupertinoDynamicColor.resolve(
      theme.primaryColor,
      context,
    );
    final inactiveColor = CupertinoDynamicColor.resolve(
      CupertinoColors.inactiveGray,
      context,
    );
    final destinationExtent =
        widget.expandedNavigationWidth / widget.destinations.length;

    return Listener(
      onPointerDown: (_) => _pointerCancelled = false,
      onPointerCancel: (_) {
        _pointerCancelled = true;
        _handleDragCancel();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: _minimized
            ? null
            : (details) => _handleDragPosition(details.localPosition),
        onHorizontalDragUpdate: _minimized
            ? null
            : (details) => _handleDragPosition(details.localPosition),
        onHorizontalDragEnd: _minimized ? null : (_) => _handleDragEnd(),
        onHorizontalDragCancel: _minimized ? null : _handleDragCancel,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: KeyedSubtree(
                  key: ValueKey(
                    _minimized
                        ? 'cupertino-navigation-minimized'
                        : 'cupertino-navigation-expanded',
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            for (final (index, destination) in widget.destinations.indexed)
              _buildDestination(
                index: index,
                destination: destination,
                minimized: _minimized,
                destinationExtent: destinationExtent,
                localizations: localizations,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                labelStyle: theme.textTheme.tabLabelTextStyle,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestination({
    required int index,
    required AdaptiveNavigationDestination destination,
    required bool minimized,
    required double destinationExtent,
    required CupertinoLocalizations localizations,
    required Color activeColor,
    required Color inactiveColor,
    required TextStyle labelStyle,
  }) {
    final selected = index == widget.selectedIndex;
    final visible = !minimized || selected;
    final compactSelected = minimized && selected;
    final onTap = !visible
        ? null
        : compactSelected
        ? widget.onExpandRequested
        : () => widget.onDestinationSelected(index);

    return _NavigationDestinationSlot(
      index: index,
      destination: destination,
      semanticsHint: localizations.tabSemanticsLabel(
        tabIndex: index + 1,
        tabCount: widget.destinations.length,
      ),
      selected: selected,
      visible: visible,
      dragFocused: _dragPreviewIndex == index,
      destinationExtent: destinationExtent,
      presentationProgress: widget.presentationProgress,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      labelStyle: labelStyle,
      duration: widget.duration,
      onTap: onTap,
    );
  }
}

class _NavigationDestinationSlot extends StatelessWidget {
  const _NavigationDestinationSlot({
    required this.index,
    required this.destination,
    required this.semanticsHint,
    required this.selected,
    required this.visible,
    required this.dragFocused,
    required this.destinationExtent,
    required this.presentationProgress,
    required this.activeColor,
    required this.inactiveColor,
    required this.labelStyle,
    required this.duration,
    required this.onTap,
  });

  final int index;
  final AdaptiveNavigationDestination destination;
  final String semanticsHint;
  final bool selected;
  final bool visible;
  final bool dragFocused;
  final double destinationExtent;
  final double presentationProgress;
  final Color activeColor;
  final Color inactiveColor;
  final TextStyle labelStyle;
  final Duration duration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final expandedStart = destinationExtent * index;
    final start = selected
        ? lerpDouble(expandedStart, 0, presentationProgress)!
        : expandedStart;
    final width = selected
        ? lerpDouble(
            destinationExtent,
            CupertinoAdaptiveNavigationBar._minimizedSurfaceExtent,
            presentationProgress,
          )!
        : destinationExtent;
    final height = selected
        ? lerpDouble(
            CupertinoAdaptiveNavigationBar.contentHeight,
            CupertinoAdaptiveNavigationBar._minimizedSurfaceExtent,
            presentationProgress,
          )!
        : CupertinoAdaptiveNavigationBar.contentHeight;

    return PositionedDirectional(
      key: ValueKey('cupertino-navigation-destination-position-$index'),
      start: start,
      bottom: 0,
      width: width,
      height: height,
      child: Opacity(
        opacity: selected ? 1 : 1 - presentationProgress,
        child: _NavigationDestinationInteraction(
          index: index,
          destination: destination,
          semanticsHint: semanticsHint,
          selected: selected,
          visible: visible,
          onTap: onTap,
          child: _NavigationDestinationVisual(
            destination: destination,
            selected: selected,
            presentationProgress: presentationProgress,
            dragFocused: dragFocused,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            labelStyle: labelStyle,
            duration: duration,
          ),
        ),
      ),
    );
  }
}

class _NavigationDestinationInteraction extends StatelessWidget {
  const _NavigationDestinationInteraction({
    required this.index,
    required this.destination,
    required this.semanticsHint,
    required this.selected,
    required this.visible,
    required this.onTap,
    required this.child,
  });

  final int index;
  final AdaptiveNavigationDestination destination;
  final String semanticsHint;
  final bool selected;
  final bool visible;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TextFieldTapRegion(
      child: Semantics(
        key: ValueKey('cupertino-navigation-destination-$index'),
        label: destination.effectiveSemanticsLabel,
        hint: semanticsHint,
        selected: selected,
        button: visible,
        hidden: !visible,
        excludeSemantics: true,
        onTap: onTap,
        child: MouseRegion(
          cursor: visible && kIsWeb
              ? SystemMouseCursors.click
              : MouseCursor.defer,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: onTap,
            child: child,
          ),
        ),
      ),
    );
  }
}

// TODO: Replace this placeholder with the primary action host in Phase 3-6.
/// Reserves the renderer-owned trailing geometry for the Phase 3-6 action
/// host without exposing an action, hit target, or semantics ahead of time.
class _PrimaryActionPlaceholder extends StatelessWidget {
  const _PrimaryActionPlaceholder();

  @override
  Widget build(BuildContext context) {
    final color = CupertinoDynamicColor.resolve(
      CupertinoTheme.of(context).primaryColor,
      context,
    );
    return ExcludeSemantics(
      child: IgnorePointer(
        child: _GlassSurface(
          child: Center(
            child: Icon(
              CupertinoIcons.search,
              key: const ValueKey('cupertino-primary-action-placeholder-icon'),
              color: color,
              size: CupertinoAdaptiveNavigationBar._iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSurface extends StatelessWidget {
  const _GlassSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = CupertinoDynamicColor.resolve(
      CupertinoTheme.of(context).barBackgroundColor,
      context,
    );
    final borderRadius = BorderRadius.circular(
      CupertinoAdaptiveNavigationBar._surfaceRadius,
    );

    // Mirrors the translucent background treatment in CupertinoTabBar.build
    // from Flutter's packages/flutter/lib/src/cupertino/bottom_tab_bar.dart.
    // The rounded clipping and shadow adapt that full-width bar treatment to
    // this renderer's floating surfaces.
    Widget surface = ColoredBox(color: backgroundColor, child: child);
    if (backgroundColor.a != 1.0) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: CupertinoAdaptiveNavigationBar._blurSigma,
          sigmaY: CupertinoAdaptiveNavigationBar._blurSigma,
        ),
        child: surface,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          CupertinoAdaptiveNavigationBar._surfaceRadius,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: borderRadius, child: surface),
    );
  }
}

class _NavigationDestinationVisual extends StatelessWidget {
  const _NavigationDestinationVisual({
    required this.destination,
    required this.selected,
    required this.presentationProgress,
    required this.dragFocused,
    required this.activeColor,
    required this.inactiveColor,
    required this.labelStyle,
    required this.duration,
  });

  final AdaptiveNavigationDestination destination;
  final bool selected;
  final double presentationProgress;
  final bool dragFocused;
  final Color activeColor;
  final Color inactiveColor;
  final TextStyle labelStyle;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final color = selected || dragFocused ? activeColor : inactiveColor;
    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.lerp(
            const Alignment(0, -0.58),
            Alignment.center,
            presentationProgress,
          )!,
          child: _DestinationIconFeedback(
            color: color,
            activeColor: activeColor,
            focused: dragFocused,
            duration: duration,
            child: selected
                ? destination.icons.appleSelected
                : destination.icons.apple,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: CupertinoAdaptiveNavigationBar._labelBottomPadding,
            ),
            child: ClipRect(
              child: Opacity(
                opacity: 1 - presentationProgress,
                child: Text(
                  destination.label,
                  semanticsLabel: destination.effectiveSemanticsLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle.copyWith(color: color),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DestinationIconFeedback extends StatelessWidget {
  const _DestinationIconFeedback({
    required this.color,
    required this.activeColor,
    required this.focused,
    required this.duration,
    required this.child,
  });

  final Color color;
  final Color activeColor;
  final bool focused;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: duration,
      curve: Curves.easeOut,
      scale: focused ? 1.1 : 1,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOut,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: activeColor.withValues(alpha: focused ? 0.14 : 0),
        ),
        child: IconTheme.merge(
          data: IconThemeData(
            color: color,
            size: CupertinoAdaptiveNavigationBar._iconSize,
          ),
          child: child,
        ),
      ),
    );
  }
}
