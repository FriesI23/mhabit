// Copyright 2025 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../common/consts.dart';
import '../../../extensions/adaptive_style_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../widgets/widgets.dart';
import '../styles.dart';
import 'habit_display_view_actions.dart';

export 'habit_display_view_actions.dart'
    show HabitDisplayViewAction, HabitDisplayViewAppBarCallbacks;
export 'sliver_search_top_app_bar.dart';

class SliverViewTopAppBar extends StatelessWidget {
  const SliverViewTopAppBar({
    super.key,
    this.height = AppAdaptiveStyle.materialToolbarHeight,
    this.callbacks = const HabitDisplayViewAppBarCallbacks(),
    this.showSelectAction,
  });

  final double? height;
  final HabitDisplayViewAppBarCallbacks callbacks;
  final bool? showSelectAction;

  @override
  Widget build(BuildContext context) => AdaptiveSliverAppBar(
    height: AdaptiveStyle.of(context) == AdaptiveStyle.apple
        ? CupertinoSliverSelectAppBar.toolbarHeight
        : height,
    title: L10nBuilder(
      builder: (context, l10n) => Text(l10n?.appName ?? appName),
    ),
    actions: [
      HabitDisplayViewActions(
        callbacks: callbacks,
        showSelectAction: showSelectAction,
        builder: (context, data) =>
            AdaptiveAppBarActions<HabitDisplayViewAction>(
              collection: data.collection,
              onInvoke: data.onInvoke,
              primaryCapacity: data.primaryCapacity,
              maxPrimaryActions: data.maxPrimaryActions,
              material: data.material,
              apple: data.apple,
            ),
      ),
    ],
    styles: const AppBarStyles(
      material: AppBarMaterialStyle(
        scrolledUnderElevation: kCommonEvalation,
        shadowColor: Colors.transparent,
      ),
    ),
  );
}

class AppleSliverViewTopAppBar extends StatelessWidget {
  const AppleSliverViewTopAppBar({
    super.key,
    this.callbacks = const HabitDisplayViewAppBarCallbacks(),
    this.showSelectAction,
  });

  final HabitDisplayViewAppBarCallbacks callbacks;
  final bool? showSelectAction;

  @override
  Widget build(BuildContext context) => HabitDisplayViewActions(
    callbacks: callbacks,
    showSelectAction: showSelectAction,
    builder: (context, data) =>
        CupertinoSliverSelectAppBar<HabitDisplayViewAction>.view(
          title: Text(L10n.of(context)?.appName ?? appName),
          collection: data.collection,
          onInvoke: data.onInvoke,
          actions: data.apple,
        ),
  );
}
