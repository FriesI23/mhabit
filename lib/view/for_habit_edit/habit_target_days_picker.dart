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
import 'package:flutter/services.dart';

import '../../common/consts.dart';
import '../../common/logging.dart';
import '../../l10n/localizations.dart';

Future<int?> showHabitTargetDaysPickerDialog(
    {required BuildContext context, required int targetDays}) async {
  return showDialog<int>(
    context: context,
    builder: (context) => HabitTargetDaysPickerDialog(targetDays),
  );
}

enum _HabitTargetDaysType { days21, days66, days180, daysCustom }

class HabitTargetDaysPickerDialog extends StatefulWidget {
  final int targetDays;

  const HabitTargetDaysPickerDialog(this.targetDays, {super.key});

  @override
  State<StatefulWidget> createState() => _HabitTargetDaysDialogView();
}

class _HabitTargetDaysDialogView extends State<HabitTargetDaysPickerDialog> {
  late _HabitTargetDaysType selectTargetDaysType;
  late int customTargetDays;
  late TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    selectTargetDaysType = getTargetDaysType(widget.targetDays);
    customTargetDays = selectTargetDaysType != _HabitTargetDaysType.daysCustom
        ? defaultHabitCustomTargetDays
        : widget.targetDays;
    _inputController = TextEditingController();
    _inputController.text = customTargetDays.toString();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  int get currentTargetDay => getTargetDaysNum(selectTargetDaysType);

  int getTargetDaysNum(_HabitTargetDaysType t) {
    switch (t) {
      case _HabitTargetDaysType.days21:
        return 21;
      case _HabitTargetDaysType.days66:
        return 66;
      case _HabitTargetDaysType.days180:
        return 180;
      case _HabitTargetDaysType.daysCustom:
        return customTargetDays;
    }
  }

  _HabitTargetDaysType getTargetDaysType(int targetDays) {
    switch (targetDays) {
      case 21:
        return _HabitTargetDaysType.days21;
      case 66:
        return _HabitTargetDaysType.days66;
      case 180:
        return _HabitTargetDaysType.days180;
      default:
        return _HabitTargetDaysType.daysCustom;
    }
  }

  String _getTargetDayText(int targetDays, L10n? l10n) {
    return [targetDays, l10n?.habitEdit_targetDays ?? ''].join(" ");
  }

  void _onRadioChangeCallback(value) {
    if (value != null) {
      selectTargetDaysType = value;
      Navigator.pop(context, currentTargetDay);
    }
  }

  void _onCustomTargetDaysInputChange(value) {
    int newValue;
    try {
      newValue = int.parse(value);
    } on FormatException {
      newValue = defaultHabitTargetDays;
    }
    if (newValue >= maxHabitTargetDays) {
    } else if (newValue <= minHabitTargetDays) {
      newValue = minHabitTargetDays;
    }
    customTargetDays = newValue;
  }

  @override
  Widget build(BuildContext context) {
    DebugLog.rebuild("dialog targetDays: "
        "$selectTargetDaysType, $customTargetDays | $currentTargetDay");

    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    final l10n = L10n.of(context);

    final textScaleFactor =
        math.min(MediaQuery.textScaleFactorOf(context), 1.3);

    return LayoutBuilder(
      builder: (context, constraints) => AlertDialog(
        title: constraints.maxHeight > dialogshowTitleMaxHeight
            ? Text(l10n?.habitEidt_targetDays_dialogTitle ?? '')
            : null,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(width: 300),
              ListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: Radio(
                  value: _HabitTargetDaysType.days21,
                  groupValue: selectTargetDaysType,
                  onChanged: (value) => _onRadioChangeCallback(value),
                ),
                title: Text(_getTargetDayText(21, l10n)),
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: Radio(
                  value: _HabitTargetDaysType.days66,
                  groupValue: selectTargetDaysType,
                  onChanged: (value) => _onRadioChangeCallback(value),
                ),
                title: Text(_getTargetDayText(66, l10n)),
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: Radio(
                  value: _HabitTargetDaysType.days180,
                  groupValue: selectTargetDaysType,
                  onChanged: (value) => _onRadioChangeCallback(value),
                ),
                title: Text(_getTargetDayText(180, l10n)),
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: Radio(
                  value: _HabitTargetDaysType.daysCustom,
                  groupValue: selectTargetDaysType,
                  onChanged: (value) => _onRadioChangeCallback(value),
                ),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: SizedBox(
                        height: 30 * textScaleFactor,
                        width: 48 * textScaleFactor,
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: _inputController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: false, signed: false),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                                maxHabitTargetDays.toString().length)
                          ],
                          style: textTheme.bodyLarge,
                          onChanged: (value) =>
                              _onCustomTargetDaysInputChange(value),
                          onSubmitted: (value) {
                            if (selectTargetDaysType ==
                                _HabitTargetDaysType.daysCustom) {
                              _onRadioChangeCallback(selectTargetDaysType);
                            }
                          },
                        ),
                      ),
                    ),
                    if (l10n != null && l10n.habitEdit_targetDays.isNotEmpty)
                      Expanded(
                        flex: 3,
                        child: Text(l10n.habitEdit_targetDays),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
