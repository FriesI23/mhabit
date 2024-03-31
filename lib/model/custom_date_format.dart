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

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import '../common/enums.dart';
import '../l10n/localizations.dart';
import 'common.dart';

part 'custom_date_format.g.dart';

@JsonEnum(valueField: 'code')
enum YearMonthDayFormtEnum implements EnumWithDBCodeABC {
  yearMonthDay(code: 1),
  monthDayYear(code: 2),
  dayMonthYear(code: 3);

  final int code;

  const YearMonthDayFormtEnum({required this.code});

  @override
  int get dbCode => code;
}

@JsonEnum(valueField: 'code')
enum DateSplitCharEnum implements EnumWithDBCodeABC {
  dash(code: 1, char: '-'),
  slash(code: 2, char: '/'),
  space(code: 3, char: ' '),
  dot(code: 4, char: '.'),
  empty(code: 99, char: '');

  final String char;
  final int code;

  const DateSplitCharEnum({required this.code, required this.char});

  @override
  int get dbCode => code;
}

@CopyWith(skipFields: true)
@JsonSerializable()
class CustomDateYmdHmsConfig implements JsonAdaptor {
  final YearMonthDayFormtEnum ymdFormat;
  final DateSplitCharEnum splitChar;
  final bool twelveHoursOn;
  final bool useMonthWithName;
  final bool useSystemFormat;
  final bool? applyFreqChart;
  final bool? applyHeatmapCal;

  bool get isApplyFreqChart => applyFreqChart ?? false;
  bool get isApplyHeatmapCal => applyHeatmapCal ?? false;

  const CustomDateYmdHmsConfig({
    required this.ymdFormat,
    required this.splitChar,
    required this.twelveHoursOn,
    this.useMonthWithName = false,
    this.useSystemFormat = true,
    this.applyFreqChart,
    this.applyHeatmapCal,
  }) : assert(ymdFormat == YearMonthDayFormtEnum.dayMonthYear ||
            ymdFormat == YearMonthDayFormtEnum.monthDayYear ||
            ymdFormat == YearMonthDayFormtEnum.yearMonthDay);

  const CustomDateYmdHmsConfig.withDefault()
      : ymdFormat = YearMonthDayFormtEnum.yearMonthDay,
        splitChar = DateSplitCharEnum.slash,
        twelveHoursOn = false,
        useMonthWithName = false,
        useSystemFormat = true,
        applyFreqChart = false,
        applyHeatmapCal = false;

  factory CustomDateYmdHmsConfig.fromJson(dynamic json) =>
      _$CustomDateYmdHmsConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CustomDateYmdHmsConfigToJson(this);

  String? _getYearFormatterString(String? locale) =>
      DateFormat(useMonthWithName ? DateFormat.YEAR : 'yyyy', locale).pattern;

  String? _getMonthFormatterString(String? locale) => useMonthWithName
      ? DateFormat(DateFormat.ABBR_MONTH, locale).pattern
      : DateFormat.NUM_MONTH;

  String? _getDayFormatterString(String? locale) =>
      useMonthWithName ? DateFormat(DateFormat.DAY, locale).pattern : 'd';

  DateFormat getFormatter([String? locale]) {
    if (useSystemFormat) {
      return DateFormat.yMd(locale).add_Hms();
    } else {
      return _getYMDHMSFormatterWithConfig(locale);
    }
  }

  DateFormat _getYMDHMSFormatterWithConfig(String? locale) {
    final ymdPattern = _getYMDFormatterWithConfig(locale).pattern;
    final hmsPattern = DateFormat(
            twelveHoursOn
                ? DateFormat.HOUR_MINUTE_SECOND
                : DateFormat.HOUR24_MINUTE_SECOND,
            locale)
        .pattern;
    return DateFormat([ymdPattern, hmsPattern].join(" "), locale);
  }

  DateFormat getYMDFormatter([String? locale]) {
    if (useSystemFormat) {
      return DateFormat.yMd(locale);
    } else {
      return _getYMDFormatterWithConfig(locale);
    }
  }

  DateFormat getYMDFormatterForFreqChart([String? locale]) {
    if (useSystemFormat || !isApplyFreqChart) {
      return DateFormat.yMd(locale);
    } else {
      return _getYMDFormatterWithConfig(locale);
    }
  }

  DateFormat _getYMDFormatterWithConfig(String? locale) {
    String getYMDFormatter() {
      final formatYear = _getYearFormatterString(locale);
      final formatMonth = _getMonthFormatterString(locale);
      final formatDay = _getDayFormatterString(locale);
      switch (ymdFormat) {
        case YearMonthDayFormtEnum.yearMonthDay:
          return [formatYear, formatMonth, formatDay].join(splitChar.char);
        case YearMonthDayFormtEnum.monthDayYear:
          return [formatMonth, formatDay, formatYear].join(splitChar.char);
        case YearMonthDayFormtEnum.dayMonthYear:
          return [formatDay, formatMonth, formatYear].join(splitChar.char);
        default:
          throw UnsupportedError("unsupport formatter with ymdhms config");
      }
    }

    return DateFormat(getYMDFormatter(), locale);
  }

  DateFormat getYMFormatterForFreqChart([String? locale]) {
    if (useSystemFormat || !isApplyFreqChart) {
      return DateFormat.yM(locale);
    } else {
      return _getYMFormatterWithConfig(locale);
    }
  }

  DateFormat getYMFormatterForHeatmapCal([String? locale]) {
    if (useSystemFormat || !isApplyHeatmapCal) {
      return DateFormat.yMMM(locale);
    } else {
      return _getYMFormatterWithConfig(locale);
    }
  }

  DateFormat _getYMFormatterWithConfig(String? locale) {
    final formatYear = _getYearFormatterString(locale);
    final formatMonth = _getMonthFormatterString(locale);
    switch (ymdFormat) {
      case YearMonthDayFormtEnum.yearMonthDay:
        return DateFormat(
            [formatYear, formatMonth].join(splitChar.char), locale);
      case YearMonthDayFormtEnum.monthDayYear:
      case YearMonthDayFormtEnum.dayMonthYear:
        return DateFormat(
            [formatMonth, formatYear].join(splitChar.char), locale);
      default:
        throw UnsupportedError("unsupport formatter with ym config");
    }
  }

  DateFormat getYFormatterForFreqChart([String? locale]) {
    if (useSystemFormat || !isApplyFreqChart) {
      return DateFormat.y(locale);
    } else {
      return DateFormat(DateFormat.YEAR, locale);
    }
  }

  String getYearMonthDayDisplayText([L10n? l10n]) {
    switch (ymdFormat) {
      case YearMonthDayFormtEnum.yearMonthDay:
        return l10n != null
            ? l10n.common_customDateTimeFormatPicker_ymd_text
            : "Year Month Day";
      case YearMonthDayFormtEnum.monthDayYear:
        return l10n != null
            ? l10n.common_customDateTimeFormatPicker_mdy_text
            : "Month Day Year";
      case YearMonthDayFormtEnum.dayMonthYear:
        return l10n != null
            ? l10n.common_customDateTimeFormatPicker_dmy_text
            : "Day Month Year";
    }
  }

  String getSplitCharDisplayText([L10n? l10n]) {
    switch (splitChar) {
      case DateSplitCharEnum.dash:
        return l10n != null
            ? l10n.common_customDateTimeFormatPicker_sep_formatter(
                l10n.common_customDateTimeFormatPicker_sepDash_text,
                splitChar.char)
            : splitChar.char;
      case DateSplitCharEnum.slash:
        return l10n != null
            ? l10n.common_customDateTimeFormatPicker_sep_formatter(
                l10n.common_customDateTimeFormatPicker_sepSlash_text,
                splitChar.char)
            : splitChar.char;
      case DateSplitCharEnum.space:
        return l10n != null
            ? l10n.common_customDateTimeFormatPicker_sep_formatter(
                l10n.common_customDateTimeFormatPicker_sepSpace_text,
                splitChar.char)
            : splitChar.char;
      case DateSplitCharEnum.dot:
        return l10n != null
            ? l10n.common_customDateTimeFormatPicker_sep_formatter(
                l10n.common_customDateTimeFormatPicker_sepDot_text,
                splitChar.char)
            : splitChar.char;
      case DateSplitCharEnum.empty:
        return l10n != null
            ? l10n.common_customDateTimeFormatPicker_empty_text
            : splitChar.char;
    }
  }

  @override
  String toString() => "$runtimeType(${toJson()})";
}
