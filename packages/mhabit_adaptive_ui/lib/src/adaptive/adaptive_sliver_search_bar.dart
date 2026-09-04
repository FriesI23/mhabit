import 'package:adaptive_actions/core.dart';
import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_sliver_search_bar.dart';
import '../material/material_sliver_search_bar.dart';
import 'adaptive_app_bar_actions.dart';

sealed class SliverSearchBarConfig<T extends Object> {
  const SliverSearchBarConfig();
}

final class MaterialSliverSearchBarConfig<T extends Object>
    extends SliverSearchBarConfig<T> {
  const MaterialSliverSearchBarConfig({
    this.style = const MaterialSliverSearchBarStyle(),
    this.searchTrailing,
    this.relocatedActionIds = const {},
    this.actions,
  });

  final MaterialSliverSearchBarStyle style;
  final Widget? searchTrailing;
  final Set<ActionId> relocatedActionIds;
  final MaterialAppBarActionsConfig<T>? actions;
}

final class CupertinoSliverSearchBarConfig<T extends Object>
    extends SliverSearchBarConfig<T> {
  const CupertinoSliverSearchBarConfig({
    this.maxSearchWidth = 240.0,
    this.bottom,
    this.bottomExtent = 0.0,
    this.actions,
  }) : assert(bottom != null || bottomExtent == 0.0);

  final double maxSearchWidth;
  final Widget? bottom;
  final double bottomExtent;
  final CupertinoAppBarActionsConfig<T>? actions;
}

/// Adaptive sliver search bar.
///
/// Shared search state and action identity stay on this facade. Platform-only
/// presentation is grouped into [material] and [apple], matching Flutter's
/// adaptive-widget boundary without spreading renderer-specific parameters
/// across the common constructor.
class AdaptiveSliverSearchBar<T extends Object> extends StatelessWidget {
  const AdaptiveSliverSearchBar({
    super.key,
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.isSearchActive,
    required this.keyword,
    required this.onChanged,
    required this.onSearchActivated,
    required this.onSearchDismissed,
    required this.collection,
    required this.onInvoke,
    this.leading,
    this.hintText,
    this.onSubmitted,
    this.onTapOutside,
    this.material,
    this.apple,
    this.pinned = true,
  }) : style = null;

  const AdaptiveSliverSearchBar.material({
    super.key,
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.isSearchActive,
    required this.keyword,
    required this.onChanged,
    required this.onSearchActivated,
    required this.onSearchDismissed,
    required this.collection,
    required this.onInvoke,
    this.leading,
    this.hintText,
    this.onSubmitted,
    this.onTapOutside,
    this.material,
    this.pinned = true,
  }) : apple = null,
       style = AdaptiveStyle.material;

  const AdaptiveSliverSearchBar.apple({
    super.key,
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.isSearchActive,
    required this.keyword,
    required this.onChanged,
    required this.onSearchActivated,
    required this.onSearchDismissed,
    required this.collection,
    required this.onInvoke,
    this.leading,
    this.hintText,
    this.onSubmitted,
    this.onTapOutside,
    this.apple,
    this.pinned = true,
  }) : material = null,
       style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final Widget title;
  final Widget? leading;
  final ActionCollection<T> collection;
  final AdaptiveAppBarActionCallback<T> onInvoke;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearchActive;
  final String keyword;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onSearchActivated;
  final VoidCallback onSearchDismissed;
  final TapRegionCallback? onTapOutside;
  final MaterialSliverSearchBarConfig<T>? material;
  final CupertinoSliverSearchBarConfig<T>? apple;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? AdaptiveStyle.of(context);
    return switch (effective) {
      AdaptiveStyle.apple => _buildCupertino(),
      AdaptiveStyle.material => _buildMaterial(),
    };
  }

  Widget _buildCupertino() {
    final config = apple ?? CupertinoSliverSearchBarConfig<T>();
    return CupertinoSliverSearchBar<T>(
      title: title,
      leading: leading,
      collection: collection,
      onInvoke: onInvoke,
      actions: config.actions,
      controller: controller,
      focusNode: focusNode,
      isSearchActive: isSearchActive,
      keyword: keyword,
      hintText: hintText,
      maxSearchWidth: config.maxSearchWidth,
      bottom: config.bottom,
      bottomExtent: config.bottomExtent,
      pinned: pinned,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onSearchActivated: onSearchActivated,
      onSearchDismissed: onSearchDismissed,
      onTapOutside: onTapOutside,
    );
  }

  Widget _buildMaterial() {
    final config = material ?? MaterialSliverSearchBarConfig<T>();
    final appBarCollection = ActionCollection<T>(
      roots: [
        for (final action in collection.roots)
          if (!config.relocatedActionIds.contains(action.id)) action,
      ],
    );
    final preferredCapacity = appBarCollection.roots.length * 48.0;
    return MaterialSliverSearchBar(
      title: title,
      leading: leading,
      actionsBuilder: (context, primaryCapacity) =>
          AdaptiveAppBarActions<T>.material(
            collection: appBarCollection,
            onInvoke: onInvoke,
            primaryCapacity: primaryCapacity,
            maxPrimaryActions: appBarCollection.roots.length,
            material: config.actions,
          ),
      preferredActionCapacity: preferredCapacity,
      searchTrailing: config.searchTrailing,
      controller: controller,
      focusNode: focusNode,
      isSearchActive: isSearchActive,
      keyword: keyword,
      hintText: hintText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onSearchActivated: onSearchActivated,
      onSearchDismissed: onSearchDismissed,
      onTapOutside: onTapOutside,
      style: config.style,
      pinned: pinned,
    );
  }
}
