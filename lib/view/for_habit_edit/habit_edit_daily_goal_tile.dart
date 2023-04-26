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

import '../../common/consts.dart';
import '../../common/re.dart';
import '../../extension/colorscheme_extensions.dart';
import '../../l10n/localizations.dart';

class HabitEditDailyGoalTile extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const HabitEditDailyGoalTile({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final textTheme = themeData.textTheme;
    final l10n = L10n.of(context);

    return ListTile(
      leading: Icon(Icons.show_chart_outlined, color: colorScheme.outline),
      title: TextField(
        controller: controller,
        decoration: InputDecoration(
            hintText:
                l10n?.habitEdit_habitDailyGoal_hintText(defaultHabitDailyGoal),
            hintStyle: TextStyle(color: colorScheme.outlineOpacity16),
            border: InputBorder.none),
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: false),
        inputFormatters: [TextFormatterCustom.decimalr2],
        style: textTheme.bodyLarge,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
