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

import '../../component/widget.dart';
import '../../l10n/localizations.dart';
import '../../model/habit_form.dart';
import '../../model/habit_reminder.dart';

Future<HabitReminder?> showHabitReminderTypePickerDialog(
    {required BuildContext context,
    required HabitReminder reminder,
    HabitColorType? colorType}) async {
  return showDialog<HabitReminder>(
    context: context,
    builder: (context) => HabitReminderTypePickerDialog(
      initReminder: reminder,
      colorType: colorType,
    ),
  );
}

class HabitReminderTypePickerDialog extends StatefulWidget {
  final HabitReminder initReminder;
  final HabitColorType? colorType;

  const HabitReminderTypePickerDialog({
    super.key,
    required this.initReminder,
    this.colorType,
  });

  @override
  State<StatefulWidget> createState() => _HabitReminderTypePickerDialog();
}

class _HabitReminderTypePickerDialog
    extends State<HabitReminderTypePickerDialog> {
  late HabitReminderType _crtType;
  late final Set<int> _weekSelectedColl;
  late final Set<int> _monthSelectedColl;

  @override
  void initState() {
    _crtType = widget.initReminder.type;
    if (widget.initReminder.type == HabitReminderType.week) {
      _weekSelectedColl = Set.of(widget.initReminder.extra);
    } else {
      _weekSelectedColl = Set.of(HabitReminder.weeklyExtraAll);
    }
    if (widget.initReminder.type == HabitReminderType.month) {
      _monthSelectedColl = Set.of(widget.initReminder.extra);
    } else {
      _monthSelectedColl = Set.of(HabitReminder.monthlyExtraAll);
    }

    super.initState();
  }

  HabitReminder get returnValue {
    List<int> extra;
    switch (_crtType) {
      case HabitReminderType.unknown:
        extra = const [];
        break;
      case HabitReminderType.whenNeeded:
        extra = const [];
        break;
      case HabitReminderType.day:
        extra = const [];
        break;
      case HabitReminderType.week:
        extra = _weekSelectedColl.toList();
        break;
      case HabitReminderType.month:
        extra = _monthSelectedColl.toList();
        break;
    }
    return HabitReminder(
      type: _crtType,
      extra: extra,
      time: const TimeOfDay(hour: 0, minute: 0),
    );
  }

  VoidCallback? getConfirmCallback(BuildContext context) {
    void callback() => Navigator.of(context).pop(returnValue);

    switch (_crtType) {
      case HabitReminderType.week:
        return _weekSelectedColl.isEmpty ? null : callback;
      case HabitReminderType.month:
        return _monthSelectedColl.isEmpty ? null : callback;
      case HabitReminderType.unknown:
      case HabitReminderType.whenNeeded:
      case HabitReminderType.day:
        return callback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    Widget buildRadioListTile(BuildContext context, HabitReminderType type) {
      return RadioListTile<HabitReminderType>(
        title: Text(HabitReminder.getReminderTypeTextByType(type, l10n: l10n)),
        value: type,
        groupValue: _crtType,
        contentPadding: EdgeInsets.zero,
        onChanged: (value) => setState(() {
          _crtType = value ?? _crtType;
        }),
      );
    }

    Widget buildWeekSelectorWrap(BuildContext context) {
      return ExpandedSection(
        expand: _crtType == HabitReminderType.week,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Wrap(
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: List.generate(
              7,
              (index) => WeekPickerCell(
                colorType: widget.colorType,
                selected: _weekSelectedColl.contains(index + 1),
                weekday: index + 1,
                onPressed: (weekday) => setState(() {
                  if (_weekSelectedColl.contains(weekday)) {
                    _weekSelectedColl.remove(weekday);
                  } else {
                    _weekSelectedColl.add(weekday);
                  }
                }),
              ),
            ),
          ),
        ),
      );
    }

    Widget buildMonthSelectorWrap(BuildContext context) {
      return ExpandedSection(
        expand: _crtType == HabitReminderType.month,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Wrap(
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: List.generate(
              31,
              (index) => MonthPickerCell(
                colorType: widget.colorType,
                selected: _monthSelectedColl.contains(index + 1),
                monthday: index + 1,
                onPressed: (monthday) => setState(() {
                  if (_monthSelectedColl.contains(monthday)) {
                    _monthSelectedColl.remove(monthday);
                  } else {
                    _monthSelectedColl.add(monthday);
                  }
                }),
              ),
            ),
          ),
        ),
      );
    }

    return AlertDialog(
      scrollable: true,
      title: Text(l10n?.habitEdit_reminder_dialogTitle ?? ''),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildRadioListTile(context, HabitReminderType.whenNeeded),
          buildRadioListTile(context, HabitReminderType.day),
          buildRadioListTile(context, HabitReminderType.week),
          buildWeekSelectorWrap(context),
          buildRadioListTile(context, HabitReminderType.month),
          buildMonthSelectorWrap(context),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: l10n != null
              ? Text(l10n.habitEdit_reminder_dialogCancel)
              : const Text('cancel'),
        ),
        TextButton(
          onPressed: getConfirmCallback(context),
          child: l10n != null
              ? Text(l10n.habitEdit_reminder_dialogConfirm)
              : const Text('confirm'),
        ),
      ],
    );
  }
}
