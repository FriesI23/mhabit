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

class HabitEditTargetDaysTile extends StatelessWidget {
  final int targetDays;
  final void Function(BuildContext context, int targetDays)? onPressed;

  const HabitEditTargetDaysTile({
    super.key,
    required this.targetDays,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeDate = Theme.of(context);
    final l10n = L10n.of(context);

    return ListTile(
      leading: Icon(Icons.flag_outlined, color: themeDate.colorScheme.outline),
      title: l10n != null
          ? Text(l10n.habitEdit_targetDays_title(targetDays))
          : null,
      onTap: () => onPressed?.call(context, targetDays),
    );
  }
}
