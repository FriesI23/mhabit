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
import 'package:flutter/services.dart';

import '../../../common/consts.dart';
import '../../../common/utils.dart';
import '../../../l10n/localizations.dart';
import '../../../logging/helper.dart';

class HabitTargetDaysPickerResult {
  final int targetDays;
  final bool isCustomDaysType;

  const HabitTargetDaysPickerResult(this.targetDays,
      {this.isCustomDaysType = false});
}

Future<HabitTargetDaysPickerResult?> showHabitTargetDaysPickerDialog({
  required BuildContext context,
  required int targetDays,
  int? initialCustomTargetDays,
}) async {
  return showDialog<HabitTargetDaysPickerResult>(
    context: context,
    builder: (context) => HabitTargetDaysPickerDialog(
      targetDays,
      initialCustomTargetDays: initialCustomTargetDays,
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
  final int? initialCustomTargetDays;

  const HabitTargetDaysPickerDialog(
    this.targetDays, {
    super.key,
    this.initialCustomTargetDays,
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
    // overwrite the last filled-in number saved in global cache
    if (selectTargetDaysType != _HabitTargetDaysType.daysCustom) {
      customTargetDays = widget.initialCustomTargetDays != null
          ? widget.initialCustomTargetDays!
          : defaultHabitCustomTargetDays;
    } else {
      customTargetDays = widget.targetDays;
    }
    _inputController = TextEditingController();
    _inputController.text = customTargetDays.toString();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  int _validateTargetDays(int day) =>
      clampInt<int>(day, min: minHabitTargetDays, max: maxHabitTargetDays);

  int get currentTargetDay => selectTargetDaysType.days ?? customTargetDays;

  void _onRadioChangeCallback(_HabitTargetDaysType? value) {
    value = value ?? selectTargetDaysType;
    selectTargetDaysType = value;
    // Text field might be empty in custom type when submitted;
    // recompute the final value and type here.
    final resultDay = _validateTargetDays(currentTargetDay);
    final resultDayType = _HabitTargetDaysType.getTargetDaysType(resultDay);
    final result = HabitTargetDaysPickerResult(resultDay,
        isCustomDaysType: resultDayType == _HabitTargetDaysType.daysCustom);
    Navigator.pop(context, result);
  }

  void _onCustomTargetDaysInputChanged(String? value) {
    final newValue = value == null
        ? defaultHabitTargetDays
        : int.tryParse(value) ?? defaultHabitTargetDays;

    customTargetDays = _validateTargetDays(newValue);
  }

  void _onCustomTargetDaysSubmitted(String? value) {
    if (selectTargetDaysType == _HabitTargetDaysType.daysCustom) {
      _onRadioChangeCallback(selectTargetDaysType);
    }
  }

  @override
  Widget build(BuildContext context) {
    appLog.build.debug(context,
        ex: [selectTargetDaysType, customTargetDays, currentTargetDay]);

    final l10n = L10n.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => AlertDialog(
        title: constraints.maxHeight > dialogshowTitleMaxHeight
            ? Text(l10n?.habitEdit_targetDays_dialogTitle ?? '')
            : null,
        content: SingleChildScrollView(
          child: RadioGroup(
            groupValue: selectTargetDaysType,
            onChanged: _onRadioChangeCallback,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 300),
                for (var days in _HabitTargetDaysType.values)
                  if (days != _HabitTargetDaysType.daysCustom)
                    _HabitSpecificTargetDaysTile(
                      value: days,
                    ),
                _HabitCustomTargetDaysTile(
                  inputController: _inputController,
                  onCustomTargetDaysChanged: _onCustomTargetDaysInputChanged,
                  onCustomTargetDaysSubmitted: _onCustomTargetDaysSubmitted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitSpecificTargetDaysTile extends StatelessWidget {
  final _HabitTargetDaysType value;

  const _HabitSpecificTargetDaysTile({
    required this.value,
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
      leading: Radio<_HabitTargetDaysType>(value: value),
      title: Text(_getTargetDayText(value.days!, l10n)),
    );
  }
}

class _HabitCustomTargetDaysTile extends StatelessWidget {
  final TextEditingController? inputController;
  final ValueChanged<String?>? onCustomTargetDaysChanged;
  final ValueChanged<String?>? onCustomTargetDaysSubmitted;

  const _HabitCustomTargetDaysTile({
    this.inputController,
    this.onCustomTargetDaysChanged,
    this.onCustomTargetDaysSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final textScaler =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);

    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    final l10n = L10n.of(context);

    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      leading: const Radio<_HabitTargetDaysType>(
          value: _HabitTargetDaysType.daysCustom, toggleable: true),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: SizedBox(
              height: textScaler.scale(30.0),
              width: textScaler.scale(48.0),
              child: TextField(
                decoration: const InputDecoration(hintText: "", isDense: true),
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
