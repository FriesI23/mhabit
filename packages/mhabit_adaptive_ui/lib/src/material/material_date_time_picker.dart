import 'package:flutter/material.dart' hide showDatePicker, showTimePicker;
import 'package:flutter/material.dart' as material;

import '../adaptive/adaptive_modal_viewport.dart';

/// Opens the existing date picker within its route's available viewport.
///
/// Date bounds, localization, entry modes and results follow [material.showDatePicker].
/// An optional [builder] runs inside the viewport and can override inherited
/// themes without repeating the display-feature layout.
Future<DateTime?> showDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? currentDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  SelectableDayPredicate? selectableDayPredicate,
  String? helpText,
  String? cancelText,
  String? confirmText,
  Locale? locale,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TextDirection? textDirection,
  TransitionBuilder? builder,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  String? errorFormatText,
  String? errorInvalidText,
  String? fieldHintText,
  String? fieldLabelText,
  TextInputType? keyboardType,
  Offset? anchorPoint,
  ValueChanged<DatePickerEntryMode>? onDatePickerModeChange,
  Icon? switchToInputEntryModeIcon,
  Icon? switchToCalendarEntryModeIcon,
  CalendarDelegate<DateTime> calendarDelegate =
      const GregorianCalendarDelegate(),
}) => material.showDatePicker(
  context: context,
  initialDate: initialDate,
  firstDate: firstDate,
  lastDate: lastDate,
  currentDate: currentDate,
  initialEntryMode: initialEntryMode,
  selectableDayPredicate: selectableDayPredicate,
  helpText: helpText,
  cancelText: cancelText,
  confirmText: confirmText,
  locale: locale,
  barrierDismissible: barrierDismissible,
  barrierColor: barrierColor,
  barrierLabel: barrierLabel,
  useRootNavigator: useRootNavigator,
  routeSettings: routeSettings,
  textDirection: textDirection,
  builder: _viewportBuilder(builder),
  initialDatePickerMode: initialDatePickerMode,
  errorFormatText: errorFormatText,
  errorInvalidText: errorInvalidText,
  fieldHintText: fieldHintText,
  fieldLabelText: fieldLabelText,
  keyboardType: keyboardType,
  anchorPoint: anchorPoint,
  onDatePickerModeChange: onDatePickerModeChange,
  switchToInputEntryModeIcon: switchToInputEntryModeIcon,
  switchToCalendarEntryModeIcon: switchToCalendarEntryModeIcon,
  calendarDelegate: calendarDelegate,
);

/// Opens the existing time picker within its route's available viewport.
///
/// Parameters and results follow [material.showTimePicker]. The optional [builder]
/// receives the local viewport rather than the whole window's MediaQuery.
Future<TimeOfDay?> showTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  TransitionBuilder? builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
  String? cancelText,
  String? confirmText,
  String? helpText,
  String? errorInvalidText,
  String? hourLabelText,
  String? minuteLabelText,
  RouteSettings? routeSettings,
  EntryModeChangeCallback? onEntryModeChanged,
  Offset? anchorPoint,
  Orientation? orientation,
  Icon? switchToInputEntryModeIcon,
  Icon? switchToTimerEntryModeIcon,
  bool emptyInitialInput = false,
}) => material.showTimePicker(
  context: context,
  initialTime: initialTime,
  builder: _viewportBuilder(builder),
  barrierDismissible: barrierDismissible,
  barrierColor: barrierColor,
  barrierLabel: barrierLabel,
  useRootNavigator: useRootNavigator,
  initialEntryMode: initialEntryMode,
  cancelText: cancelText,
  confirmText: confirmText,
  helpText: helpText,
  errorInvalidText: errorInvalidText,
  hourLabelText: hourLabelText,
  minuteLabelText: minuteLabelText,
  routeSettings: routeSettings,
  onEntryModeChanged: onEntryModeChanged,
  anchorPoint: anchorPoint,
  orientation: orientation,
  switchToInputEntryModeIcon: switchToInputEntryModeIcon,
  switchToTimerEntryModeIcon: switchToTimerEntryModeIcon,
  emptyInitialInput: emptyInitialInput,
);

TransitionBuilder _viewportBuilder(TransitionBuilder? builder) =>
    (context, child) => AdaptiveModalViewport(
      child: Builder(
        builder: (context) =>
            builder?.call(context, child) ?? child ?? const SizedBox.shrink(),
      ),
    );
