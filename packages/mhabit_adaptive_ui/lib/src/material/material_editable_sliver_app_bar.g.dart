// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_editable_sliver_app_bar.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MaterialEditableAppBarStyleCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// MaterialEditableAppBarStyle(...).copyWith(id: 12, name: "My name")
  /// ```
  MaterialEditableAppBarStyle call({
    double? scrolledUnderElevation,
    Color? shadowColor,
    Color? backgroundColor,
    Color? surfaceTintColor,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfMaterialEditableAppBarStyle.copyWith(...)`.
class _$MaterialEditableAppBarStyleCWProxyImpl
    implements _$MaterialEditableAppBarStyleCWProxy {
  const _$MaterialEditableAppBarStyleCWProxyImpl(this._value);

  final MaterialEditableAppBarStyle _value;

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// MaterialEditableAppBarStyle(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  MaterialEditableAppBarStyle call({
    Object? scrolledUnderElevation = const $CopyWithPlaceholder(),
    Object? shadowColor = const $CopyWithPlaceholder(),
    Object? backgroundColor = const $CopyWithPlaceholder(),
    Object? surfaceTintColor = const $CopyWithPlaceholder(),
  }) {
    return MaterialEditableAppBarStyle(
      scrolledUnderElevation:
          scrolledUnderElevation == const $CopyWithPlaceholder()
          ? _value.scrolledUnderElevation
          // ignore: cast_nullable_to_non_nullable
          : scrolledUnderElevation as double?,
      shadowColor: shadowColor == const $CopyWithPlaceholder()
          ? _value.shadowColor
          // ignore: cast_nullable_to_non_nullable
          : shadowColor as Color?,
      backgroundColor: backgroundColor == const $CopyWithPlaceholder()
          ? _value.backgroundColor
          // ignore: cast_nullable_to_non_nullable
          : backgroundColor as Color?,
      surfaceTintColor: surfaceTintColor == const $CopyWithPlaceholder()
          ? _value.surfaceTintColor
          // ignore: cast_nullable_to_non_nullable
          : surfaceTintColor as Color?,
    );
  }
}

extension $MaterialEditableAppBarStyleCopyWith on MaterialEditableAppBarStyle {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfMaterialEditableAppBarStyle.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$MaterialEditableAppBarStyleCWProxy get copyWith =>
      _$MaterialEditableAppBarStyleCWProxyImpl(this);
}
