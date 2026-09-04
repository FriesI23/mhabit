// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:adaptive_actions/cupertino.dart';
import 'package:adaptive_actions/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../l10n/localizations.dart';

enum HabitDisplayViewAction { select, openSettings, statistics, mainMenu }

final _selectId = ActionId('habits.view.select');
final _openSettingsId = ActionId('habits.view.open-settings');
final _statisticsId = ActionId('habits.view.statistics');
final _mainMenuId = ActionId('habits.view.main-menu');

final class HabitDisplayViewAppBarCallbacks {
  const HabitDisplayViewAppBarCallbacks({
    this.onInfo,
    this.onSettings,
    this.onOpenSettings,
    this.onSelect,
  });

  final VoidCallback? onInfo;
  final VoidCallback? onSettings;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onSelect;
}

final class HabitDisplayViewActionsData {
  const HabitDisplayViewActionsData({
    required this.collection,
    required this.onInvoke,
    required this.primaryCapacity,
    required this.maxPrimaryActions,
    required this.material,
    required this.apple,
  });

  final ActionCollection<HabitDisplayViewAction> collection;
  final AdaptiveAppBarActionCallback<HabitDisplayViewAction> onInvoke;
  final double primaryCapacity;
  final int maxPrimaryActions;
  final MaterialAppBarActionsConfig<HabitDisplayViewAction> material;
  final CupertinoAppBarActionsConfig<HabitDisplayViewAction> apple;
}

typedef HabitDisplayViewActionsBuilder =
    Widget Function(BuildContext context, HabitDisplayViewActionsData data);

class HabitDisplayViewActions extends StatelessWidget {
  const HabitDisplayViewActions({
    super.key,
    required this.callbacks,
    required this.builder,
    this.showSelectAction,
  });

  final HabitDisplayViewAppBarCallbacks callbacks;
  final HabitDisplayViewActionsBuilder builder;
  final bool? showSelectAction;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final effectiveShowSelectAction =
        showSelectAction ??
        DeviceContext.of(context).platform != TargetPlatform.android;
    final collection = ActionCollection<HabitDisplayViewAction>(
      roots: [
        if (effectiveShowSelectAction)
          AdaptiveAction.action(
            id: _selectId,
            metadata: ActionMetadata(
              label: l10n?.habitDisplay_selectButton_label ?? 'Select',
              tooltip: l10n?.habitDisplay_selectButton_label ?? 'Select',
              iconKey: _selectId.value,
            ),
            payload: HabitDisplayViewAction.select,
            isEnabled: callbacks.onSelect != null,
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
            payload: HabitDisplayViewAction.openSettings,
            isEnabled: callbacks.onOpenSettings != null,
          ),
        AdaptiveAction.action(
          id: _statisticsId,
          metadata: ActionMetadata(
            label: 'Statistics',
            iconKey: _statisticsId.value,
          ),
          payload: HabitDisplayViewAction.statistics,
          isEnabled: callbacks.onInfo != null,
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
          payload: HabitDisplayViewAction.mainMenu,
          isEnabled: callbacks.onSettings != null,
        ),
      ],
    );
    final maxPrimaryActions = switch (WindowSize.of(context).width) {
      WindowSizeClass.compact => 2,
      WindowSizeClass.medium => 3,
      _ => 4,
    };
    return builder(
      context,
      HabitDisplayViewActionsData(
        collection: collection,
        onInvoke: _onActionInvoked,
        primaryCapacity: (collection.roots.length + 1) * 48.0,
        maxPrimaryActions: maxPrimaryActions,
        material: MaterialAppBarActionsConfig(
          iconBuilder: _materialIcon,
          actionButtonBuilder: _materialButton,
        ),
        apple: CupertinoAppBarActionsConfig(
          iconBuilder: _appleIcon,
          actionButtonBuilder: _appleButton,
          presentationForAction: _applePresentation,
        ),
      ),
    );
  }

  void _onActionInvoked(
    BuildContext anchorContext,
    HabitDisplayViewAction action,
  ) {
    switch (action) {
      case HabitDisplayViewAction.select:
        callbacks.onSelect?.call();
      case HabitDisplayViewAction.openSettings:
        callbacks.onOpenSettings?.call();
      case HabitDisplayViewAction.statistics:
        callbacks.onInfo?.call();
      case HabitDisplayViewAction.mainMenu:
        callbacks.onSettings?.call();
    }
  }

  Widget _materialIcon(
    BuildContext context,
    AdaptiveAction<HabitDisplayViewAction> action,
  ) => Icon(switch (action.payload) {
    HabitDisplayViewAction.select => Icons.check_circle_outline,
    HabitDisplayViewAction.openSettings => Icons.settings,
    HabitDisplayViewAction.statistics => Icons.article_outlined,
    HabitDisplayViewAction.mainMenu => Icons.more_vert_outlined,
    null => Icons.more_vert,
  });

  Widget _appleIcon(
    BuildContext context,
    AdaptiveAction<HabitDisplayViewAction> action,
  ) => Icon(switch (action.payload) {
    HabitDisplayViewAction.select => CupertinoIcons.checkmark_alt_circle,
    HabitDisplayViewAction.openSettings => CupertinoIcons.settings_solid,
    HabitDisplayViewAction.statistics => Icons.article_outlined,
    HabitDisplayViewAction.mainMenu => CupertinoIcons.ellipsis,
    null => CupertinoIcons.ellipsis,
  });

  Widget _materialButton(
    BuildContext context,
    AdaptiveAction<HabitDisplayViewAction> action,
    VoidCallback? onPressed,
    MaterialActionButtonDefaultBuilder<HabitDisplayViewAction> defaultBuilder,
  ) {
    final child = defaultBuilder(context, action, onPressed);
    return action.payload == HabitDisplayViewAction.openSettings
        ? KeyedSubtree(
            key: const ValueKey('open-settings-action'),
            child: child,
          )
        : child;
  }

  Widget _appleButton(
    BuildContext context,
    AdaptiveAction<HabitDisplayViewAction> action,
    VoidCallback? onPressed,
    CupertinoActionButtonDefaultBuilder<HabitDisplayViewAction> defaultBuilder,
  ) {
    if (action.payload == HabitDisplayViewAction.select) {
      return CupertinoButton(
        key: const ValueKey('habit-select-primary'),
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        onPressed: onPressed,
        child: Text(action.metadata.label, maxLines: 1, softWrap: false),
      );
    }
    final child = defaultBuilder(context, action, onPressed);
    return action.payload == HabitDisplayViewAction.openSettings
        ? KeyedSubtree(
            key: const ValueKey('open-settings-action'),
            child: child,
          )
        : child;
  }

  CupertinoActionPresentation _applePresentation(
    BuildContext context,
    AdaptiveAction<HabitDisplayViewAction> action,
  ) => action.payload == HabitDisplayViewAction.select
      ? CupertinoActionPresentation.extended
      : CupertinoActionPresentation.iconOnly;
}
