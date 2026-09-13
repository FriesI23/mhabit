// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:adaptive_actions/core.dart';
import 'package:adaptive_actions/cupertino.dart'
    show CupertinoActionPresentation;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../extensions/custom_color_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_color.dart';
import '../../../theme/color.dart';
import '../_providers/habit_detail.dart';

const _appBarActionSlotExtent = 48.0;
const _appleExtendedActionAllowance = 64.0;

enum HabitDetailAppBarAction {
  recordCalendar,
  edit,
  unarchive,
  archive,
  delete,
  export,
  clone,
}

final _detailRecordCalendarActionId = ActionId('habit-detail.record-calendar');
final _detailEditActionId = ActionId('habit-detail.edit');
final _detailUnarchiveActionId = ActionId('habit-detail.unarchive');
final _detailArchiveActionId = ActionId('habit-detail.archive');
final _detailCloneActionId = ActionId('habit-detail.clone');
final _detailExportActionId = ActionId('habit-detail.export');
final _detailDeleteActionId = ActionId('habit-detail.delete');

class HabitDetailAppBarActions extends StatelessWidget {
  final HabitColor? habitColor;
  final AdaptiveAppBarActionCallback<HabitDetailAppBarAction> onInvoke;

  const HabitDetailAppBarActions({
    super.key,
    required this.habitColor,
    required this.onInvoke,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<HabitDetailViewModel, bool>(
      selector: (context, viewmodel) => viewmodel.isHabitArchived,
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, isArchived, child) {
        final theme = Theme.of(context);
        final color = habitColor != null
            ? theme.extension<CustomColors>()?.getColor(
                habitColor!,
                brightness: theme.brightness,
              )
            : Colors.transparent;
        final l10n = L10n.of(context);
        final commonActions = <AdaptiveAction<HabitDetailAppBarAction>>[
          AdaptiveAction.action(
            id: _detailEditActionId,
            metadata: ActionMetadata(
              label: l10n?.habitDetail_editButton_tooltip ?? 'Edit Habit',
              tooltip: l10n?.habitDetail_editButton_tooltip ?? 'Edit Habit',
            ),
            payload: HabitDetailAppBarAction.edit,
            placementPolicy: ActionPlacementPolicy(
              placement: ActionPlacement.pinned,
            ),
          ),
          if (isArchived)
            AdaptiveAction.action(
              id: _detailUnarchiveActionId,
              metadata: ActionMetadata(
                label: l10n?.habitDetail_editPopMenu_unarchive ?? 'Unarchive',
              ),
              payload: HabitDetailAppBarAction.unarchive,
              placementPolicy: ActionPlacementPolicy(
                automaticPreference: AutomaticPlacementPreference(
                  retentionPriority: PrimaryRetentionPriority.high,
                ),
              ),
            )
          else
            AdaptiveAction.action(
              id: _detailArchiveActionId,
              metadata: ActionMetadata(
                label: l10n?.habitDetail_editPopMenu_archive ?? 'Archive',
              ),
              payload: HabitDetailAppBarAction.archive,
              placementPolicy: ActionPlacementPolicy(
                automaticPreference: AutomaticPlacementPreference(
                  retentionPriority: PrimaryRetentionPriority.high,
                ),
              ),
            ),
          AdaptiveAction.action(
            id: _detailCloneActionId,
            metadata: ActionMetadata(
              label: l10n?.habitDetail_editPopMenu_clone ?? 'Clone',
            ),
            payload: HabitDetailAppBarAction.clone,
            placementPolicy: ActionPlacementPolicy(
              automaticPreference: AutomaticPlacementPreference(
                retentionPriority: PrimaryRetentionPriority.normal,
              ),
            ),
          ),
          AdaptiveAction.action(
            id: _detailExportActionId,
            metadata: ActionMetadata(
              label: l10n?.habitDetail_editPopMenu_export ?? 'Export',
            ),
            payload: HabitDetailAppBarAction.export,
            placementPolicy: ActionPlacementPolicy(
              automaticPreference: AutomaticPlacementPreference(
                retentionPriority: PrimaryRetentionPriority.low,
              ),
            ),
          ),
          AdaptiveAction.action(
            id: _detailDeleteActionId,
            metadata: ActionMetadata(
              label: l10n?.habitDetail_editPopMenu_delete ?? 'Delete',
            ),
            payload: HabitDetailAppBarAction.delete,
            placementPolicy: ActionPlacementPolicy(
              placement: ActionPlacement.overflowOnly,
            ),
          ),
        ];
        final materialCollection = ActionCollection<HabitDetailAppBarAction>(
          roots: commonActions,
        );
        final appleCollection = ActionCollection<HabitDetailAppBarAction>(
          roots: [
            AdaptiveAction.action(
              id: _detailRecordCalendarActionId,
              metadata: ActionMetadata(
                label: l10n?.habitDetail_recordCalendar_label ?? 'Check in',
                tooltip:
                    l10n?.habitDetail_recordCalendar_tooltip ??
                    'Open check-in calendar',
                tooltipPolicy: const ActionTooltipPolicy.allowed(
                  primaryLabeled: true,
                ),
              ),
              payload: HabitDetailAppBarAction.recordCalendar,
              placementPolicy: ActionPlacementPolicy(
                placement: ActionPlacement.pinned,
              ),
            ),
            ...commonActions,
          ],
        );
        return switch (AdaptiveStyle.of(context)) {
          AdaptiveStyle.material => _MaterialHabitDetailAppBarActions(
            collection: materialCollection,
            color: color,
            onInvoke: onInvoke,
          ),
          AdaptiveStyle.apple => _AppleHabitDetailAppBarActions(
            collection: appleCollection,
            color: color,
            onInvoke: onInvoke,
          ),
        };
      },
    );
  }
}

class _MaterialHabitDetailAppBarActions extends StatelessWidget {
  const _MaterialHabitDetailAppBarActions({
    required this.collection,
    required this.color,
    required this.onInvoke,
  });

  final ActionCollection<HabitDetailAppBarAction> collection;
  final Color? color;
  final AdaptiveAppBarActionCallback<HabitDetailAppBarAction> onInvoke;

  @override
  Widget build(BuildContext context) {
    final maxPrimaryActions = _baseMaxPrimaryActions(context);
    return AdaptiveAppBarActions<HabitDetailAppBarAction>.material(
      collection: collection,
      primaryCapacity: (maxPrimaryActions + 1) * _appBarActionSlotExtent,
      maxPrimaryActions: maxPrimaryActions,
      onInvoke: onInvoke,
      material: MaterialAppBarActionsConfig(
        iconBuilder: (context, action) => Icon(switch (action.payload) {
          HabitDetailAppBarAction.recordCalendar =>
            Icons.edit_calendar_outlined,
          HabitDetailAppBarAction.edit => Icons.edit_rounded,
          HabitDetailAppBarAction.unarchive => Icons.unarchive_rounded,
          HabitDetailAppBarAction.archive => Icons.archive_outlined,
          HabitDetailAppBarAction.clone => Icons.copy_rounded,
          HabitDetailAppBarAction.export => MdiIcons.export,
          HabitDetailAppBarAction.delete => Icons.delete_outline,
          null => Icons.more_horiz,
        }, color: color),
        overflowIcon: Icon(Icons.more_vert, color: color),
      ),
    );
  }
}

class _AppleHabitDetailAppBarActions extends StatelessWidget {
  const _AppleHabitDetailAppBarActions({
    required this.collection,
    required this.color,
    required this.onInvoke,
  });

  final ActionCollection<HabitDetailAppBarAction> collection;
  final Color? color;
  final AdaptiveAppBarActionCallback<HabitDetailAppBarAction> onInvoke;

  @override
  Widget build(BuildContext context) {
    final width = WindowSize.of(context).width;
    final maxPrimaryActions = _baseMaxPrimaryActions(context) + 1;
    final showsExtendedRecordAction = width >= WindowSizeClass.medium;
    return AdaptiveAppBarActions<HabitDetailAppBarAction>.apple(
      collection: collection,
      primaryCapacity:
          (maxPrimaryActions + 1) * _appBarActionSlotExtent +
          (showsExtendedRecordAction ? _appleExtendedActionAllowance : 0),
      maxPrimaryActions: maxPrimaryActions,
      onInvoke: onInvoke,
      apple: CupertinoAppBarActionsConfig(
        iconBuilder: (context, action) => Icon(switch (action.payload) {
          HabitDetailAppBarAction.recordCalendar =>
            CupertinoIcons.calendar_badge_plus,
          HabitDetailAppBarAction.edit => CupertinoIcons.pencil,
          HabitDetailAppBarAction.unarchive => CupertinoIcons.tray_arrow_up,
          HabitDetailAppBarAction.archive => CupertinoIcons.archivebox,
          HabitDetailAppBarAction.clone => CupertinoIcons.square_on_square,
          HabitDetailAppBarAction.export => CupertinoIcons.share_up,
          HabitDetailAppBarAction.delete => CupertinoIcons.delete,
          null => CupertinoIcons.ellipsis,
        }, color: color),
        overflowIcon: Icon(CupertinoIcons.ellipsis, color: color),
        presentationForAction: (context, action) =>
            action.payload == HabitDetailAppBarAction.recordCalendar &&
                showsExtendedRecordAction
            ? CupertinoActionPresentation.extended
            : CupertinoActionPresentation.iconOnly,
      ),
    );
  }
}

int _baseMaxPrimaryActions(BuildContext context) =>
    switch (WindowSize.of(context).width) {
      WindowSizeClass.compact => 1,
      WindowSizeClass.medium => 2,
      WindowSizeClass.expanded => 3,
      WindowSizeClass.large || WindowSizeClass.extraLarge => 4,
    };
