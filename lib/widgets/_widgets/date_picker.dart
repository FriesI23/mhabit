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
//
// Copy source code from flutter(3.7.4): flutter/lib/src/material/date_picker.dart
// Flutter license place at LICENSE_THIRDPARTY.md

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../extensions/textscale_extensions.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import 'chip_list.dart';

const Size _calendarPortraitDialogSize = Size(330.0 + 10, 518.0);
const Size _calendarLandscapeDialogSize = Size(496.0, 346.0 + 10);
const Size _inputPortraitDialogSize = Size(330.0 + 10, 270.0);
const Size _inputLandscapeDialogSize = Size(496, 160.0 + 10);
const Duration _dialogSizeAnimationDuration = Duration(milliseconds: 200);
const double _inputFormPortraitHeight = 98.0;
const double _inputFormLandscapeHeight = 108.0;
const VisualDensity _calendarChipVisualDensity =
    VisualDensity(horizontal: -4, vertical: -4);

class HabitDatetimePickerDialog extends DatePickerDialog {
  final DateTime currentDateTime;

  HabitDatetimePickerDialog({
    super.key,
    required this.currentDateTime,
    required super.initialDate,
    required super.firstDate,
    required super.lastDate,
    DateTime? currentDate,
    super.initialEntryMode,
  });

  @override
  State<DatePickerDialog> createState() => _HabitDatetimePickerDialog();
}

class _HabitDatetimePickerDialog extends State<HabitDatetimePickerDialog>
    with RestorationMixin {
  late final RestorableDateTimeN _selectedDate =
      RestorableDateTimeN(widget.initialDate);
  late final _RestorableDatePickerEntryMode _entryMode =
      _RestorableDatePickerEntryMode(widget.initialEntryMode);
  final _RestorableAutovalidateMode _autovalidateMode =
      _RestorableAutovalidateMode(AutovalidateMode.disabled);

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(_autovalidateMode, 'autovalidateMode');
    registerForRestoration(_entryMode, 'calendar_entry_mode');
  }

  @override
  void initState() {
    super.initState();
    tomorrowDate = widget.currentDate.add(const Duration(days: 1));
    nextDate = widget.currentDate.add(const Duration(days: 7));
  }

  final GlobalKey _calendarPickerKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final DateTime tomorrowDate;
  late final DateTime nextDate;
  DateTime? otherDate;

  void _handleOk() {
    if (_entryMode.value == DatePickerEntryMode.input ||
        _entryMode.value == DatePickerEntryMode.inputOnly) {
      final FormState form = _formKey.currentState!;
      if (!form.validate()) {
        setState(() => _autovalidateMode.value = AutovalidateMode.always);
        return;
      }
      form.save();
    }
    Navigator.pop(
        context,
        widget.currentDateTime.copyWith(
          year: _selectedDate.value?.year,
          month: _selectedDate.value?.month,
          day: _selectedDate.value?.day,
        ));
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleEntryModeToggle() {
    setState(() {
      switch (_entryMode.value) {
        case DatePickerEntryMode.calendar:
          _autovalidateMode.value = AutovalidateMode.disabled;
          _entryMode.value = DatePickerEntryMode.input;
          break;
        case DatePickerEntryMode.input:
          _formKey.currentState!.save();
          _entryMode.value = DatePickerEntryMode.calendar;
          break;
        case DatePickerEntryMode.calendarOnly:
        case DatePickerEntryMode.inputOnly:
          assert(false, 'Can not change entry mode from _entryMode');
          break;
      }
    });
  }

  void _handleDateChanged(DateTime date) {
    setState(() {
      _selectedDate.value = date;
      if (date != widget.currentDate &&
          date != tomorrowDate &&
          date != nextDate) {
        otherDate = date;
      }
    });
  }

  Size _dialogSize(BuildContext context) {
    final Orientation orientation = MediaQuery.orientationOf(context);
    switch (_entryMode.value) {
      case DatePickerEntryMode.calendar:
      case DatePickerEntryMode.calendarOnly:
        switch (orientation) {
          case Orientation.portrait:
            return _calendarPortraitDialogSize;
          case Orientation.landscape:
            return _calendarLandscapeDialogSize;
        }
      case DatePickerEntryMode.input:
      case DatePickerEntryMode.inputOnly:
        switch (orientation) {
          case Orientation.portrait:
            return _inputPortraitDialogSize;
          case Orientation.landscape:
            return _inputLandscapeDialogSize;
        }
    }
  }

  static const Map<ShortcutActivator, Intent> _formShortcutMap =
      <ShortcutActivator, Intent>{
    // Pressing enter on the field will move focus to the next field or control.
    SingleActivator(LogicalKeyboardKey.enter): NextFocusIntent(),
  };

  @override
  Widget build(BuildContext context) {
    appLog.build.debug(context, ex: [widget.currentDate, widget.initialDate]);

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final Orientation orientation = MediaQuery.orientationOf(context);
    final TextTheme textTheme = theme.textTheme;
    // Constrain the textScaleFactor to the largest supported value to prevent
    // layout issues.
    final TextScaler textScale =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);

    final l10n = L10n.of(context);

    final String dateText = _selectedDate.value == null
        ? ""
        : localizations.formatMediumDate(_selectedDate.value!);
    final Color onPrimarySurface = colorScheme.brightness == Brightness.light
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final TextStyle? dateStyle = orientation == Orientation.landscape
        ? textTheme.headlineSmall?.copyWith(color: onPrimarySurface)
        : textTheme.headlineMedium?.copyWith(color: onPrimarySurface);

    final Widget actions = Container(
      alignment: AlignmentDirectional.centerEnd,
      constraints: const BoxConstraints(minHeight: 52.0),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OverflowBar(
        spacing: 8,
        children: <Widget>[
          TextButton(
            onPressed: _handleCancel,
            child: Text(widget.cancelText ??
                (theme.useMaterial3
                    ? localizations.cancelButtonLabel
                    : localizations.cancelButtonLabel.toUpperCase())),
          ),
          TextButton(
            onPressed: _handleOk,
            child: Text(widget.confirmText ?? localizations.okButtonLabel),
          ),
        ],
      ),
    );

    CalendarDatePicker calendarDatePicker() {
      return CalendarDatePicker(
        key: _calendarPickerKey,
        initialDate: _selectedDate.value,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        currentDate: widget.currentDate,
        onDateChanged: _handleDateChanged,
        selectableDayPredicate: widget.selectableDayPredicate,
        initialCalendarMode: widget.initialCalendarMode,
      );
    }

    Form inputDatePicker() {
      return Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          height: orientation == Orientation.portrait
              ? _inputFormPortraitHeight
              : _inputFormLandscapeHeight,
          child: Shortcuts(
            shortcuts: _formShortcutMap,
            child: Column(
              children: <Widget>[
                const Spacer(),
                InputDatePickerFormField(
                  initialDate: _selectedDate.value,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateSubmitted: _handleDateChanged,
                  onDateSaved: _handleDateChanged,
                  selectableDayPredicate: widget.selectableDayPredicate,
                  errorFormatText: widget.errorFormatText,
                  errorInvalidText: widget.errorInvalidText,
                  fieldHintText: widget.fieldHintText,
                  fieldLabelText: widget.fieldLabelText,
                  keyboardType: widget.keyboardType,
                  autofocus: true,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    final Widget picker;
    final Widget? entryModeButton;
    switch (_entryMode.value) {
      case DatePickerEntryMode.calendar:
        picker = calendarDatePicker();
        entryModeButton = IconButton(
          icon: const Icon(Icons.edit),
          color: onPrimarySurface,
          tooltip: localizations.inputDateModeButtonLabel,
          onPressed: _handleEntryModeToggle,
        );
        break;

      case DatePickerEntryMode.calendarOnly:
        picker = calendarDatePicker();
        entryModeButton = null;
        break;

      case DatePickerEntryMode.input:
        picker = inputDatePicker();
        entryModeButton = IconButton(
          icon: const Icon(Icons.calendar_today),
          color: onPrimarySurface,
          tooltip: localizations.calendarModeButtonLabel,
          onPressed: _handleEntryModeToggle,
        );
        break;

      case DatePickerEntryMode.inputOnly:
        picker = inputDatePicker();
        entryModeButton = null;
        break;
    }

    final Widget header = _DatePickerHeader(
      helpText: widget.helpText ??
          (Theme.of(context).useMaterial3
              ? localizations.datePickerHelpText
              : localizations.datePickerHelpText.toUpperCase()),
      titleText: dateText,
      titleStyle: dateStyle,
      orientation: orientation,
      isShort: orientation == Orientation.landscape,
      entryModeButton: entryModeButton,
    );

    final bool isTodaySelected = _selectedDate.value == widget.currentDate;
    final Widget todayChip = ChoiceChip(
      iconTheme: IconThemeData(color: colorScheme.primary),
      avatar:
          isTodaySelected ? null : const FittedBox(child: Icon(Icons.event)),
      label: l10n != null
          ? Text(l10n.calendarPicker_clip_today)
          : const Text("Today"),
      selected: isTodaySelected,
      visualDensity: _calendarChipVisualDensity,
      onSelected: (value) => _handleDateChanged(widget.currentDate),
    );

    final bool isTomorrowSelected = _selectedDate.value == tomorrowDate;
    final Widget tomorrowChip = ChoiceChip(
      iconTheme: IconThemeData(color: colorScheme.primary),
      avatar: isTomorrowSelected
          ? null
          : const FittedBox(child: Icon(Icons.wb_sunny)),
      label: l10n != null
          ? Text(l10n.calendarPicker_clip_tomorrow)
          : const Text("Tomorrow"),
      selected: isTomorrowSelected,
      visualDensity: _calendarChipVisualDensity,
      onSelected: (value) => _handleDateChanged(tomorrowDate),
    );

    final bool isNextDateSelected = _selectedDate.value == nextDate;
    final Widget nextDateChip = ChoiceChip(
      iconTheme: IconThemeData(color: colorScheme.primary),
      avatar: isNextDateSelected
          ? null
          : const FittedBox(child: Icon(Icons.arrow_forward)),
      label: l10n != null
          ? Text(l10n.calendarPicker_clip_after7Days(nextDate))
          : const Text("Next week"),
      selected: isNextDateSelected,
      visualDensity: _calendarChipVisualDensity,
      onSelected: (value) => _handleDateChanged(nextDate),
    );

    if (otherDate == null &&
        !isTodaySelected &&
        !isTomorrowSelected &&
        !isNextDateSelected) {
      otherDate = _selectedDate.value;
    }

    Widget? otherDateChip;
    if (otherDate != null) {
      final bool isOtherDateSelected = _selectedDate.value == otherDate;
      otherDateChip = ChoiceChip(
        iconTheme: IconThemeData(color: colorScheme.primary),
        avatar: isOtherDateSelected
            ? null
            : const FittedBox(child: Icon(Icons.calendar_today)),
        label: Text(DateFormat(
                "MMM d, y", Localizations.localeOf(context).toLanguageTag())
            .format(otherDate!)),
        selected: isOtherDateSelected,
        visualDensity: _calendarChipVisualDensity,
        onSelected: (value) => _handleDateChanged(otherDate!),
      );
    }

    final Widget midcontent = AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200),
        child: otherDateChip != null
            ? _DatePickerChipContent(
                key: const ValueKey<int>(0),
                todayDateChip: todayChip,
                tomorrowDateChip: tomorrowChip,
                nextDateChip: nextDateChip,
                otherDateChip: otherDateChip,
              )
            : _DatePickerChipContent(
                key: const ValueKey<int>(1),
                todayDateChip: todayChip,
                tomorrowDateChip: tomorrowChip,
                nextDateChip: nextDateChip,
              ));

    final Size dialogSize = textScale.scaleForSize(_dialogSize(context));
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: dialogSize.width,
        height: dialogSize.height,
        duration: _dialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScale),
          child: Builder(builder: (context) {
            switch (orientation) {
              case Orientation.portrait:
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    header,
                    midcontent,
                    Expanded(child: picker),
                    actions,
                  ],
                );
              case Orientation.landscape:
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    header,
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          midcontent,
                          Expanded(child: picker),
                          actions,
                        ],
                      ),
                    ),
                  ],
                );
            }
          }),
        ),
      ),
    );
  }
}

class _RestorableDatePickerEntryMode
    extends RestorableValue<DatePickerEntryMode> {
  _RestorableDatePickerEntryMode(
    DatePickerEntryMode defaultValue,
  ) : _defaultValue = defaultValue;

  final DatePickerEntryMode _defaultValue;

  @override
  DatePickerEntryMode createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(DatePickerEntryMode? oldValue) {
    assert(debugIsSerializableForRestoration(value.index));
    notifyListeners();
  }

  @override
  DatePickerEntryMode fromPrimitives(Object? data) =>
      DatePickerEntryMode.values[data! as int];

  @override
  Object? toPrimitives() => value.index;
}

class _RestorableAutovalidateMode extends RestorableValue<AutovalidateMode> {
  _RestorableAutovalidateMode(
    AutovalidateMode defaultValue,
  ) : _defaultValue = defaultValue;

  final AutovalidateMode _defaultValue;

  @override
  AutovalidateMode createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(AutovalidateMode? oldValue) {
    assert(debugIsSerializableForRestoration(value.index));
    notifyListeners();
  }

  @override
  AutovalidateMode fromPrimitives(Object? data) =>
      AutovalidateMode.values[data! as int];

  @override
  Object? toPrimitives() => value.index;
}

class _DatePickerHeader extends StatelessWidget {
  const _DatePickerHeader({
    required this.helpText,
    required this.titleText,
    required this.titleStyle,
    required this.orientation,
    this.isShort = false,
    this.entryModeButton,
  });

  static const double _datePickerHeaderLandscapeWidth = 152.0;
  static const double _datePickerHeaderPortraitHeight = 120.0;
  static const double _headerPaddingLandscape = 16.0;

  final String helpText;

  final String titleText;

  final TextStyle? titleStyle;

  final Orientation orientation;

  final bool isShort;

  final Widget? entryModeButton;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    // The header should use the primary color in light themes and surface color in dark
    final bool isDark = colorScheme.brightness == Brightness.dark;
    final Color primarySurfaceColor =
        isDark ? colorScheme.surface : colorScheme.primary;
    final Color onPrimarySurfaceColor =
        isDark ? colorScheme.onSurface : colorScheme.onPrimary;

    final TextStyle? helpStyle = textTheme.labelSmall?.copyWith(
      color: onPrimarySurfaceColor,
    );

    final Text help = Text(
      helpText,
      style: helpStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final Text title = Text(
      titleText,
      semanticsLabel: titleText,
      style: titleStyle,
      maxLines: orientation == Orientation.portrait ? 1 : 2,
      overflow: TextOverflow.ellipsis,
    );

    switch (orientation) {
      case Orientation.portrait:
        return SizedBox(
          height: _datePickerHeaderPortraitHeight,
          child: Material(
            color: primarySurfaceColor,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 24,
                end: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 16),
                  help,
                  const Flexible(child: SizedBox(height: 38)),
                  Row(
                    children: <Widget>[
                      Expanded(child: title),
                      if (entryModeButton != null) entryModeButton!,
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      case Orientation.landscape:
        return SizedBox(
          width: _datePickerHeaderLandscapeWidth,
          child: Material(
            color: primarySurfaceColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _headerPaddingLandscape,
                  ),
                  child: help,
                ),
                SizedBox(height: isShort ? 16 : 56),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _headerPaddingLandscape,
                    ),
                    child: title,
                  ),
                ),
                if (entryModeButton != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: entryModeButton,
                  ),
              ],
            ),
          ),
        );
    }
  }
}

class _DatePickerChipContent extends StatelessWidget {
  static const double _datePickerChipContentHeight = 56.0;
  static const EdgeInsets _datePickerChipContentPadding =
      EdgeInsets.only(left: 24, right: 12);

  final Widget? todayDateChip;
  final Widget? tomorrowDateChip;
  final Widget? nextDateChip;
  final Widget? otherDateChip;

  const _DatePickerChipContent(
      {super.key,
      this.todayDateChip,
      this.tomorrowDateChip,
      this.nextDateChip,
      this.otherDateChip});

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
        if (nextDateChip != null) nextDateChip
      ],
    );
  }
}
