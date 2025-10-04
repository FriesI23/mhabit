// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HabitSummaryRecordCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// HabitSummaryRecord(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitSummaryRecord call({
    String uuid,
    HabitDate date,
    HabitRecordStatus status,
    num value,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHabitSummaryRecord.copyWith(...)`.
class _$HabitSummaryRecordCWProxyImpl implements _$HabitSummaryRecordCWProxy {
  const _$HabitSummaryRecordCWProxyImpl(this._value);

  final HabitSummaryRecord _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// HabitSummaryRecord(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitSummaryRecord call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
  }) {
    return HabitSummaryRecord(
      uuid == const $CopyWithPlaceholder()
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as HabitDate,
      status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as HabitRecordStatus,
      value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as num,
    );
  }
}

extension $HabitSummaryRecordCopyWith on HabitSummaryRecord {
  /// Returns a callable class that can be used as follows: `instanceOfHabitSummaryRecord.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitSummaryRecordCWProxy get copyWith =>
      _$HabitSummaryRecordCWProxyImpl(this);
}
