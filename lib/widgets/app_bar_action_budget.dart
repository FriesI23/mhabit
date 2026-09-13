// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

/// App-level width budgeting for app-bar action hosts.
///
/// This estimates space; it does not resolve action placement or measure labels.
/// The renderer still owns overflow and the surrounding layout constraints.
final class AppBarActionBudget {
  /// The app's slot estimate, independent of platform button hit-target sizes.
  static const defaultSlotExtent = 48.0;

  /// Budgets the requested primary slots and an optional More slot.
  factory AppBarActionBudget.slots({
    required int maxPrimaryActions,
    required bool reserveOverflow,
    double slotExtent = defaultSlotExtent,
    double additionalCapacity = 0,
  }) => AppBarActionBudget.candidates(
    primaryCount: maxPrimaryActions,
    maxPrimaryActions: maxPrimaryActions,
    hasOverflow: reserveOverflow,
    slotExtent: slotExtent,
    additionalCapacity: additionalCapacity,
  );

  /// Budgets only available candidates, capped by [maxPrimaryActions].
  ///
  /// A More slot is budgeted when [hasOverflow] is true or the count exceeds
  /// the limit. Counts are supplied by the page; this does not inspect actions.
  factory AppBarActionBudget.candidates({
    required int primaryCount,
    int? maxPrimaryActions,
    required bool hasOverflow,
    double slotExtent = defaultSlotExtent,
    double additionalCapacity = 0,
  }) {
    assert(primaryCount >= 0);
    assert(maxPrimaryActions == null || maxPrimaryActions >= 0);
    assert(slotExtent > 0 && slotExtent < double.infinity);
    assert(additionalCapacity >= 0 && additionalCapacity < double.infinity);
    final exceedsLimit =
        maxPrimaryActions != null && primaryCount > maxPrimaryActions;
    final primarySlots = exceedsLimit ? maxPrimaryActions : primaryCount;
    final overflowSlots = hasOverflow || exceedsLimit ? 1 : 0;
    return AppBarActionBudget.capacity(
      primaryCapacity:
          (primarySlots + overflowSlots) * slotExtent + additionalCapacity,
      maxPrimaryActions: maxPrimaryActions,
    );
  }

  /// Uses a measured or otherwise explicitly chosen width budget.
  const AppBarActionBudget.capacity({
    required this.primaryCapacity,
    this.maxPrimaryActions,
  }) : assert(primaryCapacity >= 0 && primaryCapacity < double.infinity),
       assert(maxPrimaryActions == null || maxPrimaryActions >= 0);

  /// The computed width budget passed to the adaptive action host.
  final double primaryCapacity;

  /// The primary action count limit, or null when no limit is specified.
  final int? maxPrimaryActions;
}
