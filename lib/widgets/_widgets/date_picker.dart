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
// Copy source code from flutter(3.35.7): flutter/lib/src/material/date_picker.dart
// Flutter license place at LICENSE_THIRDPARTY.md
//
// ignore_for_file: avoid_types_on_closure_parameters, unused_element_parameter

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/localizations.dart';
import 'date_picker_custom.dart';

//#region copy from flutter 3.35.7
// The M3 sizes are coming from the tokens, but are hand coded,
// as the current token DB does not contain landscape versions.
const Size _calendarPortraitDialogSizeM2 = Size(330.0, 518.0);
const Size _calendarPortraitDialogSizeM3 = Size(360.0, 568.0);
const Size _calendarLandscapeDialogSize = Size(496.0, 346.0);
const Size _inputPortraitDialogSizeM2 = Size(330.0, 270.0);
const Size _inputPortraitDialogSizeM3 = Size(328.0, 270.0);
const Size _inputLandscapeDialogSize = Size(496, 160.0);
const Duration _dialogSizeAnimationDuration = Duration(milliseconds: 200);
const double _inputFormPortraitHeight = 98.0;
const double _inputFormLandscapeHeight = 108.0;

// 3.0 is the maximum scale factor on mobile phones. As of 07/30/24, iOS goes up
// to a max of 3.0 text scale factor, and Android goes up to 2.0. This is the
// default used for non-range date pickers. This default is changed to a lower
// value at different parts of the date pickers depending on content, and device
// orientation.
const double _kMaxTextScaleFactor = 3.0;

// The max text scale factor for the header. This is lower than the default as
// the title text already starts at a large size.
const double _kMaxHeaderTextScaleFactor = 1.6;

// The entry button shares a line with the header text, so there is less room to
// scale up.
const double _kMaxHeaderWithEntryTextScaleFactor = 1.4;

const double _kMaxHelpPortraitTextScaleFactor = 1.6;
const double _kMaxHelpLandscapeTextScaleFactor = 1.4;

// 14 is a common font size used to compute the effective text scale.
const double _fontSizeToScale = 14.0;
//#endregion

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
  State<DatePickerDialog> createState() => _DatePickerDialogState();
}

//#region copy from flutter 3.35.7
class _DatePickerDialogState extends State<DatePickerDialog>
    with RestorationMixin, HabitDatePickerMixin {
  late final RestorableDateTimeN _selectedDate =
      RestorableDateTimeN(widget.initialDate);
  late final _RestorableDatePickerEntryMode _entryMode =
      _RestorableDatePickerEntryMode(
    widget.initialEntryMode,
  );
  final _RestorableAutovalidateMode _autovalidateMode =
      _RestorableAutovalidateMode(
    AutovalidateMode.disabled,
  );

  @override
  void initState() {
    super.initState();
    // --- HABIT CUSTOM BEGIN: preset dates ---
    initPresetDates(widget.currentDate);
    // --- HABIT CUSTOM END: preset dates ---
  }

  @override
  void dispose() {
    _selectedDate.dispose();
    _entryMode.dispose();
    _autovalidateMode.dispose();
    super.dispose();
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(_autovalidateMode, 'autovalidateMode');
    registerForRestoration(_entryMode, 'calendar_entry_mode');
  }

  final GlobalKey _calendarPickerKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    // --- HABIT CUSTOM BEGIN: merge picked date with current time ---
    final DateTime baseDateTime = widget is HabitDatetimePickerDialog
        ? (widget as HabitDatetimePickerDialog).currentDateTime
        : widget.currentDate;
    final DateTime mergedDate =
        mergeDateToCurrent(baseDateTime, _selectedDate.value);
    Navigator.pop(context, mergedDate);
    // --- HABIT CUSTOM END: merge picked date with current time ---
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOnDatePickerModeChange() {
    widget.onDatePickerModeChange?.call(_entryMode.value);
  }

  void _handleEntryModeToggle() {
    setState(() {
      switch (_entryMode.value) {
        case DatePickerEntryMode.calendar:
          _autovalidateMode.value = AutovalidateMode.disabled;
          _entryMode.value = DatePickerEntryMode.input;
          _handleOnDatePickerModeChange();
        case DatePickerEntryMode.input:
          _formKey.currentState!.save();
          _entryMode.value = DatePickerEntryMode.calendar;
          _handleOnDatePickerModeChange();
        case DatePickerEntryMode.calendarOnly:
        case DatePickerEntryMode.inputOnly:
          assert(false, 'Can not change entry mode from ${_entryMode.value}');
      }
    });
  }

  void _handleDateChanged(DateTime date) {
    // --- HABIT CUSTOM BEGIN: track custom date selection ---
    setState(() {
      _selectedDate.value = date;
      trackOtherDate(date, widget.currentDate);
    });
    // --- HABIT CUSTOM END: track custom date selection ---
  }

  Size _dialogSize(BuildContext context) {
    final bool useMaterial3 = Theme.of(context).useMaterial3;
    final bool isCalendar = switch (_entryMode.value) {
      DatePickerEntryMode.calendar || DatePickerEntryMode.calendarOnly => true,
      DatePickerEntryMode.input || DatePickerEntryMode.inputOnly => false,
    };
    final Orientation orientation = MediaQuery.orientationOf(context);

    return switch ((isCalendar, orientation)) {
      (true, Orientation.portrait) when useMaterial3 =>
        _calendarPortraitDialogSizeM3,
      (false, Orientation.portrait) when useMaterial3 =>
        _inputPortraitDialogSizeM3,
      (true, Orientation.portrait) => _calendarPortraitDialogSizeM2,
      (false, Orientation.portrait) => _inputPortraitDialogSizeM2,
      (true, Orientation.landscape) => _calendarLandscapeDialogSize,
      (false, Orientation.landscape) => _inputLandscapeDialogSize,
    };
  }

  static const Map<ShortcutActivator, Intent> _formShortcutMap =
      <ShortcutActivator, Intent>{
    // Pressing enter on the field will move focus to the next field or control.
    SingleActivator(LogicalKeyboardKey.enter): NextFocusIntent(),
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool useMaterial3 = theme.useMaterial3;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final Orientation orientation = MediaQuery.orientationOf(context);
    final bool isLandscapeOrientation = orientation == Orientation.landscape;
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    final TextTheme textTheme = theme.textTheme;

    // There's no M3 spec for a landscape layout input (not calendar)
    // date picker. To ensure that the date displayed in the input
    // date picker's header fits in landscape mode, we override the M3
    // default here.
    TextStyle? headlineStyle;
    if (useMaterial3) {
      headlineStyle =
          datePickerTheme.headerHeadlineStyle ?? defaults.headerHeadlineStyle;
      switch (_entryMode.value) {
        case DatePickerEntryMode.input:
        case DatePickerEntryMode.inputOnly:
          if (orientation == Orientation.landscape) {
            headlineStyle = textTheme.headlineSmall;
          }
        case DatePickerEntryMode.calendar:
        case DatePickerEntryMode.calendarOnly:
        // M3 default is OK.
      }
    } else {
      headlineStyle = isLandscapeOrientation
          ? textTheme.headlineSmall
          : textTheme.headlineMedium;
    }
    final Color? headerForegroundColor =
        datePickerTheme.headerForegroundColor ?? defaults.headerForegroundColor;
    headlineStyle = headlineStyle?.copyWith(color: headerForegroundColor);

    final Widget actions = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52.0),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: isLandscapeOrientation ? 1.6 : _kMaxTextScaleFactor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: OverflowBar(
              spacing: 8,
              children: <Widget>[
                TextButton(
                  style: datePickerTheme.cancelButtonStyle ??
                      defaults.cancelButtonStyle,
                  onPressed: _handleCancel,
                  child: Text(
                    widget.cancelText ??
                        (useMaterial3
                            ? localizations.cancelButtonLabel
                            : localizations.cancelButtonLabel.toUpperCase()),
                  ),
                ),
                TextButton(
                  style: datePickerTheme.confirmButtonStyle ??
                      defaults.confirmButtonStyle,
                  onPressed: _handleOk,
                  child:
                      Text(widget.confirmText ?? localizations.okButtonLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    CalendarDatePicker calendarDatePicker() {
      return CalendarDatePicker(
        calendarDelegate: widget.calendarDelegate,
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
        child: SizedBox(
          height: orientation == Orientation.portrait
              ? _inputFormPortraitHeight
              : _inputFormLandscapeHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Shortcuts(
              shortcuts: _formShortcutMap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 2.0,
                      child: InputDatePickerFormField(
                        calendarDelegate: widget.calendarDelegate,
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
                    ),
                  ),
                ],
              ),
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
          icon: widget.switchToInputEntryModeIcon ??
              Icon(useMaterial3 ? Icons.edit_outlined : Icons.edit),
          color: headerForegroundColor,
          tooltip: localizations.inputDateModeButtonLabel,
          onPressed: _handleEntryModeToggle,
        );

      case DatePickerEntryMode.calendarOnly:
        picker = calendarDatePicker();
        entryModeButton = null;

      case DatePickerEntryMode.input:
        picker = inputDatePicker();
        entryModeButton = IconButton(
          icon: widget.switchToCalendarEntryModeIcon ??
              const Icon(Icons.calendar_today),
          color: headerForegroundColor,
          tooltip: localizations.calendarModeButtonLabel,
          onPressed: _handleEntryModeToggle,
        );

      case DatePickerEntryMode.inputOnly:
        picker = inputDatePicker();
        entryModeButton = null;
    }

    final Widget header = _DatePickerHeader(
      helpText: widget.helpText ??
          (useMaterial3
              ? localizations.datePickerHelpText
              : localizations.datePickerHelpText.toUpperCase()),
      titleText: _selectedDate.value == null
          ? ''
          : widget.calendarDelegate
              .formatMediumDate(_selectedDate.value!, localizations),
      titleStyle: headlineStyle,
      orientation: orientation,
      isShort: orientation == Orientation.landscape,
      entryModeButton: entryModeButton,
    );

    // Constrain the textScaleFactor to the largest supported value to prevent
    // layout issues.
    // --- HABIT CUSTOM BEGIN: scaled text and dialog size ---
    final TextScaler habitScaler = habitTextScaler(context);
    final Size dialogSize = scaledDialogSize(habitScaler, _dialogSize(context));
    // --- HABIT CUSTOM END: scaled text and dialog size ---
    final DialogThemeData dialogTheme = theme.dialogTheme;
    return Dialog(
      backgroundColor:
          datePickerTheme.backgroundColor ?? defaults.backgroundColor,
      elevation: useMaterial3
          ? datePickerTheme.elevation ?? defaults.elevation!
          : datePickerTheme.elevation ?? dialogTheme.elevation ?? 24,
      shadowColor: datePickerTheme.shadowColor ?? defaults.shadowColor,
      surfaceTintColor:
          datePickerTheme.surfaceTintColor ?? defaults.surfaceTintColor,
      shape: useMaterial3
          ? datePickerTheme.shape ?? defaults.shape
          : datePickerTheme.shape ?? dialogTheme.shape ?? defaults.shape,
      insetPadding: widget.insetPadding,
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: dialogSize.width,
        height: dialogSize.height,
        duration: _dialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery.withClampedTextScaling(
          // Constrain the textScaleFactor to the largest supported value to prevent
          // layout issues.
          maxScaleFactor: _kMaxTextScaleFactor,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Size portraitDialogSize = useMaterial3
                  ? _inputPortraitDialogSizeM3
                  : _inputPortraitDialogSizeM2;
              // Make sure the portrait dialog can fit the contents comfortably when
              // resized from the landscape dialog.
              final bool isFullyPortrait = constraints.maxHeight >=
                  math.min(dialogSize.height, portraitDialogSize.height);

              switch (orientation) {
                case Orientation.portrait:
                  final bool isInputMode =
                      _entryMode.value == DatePickerEntryMode.inputOnly ||
                          _entryMode.value == DatePickerEntryMode.input;
                  // When the portrait dialog does not fit vertically, hide the header when the entry mode
                  // is input, or hide the picker when the entry mode is not input.
                  final bool showHeader = isFullyPortrait || !isInputMode;
                  final bool showPicker = isFullyPortrait || isInputMode;

                  // --- HABIT CUSTOM BEGIN: ensure custom date tracked ---
                  if (_selectedDate.value != null) {
                    ensureOtherDate(_selectedDate.value!, widget.currentDate);
                  }
                  // --- HABIT CUSTOM END: ensure custom date tracked ---

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (showHeader) header,
                      if (useMaterial3)
                        Divider(height: 0, color: datePickerTheme.dividerColor),
                      if (showPicker) ...<Widget>[
                        // --- HABIT CUSTOM BEGIN: date shortcut chips ---
                        buildDateShortcuts(
                          context: context,
                          selectedDate:
                              _selectedDate.value ?? widget.currentDate,
                          today: widget.currentDate,
                          tomorrow: tomorrowDate,
                          nextWeek: nextDate,
                          customDate: otherDate,
                          onDateChanged: _handleDateChanged,
                          l10n: L10n.of(context),
                          colorScheme: Theme.of(context).colorScheme,
                        ),
                        // --- HABIT CUSTOM END: date shortcut chips ---
                        Expanded(child: picker),
                        actions
                      ],
                    ],
                  );
                case Orientation.landscape:
                  // --- HABIT CUSTOM BEGIN: ensure custom date tracked ---
                  if (_selectedDate.value != null) {
                    ensureOtherDate(_selectedDate.value!, widget.currentDate);
                  }
                  // --- HABIT CUSTOM END: ensure custom date tracked ---
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      header,
                      if (useMaterial3)
                        VerticalDivider(
                            width: 0, color: datePickerTheme.dividerColor),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // --- HABIT CUSTOM BEGIN: date shortcut chips ---
                            buildDateShortcuts(
                              context: context,
                              selectedDate:
                                  _selectedDate.value ?? widget.currentDate,
                              today: widget.currentDate,
                              tomorrow: tomorrowDate,
                              nextWeek: nextDate,
                              customDate: otherDate,
                              onDateChanged: _handleDateChanged,
                              l10n: L10n.of(context),
                              colorScheme: Theme.of(context).colorScheme,
                            ),
                            // --- HABIT CUSTOM END: date shortcut chips ---
                            Expanded(child: picker),
                            actions,
                          ],
                        ),
                      ),
                    ],
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

// A restorable [DatePickerEntryMode] value.
//
// This serializes each entry as a unique `int` value.
class _RestorableDatePickerEntryMode
    extends RestorableValue<DatePickerEntryMode> {
  _RestorableDatePickerEntryMode(DatePickerEntryMode defaultValue)
      : _defaultValue = defaultValue;

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

// A restorable [AutovalidateMode] value.
//
// This serializes each entry as a unique `int` value.
class _RestorableAutovalidateMode extends RestorableValue<AutovalidateMode> {
  _RestorableAutovalidateMode(AutovalidateMode defaultValue)
      : _defaultValue = defaultValue;

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

/// Re-usable widget that displays the selected date (in large font) and the
/// help text above it.
///
/// These types include:
///
/// * Single Date picker with calendar mode.
/// * Single Date picker with text input mode.
/// * Date Range picker with text input mode.
class _DatePickerHeader extends StatelessWidget {
  /// Creates a header for use in a date picker dialog.
  const _DatePickerHeader({
    required this.helpText,
    required this.titleText,
    this.titleSemanticsLabel,
    required this.titleStyle,
    required this.orientation,
    this.isShort = false,
    this.entryModeButton,
  });

  static const double _datePickerHeaderLandscapeWidth = 152.0;
  static const double _datePickerHeaderPortraitHeight = 120.0;
  static const double _headerPaddingLandscape = 16.0;

  /// The text that is displayed at the top of the header.
  ///
  /// This is used to indicate to the user what they are selecting a date for.
  final String helpText;

  /// The text that is displayed at the center of the header.
  final String titleText;

  /// The semantic label associated with the [titleText].
  final String? titleSemanticsLabel;

  /// The [TextStyle] that the title text is displayed with.
  final TextStyle? titleStyle;

  /// The orientation is used to decide how to layout its children.
  final Orientation orientation;

  /// Indicates the header is being displayed in a shorter/narrower context.
  ///
  /// This will be used to tighten up the space between the help text and date
  /// text if `true`. Additionally, it will use a smaller typography style if
  /// `true`.
  ///
  /// This is necessary for displaying the manual input mode in
  /// landscape orientation, in order to account for the keyboard height.
  final bool isShort;

  final Widget? entryModeButton;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    final Color? backgroundColor =
        datePickerTheme.headerBackgroundColor ?? defaults.headerBackgroundColor;
    final Color? foregroundColor =
        datePickerTheme.headerForegroundColor ?? defaults.headerForegroundColor;
    final TextStyle? helpStyle =
        (datePickerTheme.headerHelpStyle ?? defaults.headerHelpStyle)
            ?.copyWith(color: foregroundColor);
    final double currentScale =
        MediaQuery.textScalerOf(context).scale(_fontSizeToScale) /
            _fontSizeToScale;
    final double maxHeaderTextScaleFactor = math.min(
      currentScale,
      entryModeButton != null
          ? _kMaxHeaderWithEntryTextScaleFactor
          : _kMaxHeaderTextScaleFactor,
    );
    final double textScaleFactor = MediaQuery.textScalerOf(
          context,
        )
            .clamp(maxScaleFactor: maxHeaderTextScaleFactor)
            .scale(_fontSizeToScale) /
        _fontSizeToScale;
    final double scaledFontSize = MediaQuery.textScalerOf(
      context,
    ).scale(titleStyle?.fontSize ?? 32);
    final double headerScaleFactor =
        textScaleFactor > 1 ? textScaleFactor : 1.0;

    final Text help = Text(
      helpText,
      style: helpStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textScaler: MediaQuery.textScalerOf(context).clamp(
        maxScaleFactor: math.min(
          textScaleFactor,
          orientation == Orientation.portrait
              ? _kMaxHelpPortraitTextScaleFactor
              : _kMaxHelpLandscapeTextScaleFactor,
        ),
      ),
    );
    final Text title = Text(
      titleText,
      semanticsLabel: titleSemanticsLabel ?? titleText,
      style: titleStyle,
      maxLines: orientation == Orientation.portrait
          ? (scaledFontSize > 70 ? 2 : 1)
          : scaledFontSize > 40
              ? 3
              : 2,
      overflow: TextOverflow.ellipsis,
      textScaler: MediaQuery.textScalerOf(context)
          .clamp(maxScaleFactor: textScaleFactor),
    );

    final double fontScaleAdjustedHeaderHeight =
        headerScaleFactor > 1.3 ? headerScaleFactor - 0.2 : 1.0;

    switch (orientation) {
      case Orientation.portrait:
        return Semantics(
          container: true,
          child: SizedBox(
            height:
                _datePickerHeaderPortraitHeight * fontScaleAdjustedHeaderHeight,
            child: Material(
              color: backgroundColor,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 24, end: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    help,
                    const Flexible(child: SizedBox(height: 38)),
                    Row(
                      children: <Widget>[
                        Expanded(child: title),
                        if (entryModeButton != null)
                          Semantics(container: true, child: entryModeButton),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      case Orientation.landscape:
        return Semantics(
          container: true,
          child: SizedBox(
            width: _datePickerHeaderLandscapeWidth,
            child: Material(
              color: backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: _headerPaddingLandscape),
                    child: help,
                  ),
                  SizedBox(height: isShort ? 16 : 56),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: _headerPaddingLandscape),
                      child: title,
                    ),
                  ),
                  if (entryModeButton != null)
                    Padding(
                      padding: theme.useMaterial3
                          // TODO(TahaTesser): This is an eye-balled M3 entry mode button padding
                          // from https://m3.material.io/components/date-pickers/specs#c16c142b-4706-47f3-9400-3cde654b9aa8.
                          // Update this value to use tokens when available.
                          ? const EdgeInsetsDirectional.only(
                              start: 8.0, end: 4.0, bottom: 6.0)
                          : const EdgeInsets.symmetric(horizontal: 4),
                      child: Semantics(container: true, child: entryModeButton),
                    ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
//#endregion
