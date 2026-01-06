// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file

part of 'habit_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HabitSummaryRecordCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// HabitSummaryRecord(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitSummaryRecord call({
    HabitRecordUUID uuid,
    HabitRecordDate date,
    HabitRecordStatus status,
    HabitDailyGoal value,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfHabitSummaryRecord.copyWith(...)`.
class _$HabitSummaryRecordCWProxyImpl implements _$HabitSummaryRecordCWProxy {
  const _$HabitSummaryRecordCWProxyImpl(this._value);

  final HabitSummaryRecord _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// HabitSummaryRecord(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitSummaryRecord call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
  }) {
    return HabitSummaryRecord(
      uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as HabitRecordUUID,
      date == const $CopyWithPlaceholder() || date == null
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as HabitRecordDate,
      status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as HabitRecordStatus,
      value == const $CopyWithPlaceholder() || value == null
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as HabitDailyGoal,
    );
  }
}

extension $HabitSummaryRecordCopyWith on HabitSummaryRecord {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfHabitSummaryRecord.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitSummaryRecordCWProxy get copyWith =>
      _$HabitSummaryRecordCWProxyImpl(this);
}
