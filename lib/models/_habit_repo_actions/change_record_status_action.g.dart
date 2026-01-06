// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file
// ignore_for_file: type=lint


part of 'change_record_status_action.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChangeRecordStatusResultCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// ChangeRecordStatusResult(...).copyWith(id: 12, name: "My name")
  /// ```
  ChangeRecordStatusResult call({
    HabitSummaryData habit,
    HabitSummaryRecord? origin,
    HabitSummaryRecord data,
    String? reason,
    bool added,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfChangeRecordStatusResult.copyWith(...)`.
class _$ChangeRecordStatusResultCWProxyImpl
    implements _$ChangeRecordStatusResultCWProxy {
  const _$ChangeRecordStatusResultCWProxyImpl(this._value);

  final ChangeRecordStatusResult _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// ChangeRecordStatusResult(...).copyWith(id: 12, name: "My name")
  /// ```
  ChangeRecordStatusResult call({
    Object? habit = const $CopyWithPlaceholder(),
    Object? origin = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? added = const $CopyWithPlaceholder(),
  }) {
    return ChangeRecordStatusResult(
      habit: habit == const $CopyWithPlaceholder() || habit == null
          ? _value.habit
          // ignore: cast_nullable_to_non_nullable
          : habit as HabitSummaryData,
      origin: origin == const $CopyWithPlaceholder()
          ? _value.origin
          // ignore: cast_nullable_to_non_nullable
          : origin as HabitSummaryRecord?,
      data: data == const $CopyWithPlaceholder() || data == null
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as HabitSummaryRecord,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
      added: added == const $CopyWithPlaceholder() || added == null
          ? _value.added
          // ignore: cast_nullable_to_non_nullable
          : added as bool,
    );
  }
}

extension $ChangeRecordStatusResultCopyWith on ChangeRecordStatusResult {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfChangeRecordStatusResult.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$ChangeRecordStatusResultCWProxy get copyWith =>
      _$ChangeRecordStatusResultCWProxyImpl(this);
}
