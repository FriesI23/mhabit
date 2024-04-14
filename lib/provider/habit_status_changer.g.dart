// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_status_changer.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HabitStatusChangerFormCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// HabitStatusChangerForm(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitStatusChangerForm call({
    HabitDate? selectDate,
    RecordStatusChangerStatus? selectStatus,
    TextEditingController? skipInputController,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHabitStatusChangerForm.copyWith(...)`.
class _$HabitStatusChangerFormCWProxyImpl
    implements _$HabitStatusChangerFormCWProxy {
  const _$HabitStatusChangerFormCWProxyImpl(this._value);

  final HabitStatusChangerForm _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// HabitStatusChangerForm(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitStatusChangerForm call({
    Object? selectDate = const $CopyWithPlaceholder(),
    Object? selectStatus = const $CopyWithPlaceholder(),
    Object? skipInputController = const $CopyWithPlaceholder(),
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
      skipInputController:
          skipInputController == const $CopyWithPlaceholder() ||
                  skipInputController == null
              ? _value.skipInputController
              // ignore: cast_nullable_to_non_nullable
              : skipInputController as TextEditingController,
    );
  }
}

extension $HabitStatusChangerFormCopyWith on HabitStatusChangerForm {
  /// Returns a callable class that can be used as follows: `instanceOfHabitStatusChangerForm.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitStatusChangerFormCWProxy get copyWith =>
      _$HabitStatusChangerFormCWProxyImpl(this);
}
