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

Future<int?> showHabitTargetDaysPickerDialog({
  required BuildContext context,
  required int targetDays,
  int? customShowTargetDays,
}) async {
  return showDialog<int>(
    context: context,
    builder: (context) => HabitTargetDaysPickerDialog(
      targetDays,
      customShowTargetDays: customShowTargetDays,
    ),
  );
}

enum _HabitTargetDaysType {
  days21(_days21),
  days66(_days66),
  days120(_days120),
  days180(_days180),
  daysCustom(null);

  static const _days21 = 21;
  static const _days66 = defaultHabitTargetDays;
  static const _days120 = 120;
  static const _days180 = 180;

  final int? days;

  const _HabitTargetDaysType(this.days);

  static _HabitTargetDaysType getTargetDaysType(int targetDays) {
    switch (targetDays) {
      case _days21:
        return days21;
      case _days66:
        return days66;
      case _days120:
        return days120;
      case _days180:
        return days180;
      default:
        return _HabitTargetDaysType.daysCustom;
    }
  }
}

class HabitTargetDaysPickerDialog extends StatefulWidget {
  final int targetDays;
  final int? customShowTargetDays;

  const HabitTargetDaysPickerDialog(
    this.targetDays, {
    super.key,
    this.customShowTargetDays,
  });

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
    selectTargetDaysType =
        _HabitTargetDaysType.getTargetDaysType(widget.targetDays);
    customTargetDays = widget.customShowTargetDays ??
        (selectTargetDaysType != _HabitTargetDaysType.daysCustom
            ? defaultHabitCustomTargetDays
            : widget.targetDays);
    _inputController = TextEditingController();
    _inputController.text = customTargetDays.toString();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  int get currentTargetDay => selectTargetDaysType.days ?? customTargetDays;

  void _onRadioChangeCallback(_HabitTargetDaysType? value) {
    if (value != null) {
      selectTargetDaysType = value;
      Navigator.pop(context, currentTargetDay);
    }
  }

  void _onCustomTargetDaysInputChanged(String? value) {
    int newValue = value == null
        ? defaultHabitTargetDays
        : int.tryParse(value) ?? defaultHabitTargetDays;

    if (newValue >= maxHabitTargetDays) {
    } else if (newValue <= minHabitTargetDays) {
      newValue = minHabitTargetDays;
    }
    customTargetDays = newValue;
  }

  void _onCustomTargetDaysSubmitted(String? value) {
    if (selectTargetDaysType == _HabitTargetDaysType.daysCustom) {
      _onRadioChangeCallback(selectTargetDaysType);
    }
  }

  @override
  Widget build(BuildContext context) {
    DebugLog.rebuild("dialog targetDays: "
        "$selectTargetDaysType, $customTargetDays | $currentTargetDay");

    final l10n = L10n.of(context);

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
              for (var days in _HabitTargetDaysType.values)
                if (days != _HabitTargetDaysType.daysCustom)
                  _HabitSpecificTargetDaysTile(
                    value: days,
                    groupValue: selectTargetDaysType,
                    onRadioChanged: _onRadioChangeCallback,
                  ),
              _HabitCustomTargetDaysTile(
                groupValue: selectTargetDaysType,
                inputController: _inputController,
                onRadioChanged: _onRadioChangeCallback,
                onCustomTargetDaysChanged: _onCustomTargetDaysInputChanged,
                onCustomTargetDaysSubmitted: _onCustomTargetDaysSubmitted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitSpecificTargetDaysTile extends StatelessWidget {
  final _HabitTargetDaysType value;
  final _HabitTargetDaysType? groupValue;
  final ValueChanged<_HabitTargetDaysType?>? onRadioChanged;

  const _HabitSpecificTargetDaysTile({
    required this.value,
    this.groupValue,
    this.onRadioChanged,
  });

  String _getTargetDayText(int targetDays, L10n? l10n) {
    return [targetDays, l10n?.habitEdit_targetDays ?? ''].join(" ");
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      leading: Radio<_HabitTargetDaysType>(
        value: value,
        groupValue: groupValue,
        onChanged: onRadioChanged,
      ),
      title: Text(_getTargetDayText(value.days!, l10n)),
    );
  }
}

class _HabitCustomTargetDaysTile extends StatelessWidget {
  final _HabitTargetDaysType? groupValue;
  final TextEditingController? inputController;
  final ValueChanged<_HabitTargetDaysType?>? onRadioChanged;
  final ValueChanged<String?>? onCustomTargetDaysChanged;
  final ValueChanged<String?>? onCustomTargetDaysSubmitted;

  const _HabitCustomTargetDaysTile({
    this.groupValue,
    this.inputController,
    this.onRadioChanged,
    this.onCustomTargetDaysChanged,
    this.onCustomTargetDaysSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final textScaleFactor =
        math.min(MediaQuery.textScaleFactorOf(context), 1.3);

    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    final l10n = L10n.of(context);

    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      leading: Radio<_HabitTargetDaysType>(
        value: _HabitTargetDaysType.daysCustom,
        groupValue: groupValue,
        onChanged: onRadioChanged,
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
                controller: inputController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: false, signed: false),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                      maxHabitTargetDays.toString().length)
                ],
                style: textTheme.bodyLarge,
                onChanged: onCustomTargetDaysChanged,
                onSubmitted: onCustomTargetDaysSubmitted,
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
    );
  }
}
