// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file
// ignore_for_file: type=lint


part of 'habit_stat.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HabitRangeDayStatisticCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// HabitRangeDayStatistic(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitRangeDayStatistic call({
    HabitUUID uuid,
    num startProgress,
    HabitDate lastStartRecordData,
    num enededProgress,
    HabitDate lastEndedRecordDate,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfHabitRangeDayStatistic.copyWith(...)`.
class _$HabitRangeDayStatisticCWProxyImpl
    implements _$HabitRangeDayStatisticCWProxy {
  const _$HabitRangeDayStatisticCWProxyImpl(this._value);

  final HabitRangeDayStatistic _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// HabitRangeDayStatistic(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitRangeDayStatistic call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? startProgress = const $CopyWithPlaceholder(),
    Object? lastStartRecordData = const $CopyWithPlaceholder(),
    Object? enededProgress = const $CopyWithPlaceholder(),
    Object? lastEndedRecordDate = const $CopyWithPlaceholder(),
  }) {
    return HabitRangeDayStatistic(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as HabitUUID,
      startProgress:
          startProgress == const $CopyWithPlaceholder() || startProgress == null
          ? _value.startProgress
          // ignore: cast_nullable_to_non_nullable
          : startProgress as num,
      lastStartRecordData:
          lastStartRecordData == const $CopyWithPlaceholder() ||
              lastStartRecordData == null
          ? _value.lastStartRecordData
          // ignore: cast_nullable_to_non_nullable
          : lastStartRecordData as HabitDate,
      enededProgress:
          enededProgress == const $CopyWithPlaceholder() ||
              enededProgress == null
          ? _value.enededProgress
          // ignore: cast_nullable_to_non_nullable
          : enededProgress as num,
      lastEndedRecordDate:
          lastEndedRecordDate == const $CopyWithPlaceholder() ||
              lastEndedRecordDate == null
          ? _value.lastEndedRecordDate
          // ignore: cast_nullable_to_non_nullable
          : lastEndedRecordDate as HabitDate,
    );
  }
}

extension $HabitRangeDayStatisticCopyWith on HabitRangeDayStatistic {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfHabitRangeDayStatistic.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitRangeDayStatisticCWProxy get copyWith =>
      _$HabitRangeDayStatisticCWProxyImpl(this);
}

abstract class _$HabitSummaryStatisticsDataCWProxy {
  HabitSummaryStatisticsData currentComplatedCount(int currentComplatedCount);

  HabitSummaryStatisticsData currentInProgressCount(int currentInProgressCount);

  HabitSummaryStatisticsData currentArchivedCount(int currentArchivedCount);

  HabitSummaryStatisticsData currentPopularityData(
    List<HabitRangeDayStatistic> currentPopularityData,
  );

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `HabitSummaryStatisticsData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// HabitSummaryStatisticsData(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitSummaryStatisticsData call({
    int currentComplatedCount,
    int currentInProgressCount,
    int currentArchivedCount,
    List<HabitRangeDayStatistic> currentPopularityData,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfHabitSummaryStatisticsData.copyWith(...)` or call `instanceOfHabitSummaryStatisticsData.copyWith.fieldName(value)` for a single field.
class _$HabitSummaryStatisticsDataCWProxyImpl
    implements _$HabitSummaryStatisticsDataCWProxy {
  const _$HabitSummaryStatisticsDataCWProxyImpl(this._value);

  final HabitSummaryStatisticsData _value;

  @override
  HabitSummaryStatisticsData currentComplatedCount(int currentComplatedCount) =>
      call(currentComplatedCount: currentComplatedCount);

  @override
  HabitSummaryStatisticsData currentInProgressCount(
    int currentInProgressCount,
  ) => call(currentInProgressCount: currentInProgressCount);

  @override
  HabitSummaryStatisticsData currentArchivedCount(int currentArchivedCount) =>
      call(currentArchivedCount: currentArchivedCount);

  @override
  HabitSummaryStatisticsData currentPopularityData(
    List<HabitRangeDayStatistic> currentPopularityData,
  ) => call(currentPopularityData: currentPopularityData);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `HabitSummaryStatisticsData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// HabitSummaryStatisticsData(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitSummaryStatisticsData call({
    Object? currentComplatedCount = const $CopyWithPlaceholder(),
    Object? currentInProgressCount = const $CopyWithPlaceholder(),
    Object? currentArchivedCount = const $CopyWithPlaceholder(),
    Object? currentPopularityData = const $CopyWithPlaceholder(),
  }) {
    return HabitSummaryStatisticsData(
      currentComplatedCount:
          currentComplatedCount == const $CopyWithPlaceholder() ||
              currentComplatedCount == null
          ? _value.currentComplatedCount
          // ignore: cast_nullable_to_non_nullable
          : currentComplatedCount as int,
      currentInProgressCount:
          currentInProgressCount == const $CopyWithPlaceholder() ||
              currentInProgressCount == null
          ? _value.currentInProgressCount
          // ignore: cast_nullable_to_non_nullable
          : currentInProgressCount as int,
      currentArchivedCount:
          currentArchivedCount == const $CopyWithPlaceholder() ||
              currentArchivedCount == null
          ? _value.currentArchivedCount
          // ignore: cast_nullable_to_non_nullable
          : currentArchivedCount as int,
      currentPopularityData:
          currentPopularityData == const $CopyWithPlaceholder() ||
              currentPopularityData == null
          ? _value.currentPopularityData
          // ignore: cast_nullable_to_non_nullable
          : currentPopularityData as List<HabitRangeDayStatistic>,
    );
  }
}

extension $HabitSummaryStatisticsDataCopyWith on HabitSummaryStatisticsData {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfHabitSummaryStatisticsData.copyWith(...)` or `instanceOfHabitSummaryStatisticsData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitSummaryStatisticsDataCWProxy get copyWith =>
      _$HabitSummaryStatisticsDataCWProxyImpl(this);
}
