import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../adaptive/adaptive_navigation_destination.dart';

/// A Material 3 wide-navigation-rail destination button.
///
/// This remains internal to the Material rail renderer until Flutter exposes a
/// wide rail destination with the same collapsed-to-expanded motion.
class MaterialWideNavigationRailButton extends StatelessWidget {
  const MaterialWideNavigationRailButton({
    super.key,
    required this.slotKey,
    required this.buttonKey,
    required this.animation,
    required this.collapsedRailWidth,
    required this.expandedRailWidth,
    required this.destination,
    required this.selected,
    required this.onPressed,
  });

  static const double _slotHeight = 64.0;
  static const double _buttonHeight = 56.0;
  static const double _iconSize = 24.0;
  static const double _collapsedButtonWidth = 56.0;
  static const double _collapsedIndicatorHeight = 32.0;
  static const double _expandedHorizontalMargin = 20.0;
  static const double _expandedContentInset = 16.0;
  static const double _expandedIconLabelSpacing = 8.0;

  final Key slotKey;
  final Key buttonKey;
  final Animation<double> animation;
  final double collapsedRailWidth;
  final double expandedRailWidth;
  final AdaptiveNavigationDestination destination;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        final slotWidth = lerpDouble(
          collapsedRailWidth,
          expandedRailWidth,
          progress,
        )!;
        final buttonWidth = lerpDouble(
          _collapsedButtonWidth,
          expandedRailWidth - _expandedHorizontalMargin * 2,
          progress,
        )!;
        final buttonHeight = lerpDouble(
          _collapsedIndicatorHeight,
          _buttonHeight,
          progress,
        )!;
        return SizedBox(
          key: slotKey,
          width: slotWidth,
          height: _slotHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: _MaterialWideNavigationRailButtonSurface(
                  buttonKey: buttonKey,
                  destination: destination,
                  selected: selected,
                  progress: progress,
                  onPressed: onPressed,
                ),
              ),
              PositionedDirectional(
                start: (slotWidth - _collapsedButtonWidth) / 2,
                top: 48,
                width: _collapsedButtonWidth,
                child: ExcludeSemantics(
                  child: Opacity(
                    key: const ValueKey('material-rail-collapsed-label'),
                    opacity: 1 - progress,
                    child: _MaterialWideNavigationRailLabel(
                      destination: destination,
                      selected: selected,
                      expanded: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MaterialWideNavigationRailButtonSurface extends StatelessWidget {
  const _MaterialWideNavigationRailButtonSurface({
    required this.buttonKey,
    required this.destination,
    required this.selected,
    required this.progress,
    required this.onPressed,
  });

  final Key buttonKey;
  final AdaptiveNavigationDestination destination;
  final bool selected;
  final double progress;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final railTheme = NavigationRailTheme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedIconTheme =
        railTheme.selectedIconTheme ??
        IconThemeData(
          color: colorScheme.onSecondaryContainer,
          size: MaterialWideNavigationRailButton._iconSize,
        );
    final unselectedIconTheme =
        railTheme.unselectedIconTheme ??
        IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: MaterialWideNavigationRailButton._iconSize,
        );
    final indicatorColor =
        railTheme.indicatorColor ?? colorScheme.secondaryContainer;
    final indicatorShape = railTheme.indicatorShape ?? const StadiumBorder();
    final iconStart = lerpDouble(
      (MaterialWideNavigationRailButton._collapsedButtonWidth -
              MaterialWideNavigationRailButton._iconSize) /
          2,
      MaterialWideNavigationRailButton._expandedContentInset,
      progress,
    )!;
    final iconTop = lerpDouble(4, 16, progress)!;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.effectiveSemanticsLabel,
      excludeSemantics: true,
      onTap: onPressed,
      child: TextButton(
        key: buttonKey,
        onPressed: onPressed,
        style: const ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
          minimumSize: WidgetStatePropertyAll(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: WidgetStatePropertyAll(StadiumBorder()),
        ),
        child: Stack(
          children: [
            _MaterialWideNavigationRailIndicator(
              selected: selected,
              color: indicatorColor,
              shape: indicatorShape,
            ),
            PositionedDirectional(
              start: iconStart,
              top: iconTop,
              width: MaterialWideNavigationRailButton._iconSize,
              height: MaterialWideNavigationRailButton._iconSize,
              child: _MaterialWideNavigationRailIcon(
                destination: destination,
                selected: selected,
                selectedTheme: selectedIconTheme,
                unselectedTheme: unselectedIconTheme,
              ),
            ),
            PositionedDirectional(
              start:
                  MaterialWideNavigationRailButton._expandedContentInset +
                  MaterialWideNavigationRailButton._iconSize +
                  MaterialWideNavigationRailButton._expandedIconLabelSpacing,
              end: MaterialWideNavigationRailButton._expandedContentInset,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Opacity(
                  key: const ValueKey('material-rail-expanded-label'),
                  opacity: progress,
                  child: _MaterialWideNavigationRailLabel(
                    destination: destination,
                    selected: selected,
                    expanded: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialWideNavigationRailIndicator extends StatelessWidget {
  const _MaterialWideNavigationRailIndicator({
    required this.selected,
    required this.color,
    required this.shape,
  });

  final bool selected;
  final Color color;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        key: const ValueKey('material-rail-indicator'),
        width: double.infinity,
        height: double.infinity,
        child: AnimatedOpacity(
          opacity: selected ? 1 : 0,
          duration: kThemeAnimationDuration,
          curve: Curves.easeInOut,
          child: DecoratedBox(
            decoration: ShapeDecoration(color: color, shape: shape),
          ),
        ),
      ),
    );
  }
}

class _MaterialWideNavigationRailIcon extends StatelessWidget {
  const _MaterialWideNavigationRailIcon({
    required this.destination,
    required this.selected,
    required this.selectedTheme,
    required this.unselectedTheme,
  });

  final AdaptiveNavigationDestination destination;
  final bool selected;
  final IconThemeData selectedTheme;
  final IconThemeData unselectedTheme;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: IconTheme(
        key: ValueKey(selected),
        data: selected ? selectedTheme : unselectedTheme,
        child: selected
            ? destination.icons.materialSelected
            : destination.icons.material,
      ),
    );
  }
}

class _MaterialWideNavigationRailLabel extends StatelessWidget {
  const _MaterialWideNavigationRailLabel({
    required this.destination,
    required this.selected,
    required this.expanded,
  });

  final AdaptiveNavigationDestination destination;
  final bool selected;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final railTheme = NavigationRailTheme.of(context);
    final baseStyle = expanded
        ? theme.textTheme.labelLarge
        : theme.textTheme.labelMedium;
    final style = (baseStyle ?? const TextStyle())
        .merge(
          selected
              ? railTheme.selectedLabelTextStyle
              : railTheme.unselectedLabelTextStyle,
        )
        .copyWith(
          color: selected
              ? theme.colorScheme.secondary
              : theme.colorScheme.onSurfaceVariant,
        );
    return Text(
      destination.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: expanded ? null : TextAlign.center,
      style: style,
    );
  }
}
