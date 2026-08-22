import 'package:flutter/material.dart';

import '../breakpoints/window_size_class.dart';

const List<Widget> _kDefaultActions = <Widget>[];

/// Material-only visual configuration for [MaterialSliverSearchBar].
class MaterialSliverSearchBarStyle {
  const MaterialSliverSearchBarStyle({
    this.toolbarHeight = kToolbarHeight,
    this.searchBarHeight = 48.0,
    this.maxSearchWidth = 312.0,
    this.scrolledUnderElevation,
    this.shadowColor = Colors.transparent,
  });

  final double toolbarHeight;
  final double searchBarHeight;
  final double maxSearchWidth;
  final double? scrolledUnderElevation;
  final Color? shadowColor;
}

/// Material presentation for an inline, sliver-based search command bar.
class MaterialSliverSearchBar extends StatelessWidget {
  const MaterialSliverSearchBar({
    super.key,
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.isSearchActive,
    required this.keyword,
    required this.onChanged,
    required this.onSearchActivated,
    required this.onSearchDismissed,
    this.leading,
    this.actions = _kDefaultActions,
    this.searchTrailing,
    this.hintText,
    this.onSubmitted,
    this.onTapOutside,
    this.style = const MaterialSliverSearchBarStyle(),
  });

  final Widget title;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? searchTrailing;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearchActive;
  final String keyword;
  final String? hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onSearchActivated;
  final VoidCallback onSearchDismissed;
  final TapRegionCallback? onTapOutside;
  final MaterialSliverSearchBarStyle style;

  @override
  Widget build(BuildContext context) {
    final searchBar = _MaterialSearchField(
      controller: controller,
      focusNode: focusNode,
      isSearchActive: isSearchActive,
      hintText: hintText,
      trailing: searchTrailing,
      height: style.searchBarHeight,
      maxWidth: style.maxSearchWidth,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onSearchActivated: onSearchActivated,
      onSearchDismissed: onSearchDismissed,
      onTapOutside: onTapOutside,
    );
    final isWide = WindowSize.of(context).width >= WindowSizeClass.medium;

    // TODO(adaptive-actions): Migrate the Material and Cupertino action
    // regions after adaptive_actions is published as a stable package.
    return SliverAppBar(
      key: const ValueKey('material-sliver-search-bar'),
      floating: true,
      snap: true,
      pinned: true,
      centerTitle: false,
      toolbarHeight: style.toolbarHeight,
      scrolledUnderElevation: style.scrolledUnderElevation,
      shadowColor: style.shadowColor,
      bottom: const PreferredSize(
        preferredSize: Size.zero,
        child: SizedBox.shrink(),
      ),
      leading: isWide ? leading : null,
      title: isWide ? title : searchBar,
      actions: isWide
          ? [
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                  width: style.maxSearchWidth,
                ),
                child: searchBar,
              ),
              ...actions,
            ]
          : [?leading, ...actions],
    );
  }
}

class _MaterialSearchField extends StatefulWidget {
  const _MaterialSearchField({
    required this.controller,
    required this.focusNode,
    required this.isSearchActive,
    required this.height,
    required this.maxWidth,
    required this.onChanged,
    required this.onSearchActivated,
    required this.onSearchDismissed,
    this.hintText,
    this.trailing,
    this.onSubmitted,
    this.onTapOutside,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearchActive;
  final double height;
  final double maxWidth;
  final String? hintText;
  final Widget? trailing;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onSearchActivated;
  final VoidCallback onSearchDismissed;
  final TapRegionCallback? onTapOutside;

  @override
  State<_MaterialSearchField> createState() => _MaterialSearchFieldState();
}

class _MaterialSearchFieldState extends State<_MaterialSearchField> {
  static const Duration _iconAnimationDuration = Duration(milliseconds: 300);

  var _isScrolledUnder = false;

  BoxConstraints _constraintsFor(BoxConstraints constraints) {
    final availableWidth = constraints.maxWidth;
    final width = availableWidth <= widget.maxWidth
        ? availableWidth
        : widget.maxWidth + (availableWidth - widget.maxWidth) / 2;
    return BoxConstraints.tightFor(height: widget.height, width: width);
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

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final isScrolledUnder = settings?.isScrolledUnder ?? false;
    if (_isScrolledUnder != isScrolledUnder) {
      _isScrolledUnder = isScrolledUnder;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }

    final colors = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return LayoutBuilder(
      builder: (context, constraints) => SearchBar(
        focusNode: widget.focusNode,
        controller: widget.controller,
        textInputAction: TextInputAction.search,
        overlayColor: _overlayColor(colors),
        backgroundColor: _isScrolledUnder
            ? WidgetStatePropertyAll(
                brightness == Brightness.dark
                    ? colors.surfaceContainer
                    : colors.surfaceContainerLowest,
              )
            : null,
        elevation: const WidgetStatePropertyAll(0.0),
        constraints: _constraintsFor(constraints),
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
      ),
    );
  }
}
