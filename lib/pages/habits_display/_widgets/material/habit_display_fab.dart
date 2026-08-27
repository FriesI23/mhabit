// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../../../storage/db/handlers/habit.dart';
import '../../../../widgets/widgets.dart';
import '../../../habit_edit/page.dart' as habit_edit;
import '../../../habits_status_changer/page.dart' as habits_status_changer;
import '../../_providers/habit_summary.dart';
import '../../styles.dart';

/// Material FAB for the Habits display, including its container transition.
class HabitDisplayMaterialFab extends StatelessWidget {
  const HabitDisplayMaterialFab({
    super.key,
    required this.hidden,
    required this.bottomNavVisible,
    required this.bottomNavHeight,
    required this.onCreated,
  });

  static const Duration _bottomNavAnimationDuration = Duration(
    milliseconds: 250,
  );

  final bool hidden;
  final bool bottomNavVisible;
  final double bottomNavHeight;
  final ValueChanged<HabitDBCell> onCreated;

  @override
  Widget build(BuildContext context) {
    if (hidden) return const SizedBox.shrink();
    return AnimatedPadding(
      duration: _bottomNavAnimationDuration,
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomNavVisible ? bottomNavHeight : 0),
      child: AnimatedSlide(
        duration: _bottomNavAnimationDuration,
        curve: Curves.easeOut,
        offset: bottomNavVisible ? Offset.zero : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: _bottomNavAnimationDuration,
          opacity: bottomNavVisible ? 1 : 0,
          child: _buildFab(context),
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) =>
      Selector<HabitSummaryViewModel, Tuple3<bool, bool, int>>(
        selector: (context, viewmodel) => Tuple3(
          viewmodel.isAppbarPinned,
          viewmodel.isInEditMode,
          viewmodel.selectedHabitsCount,
        ),
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, value, child) => _buildOpenContainer(
          context,
          isAppbarPinned: value.item1,
          isInEditMode: value.item2,
        ),
      );

  Widget _buildOpenContainer(
    BuildContext context, {
    required bool isAppbarPinned,
    required bool isInEditMode,
  }) {
    Widget iconBuilder(BuildContext context) => AnimatedCrossFade(
      firstChild: const Icon(Icons.add),
      secondChild: const Icon(Icons.calendar_view_day_rounded),
      crossFadeState: isInEditMode
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: kFABModeChangeDuration,
    );

    Widget labelBuilder(BuildContext context) => AnimatedCrossFade(
      firstChild: L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.habitDisplay_fab_text)
            : const Text('New Habit'),
      ),
      secondChild: const SizedBox(),
      crossFadeState: isInEditMode
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: kFABModeChangeDuration,
    );

    final selectedUUIDList = context
        .read<HabitSummaryViewModel>()
        .getSelectedHabitsData()
        .nonNulls
        .map((e) => e.uuid)
        .toList();

    return _HabitDisplayMaterialOpenContainer<Object?>(
      closeBuilder: (context, action) => ScrollingFAB.small(
        onPressed: () => _handlePressed(context, action),
        label: labelBuilder(context),
        icon: iconBuilder(context),
        isExtended: isInEditMode || isAppbarPinned,
      ),
      openBuilder: (context, action) => isInEditMode
          ? habits_status_changer.HabitsStatusChangerPage(
              uuidList: selectedUUIDList,
            )
          : const habit_edit.HabitEditPage(showInFullscreenDialog: true),
      onClosed: (data) {
        switch (data) {
          case HabitDBCell():
            return onCreated(data);
          case null:
            return;
          default:
            throw FlutterError('unhandled container close type, $data');
        }
      },
    );
  }

  void _handlePressed(BuildContext context, VoidCallback action) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    action();
  }
}

class _HabitDisplayMaterialOpenContainer<T> extends StatelessWidget {
  const _HabitDisplayMaterialOpenContainer({
    this.closedElevation,
    required this.closeBuilder,
    required this.openBuilder,
    this.onClosed,
  });

  final double? closedElevation;
  final CloseContainerBuilder closeBuilder;
  final OpenContainerBuilder<T> openBuilder;
  final ClosedCallback<T?>? onClosed;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return OpenContainer<T>(
      transitionDuration: const Duration(milliseconds: 250),
      transitionType: ContainerTransitionType.fadeThrough,
      middleColor: themeData.colorScheme.primaryContainer.withValues(
        alpha: 0.5,
      ),
      closedShape: kDefaultScrollingFABShape,
      closedColor: themeData.colorScheme.surface,
      closedElevation: closedElevation ?? kDefaultScrollingFABElevation,
      closedBuilder: closeBuilder,
      openElevation: 0,
      openShape: kDefaultScrollingFABShape,
      openColor: themeData.colorScheme.primaryContainer,
      openBuilder: openBuilder,
      onClosed: onClosed,
      tappable: false,
    );
  }
}
