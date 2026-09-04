// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:adaptive_actions/cupertino.dart';
import 'package:adaptive_actions/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoButton, CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../extensions/iterable_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_form.dart';

enum HabitDisplaySearchAction {
  select,
  openSettings,
  statistics,
  mainMenu,
  filter,
  filterStatus,
  filterOngoing,
  filterCompleted,
  filterTypes,
  filterType,
  clearFilters,
}

typedef HabitDisplaySearchActionPayload = ({
  HabitDisplaySearchAction action,
  HabitType? habitType,
});

final _selectId = ActionId('habits.search.select');
final _openSettingsId = ActionId('habits.search.open-settings');
final _statisticsId = ActionId('habits.search.statistics');
final _mainMenuId = ActionId('habits.search.main-menu');
final habitDisplaySearchFilterActionId = ActionId('habits.search.filter');
final _filterStatusId = ActionId('habits.search.filter.status');
final _filterOngoingId = ActionId('habits.search.filter.ongoing');
final _filterCompletedId = ActionId('habits.search.filter.completed');
final _filterTypesId = ActionId('habits.search.filter.types');
final _clearFiltersId = ActionId('habits.search.filter.clear');

ActionId _filterTypeId(HabitType type) =>
    ActionId('habits.search.filter.type.${type.name}');

final class HabitDisplaySearchActionsData {
  const HabitDisplaySearchActionsData({
    required this.collection,
    required this.onInvoke,
    required this.material,
    required this.apple,
  });

  final ActionCollection<HabitDisplaySearchActionPayload> collection;
  final AdaptiveAppBarActionCallback<HabitDisplaySearchActionPayload> onInvoke;
  final MaterialAppBarActionsConfig<HabitDisplaySearchActionPayload> material;
  final CupertinoAppBarActionsConfig<HabitDisplaySearchActionPayload> apple;
}

typedef HabitDisplaySearchActionsBuilder =
    Widget Function(BuildContext context, HabitDisplaySearchActionsData data);

class HabitDisplaySearchActions extends StatelessWidget {
  const HabitDisplaySearchActions({
    super.key,
    required this.options,
    required this.filterOverflowOnly,
    required this.onOngoingFilterToggled,
    required this.onCompletedFilterToggled,
    required this.onTypeFilterToggled,
    required this.onClearFilterPressed,
    required this.builder,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
    this.onOpenSettingsPressed,
    this.onSelectButtonPressed,
    this.showSelectAction,
  });

  final HabitDisplaySearchOptions options;
  final bool filterOverflowOnly;
  final VoidCallback onOngoingFilterToggled;
  final VoidCallback onCompletedFilterToggled;
  final ValueChanged<HabitType> onTypeFilterToggled;
  final VoidCallback onClearFilterPressed;
  final HabitDisplaySearchActionsBuilder builder;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;
  final VoidCallback? onOpenSettingsPressed;
  final VoidCallback? onSelectButtonPressed;
  final bool? showSelectAction;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final collection = ActionCollection<HabitDisplaySearchActionPayload>(
      roots: [..._buildCommonActions(context, l10n), _buildFilterAction(l10n)],
    );
    return builder(
      context,
      HabitDisplaySearchActionsData(
        collection: collection,
        onInvoke: _onActionInvoked,
        material: MaterialAppBarActionsConfig(
          iconBuilder: _materialIcon,
          actionButtonBuilder: _materialButton,
        ),
        apple: CupertinoAppBarActionsConfig(
          iconBuilder: _appleIcon,
          presentationForAction: _applePresentation,
          actionButtonBuilder: _appleButton,
        ),
      ),
    );
  }

  List<AdaptiveAction<HabitDisplaySearchActionPayload>> _buildCommonActions(
    BuildContext context,
    L10n? l10n,
  ) {
    final effectiveShowSelectAction =
        showSelectAction ??
        DeviceContext.of(context).platform != TargetPlatform.android;
    return [
      if (effectiveShowSelectAction)
        AdaptiveAction.action(
          id: _selectId,
          metadata: ActionMetadata(
            label: l10n?.habitDisplay_selectButton_label ?? 'Select',
            tooltip: l10n?.habitDisplay_selectButton_label ?? 'Select',
            iconKey: _selectId.value,
          ),
          payload: (action: HabitDisplaySearchAction.select, habitType: null),
          isEnabled: onSelectButtonPressed != null,
          placementPolicy: ActionPlacementPolicy(
            automaticPreference: AutomaticPlacementPreference(
              retentionPriority: PrimaryRetentionPriority.high,
            ),
          ),
        ),
      if (AdaptiveNavScope.maybeOf(context)?.form ==
          NavigationShellForm.compact)
        AdaptiveAction.action(
          id: _openSettingsId,
          metadata: ActionMetadata(
            label: l10n?.appSetting_appbar_titleText ?? 'Settings',
            tooltip: l10n?.appSetting_appbar_titleText ?? 'Settings',
            iconKey: _openSettingsId.value,
          ),
          payload: (
            action: HabitDisplaySearchAction.openSettings,
            habitType: null,
          ),
          isEnabled: onOpenSettingsPressed != null,
        ),
      AdaptiveAction.action(
        id: _statisticsId,
        metadata: ActionMetadata(
          label: 'Statistics',
          iconKey: _statisticsId.value,
        ),
        payload: (action: HabitDisplaySearchAction.statistics, habitType: null),
        isEnabled: onInfoButtonPressed != null,
        placementPolicy: ActionPlacementPolicy(
          automaticPreference: AutomaticPlacementPreference(
            retentionPriority: PrimaryRetentionPriority.low,
          ),
        ),
      ),
      AdaptiveAction.action(
        id: _mainMenuId,
        metadata: ActionMetadata(
          label: MaterialLocalizations.of(context).showMenuTooltip,
          tooltip: MaterialLocalizations.of(context).showMenuTooltip,
          iconKey: _mainMenuId.value,
        ),
        payload: (action: HabitDisplaySearchAction.mainMenu, habitType: null),
        isEnabled: onMenuButtonPressed != null,
      ),
    ];
  }

  AdaptiveAction<HabitDisplaySearchActionPayload> _buildFilterAction(
    L10n? l10n,
  ) {
    final statusSummary = [
      if (options.activated)
        l10n?.habitDisplay_searchFilter_ongoing ?? 'Ongoing',
      if (options.completed)
        l10n?.habitDisplay_searchFilter_completed ?? 'Completed',
    ].joinLocalized(l10n);
    final typeSummary = [
      for (final type in HabitType.values)
        if (type != HabitType.unknown && options.types.contains(type))
          type.getTypeName(l10n),
    ].joinLocalized(l10n);
    return AdaptiveAction<HabitDisplaySearchActionPayload>.menu(
      id: habitDisplaySearchFilterActionId,
      metadata: ActionMetadata(
        label: l10n?.habitDisplay_searchFilter_tooltips ?? 'Show Filters',
        iconKey: habitDisplaySearchFilterActionId.value,
      ),
      placementPolicy: filterOverflowOnly
          ? ActionPlacementPolicy(placement: ActionPlacement.overflowOnly)
          : ActionPlacementPolicy(
              automaticPreference: AutomaticPlacementPreference(
                retentionPriority: PrimaryRetentionPriority.low,
              ),
            ),
      children: [
        AdaptiveAction<HabitDisplaySearchActionPayload>.menu(
          id: _filterStatusId,
          metadata: ActionMetadata(
            label: l10n?.habitDisplay_sortType_status ?? 'Completion Status',
            subtitle: statusSummary,
            iconKey: _filterStatusId.value,
          ),
          children: [
            AdaptiveAction.action(
              id: _filterOngoingId,
              metadata: ActionMetadata(
                label: l10n?.habitDisplay_searchFilter_ongoing ?? 'Ongoing',
                tooltip: l10n?.habitDisplay_searchFilter_ongoing_desc,
                iconKey: _filterOngoingId.value,
              ),
              payload: (
                action: HabitDisplaySearchAction.filterOngoing,
                habitType: null,
              ),
            ),
            AdaptiveAction.action(
              id: _filterCompletedId,
              metadata: ActionMetadata(
                label: l10n?.habitDisplay_searchFilter_completed ?? 'Completed',
                iconKey: _filterCompletedId.value,
              ),
              payload: (
                action: HabitDisplaySearchAction.filterCompleted,
                habitType: null,
              ),
            ),
          ],
        ),
        AdaptiveAction<HabitDisplaySearchActionPayload>.menu(
          id: _filterTypesId,
          metadata: ActionMetadata(
            label:
                l10n?.habitDisplay_searchFilter_habitType_groupTitle ??
                'Habit Type',
            subtitle: typeSummary,
            iconKey: _filterTypesId.value,
          ),
          children: [
            for (final type in HabitType.values)
              if (type != HabitType.unknown)
                AdaptiveAction.action(
                  id: _filterTypeId(type),
                  metadata: ActionMetadata(
                    label: type.getTypeName(l10n),
                    iconKey: _filterTypeId(type).value,
                  ),
                  payload: (
                    action: HabitDisplaySearchAction.filterType,
                    habitType: type,
                  ),
                ),
          ],
        ),
        if (!options.isFilterEmpty)
          const AdaptiveMenuDivider<HabitDisplaySearchActionPayload>.menuOnly(),
        if (!options.isFilterEmpty)
          AdaptiveAction.action(
            id: _clearFiltersId,
            metadata: ActionMetadata(
              label:
                  l10n?.habitDisplay_searchFilter_clearFilter ??
                  'Clear Filters',
              iconKey: _clearFiltersId.value,
              isDestructive: true,
            ),
            payload: (
              action: HabitDisplaySearchAction.clearFilters,
              habitType: null,
            ),
          ),
      ],
    );
  }

  void _onActionInvoked(
    BuildContext anchorContext,
    HabitDisplaySearchActionPayload payload,
  ) {
    switch (payload.action) {
      case HabitDisplaySearchAction.select:
        onSelectButtonPressed?.call();
      case HabitDisplaySearchAction.openSettings:
        onOpenSettingsPressed?.call();
      case HabitDisplaySearchAction.statistics:
        onInfoButtonPressed?.call();
      case HabitDisplaySearchAction.mainMenu:
        onMenuButtonPressed?.call();
      case HabitDisplaySearchAction.filterOngoing:
        onOngoingFilterToggled();
      case HabitDisplaySearchAction.filterCompleted:
        onCompletedFilterToggled();
      case HabitDisplaySearchAction.filterType:
        final type = payload.habitType;
        if (type != null) onTypeFilterToggled(type);
      case HabitDisplaySearchAction.clearFilters:
        onClearFilterPressed();
      case HabitDisplaySearchAction.filter ||
          HabitDisplaySearchAction.filterStatus ||
          HabitDisplaySearchAction.filterTypes:
        break;
    }
  }

  Widget _materialIcon(
    BuildContext context,
    AdaptiveAction<HabitDisplaySearchActionPayload> action,
  ) => Icon(switch (action.payload?.action) {
    HabitDisplaySearchAction.select => Icons.check_circle_outline,
    HabitDisplaySearchAction.openSettings => Icons.settings,
    HabitDisplaySearchAction.statistics => Icons.article_outlined,
    HabitDisplaySearchAction.mainMenu => Icons.more_vert_outlined,
    _ => Icons.more_vert,
  });

  Widget _appleIcon(
    BuildContext context,
    AdaptiveAction<HabitDisplaySearchActionPayload> action,
  ) {
    final payload = action.payload;
    final actionType =
        payload?.action ??
        (action.id == habitDisplaySearchFilterActionId
            ? HabitDisplaySearchAction.filter
            : action.id == _filterStatusId
            ? HabitDisplaySearchAction.filterStatus
            : action.id == _filterTypesId
            ? HabitDisplaySearchAction.filterTypes
            : null);
    return Icon(switch (actionType) {
      HabitDisplaySearchAction.select => CupertinoIcons.checkmark_alt_circle,
      HabitDisplaySearchAction.openSettings => CupertinoIcons.settings_solid,
      HabitDisplaySearchAction.statistics => Icons.article_outlined,
      HabitDisplaySearchAction.mainMenu => CupertinoIcons.ellipsis,
      HabitDisplaySearchAction.filter =>
        options.isFilterEmpty
            ? CupertinoIcons.line_horizontal_3_decrease_circle
            : CupertinoIcons.line_horizontal_3_decrease_circle_fill,
      HabitDisplaySearchAction.filterStatus =>
        options.activated || options.completed
            ? CupertinoIcons.check_mark_circled_solid
            : CupertinoIcons.check_mark_circled,
      HabitDisplaySearchAction.filterOngoing =>
        options.activated
            ? CupertinoIcons.play_circle_fill
            : CupertinoIcons.play_circle,
      HabitDisplaySearchAction.filterCompleted =>
        options.completed
            ? CupertinoIcons.check_mark_circled_solid
            : CupertinoIcons.check_mark_circled,
      HabitDisplaySearchAction.filterTypes =>
        options.types.isEmpty
            ? CupertinoIcons.square_grid_2x2
            : CupertinoIcons.square_grid_2x2_fill,
      HabitDisplaySearchAction.filterType =>
        options.types.contains(payload?.habitType)
            ? payload?.habitType == HabitType.normal
                  ? CupertinoIcons.plus_circle_fill
                  : CupertinoIcons.minus_circle_fill
            : payload?.habitType == HabitType.normal
            ? CupertinoIcons.plus_circle
            : CupertinoIcons.minus_circle,
      HabitDisplaySearchAction.clearFilters =>
        CupertinoIcons.clear_circled_solid,
      null => CupertinoIcons.ellipsis,
    });
  }

  Widget _materialButton(
    BuildContext context,
    AdaptiveAction<HabitDisplaySearchActionPayload> action,
    VoidCallback? onPressed,
    MaterialActionButtonDefaultBuilder<HabitDisplaySearchActionPayload>
    defaultBuilder,
  ) {
    final child = defaultBuilder(context, action, onPressed);
    return action.payload?.action == HabitDisplaySearchAction.openSettings
        ? KeyedSubtree(
            key: const ValueKey('open-settings-action'),
            child: child,
          )
        : child;
  }

  Widget _appleButton(
    BuildContext context,
    AdaptiveAction<HabitDisplaySearchActionPayload> action,
    VoidCallback? onPressed,
    CupertinoActionButtonDefaultBuilder<HabitDisplaySearchActionPayload>
    defaultBuilder,
  ) {
    if (action.payload?.action == HabitDisplaySearchAction.select) {
      return CupertinoButton(
        key: const ValueKey('habit-select-primary'),
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        onPressed: onPressed,
        child: Text(action.metadata.label, maxLines: 1, softWrap: false),
      );
    }
    final child = defaultBuilder(context, action, onPressed);
    return action.payload?.action == HabitDisplaySearchAction.openSettings
        ? KeyedSubtree(
            key: const ValueKey('open-settings-action'),
            child: child,
          )
        : child;
  }

  CupertinoActionPresentation _applePresentation(
    BuildContext context,
    AdaptiveAction<HabitDisplaySearchActionPayload> action,
  ) => action.payload?.action == HabitDisplaySearchAction.select
      ? CupertinoActionPresentation.extended
      : CupertinoActionPresentation.iconOnly;
}
