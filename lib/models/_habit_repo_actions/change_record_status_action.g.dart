// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_record_status_action.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChangeRecordStatusResultCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ChangeRecordStatusResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ChangeRecordStatusResult call({
    HabitSummaryData habit,
    HabitSummaryRecord? origin,
    HabitSummaryRecord data,
    String? reason,
    bool added,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChangeRecordStatusResult.copyWith(...)`.
class _$ChangeRecordStatusResultCWProxyImpl
    implements _$ChangeRecordStatusResultCWProxy {
  const _$ChangeRecordStatusResultCWProxyImpl(this._value);

  final ChangeRecordStatusResult _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ChangeRecordStatusResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ChangeRecordStatusResult call({
    Object? habit = const $CopyWithPlaceholder(),
    Object? origin = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? added = const $CopyWithPlaceholder(),
  }) {
    return ChangeRecordStatusResult(
      habit: habit == const $CopyWithPlaceholder()
          ? _value.habit
          // ignore: cast_nullable_to_non_nullable
          : habit as HabitSummaryData,
      origin: origin == const $CopyWithPlaceholder()
          ? _value.origin
          // ignore: cast_nullable_to_non_nullable
          : origin as HabitSummaryRecord?,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as HabitSummaryRecord,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
      added: added == const $CopyWithPlaceholder()
          ? _value.added
          // ignore: cast_nullable_to_non_nullable
          : added as bool,
    );
  }
}

extension $ChangeRecordStatusResultCopyWith on ChangeRecordStatusResult {
  /// Returns a callable class that can be used as follows: `instanceOfChangeRecordStatusResult.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$ChangeRecordStatusResultCWProxy get copyWith =>
      _$ChangeRecordStatusResultCWProxyImpl(this);
}
