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

import '../../../../l10n/localizations.dart';
import 'habit_display_options_actions.dart';

sealed class HabitDisplayViewAction {
  const HabitDisplayViewAction();
}

final class HabitDisplayViewSelectAction extends HabitDisplayViewAction {
  const HabitDisplayViewSelectAction();
}

final class HabitDisplayViewOpenSettingsAction extends HabitDisplayViewAction {
  const HabitDisplayViewOpenSettingsAction();
}

final class HabitDisplayViewStatisticsAction extends HabitDisplayViewAction {
  const HabitDisplayViewStatisticsAction();
}

final class HabitDisplayViewOptionAction extends HabitDisplayViewAction
    implements HabitDisplayOptionPayload {
  const HabitDisplayViewOptionAction(this.intent);

  @override
  final HabitDisplayPayloadOptionIntent intent;
}

final _selectId = ActionId('habits.view.select');
final _openSettingsId = ActionId('habits.view.open-settings');
final _statisticsId = ActionId('habits.view.statistics');

final class HabitDisplayViewAppBarConfig {
  const HabitDisplayViewAppBarConfig({
    this.onInfo,
    this.onOpenSettings,
    this.onSelect,
    this.config = const HabitDisplayConfig(),
    this.callbacks = const HabitDisplayOptionsCallbacks(),
  });

  final VoidCallback? onInfo;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onSelect;
  final HabitDisplayConfig config;
  final HabitDisplayOptionsCallbacks callbacks;
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
    required this.config,
    required this.builder,
    this.showSelectAction,
  });

  final HabitDisplayViewAppBarConfig config;
  final HabitDisplayViewActionsBuilder builder;
  final bool? showSelectAction;

  @override
  Widget build(BuildContext context) {
    final style = AdaptiveStyle.of(context);
    final filterPlacementPolicy = switch (style) {
      AdaptiveStyle.material => null,
      AdaptiveStyle.apple => ActionPlacementPolicy(
        placement: ActionPlacement.pinned,
      ),
    };
    return HabitDisplayOptionsActions<HabitDisplayViewAction>(
      config: config.config,
      callbacks: config.callbacks,
      payloadFor: HabitDisplayViewOptionAction.new,
      filterPlacementPolicy: filterPlacementPolicy,
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

  ActionCollection<HabitDisplayViewAction> _buildMaterialCollection(
    BuildContext context,
    HabitDisplayOptionsActionsData<HabitDisplayViewAction> displayOptionActions,
  ) {
    final l10n = L10n.of(context)!;
    final selectAction = _buildSelectAction(
      context,
      l10n,
      retentionPriority: PrimaryRetentionPriority.high,
    );
    final settingsAction = _buildSettingsAction(context, l10n);
    return ActionCollection<HabitDisplayViewAction>(
      roots: [
        ?selectAction,
        ?displayOptionActions.sortAction,
        ?displayOptionActions.filterAction,
        ?displayOptionActions.groupAction,
        _buildStatisticsAction(l10n),
        ?displayOptionActions.themeAction,
        ?settingsAction,
      ],
    );
  }

  ActionCollection<HabitDisplayViewAction> _buildAppleCollection(
    BuildContext context,
    HabitDisplayOptionsActionsData<HabitDisplayViewAction> displayOptionActions,
  ) {
    final l10n = L10n.of(context)!;
    final selectAction = _buildSelectAction(
      context,
      l10n,
      retentionPriority: PrimaryRetentionPriority.normal,
    );
    final settingsAction = _buildSettingsAction(context, l10n);
    return ActionCollection<HabitDisplayViewAction>(
      roots: [
        ?selectAction,
        ?displayOptionActions.sortAction,
        ?displayOptionActions.groupAction,
        _buildStatisticsAction(l10n),
        ?displayOptionActions.themeAction,
        ?settingsAction,
        ?displayOptionActions.filterAction,
      ],
    );
  }

  AdaptiveAction<HabitDisplayViewAction>? _buildSelectAction(
    BuildContext context,
    L10n l10n, {
    required PrimaryRetentionPriority retentionPriority,
  }) {
    final effectiveShowSelectAction =
        showSelectAction ??
        DeviceContext.of(context).platform != TargetPlatform.android;
    if (!effectiveShowSelectAction) return null;
    return AdaptiveAction.action(
      id: _selectId,
      metadata: ActionMetadata(
        label: l10n.habitDisplay_selectButton_label,
        tooltip: l10n.habitDisplay_selectButton_label,
        iconKey: _selectId.value,
      ),
      payload: const HabitDisplayViewSelectAction(),
      isEnabled: config.onSelect != null,
      placementPolicy: ActionPlacementPolicy(
        automaticPreference: AutomaticPlacementPreference(
          retentionPriority: retentionPriority,
        ),
      ),
    );
  }

  AdaptiveAction<HabitDisplayViewAction>? _buildSettingsAction(
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
      payload: const HabitDisplayViewOpenSettingsAction(),
      isEnabled: config.onOpenSettings != null,
    );
  }

  AdaptiveAction<HabitDisplayViewAction> _buildStatisticsAction(L10n l10n) =>
      AdaptiveAction.action(
        id: _statisticsId,
        metadata: ActionMetadata(
          label: l10n.habitDisplay_statisticsAction_label,
          iconKey: _statisticsId.value,
        ),
        payload: const HabitDisplayViewStatisticsAction(),
        isEnabled: config.onInfo != null,
        placementPolicy: ActionPlacementPolicy(
          automaticPreference: AutomaticPlacementPreference(
            retentionPriority: PrimaryRetentionPriority.high,
          ),
        ),
      );

  Widget _buildActions(
    BuildContext context,
    HabitDisplayOptionsActionsData<HabitDisplayViewAction> displayOptionActions,
    ActionCollection<HabitDisplayViewAction> collection,
  ) {
    const maxPrimaryActions = 2;
    final primaryCount = collection.roots
        .where(
          (action) =>
              action.placementPolicy.placement == ActionPlacement.pinned ||
              action.placementPolicy.placement == ActionPlacement.automatic,
        )
        .length;
    final needsOverflow = collection.roots.any(
      (action) =>
          action.placementPolicy.placement == ActionPlacement.overflowOnly,
    );
    final visiblePrimaryCount = primaryCount > maxPrimaryActions
        ? maxPrimaryActions
        : primaryCount;
    final hasResolvedOverflow =
        needsOverflow || primaryCount > maxPrimaryActions;
    return builder(
      context,
      HabitDisplayViewActionsData(
        collection: collection,
        onInvoke: (context, action) =>
            _onActionInvoked(action, displayOptionActions),
        primaryCapacity:
            (visiblePrimaryCount + (hasResolvedOverflow ? 1 : 0)) * 48.0,
        maxPrimaryActions: maxPrimaryActions,
        material: MaterialAppBarActionsConfig(
          iconBuilder: (context, action) =>
              _materialIcon(action, displayOptionActions),
          actionButtonBuilder: _materialButton,
          menuBuilderForAction: displayOptionActions.materialMenuForAction,
        ),
        apple: CupertinoAppBarActionsConfig(
          iconBuilder: (context, action) =>
              _appleIcon(action, displayOptionActions),
          actionButtonBuilder: _appleButton,
          menuBuilderForAction: displayOptionActions.appleMenuForAction,
          presentationForAction: _applePresentation,
        ),
      ),
    );
  }

  void _onActionInvoked(
    HabitDisplayViewAction action,
    HabitDisplayOptionsActionsData<HabitDisplayViewAction> displayOptionActions,
  ) {
    switch (action) {
      case HabitDisplayViewSelectAction():
        config.onSelect?.call();
      case HabitDisplayViewOpenSettingsAction():
        config.onOpenSettings?.call();
      case HabitDisplayViewStatisticsAction():
        config.onInfo?.call();
      case HabitDisplayViewOptionAction(:final intent):
        displayOptionActions.onInvoke(intent);
    }
  }

  Widget _materialIcon(
    AdaptiveAction<HabitDisplayViewAction> action,
    HabitDisplayOptionsActionsData<HabitDisplayViewAction> displayOptionActions,
  ) {
    final optionIcon = displayOptionActions.materialIconForAction(action);
    if (optionIcon != null) return optionIcon;
    return switch (action.payload) {
      HabitDisplayViewOptionAction() => const Icon(Icons.more_vert),
      HabitDisplayViewSelectAction() => const Icon(Icons.select_all),
      HabitDisplayViewOpenSettingsAction() => const Icon(Icons.settings),
      HabitDisplayViewStatisticsAction() => const Icon(Icons.bar_chart_rounded),
      null => const Icon(Icons.more_vert),
    };
  }

  Widget _appleIcon(
    AdaptiveAction<HabitDisplayViewAction> action,
    HabitDisplayOptionsActionsData<HabitDisplayViewAction> displayOptionActions,
  ) {
    final optionIcon = displayOptionActions.appleIconForAction(action);
    if (optionIcon != null) return optionIcon;
    return switch (action.payload) {
      HabitDisplayViewOptionAction() => const Icon(CupertinoIcons.ellipsis),
      HabitDisplayViewSelectAction() => const Icon(
        CupertinoIcons.checkmark_alt_circle,
      ),
      HabitDisplayViewOpenSettingsAction() => const Icon(
        CupertinoIcons.settings_solid,
      ),
      HabitDisplayViewStatisticsAction() => const Icon(
        CupertinoIcons.chart_bar,
      ),
      null => const Icon(CupertinoIcons.ellipsis),
    };
  }

  Widget _materialButton(
    BuildContext context,
    AdaptiveAction<HabitDisplayViewAction> action,
    VoidCallback? onPressed,
    MaterialActionButtonDefaultBuilder<HabitDisplayViewAction> defaultBuilder,
  ) {
    final child = defaultBuilder(context, action, onPressed);
    return switch (action.payload) {
      HabitDisplayViewOpenSettingsAction() => KeyedSubtree(
        key: const ValueKey('open-settings-action'),
        child: child,
      ),
      HabitDisplayViewSelectAction() ||
      HabitDisplayViewStatisticsAction() ||
      HabitDisplayViewOptionAction() ||
      null => child,
    };
  }

  Widget _appleButton(
    BuildContext context,
    AdaptiveAction<HabitDisplayViewAction> action,
    VoidCallback? onPressed,
    CupertinoActionButtonDefaultBuilder<HabitDisplayViewAction> defaultBuilder,
  ) => switch (action.payload) {
    HabitDisplayViewSelectAction() => CupertinoButton(
      key: const ValueKey('habit-select-primary'),
      sizeStyle: CupertinoButtonSize.small,
      onPressed: onPressed,
      child: Text(action.metadata.label, maxLines: 1, softWrap: false),
    ),
    HabitDisplayViewOpenSettingsAction() => KeyedSubtree(
      key: const ValueKey('open-settings-action'),
      child: defaultBuilder(context, action, onPressed),
    ),
    HabitDisplayViewStatisticsAction() ||
    HabitDisplayViewOptionAction() ||
    null => defaultBuilder(context, action, onPressed),
  };

  CupertinoActionPresentation _applePresentation(
    BuildContext context,
    AdaptiveAction<HabitDisplayViewAction> action,
  ) => switch (action.payload) {
    HabitDisplayViewSelectAction() => CupertinoActionPresentation.extended,
    HabitDisplayViewOpenSettingsAction() ||
    HabitDisplayViewStatisticsAction() ||
    HabitDisplayViewOptionAction() ||
    null => CupertinoActionPresentation.iconOnly,
  };
}
