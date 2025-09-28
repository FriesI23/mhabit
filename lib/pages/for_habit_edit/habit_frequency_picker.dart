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
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../model/habit_form.dart';
import '../../model/habit_freq.dart';

const double _kDefaultHabitFreqTextFieldHeight = 30;
const double _kDefualtHabitFreqTextFieldWidth = 48;

Future<HabitFrequency?> showHabitFrequencyPickerDialog({
  required BuildContext context,
  required HabitFrequency frequency,
}) async {
  return showDialog<HabitFrequency>(
    context: context,
    builder: (context) => HabitFrequencyPickerDialog(frequency),
  );
}

enum _HabitFrequencyPickerType { daily, perweek, permonth, predayfreq }

class HabitFrequencyPickerDialog extends StatefulWidget {
  final HabitFrequency frequency;

  const HabitFrequencyPickerDialog(this.frequency, {super.key});

  @override
  State<StatefulWidget> createState() => _HabitFrequencyPickerDialogView();
}

class _HabitFrequencyPickerDialogView
    extends State<HabitFrequencyPickerDialog> {
  static const double dialogMaxWidth = 400.0;

  late _HabitFrequencyPickerType selectFrequencyType;
  late HabitFrequency? customFrequency;
  late TextEditingController _preweekInputController;
  late TextEditingController _premonthInputController;
  late TextEditingController _predayfreq01InputController;
  late TextEditingController _predayfreq02InputController;

  @override
  void initState() {
    super.initState();
    final pickerType = getFrequencyPickerType(widget.frequency);
    selectFrequencyType = pickerType;
    _preweekInputController = TextEditingController()
      ..text = defaultFrequencyPreWeekFreq.toString();
    _premonthInputController = TextEditingController()
      ..text = defaultFrequencyPreMonthFreq.toString();
    _predayfreq01InputController = TextEditingController()
      ..text = defaultFrequencyCustomFreq.toString();
    _predayfreq02InputController = TextEditingController()
      ..text = defaultFrequencyCustomDays.toString();
    switch (pickerType) {
      case _HabitFrequencyPickerType.daily:
        customFrequency = HabitFrequency.daily;
        break;
      case _HabitFrequencyPickerType.perweek:
        customFrequency = widget.frequency;
        _preweekInputController.text = customFrequency!.freq.toString();
        break;
      case _HabitFrequencyPickerType.permonth:
        customFrequency = widget.frequency;
        _premonthInputController.text = customFrequency!.freq.toString();
        break;
      case _HabitFrequencyPickerType.predayfreq:
        customFrequency = widget.frequency;
        _predayfreq01InputController.text = customFrequency!.freq.toString();
        _predayfreq02InputController.text = customFrequency!.days.toString();
        break;
    }
  }

  @override
  void dispose() {
    _preweekInputController.dispose();
    _premonthInputController.dispose();
    _predayfreq01InputController.dispose();
    _predayfreq02InputController.dispose();
    super.dispose();
  }

  _HabitFrequencyPickerType getFrequencyPickerType(HabitFrequency frequency) {
    switch (frequency.type) {
      case HabitFrequencyType.weekly:
        return _HabitFrequencyPickerType.perweek;
      case HabitFrequencyType.monthly:
        return _HabitFrequencyPickerType.permonth;
      case HabitFrequencyType.custom:
        return frequency == HabitFrequency.daily
            ? _HabitFrequencyPickerType.daily
            : _HabitFrequencyPickerType.predayfreq;
      default:
        return _HabitFrequencyPickerType.daily;
    }
  }

  @override
  Widget build(BuildContext context) {
    appLog.build.debug(context, ex: [selectFrequencyType, customFrequency]);

    void onRadioChangeCallback(_HabitFrequencyPickerType? value) {
      value = value ?? selectFrequencyType;

      selectFrequencyType = value;
      switch (selectFrequencyType) {
        case _HabitFrequencyPickerType.daily:
          customFrequency = HabitFrequency.daily;
          break;
        case _HabitFrequencyPickerType.perweek:
          int newValue;
          try {
            newValue = int.parse(_preweekInputController.text);
          } on FormatException {
            newValue = defaultFrequencyPreWeekFreq;
          }
          if (newValue > 7) {
            newValue = 7;
          } else if (newValue < 1) {
            newValue = 1;
          }
          customFrequency = HabitFrequency.weekly(freq: newValue);
          break;
        case _HabitFrequencyPickerType.permonth:
          int newValue;
          try {
            newValue = int.parse(_premonthInputController.text);
          } on FormatException {
            newValue = defaultFrequencyPreMonthFreq;
          }
          if (newValue > 31) {
            newValue = 31;
          } else if (newValue < 1) {
            newValue = 1;
          }
          customFrequency = HabitFrequency.monthly(freq: newValue);
          break;
        case _HabitFrequencyPickerType.predayfreq:
          int newFreq, newDays;
          try {
            newFreq = int.parse(_predayfreq01InputController.text);
          } on FormatException {
            newFreq = defaultFrequencyCustomFreq;
          }
          try {
            newDays = int.parse(_predayfreq02InputController.text);
          } on FormatException {
            newDays = defaultFrequencyCustomDays;
          }
          newDays = math.min(newDays, maxFrequencyValue);
          newFreq = math.min(newFreq, newDays);
          customFrequency = HabitFrequency.custom(days: newDays, freq: newFreq);
          break;
      }
      Navigator.pop(context, customFrequency);
    }

    void Function(String?) onInputTextSubmit(_HabitFrequencyPickerType type) {
      return (value) =>
          selectFrequencyType == type ? onRadioChangeCallback(type) : null;
    }

    final l10n = L10n.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => AlertDialog(
        title: constraints.maxHeight > dialogshowTitleMaxHeight && l10n != null
            ? Text(l10n.habitEdit_frequencySelector_title)
            : null,
        content: SingleChildScrollView(
          child: SizedBox(
            width: math.min(constraints.maxWidth, dialogMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _HabitFrequencyDailyTile(
                  selectFrequencyType: selectFrequencyType,
                  onRadioChangeCallback: onRadioChangeCallback,
                ),
                _HabitFrequencyPerWeekTile(
                  selectFrequencyType: selectFrequencyType,
                  controller: _preweekInputController,
                  onRadioChangeCallback: onRadioChangeCallback,
                  onInputSubmmit:
                      onInputTextSubmit(_HabitFrequencyPickerType.perweek),
                ),
                _HabitFrequencyPerMonthTile(
                  selectFrequencyType: selectFrequencyType,
                  controller: _premonthInputController,
                  onRadioChangeCallback: onRadioChangeCallback,
                  onInputSubmmit:
                      onInputTextSubmit(_HabitFrequencyPickerType.permonth),
                ),
                _HabitFrequencyPerDayTile(
                  selectFrequencyType: selectFrequencyType,
                  controllerFreq: _predayfreq01InputController,
                  controllerDay: _predayfreq02InputController,
                  onRadioChangeCallback: onRadioChangeCallback,
                  onInputSubmmit:
                      onInputTextSubmit(_HabitFrequencyPickerType.predayfreq),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitFrequencyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String? value)? onInputSubmmit;

  const _HabitFrequencyTextField({
    this.controller,
    this.onInputSubmmit,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    final textScaler =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);

    return SizedBox(
      height: textScaler.scale(_kDefaultHabitFreqTextFieldHeight),
      width: textScaler.scale(_kDefualtHabitFreqTextFieldWidth),
      child: TextField(
        decoration: const InputDecoration(hintText: "", isDense: true),
        textAlign: TextAlign.center,
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
            decimal: false, signed: false),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxFrequencyValue.toString().length)
        ],
        style: textTheme.bodyLarge,
        onSubmitted: onInputSubmmit,
      ),
    );
  }
}

class _HabitFrequencyDailyTile extends StatelessWidget {
  final _HabitFrequencyPickerType selectFrequencyType;
  final Function(_HabitFrequencyPickerType? value)? onRadioChangeCallback;

  const _HabitFrequencyDailyTile({
    required this.selectFrequencyType,
    this.onRadioChangeCallback,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      leading: Radio(
        value: _HabitFrequencyPickerType.daily,
        groupValue: selectFrequencyType,
        onChanged: onRadioChangeCallback,
      ),
      title: l10n != null ? Text(l10n.habitEdit_habitFreq_daily) : null,
    );
  }
}

class _HabitFrequencyPerWeekTile extends StatelessWidget {
  final _HabitFrequencyPickerType selectFrequencyType;
  final TextEditingController? controller;
  final Function(String? value)? onInputSubmmit;
  final Function(_HabitFrequencyPickerType? value)? onRadioChangeCallback;

  const _HabitFrequencyPerWeekTile({
    required this.selectFrequencyType,
    this.controller,
    this.onInputSubmmit,
    this.onRadioChangeCallback,
  });

  List<Widget> _buildTitleChildren(BuildContext context) {
    final l10n = L10n.of(context);
    return [
      if (l10n != null && l10n.habitEdit_habitFreq_perweek.isNotEmpty)
        Text(l10n.habitEdit_habitFreq_perweek),
      _HabitFrequencyTextField(
        controller: controller,
        onInputSubmmit: onInputSubmmit,
      ),
      if (l10n != null && l10n.habitEdit_habitFreq_perweek_ex01.isNotEmpty)
        Text(l10n.habitEdit_habitFreq_perweek_ex01),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      leading: Radio(
        value: _HabitFrequencyPickerType.perweek,
        toggleable: true,
        groupValue: selectFrequencyType,
        onChanged: onRadioChangeCallback,
      ),
      title: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: _buildTitleChildren(context),
      ),
    );
  }
}

class _HabitFrequencyPerMonthTile extends StatelessWidget {
  final _HabitFrequencyPickerType selectFrequencyType;
  final TextEditingController? controller;
  final Function(String? value)? onInputSubmmit;
  final Function(_HabitFrequencyPickerType? value)? onRadioChangeCallback;

  const _HabitFrequencyPerMonthTile({
    required this.selectFrequencyType,
    this.controller,
    this.onInputSubmmit,
    this.onRadioChangeCallback,
  });

  List<Widget> _buildTitleChildren(BuildContext context) {
    final l10n = L10n.of(context);
    return [
      if (l10n != null && l10n.habitEdit_habitFreq_permonth.isNotEmpty)
        Text(l10n.habitEdit_habitFreq_permonth),
      _HabitFrequencyTextField(
        controller: controller,
        onInputSubmmit: onInputSubmmit,
      ),
      if (l10n != null && l10n.habitEdit_habitFreq_permonth_ex01.isNotEmpty)
        Text(l10n.habitEdit_habitFreq_permonth_ex01),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      leading: Radio(
        value: _HabitFrequencyPickerType.permonth,
        toggleable: true,
        groupValue: selectFrequencyType,
        onChanged: onRadioChangeCallback,
      ),
      title: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: _buildTitleChildren(context),
      ),
    );
  }
}

class _HabitFrequencyPerDayTile extends StatelessWidget {
  final _HabitFrequencyPickerType selectFrequencyType;
  final TextEditingController? controllerFreq;
  final TextEditingController? controllerDay;
  final Function(String? value)? onInputSubmmit;
  final Function(_HabitFrequencyPickerType? value)? onRadioChangeCallback;

  const _HabitFrequencyPerDayTile({
    required this.selectFrequencyType,
    this.controllerFreq,
    this.controllerDay,
    this.onInputSubmmit,
    this.onRadioChangeCallback,
  });

  List<Widget> _buildTitleChildren(BuildContext context) {
    final l10n = L10n.of(context);
    final reversed = int.tryParse(
            l10n?.habitEdit_habitFreq_predayfreq_reverse_flag ?? '0') ??
        0;
    final results = [
      if (l10n != null && l10n.habitEdit_habitFreq_predayfreq.isNotEmpty)
        Text(l10n.habitEdit_habitFreq_predayfreq),
      _HabitFrequencyTextField(
        controller: controllerFreq,
        onInputSubmmit: onInputSubmmit,
      ),
      if (l10n != null && l10n.habitEdit_habitFreq_predayfreq_ex01.isNotEmpty)
        Text(l10n.habitEdit_habitFreq_predayfreq_ex01),
      _HabitFrequencyTextField(
        controller: controllerDay,
        onInputSubmmit: onInputSubmmit,
      ),
      if (l10n != null && l10n.habitEdit_habitFreq_predayfreq_ex02.isNotEmpty)
        Text(l10n.habitEdit_habitFreq_predayfreq_ex02),
    ];
    return reversed >= 1 ? results.reversed.toList() : results;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      leading: Radio(
        value: _HabitFrequencyPickerType.predayfreq,
        toggleable: true,
        groupValue: selectFrequencyType,
        onChanged: onRadioChangeCallback,
      ),
      title: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: _buildTitleChildren(context),
      ),
    );
  }
}
