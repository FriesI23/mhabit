import 'package:flutter/cupertino.dart';

import '../adaptive/adaptive_navigation_destination.dart';
import '../shell/navigation_shell_frame.dart';
import 'cupertino_floating_surface.dart';

/// Floating surface and destination presentation for a Cupertino Sidebar.
///
/// Visibility, animation, width policy, focus transfer, and toggle ownership
/// remain responsibilities of the Sidebar host.
class CupertinoNavigationSidebarPanel extends StatelessWidget {
  static const double _toolbarHeight = 44;
  static const double _destinationTopGap = 24;
  static const double _resizeHandleWidth = 16;
  static const double _resizeHandleCornerInset = 25;

  const CupertinoNavigationSidebarPanel({
    super.key,
    required this.width,
    required this.contentActive,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.dragging,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
  });

  final double width;
  final bool contentActive;
  final int selectedIndex;
  final List<AdaptiveNavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final bool dragging;
  final VoidCallback onResizeStart;
  final ValueChanged<double> onResizeUpdate;
  final VoidCallback onResizeEnd;

  @override
  Widget build(BuildContext context) {
    const toolbarLayer = Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: _toolbarHeight,
      child: IgnorePointer(
        child: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          transitionBetweenRoutes: false,
          automaticBackgroundVisibility: false,
          backgroundColor: CupertinoColors.transparent,
          border: null,
        ),
      ),
    );

    final direction = Directionality.of(context);

    final destinationList = ListView.builder(
      key: const ValueKey('cupertino-sidebar-destination-list'),
      padding: const EdgeInsets.only(
        top: _toolbarHeight + _destinationTopGap,
        bottom: 8,
      ),
      itemCount: destinations.length,
      itemBuilder: (context, index) => _CupertinoSidebarDestination(
        key: ValueKey('cupertino-sidebar-destination-$index'),
        destination: destinations[index],
        selected: selectedIndex == index,
        onPressed: () => onDestinationSelected(index),
      ),
    );
    final destinationContent = ExcludeSemantics(
      excluding: !contentActive,
      child: destinationList,
    );
    final destinationLayer = Positioned.fill(
      child: IgnorePointer(ignoring: !contentActive, child: destinationContent),
    );

    final surface = CupertinoFloatingGlassSurface(
      key: const ValueKey('cupertino-sidebar-surface'),
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: Stack(
        fit: StackFit.expand,
        children: [destinationLayer, toolbarLayer],
      ),
    );

    final resizeHandleTarget = GestureDetector(
      key: const ValueKey('cupertino-sidebar-resize-handle'),
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => onResizeStart(),
      onHorizontalDragUpdate: (details) {
        final logicalDelta = direction == TextDirection.ltr
            ? details.delta.dx
            : -details.delta.dx;
        onResizeUpdate(logicalDelta);
      },
      onHorizontalDragEnd: (_) => onResizeEnd(),
      onHorizontalDragCancel: onResizeEnd,
      child: const SizedBox(width: _resizeHandleWidth, height: double.infinity),
    );
    final resizeHandle = PositionedDirectional(
      end: 0,
      top: _resizeHandleCornerInset,
      bottom: _resizeHandleCornerInset,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: IgnorePointer(
          ignoring: !contentActive,
          child: resizeHandleTarget,
        ),
      ),
    );

    final panel = SizedBox(
      key: const ValueKey('cupertino-sidebar-panel'),
      width: width,
      height: double.infinity,
      child: Stack(fit: StackFit.expand, children: [surface, resizeHandle]),
    );

    return AnimatedSize(
      duration: dragging
          ? const Duration(milliseconds: 1)
          : navigationShellAnimationDuration,
      curve: Curves.easeOut,
      alignment: AlignmentDirectional.centerStart,
      child: panel,
    );
  }
}

class _CupertinoSidebarDestination extends StatelessWidget {
  const _CupertinoSidebarDestination({
    super.key,
    required this.destination,
    required this.selected,
    required this.onPressed,
  });

  final AdaptiveNavigationDestination destination;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    final labelColor = CupertinoDynamicColor.resolve(
      CupertinoColors.label,
      context,
    );

    final foregroundColor = (selected ? primaryColor : labelColor).withValues(
      alpha: 1,
    );
    final icon = selected
        ? destination.icons.appleSelected
        : destination.icons.apple;

    final label = Expanded(
      child: Text(
        destination.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final button = CupertinoButton(
      sizeStyle: CupertinoButtonSize.medium,
      minimumSize: const Size(0, 44),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      alignment: AlignmentDirectional.centerStart,
      color: selected ? primaryColor.withValues(alpha: 0.14) : null,
      foregroundColor: foregroundColor,
      autofocus: selected,
      onPressed: onPressed,
      child: Row(children: [icon, const SizedBox(width: 12), label]),
    );
    final paddedButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: SizedBox(width: double.infinity, child: button),
    );

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: destination.effectiveSemanticsLabel,
      excludeSemantics: true,
      child: paddedButton,
    );
  }
}
