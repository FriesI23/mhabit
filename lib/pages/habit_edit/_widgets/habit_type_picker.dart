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

Future<HabitType?> showHabitTypSelectDialog({
  required BuildContext context,
  required HabitType habitType,
}) async {
  return showDialog<HabitType>(
    context: context,
    builder: (context) => HabitTypePicker(type: habitType),
  );
}

class HabitTypePicker extends StatelessWidget {
  final HabitType? type;

  const HabitTypePicker({super.key, this.type});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    Widget buildHabitTypeTile(BuildContext context, HabitType value) {
      return SimpleDialogOption(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value.getTypeName(l10n)),
            if (type == value) const Icon(Icons.check),
          ],
        ),
        onPressed: () => Navigator.of(context).maybePop<HabitType>(value),
      );
    }

    return SimpleDialog(
      title: l10n != null
          ? Text(l10n.habitEdit_habitTypeDialog_title)
          : const Text("Select habit type"),
      children: [
        buildHabitTypeTile(context, HabitType.normal),
        buildHabitTypeTile(context, HabitType.negative),
      ],
    );
  }
}
