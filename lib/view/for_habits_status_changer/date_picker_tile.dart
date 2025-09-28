// Copyright 2024 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../common/utils.dart';
import '../../l10n/localizations.dart';
import '../../model/custom_date_format.dart';
import '../../model/habit_date.dart';
import '../../widgets/widget.dart';

class DatePickerTile extends StatefulWidget {
  final HabitDate initDate;
  final HabitDate? lastDate;
  final HabitDate firstDate;
  final CustomDateYmdHmsConfig? formatter;
  final EdgeInsetsGeometry? padding;
  final void Function(HabitDate od, HabitDate nd)? onSelectDateChanged;

  const DatePickerTile({
    super.key,
    required this.initDate,
    required this.firstDate,
    this.lastDate,
    this.formatter,
    this.padding,
    this.onSelectDateChanged,
  });

  @override
  State<DatePickerTile> createState() => _DatePickerTileState();
}

class _DatePickerTileState extends State<DatePickerTile> {
  late HabitDate _selectDate;

  HabitDate get lastDate => widget.lastDate ?? HabitDate.now();
  HabitDate get firstDate => widget.firstDate;

  @override
  void initState() {
    _selectDate = widget.initDate;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DatePickerTile oldWidget) {
    _selectDate = widget.initDate;
    super.didUpdateWidget(oldWidget);
  }

  void _updateSelectedDate(HabitDate newDate) {
    final nd = stampDateTime(newDate, min: firstDate, max: lastDate);
    final od = _selectDate;
    if (nd != od) {
      setState(() {
        _selectDate = nd;
        widget.onSelectDateChanged?.call(od, nd);
      });
    }
  }

  DateFormat _getDateFormat([L10n? l10n]) =>
      widget.formatter?.getYMDBatchCheckinFormatter(l10n?.localeName) ??
      DateFormat.yMMMMd(l10n?.localeName);

  void _onDatePressed(HabitDate date) async {
    if (!mounted) return;
    final result = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (!mounted || result == null) return;
    _updateSelectedDate(HabitDate.dateTime(result));
  }

  void _onLeftButtonPressed() async {
    if (!mounted) return;
    _updateSelectedDate(_selectDate.addDays(-1));
  }

  void _onRightButtonPressed() async {
    if (!mounted) return;
    _updateSelectedDate(_selectDate.addDays(1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Padding(
      padding: widget.padding ?? kListTileContentPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton.outlined(
            tooltip: l10n?.batchCheckin_datePicker_prevButton_tooltip,
            onPressed: _selectDate <= firstDate ? null : _onLeftButtonPressed,
            icon: const Icon(Icons.arrow_left_outlined),
          ),
          const Spacer(flex: 1),
          Expanded(
            flex: 10,
            child: L10nBuilder(
              builder: (context, l10n) => _DateTimeCell(
                formatter: _getDateFormat(l10n),
                date: _selectDate,
                onPressed: _onDatePressed,
              ),
            ),
          ),
          const Spacer(flex: 1),
          IconButton.outlined(
            tooltip: l10n?.batchCheckin_datePicker_nextButton_tooltip,
            onPressed: _selectDate >= lastDate ? null : _onRightButtonPressed,
            icon: const Icon(Icons.arrow_right_outlined),
          ),
        ],
      ),
    );
  }
}

class _DateTimeCell extends StatelessWidget {
  final DateFormat formatter;
  final HabitDate date;
  final void Function(HabitDate date)? onPressed;

  const _DateTimeCell({
    required this.formatter,
    required this.date,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onPressed != null ? () => onPressed!(date) : null,
        icon: const Icon(MdiIcons.calendarEditOutline, size: 16),
        label: FittedBox(
          child: Text(
            formatter.format(date),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
