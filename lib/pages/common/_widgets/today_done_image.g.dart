// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file
// ignore_for_file: type=lint


part of 'today_done_image.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TodayDoneImageStyleCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// TodayDoneImageStyle(...).copyWith(id: 12, name: "My name")
  /// ```
  TodayDoneImageStyle call({
    Color laserColor,
    Color sunColor,
    Color horizonColor,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfTodayDoneImageStyle.copyWith(...)`.
class _$TodayDoneImageStyleCWProxyImpl implements _$TodayDoneImageStyleCWProxy {
  const _$TodayDoneImageStyleCWProxyImpl(this._value);

  final TodayDoneImageStyle _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// TodayDoneImageStyle(...).copyWith(id: 12, name: "My name")
  /// ```
  TodayDoneImageStyle call({
    Object? laserColor = const $CopyWithPlaceholder(),
    Object? sunColor = const $CopyWithPlaceholder(),
    Object? horizonColor = const $CopyWithPlaceholder(),
  }) {
    return TodayDoneImageStyle(
      laserColor:
          laserColor == const $CopyWithPlaceholder() || laserColor == null
          ? _value.laserColor
          // ignore: cast_nullable_to_non_nullable
          : laserColor as Color,
      sunColor: sunColor == const $CopyWithPlaceholder() || sunColor == null
          ? _value.sunColor
          // ignore: cast_nullable_to_non_nullable
          : sunColor as Color,
      horizonColor:
          horizonColor == const $CopyWithPlaceholder() || horizonColor == null
          ? _value.horizonColor
          // ignore: cast_nullable_to_non_nullable
          : horizonColor as Color,
    );
  }
}

extension $TodayDoneImageStyleCopyWith on TodayDoneImageStyle {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfTodayDoneImageStyle.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$TodayDoneImageStyleCWProxy get copyWith =>
      _$TodayDoneImageStyleCWProxyImpl(this);
}
