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
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/consts.dart';
import '../../common/re.dart';
import '../../common/rules.dart';
import '../../common/types.dart';
import '../../component/widget.dart';
import '../../extension/colorscheme_extensions.dart';
import '../../l10n/localizations.dart';
import '../../model/habit_date.dart';
import '../../model/habit_form.dart';

Future<HabitDailyGoal?> showHabitRecordCustomNumberPickerDialog({
  required BuildContext context,
  required HabitDailyRecordForm recordForm,
  required HabitRecordStatus recordStatus,
  HabitDate? recordDate,
}) async {
  return showDialog<HabitDailyGoal>(
    context: context,
    builder: (context) => HabitRecordCustomNumberPickerDialog(
      recordForm: recordForm,
      recordStatus: recordStatus,
      recordDate: recordDate,
    ),
  );
}

class HabitRecordCustomNumberPickerDialog extends StatefulWidget {
  final HabitDailyRecordForm recordForm;
  final HabitRecordStatus recordStatus;
  final HabitDate? recordDate;

  const HabitRecordCustomNumberPickerDialog({
    super.key,
    required this.recordForm,
    required this.recordStatus,
    this.recordDate,
  });

  @override
  State<StatefulWidget> createState() => _HabitRecordCustomNumberPickerDialog();
}

class _HabitRecordCustomNumberPickerDialog
    extends State<HabitRecordCustomNumberPickerDialog> {
  static const double dialogMaxWidth = 400.0;

  late final TextEditingController _inputController;

  late HabitDailyGoal? _result;

  @override
  void initState() {
    String initText = '';
    switch (widget.recordStatus) {
      case HabitRecordStatus.unknown:
      case HabitRecordStatus.done:
        initText = widget.recordForm.value.toString();
        _result = widget.recordForm.value;
        break;
      case HabitRecordStatus.skip:
        break;
    }
    _inputController = TextEditingController(text: initText);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _inputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final textTheme = themeData.textTheme;
    final l10n = L10n.of(context);

    final Widget normalValChip = ActionChip(
      iconTheme: IconThemeData(color: colorScheme.primary),
      avatar: const FittedBox(child: Icon(Icons.check_circle_rounded)),
      label: Text(l10n?.habitDetail_changeGoal_doneChipText(
              widget.recordForm.targetValue) ??
          "Done: ${widget.recordForm.targetValue}"),
      onPressed: () {
        _result = widget.recordForm.targetValue;
        _inputController.text = _result.toString();
      },
    );

    final Widget zeroValChip = ActionChip(
      iconTheme: IconThemeData(color: colorScheme.primary),
      avatar: const FittedBox(child: Icon(Icons.cancel_rounded)),
      label: l10n != null
          ? Text(l10n.habitDetail_changeGoal_undoneChipText)
          : const Text("Undone"),
      backgroundColor: null,
      onPressed: () {
        _result = minHabitDailyGoal;
        _inputController.text = _result.toString();
      },
    );

    Widget buildLastValChip() {
      return ActionChip(
        iconTheme: IconThemeData(color: colorScheme.primary),
        label: Text(l10n?.habitDetail_changeGoal_currentChipText(
                widget.recordForm.value) ??
            "Current: ${widget.recordForm.value}"),
        onPressed: () {
          _result = widget.recordForm.value;
          _inputController.text = _result.toString();
        },
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      var complateStatus = widget.recordForm.complateStatus;
      return AlertDialog(
        scrollable: true,
        title: l10n != null
            ? Text(l10n.habitDetail_changeGoal_title)
            : const Text("Change goal"),
        insetPadding: kExpanedDailogInsetPadding,
        contentPadding: const EdgeInsets.only(left: 24.0, right: 24.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChipList(
              height: 56,
              width: math.min(constraints.maxWidth, dialogMaxWidth),
              padding: EdgeInsets.zero,
              children: [
                if (complateStatus != HabitDailyComplateStatus.ok &&
                    complateStatus != HabitDailyComplateStatus.zero)
                  buildLastValChip(),
                normalValChip,
                zeroValChip,
              ],
            ),
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                  hintText: l10n?.habitDetail_changeGoal_helpText(
                          defaultHabitDailyGoal) ??
                      "Daily goal, default: $defaultHabitDailyGoal",
                  hintStyle: TextStyle(color: colorScheme.outlineOpacity16),
                  helperText: widget.recordDate != null
                      ? DateFormat.yMMMd(l10n?.localeName)
                          .format(widget.recordDate!)
                      : null,
                  counterText: "${NumberFormat().format(minHabitDailyGoal)}"
                      " ~ "
                      "${NumberFormat().format(maxHabitdailyGoal)}"),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: false),
              inputFormatters: [TextFormatterCustom.decimalr2],
              style: textTheme.bodyLarge,
              onChanged: (value) {
                num newDailyGoal;
                try {
                  newDailyGoal = num.parse(value);
                } on FormatException {
                  newDailyGoal = defaultHabitDailyGoal;
                }
                _result = onDailyGoalTextInputChanged(newDailyGoal,
                    controller: _inputController, allowInputZero: true);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
              child: ButtonBar(
                buttonPadding: EdgeInsets.zero,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: l10n != null
                        ? Text(l10n.habitDetail_changeGoal_cancelText)
                        : const Text('cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, _result);
                    },
                    child: l10n != null
                        ? Text(l10n.habitDetail_changeGoal_saveText)
                        : const Text('save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
