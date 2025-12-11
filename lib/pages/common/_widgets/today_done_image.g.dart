// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file
// ignore_for_file: type=lint


part of 'today_done_image.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TodayDoneImageStyleCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TodayDoneImageStyle(...).copyWith(id: 12, name: "My name")
  /// ````
  TodayDoneImageStyle call({
    Color laserColor,
    Color sunColor,
    Color horizonColor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTodayDoneImageStyle.copyWith(...)`.
class _$TodayDoneImageStyleCWProxyImpl implements _$TodayDoneImageStyleCWProxy {
  const _$TodayDoneImageStyleCWProxyImpl(this._value);

  final TodayDoneImageStyle _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TodayDoneImageStyle(...).copyWith(id: 12, name: "My name")
  /// ````
  TodayDoneImageStyle call({
    Object? laserColor = const $CopyWithPlaceholder(),
    Object? sunColor = const $CopyWithPlaceholder(),
    Object? horizonColor = const $CopyWithPlaceholder(),
  }) {
    return TodayDoneImageStyle(
      laserColor: laserColor == const $CopyWithPlaceholder()
          ? _value.laserColor
          // ignore: cast_nullable_to_non_nullable
          : laserColor as Color,
      sunColor: sunColor == const $CopyWithPlaceholder()
          ? _value.sunColor
          // ignore: cast_nullable_to_non_nullable
          : sunColor as Color,
      horizonColor: horizonColor == const $CopyWithPlaceholder()
          ? _value.horizonColor
          // ignore: cast_nullable_to_non_nullable
          : horizonColor as Color,
    );
  }
}

extension $TodayDoneImageStyleCopyWith on TodayDoneImageStyle {
  /// Returns a callable class that can be used as follows: `instanceOfTodayDoneImageStyle.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$TodayDoneImageStyleCWProxy get copyWith =>
      _$TodayDoneImageStyleCWProxyImpl(this);
}
