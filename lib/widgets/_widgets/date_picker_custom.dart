// Copyright 2026 Fries_I23
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
//
// Custom helpers extracted from the upstream date picker to host habit-specific tweaks.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../extensions/textscale_extensions.dart';
import '../../l10n/localizations.dart';
import 'chip_list.dart';

const VisualDensity habitCalendarChipVisualDensity = VisualDensity(
  horizontal: -4,
  vertical: -4,
);

class DatePickerChipContent extends StatelessWidget {
  static const double _datePickerChipContentHeight = 56.0;
  static const EdgeInsets _datePickerChipContentPadding = EdgeInsets.only(
    left: 24,
    right: 12,
  );

  final Widget? todayDateChip;
  final Widget? tomorrowDateChip;
  final Widget? nextDateChip;
  final Widget? otherDateChip;

  const DatePickerChipContent({
    super.key,
    this.todayDateChip,
    this.tomorrowDateChip,
    this.nextDateChip,
    this.otherDateChip,
  });

  @override
  Widget build(BuildContext context) {
    return ChipList(
      height: _datePickerChipContentHeight,
      padding: _datePickerChipContentPadding,
      direction: Axis.horizontal,
      children: [
        if (otherDateChip != null) otherDateChip,
        if (todayDateChip != null) todayDateChip,
        if (tomorrowDateChip != null) tomorrowDateChip,
        if (nextDateChip != null) nextDateChip,
      ],
    );
  }
}

mixin HabitDatePickerMixin<T extends StatefulWidget> on State<T> {
  late DateTime tomorrowDate;
  late DateTime nextDate;
  DateTime? otherDate;

  void initPresetDates(DateTime currentDate) {
    tomorrowDate = currentDate.add(const Duration(days: 1));
    nextDate = currentDate.add(const Duration(days: 7));
  }

  void trackOtherDate(DateTime date, DateTime today) {
    if (date != today && date != tomorrowDate && date != nextDate) {
      otherDate = date;
    }
  }

  void ensureOtherDate(DateTime selectedDate, DateTime today) {
    if (otherDate == null &&
        selectedDate != today &&
        selectedDate != tomorrowDate &&
        selectedDate != nextDate) {
      otherDate = selectedDate;
    }
  }

  DateTime mergeDateToCurrent(DateTime base, DateTime? picked) {
    return base.copyWith(
      year: picked?.year,
      month: picked?.month,
      day: picked?.day,
    );
  }

  TextScaler habitTextScaler(BuildContext context) =>
      MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);

  Size scaledDialogSize(TextScaler textScale, Size rawSize) =>
      textScale.scaleForSize(rawSize);

  Widget buildDateShortcuts({
    required BuildContext context,
    required DateTime selectedDate,
    required DateTime today,
    required DateTime tomorrow,
    required DateTime nextWeek,
    DateTime? customDate,
    required void Function(DateTime date) onDateChanged,
    required L10n? l10n,
    required ColorScheme colorScheme,
  }) {
    final bool isTodaySelected = selectedDate == today;
    final Widget todayChip = ChoiceChip(
      iconTheme: IconThemeData(color: colorScheme.primary),
      avatar: isTodaySelected
          ? null
          : const FittedBox(child: Icon(Icons.event)),
      label: l10n != null
          ? Text(l10n.calendarPicker_clip_today)
          : const Text('Today'),
      selected: isTodaySelected,
      visualDensity: habitCalendarChipVisualDensity,
      onSelected: (_) => onDateChanged(today),
    );

    final bool isTomorrowSelected = selectedDate == tomorrow;
    final Widget tomorrowChip = ChoiceChip(
      iconTheme: IconThemeData(color: colorScheme.primary),
      avatar: isTomorrowSelected
          ? null
          : const FittedBox(child: Icon(Icons.wb_sunny)),
      label: l10n != null
          ? Text(l10n.calendarPicker_clip_tomorrow)
          : const Text('Tomorrow'),
      selected: isTomorrowSelected,
      visualDensity: habitCalendarChipVisualDensity,
      onSelected: (_) => onDateChanged(tomorrow),
    );

    final bool isNextDateSelected = selectedDate == nextWeek;
    final Widget nextDateChip = ChoiceChip(
      iconTheme: IconThemeData(color: colorScheme.primary),
      avatar: isNextDateSelected
          ? null
          : const FittedBox(child: Icon(Icons.arrow_forward)),
      label: l10n != null
          ? Text(l10n.calendarPicker_clip_after7Days(nextWeek))
          : const Text('Next week'),
      selected: isNextDateSelected,
      visualDensity: habitCalendarChipVisualDensity,
      onSelected: (_) => onDateChanged(nextWeek),
    );

    Widget? otherDateChip;
    if (customDate != null) {
      final bool isOtherDateSelected = selectedDate == customDate;
      otherDateChip = ChoiceChip(
        iconTheme: IconThemeData(color: colorScheme.primary),
        avatar: isOtherDateSelected
            ? null
            : const FittedBox(child: Icon(Icons.calendar_today)),
        label: Text(
          DateFormat(
            'MMM d, y',
            Localizations.localeOf(context).toLanguageTag(),
          ).format(customDate),
        ),
        selected: isOtherDateSelected,
        visualDensity: habitCalendarChipVisualDensity,
        onSelected: (_) => onDateChanged(customDate),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
      child: otherDateChip != null
          ? DatePickerChipContent(
              key: const ValueKey<int>(0),
              todayDateChip: todayChip,
              tomorrowDateChip: tomorrowChip,
              nextDateChip: nextDateChip,
              otherDateChip: otherDateChip,
            )
          : DatePickerChipContent(
              key: const ValueKey<int>(1),
              todayDateChip: todayChip,
              tomorrowDateChip: tomorrowChip,
              nextDateChip: nextDateChip,
            ),
    );
  }
}
