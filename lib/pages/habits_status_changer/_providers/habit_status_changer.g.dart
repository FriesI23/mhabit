// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file

part of 'habit_status_changer.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HabitStatusChangerFormCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// HabitStatusChangerForm(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitStatusChangerForm call({
    HabitDate selectDate,
    RecordStatusChangerStatus? selectStatus,
    String? skipReason,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfHabitStatusChangerForm.copyWith(...)`.
class _$HabitStatusChangerFormCWProxyImpl
    implements _$HabitStatusChangerFormCWProxy {
  const _$HabitStatusChangerFormCWProxyImpl(this._value);

  final HabitStatusChangerForm _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// HabitStatusChangerForm(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitStatusChangerForm call({
    Object? selectDate = const $CopyWithPlaceholder(),
    Object? selectStatus = const $CopyWithPlaceholder(),
    Object? skipReason = const $CopyWithPlaceholder(),
  }) {
    return HabitStatusChangerForm(
      selectDate:
          selectDate == const $CopyWithPlaceholder() || selectDate == null
          ? _value.selectDate
          // ignore: cast_nullable_to_non_nullable
          : selectDate as HabitDate,
      selectStatus: selectStatus == const $CopyWithPlaceholder()
          ? _value.selectStatus
          // ignore: cast_nullable_to_non_nullable
          : selectStatus as RecordStatusChangerStatus?,
      skipReason: skipReason == const $CopyWithPlaceholder()
          ? _value.skipReason
          // ignore: cast_nullable_to_non_nullable
          : skipReason as String?,
    );
  }
}

extension $HabitStatusChangerFormCopyWith on HabitStatusChangerForm {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfHabitStatusChangerForm.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitStatusChangerFormCWProxy get copyWith =>
      _$HabitStatusChangerFormCWProxyImpl(this);
}
