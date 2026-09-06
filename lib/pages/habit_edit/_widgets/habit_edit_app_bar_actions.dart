// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:adaptive_actions/core.dart';
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../l10n/localizations.dart';

const _saveActionCapacity = 144.0;

enum _HabitEditAppBarAction { save }

final _saveActionId = ActionId('habit-edit.save');

class HabitEditAppBarActions extends StatelessWidget {
  const HabitEditAppBarActions({super.key, required this.visible, this.onSave});

  final bool visible;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final saveLabel = L10n.of(context)?.habitEdit_saveButton_text ?? 'Save';
    final collection = ActionCollection<_HabitEditAppBarAction>(
      roots: [
        AdaptiveAction.action(
          id: _saveActionId,
          metadata: ActionMetadata(label: saveLabel, tooltip: saveLabel),
          payload: _HabitEditAppBarAction.save,
          isEnabled: visible && onSave != null,
          placementPolicy: ActionPlacementPolicy(
            placement: ActionPlacement.pinned,
          ),
        ),
      ],
    );
    return AdaptiveAppBarActions<_HabitEditAppBarAction>(
      collection: collection,
      onInvoke: (_, _) => onSave?.call(),
      primaryCapacity: _saveActionCapacity,
      maxPrimaryActions: 1,
      primaryActionDecorator: (_, _, child) => AnimatedOpacity(
        key: const ValueKey('habit-edit.save-visibility'),
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: !visible,
          child: ExcludeSemantics(excluding: !visible, child: child),
        ),
      ),
    );
  }
}
