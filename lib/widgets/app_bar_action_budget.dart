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
  ///
  /// [maxPrimaryActions] is the non-negative number of primary action slots to
  /// reserve, excluding More. [reserveOverflow] reserves one additional More
  /// slot; it does not force the renderer to display an overflow button.
  ///
  /// [slotExtent] is the estimated width of each slot in logical pixels. It
  /// defaults to [defaultSlotExtent] and must be positive and finite.
  /// [additionalCapacity] adds a non-negative, finite width in logical pixels
  /// once to the whole region, for example to allow an extended button label.
  /// The budget is `(maxPrimaryActions + More slots) * slotExtent` plus
  /// [additionalCapacity], regardless of the number of available actions.
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
  ///
  /// [primaryCount] is the non-negative number of primary action candidates,
  /// excluding actions already assigned to overflow. [maxPrimaryActions] caps
  /// the primary slots, excluding More; it must be non-negative when provided.
  /// A null limit budgets all [primaryCount] candidates. [hasOverflow] indicates
  /// that the page already has overflow actions. At most one More slot is added.
  ///
  /// [slotExtent] is the positive, finite slot width estimate in logical pixels,
  /// defaulting to [defaultSlotExtent]. [additionalCapacity] is a non-negative,
  /// finite width in logical pixels added once after all slots are counted.
  /// Reserving a More slot does not force the renderer to display it.
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
  ///
  /// [primaryCapacity] is the complete action-region budget in logical pixels
  /// and must be non-negative and finite. Include any desired More button or
  /// label allowance in this value; no additional width is added here.
  /// [maxPrimaryActions] limits primary actions, excluding More. It must be
  /// non-negative when provided; null leaves the count limit unspecified.
  const AppBarActionBudget.capacity({
    required this.primaryCapacity,
    this.maxPrimaryActions,
  }) : assert(primaryCapacity >= 0 && primaryCapacity < double.infinity),
       assert(maxPrimaryActions == null || maxPrimaryActions >= 0);

  /// The computed width budget passed to the adaptive action host.
  ///
  /// Includes any budgeted More slot and extra label allowance, in logical
  /// pixels. For example, [AppBarActionBudget.slots] can reserve:
  ///
  /// ```text
  /// | primary | primary | More | extra |
  /// <--------- primaryCapacity -------->
  /// ```
  ///
  /// This is a budget, not a measured or guaranteed final layout. The renderer
  /// and surrounding constraints determine which actions are displayed.
  final double primaryCapacity;

  /// The primary action count limit, or null when no limit is specified.
  ///
  /// Excludes the More button and does not guarantee that all slots are filled.
  /// With three candidates, [AppBarActionBudget.candidates] budgets:
  ///
  /// ```text
  /// maxPrimaryActions: 1
  /// | primary | More |
  /// <-limit:1->       primaryCapacity: 96
  ///
  /// maxPrimaryActions: 2
  /// | primary | primary | More |
  /// <---- limit: 2 ----->       primaryCapacity: 144
  /// ```
  ///
  /// Both examples use `primaryCount: 3`, `hasOverflow: false`, the default
  /// 48 logical pixels per slot, and no additional capacity. Exceeding either
  /// limit reserves one More slot. Raising the limit adds a primary slot;
  /// the More slot does not consume that limit. Actual placement remains the
  /// renderer's responsibility.
  final int? maxPrimaryActions;
}
