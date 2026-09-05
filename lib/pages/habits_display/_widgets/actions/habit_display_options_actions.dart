// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0

import 'package:adaptive_actions/adaptive_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../common/consts.dart';
import '../../../../l10n/localizations.dart';
import '../../../../models/habit_display.dart';
import '../../../../models/habit_group_display.dart';
import '../../../../providers/app_ui/habits_sort.dart';
import '../../../../theme/color.dart';
import '../../../common/widgets.dart';

sealed class HabitDisplayOptionIntent {
  const HabitDisplayOptionIntent();
}

sealed class HabitDisplayPayloadOptionIntent extends HabitDisplayOptionIntent {
  const HabitDisplayPayloadOptionIntent();
}

abstract interface class HabitDisplayOptionPayload {
  HabitDisplayPayloadOptionIntent get intent;
}

sealed class HabitDisplaySortIntent extends HabitDisplayPayloadOptionIntent {
  const HabitDisplaySortIntent();
}

final class SelectHabitDisplaySortType extends HabitDisplaySortIntent {
  const SelectHabitDisplaySortType(this.type);

  final HabitDisplaySortType type;
}

final class ToggleHabitDisplaySortDirection extends HabitDisplaySortIntent {
  const ToggleHabitDisplaySortDirection();
}

sealed class HabitDisplayGroupIntent extends HabitDisplayPayloadOptionIntent {
  const HabitDisplayGroupIntent();
}

final class SelectHabitDisplayGroupType extends HabitDisplayGroupIntent {
  const SelectHabitDisplayGroupType(this.type);

  final HabitDisplayGroupType? type;
}

final class ToggleHabitDisplayGroupDirection extends HabitDisplayGroupIntent {
  const ToggleHabitDisplayGroupDirection();
}

sealed class HabitDisplayFilterIntent extends HabitDisplayOptionIntent {
  const HabitDisplayFilterIntent();

  HabitsDisplayFilter? applyTo(HabitsDisplayFilter filter);
}

enum HabitDisplayFilterTarget { inProgress, archived, completed }

final class ToggleHabitDisplayFilter extends HabitDisplayFilterIntent {
  const ToggleHabitDisplayFilter(this.target);

  final HabitDisplayFilterTarget target;

  @override
  HabitsDisplayFilter? applyTo(HabitsDisplayFilter filter) {
    final result = switch (target) {
      HabitDisplayFilterTarget.inProgress => filter.copyWith(
        allowInProgressHabits: !filter.allowInProgressHabits,
      ),
      HabitDisplayFilterTarget.archived => filter.copyWith(
        allowArchivedHabits: !filter.allowArchivedHabits,
      ),
      HabitDisplayFilterTarget.completed => filter.copyWith(
        allowCompleteHabits: !filter.allowCompleteHabits,
      ),
    };
    return result == HabitsDisplayFilter.allFalse ? null : result;
  }
}

sealed class HabitDisplayThemeIntent extends HabitDisplayPayloadOptionIntent {
  const HabitDisplayThemeIntent();
}

final class CycleHabitDisplayTheme extends HabitDisplayThemeIntent {
  const CycleHabitDisplayTheme();
}

final habitDisplaySortActionId = ActionId('habits.display-options.sort');
final _sortReverseActionId = ActionId('habits.display-options.sort.reverse');
final habitDisplayGroupActionId = ActionId('habits.display-options.group');
final habitDisplayFilterActionId = ActionId('habits.display-options.filter');
final habitDisplayThemeActionId = ActionId('habits.display-options.theme');
final _groupReverseActionId = ActionId('habits.display-options.group.reverse');

ActionId _groupTypeActionId(HabitDisplayGroupType? type) =>
    ActionId('habits.display-options.group.${type?.name ?? 'flat'}');

ActionId _sortTypeActionId(HabitDisplaySortType type) =>
    ActionId('habits.display-options.sort.${type.name}');

class HabitDisplayConfig {
  const HabitDisplayConfig({
    this.sortType = defaultSortType,
    this.sortDirection = defaultSortDirection,
    this.groupType,
    this.groupDirection = defaultGroupSortDirection,
    this.groupingVisible = false,
    this.displayFilter = const HabitsDisplayFilter.withDefault(),
    this.themeType = AppThemeType.followSystem,
  });

  final HabitDisplaySortType sortType;
  final HabitDisplaySortDirection sortDirection;
  final HabitDisplayGroupType? groupType;
  final HabitDisplaySortDirection groupDirection;
  final bool groupingVisible;
  final HabitsDisplayFilter displayFilter;
  final AppThemeType themeType;
}

class HabitDisplayOptionsCallbacks {
  const HabitDisplayOptionsCallbacks({
    this.onSortTypeSelected,
    this.onSortDirectionToggled,
    this.onGroupTypeSelected,
    this.onGroupDirectionToggled,
    this.onDisplayFilterChanged,
    this.onThemeToggled,
  });

  final ValueChanged<HabitDisplaySortType>? onSortTypeSelected;
  final VoidCallback? onSortDirectionToggled;
  final ValueChanged<HabitDisplayGroupType?>? onGroupTypeSelected;
  final VoidCallback? onGroupDirectionToggled;
  final ValueChanged<HabitsDisplayFilter>? onDisplayFilterChanged;
  final VoidCallback? onThemeToggled;

  bool get sortEnabled =>
      onSortTypeSelected != null || onSortDirectionToggled != null;
  bool get groupEnabled =>
      onGroupTypeSelected != null || onGroupDirectionToggled != null;
  bool get filterEnabled => onDisplayFilterChanged != null;
}

final class HabitDisplayOptionsActionsData<T extends Object> {
  const HabitDisplayOptionsActionsData({
    required this.sortAction,
    required this.filterAction,
    required this.groupAction,
    required this.themeAction,
    required this.onInvoke,
    required this.materialIconForAction,
    required this.appleIconForAction,
    required this.materialMenuForAction,
    required this.appleMenuForAction,
  });

  final AdaptiveAction<T>? sortAction;
  final AdaptiveAction<T>? filterAction;
  final AdaptiveAction<T>? groupAction;
  final AdaptiveAction<T>? themeAction;
  final ValueChanged<HabitDisplayPayloadOptionIntent> onInvoke;
  final Widget? Function(AdaptiveAction<T> action) materialIconForAction;
  final Widget? Function(AdaptiveAction<T> action) appleIconForAction;
  final List<Widget>? Function(BuildContext context, AdaptiveAction<T> action)
  materialMenuForAction;
  final List<Widget>? Function(BuildContext context, AdaptiveAction<T> action)
  appleMenuForAction;
}

typedef HabitDisplayOptionsActionsBuilder<T extends Object> =
    Widget Function(
      BuildContext context,
      HabitDisplayOptionsActionsData<T> data,
    );

class HabitDisplayOptionsActions<T extends Object> extends StatelessWidget {
  const HabitDisplayOptionsActions({
    super.key,
    required this.config,
    required this.callbacks,
    required this.payloadFor,
    required this.builder,
    this.sortPlacementPolicy,
    this.filterPlacementPolicy,
    this.groupPlacementPolicy,
  });

  final HabitDisplayConfig config;
  final HabitDisplayOptionsCallbacks callbacks;
  final T Function(HabitDisplayPayloadOptionIntent intent) payloadFor;
  final HabitDisplayOptionsActionsBuilder<T> builder;
  final ActionPlacementPolicy? sortPlacementPolicy;
  final ActionPlacementPolicy? filterPlacementPolicy;
  final ActionPlacementPolicy? groupPlacementPolicy;

  @override
  Widget build(BuildContext context) => builder(
    context,
    HabitDisplayOptionsActionsData(
      sortAction: callbacks.sortEnabled ? _buildSortAction(context) : null,
      filterAction: callbacks.filterEnabled
          ? _buildFilterAction(context)
          : null,
      groupAction: config.groupingVisible && callbacks.groupEnabled
          ? _buildGroupAction(context)
          : null,
      themeAction: callbacks.onThemeToggled != null
          ? _buildThemeAction(context)
          : null,
      onInvoke: _onInvoke,
      materialIconForAction: _materialIconForAction,
      appleIconForAction: _appleIconForAction,
      materialMenuForAction: _materialMenuForAction,
      appleMenuForAction: _appleMenuForAction,
    ),
  );

  AdaptiveAction<T> _buildThemeAction(BuildContext context) {
    final l10n = L10n.of(context)!;
    final label = switch (config.themeType) {
      AppThemeType.light => l10n.common_appThemeMode_light,
      AppThemeType.dark => l10n.common_appThemeMode_dark,
      AppThemeType.unknown ||
      AppThemeType.followSystem => l10n.common_appThemeMode_followSystem,
    };
    return AdaptiveAction.action(
      id: habitDisplayThemeActionId,
      metadata: ActionMetadata(
        label: label,
        tooltip: label,
        iconKey: habitDisplayThemeActionId.value,
      ),
      payload: payloadFor(const CycleHabitDisplayTheme()),
      placementPolicy: ActionPlacementPolicy(
        placement: ActionPlacement.overflowOnly,
      ),
    );
  }

  AdaptiveAction<T> _buildGroupAction(BuildContext context) {
    final l10n = L10n.of(context)!;
    return AdaptiveAction.menu(
      id: habitDisplayGroupActionId,
      metadata: ActionMetadata(
        label: l10n.habitDisplay_groupTypeDialog_title,
        subtitle: _groupTitle(config.groupType, config.groupDirection, l10n),
        tooltip: l10n.habitDisplay_groupTypeDialog_title,
        iconKey: habitDisplayGroupActionId.value,
      ),
      placementPolicy: groupPlacementPolicy,
      children: [
        for (final type in <HabitDisplayGroupType?>[
          null,
          ...HabitDisplayGroupType.menuOrderedList,
        ])
          AdaptiveAction.action(
            id: _groupTypeActionId(type),
            metadata: ActionMetadata(
              label: _groupTitle(type, null, l10n),
              iconKey: _groupTypeActionId(type).value,
            ),
            payload: payloadFor(SelectHabitDisplayGroupType(type)),
            isEnabled: callbacks.onGroupTypeSelected != null,
          ),
        AdaptiveMenuDivider<T>.menuOnly(),
        AdaptiveAction.action(
          id: _groupReverseActionId,
          metadata: ActionMetadata(
            label: l10n.habitDisplay_sort_reverseText,
            iconKey: _groupReverseActionId.value,
          ),
          payload: payloadFor(const ToggleHabitDisplayGroupDirection()),
          isEnabled:
              callbacks.onGroupDirectionToggled != null &&
              config.groupType != null &&
              config.groupType != HabitDisplayGroupType.manual,
        ),
      ],
    );
  }

  AdaptiveAction<T> _buildFilterAction(BuildContext context) {
    final label = L10n.of(context)!.habitDisplay_displayFilterAction_label;
    return AdaptiveAction.menu(
      id: habitDisplayFilterActionId,
      metadata: ActionMetadata(
        label: label,
        tooltip: label,
        iconKey: habitDisplayFilterActionId.value,
      ),
      placementPolicy: filterPlacementPolicy,
    );
  }

  AdaptiveAction<T> _buildSortAction(BuildContext context) {
    final l10n = L10n.of(context)!;
    return AdaptiveAction.menu(
      id: habitDisplaySortActionId,
      metadata: ActionMetadata(
        label: l10n.habitDisplay_sortTypeDialog_title,
        subtitle: HabitsSortViewModel.getSortTitle(
          config.sortType,
          config.sortDirection,
          l10n: l10n,
        ),
        tooltip: l10n.habitDisplay_sortTypeDialog_title,
        iconKey: habitDisplaySortActionId.value,
      ),
      placementPolicy: sortPlacementPolicy,
      children: [
        for (final type in HabitDisplaySortType.menuOrderedList)
          AdaptiveAction.action(
            id: _sortTypeActionId(type),
            metadata: ActionMetadata(
              label: HabitsSortViewModel.getSortTitle(type, null, l10n: l10n),
              iconKey: _sortTypeActionId(type).value,
            ),
            payload: payloadFor(SelectHabitDisplaySortType(type)),
            isEnabled: callbacks.onSortTypeSelected != null,
          ),
        AdaptiveMenuDivider<T>.menuOnly(),
        AdaptiveAction.action(
          id: _sortReverseActionId,
          metadata: ActionMetadata(
            label: l10n.habitDisplay_sort_reverseText,
            iconKey: _sortReverseActionId.value,
          ),
          payload: payloadFor(const ToggleHabitDisplaySortDirection()),
          isEnabled:
              callbacks.onSortDirectionToggled != null &&
              config.sortType != HabitDisplaySortType.manual,
        ),
      ],
    );
  }

  void _onInvoke(HabitDisplayPayloadOptionIntent intent) {
    switch (intent) {
      case SelectHabitDisplaySortType(:final type):
        callbacks.onSortTypeSelected?.call(type);
      case ToggleHabitDisplaySortDirection():
        callbacks.onSortDirectionToggled?.call();
      case SelectHabitDisplayGroupType(:final type):
        callbacks.onGroupTypeSelected?.call(type);
      case ToggleHabitDisplayGroupDirection():
        callbacks.onGroupDirectionToggled?.call();
      case CycleHabitDisplayTheme():
        callbacks.onThemeToggled?.call();
    }
  }

  Widget? _materialIconForAction(AdaptiveAction<T> action) {
    final rootIcon = _materialRootIcon(action.id);
    if (rootIcon != null) return rootIcon;
    final payload = action.payload;
    return payload == null ? null : _materialIntentIcon(payload);
  }

  Widget? _appleIconForAction(AdaptiveAction<T> action) {
    final rootIcon = _appleRootIcon(action.id);
    if (rootIcon != null) return rootIcon;
    final payload = action.payload;
    return payload == null ? null : _appleIntentIcon(payload);
  }

  HabitDisplayPayloadOptionIntent? _intentForPayload(T payload) {
    final intent = switch (payload) {
      HabitDisplayOptionPayload(:final intent) => intent,
      _ => null,
    };
    return intent;
  }

  Widget? _materialIntentIcon(T payload) {
    final intent = _intentForPayload(payload);
    if (intent == null) return null;
    return switch (intent) {
      SelectHabitDisplaySortType(:final type) => Icon(
        type == config.sortType
            ? Icons.check
            : HabitsSortViewModel.getSortIcon(type, config.sortDirection),
      ),
      ToggleHabitDisplaySortDirection() => Icon(
        config.sortDirection == HabitDisplaySortDirection.desc
            ? Icons.check
            : Icons.swap_vert,
      ),
      SelectHabitDisplayGroupType(:final type) =>
        type == config.groupType
            ? const Icon(Icons.check)
            : GroupingIcon(groupType: type, direction: config.groupDirection),
      ToggleHabitDisplayGroupDirection() => Icon(
        config.groupDirection == HabitDisplaySortDirection.desc
            ? Icons.check
            : Icons.swap_vert,
      ),
      CycleHabitDisplayTheme() => _themeIcon(),
    };
  }

  Widget? _appleIntentIcon(T payload) {
    final intent = _intentForPayload(payload);
    if (intent == null) return null;
    return switch (intent) {
      SelectHabitDisplaySortType(:final type) when type == config.sortType =>
        const Icon(CupertinoIcons.check_mark),
      ToggleHabitDisplaySortDirection()
          when config.sortDirection == HabitDisplaySortDirection.desc =>
        const Icon(CupertinoIcons.check_mark),
      SelectHabitDisplayGroupType(:final type) when type == config.groupType =>
        const Icon(CupertinoIcons.check_mark),
      ToggleHabitDisplayGroupDirection()
          when config.groupDirection == HabitDisplaySortDirection.desc =>
        const Icon(CupertinoIcons.check_mark),
      SelectHabitDisplaySortType() ||
      ToggleHabitDisplaySortDirection() ||
      SelectHabitDisplayGroupType() ||
      ToggleHabitDisplayGroupDirection() ||
      CycleHabitDisplayTheme() => _materialIntentIcon(payload),
    };
  }

  Widget? _materialRootIcon(ActionId id) => switch (id) {
    _ when id == habitDisplaySortActionId => Icon(
      HabitsSortViewModel.getSortIcon(config.sortType, config.sortDirection),
    ),
    _ when id == habitDisplayGroupActionId => const Icon(
      Icons.folder_copy_outlined,
    ),
    _ when id == habitDisplayFilterActionId => const Icon(
      Icons.checklist_rounded,
    ),
    _ => null,
  };

  Widget? _appleRootIcon(ActionId id) => switch (id) {
    _ when id == habitDisplaySortActionId => Icon(
      HabitsSortViewModel.getSortIcon(config.sortType, config.sortDirection),
    ),
    _ when id == habitDisplayGroupActionId => const Icon(CupertinoIcons.folder),
    _ when id == habitDisplayFilterActionId => const Icon(
      CupertinoIcons.list_bullet,
    ),
    _ => null,
  };

  Widget _themeIcon() => Icon(switch (config.themeType) {
    AppThemeType.light => Icons.light_mode_rounded,
    AppThemeType.dark => Icons.dark_mode_rounded,
    AppThemeType.unknown || AppThemeType.followSystem => Icons.hdr_auto_rounded,
  });

  List<Widget>? _materialMenuForAction(
    BuildContext context,
    AdaptiveAction<T> action,
  ) {
    if (action.id != habitDisplayFilterActionId) return null;
    final l10n = L10n.of(context)!;
    final filter = config.displayFilter;
    final onChanged = callbacks.onDisplayFilterChanged;
    return [
      for (final target in HabitDisplayFilterTarget.values)
        CheckboxMenuButton(
          value: _filterValue(target, filter),
          closeOnActivate: false,
          onChanged: switch (ToggleHabitDisplayFilter(target).applyTo(filter)) {
            final next? when onChanged != null => (_) => onChanged(next),
            _ => null,
          },
          child: Text(_filterLabel(target, l10n)),
        ),
    ];
  }

  List<Widget>? _appleMenuForAction(
    BuildContext context,
    AdaptiveAction<T> action,
  ) {
    if (action.id != habitDisplayFilterActionId) return null;
    final l10n = L10n.of(context)!;
    final filter = config.displayFilter;
    final onChanged = callbacks.onDisplayFilterChanged;
    return [
      for (final target in HabitDisplayFilterTarget.values)
        Builder(
          builder: (context) {
            final value = _filterValue(target, filter);
            final next = ToggleHabitDisplayFilter(target).applyTo(filter);
            return Semantics(
              checked: value,
              child: CupertinoMenuItem(
                leading: value
                    ? const Icon(CupertinoIcons.check_mark)
                    : const SizedBox(width: 18),
                requestCloseOnActivate: false,
                onPressed: onChanged == null || next == null
                    ? null
                    : () => onChanged(next),
                child: Text(_filterLabel(target, l10n)),
              ),
            );
          },
        ),
    ];
  }

  String _groupTitle(
    HabitDisplayGroupType? type,
    HabitDisplaySortDirection? direction,
    L10n l10n,
  ) {
    if (type == null) return l10n.habitDisplay_groupTypeDialog_none;
    final title = switch (type) {
      HabitDisplayGroupType.name => l10n.habitDisplay_groupType_name,
      HabitDisplayGroupType.colorType => l10n.habitDisplay_groupType_colorType,
      HabitDisplayGroupType.createDate =>
        l10n.habitDisplay_groupType_createDate,
      HabitDisplayGroupType.habitCount =>
        l10n.habitDisplay_groupType_habitCount,
      HabitDisplayGroupType.manual => l10n.habitDisplay_groupType_manual,
    };
    final suffix = switch (direction) {
      null => '',
      HabitDisplaySortDirection.asc => l10n.habitDisplay_sortDirection_asc,
      HabitDisplaySortDirection.desc => l10n.habitDisplay_sortDirection_Desc,
    };
    return suffix.isEmpty ? title : '$title $suffix';
  }

  String _filterLabel(HabitDisplayFilterTarget target, L10n l10n) =>
      switch (target) {
        HabitDisplayFilterTarget.inProgress =>
          l10n.habitDisplay_displayFilter_inProgress,
        HabitDisplayFilterTarget.archived =>
          l10n.habitDisplay_displayFilter_archived,
        HabitDisplayFilterTarget.completed =>
          l10n.habitDisplay_displayFilter_completed,
      };

  bool _filterValue(
    HabitDisplayFilterTarget target,
    HabitsDisplayFilter filter,
  ) => switch (target) {
    HabitDisplayFilterTarget.inProgress => filter.allowInProgressHabits,
    HabitDisplayFilterTarget.archived => filter.allowArchivedHabits,
    HabitDisplayFilterTarget.completed => filter.allowCompleteHabits,
  };
}
