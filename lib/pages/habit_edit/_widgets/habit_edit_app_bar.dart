// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../extensions/custom_color_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_color.dart';
import '../../../theme/color.dart';
import 'habit_edit_app_bar_actions.dart';

class HabitEditAppBar extends StatelessWidget {
  final String name;
  final HabitColor color;
  final TextEditingController controller;
  final double? scrolledUnderElevation;
  final bool autofocus;
  final bool isAppbarPinned;
  final bool showInFullscreenDialog;
  final bool showSaveButton;
  final ValueChanged<String>? onNameChanged;
  final VoidCallback? onSaveButtonPressed;

  const HabitEditAppBar({
    super.key,
    required this.name,
    required this.color,
    required this.controller,
    this.scrolledUnderElevation,
    required this.autofocus,
    required this.isAppbarPinned,
    required this.showInFullscreenDialog,
    this.showSaveButton = true,
    this.onNameChanged,
    this.onSaveButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = theme.extension<CustomColors>()?.getColor(
      color,
      brightness: theme.brightness,
    );
    final l10n = L10n.of(context);
    return AdaptiveEditableSliverAppBar(
      title: name,
      controller: controller,
      isCollapsed: isAppbarPinned,
      onChanged: onNameChanged,
      hintText: l10n?.habitEdit_habitName_hintText,
      autofocus: autofocus,
      foregroundColor: foregroundColor,
      leading: AdaptiveBackButton(
        type: showInFullscreenDialog
            ? AdaptiveBackButtonType.close
            : AdaptiveBackButtonType.back,
        color: foregroundColor,
      ),
      actions: [
        HabitEditAppBarActions(
          visible: showSaveButton,
          onSave: onSaveButtonPressed,
        ),
      ],
      styles: EditableAppBarStyles(
        material: MaterialEditableAppBarStyle(
          scrolledUnderElevation: scrolledUnderElevation,
          shadowColor: theme.colorScheme.shadow,
        ),
      ),
    );
  }
}
