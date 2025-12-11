// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file
// ignore_for_file: type=lint


part of 'custom_date_format.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomDateYmdHmsConfigCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// CustomDateYmdHmsConfig(...).copyWith(id: 12, name: "My name")
  /// ````
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

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomDateYmdHmsConfig.copyWith(...)`.
class _$CustomDateYmdHmsConfigCWProxyImpl
    implements _$CustomDateYmdHmsConfigCWProxy {
  const _$CustomDateYmdHmsConfigCWProxyImpl(this._value);

  final CustomDateYmdHmsConfig _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// CustomDateYmdHmsConfig(...).copyWith(id: 12, name: "My name")
  /// ````
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
      ymdFormat: ymdFormat == const $CopyWithPlaceholder()
          ? _value.ymdFormat
          // ignore: cast_nullable_to_non_nullable
          : ymdFormat as YearMonthDayFormtEnum,
      splitChar: splitChar == const $CopyWithPlaceholder()
          ? _value.splitChar
          // ignore: cast_nullable_to_non_nullable
          : splitChar as DateSplitCharEnum,
      twelveHoursOn: twelveHoursOn == const $CopyWithPlaceholder()
          ? _value.twelveHoursOn
          // ignore: cast_nullable_to_non_nullable
          : twelveHoursOn as bool,
      useMonthWithName: useMonthWithName == const $CopyWithPlaceholder()
          ? _value.useMonthWithName
          // ignore: cast_nullable_to_non_nullable
          : useMonthWithName as bool,
      useSystemFormat: useSystemFormat == const $CopyWithPlaceholder()
          ? _value.useSystemFormat
          // ignore: cast_nullable_to_non_nullable
          : useSystemFormat as bool,
      useLeadingZero: useLeadingZero == const $CopyWithPlaceholder()
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
  /// Returns a callable class that can be used as follows: `instanceOfCustomDateYmdHmsConfig.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomDateYmdHmsConfigCWProxy get copyWith =>
      _$CustomDateYmdHmsConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomDateYmdHmsConfig _$CustomDateYmdHmsConfigFromJson(
        Map<String, dynamic> json) =>
    CustomDateYmdHmsConfig(
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
        CustomDateYmdHmsConfig instance) =>
    <String, dynamic>{
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
