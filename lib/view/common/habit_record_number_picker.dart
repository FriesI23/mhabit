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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../common/consts.dart';
import '../../common/re.dart';
import '../../common/rules.dart';
import '../../common/types.dart';
import '../../component/widget.dart';
import '../../extension/colorscheme_extensions.dart';
import '../../extension/num_extensions.dart';
import '../../l10n/localizations.dart';
import '../../model/habit_daily_record_form.dart';
import '../../model/habit_date.dart';
import '../../model/habit_form.dart';

Future<HabitDailyGoal?> showHabitRecordCustomNumberPickerDialog({
  required BuildContext context,
  required HabitDailyRecordForm recordForm,
  required HabitRecordStatus recordStatus,
  HabitDailyGoal? targetExtraValue,
  HabitDate? recordDate,
  HabitColorType? colorType,
}) async {
  return showDialog<HabitDailyGoal>(
    context: context,
    builder: (context) => ThemeWithCustomColors(
      colorType: colorType,
      child: HabitRecordCustomNumberPickerDialog(
        recordForm: recordForm,
        recordStatus: recordStatus,
        recordTargetExtraValue: targetExtraValue,
        recordDate: recordDate,
      ),
    ),
  );
}

class HabitRecordCustomNumberPickerDialog extends StatefulWidget {
  final HabitDailyRecordForm recordForm;
  final HabitRecordStatus recordStatus;
  final HabitDailyGoal? recordTargetExtraValue;
  final HabitDate? recordDate;

  const HabitRecordCustomNumberPickerDialog({
    super.key,
    required this.recordForm,
    required this.recordStatus,
    this.recordTargetExtraValue,
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
        initText = widget.recordForm.value.toSimpleString();
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

  bool _isTextFieldIncreaseButtonEnabled() {
    if (_result != null && _result! >= maxHabitdailyGoal) {
      return false;
    } else {
      return true;
    }
  }

  bool _isTextFieldDecreaseButtonEnabled() {
    if (_result != null && _result! <= minHabitDailyGoal) {
      return false;
    } else {
      return true;
    }
  }

  bool _isButtonNeedRebuild(num lastValue, num newValue) {
    if (lastValue == minHabitDailyGoal ||
        newValue == minHabitDailyGoal ||
        lastValue == maxHabitdailyGoal ||
        newValue == maxHabitdailyGoal) {
      return true;
    } else {
      return false;
    }
  }

  void _onTextFieldIncreaseButtonPressed() {
    final currentValue = num.tryParse(_inputController.text);
    if (currentValue == null) return;
    final newValue = currentValue + 1;
    _inputController.text = newValue.toSimpleString(fixedDigit: 2);
    _inputController.selection = TextSelection(
        baseOffset: _inputController.text.length,
        extentOffset: _inputController.text.length);
    _result = onDailyGoalTextInputChanged(newValue,
        controller: _inputController, allowInputZero: true);

    if (_isButtonNeedRebuild(currentValue, _result!)) {
      setState(() {});
    }
  }

  void _onTextFieldDecreaseButtonPressed() {
    final currentValue = num.tryParse(_inputController.text);
    if (currentValue == null) return;
    num newValue;
    if (currentValue < 1 + minHabitDailyGoal &&
        currentValue > minHabitDailyGoal) {
      newValue = 0;
    } else if (currentValue > 0) {
      newValue = currentValue - 1;
    } else {
      newValue = 0;
    }
    _inputController.text = newValue.toSimpleString(fixedDigit: 2);
    _inputController.selection = TextSelection(
        baseOffset: _inputController.text.length,
        extentOffset: _inputController.text.length);
    _result = onDailyGoalTextInputChanged(newValue,
        controller: _inputController, allowInputZero: true);

    if (_isButtonNeedRebuild(currentValue, _result!)) {
      setState(() {});
    }
  }

  void _onTextFieldValueChanged(String value) {
    num newDailyGoal;
    try {
      newDailyGoal = num.parse(value);
    } on FormatException {
      newDailyGoal = defaultHabitDailyGoal;
    }
    final currentValue = _result;
    _result = onDailyGoalTextInputChanged(newDailyGoal,
        controller: _inputController, allowInputZero: true);

    if (currentValue != null && _isButtonNeedRebuild(currentValue, _result!)) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    final Widget normalValChip = ActionChip(
      avatar: const FittedBox(child: Icon(MdiIcons.checkCircle)),
      label: Text(l10n?.habitDetail_changeGoal_doneChipText(
              widget.recordForm.targetValue.toSimpleString()) ??
          "Done: ${widget.recordForm.targetValue.toSimpleString()}"),
      onPressed: () {
        _result = widget.recordForm.targetValue;
        if (_result != null) {
          _inputController.text = _result!.toSimpleString();
        }
      },
    );

    final Widget zeroValChip = ActionChip(
      avatar: const FittedBox(child: Icon(MdiIcons.closeCircle)),
      label: l10n != null
          ? Text(l10n.habitDetail_changeGoal_undoneChipText)
          : const Text("Undone"),
      backgroundColor: null,
      onPressed: () {
        _result = minHabitDailyGoal;
        if (_result != null) {
          _inputController.text = _result!.toSimpleString();
        }
      },
    );

    Widget? buildExtraValChip() {
      if (widget.recordTargetExtraValue == null) return null;
      return ActionChip(
        avatar: const FittedBox(child: Icon(MdiIcons.checkUnderlineCircle)),
        label: Text(l10n?.habitDetail_changeGoal_extraChipText(
                widget.recordTargetExtraValue!.toSimpleString()) ??
            "Extra: ${widget.recordTargetExtraValue!.toSimpleString()}"),
        onPressed: () {
          _result = widget.recordTargetExtraValue;
          if (_result != null) {
            _inputController.text = _result!.toSimpleString();
          }
        },
      );
    }

    Widget buildLastValChip() {
      return ActionChip(
        label: Text(l10n?.habitDetail_changeGoal_currentChipText(
                widget.recordForm.value.toSimpleString()) ??
            "Current: ${widget.recordForm.value.toSimpleString()}"),
        onPressed: () {
          _result = widget.recordForm.value;
          if (_result != null) {
            _inputController.text = _result!.toSimpleString();
          }
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
                if (widget.recordTargetExtraValue != null) buildExtraValChip(),
              ],
            ),
            _HabitRecordTextField(
              recordDate: widget.recordDate,
              inputController: _inputController,
              increaseButtonEnabled: _isTextFieldIncreaseButtonEnabled(),
              decreaseButtonEnabled: _isTextFieldDecreaseButtonEnabled(),
              onIncreaseButtonPressed: _onTextFieldIncreaseButtonPressed,
              onDecreaseButtonPressed: _onTextFieldDecreaseButtonPressed,
              onValueChanged: _onTextFieldValueChanged,
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

class _HabitRecordTextField extends StatelessWidget {
  static const textFieldRightButtonFieldWidth = 40.0;
  static const textFieldRightButtonFieldHeight = 60.0;
  static const textFieldRightButtonIconSize = 28.0;
  static const textFieldRightButtonBorderRadius = Radius.circular(10);

  final HabitDate? recordDate;
  final bool increaseButtonEnabled;
  final bool decreaseButtonEnabled;
  final TextEditingController? inputController;
  final ValueChanged<String>? onValueChanged;
  final VoidCallback? onIncreaseButtonPressed;
  final VoidCallback? onDecreaseButtonPressed;

  const _HabitRecordTextField({
    this.recordDate,
    this.increaseButtonEnabled = false,
    this.decreaseButtonEnabled = false,
    this.inputController,
    this.onValueChanged,
    this.onIncreaseButtonPressed,
    this.onDecreaseButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final textTheme = themeData.textTheme;
    final l10n = L10n.of(context);

    final double textScaleFactor =
        math.min(MediaQuery.textScaleFactorOf(context), 1.3);

    final increaseButton = _NumberStepButton(
      onUpdate: onIncreaseButtonPressed,
      borderRadius: const BorderRadius.only(
        topLeft: textFieldRightButtonBorderRadius,
        topRight: textFieldRightButtonBorderRadius,
      ),
      child: SizedBox(
        width: textFieldRightButtonFieldWidth,
        height: textFieldRightButtonFieldHeight / 2,
        child: Icon(
          MdiIcons.menuUp,
          size: textFieldRightButtonIconSize * textScaleFactor,
          color: increaseButtonEnabled
              ? colorScheme.outline
              : colorScheme.outlineVariant,
        ),
      ),
    );

    final decreaseButton = _NumberStepButton(
      onUpdate: onDecreaseButtonPressed,
      borderRadius: const BorderRadius.only(
        bottomLeft: textFieldRightButtonBorderRadius,
        bottomRight: textFieldRightButtonBorderRadius,
      ),
      child: SizedBox(
        width: textFieldRightButtonFieldWidth,
        height: textFieldRightButtonFieldHeight / 2,
        child: Icon(
          MdiIcons.menuDown,
          size: textFieldRightButtonIconSize * textScaleFactor,
          color: decreaseButtonEnabled
              ? colorScheme.outline
              : colorScheme.outlineVariant,
        ),
      ),
    );

    final textField = TextField(
      controller: inputController,
      decoration: InputDecoration(
          hintText: l10n?.habitDetail_changeGoal_helpText(
                  defaultHabitDailyGoal.toSimpleString()) ??
              "Daily goal, "
                  "default: ${defaultHabitDailyGoal.toSimpleString()}",
          hintStyle: TextStyle(color: colorScheme.outlineOpacity16),
          helperText: recordDate != null
              ? DateFormat.yMMMd(l10n?.localeName).format(recordDate!)
              : null,
          counterText: "${NumberFormat().format(minHabitDailyGoal)}"
              " ~ "
              "${NumberFormat().format(maxHabitdailyGoal)}"),
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: false),
      inputFormatters: [TextFormatterCustom.decimalr2],
      style: textTheme.bodyLarge,
      onChanged: onValueChanged,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: textField),
        const SizedBox(width: 10),
        SizedBox(
          height: textFieldRightButtonFieldHeight * textScaleFactor,
          width: textFieldRightButtonFieldWidth * textScaleFactor,
          child: Column(
            children: [
              Expanded(child: increaseButton),
              Expanded(child: decreaseButton),
            ],
          ),
        )
      ],
    );
  }
}

// Copyright: Leo@stackoverflow 2022
// see: https://stackoverflow.com/a/71945256
class _NumberStepButton extends StatefulWidget {
  final VoidCallback? onUpdate;
  final Duration minDelay;
  final Duration initialDelay;
  final int delaySteps = 2;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape = null;
  final Widget child;

  const _NumberStepButton(
      {Key? key,
      this.onUpdate,
      this.minDelay = const Duration(milliseconds: 60),
      this.initialDelay = const Duration(milliseconds: 1000),
      // this.delaySteps = 2,
      this.borderRadius,
      // this.shape,
      required this.child})
      : assert(minDelay <= initialDelay,
            "The minimum delay cannot be larger than the initial delay"),
        super(key: key);

  @override
  _NumberStepButtonState createState() => _NumberStepButtonState();
}

class _NumberStepButtonState extends State<_NumberStepButton> {
  late bool _holding;
  late int _tapDownCount;

  @override
  void initState() {
    super.initState();
    _holding = false;
    _tapDownCount = 0;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _stopHolding(),
      onTapDown: (_) => _startHolding(),
      onTapCancel: () => _stopHolding(),
      borderRadius: widget.borderRadius,
      customBorder: widget.shape,
      child: widget.child,
    );
  }

  void _startHolding() async {
    widget.onUpdate?.call();
    _tapDownCount += 1;

    final int myCount = _tapDownCount;
    if (_holding) return;
    _holding = true;

    final step =
        (widget.initialDelay - widget.minDelay).inMilliseconds.toDouble() /
            widget.delaySteps;
    var delay = widget.initialDelay.inMilliseconds.toDouble();

    while (true) {
      await Future.delayed(Duration(milliseconds: delay.round()));
      if (_holding && myCount == _tapDownCount) {
        widget.onUpdate?.call();
      } else {
        return;
      }
      if (delay > widget.minDelay.inMilliseconds) delay -= step;
    }
  }

  void _stopHolding() {
    _holding = false;
  }
}
