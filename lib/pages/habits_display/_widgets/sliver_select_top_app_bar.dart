// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../extensions/adaptive_style_extensions.dart';
import '../../../l10n/localizations.dart';
import '../styles.dart';
import 'actions/habit_display_select_actions.dart';

const _actionSlotExtent = 48.0;

class MaterialSliverSelectAppBar extends StatelessWidget {
  const MaterialSliverSelectAppBar({
    super.key,
    this.height = AppAdaptiveStyle.materialToolbarHeight,
    required this.callbacks,
  });

  final double height;
  final HabitDisplaySelectAppBarCallbacks callbacks;

  @override
  Widget build(BuildContext context) => HabitDisplaySelectActions(
    callbacks: callbacks,
    includeSelectAll: true,
    builder: (context, data) => AdaptiveSliverAppBar.material(
      height: height,
      title: Text(data.selectedCount.toString()),
      leading: AdaptiveBackButton.material(
        type: AdaptiveBackButtonType.close,
        onPressed: callbacks.onDone,
      ),
      actions: [
        AdaptiveAppBarActions<HabitDisplaySelectAction>.material(
          collection: data.collection,
          onInvoke: data.onInvoke,
          primaryCapacity: data.collection.roots.length * _actionSlotExtent,
          material: data.material,
        ),
      ],
      styles: AppBarStyles(
        material: AppBarMaterialStyle(
          floating: false,
          snap: false,
          pinned: true,
          forceElevated: true,
          centerTitle: false,
          scrolledUnderElevation: kCommonEvalation,
          shadowColor: Theme.of(context).colorScheme.shadow,
        ),
      ),
    ),
  );
}

class AppleSliverSelectAppBar extends StatelessWidget {
  const AppleSliverSelectAppBar({
    super.key,
    required this.callbacks,
    this.bottom,
    this.bottomExtent = 0.0,
  });

  final HabitDisplaySelectAppBarCallbacks callbacks;
  final Widget? bottom;
  final double bottomExtent;

  @override
  Widget build(BuildContext context) => HabitDisplaySelectActions(
    callbacks: callbacks,
    includeSelectAll: false,
    builder: (context, data) {
      final l10n = L10n.of(context);
      return CupertinoSliverSelectAppBar<HabitDisplaySelectAction>(
        title: Text(
          l10n?.habitDisplay_selectedHabits_title(data.selectedCount) ??
              'Selected ${data.selectedCount}',
        ),
        selectAllLabel:
            l10n?.habitDisplay_editPopMenu_selectAll ?? 'Select All',
        doneLabel: l10n?.habitDisplay_doneButton_label ?? 'Done',
        onSelectAll: callbacks.onSelectAll,
        onDone: callbacks.onDone,
        collection: data.collection,
        onInvoke: data.onInvoke,
        actions: data.apple,
        bottom: bottom,
        bottomExtent: bottomExtent,
      );
    },
  );
}

class HabitCupertinoSelectBottomToolbar extends StatelessWidget {
  const HabitCupertinoSelectBottomToolbar({super.key, required this.callbacks});

  final HabitDisplaySelectAppBarCallbacks callbacks;

  @override
  Widget build(BuildContext context) => HabitDisplaySelectActions(
    callbacks: callbacks,
    includeSelectAll: false,
    builder: (context, data) =>
        CupertinoSelectBottomToolbar<HabitDisplaySelectAction>(
          collection: data.collection,
          onInvoke: data.onInvoke,
          actions: data.apple,
        ),
  );
}
