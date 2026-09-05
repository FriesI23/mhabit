// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:adaptive_actions/cupertino.dart';
import 'package:adaptive_actions/material.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoButton, CupertinoButtonSize, CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../../extensions/iterable_extensions.dart';
import '../../../../l10n/localizations.dart';
import '../../../../models/habit_display.dart';
import '../../../../models/habit_form.dart';
import 'habit_display_options_actions.dart';

sealed class HabitDisplaySearchAction {
  const HabitDisplaySearchAction();
}

final class HabitDisplaySearchSelectAction extends HabitDisplaySearchAction {
  const HabitDisplaySearchSelectAction();
}

final class HabitDisplaySearchOpenSettingsAction
    extends HabitDisplaySearchAction {
  const HabitDisplaySearchOpenSettingsAction();
}

final class HabitDisplaySearchStatisticsAction
    extends HabitDisplaySearchAction {
  const HabitDisplaySearchStatisticsAction();
}

final class HabitDisplaySearchOptionAction extends HabitDisplaySearchAction
    implements HabitDisplayOptionPayload {
  const HabitDisplaySearchOptionAction(this.intent);

  @override
  final HabitDisplayPayloadOptionIntent intent;
}

sealed class HabitDisplaySearchFilterAction extends HabitDisplaySearchAction {
  const HabitDisplaySearchFilterAction();
}

enum HabitDisplaySearchStatus { ongoing, completed }

final class ToggleHabitDisplaySearchStatus
    extends HabitDisplaySearchFilterAction {
  const ToggleHabitDisplaySearchStatus(this.status);

  final HabitDisplaySearchStatus status;
}

final class ToggleHabitDisplaySearchType
    extends HabitDisplaySearchFilterAction {
  const ToggleHabitDisplaySearchType(this.type);

  final HabitType type;
}

final class ClearHabitDisplaySearchFilters
    extends HabitDisplaySearchFilterAction {
  const ClearHabitDisplaySearchFilters();
}

final _selectId = ActionId('habits.search.select');
final _openSettingsId = ActionId('habits.search.open-settings');
final _statisticsId = ActionId('habits.search.statistics');
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

  final ActionCollection<HabitDisplaySearchAction> collection;
  final AdaptiveAppBarActionCallback<HabitDisplaySearchAction> onInvoke;
  final MaterialAppBarActionsConfig<HabitDisplaySearchAction> material;
  final CupertinoAppBarActionsConfig<HabitDisplaySearchAction> apple;
}

typedef HabitDisplaySearchActionsBuilder =
    Widget Function(BuildContext context, HabitDisplaySearchActionsData data);

final class HabitDisplaySearchConfig {
  const HabitDisplaySearchConfig({
    required this.options,
    required this.onOngoingFilterToggled,
    required this.onCompletedFilterToggled,
    required this.onTypeFilterToggled,
    required this.onClearFilterPressed,
    this.onInfoButtonPressed,
    this.onOpenSettingsPressed,
    this.onSelectButtonPressed,
    this.display = const HabitDisplayConfig(),
    this.callbacks = const HabitDisplayOptionsCallbacks(),
  });

  final HabitDisplaySearchOptions options;
  final VoidCallback onOngoingFilterToggled;
  final VoidCallback onCompletedFilterToggled;
  final ValueChanged<HabitType> onTypeFilterToggled;
  final VoidCallback onClearFilterPressed;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onOpenSettingsPressed;
  final VoidCallback? onSelectButtonPressed;
  final HabitDisplayConfig display;
  final HabitDisplayOptionsCallbacks callbacks;
}

class HabitDisplaySearchActions extends StatelessWidget {
  const HabitDisplaySearchActions({
    super.key,
    required this.config,
    required this.filterOverflowOnly,
    required this.builder,
    required this.compactWidth,
    this.showSelectAction,
  });

  final HabitDisplaySearchConfig config;
  final bool filterOverflowOnly;
  final HabitDisplaySearchActionsBuilder builder;
  final bool compactWidth;
  final bool? showSelectAction;

  @override
  Widget build(BuildContext context) {
    final style = AdaptiveStyle.of(context);
    return HabitDisplayOptionsActions<HabitDisplaySearchAction>(
      config: config.display,
      callbacks: config.callbacks,
      payloadFor: HabitDisplaySearchOptionAction.new,
      sortPlacementPolicy: compactWidth
          ? ActionPlacementPolicy(placement: ActionPlacement.overflowOnly)
          : ActionPlacementPolicy(),
      filterPlacementPolicy: compactWidth
          ? ActionPlacementPolicy(placement: ActionPlacement.overflowOnly)
          : ActionPlacementPolicy(),
      groupPlacementPolicy: ActionPlacementPolicy(
        placement: ActionPlacement.overflowOnly,
      ),
      builder: (context, displayOptionActions) {
        final collection = switch (style) {
          AdaptiveStyle.material => _buildMaterialCollection(
            context,
            displayOptionActions,
          ),
          AdaptiveStyle.apple => _buildAppleCollection(
            context,
            displayOptionActions,
          ),
        };
        return _buildActions(context, displayOptionActions, collection);
      },
    );
  }

  ActionCollection<HabitDisplaySearchAction> _buildMaterialCollection(
    BuildContext context,
    HabitDisplayOptionsActionsData<HabitDisplaySearchAction>
    displayOptionActions,
  ) {
    final l10n = L10n.of(context)!;
    final commonActions = _buildCommonActions(
      context,
      l10n,
      displayOptionActions,
      selectRetentionPriority: PrimaryRetentionPriority.high,
    );
    final settingsAction = _buildSettingsAction(context, l10n);
    return ActionCollection<HabitDisplaySearchAction>(
      roots: [
        ...commonActions,
        _buildMaterialFilterAction(l10n),
        ?settingsAction,
      ],
    );
  }

  ActionCollection<HabitDisplaySearchAction> _buildAppleCollection(
    BuildContext context,
    HabitDisplayOptionsActionsData<HabitDisplaySearchAction>
    displayOptionActions,
  ) {
    final l10n = L10n.of(context)!;
    final commonActions = _buildCommonActions(
      context,
      l10n,
      displayOptionActions,
      selectRetentionPriority: PrimaryRetentionPriority.normal,
    );
    final settingsAction = _buildSettingsAction(context, l10n);
    return ActionCollection<HabitDisplaySearchAction>(
      roots: [...commonActions, ?settingsAction, _buildAppleFilterAction(l10n)],
    );
  }

  Widget _buildActions(
    BuildContext context,
    HabitDisplayOptionsActionsData<HabitDisplaySearchAction>
    displayOptionActions,
    ActionCollection<HabitDisplaySearchAction> collection,
  ) {
    return builder(
      context,
      HabitDisplaySearchActionsData(
        collection: collection,
        onInvoke: (context, action) =>
            _onActionInvoked(action, displayOptionActions),
        material: MaterialAppBarActionsConfig(
          iconBuilder: (context, action) =>
              _materialIcon(action, displayOptionActions),
          actionButtonBuilder: _materialButton,
          menuBuilderForAction: displayOptionActions.materialMenuForAction,
        ),
        apple: CupertinoAppBarActionsConfig(
          iconBuilder: (context, action) =>
              _appleIcon(action, displayOptionActions),
          presentationForAction: _applePresentation,
          actionButtonBuilder: _appleButton,
          menuBuilderForAction: displayOptionActions.appleMenuForAction,
        ),
      ),
    );
  }

  List<AdaptiveAction<HabitDisplaySearchAction>> _buildCommonActions(
    BuildContext context,
    L10n l10n,
    HabitDisplayOptionsActionsData<HabitDisplaySearchAction>
    displayOptionActions, {
    required PrimaryRetentionPriority selectRetentionPriority,
  }) {
    final effectiveShowSelectAction =
        showSelectAction ??
        DeviceContext.of(context).platform != TargetPlatform.android;
    return [
      if (effectiveShowSelectAction)
        AdaptiveAction.action(
          id: _selectId,
          metadata: ActionMetadata(
            label: l10n.habitDisplay_selectButton_label,
            tooltip: l10n.habitDisplay_selectButton_label,
            iconKey: _selectId.value,
          ),
          payload: const HabitDisplaySearchSelectAction(),
          isEnabled: config.onSelectButtonPressed != null,
          placementPolicy: ActionPlacementPolicy(
            automaticPreference: AutomaticPlacementPreference(
              retentionPriority: selectRetentionPriority,
            ),
          ),
        ),
      ?displayOptionActions.sortAction,
      ?displayOptionActions.filterAction,
      ?displayOptionActions.groupAction,
      AdaptiveAction.action(
        id: _statisticsId,
        metadata: ActionMetadata(
          label: l10n.habitDisplay_statisticsAction_label,
          iconKey: _statisticsId.value,
        ),
        payload: const HabitDisplaySearchStatisticsAction(),
        isEnabled: config.onInfoButtonPressed != null,
        placementPolicy: ActionPlacementPolicy(
          automaticPreference: AutomaticPlacementPreference(
            retentionPriority: PrimaryRetentionPriority.high,
          ),
        ),
      ),
      ?displayOptionActions.themeAction,
    ];
  }

  AdaptiveAction<HabitDisplaySearchAction>? _buildSettingsAction(
    BuildContext context,
    L10n l10n,
  ) {
    if (AdaptiveNavScope.maybeOf(context)?.form !=
        NavigationShellForm.compact) {
      return null;
    }
    return AdaptiveAction.action(
      id: _openSettingsId,
      metadata: ActionMetadata(
        label: l10n.appSetting_appbar_titleText,
        tooltip: l10n.appSetting_appbar_titleText,
        iconKey: _openSettingsId.value,
      ),
      payload: const HabitDisplaySearchOpenSettingsAction(),
      isEnabled: config.onOpenSettingsPressed != null,
    );
  }

  AdaptiveAction<HabitDisplaySearchAction> _buildMaterialFilterAction(
    L10n l10n,
  ) => _buildFilterAction(
    l10n,
    placementPolicy: filterOverflowOnly
        ? ActionPlacementPolicy(placement: ActionPlacement.overflowOnly)
        : ActionPlacementPolicy(
            automaticPreference: AutomaticPlacementPreference(
              retentionPriority: PrimaryRetentionPriority.high,
            ),
          ),
  );

  AdaptiveAction<HabitDisplaySearchAction> _buildAppleFilterAction(L10n l10n) =>
      _buildFilterAction(
        l10n,
        placementPolicy: ActionPlacementPolicy(
          placement: ActionPlacement.pinned,
        ),
      );

  AdaptiveAction<HabitDisplaySearchAction> _buildFilterAction(
    L10n l10n, {
    required ActionPlacementPolicy placementPolicy,
  }) {
    final statusSummary = [
      if (config.options.activated) l10n.habitDisplay_searchFilter_ongoing,
      if (config.options.completed) l10n.habitDisplay_searchFilter_completed,
    ].joinLocalized(l10n);
    final typeSummary = [
      for (final type in HabitType.values)
        if (type != HabitType.unknown && config.options.types.contains(type))
          type.getTypeName(l10n),
    ].joinLocalized(l10n);
    return AdaptiveAction<HabitDisplaySearchAction>.menu(
      id: habitDisplaySearchFilterActionId,
      metadata: ActionMetadata(
        label: l10n.habitDisplay_searchFilter_tooltips,
        iconKey: habitDisplaySearchFilterActionId.value,
      ),
      placementPolicy: placementPolicy,
      children: [
        AdaptiveAction<HabitDisplaySearchAction>.menu(
          id: _filterStatusId,
          metadata: ActionMetadata(
            label: l10n.habitDisplay_sortType_status,
            subtitle: statusSummary,
            iconKey: _filterStatusId.value,
          ),
          children: [
            AdaptiveAction.action(
              id: _filterOngoingId,
              metadata: ActionMetadata(
                label: l10n.habitDisplay_searchFilter_ongoing,
                tooltip: l10n.habitDisplay_searchFilter_ongoing_desc,
                iconKey: _filterOngoingId.value,
              ),
              payload: const ToggleHabitDisplaySearchStatus(
                HabitDisplaySearchStatus.ongoing,
              ),
            ),
            AdaptiveAction.action(
              id: _filterCompletedId,
              metadata: ActionMetadata(
                label: l10n.habitDisplay_searchFilter_completed,
                iconKey: _filterCompletedId.value,
              ),
              payload: const ToggleHabitDisplaySearchStatus(
                HabitDisplaySearchStatus.completed,
              ),
            ),
          ],
        ),
        AdaptiveAction<HabitDisplaySearchAction>.menu(
          id: _filterTypesId,
          metadata: ActionMetadata(
            label: l10n.habitDisplay_searchFilter_habitType_groupTitle,
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
                  payload: ToggleHabitDisplaySearchType(type),
                ),
          ],
        ),
        if (!config.options.isFilterEmpty)
          const AdaptiveMenuDivider<HabitDisplaySearchAction>.menuOnly(),
        if (!config.options.isFilterEmpty)
          AdaptiveAction.action(
            id: _clearFiltersId,
            metadata: ActionMetadata(
              label: l10n.habitDisplay_searchFilter_clearFilter,
              iconKey: _clearFiltersId.value,
              isDestructive: true,
            ),
            payload: const ClearHabitDisplaySearchFilters(),
          ),
      ],
    );
  }

  void _onActionInvoked(
    HabitDisplaySearchAction action,
    HabitDisplayOptionsActionsData<HabitDisplaySearchAction>
    displayOptionActions,
  ) {
    switch (action) {
      case HabitDisplaySearchSelectAction():
        config.onSelectButtonPressed?.call();
      case HabitDisplaySearchOpenSettingsAction():
        config.onOpenSettingsPressed?.call();
      case HabitDisplaySearchStatisticsAction():
        config.onInfoButtonPressed?.call();
      case HabitDisplaySearchOptionAction(:final intent):
        displayOptionActions.onInvoke(intent);
      case ToggleHabitDisplaySearchStatus(:final status):
        switch (status) {
          case HabitDisplaySearchStatus.ongoing:
            config.onOngoingFilterToggled();
          case HabitDisplaySearchStatus.completed:
            config.onCompletedFilterToggled();
        }
      case ToggleHabitDisplaySearchType(:final type):
        config.onTypeFilterToggled(type);
      case ClearHabitDisplaySearchFilters():
        config.onClearFilterPressed();
    }
  }

  Widget _materialIcon(
    AdaptiveAction<HabitDisplaySearchAction> action,
    HabitDisplayOptionsActionsData<HabitDisplaySearchAction>
    displayOptionActions,
  ) {
    final optionIcon = displayOptionActions.materialIconForAction(action);
    if (optionIcon != null) return optionIcon;
    return switch (action.payload) {
      HabitDisplaySearchOptionAction() => const Icon(Icons.more_vert),
      HabitDisplaySearchSelectAction() => const Icon(Icons.select_all),
      HabitDisplaySearchOpenSettingsAction() => const Icon(Icons.settings),
      HabitDisplaySearchStatisticsAction() => const Icon(
        Icons.bar_chart_rounded,
      ),
      ToggleHabitDisplaySearchStatus() ||
      ToggleHabitDisplaySearchType() ||
      ClearHabitDisplaySearchFilters() ||
      null => const Icon(Icons.more_vert),
    };
  }

  Widget _appleIcon(
    AdaptiveAction<HabitDisplaySearchAction> action,
    HabitDisplayOptionsActionsData<HabitDisplaySearchAction>
    displayOptionActions,
  ) {
    final payload = action.payload;
    final optionIcon = displayOptionActions.appleIconForAction(action);
    if (optionIcon != null) return optionIcon;
    if (action.id == habitDisplaySearchFilterActionId) {
      return Icon(
        config.options.isFilterEmpty
            ? CupertinoIcons.line_horizontal_3_decrease_circle
            : CupertinoIcons.line_horizontal_3_decrease_circle_fill,
      );
    }
    if (action.id == _filterStatusId) {
      return Icon(
        config.options.activated || config.options.completed
            ? CupertinoIcons.check_mark_circled_solid
            : CupertinoIcons.check_mark_circled,
      );
    }
    if (action.id == _filterTypesId) {
      return Icon(
        config.options.types.isEmpty
            ? CupertinoIcons.square_grid_2x2
            : CupertinoIcons.square_grid_2x2_fill,
      );
    }
    return switch (payload) {
      HabitDisplaySearchOptionAction() => const Icon(CupertinoIcons.ellipsis),
      HabitDisplaySearchSelectAction() => const Icon(
        CupertinoIcons.checkmark_alt_circle,
      ),
      HabitDisplaySearchOpenSettingsAction() => const Icon(
        CupertinoIcons.settings_solid,
      ),
      HabitDisplaySearchStatisticsAction() => const Icon(
        CupertinoIcons.chart_bar,
      ),
      ToggleHabitDisplaySearchStatus(:final status) => Icon(switch (status) {
        HabitDisplaySearchStatus.ongoing =>
          config.options.activated
              ? CupertinoIcons.play_circle_fill
              : CupertinoIcons.play_circle,
        HabitDisplaySearchStatus.completed =>
          config.options.completed
              ? CupertinoIcons.check_mark_circled_solid
              : CupertinoIcons.check_mark_circled,
      }),
      ToggleHabitDisplaySearchType(:final type) => Icon(
        config.options.types.contains(type)
            ? type == HabitType.normal
                  ? CupertinoIcons.plus_circle_fill
                  : CupertinoIcons.minus_circle_fill
            : type == HabitType.normal
            ? CupertinoIcons.plus_circle
            : CupertinoIcons.minus_circle,
      ),
      ClearHabitDisplaySearchFilters() => const Icon(
        CupertinoIcons.clear_circled_solid,
      ),
      null => const Icon(CupertinoIcons.ellipsis),
    };
  }

  Widget _materialButton(
    BuildContext context,
    AdaptiveAction<HabitDisplaySearchAction> action,
    VoidCallback? onPressed,
    MaterialActionButtonDefaultBuilder<HabitDisplaySearchAction> defaultBuilder,
  ) {
    final child = defaultBuilder(context, action, onPressed);
    return switch (action.payload) {
      HabitDisplaySearchOpenSettingsAction() => KeyedSubtree(
        key: const ValueKey('open-settings-action'),
        child: child,
      ),
      HabitDisplaySearchSelectAction() ||
      HabitDisplaySearchStatisticsAction() ||
      HabitDisplaySearchOptionAction() ||
      ToggleHabitDisplaySearchStatus() ||
      ToggleHabitDisplaySearchType() ||
      ClearHabitDisplaySearchFilters() ||
      null => child,
    };
  }

  Widget _appleButton(
    BuildContext context,
    AdaptiveAction<HabitDisplaySearchAction> action,
    VoidCallback? onPressed,
    CupertinoActionButtonDefaultBuilder<HabitDisplaySearchAction>
    defaultBuilder,
  ) => switch (action.payload) {
    HabitDisplaySearchSelectAction() => CupertinoButton(
      key: const ValueKey('habit-select-primary'),
      sizeStyle: CupertinoButtonSize.small,
      onPressed: onPressed,
      child: Text(action.metadata.label, maxLines: 1, softWrap: false),
    ),
    HabitDisplaySearchOpenSettingsAction() => KeyedSubtree(
      key: const ValueKey('open-settings-action'),
      child: defaultBuilder(context, action, onPressed),
    ),
    HabitDisplaySearchStatisticsAction() ||
    HabitDisplaySearchOptionAction() ||
    ToggleHabitDisplaySearchStatus() ||
    ToggleHabitDisplaySearchType() ||
    ClearHabitDisplaySearchFilters() ||
    null => defaultBuilder(context, action, onPressed),
  };

  CupertinoActionPresentation _applePresentation(
    BuildContext context,
    AdaptiveAction<HabitDisplaySearchAction> action,
  ) => switch (action.payload) {
    HabitDisplaySearchSelectAction() => CupertinoActionPresentation.extended,
    HabitDisplaySearchOpenSettingsAction() ||
    HabitDisplaySearchStatisticsAction() ||
    HabitDisplaySearchOptionAction() ||
    ToggleHabitDisplaySearchStatus() ||
    ToggleHabitDisplaySearchType() ||
    ClearHabitDisplaySearchFilters() ||
    null => CupertinoActionPresentation.iconOnly,
  };
}
