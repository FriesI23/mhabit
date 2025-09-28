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

import '../../common/re.dart';
import '../../extension/colorscheme_extensions.dart';
import '../../l10n/localizations.dart';
import '../../model/habit_form.dart';

class HabitEditDailyGoalExtraTile extends StatelessWidget {
  final bool isValid;
  final HabitType habitType;
  final num? dailyGoal;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const HabitEditDailyGoalExtraTile({
    super.key,
    this.isValid = true,
    required this.habitType,
    this.dailyGoal,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  String? _getHintText([L10n? l10n]) {
    switch (habitType) {
      case HabitType.unknown:
        return null;
      case HabitType.normal:
        return l10n?.habitEdit_habitDailyGoalExtra_hintText;
      case HabitType.negative:
        return l10n?.habitEdit_habitDailyGoalExtra_negativeHintText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final textTheme = themeData.textTheme;
    final l10n = L10n.of(context);

    return ListTile(
      leading: Icon(Icons.auto_graph_outlined, color: colorScheme.outline),
      title: TextField(
        controller: controller,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: _getHintText(l10n),
          hintStyle: TextStyle(color: colorScheme.outlineOpacity64),
          border: InputBorder.none,
          errorText: isValid || dailyGoal == null
              ? null
              : l10n?.habitEdit_habitDailyGoalExtra_errorText(dailyGoal!) ??
                  "invalid value, must be empty or >= $dailyGoal",
          suffixIcon: isValid ? null : const Icon(Icons.error_outline),
          suffixIconConstraints: const BoxConstraints.tightFor(height: 0.0),
        ),
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: false),
        inputFormatters: [TextFormatterCustom.decimalr2],
        style: textTheme.bodyLarge,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
      titleAlignment: ListTileTitleAlignment.titleHeight,
    );
  }
}
