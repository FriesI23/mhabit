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

import '../../../l10n/localizations.dart';
import '../../../models/habit_form.dart';

class HabitEditHabitTypeTile extends StatelessWidget {
  final HabitType habitType;
  final bool readOnly;
  final VoidCallback? onPressed;

  const HabitEditHabitTypeTile({
    super.key,
    required this.habitType,
    this.readOnly = false,
    this.onPressed,
  });

  String getHabitTypeName([L10n? l10n]) =>
      HabitType.getHabitTypeName(habitType, l10n);

  @override
  Widget build(BuildContext context) {
    final themeDate = Theme.of(context);
    final l10n = L10n.of(context);

    return ListTile(
      leading: Icon(
        habitType.getIcon(),
        color: themeDate.colorScheme.outline,
      ),
      title: Text(getHabitTypeName(l10n)),
      textColor: readOnly ? themeDate.colorScheme.outlineVariant : null,
      onTap: readOnly ? null : onPressed,
    );
  }
}
