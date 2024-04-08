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
import '../../model/habit_daily_goal.dart';
import '../../model/habit_daily_record_form.dart';
import '../../model/habit_date.dart';
import '../../model/habit_form.dart';

const _kDefaultHabitRecordChipListHeight = 56.0;

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
    final newDailyGoal = num.tryParse(value) ??
        HabitDailyGoalHelper.getDefaultDailyGoal(widget.recordForm.habitType);
    final currentValue = _result;
    _result = onDailyGoalTextInputChanged(newDailyGoal,
        controller: _inputController, allowInputZero: true);

    if (currentValue != null && _isButtonNeedRebuild(currentValue, _result!)) {
      setState(() {});
    }
  }

  void _onChipValueChanged(num? newValue) {
    if (newValue != null) {
      _result = newValue;
      _inputController.text = _result!.toSimpleString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    Widget buildNormalHabitChipList(
      BuildContext context, {
      required BoxConstraints constraints,
    }) {
      final complateStatus = widget.recordForm.complateStatus;
      return _NormalHabitRecordChipList(
        height: _kDefaultHabitRecordChipListHeight,
        value: widget.recordForm.value,
        targetValue: widget.recordForm.targetValue,
        recordTargetExtraValue: widget.recordTargetExtraValue,
        width: math.min(constraints.maxWidth, dialogMaxWidth),
        showCurrentValChip: complateStatus != HabitDailyComplateStatus.ok &&
            complateStatus != HabitDailyComplateStatus.zero,
        showExtraValChip: widget.recordTargetExtraValue != null,
        onNormalValChipTapped: _onChipValueChanged,
        onZeroValChipTapped: _onChipValueChanged,
        onExtraValChipTapped: _onChipValueChanged,
        onCurrentValChipTapped: _onChipValueChanged,
      );
    }

    Widget buildNegativeHabitChipList(
      BuildContext context, {
      required BoxConstraints constraints,
    }) {
      final complateStatus = widget.recordForm.complateStatus;
      return _NormalHabitRecordChipList(
        height: _kDefaultHabitRecordChipListHeight,
        value: widget.recordForm.value,
        targetValue:
            widget.recordTargetExtraValue ?? widget.recordForm.targetValue,
        recordTargetExtraValue: widget.recordForm.targetValue,
        width: math.min(constraints.maxWidth, dialogMaxWidth),
        showCurrentValChip: complateStatus != HabitDailyComplateStatus.ok &&
            complateStatus != HabitDailyComplateStatus.zero,
        showExtraValChip: widget.recordTargetExtraValue != null &&
            widget.recordTargetExtraValue! != widget.recordForm.targetValue,
        showZeroValChip: false,
        showNormalValChip: true,
        onNormalValChipTapped: _onChipValueChanged,
        onZeroValChipTapped: _onChipValueChanged,
        onExtraValChipTapped: _onChipValueChanged,
        onCurrentValChipTapped: _onChipValueChanged,
      );
    }

    Widget buildChipList(BuildContext context, BoxConstraints constraints) {
      switch (widget.recordForm.habitType) {
        case HabitType.unknown:
        case HabitType.normal:
          return buildNormalHabitChipList(context, constraints: constraints);
        case HabitType.negative:
          return buildNegativeHabitChipList(context, constraints: constraints);
      }
    }

    return LayoutBuilder(builder: (context, constraints) {
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
            buildChipList(context, constraints),
            _HabitRecordTextField(
              habitType: widget.recordForm.habitType,
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

  final HabitType habitType;
  final HabitDate? recordDate;
  final bool increaseButtonEnabled;
  final bool decreaseButtonEnabled;
  final TextEditingController? inputController;
  final ValueChanged<String>? onValueChanged;
  final VoidCallback? onIncreaseButtonPressed;
  final VoidCallback? onDecreaseButtonPressed;

  const _HabitRecordTextField({
    required this.habitType,
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

    final defaultDailyGoal =
        HabitDailyGoalHelper.getDefaultDailyGoal(habitType);
    final textField = TextField(
      controller: inputController,
      decoration: InputDecoration(
          hintText: l10n?.habitDetail_changeGoal_helpText(
                  defaultDailyGoal.toSimpleString()) ??
              "Daily goal, "
                  "default: ${defaultDailyGoal.toSimpleString()}",
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
      {this.onUpdate,
      this.minDelay = const Duration(milliseconds: 60),
      this.initialDelay = const Duration(milliseconds: 1000),
      // this.delaySteps = 2,
      this.borderRadius,
      // this.shape,
      required this.child})
      : assert(minDelay <= initialDelay,
            "The minimum delay cannot be larger than the initial delay");

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
      onTap: _stopHolding,
      onTapDown: (_) => _startHolding(),
      onTapCancel: _stopHolding,
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

class _NormalHabitRecordChipList extends StatelessWidget {
  final double? height;
  final double? width;
  final HabitDailyGoal value;
  final HabitDailyGoal targetValue;
  final HabitDailyGoal? recordTargetExtraValue;
  final bool showNormalValChip;
  final bool showZeroValChip;
  final bool showExtraValChip;
  final bool showCurrentValChip;
  final ValueChanged<HabitDailyGoal>? onNormalValChipTapped;
  final ValueChanged<HabitDailyGoal>? onZeroValChipTapped;
  final ValueChanged<HabitDailyGoal?>? onExtraValChipTapped;
  final ValueChanged<HabitDailyGoal>? onCurrentValChipTapped;

  const _NormalHabitRecordChipList({
    this.height,
    this.width,
    required this.value,
    required this.targetValue,
    this.recordTargetExtraValue,
    this.showNormalValChip = true,
    this.showZeroValChip = true,
    this.showExtraValChip = false,
    this.showCurrentValChip = false,
    this.onNormalValChipTapped,
    this.onZeroValChipTapped,
    this.onExtraValChipTapped,
    this.onCurrentValChipTapped,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final Widget normalValChip = ActionChip(
      avatar: const FittedBox(child: Icon(MdiIcons.checkCircle)),
      label: Text(l10n?.habitDetail_changeGoal_doneChipText(
              targetValue.toSimpleString()) ??
          "Done: ${targetValue.toSimpleString()}"),
      onPressed: onNormalValChipTapped != null
          ? () => onNormalValChipTapped!(targetValue)
          : null,
    );

    final Widget zeroValChip = ActionChip(
      avatar: const FittedBox(child: Icon(MdiIcons.closeCircle)),
      label: l10n != null
          ? Text(l10n.habitDetail_changeGoal_undoneChipText)
          : const Text("Undone"),
      backgroundColor: null,
      onPressed: onZeroValChipTapped != null
          ? () => onZeroValChipTapped!(minHabitDailyGoal)
          : null,
    );

    Widget? buildExtraValChip() {
      if (recordTargetExtraValue == null) return null;
      return ActionChip(
        avatar: const FittedBox(child: Icon(MdiIcons.checkUnderlineCircle)),
        label: Text(l10n?.habitDetail_changeGoal_extraChipText(
                recordTargetExtraValue!.toSimpleString()) ??
            "Extra: ${recordTargetExtraValue!.toSimpleString()}"),
        onPressed: onExtraValChipTapped != null
            ? () => onExtraValChipTapped!(recordTargetExtraValue)
            : null,
      );
    }

    Widget buildLastValChip() {
      return ActionChip(
        label: Text(l10n?.habitDetail_changeGoal_currentChipText(
                value.toSimpleString()) ??
            "Current: ${value.toSimpleString()}"),
        onPressed: onCurrentValChipTapped != null
            ? () => onCurrentValChipTapped!(value)
            : null,
      );
    }

    return ChipList(
      height: height,
      width: width,
      padding: EdgeInsets.zero,
      children: [
        if (showCurrentValChip) buildLastValChip(),
        if (showNormalValChip) normalValChip,
        if (showZeroValChip) zeroValChip,
        if (showExtraValChip) buildExtraValChip(),
      ],
    );
  }
}
