import 'package:flutter/material.dart';

/// A controlled Material search bar that expands from a compact search button.
///
/// The widget is business agnostic: callers provide the collapsed title,
/// controller, focus node, optional trailing content, and all callbacks. It
/// requires bounded horizontal constraints so the expanded width can be
/// resolved without owning page layout state.
class MaterialExpandableSearchBar extends StatefulWidget {
  const MaterialExpandableSearchBar({
    super.key,
    required this.expanded,
    required this.isSearchActive,
    required this.collapsedTitle,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSearchActivated,
    required this.onSearchDismissed,
    this.trailing,
    this.hintText,
    this.onSubmitted,
    this.onTapOutside,
    this.height = 48.0,
    this.maxWidth = 312.0,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Easing.standard,
  });

  final bool expanded;
  final bool isSearchActive;
  final Widget collapsedTitle;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Widget? trailing;
  final String? hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onSearchActivated;
  final VoidCallback onSearchDismissed;
  final TapRegionCallback? onTapOutside;
  final double height;
  final double maxWidth;
  final Duration duration;
  final Curve curve;

  @override
  State<MaterialExpandableSearchBar> createState() =>
      _MaterialExpandableSearchBarState();
}

class _MaterialExpandableSearchBarState
    extends State<MaterialExpandableSearchBar>
    with SingleTickerProviderStateMixin {
  static const Duration _iconAnimationDuration = Duration(milliseconds: 300);

  late final AnimationController _widthController;

  @override
  void initState() {
    super.initState();
    _widthController = AnimationController(
      vsync: this,
      value: widget.expanded ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(MaterialExpandableSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded) {
      _widthController.animateTo(
        widget.expanded ? 1.0 : 0.0,
        duration: widget.duration,
        curve: widget.curve,
      );
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    super.dispose();
  }

  double _expandedWidthFor(BoxConstraints constraints) {
    final availableWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : widget.maxWidth;
    return availableWidth < widget.maxWidth ? availableWidth : widget.maxWidth;
  }

  WidgetStateProperty<Color?> _overlayColor(ColorScheme colors) =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colors.onSurfaceVariant.withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.onSurfaceVariant.withValues(alpha: 0.08);
        }
        return Colors.transparent;
      });

  Widget _buildCollapsedTitle() => Align(
    alignment: AlignmentDirectional.centerStart,
    child: ExcludeSemantics(
      excluding: widget.expanded,
      child: SingleChildScrollView(
        key: const ValueKey('collapsed-search-title-scroll'),
        scrollDirection: Axis.horizontal,
        primary: false,
        child: widget.collapsedTitle,
      ),
    ),
  );

  Widget _buildSearchBar(double width, {required bool isScrolledUnder}) {
    final colors = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return SearchBar(
      focusNode: widget.focusNode,
      controller: widget.controller,
      textInputAction: TextInputAction.search,
      overlayColor: _overlayColor(colors),
      backgroundColor: isScrolledUnder
          ? WidgetStatePropertyAll(
              brightness == Brightness.dark
                  ? colors.surfaceContainer
                  : colors.surfaceContainerLowest,
            )
          : null,
      elevation: const WidgetStatePropertyAll(0.0),
      constraints: BoxConstraints.tightFor(height: widget.height, width: width),
      hintText: widget.hintText,
      leading: AnimatedCrossFade(
        firstChild: IconButton(
          key: const ValueKey('dismiss-search'),
          onPressed: widget.onSearchDismissed,
          icon: const Icon(Icons.close),
        ),
        secondChild: IconButton(
          key: const ValueKey('activate-search'),
          onPressed: widget.onSearchActivated,
          icon: const Icon(Icons.search_outlined),
        ),
        crossFadeState: widget.isSearchActive
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: _iconAnimationDuration,
      ),
      trailing: [if (widget.trailing != null) widget.trailing!],
      onTapOutside: widget.onTapOutside,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final isScrolledUnder = settings?.isScrolledUnder ?? false;

    return LayoutBuilder(
      builder: (context, constraints) {
        final expandedWidth = _expandedWidthFor(constraints);
        final collapsedWidth = expandedWidth < widget.height
            ? expandedWidth
            : widget.height;
        return AnimatedBuilder(
          animation: _widthController,
          builder: (context, _) {
            final width =
                collapsedWidth +
                (expandedWidth - collapsedWidth) * _widthController.value;
            final showSearchBar =
                widget.expanded || _widthController.value > 0.0;
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                width: expandedWidth,
                height: widget.height,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(start: width),
                        child: _buildCollapsedTitle(),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: SizedBox(
                        key: const ValueKey('expandable-search-region'),
                        width: width,
                        height: widget.height,
                        child: ClipRect(
                          child: showSearchBar
                              ? OverflowBox(
                                  alignment: AlignmentDirectional.centerStart,
                                  minWidth: expandedWidth,
                                  maxWidth: expandedWidth,
                                  child: _buildSearchBar(
                                    expandedWidth,
                                    isScrolledUnder: isScrolledUnder,
                                  ),
                                )
                              : IconButton(
                                  key: const ValueKey('activate-search'),
                                  onPressed: widget.onSearchActivated,
                                  icon: const Icon(Icons.search_outlined),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
