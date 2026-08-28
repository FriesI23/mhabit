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
    extends State<MaterialExpandableSearchBar> {
  static const Duration _iconAnimationDuration = Duration(milliseconds: 300);

  late bool _showSearchBar;
  bool _animateWidth = false;
  double? _lastExpandedWidth;

  @override
  void initState() {
    super.initState();
    _showSearchBar = widget.expanded;
  }

  @override
  void didUpdateWidget(MaterialExpandableSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded) {
      _animateWidth = true;
      if (widget.expanded) _showSearchBar = true;
    }
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

  void _onAnimationEnd() {
    if (!mounted) return;
    if (_animateWidth || (!widget.expanded && _showSearchBar)) {
      setState(() {
        _animateWidth = false;
        if (!widget.expanded) _showSearchBar = false;
      });
    }
  }

  Widget _buildCollapsedTitle() => Flexible(
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
        var animateWidth = _animateWidth;
        if (_lastExpandedWidth != null && _lastExpandedWidth != expandedWidth) {
          _animateWidth = false;
          animateWidth = false;
        }
        _lastExpandedWidth = expandedWidth;
        final collapsedWidth = expandedWidth < widget.height
            ? expandedWidth
            : widget.height;
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: expandedWidth,
            height: widget.height,
            child: Row(
              children: [
                AnimatedContainer(
                  key: const ValueKey('expandable-search-region'),
                  width: widget.expanded ? expandedWidth : collapsedWidth,
                  height: widget.height,
                  duration: animateWidth ? widget.duration : Duration.zero,
                  curve: widget.curve,
                  onEnd: _onAnimationEnd,
                  child: ClipRect(
                    child: _showSearchBar
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
                _buildCollapsedTitle(),
              ],
            ),
          ),
        );
      },
    );
  }
}
