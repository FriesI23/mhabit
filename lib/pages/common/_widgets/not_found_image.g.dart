// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file
// ignore_for_file: type=lint


part of 'not_found_image.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NotFoundImageStyleCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// NotFoundImageStyle(...).copyWith(id: 12, name: "My name")
  /// ```
  NotFoundImageStyle call({
    Color backBoardBackgroundColor,
    Color backBoardPaperColor,
    Color fronBoardPaperColor,
    Color fronBoardPaperShadowColor,
    Color magnifierHandleColor,
    Color magnifierStrokeColor,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfNotFoundImageStyle.copyWith(...)`.
class _$NotFoundImageStyleCWProxyImpl implements _$NotFoundImageStyleCWProxy {
  const _$NotFoundImageStyleCWProxyImpl(this._value);

  final NotFoundImageStyle _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// NotFoundImageStyle(...).copyWith(id: 12, name: "My name")
  /// ```
  NotFoundImageStyle call({
    Object? backBoardBackgroundColor = const $CopyWithPlaceholder(),
    Object? backBoardPaperColor = const $CopyWithPlaceholder(),
    Object? fronBoardPaperColor = const $CopyWithPlaceholder(),
    Object? fronBoardPaperShadowColor = const $CopyWithPlaceholder(),
    Object? magnifierHandleColor = const $CopyWithPlaceholder(),
    Object? magnifierStrokeColor = const $CopyWithPlaceholder(),
  }) {
    return NotFoundImageStyle(
      backBoardBackgroundColor:
          backBoardBackgroundColor == const $CopyWithPlaceholder() ||
              backBoardBackgroundColor == null
          ? _value.backBoardBackgroundColor
          // ignore: cast_nullable_to_non_nullable
          : backBoardBackgroundColor as Color,
      backBoardPaperColor:
          backBoardPaperColor == const $CopyWithPlaceholder() ||
              backBoardPaperColor == null
          ? _value.backBoardPaperColor
          // ignore: cast_nullable_to_non_nullable
          : backBoardPaperColor as Color,
      fronBoardPaperColor:
          fronBoardPaperColor == const $CopyWithPlaceholder() ||
              fronBoardPaperColor == null
          ? _value.fronBoardPaperColor
          // ignore: cast_nullable_to_non_nullable
          : fronBoardPaperColor as Color,
      fronBoardPaperShadowColor:
          fronBoardPaperShadowColor == const $CopyWithPlaceholder() ||
              fronBoardPaperShadowColor == null
          ? _value.fronBoardPaperShadowColor
          // ignore: cast_nullable_to_non_nullable
          : fronBoardPaperShadowColor as Color,
      magnifierHandleColor:
          magnifierHandleColor == const $CopyWithPlaceholder() ||
              magnifierHandleColor == null
          ? _value.magnifierHandleColor
          // ignore: cast_nullable_to_non_nullable
          : magnifierHandleColor as Color,
      magnifierStrokeColor:
          magnifierStrokeColor == const $CopyWithPlaceholder() ||
              magnifierStrokeColor == null
          ? _value.magnifierStrokeColor
          // ignore: cast_nullable_to_non_nullable
          : magnifierStrokeColor as Color,
    );
  }
}

extension $NotFoundImageStyleCopyWith on NotFoundImageStyle {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfNotFoundImageStyle.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$NotFoundImageStyleCWProxy get copyWith =>
      _$NotFoundImageStyleCWProxyImpl(this);
}
