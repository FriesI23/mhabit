import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../adaptive/adaptive_navigation_destination.dart';
import 'cupertino_floating_surface.dart';
import 'cupertino_navigation_primary_action.dart';

/// Visible presentation of an Apple compact navigation bar.
///
/// Hidden chrome is expressed by the shell not laying out the bar.
///
/// ```text
/// expanded   [ Home | Stats | Settings ]   [ + ]
/// minimized  [ Home ]                      [ + ]
/// ```
enum AdaptiveNavigationBarPresentation {
  /// Displays every destination in the navigation surface.
  expanded,

  /// Displays only the selected destination until expansion is requested.
  minimized,
}

/// Apple-only visual configuration for `AdaptiveNavigationBar` and the
/// Cupertino navigation shell.
class AppleNavigationBarStyle {
  /// Creates Apple navigation-bar styling.
  ///
  /// A null or infinite [expandedNavigationWidth] uses all available width.
  ///
  /// ```text
  /// [<-- expandedNavigationWidth -->] gap [action]
  /// ============================================= screen bottom
  ///            floatingBottomMargin
  /// ```
  const AppleNavigationBarStyle({
    this.expandedNavigationWidth,
    this.floatingBottomMargin,
  }) : assert(expandedNavigationWidth == null || expandedNavigationWidth > 0),
       assert(
         floatingBottomMargin == null ||
             (floatingBottomMargin >= 0 &&
                 floatingBottomMargin < double.infinity),
       );

  /// Preferred width of the expanded destination surface.
  ///
  /// A null or infinite value fills the space available before the trailing
  /// action boundary. A finite value is clamped when less space is available,
  /// while any remaining space stays flexible.
  final double? expandedNavigationWidth;

  /// Overrides the distance between the floating surfaces and the bottom.
  ///
  /// When null, the renderer combines UIKit's reported boundary geometry with
  /// Flutter's bottom view padding and its visual baseline. Values must be
  /// finite and non-negative; values smaller than the renderer's minimum
  /// surface margin are clamped.
  final double? floatingBottomMargin;
}

/// An Apple-styled bottom bar for compact top-level navigation.
///
/// The bar renders [destinations] in a leading floating surface and can render
/// [primaryAction] in an independent trailing surface. In the
/// [AdaptiveNavigationBarPresentation.expanded] presentation, every
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
  /// Height of the floating navigation surface, excluding its bottom margin.
  static const double contentHeight = 50.0;
  static const double _minimumTapExtent = 44.0;
  static const double _minimizedSurfaceExtent = _minimumTapExtent;
  static const double _surfaceGap = 8.0;
  static const double _iconSize = 24.0;
  static const double _labelBottomPadding = 3.0;
  static const Duration _transitionDuration = Duration(milliseconds: 250);

  /// Returns the stable outer height required by the floating bar.
  ///
  /// The result includes the resolved floating margin. A non-null
  /// [floatingBottomMargin] overrides the platform geometry; otherwise the
  /// renderer combines its visual baseline with UIKit's corner-adaptation
  /// avoidance and falls back to Flutter's bottom view padding.
  static double heightOf(BuildContext context, {double? floatingBottomMargin}) {
    final geometry = CupertinoFloatingSurfaceGeometry.resolveOf(
      context,
      floatingBottomMargin: floatingBottomMargin,
    );
    return contentHeight + geometry.floatingMargin;
  }

  /// Creates an Apple-styled compact navigation bar.
  ///
  /// [selectedIndex] identifies the current entry in [destinations].
  /// [onDestinationSelected] is called for expanded tap and drag selections,
  /// while [onExpandRequested] is reserved for the minimized selected item.
  /// A null or infinite [expandedNavigationWidth] fills the width available
  /// before the optional trailing action; a finite value is clamped to fit.
  /// A null [floatingBottomMargin] combines the visual baseline with UIKit's
  /// corner-adaptation avoidance, then falls back to Flutter geometry.
  const CupertinoAdaptiveNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onExpandRequested,
    required this.destinations,
    required this.presentation,
    this.primaryAction,
    this.reservePrimaryActionSpace = false,
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

  /// Optional page action rendered in the independent trailing surface.
  final CupertinoNavigationPrimaryAction? primaryAction;

  /// Whether layout should leave the trailing action gap to an external host.
  final bool reservePrimaryActionSpace;

  /// Preferred width of the expanded destination surface.
  ///
  /// A null or infinite value fills the available width before the trailing
  /// action. A finite value is clamped when less space is available.
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
    final boundaryInsets = CupertinoFloatingSurfaceGeometry.resolveOf(
      context,
      floatingBottomMargin: floatingBottomMargin,
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
          primaryAction: primaryAction,
          reservePrimaryActionSpace: reservePrimaryActionSpace,
          expandedNavigationWidth: expandedNavigationWidth,
          duration: duration,
        ),
      ),
    );
  }
}

class _NavigationBarLayout extends StatelessWidget {
  const _NavigationBarLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onExpandRequested,
    required this.destinations,
    required this.presentation,
    required this.primaryAction,
    required this.reservePrimaryActionSpace,
    required this.expandedNavigationWidth,
    required this.duration,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onExpandRequested;
  final List<AdaptiveNavigationDestination> destinations;
  final AdaptiveNavigationBarPresentation presentation;
  final CupertinoNavigationPrimaryAction? primaryAction;
  final bool reservePrimaryActionSpace;
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
            final hasTrailingAction =
                primaryAction != null || reservePrimaryActionSpace;
            final maximumNavigationExtent = math.max(
              CupertinoAdaptiveNavigationBar._minimizedSurfaceExtent,
              constraints.maxWidth -
                  (hasTrailingAction
                      ? CupertinoAdaptiveNavigationBar.contentHeight +
                            CupertinoAdaptiveNavigationBar._surfaceGap
                      : 0),
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
                    primaryAction: primaryAction,
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
    required this.primaryAction,
    required this.presentationProgress,
    required this.expandedNavigationWidth,
    required this.duration,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onExpandRequested;
  final List<AdaptiveNavigationDestination> destinations;
  final AdaptiveNavigationBarPresentation presentation;
  final CupertinoNavigationPrimaryAction? primaryAction;
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
          child: CupertinoFloatingGlassSurface(
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
        if (primaryAction != null)
          PositionedDirectional(
            key: const ValueKey('cupertino-primary-action-slot'),
            end: 0,
            bottom: 0,
            width: surfaceHeight,
            height: surfaceHeight,
            child: CupertinoNavigationPrimaryActionButton(
              action: primaryAction!,
              extent: surfaceHeight,
            ),
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
