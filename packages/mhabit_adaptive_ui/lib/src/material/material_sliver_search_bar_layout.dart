import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../breakpoints/window_size_class.dart';

/// Resolved horizontal layout for a Material sliver search bar.
final class MaterialSliverSearchBarLayout {
  const MaterialSliverSearchBarLayout._({
    required this.isWide,
    required this.showWideTitle,
    required this.actionCapacity,
  });

  final bool isWide;
  final bool showWideTitle;
  final double actionCapacity;
}

/// Calculates Material sliver search-bar geometry independently of widgets.
///
/// The logical horizontal budgets are:
///
/// ```text
/// wide:    leading | title | flexible gap | search | actions | outer reserve
/// compact: search | flexible gap | leading | actions | outer reserve
/// ```
///
/// Action capacity is rounded down to whole Material interaction slots while
/// preserving one slot for the More button whenever actions are available.
final class MaterialSliverSearchBarLayoutCalculator {
  static const _mediumTitleTrailingWidthThreshold = 0.7;
  static const _actionSlotExtent = kMinInteractiveDimension;
  static const _minimumActionCapacity = _actionSlotExtent;
  static const _collapsedSearchReserve = 120.0;
  static const _wideLeadingReserve = kToolbarHeight;
  static const _compactLeadingReserve = kMinInteractiveDimension;
  static const _wideTitleReserve = 96.0;
  static const _wideHorizontalReserve = 32.0;
  static const _compactHorizontalReserve = 16.0;

  const MaterialSliverSearchBarLayoutCalculator({
    required this.widthClass,
    required this.availableWidth,
    required this.isSearchActive,
    required this.hasLeading,
    required this.maxSearchWidth,
    required this.preferredActionCapacity,
  }) : assert(availableWidth >= 0 && availableWidth < double.infinity),
       assert(maxSearchWidth >= 0 && maxSearchWidth < double.infinity),
       assert(
         preferredActionCapacity >= 0 &&
             preferredActionCapacity < double.infinity,
       );

  final WindowSizeClass widthClass;
  final double availableWidth;
  final bool isSearchActive;
  final bool hasLeading;
  final double maxSearchWidth;
  final double preferredActionCapacity;

  MaterialSliverSearchBarLayout calculate() {
    final isWide = widthClass >= WindowSizeClass.medium;
    if (!availableWidth.isFinite ||
        availableWidth < 0 ||
        !maxSearchWidth.isFinite ||
        maxSearchWidth < 0 ||
        !preferredActionCapacity.isFinite ||
        preferredActionCapacity < 0) {
      return MaterialSliverSearchBarLayout._(
        isWide: isWide,
        showWideTitle: false,
        actionCapacity: 0,
      );
    }
    final showWideTitle = _resolveShowWideTitle();
    return MaterialSliverSearchBarLayout._(
      isWide: isWide,
      showWideTitle: showWideTitle,
      actionCapacity: _resolveActionCapacity(
        isWide: isWide,
        showWideTitle: showWideTitle,
      ),
    );
  }

  bool _resolveShowWideTitle() {
    if (widthClass >= WindowSizeClass.expanded) return true;
    if (widthClass != WindowSizeClass.medium) return false;
    final preferredTrailingWidth = maxSearchWidth + preferredActionCapacity;
    return preferredTrailingWidth <
        availableWidth * _mediumTitleTrailingWidthThreshold;
  }

  double _resolveActionCapacity({
    required bool isWide,
    required bool showWideTitle,
  }) {
    if (preferredActionCapacity <= 0) return 0;
    final searchReserve = isWide || isSearchActive
        ? maxSearchWidth
        : _collapsedSearchReserve;
    final leadingReserve = hasLeading
        ? (isWide ? _wideLeadingReserve : _compactLeadingReserve)
        : 0.0;
    final titleReserve = showWideTitle ? _wideTitleReserve : 0.0;
    final horizontalReserve = isWide
        ? _wideHorizontalReserve
        : _compactHorizontalReserve;
    final available =
        availableWidth -
        searchReserve -
        leadingReserve -
        titleReserve -
        horizontalReserve;
    final slotted =
        (available / _actionSlotExtent).floorToDouble() * _actionSlotExtent;
    return math.min(
      preferredActionCapacity,
      math.max(_minimumActionCapacity, slotted),
    );
  }
}
