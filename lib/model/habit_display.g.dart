// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_display.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HabitsDisplayFilterCWProxy {
  HabitsDisplayFilter allowInProgressHabits(bool allowInProgressHabits);

  HabitsDisplayFilter allowArchivedHabits(bool allowArchivedHabits);

  HabitsDisplayFilter allowCompleteHabits(bool allowCompleteHabits);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HabitsDisplayFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HabitsDisplayFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitsDisplayFilter call({
    bool? allowInProgressHabits,
    bool? allowArchivedHabits,
    bool? allowCompleteHabits,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHabitsDisplayFilter.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHabitsDisplayFilter.copyWith.fieldName(...)`
class _$HabitsDisplayFilterCWProxyImpl implements _$HabitsDisplayFilterCWProxy {
  const _$HabitsDisplayFilterCWProxyImpl(this._value);

  final HabitsDisplayFilter _value;

  @override
  HabitsDisplayFilter allowInProgressHabits(bool allowInProgressHabits) =>
      this(allowInProgressHabits: allowInProgressHabits);

  @override
  HabitsDisplayFilter allowArchivedHabits(bool allowArchivedHabits) =>
      this(allowArchivedHabits: allowArchivedHabits);

  @override
  HabitsDisplayFilter allowCompleteHabits(bool allowCompleteHabits) =>
      this(allowCompleteHabits: allowCompleteHabits);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HabitsDisplayFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HabitsDisplayFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitsDisplayFilter call({
    Object? allowInProgressHabits = const $CopyWithPlaceholder(),
    Object? allowArchivedHabits = const $CopyWithPlaceholder(),
    Object? allowCompleteHabits = const $CopyWithPlaceholder(),
  }) {
    return HabitsDisplayFilter(
      allowInProgressHabits:
          allowInProgressHabits == const $CopyWithPlaceholder() ||
                  allowInProgressHabits == null
              ? _value.allowInProgressHabits
              // ignore: cast_nullable_to_non_nullable
              : allowInProgressHabits as bool,
      allowArchivedHabits:
          allowArchivedHabits == const $CopyWithPlaceholder() ||
                  allowArchivedHabits == null
              ? _value.allowArchivedHabits
              // ignore: cast_nullable_to_non_nullable
              : allowArchivedHabits as bool,
      allowCompleteHabits:
          allowCompleteHabits == const $CopyWithPlaceholder() ||
                  allowCompleteHabits == null
              ? _value.allowCompleteHabits
              // ignore: cast_nullable_to_non_nullable
              : allowCompleteHabits as bool,
    );
  }
}

extension $HabitsDisplayFilterCopyWith on HabitsDisplayFilter {
  /// Returns a callable class that can be used as follows: `instanceOfHabitsDisplayFilter.copyWith(...)` or like so:`instanceOfHabitsDisplayFilter.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitsDisplayFilterCWProxy get copyWith =>
      _$HabitsDisplayFilterCWProxyImpl(this);
}
