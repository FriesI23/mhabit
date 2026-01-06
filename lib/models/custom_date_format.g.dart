// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file

part of 'custom_date_format.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomDateYmdHmsConfigCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// CustomDateYmdHmsConfig(...).copyWith(id: 12, name: "My name")
  /// ```
  CustomDateYmdHmsConfig call({
    YearMonthDayFormtEnum ymdFormat,
    DateSplitCharEnum splitChar,
    bool twelveHoursOn,
    bool useMonthWithName,
    bool useSystemFormat,
    bool useLeadingZero,
    bool? applyFreqChart,
    bool? applyHeatmapCal,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfCustomDateYmdHmsConfig.copyWith(...)`.
class _$CustomDateYmdHmsConfigCWProxyImpl
    implements _$CustomDateYmdHmsConfigCWProxy {
  const _$CustomDateYmdHmsConfigCWProxyImpl(this._value);

  final CustomDateYmdHmsConfig _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// CustomDateYmdHmsConfig(...).copyWith(id: 12, name: "My name")
  /// ```
  CustomDateYmdHmsConfig call({
    Object? ymdFormat = const $CopyWithPlaceholder(),
    Object? splitChar = const $CopyWithPlaceholder(),
    Object? twelveHoursOn = const $CopyWithPlaceholder(),
    Object? useMonthWithName = const $CopyWithPlaceholder(),
    Object? useSystemFormat = const $CopyWithPlaceholder(),
    Object? useLeadingZero = const $CopyWithPlaceholder(),
    Object? applyFreqChart = const $CopyWithPlaceholder(),
    Object? applyHeatmapCal = const $CopyWithPlaceholder(),
  }) {
    return CustomDateYmdHmsConfig(
      ymdFormat: ymdFormat == const $CopyWithPlaceholder() || ymdFormat == null
          ? _value.ymdFormat
          // ignore: cast_nullable_to_non_nullable
          : ymdFormat as YearMonthDayFormtEnum,
      splitChar: splitChar == const $CopyWithPlaceholder() || splitChar == null
          ? _value.splitChar
          // ignore: cast_nullable_to_non_nullable
          : splitChar as DateSplitCharEnum,
      twelveHoursOn:
          twelveHoursOn == const $CopyWithPlaceholder() || twelveHoursOn == null
          ? _value.twelveHoursOn
          // ignore: cast_nullable_to_non_nullable
          : twelveHoursOn as bool,
      useMonthWithName:
          useMonthWithName == const $CopyWithPlaceholder() ||
              useMonthWithName == null
          ? _value.useMonthWithName
          // ignore: cast_nullable_to_non_nullable
          : useMonthWithName as bool,
      useSystemFormat:
          useSystemFormat == const $CopyWithPlaceholder() ||
              useSystemFormat == null
          ? _value.useSystemFormat
          // ignore: cast_nullable_to_non_nullable
          : useSystemFormat as bool,
      useLeadingZero:
          useLeadingZero == const $CopyWithPlaceholder() ||
              useLeadingZero == null
          ? _value.useLeadingZero
          // ignore: cast_nullable_to_non_nullable
          : useLeadingZero as bool,
      applyFreqChart: applyFreqChart == const $CopyWithPlaceholder()
          ? _value.applyFreqChart
          // ignore: cast_nullable_to_non_nullable
          : applyFreqChart as bool?,
      applyHeatmapCal: applyHeatmapCal == const $CopyWithPlaceholder()
          ? _value.applyHeatmapCal
          // ignore: cast_nullable_to_non_nullable
          : applyHeatmapCal as bool?,
    );
  }
}

extension $CustomDateYmdHmsConfigCopyWith on CustomDateYmdHmsConfig {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfCustomDateYmdHmsConfig.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomDateYmdHmsConfigCWProxy get copyWith =>
      _$CustomDateYmdHmsConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomDateYmdHmsConfig _$CustomDateYmdHmsConfigFromJson(
  Map<String, dynamic> json,
) => CustomDateYmdHmsConfig(
  ymdFormat: $enumDecode(_$YearMonthDayFormtEnumEnumMap, json['ymdFormat']),
  splitChar: $enumDecode(_$DateSplitCharEnumEnumMap, json['splitChar']),
  twelveHoursOn: json['twelveHoursOn'] as bool,
  useMonthWithName: json['useMonthWithName'] as bool? ?? false,
  useSystemFormat: json['useSystemFormat'] as bool? ?? true,
  useLeadingZero: json['useLeadingZero'] as bool? ?? false,
  applyFreqChart: json['applyFreqChart'] as bool?,
  applyHeatmapCal: json['applyHeatmapCal'] as bool?,
);

Map<String, dynamic> _$CustomDateYmdHmsConfigToJson(
  CustomDateYmdHmsConfig instance,
) => <String, dynamic>{
  'ymdFormat': _$YearMonthDayFormtEnumEnumMap[instance.ymdFormat]!,
  'splitChar': _$DateSplitCharEnumEnumMap[instance.splitChar]!,
  'twelveHoursOn': instance.twelveHoursOn,
  'useMonthWithName': instance.useMonthWithName,
  'useSystemFormat': instance.useSystemFormat,
  'useLeadingZero': instance.useLeadingZero,
  'applyFreqChart': instance.applyFreqChart,
  'applyHeatmapCal': instance.applyHeatmapCal,
};

const _$YearMonthDayFormtEnumEnumMap = {
  YearMonthDayFormtEnum.yearMonthDay: 1,
  YearMonthDayFormtEnum.monthDayYear: 2,
  YearMonthDayFormtEnum.dayMonthYear: 3,
};

const _$DateSplitCharEnumEnumMap = {
  DateSplitCharEnum.dash: 1,
  DateSplitCharEnum.slash: 2,
  DateSplitCharEnum.space: 3,
  DateSplitCharEnum.dot: 4,
  DateSplitCharEnum.empty: 99,
};
